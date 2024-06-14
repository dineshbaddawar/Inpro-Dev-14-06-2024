@isTest
public class PrintControllerTest {
    @isTest static void PrintTest() {
        Account acc = new account();
        acc.name ='Test Architect Account for Samples';
        acc.phone ='9999999999';
        acc.BillingCity='Test';
        acc.BillingState='California';
        acc.BillingStreet='Test';
        acc.BillingPostalCode ='34567';
        acc.CurrencyIsoCode =[SELECT Id, ConversionRate, IsoCode FROM CurrencyType][0].IsoCode;
        insert acc;
        Contact con  = new contact();
        con.accountId =acc.Id;
        con.LastName ='Test Architect contact';
        insert con;
        Sample_Request__c sample = new Sample_Request__c();
        sample.Account__c =acc.Id;
        sample.Contact__c =con.Id;
        sample.Status__c ='New';
        sample.Desired_Shipping_Method__c ='UPS_GROUND';
        sample.Ship_To__c ='Account - Billing';
        sample.Type__c ='Promotional Request';
        sample.ISR__c = [SELECT Id FROM USER LIMIT 1].Id;
        insert sample;
        
        PageReference pageRef = Page.SampleRequestPrintTicket;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('Id',sample.Id);
        PrintTicketController ptc = new PrintTicketController();
        ptc.sampleRequest.Id =sample.Id;
        ptc.updatePrintDate();
    }
    
     @isTest static void PrintBulkTest() {
        Account acc = new account();
        acc.name ='Test Architect Account for Samples';
        acc.phone ='9999999999';
        acc.BillingCity='Test';
        acc.BillingState='California';
        acc.BillingStreet='Test';
        acc.BillingPostalCode ='34567';
        acc.CurrencyIsoCode =[SELECT Id, ConversionRate, IsoCode FROM CurrencyType][0].IsoCode;
        insert acc;
        Contact con  = new contact();
        con.accountId =acc.Id;
        con.LastName ='Test Architect contact';
        insert con;
        Sample_Request__c sample = new Sample_Request__c();
        sample.Account__c =acc.Id;
        sample.Contact__c =con.Id;
        sample.Status__c ='New';
        sample.Desired_Shipping_Method__c ='UPS_GROUND';
        sample.Ship_To__c ='Account - Billing'; 
        sample.Type__c ='Promotional Request';
        sample.ISR__c = [SELECT Id FROM USER LIMIT 1].Id;
        insert sample;
        
       
        
        
        PageReference pageRef = Page.PrintTickets;
        Test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',String.valueOf(sample.Id));
        
      //  ApexPages.StandardSetController sc = new ApexPages.StandardSetController(sample);
       // PrintController pc = new PrintController(sc);
         
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, OwnerId FROM Sample_Request__c LIMIT 2]));
        setCon.setSelected([SELECT Id, OwnerId FROM Sample_Request__c LIMIT 2]); // this method gives selected records
        //apex_class_example t = news apex_class_example(setCon);
         PrintController pc = new PrintController(setCon);
         pc.sampleRequestList =[SELECT Id FROM Sample_Request__c LIMIT 2];
         pc.updatePrintDate();         
    }
    
}