/*************************************************************
* Created by:   The Hunley Group
* Created on:   7/7/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      Test class for EventTriggerHandler.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/7/2020     THG - JP        Created
************************************************************/
@isTest
public class EventTriggerHandlerTest {
    
    @testSetup static void methodName() {
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name='Credentials';
        insert Credentials;
    }
    
    @isTest static void EventDetailsUpdate() 
    {
        Account newAccount = new Account(Name = 'Sample Test Account');
        insert newAccount;
        LunchAndLearnEvent__c lunchlearn = new LunchAndLearnEvent__c();
        lunchlearn.Name = 'Test Lunch and Learn';
        lunchlearn.StartDateTime__c=System.today();
        lunchlearn.EndDateTime__c=System.today().addDays(2);
        lunchlearn.Subject__c='Lunch and Learn';
        lunchlearn.Related_To__c= newAccount.Id;
        insert lunchlearn;
        lunchlearn.StartDateTime__c = System.today().addDays(-2);
        upsert lunchlearn;
        
        Event evt=[Select Id,Lunch_and_Learn_Event__c,StartDateTime,EndDateTime from Event
                   where Lunch_and_Learn_Event__c=:lunchlearn.Id];
        evt.StartDateTime=system.today().addDays(4);
        evt.EndDateTime=system.today().addDays(5);
        update evt;
    }

}