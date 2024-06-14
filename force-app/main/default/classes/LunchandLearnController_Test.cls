/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:
* ==========================================================================
* Purpose:      This is the test class for BitlyIntegrationRest, BitlyIntegrationVC
*               and LunchandlearnController classes.
*
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/

@isTest
public class LunchandLearnController_Test {
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
    static testMethod void validatePositive() {
        test.startTest();
        PageReference pageRef = Page.BitlyIntegrationVF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('code', '1234');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BitlyIntegrationVC bivc = new BitlyIntegrationVC();
        bivc.BitlyIntegration();
        test.stopTest();
    }
    
    static testMethod void testMethodURLShort() {
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
    
    static testMethod void testMethodBitlyIntegrationAccessRes() {
        test.startTest();
        BitlyIntegrationAccessRes obj = new BitlyIntegrationAccessRes();
        obj.access_token = '123';
        obj.login = '123';
        obj.apiKey = '123';
        test.stopTest();
    }
    
    public static testMethod void testNullLeadContact() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
        testMethodURLShort();
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchandLearnCampaign LunchCampaign = new LunchandLearnCampaign();
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
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = 'testlal@gmail.com';
        Course__c testCampaign = new Course__c(Name = 'Test Course');
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
        LunchandLearnCampaign.searchDuplicateEvents(accId, location, testCampaign.id, '2017-09-20T19:00:00.000Z');
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
        scheduledBatchableEmailSend.scheduleMe();
    }
    
    public static testMethod void testLeadContact() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
        testMethodURLShort();
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
        update evtAttendee;
        
