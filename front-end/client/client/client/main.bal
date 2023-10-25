import ballerina/http;
import ballerina/graphql;
import ballerina/io;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = "";
configurable string password = "";
configurable string database = "";
configurable string collection = "";

mongodb:ClientConfig mongoConfig = {
    host: host,
    port: port,
    // username: username,
    // password: password,
    options: {sslEnabled: false, serverSelectionTimeout: 5000}
};

mongodb:Client mongoClient = checkpanic new (mongoConfig, database);

public client class PerformanceManagementClient {
    const string GRAPHQL_ENDPOINT = "https://api.github.com/graphql";
    graphql:Client|graphql:ClientError graphqlClient = new (GRAPHQL_ENDPOINT);

    public function init(http:ClientConfiguration clientConfig = {}) {
        graphqlClient.initClient(clientConfig);
    }

    public function createDepartmentObjectives(string departmentId, string objectives) returns string|graphql:ClientError {
        string mutation = string `mutation ($departmentId: ID!, $objectives: String!) {
                createDepartmentObjectives(departmentId: $departmentId, objectives: $objectives)
            }`;

        map<anydata> variables = {"departmentId": departmentId, "objectives": objectives};

        json graphqlResponse = check graphqlClient->executeWithType(mutation, variables);

        if (graphqlResponse is json) {
            return graphqlResponse.toString();
        } else if (graphqlResponse is graphql:ClientError) {
            return graphqlResponse;
        }

        return "Unknown response";
    }

    public function deleteDepartmentObjectives(string departmentId) returns string|graphql:ClientError {
        string mutation = string `mutation ($departmentId: ID!) {
                deleteDepartmentObjectives(departmentId: $departmentId)
            }`;

        map<anydata> variables = {"departmentId": departmentId};

        json graphqlResponse = check graphqlClient->executeWithType(mutation, variables);

        if (graphqlResponse is json) {
            return graphqlResponse.toString();
        } else if (graphqlResponse is graphql:ClientError) {
            return graphqlResponse;
        }

        return "Unknown response";
    }

    public function viewEmployeesTotalScores(string departmentId) returns json|graphql:ClientError {
        string query = string `query ($departmentId: ID!) {
                viewEmployeesTotalScores(departmentId: $departmentId)
            }`;

        map<anydata> variables = {"departmentId": departmentId};

        json graphqlResponse = check graphqlClient->executeWithType(query, variables);

        if (graphqlResponse is json) {
            return graphqlResponse;
        } else if (graphqlResponse is graphql:ClientError) {
            return graphqlResponse;
        }

        return "Unknown response";
    }

    // Implement other client-side functions as needed.

    public function main() {
        PerformanceManagementClient client = new ();

        // Example: Create department objectives
        string result = client.createDepartmentObjectives("dept123", "Improve productivity");

        if (result is string) {
            io:println("Department objectives created: " + result);
        } else if (result is graphql:ClientError) {
            io:println("GraphQL Request failed: " + result.message);
        } else {
            io:println("Unknown response type");
        }

        // Example: Delete department objectives
        string deleteResult = client.deleteDepartmentObjectives("dept123");

        if (deleteResult is string) {
            io:println("Department objectives deleted: " + deleteResult);
        } else if (deleteResult is graphql:ClientError) {
            io:println("GraphQL Request failed: " + deleteResult.message);
        } else {
            io:println("Unknown response type");
        }

        // Example: View employees' total scores
        json scoresResult = client.viewEmployeesTotalScores("dept123");

        if (scoresResult is json) {
            io:println("Employees' total scores: " + scoresResult.toString());
        } else if (scoresResult is graphql:ClientError) {
            io:println("GraphQL Request failed: " + scoresResult.message);
        } else {
            io:println("Unknown response type");
        }
    }
}
