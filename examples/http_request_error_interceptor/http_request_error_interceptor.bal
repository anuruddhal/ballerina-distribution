import ballerina/http;
import ballerina/io;

// Header name checked by the first request interceptor.
final string interceptor_check_header = "X-requestCheckHeader";

// Header value to be set to the request in the request error interceptor.
final string interceptor_check_header_value = "RequestErrorInterceptor";

service class RequestInterceptor1 {
    *http:RequestInterceptor;

    resource function 'default [string... path](http:RequestContext ctx, http:Request req) returns http:NextService|error? {
        io:println("Executing Request Interceptor 1");
        // Try to read header. This will return a `HeaderNotFoundError` if we do not set this header. Then the execution will 
        // jump to the nearest `RequestErrorInterceptor`.
        string checkHeader = check req.getHeader(interceptor_check_header);
        io:println("Check Header Value : " + checkHeader);
        return ctx.next();
    }
}

RequestInterceptor1 requestInterceptor1 = new;

service class RequestInterceptor2 {
    *http:RequestInterceptor;

    resource function get greeting(http:RequestContext ctx) returns http:NextService|error? {
        io:println("Executing Request Interceptor 2");
        return ctx.next();
    }
}

RequestInterceptor2 requestInterceptor2 = new;

// A Request Error Interceptor service class implementation. It intercepts the Request when an error occurred in the interceptor execution
// and adds a header before it dispatched to the target HTTP Resource. A Request Error Interceptor service class also can have only one resource function.
service class RequestErrorInterceptor {
    *http:RequestErrorInterceptor;

    // The resource function inside an `RequestErrorInterceptor` is only allowed to have default method and default path. The error occurred
    // in the interceptor execution can be accessed by the `error` parameter.
    resource function 'default [string... path](http:RequestContext ctx, http:Request req, error err) returns http:NextService|error? {
        io:println("Executing Request Error Interceptor");
        io:println("Error occurred : " + err.message());
        // Sets a header to the request.
        req.setHeader(interceptor_check_header, interceptor_check_header_value);
        return ctx.next();
    }
}

// Creates a new Request Error Interceptor
RequestErrorInterceptor requestErrorInterceptor = new;

listener http:Listener interceptorListener = new http:Listener(9090, config = { 
    // `RequestErrorInterceptor` can be added anywhere in the interceptor pipeline.
    interceptors: [requestInterceptor1, requestInterceptor2, requestErrorInterceptor] 
});

service / on interceptorListener {

    resource function get greeting(http:Request req, http:Caller caller) returns error? {
        io:println("Executing Target Resource");
        // Create a new response.
        http:Response res = new;
        // Set the headers from request
        res.setHeader(interceptor_check_header, check req.getHeader(interceptor_check_header));
        res.setTextPayload("Greetings!");
        check caller->respond(res);
    }
}
