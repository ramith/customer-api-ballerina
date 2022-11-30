import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public type Customer record {
    @sql:Column {name: "account_id"}
    string accountId;
    @sql:Column {name: "first_name"}
    string firstName;
    @sql:Column {name: "last_name"}
    string lastName;

    @sql:Column {name: "kyc_status"}
    string kycStatus;
};

configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = 3306;

mysql:Client mysqlEp = check new (host = dbHost, user = dbUser, password = dbPassword, database = dbName, port = dbPort);

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource get customer given the account id 
    # + accountId - the account id of the customer
    # + return - the customer or an error or nothing
    resource function get customer/[string accountId]() returns Customer| http:NotFound | error {
        Customer|error customer = mysqlEp->queryRow(sqlQuery = `SELECT * FROM customer WHERE account_Id = ${accountId}`);
        if customer is sql:NoRowsError {
            return http:NOT_FOUND;
        }
        return customer;
    }
}
