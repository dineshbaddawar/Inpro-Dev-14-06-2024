public with sharing class CustomPricingHelper {
    @AuraEnabled()
    public static List<QuoteLineItem> getQuoteLineItems(string quoteId) {
        string Query = 'SELECT Id, Is_Custom_Product__c, Custom_Pricing_Requested__c, Document_Name__c, ' +
                      'Item_Number__c, Customer_Priced_On__c, Description, Description_2__c, Alternate__c, QuoteId, Alternate_Name__c ' +
                      'FROM QuoteLineItem where QuoteId = :quoteId and Is_Custom_Product__c = true and Custom_Pricing_Requested__c = false';
            List<QuoteLineItem> quoteLineItems = Database.query(Query);
          return quoteLineItems;     
                          
    }
    
    @AuraEnabled()
    public static List<QuoteLineItem> getCustomPricingLineItems(string customPricingId) {
        string Query = 'SELECT ' +
                            'LineNumber__c,Item_Number__c, RecordId__c,ParentId__c,Quote.Id,Id,Alternate__r.Name__c,Additional_Liner__c, ' +
                            'Yards_Per_Line__c,Labor__c,Room_Location__c,Style__c, ' +
                            'Quantity,Mounting_Type__c,Pattern__c,Fabric_Width__c, ' +
                            'Fabric_Vertical_Repeat__c,Color__c,Height__c,Return__c, ' +
                            'Lining__c,Thickness__c,Color_2__c,Color_3__c,Color_4__c, ' +
                            'Color_5__c,Vendor__c,Vendor_2__c,Pattern_2__c,Width__c, ' +
                            'Note__c,Height_2__c,Height_3__c,Sewing_Type__c,Sewing_Type_2__c, ' +
                            'Installation__c,Fullness__c,Operator__c,Draw_Type__c, ' +
                            'Window_Depth__c,Railroad__c,Chain_Guide__c,Hem_Bar__c,Accessory__c, ' +
                            'Size__c,Size_2__c,Rod_Part_Number__c,Stiffener__c,Type__c, ' +
                            'Unit_Cost__c,Operator_Location__c,T_Note__c,Tilt__c,Lift__c, ' +
                            'Valance__c,Valance_2__c,Tilt_2__c,Lift_2__c,Brackets__c, ' +
                            'Brackets_2__c,Quote_Note__c,Privacy_Slat__c,Fabric_Tape__c, ' +
                            'Document_Name__c,Custom_Pricing__c, Custom_Pricing__r.CreatedBy.Id, Quote.QuoteNumber ' +
                    'FROM ' +
                        'QuoteLineItem WHERE Custom_Pricing__c = :customPricingId';
            List<QuoteLineItem> quoteLineItems = Database.query(Query);
          return quoteLineItems;                     
    }

    @AuraEnabled()
    public static string updateQuoteProducts(string userId, string quoteProducts) {
        try {
             custompricing.CustomPricingServiceSoap service = new  custompricing.CustomPricingServiceSoap();
             service.timeout_x = 120000;

             custompricing.Result results = service.SubmitCustomPricingActivities(userId, quoteProducts,'dsj8U73_3nv3Dhba');            
             return results.Message;                     
        } catch (Exception ex) {
            return JSON.serialize(ex);
        }   
    }
    @AuraEnabled()
    public static string createPricingRequests(String userId, List<string> quoteProducts)
    {
        try {
            custompricing.CustomPricingServiceSoap service = new  custompricing.CustomPricingServiceSoap();
            service.timeout_x = 120000;
            custompricing.ArrayOfString stringArray = new custompricing.ArrayOfString();
            stringArray.string_x = quoteProducts;
            custompricing.Result results = service.CreateCustomPricingActivities(userId,stringArray, 'dsj8U73_3nv3Dhba');            
            return results.Message;                     
       } catch (Exception ex) {
           return JSON.serialize(ex);
       }   
    }

    @AuraEnabled()
    public static string cancelPricingRequests(String userId, List<string> quoteProducts)
    {
        try {

            List<QuoteLineItem> quoteLines = new List<QuoteLineItem>();          

            for (string id : quoteProducts) {
                QuoteLineItem lineItem = new QuoteLineItem();
                lineItem.Custom_Pricing_Requested__c = false;
                lineItem.Id = id;
                quoteLines.Add(lineItem);
            }

            update quoteLines;

            return 'Success';
                 
       } catch (Exception ex) {
           return JSON.serialize(ex);
       }   
    }

    @AuraEnabled()
    public static string resetCustomPricing(string quoteId) {
          try {

            string Query = 'SELECT Id, Is_Custom_Product__c, Custom_Pricing_Requested__c, Document_Name__c, ' +
            'Item_Number__c, Customer_Priced_On__c, Description, Description_2__c, Alternate__c, QuoteId, Alternate_Name__c ' +
            'FROM QuoteLineItem where QuoteId = :quoteId and Is_Custom_Product__c = true and Custom_Pricing_Requested__c = true';

            List<QuoteLineItem> quoteLineItems = Database.query(Query);
            List<QuoteLineItem> quoteLines = new List<QuoteLineItem>();

            for (QuoteLineItem lineItem : quoteLineItems) {  
                
                QuoteLineItem item = new QuoteLineItem();
                item.Custom_Pricing_Requested__c = false;
                item.Id = lineItem.id;
                quoteLines.Add(item);
            }

            update quoteLines;

          List<AsyncProcess__c> asyncProcesses =
            [SELECT ObjectId__c, Log__c, 
                    Status__c, Id
             FROM AsyncProcess__c
             WHERE Status__c = 'In-Process' 
             AND ObjectId__c = :quoteId];
             
             List<AsyncProcess__c> asyncToUpdate = 
             new List<AsyncProcess__c>();

            for (AsyncProcess__c ap : asyncProcesses) {
                AsyncProcess__c async = new AsyncProcess__c();
                async.Id = ap.Id;
                async.Status__c = 'Complete';
                asyncToUpdate.add(async);
            }

            update asyncToUpdate;

            return 'Success'; 
                 
       } catch (Exception ex) {
           return JSON.serialize(ex);
       }                  
    }

    @AuraEnabled
    public static string cancelAsyncSave(string quoteId){
        try {
            
            List<AsyncProcess__c> asyncProcesses =
            [SELECT ObjectId__c, Log__c, 
                    Status__c, Id
             FROM AsyncProcess__c
             WHERE Status__c = 'In-Process' 
             AND ObjectId__c = :quoteId];
             
             List<AsyncProcess__c> asyncToUpdate = 
             new List<AsyncProcess__c>();

            for (AsyncProcess__c ap : asyncProcesses) {
                AsyncProcess__c async = new AsyncProcess__c();
                async.Id = ap.Id;
                async.Status__c = 'Complete';
                asyncToUpdate.add(async);
            }

            update asyncToUpdate;

            return 'Success'; 
        } catch (Exception e) {
            return JSON.serialize(e);
        }
    }
   
}