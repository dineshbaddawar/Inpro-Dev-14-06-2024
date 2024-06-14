@isTest
public class LandLAdvancedRegistrationControllerTest {
    
    @testSetup public static void setup() {
        
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c(); 
        Credentials.name = 'Credentials';
        insert Credentials;
        
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        
        Contact conObj = new Contact();
        conObj.LastName = 'Test Hunley';
        conObj.Email = 'testing1@thehunleygroup.com';
        insert conObj;
        
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
        
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today() + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
        
        Event_Attendee__c newAttendee= new Event_Attendee__c();
        newAttendee.Contact__c = conObj.Id;
        newAttendee.Course__c =eventObj.Course_Name__c;
        newAttendee.LunchAndLearnEvent__c=eventObj.Id;
        newAttendee.Status__C='Pre-Registered';
        newAttendee.Created_from_Site__c =true; 
        insert newAttendee;
    }
    
    public static testMethod void testControllerMethods() {
        LunchAndLearnEvent__c evt  = [Select Id, Name,Course_Name__r.Name,Course_Name__c,
                                      Start_Formatted__c,Related_To__c 
                                      from LunchAndLearnEvent__c limit 1];
        
        LandLAdvancedRegistrationController.getLunchAndLearnEvent(evt.Id);
        
        List<LandLAdvancedRegistrationController.AttendeeWrapper> wrapperList =  LandLAdvancedRegistrationController.getAttendees(evt.Id);
        system.assertEquals(1, wrapperList.size());
        
        LandLAdvancedRegistrationController.updateAttendance(wrapperList[0].eventAttendeeId, true);
        
        Event_Attendee__c attendee = [Select Id,Attended__c,Status__c
                                      from Event_Attendee__c
                                      where Id =: wrapperList[0].eventAttendeeId];
        
        system.assertEquals('Attended', attendee.Status__c);
    }
    
}