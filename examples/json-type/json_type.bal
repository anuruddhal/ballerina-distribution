import ballerina/io;

type Student record {|
    int id;
    string name;
|};
 
public function main() returns error? {
    // Since json is a union: ()|boolean|int|float|decimal|string|json[]|map<json>,
    // the following cases are allowed
    json n = null;
    json i = 21;
    json s = "str";
    json a = [1, 2];
    json m = {"x": n, "y": s, "z": a};
    io:println(m);
    json[] arr = [m, {"x": i}];
    io:println(arr);
 
	string rawData = "{\"id\": 2, \"name\": \"Georgy\"}";
	// Get `json` value from string
	json j = check rawData.fromJsonString();
	io:println(j);
 
	// Access fields of `j` using field access
	string name = check j.name;
	io:println(name);
 
	// Convert `json` into a user-defined type
	Student student = check j.cloneWithType();
	io:println(student.id);
 
	// Convert user defined type to a `json`
	j = student;
	io:println(j);
}
