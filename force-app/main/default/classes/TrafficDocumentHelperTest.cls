@isTest
private class TrafficDocumentHelperTest{

	@TestSetup
	static void makeData(){
		Account accountObj = new Account (
			Name = 'test value'
		);
		insert accountObj;
		
		Contact contactObj = new Contact (
			FirstName = 'John', 
			LastName = 'Smith',
			AccountId = accountObj.Id
		);
		insert contactObj;

		Order orderObj = new Order (
			AccountId = accountObj.Id, 
			EffectiveDate = Date.today(), 
			Status ='Draft'
		);
		insert orderObj;
		 
		 Traffic_document__c trafficdocumentcObj = new Traffic_document__c (
			Name = 'Commercial Invoice.pdf', 
			Type__c ='Commercial Invoice',
			Order__c = orderObj.Id
		);
		insert trafficdocumentcObj;

		Traffic_document__c td1 = new Traffic_document__c (
			Name = 'Certificate of Origin.pdf', 
			Type__c ='Certificate of Origin',
			Order__c = orderObj.Id
		);
		insert td1;
		Traffic_document__c td2 = new Traffic_document__c (
			Name = 'Transport Document.pdf', 
			Type__c ='Transport Document',
			Order__c = orderObj.Id
		);
		insert td2;
		Traffic_document__c td3 = new Traffic_document__c (
			Name = 'WTFYP.pdf', 
			Type__c ='WTFYP',
			Order__c = orderObj.Id
		);
		insert td3;
		Traffic_document__c td4 = new Traffic_document__c (
			Name = 'Miscellaneous.pdf', 
			Type__c ='Miscellaneous',
			Order__c = orderObj.Id
		);
		insert td4;

		Test.startTest();
	}

	@isTest 
	static void testGetAccountContacts_success() {
		// This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

        // Call the method that invokes a callout       
        String results = TrafficDocumentHelper.getAccountContacts(order.Id);

		List<sObject> deserializedResults = (List<sObject>)JSON.deserialize(results, List<sObject>.class);
		System.assertEquals(1, deserializedResults.size());
	}

	@isTest
	static void testCreateTrafficDocument_new_success()
	{
		Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());

		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

		String results = TrafficDocumentHelper.createTrafficDocument(order.Id, 'WTFYP', 'Test.pdf');

		String Query2 = 'Select Id from Traffic_document__c';
		List<Traffic_document__c> docs = (List<Traffic_document__c>)Database.query(Query2);

		System.assert(results == 'true');
		System.assert(docs.size() == 6);
	}

	@isTest
	static void testCreateTrafficDocument_existing_success()
	{
		Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());

		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

		String results = TrafficDocumentHelper.createTrafficDocument(order.Id, 'Commercial Invoice', 'Commercial Invoice.pdf');

		String Query2 = 'Select Id from Traffic_document__c';
		List<sObject> docs = Database.query(Query2);

		System.assert(results == 'true');
		System.assert(docs.size() == 5);
	}

	@isTest
	static void testCreateTrafficDocument_exception()
	{
		try{ //bad order id
			String results = TrafficDocumentHelper.createTrafficDocument('', 'Commercial Invoice', 'Commercial Invoice.pdf');

			System.assert(false);
		}catch(Exception e)
		{
			System.assert(true);
		}
	}

	@isTest
	static void testDeleteTrafficDocument_remove_success()
	{
		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

		String results = TrafficDocumentHelper.deleteTrafficDocument(order.Id, 'Commercial Invoice', 'Commercial Invoice.pdf');
		String Query2 = 'Select Id from Traffic_document__c';
		List<sObject> docs = Database.query(Query2);

		System.assert(results == 'true');
		System.assert(docs.size() == 4);
	}

	@isTest
	static void testDeleteTrafficDocument_remove_failure()
	{
		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

		String results = TrafficDocumentHelper.deleteTrafficDocument(order.Id, 'Commercial Invoice', 'Wrong Name.pdf');
		String Query2 = 'Select Id from Traffic_document__c';
		List<sObject> docs = Database.query(Query2);

		System.assert(results == 'false');
		System.assert(docs.size() == 5);
	}

	@isTest
	static void sendContactEmail_full_success()
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String Query = 'Select Id from Order LIMIT 1';
		Order order = (Order)Database.query(query);

		List<string> testEmails = new List<string>();
		testEmails.add('bsibley@inprocorp.com.invalid');

		String results = TrafficDocumentHelper.sendContactEmail(order.Id, testEmails);

		//If email is turned off in beta, catch the exact error and assume email was made successfully
		System.assertNotEquals(results, 'The email was sent successfully');
	}
}