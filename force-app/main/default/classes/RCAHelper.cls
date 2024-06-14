public with sharing class RCAHelper {
    @AuraEnabled
    public static string SubmitRCARequest(string rcaId) {        
            InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
            service.timeout_x = 120000;
            return service.SubmitRCA('dsj8U73_3nv3Dhba', rcaId);  
    }

    @AuraEnabled
    public static string SendRCAToNetSuite(string rcaId) {        
            InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
            service.timeout_x = 120000;
            return service.SendRCAToNetSuite('dsj8U73_3nv3Dhba', rcaId);  
    }

    @AuraEnabled
    public static string ApproveRCARequest(string rcaId, string notes, string userId) {        
            InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
            service.timeout_x = 120000;
            return service.ApproveRCARequest('dsj8U73_3nv3Dhba', rcaId, notes, userId);  
    }

    @AuraEnabled
    public static string RejectRCARequest(string rcaId, string notes, string userId) {        
            InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
            service.timeout_x = 120000;
            return service.RejectRCARequest('dsj8U73_3nv3Dhba', rcaId, notes, userId);  
    }

    @AuraEnabled
    public static string CreateRCARequest(string rcaType, string orderNumber, string invoiceNumber, string createdById) {        
            InproRCA.RCAServiceSoap service = new InproRCA.RCAServiceSoap();
            service.timeout_x = 120000;
            return service.CreateRCAFromSalesforce('dsj8U73_3nv3Dhba', rcaType, orderNumber, invoiceNumber, createdById);  
    }

    @AuraEnabled
    public static List<RCA__c> GetCurrentRCA(string rcaId)
    {
        try {
            String Query = 'SELECT RCA_Type__c, Total_Inpro_Impact__c, Days_Since_Invoice__c, Status__c FROM RCA__c WHERE Id = :rcaId LIMIT 1';
            List<RCA__c> RCA = Database.query(Query);
            return RCA;
             
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static string IsRCAApprovalInProcess(string rcaId)
    {
        try {
            String Query = 'SELECT Id FROM RCA_Approval_Step__c WHERE RCA__c = :rcaId AND Status__c = \'In Process\' LIMIT 1';
            List<RCA_Approval_Step__c> steps = Database.query(Query);
            if(steps != null && steps.size() > 0)
                return 'true';
            else 
                return 'false';      
             
        } catch (Exception e) {
            return e.getMessage();
        }
    }  
}