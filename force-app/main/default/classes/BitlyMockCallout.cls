/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      This is the mock interface to inercept the Bitly 
*				URL callout during other test classes.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
*
************************************************************/
@isTest
global class BitlyMockCallout implements HttpCalloutMock {
	global static HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"created_at": "2023-03-07T05:37:44+0000","id": "bitly.is/sampleId","link": "https://bitly.is/sampleLink","custom_bitlinks": [],"long_url": "https://dev.bitly.com/","archived": false,"tags": [],"deeplinks": [],"references": {"group": "https://group"}}');
		res.setStatusCode(200);
		return res;
	}
}