public with sharing class CustomFormsHelper {
    @AuraEnabled(Cacheable = true)
    public static string getCustomOrderForms() {
                      
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfCustomForm results = service.GetCustomForms('dsj8U73_3nv3Dhba');
        return  JSON.serialize(results.CustomForm);
    }  


    @AuraEnabled()
    public static string downloadOrderForms(string recordId, string reportName, Boolean isBlank, Boolean isMetric, string division) {
        try {                                   
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            sfdata.DownloadStatus results = service.DownloadCustomForm(recordId, reportName, isBlank, isMetric, 'dsj8U73_3nv3Dhba', division);

            if (results.Status) {
                return  results.FileData;
            }
            else {
                return results.Message;
            }
        }
         catch (Exception ex) 
        {
            return  JSON.serialize(ex);
        }   
        
    }  

}