        //BatchEmailSendForCampaigns batch = new BatchEmailSendForCampaigns();
        //Database.executeBatch(batch);
    }
    
    public static testMethod void testLeadContactWithCompany1() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
        Lead LeadObj = new Lead(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Company = 'TestOrg',
            Status = 'Open - Not Contacted',
            email = 'seethal45@gmail.com',
            Country = 'India'
        );
        insert LeadObj;
        testMethodURLShort();
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchandLearnCampaign LunchCampaign = new LunchandLearnCampaign();
        
        LunchObj.contactEmail = '';
        LunchObj.firstName = 'testFirst';
        LunchObj.LastName = 'testLast';
        LunchObj.Is_AIA_Member = 'Yes';
        LunchObj.AIA_Member_Number = '123';
        LunchObj.CompanyName = 'TestCompany';
        
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'seethal45@gmail.com');
        ApexPages.currentPage().getParameters().put('firstName', 'test name');
        ApexPages.currentPage().getParameters().put('LastName', 'test name');
        ApexPages.currentPage().getParameters().put('Is_AIA_Member', 'Yes');
        ApexPages.currentPage().getParameters().put('CompanyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('AIA_Member_Number', '7800');
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = '';
        Course__c testCampaign = new Course__c(Name = 'Test Course');
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
    }
    public static testMethod void testLeadContactWithCompany12() {
        Test.setMock(WebServiceMock.class, new sfdataTest());

        Lead LeadObj = new Lead(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Company = 'TestOrg',
            Status = 'Open - Not Contacted',
            email = 'seethal45@gmail.com',
            Country = 'India'
        );
        insert LeadObj;
        testMethodURLShort();
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchandLearnCampaign LunchCampaign = new LunchandLearnCampaign();
        
        LunchObj.contactEmail = '';
        LunchObj.firstName = 'testFirst';
        LunchObj.LastName = 'testLast';
        LunchObj.Is_AIA_Member = 'Yes';
        LunchObj.AIA_Member_Number = '123';
        LunchObj.CompanyName = 'TestCompany';
        
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'seethal@gmail.com');
        ApexPages.currentPage().getParameters().put('firstname', 'test name');
        ApexPages.currentPage().getParameters().put('lastname', 'test name');
        ApexPages.currentPage().getParameters().put('AIAName', 'Yes');
        ApexPages.currentPage().getParameters().put('companyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('NumName', '7800');
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = '';
        Course__c testCampaign = new Course__c(Name = 'Test Course');
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
    }
    
    public static testMethod void testLeadContactWithCompany() {
        Test.setMock(WebServiceMock.class, new sfdataTest());

        testMethodURLShort();
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchandLearnCampaign LunchCampaign = new LunchandLearnCampaign();
        LunchObj.contactEmail = 'test@test.com.invalid';
        LunchObj.firstName = 'testFirst';
        LunchObj.LastName = 'testLast';
        LunchObj.Is_AIA_Member = 'Yes';
        LunchObj.AIA_Member_Number = '123';
        LunchObj.CompanyName = 'TestCompany';
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('contactEmail', 'seethal@gmail.com');
        ApexPages.currentPage().getParameters().put('firstName', 'test name');
        ApexPages.currentPage().getParameters().put('LastName', 'test name');
        ApexPages.currentPage().getParameters().put('Is_AIA_Member', 'Yes');
        ApexPages.currentPage().getParameters().put('CompanyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('AIA_Member_Number', '7800');
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = 'test@test.com.invalid';
        Course__c testCampaign = new Course__c(Name = 'Test Course');
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
        LunchandLearnCampaign.searchDuplicateEvents(
            accId,
            location,
            testCampaign.id,
            '2017-09-20T19:00:00.000Z'
        );
        LunchandLearnCampaign.searchDB(2, 'test');
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
    }
    
    static testMethod void testWithContactNoLeadPositive() {
        testMethodURLShort();
        
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'seethal@gmail.com');
        ApexPages.currentPage().getParameters().put('firstname', 'test name');
        ApexPages.currentPage().getParameters().put('lastname', 'test name');
        ApexPages.currentPage().getParameters().put('AIAName', 'No');
        ApexPages.currentPage().getParameters().put('companyName', '');
        ApexPages.currentPage().getParameters().put('NumName', '');
        LunchandlearnController LunchObj = new LunchandlearnController();
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        Contact contactObj = new Contact(
            FirstName = 'testFirstName',
            Lastname = 'testContact',
            Account = accObj,
            email = 'seethal@gmail.com',
            MailingCountry = 'India'
        );
        insert contactObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = 'testlal@gmail.com';
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = myStartDate,
            EndDateTime__c = myEndDate + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        
        ApexPages.currentPage().getParameters().put('id', eventObj.Id);
        
        Event_Attendee__c memberObj = new Event_Attendee__c(
            Contact__c = contactObj.id,
            Course__c = testCampaign.id,
            Status__c = 'Attended'
        );
        insert memberObj;
        LunchObj.selectAction();
        LunchObj.CreateNewContact();
    }
    
    static testMethod void testWithLeadContact() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
        testMethodURLShort();
        LunchandlearnController LunchObj = new LunchandlearnController();
        LunchObj.contactEmail = '';
        LunchObj.firstName = 'testFirst';
        LunchObj.LastName = 'testLast';
        LunchObj.Is_AIA_Member = 'Yes';
        LunchObj.AIA_Member_Number = '12378';
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'seethal@gmail.com');
        ApexPages.currentPage().getParameters().put('firstname', 'test name');
        ApexPages.currentPage().getParameters().put('lastname', 'test name');
        ApexPages.currentPage().getParameters().put('AIAName', 'Yes');
        ApexPages.currentPage().getParameters().put('companyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('NumName', '7800');
        
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        LunchObj.AccountIdx = accObj.id;
        LunchObj.contactEmail = 'testlal456@gmail.com';
        system.debug('Entered');
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = myStartDate,
            EndDateTime__c = myEndDate + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        ApexPages.currentPage().getParameters().put('id', eventObj.Id);
        LunchObj.selectAction();
        Lead LeadObj = new Lead(
            FirstName = 'JosephTest',
            LastName = 'TestPauly',
            Company = 'TestHg12',
            Status = 'Open - Not Contacted',
            email = 'barryallen12@gmail.com',
            Country = 'India',
            AIA_Member_Number__c = '74125'
        );
        insert LeadObj;
        Contact contactObj = new Contact(
            FirstName = 'testFirstName433',
            Lastname = 'testContact34343',
            Accountid = accObj.id,
            email = 'test44434@gmail.com',
            MailingCountry = 'India'
        );
        insert contactObj;
        Event_Attendee__c memberObj = new Event_Attendee__c(
            Contact__c = contactObj.id,
            Course__c = testCampaign.id,
            Status__c = 'Attended'
        );
        insert memberObj;
        LunchObj.CreateNewContact();
        LunchObj.createCampaignLeadMember(LeadObj.id, testCampaign.id, eventObj.id);
    }
    
    //####### TESTING 2##################
    
    static testMethod void testWithExixtingLeadContact() {
        Test.setMock(WebServiceMock.class, new sfdataTest());

        testMethodURLShort();
        
        Lead LeadObj = new Lead(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Company = 'TestOrg',
            Status = 'Open - Not Contacted',
            email = 'testlal8@gmail.com',
            Country = 'India'
        );
        LeadObj.AIA_Member_Number__c = '1236';
        insert LeadObj;
        Account accObj = new Account(Name = 'testFirstName', BillingCountry = 'India');
        insert accObj;
        Contact contactObj = new Contact(
            FirstName = 'testFirstName',
            Lastname = 'testContact',
            Accountid = accObj.id,
            email = 'testlal4@gmail.com',
            MailingCountry = 'India'
        );
        insert contactObj;
        LunchandlearnController LunchObj = new LunchandlearnController();
        
        PageReference myVfPage = Page.LandLSiteHomePage;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Email', 'testlal4@gmail.com');
        ApexPages.currentPage().getParameters().put('firstName', 'test name');
        ApexPages.currentPage().getParameters().put('lastname', 'test name');
        ApexPages.currentPage().getParameters().put('AIAName', 'Yes');
        ApexPages.currentPage().getParameters().put('CompanyName', 'CompanyName');
        ApexPages.currentPage().getParameters().put('NumName', '1236');
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
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
    }
    
    static testMethod void scheduletes() {
        Test.StartTest();
        scheduledBatchableEmailSend sh1 = new scheduledBatchableEmailSend();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
    }
    
    static testMethod void testMapEvent() {
        Test.setMock(WebServiceMock.class, new sfdataTest());

        testMethodURLShort();
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(
            Name = 'Test',
            BillingCity = 'Kochi',
            BillingStreet = 'test street',
            BillingState = 'Kerala',
            BillingCountry = 'India',
            BillingPostalCode = '689510'
        );
        insert accObj;
        
        Course__c testCampaign = new Course__c(Name = 'Test Course', Course_Id__c = 'MFS001',IDCEC_Course_ID__c='idcec-1',USGBC_Course_ID__c='USGBC-1');
        insert testCampaign;
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = myStartDate,
            EndDateTime__c = myEndDate + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        ApexPages.currentPage().getParameters().put('id', eventObj.Id);
        Lead LeadObj = new Lead(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Company = 'TestOrg',
            Status = 'Open - Not Contacted',
            email = 'testlal@gmail.com',
            Country = 'India'
        );
        insert LeadObj;
        
        Contact contactObj = new Contact(
            Lastname = 'testContact',
            Account = accObj,
            email = 'testlal123@gmail.com',
            Firstname = 'hhh',
            MailingCountry = 'India'
        );
        insert contactObj;
        
        PageReference pageRef = Page.MapEventVF;
        pageRef.getParameters().put('id', eventObj.id);
        Test.setCurrentPage(pageRef);
        
        MapEventController EventCont = new MapEventController();
        EventCont.LunchAndLearnEventRecord.lookup_to_contact__c = contactObj.id;
        EventCont.submit();
        EventCont.AddNext();
        PageReference pageRef1 = Page.MapEventVF;
        pageRef1.getParameters().put('id', eventObj.id);
        Test.setCurrentPage(pageRef1);
        MapEventController EventCont1 = new MapEventController();
        EventCont1.LunchAndLearnEventRecord.lookup_to_lead__c = LeadObj.id;
        EventCont1.submit();
        EventCont1.Close();
        PageReference pageRef2 = Page.MapEventVF;
        pageRef2.getParameters().put('id', eventObj.id);
        Test.setCurrentPage(pageRef2);
        MapEventController EventCont2 = new MapEventController();
        EventCont2.LunchAndLearnEventRecord.lookup_to_contact__c = contactObj.id;
        EventCont2.submit();
        PageReference pageRef3 = Page.MapEventVF;
        pageRef3.getParameters().put('id', eventObj.id);
        Test.setCurrentPage(pageRef3);
        MapEventController EventCont3 = new MapEventController();
        EventCont3.LunchAndLearnEventRecord.lookup_to_lead__c = LeadObj.id;
        EventCont3.submit();
        PageReference pageRef4 = Page.MapEventVF;
        pageRef4.getParameters().put('id', eventObj.id);
        Test.setCurrentPage(pageRef4);
        MapEventController EventCont4 = new MapEventController();
        EventCont4.submit();
        delete [SELECT id FROM Event_Attendee__c WHERE LunchAndLearnEvent__c = :eventObj.id LIMIT 1];
    }
    static testMethod void testPDF() {
        DateTime myStartDate = system.today();
        DateTime myEndDate = system.today() + 1;
        Account accObj = new Account(
            Name = 'Test',
            BillingCity = 'Kochi',
            BillingStreet = 'test street',
            BillingState = 'Kerala',
            BillingCountry = 'India',
            BillingPostalCode = '689510'
        );
        insert accObj;
        Course__c testCampaign = new Course__c(Name = 'Test Course', Course_Id__c = 'MFS001',IDCEC_Course_ID__c='idcec-1',USGBC_Course_ID__c='USGBC-1');
        insert testCampaign;
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = myStartDate,
            EndDateTime__c = myEndDate + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        Test.StartTest();
   
        Contact contactObj = new Contact(
            FirstName = 'testFirstName',
            Lastname = 'testContact',
            Account = accObj,
            email = 'seethal@gmail.com',
            MailingCountry = 'India'
        );
        insert contactObj;
        PageReference myVfPage = Page.CertificateAIA2;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('id', contactObj.Id);
        ApexPages.currentPage().getParameters().put('courseRecordId', testCampaign.Id);
        ApexPages.currentPage().getParameters().put('l&lRecordId', eventObj.Id);
        contactDetailsControllerPDF obj=new contactDetailsControllerPDF();
        Test.stopTest();
    }
}