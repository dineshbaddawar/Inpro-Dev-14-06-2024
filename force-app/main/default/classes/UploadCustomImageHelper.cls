public with sharing class UploadCustomImageHelper {
    
    @AuraEnabled()
    public static string uploadCustomImage(String fileId, string quoteId, string quoteDetailId, string illustratorDrawingRequestID, string notes){            
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.Result results = service.SaveCustomImage(fileId, quoteId, quoteDetailId, illustratorDrawingRequestID, 'dsj8U73_3nv3Dhba');

        QuoteLineItem qli = [SELECT Id, Material_Allocation_Note__c FROM QuoteLineItem WHERE Id = :quoteDetailId LIMIT 1];
        qli.Material_Allocation_Note__c = notes;
        update qli; 

        if(results.Message != '')
            return results.Message;   
        else {
            return 'Image Uploaded Successfully.';
        }
    }

    @AuraEnabled()
    public static string getQuoteDetailNotes(String quoteDetailId){      
        QuoteLineItem qli = [SELECT Id, Material_Allocation_Note__c FROM QuoteLineItem WHERE Id = :quoteDetailId LIMIT 1];
        if (qli != null && qli.Material_Allocation_Note__c != null)
        {
            return qli.Material_Allocation_Note__c;
        }
        else{
            return 'Face:\r\nText:\r\nBorder/Accent:\r\nBackplate:\r\nBacker:\r\nLogo:\r\nGraphic:\r\nProduction Type:\r\nMaterial Listing:';
        }
    }

    @AuraEnabled()
    public static  List<IDR_Line_Item__c> getQuoteInfo(String recordId){      
      string Query = 'SELECT Id, Quote__c, Quote_Line_Item__c,IDR__c FROM IDR_Line_Item__c where Id = :recordId LIMIT 1';
      List<IDR_Line_Item__c> IDRLineItems = Database.query(Query);
      return IDRLineItems;    
    }

    @AuraEnabled()
    public static string getExistingImage(String quoteDetailId){
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.CustomImageExistsResult results = service.CheckCustomImages(quoteDetailId,  'dsj8U73_3nv3Dhba');
        if(results.FileData == '')   
        {
            return 'No Image Found';
        }
        else {
            return results.FileData;
        }
    }
}