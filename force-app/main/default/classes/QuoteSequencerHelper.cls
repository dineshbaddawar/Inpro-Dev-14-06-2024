public with sharing class QuoteSequencerHelper {
    @AuraEnabled
    public static List<Alternate__c> getAlternates(string recordId){
        List<Alternate__c> alts = [SELECT Id, Sequence_Number__c, Group_Sequence_Number__c, Name__c, Freight_Group_Name__c, Total_List_Price__c, 
                                          Freight_Amount__c, QuoteId__c 
                                   FROM Alternate__c 
                                   WHERE QuoteId__c = :recordId
                                   ORDER BY Sequence_Number__c ASC];
        return alts;
    }

    @AuraEnabled
    public static List<QuoteLineItem> getQuoteProductsByAlternate(string alternateId){
        List<QuoteLineItem> qlis = [SELECT Id, Sequence_Number__c, Item_Number__c, Color__c, Description,
                                           Description_2__c, Note__c, Base_Price__c, Quantity, TotalPrice, Alternate__c
                                    FROM QuoteLineItem
                                    WHERE Alternate__c = :alternateId
                                    ORDER BY Sequence_Number__c ASC];

        return qlis;
    }
    

    @AuraEnabled
    public static void updateAlternates(string quoteId, string altJson){
        List<Alternate__c> alts = (List<Alternate__c>)JSON.deserialize(altJson, List<Alternate__c>.class);
        
        String altIds = '';
        List<Alternate__c> updatedAlts = new List<Alternate__c>();


        for(Alternate__c alt : alts)
        {
            Alternate__c updatedAlt = new Alternate__c();
            updatedAlt.Id = alt.Id;
            updatedAlt.Sequence_Number__c = alt.Sequence_Number__c;
            updatedAlt.Group_Sequence_Number__c = alt.Group_Sequence_Number__c;
            updatedAlts.Add(updatedAlt);
        }

        update updatedAlts;
    }

    @AuraEnabled
    public static void updateQuoteLineItems(string quoteLineItemJson){
        List<QuoteLineItem> qlis = (List<QuoteLineItem>)JSON.deserialize(quoteLineItemJson, List<QuoteLineItem>.class);
        List<QuoteLineItem> qlisToUpdate = new List<QuoteLineItem>();
        for(QuoteLineItem quoteLineItem : qlis)
        {           
            QuoteLineItem newQLI = new QuoteLineItem();            
            newQLI.Sequence_Number__c = quoteLineItem.Sequence_Number__c;
            newQLI.Id = quoteLineItem.Id;
            qlisToUpdate.add(newQLI);            
        }
        update qlisToUpdate;
    }
}