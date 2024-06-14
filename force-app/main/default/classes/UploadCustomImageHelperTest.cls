@isTest
private class UploadCustomImageHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;
		List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');

		Contact contact = new Contact(
            AccountId = accounts.get(0).Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

		Division__c endurantDiv = new Division__c(
			Name = 'Endurant'
		);
		insert endurantDiv;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
			AccountId = accounts.get(0).id,
			Division_Lookup__c = endurantDiv.Id
		);
		insert opp;

		Quote quote = new Quote (
			Name = 'test value', 
			OpportunityId = opp.Id
		);
		insert quote;
		Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate CZ',
            QuoteId__c = quote.Id
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
			QuoteId = quote.Id,
			PricebookEntryId = pbe.Id,
			Product2Id = prod.Id,
			LineNumber__c = 1,
			Sequence_Number__c = 1,
			Alternate_Number__c = 1,
			Unit_Weight__c = 1
		);
		insert quotelineitemObj;
		Illustrator_Design_Request__c idr = new Illustrator_Design_Request__c(
			Quote__c = quote.Id
		);
		insert idr;

		Idr_line_item__c idrlineitemcObj = new Idr_line_item__c (
			Quote__c = quote.Id,
			Quote_Line_Item__c = quotelineitemObj.Id,
			IDR__c = idr.Id
		);
		insert idrlineitemcObj;

		Test.startTest();
	}

	@isTest static void testUploadCustomImage_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		Quotelineitem qli = [SELECT Id, QuoteId FROM Quotelineitem LIMIT 1];
		Idr_line_item__c idrli = [SELECT Id FROM Idr_line_item__c LIMIT 1];

		String results = UploadCustomImageHelper.uploadCustomImage('fileId',qli.QuoteId,qli.Id, idrli.id, '');

		System.assertEquals(results,'Image Uploaded Successfully.');
	}

	@isTest static void testUploadCustomImage_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		try{
			String results = UploadCustomImageHelper.uploadCustomImage(null,null,null,null, '');
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest static void testGetQuoteInfo() {
		String query = 'Select Id from Idr_line_item__c LIMIT 1';
		Idr_line_item__c item = Database.query(query);

		List<IDR_Line_Item__c> results = UploadCustomImageHelper.getQuoteInfo(item.Id);

		System.assertEquals(results.size(), 1);
	}

	@isTest static void testGetExistingImage_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = UploadCustomImageHelper.getExistingImage('quoteDetailId');

		System.assertEquals(results,'{filedata}');
	}

	@isTest static void testGetExistingImage_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = UploadCustomImageHelper.getExistingImage(null);

		System.assertEquals(results,'No Image Found');
	}
}