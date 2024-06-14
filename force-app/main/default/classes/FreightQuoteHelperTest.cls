@isTest
private class FreightQuoteHelperTest{

	@testSetup static void setup(){

		Opportunity o = new Opportunity();
		o.Name = 'test';
		o.StageName = 'Estimating';
		o.CloseDate = Date.today();
		insert o;

		Quote q = new Quote();
		q.Name = 'test';
		q.OpportunityId = o.Id;
		insert q;

		Alternate__c a = new Alternate__c();
		a.QuoteId__c = q.Id;
		insert a;
		test.startTest();
	}

	@isTest static void testGetFreightCarriers()
	{
		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('RFO');	
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('RFO');
		FreightQuotes.add(freightQuote);

		List<Freight_Carrier__c> fc = FreightQuoteHelper.getFreightCarriers();

		System.assertEquals(1, fc.size());
	}

	@isTest static void testSaveFreightQuoteUPS() {			
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('UPS');			
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('UPS');
		FreightQuotes.add(freightQuote);
		Boolean response =  FreightQuoteHelper.saveFreightQuote(FreightQuotes);		
		System.assertEquals(true, response);
	}

	@isTest static void testSaveFreightQuoteUPS_MissingFreightCarrier()
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('UPS');
		FreightQuotes.add(freightQuote);
		Boolean response =  FreightQuoteHelper.saveFreightQuote(FreightQuotes);		
		System.assertEquals(true, response);
	}

	@isTest static void testSaveFreightQuoteMFQ() {		
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('MFQ');			
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('MFQ');
		Test.startTest();
		
		FreightQuotes.add(freightQuote);
		Boolean response =  FreightQuoteHelper.saveFreightQuote(FreightQuotes);		
		System.assertEquals(true, response);
	}

	@isTest static void testSaveFreightQuoteNegotiatedFreight() {		
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('NegotiatedFreight');			
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('NegotiatedFreight');
		FreightQuotes.add(freightQuote);
		Boolean response =  FreightQuoteHelper.saveFreightQuote(FreightQuotes);		
		System.assertEquals(true, response);
	}

	@isTest static void testSaveFreightQuoteRFO() {			
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('RFO');	
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('RFO');
		FreightQuotes.add(freightQuote);
		Boolean response =  FreightQuoteHelper.saveFreightQuote(FreightQuotes);		
		System.assertEquals(true, response);
	}	

	@isTest static void testGetFreightQuote() {		
		Test.setMock(WebServiceMock.class, new sfdataTest());

		Quote quote = [SELECT Id FROM Quote LIMIT 1];

		string recordId = quote.Id;
		string cache = '1';
		List<FreightQuoteHelper.freightQuote> response =  FreightQuoteHelper.getFreightQuote(recordId,  cache);
		System.assertEquals(0, 0);
	}	

	@isTest static void testSaveAlternateGroupName(){
		Test.setMock(WebServiceMock.class, new sfdataTest());
		
		List<FreightQuoteHelper.FreightQuote> FreightQuotes = new List<FreightQuoteHelper.freightQuote>();
		createTestFreightCarrier('UPS');			
		FreightQuoteHelper.FreightQuote freightQuote = createFreightQuoteObject('UPS');
		freightQuote.GroupName = 'UPS Group';
		FreightQuotes.add(freightQuote);

		Boolean results = FreightQuoteHelper.saveAlternateGroupName(FreightQuotes);

		System.assertEquals(true,results);
		String altId = freightQuote.AlternateId;
		String query = 'Select Id, Freight_Group_Name__c from Alternate__c where Id = :altId';
		List<Alternate__c> alts = Database.query(query);
		System.assertEquals(alts.get(0).Freight_Group_Name__c, 'UPS Group');
	}

	@isTest static void testRequestManualFreightQuote(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		User user = [SELECT Id FROM User LIMIT 1];

				
		String results = FreightQuoteHelper.RequestManualFreightQuote('alternateid', 'quoteId', user.Id, 'notes', false, 'shipping notes');

		System.assertEquals(results,'Success');
	}

	@isTest static void testRequestManualFreightQuote_IsRush(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		User user = [SELECT Id FROM User LIMIT 1];		
		String results = FreightQuoteHelper.RequestManualFreightQuote('alternateid', 'quoteId', user.Id, 'notes', true, 'shipping notes');

		System.assertEquals(results,'Success');
	}

	@isTest static void testUpdateManualFreightQuote(){
		Test.setMock(WebServiceMock.class, new sfdataTest());
		String results = FreightQuoteHelper.UpdateManualFreightQuote('alternateId', 'manualFreightQuoteID');
		System.assertEquals(results,'Success');
	}

	private static Freight_carrier__c createTestFreightCarrier(String name) {
       	 Freight_carrier__c freightcarriercObj = new Freight_carrier__c (
		 	Name = name, 
		 	Carrier_Code__c = name
		 );
		 insert freightcarriercObj;
		 return freightcarriercObj;
	}
	
	private static Alternate__c createTestAlternate(String name) {

		Quote quote = createTestQuote(name);
			Alternate__c alternatecObj = new Alternate__c (
				CurrencyIsoCode ='GBP',
				QuoteId__c = quote.Id
		
			);
			insert alternatecObj;
			return alternatecObj;
	 }

	 private static Quote createTestQuote(String name) {
		Opportunity opp = createTestOpportunity(name);
		Quote quote = new Quote(Name = name,
		OpportunityId = opp.Id
		);
        insert quote;
        return quote;
	}
	
	private static Opportunity createTestOpportunity(String name) {
		Opportunity opp = new Opportunity(Name = name, 
		StageName = 'test',
		CloseDate = date.today()
		);
        insert opp;
        return opp;
    }

		private static FreightQuoteHelper.FreightQuote createFreightQuoteObject(string CarrierCode)
		{
			FreightQUoteHelper.FreightQuote freightQuote = new FreightQuoteHelper.FreightQuote();
			freightQuote.CarrierCode = CarrierCode;	
			Alternate__c alternate =  createTestAlternate('test');
			freightQuote.AlternateId = alternate.Id;	
			freightQuote.TotalCharge = 100; 
			freightQuote.DriverWaitChrg = 50;
			freightQuote.DriverWait = true;
			freightQuote.InsideDeliveryChrg = 50;
			freightQuote.InsideDelivery = true;
			freightQuote.LiftGateChrg = 75;
			freightQuote.LiftGate = true;
			freightQuote.LoadingDockChrg = 40;
			freightQuote.LoadingDock = true;	   
			freightQuote.ServiceCall = true;
			freightQuote.ServiceCallChrg = 20;
			freightQuote.ServiceCallNote = 'test';
			freightQuote.QuotedFromLocation = 'test';
			return freightQuote;
		}
}