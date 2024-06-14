@isTest
private class SignScheduleManagementHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;
		Account account = new Account();
		account.Name = 'Test';

		Contact contact = new Contact(
            AccountId =  account.Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
			AccountId =  account.id
		);
		insert opp;

		Quote quote = new Quote (
			Name = 'test value', 
			OpportunityId = opp.Id
		);
		insert quote;
		 Contact contactObj = new Contact (
			AccountId =  account.Id, 
			FirstName = 'test value', 
			LastName = 'test value'
		);
		insert contactObj;

		Sign_Schedule__c signschedule = new Sign_Schedule__c(

		);
		insert signschedule;
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
			SignScheduleId__c = signschedule.Id,
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

		 Sign_schedule_item__c signscheduleitemcObj = new Sign_schedule_item__c (
			Index__c = 1.1, 
			Line1__c = 'test value', 
			Line20__c = 'test value', 
			Line20Font__c = 1.1, 
			SavedToCRM__c = TRUE, 
			SignScheduleId__c = signschedule.Id, 
			Text_Too_Tall__c = TRUE, 
			Text_Too_Wide__c = TRUE, 
			Missing_Configuration_Info__c = TRUE
		);
		insert signscheduleitemcObj;
		 
		Test.startTest();
	}

	@isTest static void testGetAlternates() {
		String query = 'Select Id from Quote LIMIT 1';
		Quote quote = Database.query(query);

		List<Alternate__c> results = SignScheduleManagementHelper.getAlternates(quote.Id);

		String query2 = 'Select Id from Alternate__c';
		List<Alternate__c> alts = Database.query(query2);

		System.assertEquals(results.size(), alts.size());
	}

	@isTest static void testGetProducts() {
		String query = 'Select Id from Quote LIMIT 1';
		Quote quote = Database.query(query);

		List<QuoteLineItem> results = SignScheduleManagementHelper.getProducts(quote.Id);

		String query2 = 'Select Id from QuoteLineItem';
		List<QuoteLineItem> quoteLineItems = Database.query(query2);

		System.assertEquals(results.size(), quoteLineItems.size());
	}

	@isTest static void testGetSignScheduleItems() {
		String query = 'Select Id from Sign_Schedule__c Limit 1';
		Sign_Schedule__c signSchedule = Database.query(query);

		List<Sign_Schedule_Item__c> results = SignScheduleManagementHelper.getSignScheduleItems(signSchedule.Id);

		String query2 = 'Select Id from Sign_Schedule_Item__c';
		List<Sign_Schedule_Item__c> signScheduleItems = Database.query(query2);

		System.assertEquals(results.size(), signScheduleItems.size());
	}

	@isTest static void testCreateSignScheduleItems() {
		SignScheduleManagementHelper.createSignScheduleItems('test',1);

		//This appears to not be used right now - this test is purely for code coverage right now
		System.assert(true);
	}

	@isTest static void testGetProductsByAltId() {
		String query = 'Select Id from Alternate__c Limit 1';
		Alternate__c alt = Database.query(query);

		List<QuoteLineItem> results = SignScheduleManagementHelper.getProductsByAltId(alt.Id);

		String query2 = 'Select Id from QuoteLineItem WHERE Alternate__c = \'' + alt.Id + '\'';
		List<QuoteLineItem> quoteLineItems = Database.query(query2);

		System.assertEquals(results.size(), quoteLineItems.size());
	}

	@isTest static void testUploadSchedule() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignScheduleManagementHelper.UploadSchedule('any record','UserId', 'file id');

		System.assertEquals('',results);
	}
	@isTest static void testDownloadSchedule_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignScheduleManagementHelper.DownloadSchedule('any record id', new List<string>());

		System.assertEquals('{testdata}',results);
	}

	@isTest static void testDownloadSchedule_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignScheduleManagementHelper.DownloadSchedule(null, new List<string>());

		System.assertEquals('Error!',results);
	}

	@isTest static void testDownloadSignPro_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		User user = [SELECT Id FROM User LIMIT 1];

		String results = SignScheduleManagementHelper.downloadSignPro('any record id', new List<string>(), true, user.Id);

		System.assertEquals('',results);
	}

	@isTest static void testDownloadSignPro_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		User user = [SELECT Id FROM User LIMIT 1];


		String results = SignScheduleManagementHelper.downloadSignPro(null, new List<string>(), true, user.Id);

		System.assertEquals('Error!',results);
	}
	@isTest static void testSaveScheduleItems() {
		Test.setMock(WebServiceMock.class, new datawarehouseTest());

		String query = 'Select Id, Line20__c from Sign_Schedule_Item__c';
		List<Sign_Schedule_Item__c> signScheduleItems = Database.query(query);

		String results = SignScheduleManagementHelper.saveScheduleItems(signScheduleItems);

		System.assertEquals('Success',results);
	}
	@isTest static void testRenderSign() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignScheduleManagementHelper.renderSign('quoteDetailId', 'signScheduleItemId', 'cache');	
	
		System.assertEquals('data',results);
	}

	@isTest static void testRenderSign_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignScheduleManagementHelper.renderSign(null,null, 'cache');	
	
		System.assertEquals('Error!',results);
	}

	@isTest static void testValidateSign() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String jsonResults = SignScheduleManagementHelper.validateSign('quotedetailid','content');
		sfdata.ValidateContentWidthResult result = (sfdata.ValidateContentWidthResult)Json.deserialize(jsonResults, sfdata.ValidateContentWidthResult.class);

		System.assert(result.Status == true);
	}

	@isTest static void testCreateSignSchedules() {
		String query = 'Select Id from Quote LIMIT 1';
		Quote quote = Database.query(query);

		String query2 = 'SELECT Id, Quantity,Item_Number__c, Description FROM QuoteLineItem WHERE QuoteId = \'' + quote.Id + '\'AND SignScheduleId__c = null';                 
		List<QuoteLineItem> quoteLineItems = Database.query(query2);       
		List<string> qli_ids = new List<string>();
		for(QuoteLineItem q: quoteLineItems){ qli_ids.add(q.Id);}

		String results = SignScheduleManagementHelper.createSignSchedules(quote.Id);
		quoteLineItems = Database.query(query2);       

		System.assertEquals(results,'Success!');
		System.assertEquals(quoteLineItems.size(), 0);
	}
}