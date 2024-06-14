@isTest
private class CustomPartNumberConfigHelperTest{

	@testSetup 
	static void setup(){
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

		Task taskObj = new Task (
			WhatId = quote.Id, 
			Subject = 'AddShortDescriptionHere'
		);
		insert taskObj;
		Quote_action__c quoteactioncObj = new Quote_action__c (
			QuoteId__c = quote.Id,
			TaskId__c = taskObj.Id
		);
		insert quoteactioncObj;

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

	@isTest 
	static void testGetCustomPartNumbers_success() {
		String query = 'Select Id, TaskId__c from Quote_action__c LIMIT 1';
		Quote_action__c quoteAction = (Quote_action__c)Database.query(query);

		String jsonResults = CustomPartNumberConfigHelper.getCustomPartNumbers(quoteAction.TaskId__c);
		sObject[] lineItems = (sObject[])JSON.deserialize(jsonResults, sObject[].class);

		System.assertEquals(lineItems.size(), 1);
		// code_block	
	}

	@isTest 
	static void testGetCustomPartNumbers_exception() {
		try{
			String jsonResults = CustomPartNumberConfigHelper.getCustomPartNumbers('');
			System.assert(false);
		}catch(Exception e){
			System.assert(true);
		}
	}

	@isTest
	static void testUpdateCustomPartNumbers_success(){
		String query = 'SELECT QuoteId, Id, UnitPrice FROM Quotelineitem LIMIT 1';
		Quotelineitem item = (Quotelineitem)Database.query(query);

		item.UnitPrice = 2.0;
		List<Quotelineitem> items = new List<Quotelineitem>();
		items.add(item);

		String message = CustomPartNumberConfigHelper.updateCustomPartNumbers(JSON.serialize(items));

		Quotelineitem itemUpdated = (Quotelineitem)Database.query(query);

		System.assertEquals(message, 'success');
		System.assertEquals(itemUpdated.UnitPrice, 2.0);
	}

	@isTest 
	static void testUpdateCustomPartNumbers_exception() {
		String query = 'SELECT QuoteId, Id, UnitPrice FROM Quotelineitem LIMIT 1';
		Quotelineitem item = (Quotelineitem)Database.query(query);

		String message = CustomPartNumberConfigHelper.updateCustomPartNumbers(JSON.serialize(item));

		System.assertNotEquals(message, 'success');
	}
}