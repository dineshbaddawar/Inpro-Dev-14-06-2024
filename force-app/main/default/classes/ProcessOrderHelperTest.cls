@isTest
private class ProcessOrderHelperTest{

	@testSetup static void setup(){
		//List<sObject> users = Test.loadData(User.sObjectType, 'testUser');
		//List<sObject> pricebooks = Test.loadData(Pricebook2.sObjectType, 'testPricebook');
		//List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts2');
		//List<sObject> contacts = Test.loadData(Contact.sObjectType, 'testContacts');
		//List<sObject> divisions = Test.loadData(Division__c.sObjectType, 'testDivisions');
		//List<sObject> opportunities = Test.loadData(Opportunity.sObjectType, 'testOpportunity');
		//List<sObject> products = Test.loadData(Product2.sObjectType, 'testProduct2');
		/*List<sObject> pricebookEntries = Test.loadData(PricebookEntry.sObjectType, 'testPricebookEntry');
		List<sObject> quotes = Test.loadData(Quote.sObjectType, 'testQuote');
		List<sObject> alternates = Test.loadData(Alternate__c.sObjectType, 'testAlternate');
		List<sObject> quotelineitems = Test.loadData(Quotelineitem.sObjectType, 'testQuotelineitem');
		List<sObject> orderRequests = Test.loadData(Order_Request__c.sObjectType, 'testOrderRequest');*/
	}

	@isTest static void testGetLocations() {
		List<string> locations = ProcessOrderHelper.getLocations();
		System.assert(locations.size() > 0);
	}

	@isTest static void testGetQuoteProducts() {
		string ordSql = 'SELECT Id FROM Order_Request__c ORDER BY CreatedDate DESC LIMIT 1';
		for (Order_Request__c ord: Database.Query(ordSql))
		{  
			List<QuoteLineItem> quoteProducts = ProcessOrderHelper.getQuoteProducts(ord.Id);
		}		
		//System.assert(quoteProducts.size() > 0);
	}

	@isTest static void testGetOrderRequest() {

		string ordSql = 'SELECT Id FROM Order_Request__c ORDER BY CreatedDate DESC LIMIT 1';
		for (Order_Request__c ord: Database.Query(ordSql))
		{ 
			Order_Request__c orderRequest = ProcessOrderHelper.getOrderRequest('a2f050000000zA3AAI');
		}
	}

	@isTest static void testProcessOrder() {
		string result = ProcessOrderHelper.processOrder('a2f050000000zA3AAI','1000V-0101',false,'APOLLO','0056g000005OkrhAAC');
	}

	/*@isTest static void testGetQuoteProducts_Clickeze() {
		String query = 'Select Id from Quote where Division__c = \'Clickeze Cubicles, Curtains, & Tracks\' LIMIT 1';
		Quote czQuote = Database.query(query);

		String query2 = 'Select Id from Order_Request__c where QuoteId__c = \'' + czQuote.Id + '\'';
		Order_Request__c ordreq = Database.query(query2);

		List<QuoteLineItem> lineItems = ProcessOrderHelper.getQuoteProducts(ordreq.Id);

		String query3 = 'Select Id from Alternate__c where name = \'Alternate CZ\'';
		Alternate__c alt = Database.query(query3);

		System.assertEquals(1, lineItems.size());
		System.assertEquals(alt.Id, lineItems[0].Alternate__c);
	}

	@isTest static void testGetQuoteProducts_Other() {
		String query = 'Select Id from Quote where Division__c <> \'Clickeze Cubicles, Curtains, & Tracks\' LIMIT 1';
		Quote dwQuote = Database.query(query);

		String query2 = 'Select Id from Order_Request__c where QuoteId__c = \'' + dwQuote.Id + '\' LIMIT 1';
		Order_Request__c ordreq = Database.query(query2);

		List<QuoteLineItem> lineItems = ProcessOrderHelper.getQuoteProducts(ordreq.Id);

		String query3 = 'Select Id from Alternate__c where name = \'Alternate DW\' LIMIT 1';
		Alternate__c alt = Database.query(query3);

		System.assertEquals(1, lineItems.size());
		System.assertEquals(alt.Id, lineItems[0].Alternate__c);
	}*/
}