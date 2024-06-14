@isTest
public class BatchSendCertificatesTest {
    @testSetup
    static void methodName() {
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name='Credentials';
        Credentials.Access_Token__c= 'test';
        Credentials.API_Key__c='test'; 
        Credentials.user_name__c='test';  
        Credentials.Endpoint__c= 'https://test';
        Credentials.Group_guid__c='test';
        insert Credentials;
    }
    public static testMethod void testLeadContact() {
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchandLearnCampaign LunchCampaign = new LunchandLearnCampaign();
        LunchandLearnCampaign.Campaign();
        LunchandLearnCampaign.getLocalDateTime(system.today());
        LunchObj.contactEmail = '';
        LunchObj.firstName = 'testFirst';
        LunchObj.LastName = 'testLast';
        LunchObj.Is_AIA_Member = 'Yes';
        LunchObj.AIA_Member_Number = '123';
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'seethal@gmail.com');
        ApexPages.currentPage().getParameters().put('firstname', 'test name');
        ApexPages.currentPage().getParameters().put('lastname', 'test name');
        ApexPages.currentPage().getParameters().put('AIAName', 'Yes');
        ApexPages.currentPage().getParameters().put('companyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('NumName', '7800');
        ApexPages.currentPage().getParameters().put('GBCINumber', '4421424');
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = '';
        Course__c testCampaign = new Course__c(Name = 'Test Course',USGBC_Course_ID__c ='gbci2434',Course_Id__c='aiae22');
        insert testCampaign;
        String accId = accObj.id;
        String location = '';
        LunchandLearnCampaign.createEvent(
            accId,
            location,
            'Test Course',
            testCampaign.id,
            '2017-09-20T19:00:00.000Z'
        );
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = myStartDate,
            EndDateTime__c = myEndDate + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        ApexPages.currentPage().getParameters().put('id', eventObj.Id);
        
        LunchObj.selectAction();
        LunchObj.CreateNewContact();
        LunchObj.pageLoadFunction();
        
        Event_Attendee__c evtAttendee = [Select Id,created_by_admin__c from Event_Attendee__c LIMIT 1];
        SYSTEM.debug('evtAttendee'+evtAttendee);
        evtAttendee.Created_by_Admin__c = TRUE;
        evtAttendee.Status__c = 'Attended';
        update evtAttendee;
        
        BatchSendCertificates batch = new BatchSendCertificates();
        Database.executeBatch(batch);
    }
    
    static testMethod void testMethodURLShort() {
        // test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpURLShort());
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today() + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        BitlyIntegrationRest.shortenLandLRegistrationLinks(eventObj.id,'Attendance_Link1__c','Attendance_Link__c');
    }
    
    
}