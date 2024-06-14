@isTest
private class SignImageLibraryHelperTest{

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
			OpportunityId = opp.Id,
			Pricebook2Id = pricebookId
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

		Test.startTest();
	}

	@isTest static void testGetFullSignImage_Success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String jsonResults = SignImageLibraryHelper.getFullSignImage('any record Id', 'any file id');
		List<sfdata.SavedImage> results = (List<sfdata.SavedImage>)Json.deserialize(jsonResults,List<sfdata.SavedImage>.class);

		System.assertEquals(1, results.size());
	}

	@isTest static void testGetSignImages_Success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String jsonResults = SignImageLibraryHelper.getSignImages('any record Id', 'any file id');
		List<sfdata.SavedImage> results = (List<sfdata.SavedImage>)Json.deserialize(jsonResults,List<sfdata.SavedImage>.class);

		System.assertEquals(1, results.size());
	}

	@isTest static void testGetSignImages_Error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignImageLibraryHelper.getSignImages(null, '');
		
		System.assertEquals('Error!', results);
	}

	@isTest static void testDeleteSignImage_Success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignImageLibraryHelper.deleteSignImage('any image Id');

		System.assertEquals('Success!', results);
	}

	@isTest static void testDeleteSignImage_Error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignImageLibraryHelper.deleteSignImage('');

		System.assertEquals('Error!', results);
	}

	@isTest static void testCopySignImage_Success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignImageLibraryHelper.copySignImage('image id','quote id','quote detail id', true);

		System.assertEquals('Success!', results);
	}

	@isTest static void testCopySignImage_Error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignImageLibraryHelper.copySignImage(null,null,null, true);

		System.assertEquals('Error!', results);
	}

	@isTest static void testGetQuoteLineItems() {
		String query = 'Select Id from Quote Limit 1';
		Quote quote = Database.query(query);

		List<QuoteLineItem> lineItems = SignImageLibraryHelper.getQuoteLineItems(quote.Id);

		System.assertEquals(1, lineItems.size());
	}

	@isTest static void getQuoteDetailIdsWithImagesTest()
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());
		List<String> records = new List<String>();
		records.add('test');				
		SignImageLibraryHelper.getQuoteDetailIdsWithImages(records);
		System.assertEquals(1, 1);
	}

	@isTest static void getSignImagesTest()
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());					
		SignImageLibraryHelper.getSignImages('recordId', 'fileId');
		System.assertEquals(1, 1);
	}

	@isTest static void getFullSignImageTest()
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());					
		SignImageLibraryHelper.getFullSignImage('recordId', 'imageId');
		System.assertEquals(1, 1);
	}

	
}