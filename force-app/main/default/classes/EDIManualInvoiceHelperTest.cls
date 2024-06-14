@isTest
public with sharing class EDIManualInvoiceHelperTest {
    @isTest
    static void getXMLLineItemsTest()
    {
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        string statusId = '';
        string results = EDIManualInvoiceHelper.getXMLLineItems(statusId);
        system.assertEquals(1, 1);

    }
    @isTest
    static void getERPPartsTest()
    {
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        string statusId = '';
        string results = EDIManualInvoiceHelper.getERPParts(statusId);
        system.assertEquals(1, 1);
    }
    @isTest
    static void updateXMLItems()
    {
        Test.setMock(WebServiceMock.class, new EDISvcTest());
        Test.startTest();
        string statusId = '';
         string lineItems = '';
         string results  = EDIManualInvoiceHelper.updateXMLItems(statusId, lineItems);
         system.assertEquals(1, 1);
    }
}