/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      Fires after delete or insert of Event_Attendee__c records
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
* 7/7/2020      THG - ATS       Added after insert handler
************************************************************/
trigger EventAttendeeTrigger on Event_Attendee__c (after delete, after insert, before insert,after update) {
    
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            EventAttendeeTriggerHandler handler = new EventAttendeeTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeInsert();
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isDelete) {
            EventAttendeeTriggerHandler handler = new EventAttendeeTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterDelete();
        }
        if (trigger.isInsert) {
            EventAttendeeTriggerHandler handler = new EventAttendeeTriggerHandler(null, trigger.newMap, null, trigger.new);
            handler.afterInsert();
        }
        if (trigger.isUpdate) {
            EventAttendeeTriggerHandler handler = new EventAttendeeTriggerHandler(null, trigger.newMap, null, trigger.new);
            handler.afterUpdate();
        }
    }
}