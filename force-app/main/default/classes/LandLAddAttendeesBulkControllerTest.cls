@isTest
public class LandLAddAttendeesBulkControllerTest {
    
    @testSetup public static void setup() {
        
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name = 'Credentials';
        insert Credentials;
        
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        
        Standards_Body__c stdBody1 = new Standards_Body__c();
        stdBody1.Name = 'RIBA';
        insert stdBody1;
        
        Standards_Body__c stdBody2 = new Standards_Body__c();
        stdBody2.Name = 'BDA';
        insert stdBody2;
        
        Course__c testCampaign = new Course__c(Name = 'Test Course');
        insert testCampaign;
        
        Standards_Bodies_Covered__c sbc1 = new Standards_Bodies_Covered__c();
        sbc1.Course__c = testCampaign.Id;
        sbc1.Standards_Body__c = stdBody1.Id;
        insert sbc1;
        
        Standards_Bodies_Covered__c sbc2 = new Standards_Bodies_Covered__c();
        sbc2.Course__c = testCampaign.Id;
        sbc2.Standards_Body__c = stdBody2.Id;
        insert sbc2;
        
        
        Contact conObj = new Contact();
        conObj.LastName = 'Test Hunley';
        conObj.Email = 'testing1@thehunleygroup.com';
        insert conObj;
        
        Standards_Bodies_Registered__c sbr1 = new Standards_Bodies_Registered__c();
        sbr1.Contact__c = conObj.Id;
        sbr1.Standards_Body__c = stdBody1.Id;
        sbr1.Registration_Number__c='RIBA-324';
        insert sbr1;
        
        Lead leadObj = new Lead();
        leadObj.FirstName ='Test';
        leadObj.LastName='Lead';
        leadObj.Email = 'testing2@thehunleygroup.com';
        leadObj.Company='Hunley';
        insert leadObj;
        
        LunchAndLearnEvent__c eventObj = new LunchAndLearnEvent__c(
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today() + 1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
    }
    
    public static testMethod void testControllerMethods() {
        
        LunchAndLearnEvent__c evt  = [Select Id, Name,Course_Name__r.Name,Course_Name__c,
                                      Start_Formatted__c,Related_To__c 
                                      from LunchAndLearnEvent__c limit 1];
        
        LandLAddAttendeesBulkController.getStandardBodyList(evt.Id);
        
        LandLAddAttendeesBulkController.getLunchAndLearnEvent(evt.Id);
        
        LandLAddAttendeesBulkController.AttendeeWrapper wrapper =  LandLAddAttendeesBulkController.addRow(evt.Id);
        wrapper.EmailAddress='testing@thehunleygroup.com';
        wrapper.FirstName='First Name';
        wrapper.LastName='Last Name';
        
        LandLAddAttendeesBulkController.createNewAttendee(wrapper, evt.Id);
        
        LandLAddAttendeesBulkController.AttendeeWrapper wrapper1 =  LandLAddAttendeesBulkController.addRow(evt.Id);
        wrapper1.EmailAddress='testing1@thehunleygroup.com';
        wrapper1.FirstName='First Name1';
        wrapper1.LastName='Last Name1';
        wrapper1.StandardBodies[0].RegistrationNumber = 'REG1';
        
        
        LandLAddAttendeesBulkController.createNewAttendee(wrapper1, evt.Id);
        
        
        LandLAddAttendeesBulkController.AttendeeWrapper wrapper2 =  LandLAddAttendeesBulkController.addRow(evt.Id);
        wrapper2.EmailAddress='testing2@thehunleygroup.com';
        wrapper2.FirstName='First Name2';
        wrapper2.LastName='Last Name3';
        wrapper2.Company ='Test Company';
        wrapper2.StandardBodies[0].RegistrationNumber = 'REG2';
        
        
        LandLAddAttendeesBulkController.createNewAttendee(wrapper2, evt.Id);
        
        
        List<LandLAddAttendeesBulkController.AttendeeWrapper> wrapperList = LandLAddAttendeesBulkController.getAttendees(evt.Id);
        system.assertEquals(3, wrapperList.size());
            
        LandLAddAttendeesBulkController.AttendeeWrapper editedAttendee = wrapperList[0];
        editedAttendee.FirstName = 'First Name-1';
        
        LandLAddAttendeesBulkController.editAttendee(editedAttendee);
        
        Event_Attendee__c evtAttendee = [select Id,FirstName__c
                                         from Event_Attendee__c
                                         where FirstName__c = 'First Name-1'];
        
        system.assertEquals(editedAttendee.AttendeeId, evtAttendee.Id);
        
        LandLAddAttendeesBulkController.AttendeeWrapper editedAttendee2 = wrapperList[1];
        editedAttendee2.FirstName = 'First Name-2';
        
        LandLAddAttendeesBulkController.editAttendee(editedAttendee2);
    }
    
}