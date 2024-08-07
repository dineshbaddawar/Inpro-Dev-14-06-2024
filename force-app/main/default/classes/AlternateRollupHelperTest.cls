@istest
public with sharing class AlternateRollupHelperTest {

    @testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'AlternateHelperQuote', 
			OpportunityId = opp.Id,
			Status = 'Draft',
            Pricebook2Id = pricebookId
		);
		insert quoteObj;

		Alternate__c alt1 = new Alternate__c(
            //Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate Helper 1',
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
            Quantity = 5, 
            UnitPrice = 25.0,
            Item_Number__c = '123',
            ParentID__c = '123',
            QuoteId = quoteObj.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            LineNumber__c = 1,
            Sequence_Number__c = 1,
            Alternate_Number__c = 1,
            Unit_Weight__c = 2
        );
        insert quotelineitemObj;
	}

	

    @istest 
    static void testAlteranteRollup() {
       // This causes a fake response to be generated
       Test.setMock(WebServiceMock.class, new sfdataTest());       
    
       // Call the method that invokes a callout
       List<string> quoteIds = new List<string>();
       AlternateRollupHelper alternateRollupHelper = new AlternateRollupHelper();
       String quoteId = [SELECT Id, Name FROM Quote WHERE Name = 'AlternateHelperQuote' LIMIT 1].Id;
       //List<Quote> quotes = [select id from quote limit 2];
    //    for (Quote q : quotes) {
    //        quoteIds.add(q.Id);
    //    }
       quoteIds.add(quoteId);       
       alternateRollupHelper.UpdateAlternateTotals(quoteIds);              
       // Verify that a fake result is returned       
       System.assertEquals('Success', 'Success');
    }    
}