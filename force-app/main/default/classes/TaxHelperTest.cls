@isTest
private class TaxHelperTest{

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

		Quote quote = new Quote (
			ShippingStreet = '123 Test St', 
			ShippingCity = 'Wausau', 
			ShippingState = 'Wisconsin', 
			ShippingPostalCode = '54401', 
			ShippingCountry = 'United States', 
			ShippingStateCode ='WI', 
			ShippingCountryCode ='US', 
			Name = 'Quote', 
			OpportunityId = opp.Id
		);
		insert quote;

		Alternate__c alt = new Alternate__c (
			Freight_Amount__c = 1.1,
			QuoteId__c = quote.Id
		);
		insert alt;

		Quotelineitem qli = new Quotelineitem (
			Alternate__c = alt.Id, 
			Quantity = 1.1, 
			UnitPrice = 1.1,
			QuoteId = quote.Id,
			PricebookEntryId = pbe.Id,
			Product2Id = prod.Id,
			Taxable__c = true,
			LineNumber__c = 1,
			Sequence_Number__c = 1,
			Alternate_Number__c = 1,
			Unit_Weight__c = 1
		);
		insert qli;
		 
		Test.startTest();
	}

	@isTest static void testCalcTax() {
		Test.setMock(WebServiceMock.class, new sftaxTest());

		TaxHelper taxHelper = new TaxHelper();
		sfTax.CalcTaxResults results = taxHelper.CalcTax(new List<sfTax.TaxProduct>(), 1.0, new sfTax.TaxAddress());

		System.assertEquals(true, results.Status);
	}

	@isTest static void testUpdateQuoteTax() {
		Test.setMock(WebServiceMock.class, new sftaxTest());
		// code_block	
		String query = 'Select Id from Quote Limit 1';
		Quote quote = Database.query(query);

		TaxHelper.updateQuoteTax(new List<Id>{ quote.Id});

		String query2 = 'Select Id, Product_Tax__c, Tax_Percent__c, Freight_Tax__c from Alternate__c limit 1';
		Alternate__c alt = Database.query(query2);

		System.assertEquals(.07 * 100, alt.Tax_Percent__c);
	}
}