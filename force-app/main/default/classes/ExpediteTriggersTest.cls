@isTest
private class ExpediteTriggersTest {
    @isTest static void testExpediteRequestTrigger() {
        Test.setMock(WebServiceMock.class, new sfExpediteTest());
        Expedite_Request__c er = new Expedite_Request__c();
        er.Name = 'Test Expedite Request';
        er.Expedite_Part_Number__c = 'DW-EXPEDITE-2F | Fabrication Expedite';
        er.NetSuite_ID__c = '1234';
        insert er;

        er.Expedite_Part_Number__c = 'DW-EXPEDITE-1 | Customer Shipping Expedite';
        update er;
    }

    @isTest static void testExpediteSupplierOptionTrigger() {
        Test.setMock(WebServiceMock.class, new sfExpediteTest());
        Expedite_Request__c er = new Expedite_Request__c();
        er.Name = 'Test Expedite Request';
        er.Expedite_Part_Number__c = 'DW-EXPEDITE-2F | Fabrication Expedite';
        er.NetSuite_ID__c = '1234';
        insert er;
        
        Expedite_Supplier_Option__c eso = new Expedite_Supplier_Option__c();
        eso.NetSuite_ID__c = '1234';
        eso.Cost__c = 123;
        eso.Expedite_Request__c = er.Id;
        insert eso;

        eso.Selected_Option__c = true;
        update eso;
    }
}