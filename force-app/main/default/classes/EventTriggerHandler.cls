/*************************************************************
* Created by:   The Hunley Group
* Created on:   7/7/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      This class acts as the trigger handler for the Event object. 
*				It does the following:
*				1)Update the lunch and learn event record when 
corresponding event record is updated.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/7/2020     THG - JP        Created
************************************************************/
public class EventTriggerHandler {
    
    private Map<Id, Event> newMap;
    private Map<Id, Event> oldMap;
    private List<Event> trigNew;
    private List<Event> trigOld;
    
    
    public EventTriggerHandler(Map<Id, Event> triggerOldMap,
                               Map<Id, Event> triggerNewMap,
                               List<Event> triggerOld,
                               List<Event> triggerNew) {
                                   this.oldMap = triggerOldMap;
                                   this.newMap = triggerNewMap;
                                   this.trigOld = triggerOld;
                                   this.trigNew = triggerNew;
                               }
    
    public void afterUpdate() {
        updateLunchandLearnEventDetails(trigNew,newMap,oldMap);
    }
    
    public  void updateLunchandLearnEventDetails(List<Event> newEventList,Map<Id,Event> newEventMap,Map<Id,Event> oldEventMap){
        List<Id> lunchandlearnIds=new List<Id>();
        for(Event evt:newEventList){
            if(evt.Lunch_and_Learn_Event__c !=null)
                lunchandlearnIds.add(evt.Lunch_and_Learn_Event__c);
        }
        system.debug('lunchandlearnIds'+lunchandlearnIds);
        Map<Id,LunchAndLearnEvent__c> landlMap= new Map<Id,LunchAndLearnEvent__c>();
        for(LunchAndLearnEvent__c landl: [select Id,StartDateTime__c,EndDateTime__c 
                                          from LunchAndLearnEvent__c where Id in:lunchandlearnIds]){
                                              landlMap.put(landl.Id, landl);  
                                          }
        system.debug('landlMap'+landlMap);
        for(Event evt:newEventList){
            if(evt.StartDateTime != oldEventMap.get(evt.Id).StartDateTime){
                system.debug('evt.Lunch_and_Learn_Event__c'+evt.Lunch_and_Learn_Event__c);
                if(landlMap.get(evt.Lunch_and_Learn_Event__c) != null)
                    landlMap.get(evt.Lunch_and_Learn_Event__c).StartDateTime__c = evt.StartDateTime;
            }
            if(evt.EndDateTime != oldEventMap.get(evt.Id).EndDateTime){
                if(landlMap.get(evt.Lunch_and_Learn_Event__c) != null)
                    landlMap.get(evt.Lunch_and_Learn_Event__c).EndDateTime__c = evt.EndDateTime;
            }
        }
        
        update landlMap.values();
    }
}