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
trigger LeadTrigger on Lead (after insert,  after update) {
    
    if(!System.IsBatch() && !System.isFuture())
    {
        
    if(trigger.isAfter ) {

        if (trigger.isInsert && HunleyTriggerUtilities.runOnce('LeadTrigger') == true) {           
            LeadTriggerHandler handler = new LeadTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterInsert();
        }
        if (trigger.isUpdate && HunleyTriggerUtilities.runOnce('LeadTrigger') == true) {
            LeadTriggerHandler handler = new LeadTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterUpdate();                        
        }        
    }     
}

}