/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      Updates the Number Attending on parent 
LunchAndLearnEvent__c records.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
* 7/7/2020      THG - ATS       Added after insert handler
************************************************************/
public class EventAttendeeTriggerHandler {
    
    private Map<Id, Event_Attendee__c> newMap;
    private Map<Id, Event_Attendee__c> oldMap;
    private List<Event_Attendee__c> trigNew;
    private List<Event_Attendee__c> trigOld;
    
    public EventAttendeeTriggerHandler(
        Map<Id, Event_Attendee__c> triggerOldMap,
        Map<Id, Event_Attendee__c> triggerNewMap,
        List<Event_Attendee__c> triggerOld,
        List<Event_Attendee__c> triggerNew
    ) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
    }
    
    public void afterDelete() {
        updateNumberAttending(trigOld);
    }
    
    public void afterUpdate() {
        updateNumberAttending(trigNew);
    }
    
    public void afterInsert() {
        updateNumberAttending(trigNew);
    }
    
    public void beforeInsert() {
        setBlankStatusToAttended(trigNew);
    }
    
    
    public  void updateNumberAttending(List<Event_Attendee__c> newList){
        set<id> lunchLearnEvent =new set<id>();
        list<LunchAndLearnEvent__c> LunchAndLearnEventList =new list<LunchAndLearnEvent__c>();
        
        for( Event_Attendee__c cmpMem : newList){
            if(cmpMem.LunchAndLearnEvent__c != null){
                lunchLearnEvent.add(cmpMem.LunchAndLearnEvent__c);
            }
        }
        for(LunchAndLearnEvent__c  LandL: [SELECT id, (SELECT LunchAndLearnEvent__c,Status__c FROM Event_Attendees__r) from LunchAndLearnEvent__c where id IN:lunchLearnEvent  ])
        {
            LunchAndLearnEvent__c levent =new LunchAndLearnEvent__c();
            levent.id          =  LandL.id;
            integer attendedNo = 0;
            for(Event_Attendee__c attendee:LandL.Event_Attendees__r){
                if(attendee.Status__c == 'Attended')
                    attendedNo++;
            }
            levent.Number_Registered__c  =   LandL.Event_Attendees__r.size();
            levent.Number_Attending__c = attendedNo;
            LunchAndLearnEventList.add(levent);
        }
        if(LunchAndLearnEventList.size()>0)
            update LunchAndLearnEventList;
    }
    
    public void setBlankStatusToAttended(List<Event_Attendee__c> newList) {
        for (Event_Attendee__c attendee : newList) {
            if (!attendee.isSet('Status__c')) {
                attendee.Status__c = 'Attended';
            }
        }
    }
    
    
}