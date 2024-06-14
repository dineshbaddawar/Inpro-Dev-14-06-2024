@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string json = ' {"access_token":"432","login":"PSC-0057","apiKey":"testApi"}';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}