public with sharing class customRelatedListHelper {
    @AuraEnabled
    public static list<QuoteLineItem> fetchRecords(string recordId) {
        return [SELECT Id, Product__c, Alternate_Name__c, Quantity, TotalPrice, Subtotal, Discount__c, UnitPrice, Item_Number__c,Description, Description_2__c,
                       Color__c, Note__c, Yield__c, Sequence_Number__c
                FROM QuoteLineItem
                WHERE Product2.Name != 'output' and is_Parent__c = true and QuoteId = :recordId ORDER BY  Alternate_Name__c,Sequence_Number__c  ];               
  
    }
}