public with sharing class AlternateRollupHelper {
    public void UpdateAlternateTotals(List<string> quoteIds) {
        try {
            for (string quoteId : quoteIds) {                
            
                Map<ID, Alternate__c> alternateMap = new Map<ID, Alternate__c>();        
                List<QuoteLineItem> quoteLineItems = [SELECT Total_Cost__c, TotalPrice, Total_Weight__c, 
                                                            Total_Base_Price__c, Alternate_Name__c, 
                                                            Alternate_Number__c, Alternate__c, quantity
                                                        FROM QuoteLineItem
                                                        WHERE QuoteId = :quoteId LIMIT 1000];

                for (QuoteLineItem qli : quoteLineItems) {                              
                        if(alternateMap.containsKey(qli.Alternate__c))
                        {
                            Alternate__c alt = alternateMap.get(qli.Alternate__c);
                            alt.Total_Cost__c = alt.Total_Cost__c + qli.Total_Cost__c;
                            alt.Total_List_Price__c = alt.Total_List_Price__c + qli.Total_Base_Price__c;
                            alt.Total_Material__c = alt.Total_Material__c + qli.TotalPrice;
                            alt.Total_Weight__c = alt.Total_Weight__c  + qli.Total_Weight__c;
                        }
                        else 
                        {
                            Alternate__c alt = new Alternate__c();
                            alt.ID = qli.Alternate__c;
                            alt.Total_Cost__c = qli.Total_Cost__c;
                            alt.Total_List_Price__c = qli.Total_Base_Price__c;
                            alt.Total_Material__c = qli.TotalPrice;
                            alt.Total_Weight__c = qli.Total_Weight__c;
                            alternateMap.put(qli.Alternate__c, alt);
                        }
                    }

                    if(alternateMap.size() > 0)
                    {
                        List<Alternate__c> altsToUpdate = new List<Alternate__c>();
                        for(Alternate__c alt : alternateMap.values())    
                        {
                            altsToUpdate.add(alt);
                        }      
                        if(altsToUpdate.size() > 0)
                            update(altsToUpdate);
                    }
                }

            } catch (Exception ex) {                    
                string error = JSON.serialize(ex);
                EmailSendHelper.sendEmail('dsieraski@inprocorp.com', 'mdaniel@inprocorp.com', 'Salesforce - AlternateRollup Error', error);
            }         
            

    }
}