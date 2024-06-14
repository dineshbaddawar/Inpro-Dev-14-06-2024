public with sharing class ReloadExperlogixConfigHelper {
    
    @AuraEnabled
    public static string reloadConfiguration (string recordId) 
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        String results = service.ReloadConfig(recordId, 'dsj8U73_3nv3Dhba');
        return results;
    }
}