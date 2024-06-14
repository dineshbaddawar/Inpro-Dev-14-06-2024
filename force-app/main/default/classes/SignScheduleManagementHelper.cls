public inherited sharing class SignScheduleManagementHelper {
   
    @AuraEnabled()
    public static List<Alternate__c> getAlternates(String recordId) {
        String Query = 'SELECT Id, Name, Name__c, Number__c FROM Alternate__c WHERE QuoteId__c = :recordId';
        List<Alternate__c> alternates = Database.query(Query);
        return alternates;    
    }

    @AuraEnabled()
    public static List<QuoteLineItem> getProducts(String recordId) {
        String Query = 'SELECT SignScheduleId__c, Id, QuoteId, Alternate__c, Item_Number__c, Quantity, Description FROM QuoteLineItem WHERE QuoteId = :recordId';
        List<QuoteLineItem> quoteLineItems = Database.query(Query);
        return quoteLineItems;    
    }

    @AuraEnabled()
    public static List<Sign_Schedule_Item__c> getSignScheduleItems(String signScheduleId) {
        
        String Query = 'SELECT Text_Too_Tall__c, Text_Too_Wide__c, SavedToCRM__c, Missing_Configuration_Info__c, ' + 
                            'Name, Id, Line1__c, Index__c, Line10__c, Line11__c, Line12__c, Line13__c, ' +
                            'Line14__c, Line15__c, Line16__c, Line17__c, Line18__c, Line19__c, Line2__c, Line20__c, Line3__c, Line4__c, ' +
                            'Line5__c, Line6__c, Line7__c, Line8__c, Line9__c, SignScheduleId__c,Line10Font__c, Line11Font__c, Line12Font__c, ' +
                            'Line13Font__c, Line14Font__c, Line15Font__c, Line16Font__c, Line17Font__c, Line18Font__c, Line19Font__c, Line20Font__c, ' +
                            'Line3Font__c, Line4Font__c, Line5Font__c, Line6Font__c, Line7Font__c, Line8Font__c, Line9Font__c ' + 
                            'FROM Sign_Schedule_Item__c WHERE SignScheduleId__c = :signScheduleId';
        List<Sign_Schedule_Item__c> signScheduleItems = Database.query(Query);
        return signScheduleItems;    
    }

    @AuraEnabled()
    public static List<Sign_Schedule_Item__c> createSignScheduleItems(String quoteDetailId, Integer quantity) {
        
        List<Sign_Schedule_Item__c> signScheduleItems = new List<Sign_Schedule_Item__c>();
        // Sign_Schedule__c signSchedule = new Sign_Schedule__c();

        // for (Integer i = 0; i < quantity; i++) {
        //     Sign_Schedule_Item__c s = new Sign_Schedule_Item__c();
        //     s.SignScheduleId__c = SignScheduleId;
        // }

        
        return signScheduleItems;    
    }

    @AuraEnabled()
    public static List<QuoteLineItem> getProductsByAltId(String recordId) {
        String Query = 'SELECT Id, QuoteId, Alternate__c, Item_Number__c FROM QuoteLineItem WHERE Alternate__c = :recordId';
        List<QuoteLineItem> quoteLineItems = Database.query(Query);
        return quoteLineItems;    
    }
    
    @AuraEnabled()
    public static string UploadSchedule(String recordId, string fileId, string userId) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.UploadStatus results = service.UploadSignSchedule(fileId, recordId, userId, 'dsj8U73_3nv3Dhba');
        return results.Message;   
    }

    @AuraEnabled()
    public static string DownloadSchedule(String recordId, List<string> alternates) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfString stringArray = new sfdata.ArrayOfString();
        stringArray.string_x = new List<string>();
        stringArray.string_x = alternates;
        sfdata.DownloadStatus results = service.DownloadSignSchedule(recordId, stringArray, 'dsj8U73_3nv3Dhba');
        
        if(results.Status)
        {
            return results.FileData;
        }
        else 
        {
            return results.Message;   
        }        
    }

    @AuraEnabled()
    public static string downloadSignPro(String recordId, List<string> alternates, Boolean includesNotes, string userId) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfString stringArray = new sfdata.ArrayOfString();
        stringArray.string_x = new List<string>();
        stringArray.string_x = alternates;

        decimal[] alternateDecimals = new decimal[alternates.size()];
        integer i = 0;
        
        for (string alt : alternates) {
            alternateDecimals[i++] = Decimal.ValueOf(alt);

        }

        //Check to see if the quantity on the quote line matches the number of sign schedule items
        //Get all the quote line items for the chosen alternates
        List<QuoteLineItem> quoteLines =  [SELECT Alternate_Number__c, SignScheduleId__c, Quantity, Item_Number__c
                                           FROM QuoteLineItem
                                           WHERE QuoteId = :recordId AND Alternate_Number__c IN :alternateDecimals AND SignScheduleId__c != null];
                                         


        //Get all the sign schedule items at once to avoid api limits
        ID[] ssIds = new ID[quoteLines.size()];
        i = 0;
        for (QuoteLineItem qli : quoteLines) {
            ssIds[i++] = qli.SignScheduleId__c;
        }            

        List<Sign_Schedule_Item__c> ssItems =   [SELECT SignScheduleId__c
                                            FROM Sign_Schedule_Item__c
                                            WHERE SignScheduleId__c IN :ssIds];

        //group items by signschedule
        Map<string,List<Sign_Schedule_Item__c>> signScheduleGroups = new Map <string, List <Sign_Schedule_Item__c>>();

        for (Sign_Schedule_Item__c ssi: ssItems) {
            if (signScheduleGroups.ContainsKey(ssi.SignScheduleId__c)) {
                signScheduleGroups.get(ssi.SignScheduleId__c).add(ssi);
            } else {
                List < Sign_Schedule_Item__c > ssiList = new List < Sign_Schedule_Item__c > ();
                ssiList.add(ssi);
                signScheduleGroups.put(ssi.SignScheduleId__c, ssiList);
            }
        }
        
        string response = 'PLEASE NOTE: The configurator quantity and sign schedule quantity do not match.  Please review before sending to customer: ';
        Boolean showResponse = false;
        //Validate lengths
        for (QuoteLineItem qli : quoteLines) {
            
            integer size =  signScheduleGroups.get(qli.SignScheduleId__c).size();
            if(size != qli.quantity)
            {                        
                response += 'Item Number: ' + qli.Item_Number__c + ' Alternate: ' + qli.Alternate_Number__c + ' ';
                showResponse = true;
            }
        }

        sfdata.DownloadStatus results = service.CreateSignPro(recordId, stringArray, includesNotes, userId, 'dsj8U73_3nv3Dhba');

        if(showResponse)
            results.Message += response;

        return results.Message;         
    }    

    @AuraEnabled()
    public static string saveScheduleItems(List<Sign_Schedule_Item__c> SSItems) {
        List<Sign_Schedule_Item__c> itemsToUpdate = new List<Sign_Schedule_Item__c>();
        List<Sign_Schedule_Item__c> itemsToDelete = new List<Sign_Schedule_Item__c>();
        List<Sign_Schedule_Item__c> itemsToCreate = new List<Sign_Schedule_Item__c>();

        for (Sign_Schedule_Item__c ssi : SSItems) {

            string Id = String.valueOf(ssi.Id);
            if((Id.length() == 15 || Id.length() == 18) 
                && ssi.Line20__c != 'delete')            
                itemsToUpdate.add(ssi);            
            else if((Id.length() == 15 || Id.length() == 18) 
                    && ssi.Line20__c == 'delete') 
                itemsToDelete.add(ssi);            
            else
            {                           
                ssi.Id = null;
                itemsToCreate.add(ssi);           
            }
        }

        if(itemsToDelete.size() > 0)
            delete itemsToDelete;        
        if(itemsToUpdate.size() > 0)
            update itemsToUpdate;
        if(itemsToCreate.size() > 0)
            insert itemsToCreate;       

        return 'Success';
    }  

    @AuraEnabled()
    public static string renderSign(string quoteDetailId, string signScheduleItemId, string cache) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;

         sfdata.RenderSignResult result = service.RenderSign(quoteDetailId, signScheduleItemId, 'dsj8U73_3nv3Dhba');

         if(result.Status)
         {
             return result.Data;
         }
         else 
         {
             return result.Message;
         }
    }

    @AuraEnabled(Cacheable = true)
    public static string validateSign(string quoteDetailId, string content) {
         sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
         service.timeout_x = 120000;
         sfdata.ValidateContentWidthResult result = service.ValidateContentWidth(quoteDetailID, content, true, 'dsj8U73_3nv3Dhba');
         return JSON.serialize(result);
    }

    @AuraEnabled()
    public static string createSignSchedules(string quoteId) {

        try {
            
            //First try to tie historically imported signschedules to their new quote
            String Query = 'SELECT Id, Quantity,Item_Number__c, Description,Quote.Copied_From_Quote__c,Quote.Copied_From_Quote__r.MSCRM_ID__c, Quote.MSCRM_ID__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND SignScheduleId__c = null';                 
            List<QuoteLineItem> quoteLineItems = Database.query(Query);       
        
            if(quoteLineItems.size() > 0 &&    (
             (quoteLineItems[0].Quote.MSCRM_ID__c != null 
             && quoteLineItems[0].Quote.MSCRM_ID__c != '') 
            || (quoteLineItems[0].Quote.Copied_From_Quote__c != null && 
                quoteLineItems[0].Quote.Copied_From_Quote__r.MSCRM_ID__c != null &&
                quoteLineItems[0].Quote.Copied_From_Quote__r.MSCRM_ID__c != '' )
                )
                )
            {
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;
                service.FindHistoricalSignSchedule(quoteId, 'dsj8U73_3nv3Dhba');
            }

            //This will find any missing signschedules, and create them with the associated items by quantity.             
            quoteLineItems = Database.query(Query);       
            
                for (QuoteLineItem qli : quoteLineItems) {    
                    Sign_Schedule__c signSchedule = new Sign_Schedule__c();       
                    String ItemNumber =  (String)qli.get('Item_Number__c');
                    String Description = (String) qli.get('Description');
                    Double Quantity = (Double)qli.get('Quantity');

                    signSchedule.Name = ItemNumber + ' - ' + Description;
                    insert signSchedule;

                    List<Sign_Schedule_Item__c> signScheduleItems = new List<Sign_Schedule_Item__c>();
                    for (Integer i = 0; i < Quantity; i++) {
                        Sign_Schedule_Item__c s = new Sign_Schedule_Item__c();
                        s.SignScheduleId__c = signSchedule.Id;
                        s.Index__c = i + 1;
                        signScheduleItems.add(s);
                    }
                    if(signScheduleItems.size() > 0)
                        insert signScheduleItems;

                    qli.SignScheduleId__c = signSchedule.Id;
                    update qli;

                } 
            

            return 'Success!';
        } 
        catch (Exception ex) {
            return ex.getMessage() + ': ' + ex.getStackTraceString();
        }
    }
}