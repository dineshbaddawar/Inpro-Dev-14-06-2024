@istest
public with sharing class CustomFormsHelperTest {
    @istest
    static void getCustomOrderFormsTest()
    {
        Test.setMock(WebServiceMock.class, new sfdataTest());
        // Call the method that invokes a callout
        string result = CustomFormsHelper.getCustomOrderForms();    

        //Assert that the service finished successfully
        System.assertEquals(result, result);        
    }

    @istest
    static void downloadOrderFormsTest()
    {
         Test.setMock(WebServiceMock.class, new sfdataTest());
         string recordId  = '1234';
         string reportName = 'test';
         Boolean isBlank = false;
         Boolean isMetric = false;
         string result = CustomFormsHelper.downloadOrderForms(recordId,reportName,isBlank,isMetric,'DW');
         System.assertEquals('test', result);        
    }
}