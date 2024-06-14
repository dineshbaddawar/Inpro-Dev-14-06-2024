public with sharing class OrderHelper {

    @AuraEnabled
    public static string getLineItems(string recordId){
        try {
            string results = 'Error';
            if (recordId != '')
            {             
                string tranId = '';
                String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();  
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;        

                if(sObjName == 'Order')
                {
                    tranId = [SELECT Id, NetSuite_TranId__c FROM Order where Id = :recordId limit 1].NetSuite_TranId__c;
                    results = service.getNetSuiteSalesOrderLines(tranId, 'dsj8U73_3nv3Dhba');
                }
                else
                {
                    tranId = [SELECT Id, Name FROM Invoice__c where Id = :recordId limit 1].Name;
                    results = service.getNetSuiteInvoiceLines(tranId,'dsj8U73_3nv3Dhba');
                }
            }
            
            return results;
        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }

    @AuraEnabled
    public static string getItemFulfillments(string recordId){
        try {
            string results = 'Error';
            if (recordId != '')
            {             
                string tranId = '';
                String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();  
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;        
              
                tranId = [SELECT Id, NetSuite_TranId__c FROM Order where Id = :recordId limit 1].NetSuite_TranId__c;
                results = service.getNetSuiteFulfillments(tranId, 'dsj8U73_3nv3Dhba');              
            }
            
            return results;
        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }

    @AuraEnabled
    public static string getItemFulfillmentItems(string fulfillmentId){
        try {
            string results = 'Error';             
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;        
            
            results = service.getNetSuiteFulfillmentItems(fulfillmentId, 'dsj8U73_3nv3Dhba');                         
            return results;

        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }  

    @AuraEnabled
    public static string getOrderHeaderInformation(string recordId, string recordType){
        try {
            string results = 'Error';             
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;        
            string tranId = [SELECT Id, NetSuite_TranId__c FROM Order where Id = :recordId limit 1].NetSuite_TranId__c;
            if(tranId != null)
            {
                if(recordType == 'Order')
                    results = service.getNetSuiteOrderHeaderInformation(tranId, 'dsj8U73_3nv3Dhba'); 
                                        
                return results;
            }
            else 
                return 'Error: The current order does not have a NetSuite document number specified.';

        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }  
}