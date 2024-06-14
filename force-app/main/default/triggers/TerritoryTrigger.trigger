/************************************************************
* Created by:   The Hunley Group
* Created on:   04/08/2021
* ===========================================================
* Test Class:   BatchTerritoryUpdates_Test
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/23/2021     THG - Jason     Created
*************************************************************/
trigger TerritoryTrigger on Territory__c (before update) {
    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            System.debug('#@# TerritoryTrigger: isUpdate');
            TerritoryTriggerHandler handler = new TerritoryTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeUpdate();
        }
    }
}