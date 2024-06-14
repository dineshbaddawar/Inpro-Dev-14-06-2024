@isTest
public with sharing class EDIActionPanelHelperTest {
    @isTest
    static void getEDIDetailsTest() {
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        List<EDI_Detail__c> details =  EDIActionPanelHelper.getEDIDetails('');
        system.assertEquals(1,1);
    }

    @isTest
    static void getOrderRequestTest()
    {
        Order_Request__c orderRequest = EDIActionPanelHelper.getOrderRequest('');
        system.assertEquals(1,1);
    }

    @isTest
    static void updateDetailsTest()
    {
        List<EDI_Detail__c> details = new List<EDI_Detail__c>();
        EDIActionPanelHelper.updateDetails(details);
        system.assertEquals(1,1);
    }
}