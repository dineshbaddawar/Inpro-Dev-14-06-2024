public inherited sharing class SignRenderDashboardHelper {
    @AuraEnabled()
    public static string saveToCRM(String jsonSigns){
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.SaveSignsResult results =  service.SaveSigns(jsonSigns, 'dsj8U73_3nv3Dhba');
        if(results.Message == '')
        return 'Success!';
        else
         return results.Message;   
    }

    @AuraEnabled()
    public static List<QuoteLineItem> getQuoteLineItems(List<String> SignScheduleIds){
        
        String Ids = '';
        for (Integer i = 0; i < SignScheduleIds.size(); i++) {
            Ids += '\'' + SignScheduleIds[i] + '\'';            
            if (i != SignScheduleIds.size() - 1) {
                Ids +=  ',';    
            }            
        }

        String Query = 'SELECT SignScheduleId__c, Item_Number__c, Alternate__r.Name__c, Alternate__r.Number__c, Id, Quote.QuoteNumber ' +
                       'FROM QuoteLineItem WHERE SignScheduleId__c IN ('+Ids+')';
        List<QuoteLineItem> quoteLineItems = Database.query(Query);
        return quoteLineItems;    
    }
    
    @AuraEnabled()
    public static List<Sign_Schedule_Item__c> getAllSignScheduleItems(String quoteId){


        String qQuery = 'SELECT SignScheduleId__c ' +
                        'FROM QuoteLineItem WHERE QuoteId = :quoteId';
                        
        List<QuoteLineItem> quoteLineItems = Database.query(qQuery);

        String Ids = '';
        for (Integer i = 0; i < quoteLineItems.size(); i++) {
            Ids += '\'' + quoteLineItems[i].SignScheduleId__c + '\'';            
            if (i != quoteLineItems.size() - 1) {
                Ids +=  ',';    
            }            
        }

        if (Ids == '')
        {
            return new List<Sign_Schedule_Item__c>();
        }
        
        String Query = 'SELECT Text_Too_Tall__c, Text_Too_Wide__c, SavedToCRM__c, Missing_Configuration_Info__c, ' + 
                            'Name, Id, Line1__c, Index__c, Line10__c, Line11__c, Line12__c, Line13__c, ' +
                            'Line14__c, Line15__c, Line16__c, Line17__c, Line18__c, Line19__c, Line2__c, Line20__c, Line3__c, Line4__c, ' +
                            'Line5__c, Line6__c, Line7__c, Line8__c, Line9__c, SignScheduleId__c,Line10Font__c, Line11Font__c, Line12Font__c, ' +
                            'Line13Font__c, Line14Font__c, Line15Font__c, Line16Font__c, Line17Font__c, Line18Font__c, Line19Font__c, Line20Font__c, ' +
                            'Line3Font__c, Line4Font__c, Line5Font__c, Line6Font__c, Line7Font__c, Line8Font__c, Line9Font__c ' + 
                            'FROM Sign_Schedule_Item__c WHERE SignScheduleId__c IN ('+ Ids+')';
        List<Sign_Schedule_Item__c> signScheduleItems = Database.query(Query);
        return signScheduleItems;    
    }

    @AuraEnabled
    public static List<Contact> getContacts(String quoteId){       

        String qQuery = 'SELECT AccountId FROM Quote where id = :quoteId';
        List<Quote> Quotes = Database.query(qQuery);
        string accountId = (String)Quotes[0].get('AccountId');
        String aQuery = 'SELECT FirstName, AccountId, Id, LastName, Name FROM Contact WHERE AccountId = :accountId';
        List<Contact> Contacts = Database.query(aQuery);
        return Contacts;    
    }    

    @AuraEnabled
    public static string emailSign(string quoteId, String userId, String jsonContactList, String jsonAlternateList, String jsonSigns){
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.Result results =  service.EmailSigns(quoteId, userId, jsonContactList, jsonAlternateList, jsonSigns, 'dsj8U73_3nv3Dhba');
        if(results.Message == '')
             return 'Success!';
        else
         return results.Message;  
    }

}