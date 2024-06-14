public with sharing class WebserviceTriggerProxy {

    public static boolean firstRun = true;

    @future (callout = true)
    public static void AddAccountToNetSuite(string accountId) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        service.AddAccountToNetSuite(accountId, 'dsj8U73_3nv3Dhba');          
    }  

    @future (callout = true)
    public static void DeleteRecord(string objectType, string recordId) {
        if (!Test.isRunningTest())
        {
            datawarehouse.DataWarehouseSoap service = new datawarehouse.DataWarehouseSoap();
            service.timeout_x = 120000;
            service.DeleteRecord(objectType, recordId, 'dsj8U73_3nv3Dhba');       
        }                 
    }  

    @future (callout = true)
    public static void ApproveEcomRegistration(string email) {       
        if (!Test.isRunningTest())
        {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            service.ApproveUserRegistration(email, 'dsj8U73_3nv3Dhba');
        }
    }
}