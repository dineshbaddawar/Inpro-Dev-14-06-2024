@isTest
private class CalculateAlternateYardageHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId
		);
		insert opp;
		Quote quote = new Quote(
			Name = 'Test',
			OpportunityId = opp.Id
		);
		insert quote;

		Quotelineitem quotelineitemObj = new Quotelineitem (
			Description = 'test value', 
			Description_2__c = 'Test Value', 
			Item_Number__c = 'Custom-DW', 
			Custom_Part_Number__c = 'test value', 
			Quantity = 1.1, 
			UnitPrice = 1.1,
			QuoteId = quote.Id,
			Product2Id = prod.Id,
			PricebookEntryId = pbe.Id,
			LineNumber__c = 1,
			Sequence_Number__c = 1,
			Alternate_Number__c = 1,
			Unit_Weight__c = 1
		);
		insert quotelineitemObj;
	}

	@isTest static void testGetQuoteProducts() {
		String Query = 'Select Id from Quote LIMIT 1';
		sObject q = Database.query(Query);
		List<QuoteLineItem> results = CalculateAlternateYardageHelper.GetQuoteProducts(q.Id);

		System.assert(true, results.size() == 1);
	}
}