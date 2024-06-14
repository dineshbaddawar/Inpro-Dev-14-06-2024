@isTest
private class SampleRequestControllerTest{

	@testSetup static void setup(){
		Territory__c ter = new Territory__c();
        ter.Name = 'Test01';
        ter.Area__c = 'Central US';
        insert ter;
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        acc1.Territory_Lookup__c = ter.Id;
        acc1.ARC_FAC__c = 'FAC';
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.Territory__c = ter.Id;
        opp.CloseDate = Date.today();
        insert opp;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;
        Lead lead = new Lead();
        lead.Street = '123 Nope Blvd';
        lead.LastName = 'Sibley';
        lead.Territory__c = ter.Id;
        lead.Company = 'Inpro Corporation';
        insert lead;

		Sample_Request__c sr = new Sample_Request__c(
			Account__c = acc1.Id,
			Contact__c = con.Id,
			Lead__c = lead.Id,
			Desired_Shipping_Method__c = 'UPS_Ground',
			Desired_Package_Type__c = 'UPS Your Packaging',
			Type__c = '	Submittal Package'
		);
        insert sr;

	}
	@isTest static void testChangeMethods() {
		Sample_Request__c sr = [SELECT Id FROM Sample_Request__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('id', sr.Id);

		SampleRequestController controller = new SampleRequestController();

		System.assertEquals('UPS_GROUND', controller.desiredShipping);
		System.assertEquals('UPS Your Packaging', controller.desiredPackaging);

		controller.ChangeToFedEx();
		controller = new SampleRequestController();

		System.assertEquals('STANDARD_OVERNIGHT', controller.desiredShipping);
		System.assertEquals('FedEx Your Packaging', controller.desiredPackaging);

		controller.ChangeToUSPS();
		controller = new SampleRequestController();

		System.assertEquals('Priority', controller.desiredShipping);
		System.assertEquals(null, controller.desiredPackaging);

		controller.ChangeToUSPSFlatRateEnvelope();
		controller = new SampleRequestController();

		System.assertEquals('USPS Flat Rate Envelope', controller.desiredPackaging);

		controller.ChangeToUSPSPaddedFlatRateEnvelope();
		controller = new SampleRequestController();

		System.assertEquals('USPS Padded Flat Rate Envelope', controller.desiredPackaging);

		controller.ChangeToUPS();
		controller = new SampleRequestController();

		System.assertEquals('UPS_GROUND', controller.desiredShipping);
		System.assertEquals('UPS Your Packaging', controller.desiredPackaging);
	}
}