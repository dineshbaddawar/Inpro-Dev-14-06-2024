/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   LunchAndLearnEventTriggerTest
* ===========================================================
* Purpose:      This trigger fires on the LunchAndLearnEvent__c object 
*				before delete,after delete,after update and after insert. 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
* 7/17/2020     THG - ATS       Added beforeInsert()
************************************************************/
trigger LunchAndLearnEventTrigger on LunchAndLearnEvent__c (after insert,after update,before delete,after delete,before update,before insert) {
    if (trigger.isBefore) {
        if (trigger.isDelete) {
            LunchAndLearnEventTriggerHandler handler = new LunchAndLearnEventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeDelete(); 
        }
        if (trigger.isUpdate) {
            LunchAndLearnEventTriggerHandler handler = new LunchAndLearnEventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeUpdate(); 
        }
        if (trigger.isInsert) {
            LunchAndLearnEventTriggerHandler handler = new LunchAndLearnEventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeInsert();
        }
    }
    if (trigger.isAfter && HunleyTriggerUtilities.runOnce('LunchAndLearnEventTrigger') == true) {
        if (trigger.isUpdate) {
            LunchAndLearnEventTriggerHandler handler = new LunchAndLearnEventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterUpdate();
        }
        if (trigger.isInsert) {
            LunchAndLearnEventTriggerHandler handler = new LunchAndLearnEventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterInsert();
        }
    }
}