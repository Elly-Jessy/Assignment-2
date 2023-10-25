import ballerina/http;
import ballerinax/mongodb;
import ballerina/graphql;

// Define Data Models
type DepartmentObjectives record {
    string departmentName;
    map<string> objectives;
};

type EmployeeKPI record {
    string kpiName;
    string unit;
    float score;
};

type Employee record {
    string empId;
    string departmentName;
    string supervisorId;
    map<string> kpis;
};

type Supervisor record {
    string supervisorId;
    string empId;
};

// MongoDB Configuration
mongodb:Client|mongodb:DatabaseError|mongodb:ApplicationError|error mongodbClient = new ({
    host: "localhost",
    port: 27017
});

// Define MongoDB Collections
// mongodb:Collection departmentObjectivesCollection = mongodbClient["departmentObjectives"];
// mongodb:Collection employeeKpiCollection = mongodbClient["employeeKPI"];
// mongodb:Collection employeeCollection = mongodbClient["employee"];
// mongodb:Collection supervisorCollection = mongodbClient["supervisor"];

// Define GraphQL Schema
graphql:TypeDefinitions departmentObjectivesTypeDefs = `
    type DepartmentObjectives {
        departmentName: String
        objectives: [String: String]
    }
`;

graphql:TypeDefinitions employeeKpiTypeDefs = `
    type EmployeeKPI {
        kpiName: String
        unit: String
        score: Float
    }
`;

graphql:TypeDefinitions employeeTypeDefs = `
    type Employee {
        empId: String
        departmentName: String
        supervisorId: String
        kpis: [EmployeeKPI]
    }
`;

graphql:TypeDefinitions supervisorTypeDefs = `
    type Supervisor {
        supervisorId: String
        empId: String
    }
`;

// Define GraphQL Query and Mutation Types
graphql:TypeDefinitions queryTypeDefs = `
    type Query {
        viewDepartmentObjectives(departmentName: String): DepartmentObjectives
        viewEmployeeKPI(empId: String): [EmployeeKPI]
        viewEmployee(empId: String): Employee
        viewSupervisor(supervisorId: String): Supervisor
    }
`;

graphql:TypeDefinitions mutationTypeDefs = `
    type Mutation {
        createDepartmentObjectives(departmentName: String, objectives: [String: String]): DepartmentObjectives
        createEmployeeKPI(empId: String, kpiName: String, unit: String, score: Float): EmployeeKPI
        assignEmployeeToSupervisor(empId: String, supervisorId: String): Employee
        approveEmployeeKPI(empId: String, kpiName: String): EmployeeKPI
        deleteEmployeeKPI(empId: String, kpiName: String): EmployeeKPI
        updateEmployeeKPI(empId: String, kpiName: String, newScore: Float): EmployeeKPI
        gradeEmployeeKPI(empId: String, kpiName: String, grade: String): EmployeeKPI
        gradeSupervisor(supervisorId: String, empId: String): Supervisor
    }
`;

// Create GraphQL Service
graphql:Service employeeService
 on new graphql:Listener(8080) {
    typeDefs:[departmentObjectivesTypeDefs , employeeKpiTypeDefs, employeeTypeDefs, supervisorTypeDefs, queryTypeDefs, mutationTypeDefs];

    // Implement GraphQL resolvers here
};

public function main() {
    // Start the GraphQL service
    employeeService.start();
}
