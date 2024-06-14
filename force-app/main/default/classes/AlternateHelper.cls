public with sharing class AlternateHelper {

    @AuraEnabled
    public static List<Alternate__c> getAlternates(string quoteId)
    {
        //Ensure calculated fields are up to date
        return getUpdatedAlternates(quoteId);
    }

    private static List<Alternate__c> getUpdatedAlternates(string quoteId)
    {
        List<Alternate__c> alts = 
            [SELECT Id, Number__c, Name__c, Name, CM__c, Yield__c,
                Total_Material__c, Total_List_Price__c,
                Freight_Amount__c, Total_Tax__c, Total_Cost__c,
                Total_incl_Freight_Tax__c, QuoteId__c, Total_Weight__c, Group_Name__c, Group_Sequence_Number__c,
                Sequence_Number__c, Show_Unit_Pricing__c, Freight_Group_Name__c,Total_incl_Freight_No_Tax__c
            FROM Alternate__c
            WHERE QuoteId__c = :quoteId];

        Map<ID, Alternate__c> alternateMap = new Map<ID, Alternate__c>();        
        Map<ID, Alternate__c> existingAlternateMap = new Map<ID, Alternate__c>();
        for(Alternate__c alt : alts)
        {
            existingAlternateMap.put(alt.Id, alt);
        }

        List<QuoteLineItem> quoteLineItems = [SELECT Total_Cost__c, TotalPrice, Total_Weight__c, 
                                                    Total_Base_Price__c, Alternate_Name__c, 
                                                    Alternate_Number__c, Alternate__c, quantity
                                                FROM QuoteLineItem
                                                WHERE QuoteId = :quoteId AND Is_Parent__c = true LIMIT 1000 FOR UPDATE];

        for (QuoteLineItem qli : quoteLineItems)
        {                              
            if(alternateMap.containsKey(qli.Alternate__c))
            {
                Alternate__c alt = alternateMap.get(qli.Alternate__c);
                alt.Total_Cost__c += qli.Total_Cost__c;
                alt.Total_List_Price__c += qli.Total_Base_Price__c;
                alt.Total_Material__c += qli.TotalPrice;
                alt.Total_Weight__c += qli.Total_Weight__c;
                alternateMap.remove(alt.Id);
                alternateMap.put(alt.Id, alt);
            }
            else 
            {
                Alternate__c alt = new Alternate__c();
                alt.Id = qli.Alternate__c;
                
                alt.Total_Cost__c = qli.Total_Cost__c;
                alt.Total_List_Price__c = qli.Total_Base_Price__c;
                alt.Total_Material__c = qli.TotalPrice;
                alt.Total_Weight__c = qli.Total_Weight__c;

                alternateMap.put(alt.Id, alt);
            }
        }

        Decimal quoteTotalCost = 0;
        Decimal quoteTotalMaterial = 0;
        if(alternateMap.size() > 0)
        {           
            List<Alternate__c> altsToUpdate = new List<Alternate__c>();
            for(Alternate__c alt : alternateMap.values())    
            {
                //Only update alternate if totals changed
                Alternate__c existingAlt = existingAlternateMap.get(alt.Id);
                if (existingAlt.Total_Cost__c != alt.Total_Cost__c ||
                    existingAlt.Total_List_Price__c != alt.Total_List_Price__c ||
                    existingAlt.Total_Material__c != alt.Total_Material__c ||
                    existingAlt.Total_Weight__c != alt.Total_Weight__c)
                {
                    altsToUpdate.add(alt);
                }
                if(alt.Total_Cost__c != null)
                    quoteTotalCost += alt.Total_Cost__c;
                if(alt.Total_Material__c != null)
                    quoteTotalMaterial += alt.Total_Material__c;
            }      
            if(altsToUpdate.size() > 0)
                update(altsToUpdate);
        }
        Quote quoteToUpdate = new Quote();
        quoteToUpdate.Id = quoteId;
        quoteToUpdate.Alternate_Total_Cost__c = quoteTotalCost;
        quoteToUpdate.Alternate_Total_Material__c = quoteTotalMaterial;
        update quoteToUpdate;

        List<Alternate__c> finalAlts = new List<Alternate__c>();
        for(Alternate__c alt : existingAlternateMap.values())
        {
            finalAlts.add(alt);
        }
        return finalAlts;
    }
}