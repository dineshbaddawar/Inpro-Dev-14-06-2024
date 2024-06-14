@isTest
private class ReviewAllDivisionsHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;


        Account testAccount = new Account(name = 'Test Account');
        insert testAccount;

        Construction_Project__c cp = new Construction_Project__c(
            Project_Number__c = '12345'
        );
        insert cp;

        Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
            Construction_Project__c = cp.Id,
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
            Project_Number__c = '12345'
		);
		insert opp;

        Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id
		);
		insert quoteObj;
		
		Test.startTest();
	}

	@isTest static void testSendDivisionReviewRequest() {
		Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
		User user = [SELECT Id FROM User LIMIT 1];
		ReviewAllDivisionsHelper.DivisionalReviewRequest request = new ReviewAllDivisionsHelper.DivisionalReviewRequest();
		request.DivisionName = 'IPC';
		request.Notes = 'Test';
		request.ISR = user.Id;
		List<ReviewAllDivisionsHelper.DivisionalReviewRequest> requests = new List<ReviewAllDivisionsHelper.DivisionalReviewRequest>{request};
		Construction_Project__c cp = [SELECT Id, Project_Number__c FROM Construction_Project__c LIMIT 1];

		string result = ReviewAllDivisionsHelper.sendDivisionReviewRequest(requests, cp.Id,cp.Project_Number__c);

		System.assertEquals('Success!', result);

	}

	@isTest static void testRetrieveConstructionProject() {
		Construction_Project__c cp = [SELECT Id, Project_Number__c FROM Construction_Project__c LIMIT 1];
		Construction_Project__c cp2 = ReviewAllDivisionsHelper.retrieveConstructionProject(cp.Id);
		System.assertEquals(cp.Id, cp2.Id);
	}
}