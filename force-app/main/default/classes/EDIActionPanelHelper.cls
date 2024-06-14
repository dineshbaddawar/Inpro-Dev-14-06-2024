public with sharing class EDIActionPanelHelper {
    @AuraEnabled()
    public static List<EDI_Detail__c> getEDIDetails(string recordId) {       
        
       List<EDI_Detail__c> details =  [SELECT CreatedById, CreatedDate, CurrencyIsoCode, EDI_Header__c, Id, Inpro_Unit_Price__c,
                                              IsDeleted, LastModifiedById, LastModifiedDate, Line_Change_Code__c, Line_Number__c, Name, 
                                              Notes__c, OwnerId, Quantity__c, Response__c, Ship_Date__c, SystemModstamp, UOM__c, Unit_Price__c,
                                              Vendor_Item_Number__c, Vendor_Sku__c,EDI_Header__r.Account_Number__c
                                        FROM EDI_Detail__c
                                        WHERE EDI_Header__c = :recordId];    
                       if(details.size()> 0)
                       {                                        
                          if(details[0].EDI_Header__r.Account_Number__c != null
                           && details[0].EDI_Header__r.Account_Number__c != '')
                          {
                              string AccountNumber = details[0].EDI_Header__r.Account_Number__c;
                              EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
                                    service.timeout_x = 120000;    
                              for (EDI_Detail__c detail : details) 
                              {   
                                  if(detail.Inpro_Unit_Price__c > 0)
                                        detail.Line_Change_Code__c = String.valueOf(detail.Inpro_Unit_Price__c);

                                    Decimal price = service.PriceCheck(detail.Name, AccountNumber);
                                    detail.Inpro_Unit_Price__c = price;
                              }
                          }
                       }
                        
          return details;                               
    }

    @AuraEnabled()
    public static Order_Request__c getOrderRequest(string recordId) {       
        

        List<EDI_Header__c> ediHeaders = [SELECT Quote__c
                                            FROM EDI_Header__c
                                            WHERE Id = :recordId];
            
                    if(ediHeaders.size() > 0)
                    {
                        string quoteId = ediHeaders[0].Quote__c;

                                List<Order_Request__c> orderRequests =  [SELECT QuoteId__c, Id, Name, Opportunity__c, Opportunity__r.Name,
                                                                        QuoteId__r.Name
                                                                    FROM Order_Request__c
                                                                    WHERE QuoteId__c = :quoteId];            
                                    if(orderRequests.size() > 0)
                                        return orderRequests[0];
                                    else
                                        return null;         
                    }
                    else return null;                      
     }

    @AuraEnabled
    public static string updateDetails(List<EDI_Detail__c> details){
        try {
            
            update details;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string resendNexusInvoice(string recordId){                

        string ediDocumentId = '';
        string invNo = '';        
        List<EDI_Document__c> ediDocs = [SELECT Id, Name
                                    FROM EDI_Document__c
                                    WHERE Id = :recordId LIMIT 1];

        if(ediDocs.size() > 0)
        {
            ediDocumentId = recordId;            
            invNo = ediDocs[0].Name.split('\\.')[0];
        }
        else 
        {
           List<EDI_Error_Log__c> errorLogs =  [SELECT Id, Name
                                                FROM EDI_Error_Log__c
                                                WHERE Id = :recordId LIMIT 1];
            if(errorLogs.size() > 0)            
            {
                invNo = errorLogs[0].Name;    
            }
        }

        EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
        service.timeout_x = 120000;                  
        return service.RunVentas(invNo, ediDocumentId, 'dsj8U73_3nv3Dhba');        
    }    

    @AuraEnabled(cacheable=true)
    public static List<file> getRelatedFiles(String recordId){
        List<File> files = new List<File>();

            for(ContentDocumentLink conLink : [SELECT 
                                                    ContentDocument.Id, 
                                                    ContentDocument.Title, 
                                                    ContentDocument.CreatedDate, 
                                                    ContentDocument.FileType
                                                        FROM ContentDocumentLink 
                                                            WHERE LinkedEntityId =:recordId]){
                File file = new File();
                file.Title = conLink.ContentDocument.Title;
                file.Id = conLink.ContentDocument.Id;
                file.CreatedDate = conLink.ContentDocument.CreatedDate;
                file.Type = conLink.ContentDocument.FileType;
                files.add(file);
            
        }
        return files;
    }    

    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
        @AuraEnabled public Datetime CreatedDate;
    }
}