@istest
public with sharing class QualificationHelperTest {
    @isTest static void testqualificationRefresh() {
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
            Pricebook2Id = pricebookId,
            Qualifications__c = '2-Test|3-Test2'
		);
		insert quoteObj;

		Alternate__c alt1 = new Alternate__c(
            //Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate Helper 1',
            QuoteId__c = quoteObj.Id            
        );
        insert alt1;

        QualificationHelper.refreshQualifications(quoteObj.Id);
		System.assert(true);
	}
}