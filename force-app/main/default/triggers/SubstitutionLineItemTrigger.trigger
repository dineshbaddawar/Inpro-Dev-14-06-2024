/*************************************************************
* Created by:  The Hunley Group
* Created on:  5/21/2019
* ===========================================================
* Test Class:   SubstitutionLineItemTriggerHandlerTest
* ===========================================================
* Purpose:      This trigger fires on the Substitution_Line_Item__c object Before Insert,Before Update and After update.
*               It uses the SubstitutionLineItemTriggerHandler for processing records.
* ===========================================================
* Change History
* Date          Author        Purpose
* ----------    ------------  -----------------------------
* 5/21/2019    THG - JP      Created
*
************************************************************/
trigger SubstitutionLineItemTrigger on Substitution_Line_Item__c (before update,before insert,after update) {  
    
    Trigger_Switch__mdt trgSwitch = [Select Active__c,sObject_API_Name__c from Trigger_Switch__mdt where sObject_API_Name__c = 'Substitution_Line_Item__c'];
    if(trgSwitch.Active__c == true) {
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                SubstitutionLineItemTriggerHandler handler = new SubstitutionLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.beforeInsert();
            } 
            else if (trigger.isUpdate) {
                SubstitutionLineItemTriggerHandler handler = new SubstitutionLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.beforeUpdate(); 
            }
        }
        if (trigger.isAfter) {
            if (trigger.isUpdate) {
                SubstitutionLineItemTriggerHandler handler = new SubstitutionLineItemTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.afterUpdate(trigger.New,trigger.oldMap);
            }
        }
    }
}