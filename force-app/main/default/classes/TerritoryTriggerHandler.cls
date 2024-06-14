/*************************************************************
* Created by:   The Hunley Group
* Created on:   04/08/2021
* ===========================================================
* Test Class:   BatchTerritoryUpdates_Test
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/08/2021     THG - JAK       Created
*
************************************************************/
public class TerritoryTriggerHandler {

    private Map<Id, Territory__c> newMap;
    private Map<Id, Territory__c> oldMap;
    private List<Territory__c> trigNew;
    private List<Territory__c> trigOld;
    
    
    public TerritoryTriggerHandler( Map<Id, Territory__c> triggerOldMap,
                                    Map<Id, Territory__c> triggerNewMap,
                                    List<Territory__c> triggerOld,
                                    List<Territory__c> triggerNew) {
                                    system.debug('#@# TerritoryTriggerHandler: constructor');
                                    this.oldMap = triggerOldMap;
                                    this.newMap = triggerNewMap;
                                    this.trigOld = triggerOld;
                                    this.trigNew = triggerNew;
                               }

    public void beforeUpdate() {
        system.debug('#@# TerritoryTriggerHandler.beforeUpdate: BEGIN');
        for (Territory__c t : trigNew) {
            Territory__c oldT = oldMap.get(t.Id);
            system.debug('#@# TerritoryTriggerHandler.beforeUpdate: t.Territory_Refresh_Required__c =' + t.Territory_Refresh_Required__c);
            system.debug('#@# TerritoryTriggerHandler.beforeUpdate: oldT.Territory_Refresh_Required__c =' + oldT.Territory_Refresh_Required__c);
            if (
                (t.Ascend_ISR__c != oldT.Ascend_ISR__c) ||
                (t.Clickeze_CCT_ARC_ISR__c != oldT.Clickeze_CCT_ARC_ISR__c) ||
                (t.Clickeze_CCT_FAC_ISR__c != oldT.Clickeze_CCT_FAC_ISR__c) ||
                (t.Clickeze_Dialysis_ISR__c != oldT.Clickeze_Dialysis_ISR__c) ||
                (t.Clickeze_OSR__c != oldT.Clickeze_OSR__c) ||
                (t.Clickeze_WT_ARC_ISR__c != oldT.Clickeze_WT_ARC_ISR__c) ||
                (t.Clickeze_WT_FAC_ISR__c != oldT.Clickeze_WT_FAC_ISR__c) ||
                (t.Collector__c != oldT.Collector__c) ||
                (t.Contracting__c != oldT.Contracting__c) ||
                (t.Endurant_ISR__c != oldT.Endurant_ISR__c) ||
                (t.Healthcare_OSR__c != oldT.Healthcare_OSR__c) ||
                (t.IPC_Dialysis_ISR__c != oldT.IPC_Dialysis_ISR__c) ||
                (t.IPC_Education_ISR__c != oldT.IPC_Education_ISR__c) ||
                (t.IPC_Retail_ISR__c != oldT.IPC_Retail_ISR__c) ||
                (t.IPC_Team_Lead__c != oldT.IPC_Team_Lead__c) ||
                (t.JointMaster_ISR__c != oldT.JointMaster_ISR__c) ||
                (t.JointMaster_OSR__c != oldT.JointMaster_OSR__c) ||
                (t.JointMaster_RSM__c != oldT.JointMaster_RSM__c) ||
                (t.SignScape_ISR__c != oldT.SignScape_ISR__c) || 
                (t.Spaces_OSR__c != oldT.Spaces_OSR__c) ||
                (t.SW_DSSI_Collector__c != oldT.SW_DSSI_Collector__c)
            ) {
                system.debug('#@# TerritoryTriggerHandler.beforeUpdate: marked territory as needing refresh. t.Name = ' + t.Name);
                t.Territory_Refresh_Required__c = true;
            }

        }
        system.debug('#@# TerritoryTriggerHandler.beforeUpdate: END');
    }

}