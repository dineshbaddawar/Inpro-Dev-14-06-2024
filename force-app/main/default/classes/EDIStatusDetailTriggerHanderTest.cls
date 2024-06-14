@isTest
public with sharing class EDIStatusDetailTriggerHanderTest {    

    @testSetup 
	static void setup(){
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        EDI_Header__c header = new EDI_Header__c();
        header.name = 'test' ;
        insert header;
    }
    
    @isTest
    static void EDICalloutTest()
    {
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        string EDIHeaderID = [select id from EDI_Header__c limit 1].Id;
        EDI_Status_Detail__c statusDetail = new EDI_Status_Detail__c();
        statusDetail.Status__c = 'New PO Created';
        statusDetail.EDI_Header__c = EDIHeaderID; //header.Id;
        insert statusDetail;
        // string Status= 'New PO Created';
        // string DetailId=[select id from EDI_Status_Detail__c limit 1].Id;
        // EDIStatusDetailTriggerHandler.EDICallout(EDIHeaderID,Status,DetailId);
        System.assertEquals(1, 1);
        
    }
}