@isTest
public class ResendLunchAndLearnTest {
    
    @testSetup public static void setup() {
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name = 'Credentials';
        insert Credentials;
        
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        
        Standards_Body__c stdBody1 = new Standards_Body__c();
        stdBody1.Name = 'AIA';
        stdBody1.Requires_Certificate__c =true;
        insert stdBody1;
        
        Standards_Body__c stdBody2 = new Standards_Body__c();
        stdBody2.Name = 'GBCI';
        stdBody2.Requires_Certificate__c =true;
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
        wrapper2.Company = 'Test Company';
        wrapper2.StandardBodies[0].RegistrationNumber = 'REG2';
        
        
        LandLAddAttendeesBulkController.createNewAttendee(wrapper2, evt.Id);
        
        List<Event_Attendee__c> eventAttendeeList = [Select Id,Status__c from Event_Attendee__c
                                                    where LunchAndLearnEvent__c = :evt.Id];
        for(Event_Attendee__c att:eventAttendeeList){
            att.Status__c = 'Attended';
        }
        update eventAttendeeList;
        
        List<ResendLunchAndLearnContact.AttendeeWrapper> wrapperList = ResendLunchAndLearnContact.getAttendees(evt.Id);
        for(ResendLunchAndLearnContact.AttendeeWrapper aw : wrapperList){
            system.assertEquals(false, aw.resend);
            aw.resend = true;
        }
            
        
        string attendeeListJSON =json.serialize(wrapperList);
        ResendLunchAndLearnContact.doEventLevelResend(attendeeListJSON); 
        
        PageReference myVfPage = Page.LandLEventCertificate;
        Test.setCurrentPage(myVfPage);
        LandLEventCertificateController obj = new LandLEventCertificateController();
    }
    
}