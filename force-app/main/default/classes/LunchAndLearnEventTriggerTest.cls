/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      Test class for LunchAndLearnEventTrigger.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
************************************************************/
@isTest
public class LunchAndLearnEventTriggerTest { 
    
    @testSetup static void methodName() {
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name='Credentials';
        Credentials.Access_Token__c= 'test';
        Credentials.API_Key__c='test'; 
        Credentials.user_name__c='test';  
        Credentials.Endpoint__c= 'https://test';
        Credentials.Group_guid__c='test';
        insert Credentials;
        
        Account newAccount = new Account(Name = 'Sample Test Account');
        insert newAccount;
        LunchAndLearnEvent__c lunchlearn = new LunchAndLearnEvent__c();
        lunchlearn.Name = 'Test Lunch and Learn';
        lunchlearn.StartDateTime__c=System.today();
        lunchlearn.EndDateTime__c=System.today().addDays(2);
        lunchlearn.Subject__c='Lunch and Learn';
        lunchlearn.Related_To__c= newAccount.Id;
        insert lunchlearn;
        
    }
    static testMethod void testMethodURLShort() {
        // test.startTest();
        BitlyAccessToken__c bit = new BitlyAccessToken__c(name = 'Credentials');
        bit.Access_Token__c= 'test';
        bit.API_Key__c='test'; 
        bit.user_name__c='test';        
        insert bit;
        Test.setMock(HttpCalloutMock.class, new MockHttpURLShort());  
        Course__c testCampaign= new Course__c(Name='Test Course');
        insert testCampaign;
        Account accObj = new Account(Name='Test',BillingCountry='India');
        insert accObj;
        LunchAndLearnEvent__c eventObj= new LunchAndLearnEvent__c (StartDateTime__c=system.today(),EndDateTime__c=system.today()+1,Course_Name__c=testCampaign.id,Related_To__c=accObj.id);
        insert eventObj;
        //BitlyIntegrationRest.UrlShortenAttendanceLink(eventObj.id);
        BitlyIntegrationRest.shortenLandLRegistrationLinks(eventObj.id,'Attendance_Link1__c','Attendance_Link__c');
    }
    
    @isTest static void EventDetailsUpdate() 
    {
       LunchAndLearnEvent__c landl=[select Id,Name,StartDateTime__c,EndDateTime__c from LunchAndLearnEvent__c 
                                    where Name='Test Lunch and Learn'];
        landl.StartDateTime__c=system.today().addDays(4);
        landl.EndDateTime__c=system.today().addDays(6);
        update landl;
    }

}