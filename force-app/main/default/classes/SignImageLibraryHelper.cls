public with sharing class SignImageLibraryHelper {
   
    @invocablemethod(label='Get Quote Detail Ids With Images')
    public static List<string> getQuoteDetailIdsWithImages(List<string> recordId)
    {
        string rId = recordId[0];
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.RetrieveSavedImagesResult results = service.RetrieveSavedImages(rId, 'dsj8U73_3nv3Dhba');
        if(results.Status)
        {
            if (results.SavedImages.SavedImage != null && results.SavedImages.SavedImage.size() > 0)
            {
                List<sfdata.SavedImage> images = results.SavedImages.SavedImage;
                List<string> quoteDetailIds = new List<string>();
                string test = '';
                for(sfdata.SavedImage image : images)
                {
                    test += test == '' ? image.QuoteDetailId : ',' + image.QuoteDetailId;
                }
                quoteDetailIds.add(test);
                return quoteDetailIds;
            }
            else return new List<string>();
        }
        else
            return new List<string>();  
    }

    @AuraEnabled()
    public static string getSignImages(String recordId, string fileId){        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.RetrieveSavedImagesResult results = service.RetrieveSavedImages(recordId, 'dsj8U73_3nv3Dhba');
        if(results.Status)
        {
            if (results.SavedImages.SavedImage != null && results.SavedImages.SavedImage.size() > 0)
                return JSON.serialize(results.SavedImages.SavedImage);
            else return '';
        }
            
        else
            return results.Message;   
    }

    @AuraEnabled()
    public static string getFullSignImage(String recordId, String imageId)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.RetrieveSavedImagesResult results = service.RetrieveFullSavedImage(recordId, imageId, 'dsj8U73_3nv3Dhba');
        if(results.Status)
        {
            if (results.SavedImages.SavedImage != null && results.SavedImages.SavedImage.size() > 0)
                return JSON.serialize(results.SavedImages.SavedImage);
            else return '';
        }
            
        else
            return results.Message;  
    }

    @AuraEnabled()
    public static string deleteSignImage(String imageId){        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.Result results = service.DeleteSavedImage(imageId, 'dsj8U73_3nv3Dhba');        
            if (results.Message == '')
                return 'Success!';
            else
                return results.Message;   
    }

    @AuraEnabled()
    public static string copySignImage(String imageId, String quoteId, String quoteDetailId, Boolean useUpdate){        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.Result results = service.CopySavedImage(imageId, quoteId, quoteDetailId, useUpdate, 'dsj8U73_3nv3Dhba');        
            if (results.Message == '')
                return 'Success!';
            else
                return results.Message;   
    }

    @AuraEnabled()
    public static List<QuoteLineItem> getQuoteLineItems(String quoteId){
        String Query = 'SELECT Id, Alternate__c, Alternate_Name__c, SignScheduleId__c, Item_Number__c, Quantity,Description, Description_2__c, Note__c FROM QuoteLineItem WHERE QuoteId = :quoteId';
        List<QuoteLineItem> quoteLineItems = Database.query(Query);
        return quoteLineItems;    
    }

    @future (callout = true)
    public static void cloneSignImages(String userId,String imageId,String signScheduleItemId,String signScheduleId,String quoteId,String quoteDetailId,String quoteNumber) {                
          sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
          service.timeout_x = 120000;         
          service.CloneSignImage(userId,imageId,signScheduleItemId,signScheduleId,quoteId,quoteDetailId,quoteNumber,'dsj8U73_3nv3Dhba');
    }  

}