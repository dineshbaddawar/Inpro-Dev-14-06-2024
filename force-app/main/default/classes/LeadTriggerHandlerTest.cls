@isTest
public with sharing class LeadTriggerHandlerTest {
     

    @isTest
   public static void doLeadTesting()
    {
        Lead lead = new Lead();        
        lead.FirstName = 'First';
        lead.LastName = 'Last';
        lead.Email = 'test@inprocorp.com';
        lead.Company = 'Inpro Test';
        lead.Phone = '2626799010';
        lead.Country = 'United States';
        lead.Street = '123 Main Street';
        lead.City = 'Muskego';
        lead.State = 'Wisconsin';
        lead.PostalCode = '53105';
        lead.Email_Opt_In__c = true;        
        lead.Title = 'Test Title';
        lead.Market_Segment__c = 'Healthcare';
        lead.Project_Market_Segment__c = 'Healthcare';
        lead.Sub_Segment__c = 'Hospital';
        lead.Project_Sub_Segment__c = 'Hospital';
        lead.Products_Interested_in__c = 'Door and Wall Protection';
        //lead.OwnerId = 
        lead.LeadSource = 'Website';
        lead.Lead_Source_Details__c = 'Color Sample';
        lead.Description = 'Test description';
        //lead.Bid_Due_Date__c = 
        lead.Building_City__c = 'Muskego';
        lead.Building_Zip__c = '53105';
        lead.Building_Street__c = '123 Main Street';
        lead.Building_State__c = 'Wisconsin';
        lead.Building_Country__c = 'United States';
        insert Lead;
        
        Sample_Request__c sr = new Sample_Request__c();
        sr.Lead__c = Lead.Id;
        sr.Type__c = 'Acquired Marketing Lead';
        sr.Type__c = 'Web Request';
        insert sr;
        
        lead.ownerId = [select Id from User Limit 1].Id;
        update lead;

    }


}