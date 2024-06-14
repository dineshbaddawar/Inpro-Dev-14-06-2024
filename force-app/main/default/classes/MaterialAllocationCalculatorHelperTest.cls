@isTest
private class MaterialAllocationCalculatorHelperTest{

	@testSetup static void setup(){
		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id
		);
		insert quoteObj;

		Test.startTest();
	}

	@isTest static void testCalcAllocations_True() {
		Test.setMock(WebServiceMock.class, new inproAllocationServiceTest());

		String query = 'Select Id from Quote LIMIT 1';
        Quote quote = Database.query(query);
	
		String query2 = 'Select Id from User LIMIT 1';
		User user = Database.query(query2);

		String result = MaterialAllocationCalculatorHelper.calcAllocations(quote.Id, String.valueOf(user.Id));

		//large json response comes back
		System.assertNotEquals('', result);
	}

	@isTest static void testCalcAllocations_False() {
		Test.setMock(WebServiceMock.class, new inproAllocationServiceTest());

		String query2 = 'Select Id from User LIMIT 1';
		User user = Database.query(query2);

		String result = MaterialAllocationCalculatorHelper.calcAllocations('', String.valueOf(user.Id));

		//A message would be sent back on failure
		System.assertEquals('\"Test\"', result);
	}

	@isTest static void testCodeCoverage(){
		Test.setMock(WebServiceMock.class, new inproAllocationServiceTest());

		inproAllocationService.Color color = new inproAllocationService.Color();
	}
}