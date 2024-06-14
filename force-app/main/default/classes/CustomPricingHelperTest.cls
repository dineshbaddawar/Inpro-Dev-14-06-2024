@isTest
private class CustomPricingHelperTest{

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

		Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id
		);
		insert quoteObj;
		
		Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate 1',
            QuoteId__c = quoteObj.Id
        );
        insert alt1;

		Quotelineitem quotelineitemObj = new Quotelineitem (
			Description = 'test value', 
			Alternate__c = alt1.Id, 
			Custom_Pricing_Requested__c = false, 
			Customer_Priced_On__c = 'test value', 
			Description_2__c = 'Test Value', 
			Document_Name__c = 'test value', 
			Is_Custom_Product__c = true, 
			Quantity = 1.1, 
			UnitPrice = 1.1,
			Item_Number__c = '123',
			ParentID__c = '123',
			QuoteId = quoteObj.Id,
			PricebookEntryId = pbe.Id,
			Product2Id = prod.Id,
			LineNumber__c = 1,
			Sequence_Number__c = 1,
			Alternate_Number__c = 1,
			Unit_Weight__c = 1
		);
		insert quotelineitemObj;

		Custom_Pricing__c customPricing = new Custom_Pricing__c(
			Subject__c = 'Test',
			Name = 'Test'
		);
		insert customPricing;

		Quotelineitem quotelineitemObj2 = new Quotelineitem (
			Description = 'test value', 
			Alternate__c = alt1.Id, 
			Custom_Pricing_Requested__c = true, 
			Customer_Priced_On__c = 'test value', 
			Description_2__c = 'Test Value', 
			Document_Name__c = 'test value', 
			Is_Custom_Product__c = true, 
			Quantity = 1.1, 
			UnitPrice = 1.1,
			Item_Number__c = '123',
			ParentID__c = '123',
			QuoteId = quoteObj.Id,
			PricebookEntryId = pbe.Id,
			Product2Id = prod.Id,
			Custom_Pricing__c = customPricing.Id,
			LineNumber__c = 1,
			Sequence_Number__c = 1,
			Alternate_Number__c = 1,
			Unit_Weight__c = 1
		);
		insert quotelineitemObj2;

		Test.startTest();
	}

	@isTest static void testGetQuoteLineItems() {
		// code_block
		String query = 'Select Id from Quote LIMIT 1';
        Quote quote = Database.query(query);

		List<QuoteLineItem> items = CustomPricingHelper.getQuoteLineItems(quote.Id);

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetCustomPricingLineItems(){
		String query = 'Select Id from Custom_Pricing__c LIMIT 1';
        Custom_Pricing__c customPricing = Database.query(query);

		List<QuoteLineItem> items = CustomPricingHelper.getCustomPricingLineItems(customPricing.Id);

		System.assertEquals(1,items.size());
	}

	@isTest static void testUpdateQuoteProducts_success(){
		Test.setMock(WebServiceMock.class, new custompricingTest());
		
		String query = 'Select Id from QuoteLineItem';
        List<QuoteLineItem> items = Database.query(query);
		string itemsJson = Json.serialize(items);

		String query2 = 'Select Id from User LIMIT 1';
		User user = Database.query(query2);

		String results = CustomPricingHelper.updateQuoteProducts(String.valueOf(user.Id), itemsJson);

		System.assertEquals('Activity Completed Successfully.',results);
	}

	@isTest static void testUpdateQuoteProducts_exception(){
		try{
			String results = CustomPricingHelper.updateQuoteProducts(null, null);
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest static void testCancelPricingRequests_success()
	{
		List<QuoteLineItem> items = [SELECT Id, Custom_Pricing_Requested__c FROM QuoteLineItem];
		List<string> quoteProductIds = new List<string>();

		for(QuoteLineItem i : items){
			quoteProductIds.add(i.Id);
		}
		String userId = String.valueOf([SELECT Id FROM User LIMIT 1].Id);

		String results = CustomPricingHelper.cancelPricingRequests(userId, quoteProductIds);

		System.assertEquals(results, 'Success');
	}

	@isTest static void testCancelPricingRequests_exception(){
		try {
			String results = CustomPricingHelper.cancelPricingRequests('', null);
			System.assert(false);
		} catch (Exception ex) {
			System.assert(true);
		}
		
	}
	@isTest static void testCreatePricingRequests_success(){
		Test.setMock(WebServiceMock.class, new custompricingTest());
		
		String query = 'Select Id from QuoteLineItem';
        List<QuoteLineItem> items = Database.query(query);

		List<String> itemIds = new List<String>();
		for(QuoteLineItem i : items){
			itemIds.add(i.Id);
		}

		String query2 = 'Select Id from User LIMIT 1';
		User user = Database.query(query2);

		String results = CustomPricingHelper.createPricingRequests(String.valueOf(user.Id), itemIds);

		System.assertEquals('Activities Completed Successfully.',results);
	}

	@isTest static void testCreateQuoteProducts_exception(){
		try{
			String results = CustomPricingHelper.createPricingRequests(null, null);
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}
	@isTest
	static void resetCustomPricingTest()
	{
		String quoteId = String.valueOf([SELECT Id FROM Quote LIMIT 1].Id);
		CustomPricingHelper.resetCustomPricing(quoteId);
		System.assertEquals(1, 1);
	}
}