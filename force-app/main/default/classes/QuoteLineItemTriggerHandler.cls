/************************************************************
* Created by:   Inpro
* Created on:   2/24/2022
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 2/25/2022       Inpro - David    Created
*************************************************************/
public with sharing class QuoteLineItemTriggerHandler {
    private Map<Id, QuoteLineItem> newMap;
    private Map<Id, QuoteLineItem> oldMap;
    private List<QuoteLineItem> trigNew;
    private List<QuoteLineItem> trigOld;
    private Boolean isDelete;

    // Constructor used for Before/After Update handler
    public QuoteLineItemTriggerHandler(Map<Id, QuoteLineItem> triggerOldMap,  Map<Id, QuoteLineItem> triggerNewMap, List<QuoteLineItem> triggerOld, List<QuoteLineItem> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
        setupData();
    }

    //Private void method that will stage local variables and related data for use within the rest of the handler
    private void setupData() {
    }

    public void beforeInsert() {     
        handleBefore();
    }

    public void beforeDelete() {
    }

    //Public void method called After Delete from the QuoteLineItem Trigger
    public void afterDelete() {   
        handleAlternateDeletes();     
    }


    //Public void method called After Insert from the QuoteLineItem Trigger
    public void afterInsert() {   
        doAlternateCreation();     
    }

    //Public void method called Before Update from the QuoteLineItem Trigger
    public void beforeUpdate() {  
        handleBefore();    
    }

    //Public void method called After Update from the QuoteLineItem Trigger
    public void afterUpdate() {  
        handleAlternateUpdates();      
    }
  
    private void doAlternateCreation() {     
        
        Set<String> AltNames = new Set<String>();
        Set<Integer> AltNumbers = new Set<Integer>();
        List<Alternate__c> aList;
        Boolean useAltName = false;              
        for(QuoteLineItem qli : this.trigNew)
        {       
            if(!AltNames.contains(qli.Alternate_Name__c))
                AltNames.add(qli.Alternate_Name__c);
            if(!AltNumbers.contains(Integer.valueOf(qli.LineNumber__c)))
                AltNumbers.add(Integer.valueOf(qli.LineNumber__c));
        }

        if(this.trigNew[0].SeriesID__c != null && this.trigNew[0].SeriesID__c != '')
        {
             aList = [select Id, Total_Weight__c,Number__c, Name__c from Alternate__c 
                      where QuoteId__c =:this.trigNew[0].QuoteId and Name__c in :AltNames];
                useAltName = true;                
        }
        else
        {
             aList = [select Id, Total_Weight__c, Number__c,Name__c from Alternate__c 
                      where QuoteId__c =:this.trigNew[0].QuoteId and Number__c in :AltNumbers];
        }        

        Map<String,Alternate__c> altNameMap = new Map<String,Alternate__c>();
        Map<Integer,Alternate__c> altNumberMap = new Map<Integer,Alternate__c>();

        for (Alternate__c alt : aList) {
            altNameMap.put(alt.Name__c, alt);
            altNumberMap.put(Integer.valueOf(alt.Number__c), alt);         
        }        

        List<Alternate__c> altsToCreate = new List<Alternate__c>();
        List<QuoteLineItem> lineItemsToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> lineItemsMissingAltId = new List<QuoteLineItem>();
        
        for(QuoteLineItem qli : this.trigNew)
        {               
            Alternate__c alt;
            if (useAltName) 
            {
                if(altNameMap.containsKey(qli.Alternate_Name__c))
                {
                    alt = altNameMap.get(qli.Alternate_Name__c);

                    if(alt.Id != null)
                    {
                        QuoteLineItem li = new QuoteLineItem();
                        li.id = qli.id;
                        li.Alternate_Number__c  = Integer.valueOf(qli.LineNumber__c); 
                        li.Alternate__c = alt.Id;
                        lineItemsToUpdate.add(li);
                    }
                    else {
                        lineItemsMissingAltId.add(qli);
                    }
                }
                else {    
                    alt =  new Alternate__c(Name__c = qli.Alternate_Name__c, 
                                            Number__c = Integer.valueOf(qli.LineNumber__c), 
                                            QuoteId__c = qli.QuoteId,
                                            Sequence_Number__c = qli.Sequence_Number__c);                    
                        
                     altNameMap.put(qli.Alternate_Name__c, alt);
                     lineItemsMissingAltId.add(qli);
                     altsToCreate.add(alt);                               
                }
            }
            else
            {                
                if(altNumberMap.containsKey(Integer.valueOf(qli.LineNumber__c)))
                {
                    alt = altNumberMap.get(Integer.valueOf(qli.LineNumber__c));

                    if(alt.Id != null)
                    {                      
                        QuoteLineItem li = new QuoteLineItem();
                        li.Alternate__c = alt.Id;
                        li.Alternate_Number__c  = Integer.valueOf(qli.LineNumber__c); 
                        li.Id = qli.Id;
                        lineItemsToUpdate.add(li);
                    }
                    else {
                        lineItemsMissingAltId.add(qli);
                    }
                }
                else {
                    alt =  new Alternate__c(Name__c = qli.Alternate_Name__c, 
                                            Number__c = Integer.valueOf(qli.LineNumber__c), 
                                            QuoteId__c = qli.QuoteId,
                                            Sequence_Number__c = qli.Sequence_Number__c);                    
                        
                     altNumberMap.put(Integer.valueOf(qli.LineNumber__c), alt);
                     lineItemsMissingAltId.add(qli);
                     altsToCreate.add(alt);                               
                }
            }
        }                
           if(altsToCreate.size() > 0)
           {
                insert altsToCreate;

                for (Alternate__c alt : altsToCreate) {
                    for (QuoteLineItem qli : lineItemsMissingAltId) {
                        if(useAltName)
                        {
                            if (alt.Name__c == qli.Alternate_Name__c) {
                                QuoteLineItem li = new QuoteLineItem();
                                li.Alternate__c = alt.Id;
                                li.Id = qli.Id;
                                li.Alternate_Number__c = Integer.valueOf(qli.LineNumber__c); 
                                lineItemsToUpdate.add(li);
                            }
                        }
                        else 
                        {
                            if (Integer.valueOf(alt.Number__c) == Integer.valueOf(qli.LineNumber__c)) {
                                QuoteLineItem li = new QuoteLineItem();
                                li.Alternate__c = alt.Id;
                                li.Id = qli.Id;
                                li.Alternate_Number__c = Integer.valueOf(qli.LineNumber__c); 
                                lineItemsToUpdate.add(li);
                            }
                        }
                    }
                }
            }            
            
            update lineItemsToUpdate;                    
    }

    private void handleAlternateUpdates()
    {   
        List<Alternate__c> altsToUpdate = new List<Alternate__c>();
        List<Alternate__c> altsToCreate = new List<Alternate__c>();
        List<QuoteLineItem> lineItemsToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> lineItemsMissingAltId = new List<QuoteLineItem>();
        Map<string,Alternate__c> alternateGroups = new Map <string,Alternate__c>();                       
        Map<String,Alternate__c> altNameMap = new Map<String,Alternate__c>();
        List<Alternate__c> aList;
        Set<String> AltNames = new Set<String>();
        Boolean useAltName = false;               
        if(this.trigNew[0].SeriesID__c != null && this.trigNew[0].SeriesID__c != '')
        {
            for(QuoteLineItem qli : this.trigNew)
            {       
                if(!AltNames.contains(qli.Alternate_Name__c))
                    AltNames.add(qli.Alternate_Name__c);            
            }

             aList = [select Id, Total_Weight__c,Number__c, Name__c from Alternate__c 
                      where QuoteId__c =:this.trigNew[0].QuoteId and Name__c in :AltNames];
             useAltName = true;

             for (Alternate__c alt : aList) {
                altNameMap.put(alt.Name__c, alt);            
            }
        }

        for(QuoteLineItem qli :this.trigNew)
        {   
            QuoteLineItem oldQuoteLine = this.oldMap.get(qli.Id);
            if(useAltName)
            {                
                if(qli.Alternate_Name__c != oldQuoteLine.Alternate_Name__c)                
                {
                    if(altNameMap.containsKey(qli.Alternate_Name__c))
                    {
                       Alternate__c alt = altNameMap.get(qli.Alternate_Name__c);                                   
                        if(alt.Id != null)
                        {
                            QuoteLineItem li = new QuotelineItem();
                            li.Alternate__c = alt.Id;  
                            li.Id = qli.Id;        
                            li.Alternate_Number__c = qli.LineNumber__c;                     
                            lineItemsToUpdate.add(li);
                        }
                        else {
                            lineItemsMissingAltId.add(qli);
                        }
                     }   
                     else
                     {                                              
                            // create the Alternate if it doesn't exist      
                            Alternate__c a = new Alternate__c(Name__c = qli.Alternate_Name__c, 
                                                            Number__c = qli.LineNumber__c, 
                                                            QuoteId__c = qli.QuoteId,
                                                            Sequence_Number__c = qli.Sequence_Number__c);                    
                            altsToCreate.add(a);
                            altNameMap.put(qli.Alternate_Name__c,a);
                            lineItemsMissingAltId.add(qli);
                     }   
                }
             }
             else if(qli.Alternate_Name__c != oldQuoteLine.Alternate_Name__c)                
             {   
                if (!alternateGroups.ContainsKey(qli.Alternate__c)) {
                    
                    Alternate__c alt = new ALternate__c();
                    alt.Id = qli.Alternate__c;
                    alt.Name__c = qli.Alternate_Name__c;
                    alternateGroups.put(qli.Alternate__c, alt);
                    altsToUpdate.add(alt);   
                }                    
             }          
        }        

        if(altsToUpdate.size() > 0)
        {
            update altsToUpdate;            
        }

        if(altsToCreate.size() > 0)
        {
            insert altsToCreate;

            for (Alternate__c alt : altsToCreate) {
                for (QuoteLineItem qli : lineItemsMissingAltId) {
                    if(useAltName)
                    {
                        if (alt.Name__c == qli.Alternate_Name__c) {
                            QuoteLineItem li = new QuoteLineItem();
                            li.Id = qli.Id;
                            li.Alternate__c = alt.Id;        
                            li.Alternate_Number__c = Integer.valueOf(qli.LineNumber__c);                         
                            lineItemsToUpdate.add(li);
                        }
                    }                        
                }
            }
        }

        if(lineItemsToUpdate.size() > 0)
        {            
            update lineItemsToUpdate;     
        }

        handleAlternateDeletes();
    }

    private void handleAlternateDeletes()
    {
        if(this.trigOld.size() > 0 && this.trigOld[0] != null)        
        {            
            string quoteId = this.trigOld[0].QuoteId;
            if(quoteId != null && quoteId != '')
            {
                List<alternate__c> altsToDelete = [select Id
                        from alternate__c
                        where Id not in 
                            (select alternate__c from quotelineItem where quoteid = :quoteId) 
                        and quoteId__c = :quoteId];
                        if(altsToDelete != null && altsToDelete.size() > 0)
                        {
                            delete altsToDelete;
                        }
            }
        }
    }

    private void handleBefore()
    {
        for (QuoteLineItem qli : this.trigNew) 
        {
            if(String.isNotEmpty(qli.ParentID__c) && qli.Item_Number__c != qli.ParentID__c)            
                qli.Is_Parent__c = false;            
            else 
                qli.Is_Parent__c = true;

            

            if(qli.Yield__c != 100 && qli.Discount__c == 0 &&
               qli.Base_Price__c != null && qli.Base_Price__c != 0)
            {
                decimal x = 100 - ((qli.Price_Per_Unit__c / qli.Base_Price__c ) * 100);
                qli.Discount__c = x.setScale(0);
                qli.Discount_Type__c = 'Percent';                     
            }
        }
        HunleyTriggerUtilities.resetRun('QuoteLineItemTrigger');
    }
  
}