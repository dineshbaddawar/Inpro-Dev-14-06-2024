@isTest
public class LandLRegistrationPageControllerTest {
    
    @testSetup public static void setup() {
        
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name = 'Credentials';
        insert Credentials;
        
        Account accObj = new Account(Name = 'Test', BillingCountry = 'India');
        insert accObj;
        
        Standards_Body__c stdBody1 = new Standards_Body__c();
        stdBody1.Name = 'AIA';
        stdBody1.Requires_Certificate__c = true;
        insert stdBody1;
        
        Standards_Body__c stdBody2 = new Standards_Body__c();
        stdBody2.Name = 'GBCI';
        stdBody2.Requires_Certificate__c = true;
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
            StartDateTime__c = system.today()-2,
            EndDateTime__c = system.today() -1,
            Course_Name__c = testCampaign.id,
            Related_To__c = accObj.id
        );
        insert eventObj;
    }
    
    public static testMethod void testControllerMethods() {
        
        LunchAndLearnEvent__c evt = [Select Id,EndDateTime__c from LunchAndLearnEvent__c limit 1];
        LandLRegistrationPageController.getLunchAndLearnEvent(evt.Id);
        
        List<LandLRegistrationPageController.StandardBodyWrapper> sbwList = LandLRegistrationPageController.getStandardBodyWrapper(evt.Id);
        for(LandLRegistrationPageController.StandardBodyWrapper sbw:sbwList){
            sbw.RegistrationNumber = 'TEST-REG';
        }
        
        system.debug('evt.EndDateTime__c'+evt.EndDateTime__c);
        
        LandLRegistrationPageController.createNewAttendee(evt.Id, 'FName', 'LName','', 'EmailAddress@thehunleygroup.com', true, true, sbwList);
        LandLRegistrationPageController.createNewAttendee(evt.Id, 'FName', 'LName','','testing1@thehunleygroup.com', true, true, sbwList);
        LandLRegistrationPageController.createNewAttendee(evt.Id, 'FName', 'LName','','testing2@thehunleygroup.com', true, true, sbwList);
        
        List<Event_Attendee__c> attendeeList = [Select Id from Event_Attendee__c
                                                where LunchAndLearnEvent__c =: evt.Id];
        for(Event_Attendee__c att:attendeeList){
            att.Mail_Send__c = false;
        }
        update attendeeList;
        
        system.assertEquals(3, attendeeList.size());
        
        ScheduledBatchSendCertificates.scheduleMe();
        
        BatchSendCertificates batch = new BatchSendCertificates();
        Database.executeBatch(batch);
        
    }
}