public with sharing class accountToNSHelper {
    @AuraEnabled
    public static string AddAccountToNetSuite(string accountId) {        
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
         return service.AddAccountToNetSuite(accountId, 'dsj8U73_3nv3Dhba');  
    }
}