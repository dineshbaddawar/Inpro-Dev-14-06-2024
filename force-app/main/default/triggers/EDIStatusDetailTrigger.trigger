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
trigger EDIStatusDetailTrigger on EDI_Status_Detail__c (after insert) 
{                
    if(trigger.isAfter) 
    {
        if (trigger.isInsert) 
        {   
             EDIStatusDetailTriggerHandler handler = new EDIStatusDetailTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
             handler.afterInsert();
        }      
    }     
}