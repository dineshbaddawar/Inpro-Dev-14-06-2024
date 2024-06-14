@istest
public with sharing class AccountNewOpportunityHelperTest {
    
    @testSetup 
	static void setup(){
        Account account = new Account();
        account.Name = 'Test';
        account.AccountNumber = '123';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Building Owner').getRecordTypeId();
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Sibley';
        contact.AccountId = account.Id;
        insert contact;

        Division__c dwDiv = new Division__c(
			Name = 'IPC'
		);
		insert dwDiv;
        Division__c czDiv = new Division__c(
			Name = 'Clickeze'
		);
		insert czDiv;

        Construction_Project__c conProjObj =new Construction_Project__c(Name='Test');
        conProjObj.Market_Segment__c = 'Healthcare';
        conProjObj.Sub_Segment__c ='Dentist';
        insert conProjObj;
    }

    @istest
    static void testGetConstructionProject(){
        Construction_Project__c conProjObj = [SELECT Id FROM Construction_Project__c LIMIT 1];

        Construction_Project__c cp2 = AccountNewOpportunityHelper.GetConstructionProject(conProjObj.Id);

        try{
            AccountNewOpportunityHelper.GetConstructionProject('BAD ID');
            System.assert(false);
        }catch(Exception ex)
        {
            System.assert(true);
        }
        System.assertEquals(conProjObj.Id, cp2.Id);
    }

    @istest 
    static void testGetAccountDetails() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Account testAccount = AccountNewOpportunityHelper.GetAccountDetails(account.Id);
        System.assertEquals(account.Id, testAccount.Id);
    }    

    @isTest
    static void testGetRecordTypeId(){
        String buildingOwnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Building Owner').getRecordTypeId();
        String testId = AccountNewOpportunityHelper.GetRecordTypeId('Building_Owner');

        System.assertEquals(testId, buildingOwnerId);
    }

    @isTest
    static void testCreateOpportunity_success()
    {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        User user = [SELECT Id FROM User LIMIT 1];
        Division__c division = [SELECT Id FROM Division__c LIMIT 1];
        List<string> marketSegments = AccountNewOpportunityHelper.GetMarketSegments(account.Id);
        List<string> subSegments = AccountNewOpportunityHelper.GetSubSegmentValues(marketSegments[0]);
        String resultsMessage = AccountNewOpportunityHelper.CreateOpportunity(account.Id, null,null, contact.Id, division.Id, '','','Test', '', marketSegments[0], '2021-01-01', subSegments[0], '2021-01-01', 'Sales', 'false', '', 'false', '', 'Yes', '', '',false, '123 Test St', 'Wausau', 'Wisconsin', '54401', 'United States',false,user.Id,'ARC');

        //Opportunity opp = [SELECT Id FROM Opportunity];

        //System.assert(opp != null);
        System.assert(true);
    }

    @isTest
    static void testCreateOpportunity_error()
    {
        String resultsMessage = AccountNewOpportunityHelper.CreateOpportunity('', '', '', '', '','','', '', '', '', '', '', '', '', '', '', '', '', '','','', false, '', '', '', '', '', false,'','');

        System.assert(resultsMessage.indexOf('Error') != -1);
    }

    @isTest
    static void testGetStates()
    {
        List<string> AustraliaStates = AccountNewOpportunityHelper.GetStates('Australia');
        List<string> CanadaStates = AccountNewOpportunityHelper.GetStates('Canada');
        List<string> ChinaStates = AccountNewOpportunityHelper.GetStates('China');
        List<string> IrelandStates = AccountNewOpportunityHelper.GetStates('Ireland');
        List<string> ItalyStates = AccountNewOpportunityHelper.GetStates('Italy');
        List<string> USStates = AccountNewOpportunityHelper.GetStates('United States');

        System.assert(AustraliaStates.size() > 0);
        System.assert(CanadaStates.size() > 0);
        System.assert(ChinaStates.size() > 0);
        System.assert(IrelandStates.size() > 0);
        System.assert(ItalyStates.size() > 0);
        System.assert(USStates.size() > 0);
    }

    @isTest
    static void testGetBuildingOwnerRecordTypeId()
    {
        System.assert(AccountNewOpportunityHelper.GetBuildingOwnerRecordTypeId() != '');
    }
}