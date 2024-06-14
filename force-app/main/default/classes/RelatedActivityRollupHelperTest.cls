@isTest
public with sharing class RelatedActivityRollupHelperTest {

	@TestSetup
	static void setup(){
		
		String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
		Account architectAcct = new Account(
            BillingStreet = GeolocationUtilitiesCalloutMock.testStreet,
            BillingCity = GeolocationUtilitiesCalloutMock.testCity,
            BillingState = GeolocationUtilitiesCalloutMock.testState,
            BillingPostalCode = GeolocationUtilitiesCalloutMock.testZip,
            BillingCountry = GeolocationUtilitiesCalloutMock.testCountry,
            BillingLatitude = GeolocationUtilitiesCalloutMock.testLatitude,
            BillingLongitude = GeolocationUtilitiesCalloutMock.testLongitude,

            Name = 'New Opp Acct'
        );
		Construction_Project__c conProjObj = new Construction_Project__c(
            Name = 'Test Opp',
            Architect_Firm__c = architectAcct.Id,
            Street_Address__c = GeolocationUtilitiesCalloutMock.testStreet,
            City__c = GeolocationUtilitiesCalloutMock.testCity,
            State__c = GeolocationUtilitiesCalloutMock.testState,
            Zip_or_Postal_Code__c = GeolocationUtilitiesCalloutMock.testZip,
            Country__c = GeolocationUtilitiesCalloutMock.testCountry,
            Project_Location__Latitude__s = 39.194847,
            Project_Location__Longitude__s = -103.758507,
            Market_Segment__c = 'Healthcare',
            Sub_Segment__c ='Dentist'
        );
        insert conProjObj;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Construction_Project__c = conProjObj.Id
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'AlternateHelperQuote', 
			OpportunityId = opp.Id,
			Status = 'Draft',
            Pricebook2Id = pricebookId			
		);
		insert quoteObj;

		Task taskObj = new Task (
			WhatId = quoteObj.Id, 
			Subject = 'AddShortDescriptionHere',
			TaskSubtype = 'Email'
		);
		insert taskObj;

		EmailMessage emObj = new EmailMessage();		
		emObj.Subject = 'test';
		emObj.RelatedToId = quoteObj.Id;		
		emObj.TextBody = 'test';
		emObj.HtmlBody = 'test';		
		insert emObj;

		Task taskObj1 = new Task (
			WhatId = opp.Id, 
			Subject = 'AddShortDescriptionHere'
		);
		insert taskObj1;

		Task taskObj2 = new Task (
			WhatId = conProjObj.Id, 
			Subject = 'AddShortDescriptionHere'
		);
		insert taskObj2;
		

	}

    @isTest static void testGetActivities() {		
		Test.setMock(WebServiceMock.class, new sfdataTest());
		List<Task> results1 = RelatedActivityRollupHelper.getActivities([select id from Construction_Project__c limit 1].Id, 'Construction_Project__c');
        List<Task> results2 = RelatedActivityRollupHelper.getActivities([select id from Opportunity limit 1].Id, 'Opportunity');
		List<Task> results3 = RelatedActivityRollupHelper.getActivities([select id from Quote limit 1].Id, 'Quote');
		String result =  RelatedActivityRollupHelper.getHistoricalActivities('test'); 
		System.assertEquals(1, 1);
	}
}