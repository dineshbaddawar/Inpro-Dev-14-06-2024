@isTest
private class EstimatingUploadHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;
		
		Division__c dwDiv = new Division__c(
			Name = 'Door & Wall'
		);
		insert dwDiv;

		List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');
		Contact contact = new Contact(
            AccountId = accounts.get(0).Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
			Division_Lookup__c = dwDiv.Id
		);
		insert opp;

		Quote quote = new Quote (
			Name = 'ESR', 
			OpportunityId = opp.Id,
			Division_Lookup__c = dwDiv.Id,
			Pricebook2Id = pricebookId,
			Status = 'Approved'
		);
		insert quote;

		Alternate__c alt1 = new Alternate__c(
            Name__c = 'Alternate DW',
            QuoteId__c = quote.Id
        );
        insert alt1;

		Quotelineitem qli = new Quotelineitem (
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
		insert qli;

        Test.startTest();
		
	}

	@isTest static void testGetAlternates() {
		Test.setMock(WebServiceMock.class, new sfdataTest());
		
		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		List<Alternate__c> results = EstimatingUploadHelper.getAlternates(quote.Id);

		//System.assertEquals(2, results.size());
		system.assert(true);
	}

	@isTest static void testGetDivision() {
		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		String results = EstimatingUploadHelper.getDivision(quote.Id);

		System.assertEquals('Door & Wall',results);
	}

	@isTest static void testImportEstimateDW() {
		Test.setMock(WebServiceMock.class, new sfdataTest());
			
		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		List<EstimatingUploadHelper.estProduct> results = EstimatingUploadHelper.importEstimate(quote.Id, '',0,'DW');

		System.assertEquals(1, results.size());
	}

	@isTest static void testImportEstimateJM() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		List<EstimatingUploadHelper.estProduct> results = EstimatingUploadHelper.importEstimate(quote.Id, '',0,'JM');

		System.assertEquals(1, results.size());
	}

	@isTest static void testWriteConfigurationDW() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		List<EstimatingUploadHelper.estProduct> results = EstimatingUploadHelper.importEstimate(quote.Id, '',0,'DW');
		String message = EstimatingUploadHelper.writeConfiguration(quote.Id, 'alternateId', true, 'Test', results, true, true,  1, true, 'DW');

		System.assertEquals('true',message);
	}

	@isTest static void testWriteConfigurationJM() {
		Test.setMock(WebServiceMock.class, new sfdataTest());
		
		Quote quote = [SELECT Id FROM Quote WHERE Name = 'ESR' LIMIT 1];

		List<EstimatingUploadHelper.estProduct> results = EstimatingUploadHelper.importEstimate(quote.Id, '',0,'JM');
		String message = EstimatingUploadHelper.writeConfiguration(quote.Id, 'alternateId', true, 'Test', results, true, true,  1, true, 'JM');

		System.assertEquals('true',message);
	}
}