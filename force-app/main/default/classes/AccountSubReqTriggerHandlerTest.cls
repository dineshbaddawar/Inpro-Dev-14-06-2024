@isTest
public class AccountSubReqTriggerHandlerTest {
    
    public static testmethod void testfn(){
        Test.setMock(WebServiceMock.class, new datawarehouseTest());
          Test.setMock(WebServiceMock.class, new sfdataTest());
          
        // we have to bootstrap with some GeoCode api settings for GeoCode.cls
        String strRes = '{"location":{"lat": 11,"lng":22}}';
        Google_API_Setting__c sobj = new Google_API_Setting__c(
            Request_Path__c = 'json',
            API_Key__c = 'xxxxxxx', 
            Base_URL__c = 'https://map.google.com/'
        );
        insert sobj;
        
        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Specialty Contractor').getRecordTypeId();
        Account acc =new Account();
        acc.Name='Test acc';
        acc.Billing_Street_Address__c='test street';
        acc.Market_Segment__c = 'Contractor';
        acc.Sub_Segment__c = 'Specialty Contractor';
        acc.RecordTypeId = contractorRecordTypeId;
        acc.ShippingPostalCode = '27513';
        insert acc;
        
        acc.BillingState = 'North Carolina';
        update acc;
        
       
        
        Account acc1 =new Account();
        acc1.Name='Test acc';
        acc1.Market_Segment__c = 'Contractor';
        acc1.Sub_Segment__c = 'Specialty Contractor';
        acc1.RecordTypeId = contractorRecordTypeId;
        acc1.ShippingPostalCode = '27513';
        acc1.BillingPostalCode='27513';
        insert acc1;
        
    }

}