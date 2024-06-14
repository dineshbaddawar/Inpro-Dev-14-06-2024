public with sharing class CalculateAlternateYardageHelper {
    @AuraEnabled()
    public static List<QuoteLineItem> GetQuoteProducts(String recordId){         
        String qQuery = 'SELECT Id, Color__c,  Alternate__r.Name, Item_Number__c,Yards_Per_Line__c, Total_Yards__c '
                     + ' FROM QuoteLineItem WHERE Subtotal > 0 AND QuoteId = :recordId ORDER BY Alternate__r.Name';
        List<QuoteLineItem> quoteLineItems = Database.query(qQuery);
        return quoteLineItems;    
    }
}