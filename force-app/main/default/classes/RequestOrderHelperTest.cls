@isTest
private class RequestOrderHelperTest{

	@testSetup static void setup(){
		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'test value', 
			OpportunityId = opp.Id,
			Status = 'Approved'
		);
		insert quoteObj;
		
		Account account = new Account(
            Name = 'Test IT Account'
        );
        insert account;

		Contact c1 = new Contact(
			LastName = 'Test 1',
			AccountId = account.Id
		);
		insert c1;

		Contact c2 = new Contact(
			LastName = 'Test 2',
			AccountId = account.Id
		);
		insert c2;

		Bidder__c bidder = new Bidder__c(
            Opportunity__c = opp.Id,
            Bidder__c = account.Id
        );
        insert bidder;

        Quote_Bidder__c quoteBidder = new Quote_Bidder__c(
            Bidder_Name__c = bidder.Id,
            Quote__c = quoteObj.Id
        ); //Bidder_Name__r.Opportunity__c <>  Quote__r.OpportunityId
        insert quoteBidder;
		
		 Contract__c contractcObj = new Contract__c (
			CurrencyIsoCode ='GBP',
			Account__c = account.Id
		);
		insert contractcObj;

		
		Test.startTest();	 
	}

	@isTest static void testGetQuote() {
		String query = 'Select ID from Quote LIMIT 1';
		Quote quote = Database.query(query);

		Quote results = RequestOrderHelper.getQuote(quote.Id);

		System.assertEquals(quote.Id, results.Id);
	}

	// @isTest static void testGetSalesRepNumbers() {
	// 	Test.setMock(WebServiceMock.class, new sfdataTest());

	// 	String jsonResults = RequestOrderHelper.getSalesRepNumbers();
	// 	List<sfdata.SalesRepNumber> results = (List<sfdata.SalesRepNumber>)Json.deserialize(jsonResults, List<sfdata.SalesRepNumber>.class);

	// 	System.assertEquals('Tester', 'Tester');
	// }

	// @isTest static void testCreateOrderRequest(){
	// 	String query = 'Select ID from Quote LIMIT 1';
	// 	Quote quote = Database.query(query);

	// 	String query2 = 'Select ID from Contract__c LIMIT 1';
	// 	Contract__c contract = Database.query(query2);

	// 	String query3 = 'Select ID from Account LIMIT 1';
	// 	Account account = Database.query(query3);

	// 	RequestOrderHelper.RequestOrder requestOrder = new RequestOrderHelper.RequestOrder();
		
	// 	requestOrder.SameDayOrder = false;
	// 	requestOrder.NoChargeOrder = true;
	// 	requestOrder.PO = '12345';
	// 	requestOrder.RepNumber = '12345';
	// 	requestOrder.ShippingInstructions = 'Test';
	// 	requestOrder.InstallerEmail = 'test@inprocorp.com.invalid';
	// 	requestOrder.Bidder = account.Id;
	// 	requestOrder.OrderAmount = 100.0;
	// 	requestOrder.ContractId = contract.Id;
	// 	requestOrder.InvoiceDetail = false;

	// 	String results = RequestOrderHelper.createOrderRequest(String.valueOf(Quote.Id), requestOrder);

	// 	String query4 = 'Select ID, Inpro_Contract__c from Order_Request__c LIMIT 1';
	// 	Order_Request__c orderRequest = Database.query(query4);		

	// 	System.assertEquals(orderRequest.Id, results);
	// 	System.assertEquals(orderRequest.Inpro_Contract__c, contract.Id);
	// }

	@isTest static void testGetBidders(){
		String query = 'Select ID from Quote LIMIT 1';
		Quote quote = Database.query(query);

		String query2 = 'Select ID from Quote_Bidder__c LIMIT 1';
		Quote_Bidder__c quoteBidder = Database.query(query2);

		List<Quote_Bidder__c> results = RequestOrderHelper.getBidders(quote.Id);

		System.assertEquals(1, results.size());
		System.assertEquals(quoteBidder.Id, results[0].Id);
	}

	@isTest static void testContractSearch() {
		String query = 'SELECT Id, Name FROM Contract__c LIMIT 1';
		Contract__c contract = Database.query(query);

		String query2 = 'SELECT Id FROM Account LIMIT 1';
		Account account = Database.query(query2);

		List<LookupSearchResult> results = RequestOrderHelper.contractSearch(contract.Name,Account.Id, new List<String>());

		System.assertEquals(contract.Name, results.get(0).getTitle());
	}

	@isTest static void testContactSearch()
	{
		Account account = [SELECT Id, Name FROM Account LIMIT 1];

		List<LookupSearchResult> results = RequestOrderHelper.contactSearch(account.Name, String.valueOf(account.Id), null);

		System.assertEquals(2, results.size());
	}
}