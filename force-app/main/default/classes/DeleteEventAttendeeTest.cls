/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:   
* ==========================================================================
* Purpose:      This is the test class for DeleteEventAttendee class.  
*				
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/
@istest
public class DeleteEventAttendeeTest {
    
    @testsetup static void createRecord(){
        BitlyAccessToken__c Credentials = new BitlyAccessToken__c();
        Credentials.name='Credentials';
        Credentials.Access_Token__c= 'test';
        Credentials.API_Key__c='test'; 
        Credentials.user_name__c='test';  
        Credentials.Endpoint__c= 'https://test';
        Credentials.Group_guid__c='test';
        insert Credentials;
        Datetime startdt = System.today();
        Datetime enddt = System.today();
        enddt = enddt.addDays(5);
        Account acc = new Account(Name='Test',BillingCity='Kochi',BillingStreet='test street',BillingState='Alaska',BillingCountry='United States',BillingPostalCode='689510');  
        insert acc;
        List<Contact> con = new List<Contact>(); 
        integer i=0;
        for(i=0;i<5;i++) {
            Contact cont = new Contact();
            cont.FirstName = 'Test';
            cont.LastName = 'Test'+i;
            cont.AccountId = acc.Id;
            cont.MailingCountry = 'India';
            cont.MailingPostalCode = '683575';
            con.add(cont);
        }
        insert con;
        Course__c cp = new Course__c();
        cp.Name = 'Test-Campaign';
        
        insert cp;
        Test.setMock(HttpCalloutMock.class, new MockHttpURLShort());  
        LunchAndLearnEvent__c lunchevent = new LunchAndLearnEvent__c();
        lunchevent.Name = 'TestEvent';
        lunchevent.StartDateTime__c = startdt ;
        lunchevent.EndDateTime__c = enddt;
        lunchevent.Course_Name__c = cp.Id;  
        lunchevent.Location__c = 'India';
        insert lunchevent;
        List<Event_Attendee__c> campaigmemberlist = new List<Event_Attendee__c>();
        for(Contact conta : con) {
            Event_Attendee__c CampaignMemberRecord = new Event_Attendee__c();  
            CampaignMemberRecord.Course__c    =   lunchevent.Course_Name__c;
            CampaignMemberRecord.Contact__c     =    conta.Id;
            CampaignMemberRecord.LunchAndLearnEvent__c  =   lunchevent.Id;
            CampaignMemberRecord.Email_Opt_In__c     =   false;
            CampaignMemberRecord.created_by_admin__c  =  true;
            campaigmemberlist.add(CampaignMemberRecord);
        }
        insert campaigmemberlist;
    }
    
    static testMethod void testMethodURLShort() {
        // test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpURLShort());  
        Course__c testCampaign= new Course__c(Name='Test Course');
        insert testCampaign;
        Account accObj = new Account(Name='Test',BillingCountry='India');
        insert accObj;
        LunchAndLearnEvent__c eventObj= new LunchAndLearnEvent__c (StartDateTime__c=system.today(),EndDateTime__c=system.today()+1,Course_Name__c=testCampaign.id,Related_To__c=accObj.id);
        insert eventObj;
        //  BitlyIntegrationRestCall.UrlShorten(eventObj.id);
        BitlyIntegrationRest.shortenLandLRegistrationLinks(eventObj.id,'Attendance_Link1__c','Attendance_Link__c');
        // test.stopTest();
    }
    
    static testMethod void testMethodBitlyIntegrationAccessRes() {
        test.startTest();
        BitlyIntegrationAccessRes obj =new BitlyIntegrationAccessRes ();
        obj.access_token='123';
        obj.login='123';
        obj.apiKey='123';
        test.stopTest();
    }
    
    static testMethod void testDeleteAttendeePositive() {
        test.startTest(); 
        testMethodURLShort();
        LunchAndLearnEvent__c lunchtest = new LunchAndLearnEvent__c();
        lunchtest = [SELECT Id, Name FROM LunchAndLearnEvent__c where Name =:'TestEvent']; 
        system.debug('lunchtest ---> '+lunchtest ); 
        PageReference pageRef = Page.DeleteEventAttendeeVF; 
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',lunchtest.Id);
        LunchAndLearnEvent__c LunchL = new LunchAndLearnEvent__c();
        DeleteEventAttendee delattend = new DeleteEventAttendee(new ApexPages.StandardController(LunchL));
        System.debug('delattend.listMemberWrapper'+delattend.listMemberWrapper);
        delattend.listMemberWrapper[0].selected =true;
        delattend.processSelected();
        test.stopTest(); 
    }
    
}