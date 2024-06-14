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
* 2/24/2022       Inpro - David    Created
*************************************************************/
trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after update, after delete, before insert, before update) {
    
    if(!System.IsBatch())
    {   
        if(trigger.isBefore)
        {
            if (trigger.isInsert && HunleyTriggerUtilities.runOnce('QuoteLineItemTrigger') == true) 
            {
                QuoteLineItemTriggerHandler handler =
                new QuoteLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.beforeInsert();
            }
            else if(trigger.isUpdate && HunleyTriggerUtilities.runOnce('QuoteLineItemTrigger') == true)
            {                
                QuoteLineItemTriggerHandler handler =
                new QuoteLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.beforeUpdate();
            }
        }
        else if(trigger.isAfter) 
        {
            if (trigger.isInsert && HunleyTriggerUtilities.runOnce('QuoteLineItemTrigger') == true) {                          
                QuoteLineItemTriggerHandler handler =
                 new QuoteLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.afterInsert();
            }
            else if (trigger.isUpdate && HunleyTriggerUtilities.runOnce('QuoteLineItemTrigger') == true) {                
                QuoteLineItemTriggerHandler handler = 
                new QuoteLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.afterUpdate();                        
            }
            else if (trigger.isDelete && HunleyTriggerUtilities.runOnce('QuoteLineItemTrigger') == true) {                
                QuoteLineItemTriggerHandler handler = 
                new QuoteLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.afterDelete();                        
            }        
        }     
    }
}