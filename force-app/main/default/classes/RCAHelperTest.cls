@isTest
private class RCAHelperTest{

	@testSetup static void setup(){
		RCA__c rca = new RCA__c(

		);
		insert rca;

		Test.startTest();
	}

	@isTest static void testSubmitRCARequest() {
		Test.setMock(WebServiceMock.class, new InproRCATest());

		String results = RCAHelper.SubmitRCARequest('12345');

		System.assertEquals('Success', results);
	}

	@isTest static void testSendRCAToNetSuite() {
		Test.setMock(WebServiceMock.class, new InproRCATest());

		String results = RCAHelper.SendRCAToNetSuite('12345');
		
		System.assertEquals('Success', results);
	}

	@isTest static void testApproveRCARequest() {
		Test.setMock(WebServiceMock.class, new InproRCATest());

		String results = RCAHelper.ApproveRCARequest('12345', 'notes', 'userId');
		
		System.assertEquals('Success', results);
	}

	@isTest static void testRejectRCARequest() {
		Test.setMock(WebServiceMock.class, new InproRCATest());

		String results = RCAHelper.RejectRCARequest('12345', 'notes', 'userId');
		
		System.assertEquals('Success', results);
	}

	@isTest static void testCreateRCARequest() {
		Test.setMock(WebServiceMock.class, new InproRCATest());

		String results = RCAHelper.CreateRCARequest('rycaType', 'orderNumber', 'invoiceNumber', 'createdById');
		
		System.assertEquals('Success', results);
	}

	@isTest static void testGetCurrentRCA() {
		Test.setMock(WebServiceMock.class, new InproRCATest());
		String query = 'Select Id from RCA__c LIMIT 1';
		RCA__c rca = Database.query(query);

		List<RCA__c> results = RCAHelper.GetCurrentRCA(rca.Id);
		
		System.assertEquals(1, results.size());
	}

	@isTest static void testRCACoverage(){
		Test.setMock(WebServiceMock.class, new InproRCATest());

		InproRCA.RetrieveOrderTax_element test = new InproRCA.RetrieveOrderTax_element();
		test.City = 'Wausau'; test.Country = 'US'; test.LineItemAmounts = new InproRCA.ArrayOfDouble();
		test.PostalCode = '54401'; test.ShippingAmount = 1.0; test.State = 'WI'; 
		test.StreetAddress1 ='123 Test St'; test.StreetAddress2 = '1'; test.token = '12345';
		
		InproRCA.RetrieveOrderTaxResponse_element test2 = new InproRCA.RetrieveOrderTaxResponse_element();
		test2.RetrieveOrderTaxResult = new InproRCA.RetrieveOrderTaxResult();
		test2.RetrieveOrderTaxResult.Tax = 1.0;

		InproRCA.CreateRCARecordFromStagingResponse_element test3 = new InproRCA.CreateRCARecordFromStagingResponse_element();
		test3.CreateRCARecordFromStagingResult = new InproRCA.JobStatus();
		test3.CreateRCARecordFromStagingResult.Message = '';
		test3.CreateRCARecordFromStagingResult.Status = true;

		InproRCA.RetrieveRCANumberResult test4 = new InproRCA.RetrieveRCANumberResult();
		test4.RCANumber = 1.0;

		InproRCA.RetrieveRCANumberResponse_element test5 = new InproRCA.RetrieveRCANumberResponse_element();
		test5.RetrieveRCANumberResult = new InproRCA.RetrieveRCANumberResult();
		test5.RetrieveRCANumberResult.RCANumber = 1.0;

		InproRCA.CreateRCARecordFromStaging_element test6 = new InproRCA.CreateRCARecordFromStaging_element();
		test6.sOrderNumber = '';
		test6.sQuoteID = '';
		test6.token = '';

		InproRCA.RejectRCARequest_element test7 = new InproRCA.RejectRCARequest_element();
		test7.rcaId = '';
		test7.rejectionNotes = '';
		test7.token = '';
		test7.userId = '';

		InproRCA.RetrieveRCANumber_element test8 = new InproRCA.RetrieveRCANumber_element();
		test8.token = '';

		InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
		service.timeout_x = 120000;
		service.RetrieveRCANumber('dsj8U73_3nv3Dhba');
		service.RetrieveOrderTax('test', new InproRCA.ArrayOfDouble(), 1.0, 'Wausau', 'US', '54401', 'WI', '123', '123');
		service.CreateRCARecordFromStaging('test','test','test');
	}
}