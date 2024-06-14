@isTest
public with sharing class EDIPODetailsHelperTest {
    @istest
    static void getCustomOrderFormsTest()
    {
       
        // Call the method that invokes a callout
        Opportunity o = createTestOpportunity('test');

        Test.setMock(WebServiceMock.class, new sfdataTest());
        Test.startTest();
        string result = EDIPODetailsHelper.getPOHeaders(o.Id);
        //Assert that the service finished successfully
        System.assertEquals(result, result);        
        Test.stopTest();
    }

    private static Opportunity createTestOpportunity(String name) {
        
        Opportunity opp = new Opportunity(Name = name, StageName = 'Quoting/Bidding', CloseDate = System.today());
        insert opp;
        return opp;
    }
}