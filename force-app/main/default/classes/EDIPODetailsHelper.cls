public with sharing class EDIPODetailsHelper {
    @AuraEnabled
    public static String getPOHeaders(string recordId) {         
       
        String qSOQL = 'Select Project_Number__c FROM Opportunity WHERE Id = :recordId LIMIT 1';
        List<Opportunity> oppList =  Database.Query(qSOQL);
        String quoteNumber = oppList[0].Project_Number__c;

            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            sfdata.ArrayOfString results = service.GetEDIHeaders(quoteNumber, 'dsj8U73_3nv3Dhba');
            return  JSON.serialize(results.string_x);
      }
}