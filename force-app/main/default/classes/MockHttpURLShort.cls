@isTest
global class MockHttpURLShort implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string json = ' {"status_code":200,"status_txt":"OK","data":{"url":"http://bit.ly/2xccbj8","hash":"2xccbj8","global_hash":"2xbLXgL","long_url":"https://lunchandlearns-developer-edition.na59.force.com/LandL/LandLSiteHomePage1?Id=00Uf4000001MqBs","new_hash":1}}';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}