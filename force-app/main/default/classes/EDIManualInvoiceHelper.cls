public with sharing class EDIManualInvoiceHelper {

    @AuraEnabled()
    public static string getXMLLineItems(string statusId){
        try {            
            EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
            service.timeout_x = 120000;    
            return service.RetrieveXMLLineItems(statusId, getEDIHeaderId(statusId));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled()
    public static string getERPParts(string statusId){
        try {                                    
            EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
            service.timeout_x = 120000;    
            string ediHeaderId = getEDIHeaderId(statusId);            
            return service.RetrieveGraingerMacolaParts(ediHeaderId, statusId);                         
        } catch (Exception e) {
           system.debug(e);
           return null;
        }
    }

    @AuraEnabled()
    public static string updateXMLItems(string statusId, string lineItems){
        try {                        
            EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
            service.timeout_x = 120000;    
            service.UpdateXMLLineItems(statusId, getEDIHeaderId(statusId),lineItems);            
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    private static string getEDIHeaderId(string statusId)
    {
       return [SELECT EDI_Header__c FROM EDI_Status_Detail__c WHERE Id = :statusId limit 1].EDI_Header__c;
    }

}