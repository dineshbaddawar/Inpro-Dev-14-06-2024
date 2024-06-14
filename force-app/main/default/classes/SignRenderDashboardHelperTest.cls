@isTest
private class SignRenderDashboardHelperTest{

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

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
			AccountId = accounts.get(0).id
		);
		insert opp;

		Quote quote = new Quote (
			Name = 'test value', 
			OpportunityId = opp.Id
		);
		insert quote;
		 Contact contactObj = new Contact (
			AccountId = accounts.get(0).Id, 
			FirstName = 'test value', 
			LastName = 'test value'
		);
		insert contactObj;

		Sign_Schedule__c signschedule = new Sign_Schedule__c(

		);
		insert signschedule;
		Sign_Schedule__c signschedule2 = new Sign_Schedule__c(

		);
		insert signschedule2;
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
		Quotelineitem quotelineitemObj2 = new Quotelineitem (
			Description = 'test value', 
			Alternate__c = alt1.Id, 
			SignScheduleId__c = signschedule2.Id,
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
		insert quotelineitemObj2;

		 Sign_schedule_item__c signscheduleitemcObj = new Sign_schedule_item__c (
			Index__c = 1.1, 
			Line1__c = 'test value', 
			Line10__c = 'test value', 
			Line10Font__c = 1.1, 
			Line11__c = 'test value', 
			Line11Font__c = 1.1, 
			Line12__c = 'test value', 
			Line12Font__c = 1.1, 
			Line13__c = 'test value', 
			Line14Font__c = 1.1, 
			Line15__c = 'test value', 
			Line15Font__c = 1.1, 
			Line16__c = 'test value', 
			Line16Font__c = 1.1, 
			Line17__c = 'test value', 
			Line17Font__c = 1.1, 
			Line18__c = 'test value', 
			Line18Font__c = 1.1, 
			Line19__c = 'test value', 
			Line19Font__c = 1.1, 
			Line2__c = 'test value', 
			Line20__c = 'test value', 
			Line20Font__c = 1.1, 
			Line3__c = 'test value', 
			Line4__c = 'test value', 
			Line4Font__c = 1.1, 
			Line5Font__c = 1.1, 
			Line6__c = 'test value', 
			Line6Font__c = 1.1, 
			Line7__c = 'test value', 
			Line7Font__c = 1.1, 
			Line8__c = 'test value', 
			Line8Font__c = 1.1, 
			Line9__c = 'test value', 
			SavedToCRM__c = TRUE, 
			SignScheduleId__c = signschedule.Id, 
			Text_Too_Tall__c = TRUE, 
			Text_Too_Wide__c = TRUE, 
			Missing_Configuration_Info__c = TRUE
		);
		insert signscheduleitemcObj;
		Sign_schedule_item__c signscheduleitemcObj2 = new Sign_schedule_item__c (
			Index__c = 1.1, 
			Line1__c = 'test value', 
			Line10__c = 'test value', 
			Line10Font__c = 1.1, 
			Line11__c = 'test value', 
			Line11Font__c = 1.1, 
			Line12__c = 'test value', 
			Line12Font__c = 1.1, 
			Line13__c = 'test value', 
			Line14Font__c = 1.1, 
			Line15__c = 'test value', 
			Line15Font__c = 1.1, 
			Line16__c = 'test value', 
			Line16Font__c = 1.1, 
			Line17__c = 'test value', 
			Line17Font__c = 1.1, 
			Line18__c = 'test value', 
			Line18Font__c = 1.1, 
			Line19__c = 'test value', 
			Line19Font__c = 1.1, 
			Line2__c = 'test value', 
			Line20__c = 'test value', 
			Line20Font__c = 1.1, 
			Line3__c = 'test value', 
			Line4__c = 'test value', 
			Line4Font__c = 1.1, 
			Line5Font__c = 1.1, 
			Line6__c = 'test value', 
			Line6Font__c = 1.1, 
			Line7__c = 'test value', 
			Line7Font__c = 1.1, 
			Line8__c = 'test value', 
			Line8Font__c = 1.1, 
			Line9__c = 'test value', 
			SavedToCRM__c = TRUE, 
			SignScheduleId__c = signschedule.Id, 
			Text_Too_Tall__c = TRUE, 
			Text_Too_Wide__c = TRUE, 
			Missing_Configuration_Info__c = TRUE
		);
		insert signscheduleitemcObj2;
		 
		Test.startTest();
	}

	@isTest static void testSaveToCRM_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignRenderDashboardHelper.saveToCRM('{"json":"value"}');

		System.assertEquals('Success!', results);
	}

	@isTest static void testSaveToCRM_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignRenderDashboardHelper.saveToCRM(null);

		System.assertEquals('Error!', results);
	}

	@isTest static void testGetQuoteLineItems() {
		String query = 'Select Id from Sign_Schedule__c';
		List<Sign_Schedule__c> signSchedules = Database.query(query);
		List<string> ids = new List<string>();
		for(Sign_Schedule__c s : signSchedules)
		{
			ids.add(s.Id);
		}

		List<QuoteLineItem> results = SignRenderDashboardHelper.getQuoteLineItems(ids);

		String query2 = 'Select Id, SignScheduleId__c from QuoteLineItem';
		List<QuoteLineItem> quotelineitems = Database.query(query2);

		System.assertEquals(quotelineitems.size(), results.size());
	}

	@isTest static void testGetAllSignScheduleItems() {
		String query = 'Select Id from Quote LIMIT 1';
		Quote quote = Database.query(query);

		List<Sign_Schedule_Item__c> results = SignRenderDashboardHelper.getAllSignScheduleItems(quote.Id);

		String query2 = 'Select Id from Sign_Schedule_Item__c';
		List<Sign_Schedule_Item__c> signScheduleItems = Database.query(query2);

		System.assertEquals(signScheduleItems.size(), results.size());
	}

	@isTest static void testGetContacts() {
		String query = 'Select Id from Quote LIMIT 1';
		Quote quote = Database.query(query);

		List<Contact> results = SignRenderDashboardHelper.getContacts(quote.Id);

		String query2 = 'Select Id from Contact';
		List<Contact> contacts = Database.query(query2);

		System.assertEquals(contacts.size(), results.size());
	}

	@isTest static void testEmailSign_success() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignRenderDashboardHelper.emailSign('any quote id','userid', '{jsoncontactlist}','{jsonalternatelist}','{jsonSigns}');

		System.assertEquals('Success!', results);
	}

	@isTest static void testEmailSign_error() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		String results = SignRenderDashboardHelper.emailSign('any quote id','userid', '{jsoncontactlist}','{jsonalternatelist}',null);

		System.assertEquals('Error!', results);
	}
}