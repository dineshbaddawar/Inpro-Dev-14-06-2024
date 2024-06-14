/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      This is the test class for the ResendLunchAndLearn class, which can regenerate
*				L&L certificates as well as resend emails with certificates.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
************************************************************/
@isTest
public with sharing class ResendLunchAndLearn_Test {
    @testSetup
    private static void createTestData() { 
        /* Add back if record types are added to the campaign*/
        
        BitlyAccessToken__c mockToken = new BitlyAccessToken__c(Access_Token__c='test', API_Key__c='TestKey',
                                                                User_Name__c='TestUserName', Name='TestToken');
        insert mockToken;
        
        Course__c testLandLCampaign = new Course__c(Name='Lunch and Learn Test Campaign',
                                                    IsActive__c=true, 
                                                    Course_ID__c='99099099', USGBC_Course_ID__c='99199199', 
                                                    IDCEC_Course_ID__c='99299299', LandLCourseCredit__c=10.0);
        insert testLandLCampaign;
        
        Account testAcct = new Account(Name='Test Customer Account');
        insert testAcct;
        
        List<Contact> testContacts = new List<Contact>();
        Contact testCont1 = new Contact(FirstName='Greg', LastName='Jones', Email='Greg.Jones@Mailinator.com', 
                                        AccountId=testAcct.Id);
        testContacts.add(testCont1);
        Contact testCont2= new Contact(FirstName='Barb', LastName='Sheridan', Email='Barb.Sheridan@Mailinator.com',
                                       AccountId=testAcct.Id);
        testContacts.add(testCont2);
        
        insert testContacts;
    }
    
    @isTest
    private static void testResendEmail() {
        Course__c testCamp = [Select Id from Course__c where Name = 'Lunch and Learn Test Campaign'];
        Account testAcct = [Select Id from Account where Name = 'Test Customer Account'];
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new BitlyMockCallout());
        
        Id LandLID = LunchandLearnCampaign.createEvent(testAcct.Id,'', 'Lunch and Learn Test Campaign', 
                                                       testCamp.Id, String.valueOf(System.now().addDays(-2)));
        
        List<Contact> conts = new List<Contact>();
        List<String> contIds = new List<String>();
        
        List<Event_Attendee__c> attendees = new List<Event_Attendee__c>();
        
        for(Contact c : [Select Id from Contact]) {
            contIds.add(c.Id);
            conts.add(c);
            Event_Attendee__c tempAttendee = new Event_Attendee__c(Course__c=testCamp.Id, Contact__c=c.Id,
                                                                   Status__c='Pre-Registered', LunchAndLearnEvent__c=LandLID, Email_Opt_In__c=true);
            attendees.add(tempAttendee);
        }
        
        insert attendees;
        ApexPages.StandardController contactController = new ApexPages.StandardController(conts[0]);
        ResendLunchAndLearnContact contactExt = new ResendLunchAndLearnContact(contactController);
        PageReference flowPage = Page.ResendLunchAndLearnContact;
        Test.setCurrentPage(flowPage);
        contactExt.doResendLandL();
        PageReference goToRecord = contactExt.getRecordPage();
        test.StopTest();
        for(Task a : [Select Id, Subject from Task where WhoId in: conts]) {
            System.assertEquals(a.Subject.contains('Email: Thank you'), true);
        }
    }
    
    @isTest
    private static void testResendEmailLightning() {
        Course__c testCamp = [Select Id from Course__c where Name = 'Lunch and Learn Test Campaign'];
        Account testAcct = [Select Id from Account where Name = 'Test Customer Account'];
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new BitlyMockCallout());
        Id LandLID = LunchandLearnCampaign.createEvent(testAcct.Id,'', 'Lunch and Learn Test Campaign', 
                                                       testCamp.Id, String.valueOf(System.now().addDays(-2)));
        
        List<Contact> conts = new List<Contact>();
        List<String> contIds = new List<String>();
        
        List<Event_Attendee__c> attendees = new List<Event_Attendee__c>();
        
        for(Contact c : [Select Id from Contact]) {
            contIds.add(c.Id);
            conts.add(c);
            Event_Attendee__c tempAttendee = new Event_Attendee__c(Course__c=testCamp.Id, Contact__c=c.Id,
                                                                   Status__c='Attended', LunchAndLearnEvent__c=LandLID,Email_Opt_In__c=true);
            attendees.add(tempAttendee);
        }
        
        insert attendees;
        LunchAndLearnEvent__c testEvent = ResendLunchAndLearnContact.getLunchAndLearnEvent(LandLId);
        System.assert(testEvent.Name.contains('Lunch and Learn Test Campaign - Test Customer Account'));
        List<ResendLunchAndLearnContact.AttendeeWrapper> attendeeWrap = ResendLunchAndLearnContact.getAttendees(testEvent.Id);
        System.assertEquals(attendeeWrap.size(),2);
        for(ResendLunchAndLearnContact.AttendeeWrapper wrap : attendeeWrap) {
            wrap.resend = true;
        }
        String resendResult = ResendLunchAndLearnContact.doEventLevelResend(JSON.serialize(attendeeWrap));
        System.assertEquals('Certificates confirmed and emails resent successfully.', resendResult);
        test.StopTest();
    }
}