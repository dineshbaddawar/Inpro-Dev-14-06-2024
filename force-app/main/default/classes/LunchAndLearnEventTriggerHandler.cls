/*************************************************************
 * Created by:   The Hunley Group
 * Created on:   4/21/2020
 * ===========================================================
 * Test Class:   LunchAndLearnEventTriggerTest
 * ===========================================================
 * Purpose:      This class acts as the trigger handler for the Lunch & Learn Event object.
 *				It does the following:
 *				1)Create an event record associated with a lunch and learn record
 *				2)Delete the associated event record when a lunch and learn record is deleted.
 *				3)Shorten the attendance URL
 *				4)Update the event record when corresponding lunch and learn record is updated.
 * ===========================================================
 * Change History
 * Date          Author          Purpose
 * ----------    -------------   -----------------------------
 * 4/21/2020     THG - JP        Created
 * 7/17/2020     THG - ATS       Added afterInsert(); formatted
 ************************************************************/
public class LunchAndLearnEventTriggerHandler {
    private Map<Id,LunchAndLearnEvent__c> newMap;
    private Map<Id,LunchAndLearnEvent__c> oldMap;
    private List<LunchAndLearnEvent__c> trigNew;
    private List<LunchAndLearnEvent__c> trigOld;

    public LunchAndLearnEventTriggerHandler(Map<Id,LunchAndLearnEvent__c> triggerOldMap, Map<Id,LunchAndLearnEvent__c> triggerNewMap, List<LunchAndLearnEvent__c> triggerOld, List<LunchAndLearnEvent__c> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
    }

    public void beforeInsert() {
        setPresenterIfBlank(trigNew);
        setCityAndStateFields(trigNew);
    }

    public void beforeUpdate() {
        checkStartAndEndDateTime(trigNew, newMap, oldMap);
    }

    public void beforeDelete() {
        deleteEventRecord(trigOld);
    }

    public void afterInsert() {
        createEventRecord(trigNew);
        shortenAttendanceURL(trigNew);
    }

    public void afterUpdate() {
        updateEventDetails(trigNew, newMap, oldMap);
    }

    public void setPresenterIfBlank(List<LunchAndLearnEvent__c> lunchEvents) {
        for (LunchAndLearnEvent__c event : lunchEvents) {
            if (!event.isSet('Presenter_User__c')) {
                event.Presenter_User__c = event.OwnerId;
            }
        }
    }
    
    public void setCityAndStateFields(List<LunchAndLearnEvent__c> lunchEvents) {
        List<Id> AccountIdsList = new List<Id>();
        for (LunchAndLearnEvent__c event : lunchEvents) {
            if (event.Related_To__c != null) {
                AccountIdsList.add(event.Related_To__c);
            }
        }
        Map<Id,Account> accountMap = New Map <Id,Account>([SELECT Id, BillingCity, BillingState
                                                           FROM Account WHERE Id in :AccountIdsList]);
        for (LunchAndLearnEvent__c event : lunchEvents) {
            if (event.Related_To__c != null) {
                if(accountMap.containsKey(event.Related_To__c)){
                    if(accountMap.get(event.Related_To__c) != null){
                        event.City__c = accountMap.get(event.Related_To__c).BillingCity;
                        event.State__c = accountMap.get(event.Related_To__c).BillingState;
                    }
                }
            }
        }
    }

    public void checkStartAndEndDateTime(List<LunchAndLearnEvent__c> newLandLList, Map<Id,LunchAndLearnEvent__c> newLandLMap, Map<Id,LunchAndLearnEvent__c> oldLandLMap) {
        for (LunchAndLearnEvent__c landlEvent : newLandLList) {
            if (landlEvent.StartDateTime__c > landlEvent.EndDateTime__c)
                landlEvent.addError('Start Date Time cannot be greater than End Date Time');
        }
    }

    public void deleteEventRecord(List<LunchAndLearnEvent__c> newLandLList) {
        set<Id> DelEventIds = new Set<Id>();
        for (LunchAndLearnEvent__c LunchAndLearn : newLandLList) {
            DelEventIds.add(LunchAndLearn.id);
        }
        if (DelEventIds.size() > 0)
            delete [SELECT Id FROM event WHERE Lunch_and_Learn_Event__c IN :DelEventIds];
    }

    public void createEventRecord(List<LunchAndLearnEvent__c> newLandLList) {
        list<event> newEventList = new List<event>();
        for (LunchAndLearnEvent__c LunchAndLearn : newLandLList) {
            event eventobj = new event();
            eventobj.Subject = 'Lunch & Learn at ' + LunchAndLearn.Location1__c;
            eventobj.ActivityDateTime = LunchAndLearn.StartDateTime__c;
            eventobj.StartDateTime = LunchAndLearn.StartDateTime__c;
            eventobj.EndDateTime = LunchAndLearn.EndDateTime__c;
            eventobj.OwnerId = LunchAndLearn.OwnerId;
            eventobj.Lunch_and_Learn_Event__c = LunchAndLearn.Id;
            if (LunchAndLearn.Related_To__c != null) {
                eventobj.WhatId = LunchAndLearn.Related_To__c;
            }
            eventobj.Location = getLLAddress(LunchAndLearn);
            newEventList.add(eventobj);
        }
        insert newEventList;
    }

    public String getLLAddress(LunchAndLearnEvent__c lunchEvent) {
        String address = '';
        String accId = lunchEvent.Related_To__c;
        String loc = lunchEvent.Location__c;
        if (String.isNotBlank(accId)) {
            address = getAccountBillingAddress(accId);
        } else if (String.isNotBlank(loc)) {
            address = loc;
        }
        return address;
    }

    public String getAccountBillingAddress(String accId) {
        Account acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id = :accId];
        
        String statePostalCountry = '';
        String delimiter = ' ';
        statePostalCountry = appendDelimited(statePostalCountry, acc.BillingState, delimiter);
        statePostalCountry = appendDelimited(statePostalCountry, acc.BillingPostalCode, delimiter);
        statePostalCountry = appendDelimited(statePostalCountry, acc.BillingCountry, delimiter);

        String billingAdd = '';
        delimiter = ', ';
        billingAdd = appendDelimited(billingAdd, acc.BillingStreet, delimiter);
        billingAdd = appendDelimited(billingAdd, acc.BillingCity, delimiter);
        billingAdd = appendDelimited(billingAdd, statePostalCountry, delimiter);
        return billingAdd;
    }

    public String appendDelimited(String parent, String child, String delimiter) {
        if (String.isNotBlank(child)) {
            if (String.isNotBlank(parent)) {
                parent += delimiter + child;
            } else {
                parent = child;
            }
        }
        return parent;
    }


    public void shortenAttendanceURL(List<LunchAndLearnEvent__c> newLandLList) {
        for (LunchAndLearnEvent__c e : newLandLList) {
            /*BitlyIntegrationRest.UrlShortenAttendanceLink(e.id);
            BitlyIntegrationRest.UrlShortenAdvanceLink(e.id);*/
            BitlyIntegrationRest.shortenLandLRegistrationLinks(e.id,'Attendance_Link1__c','Attendance_Link__c');
            BitlyIntegrationRest.shortenLandLRegistrationLinks(e.id,'Advance_Registration_Link__c','Advance_Registration_Link_Small__c');
        }
    }

    public void updateEventDetails(List<LunchAndLearnEvent__c> newLandLList, Map<Id,LunchAndLearnEvent__c> newLandLMap, Map<Id,LunchAndLearnEvent__c> oldLandLMap) {
        List<Event> eventWithLunchLearnEvent = new List<Event>();
        List<Id> LunchLearnIds = new List<Id>();
        Map<Id,Event> lunchEventMap = new Map<Id,Event>();
        for (LunchAndLearnEvent__c lunchevent : newLandLList) {
            if (lunchevent.Attendance_Link1__c != null && lunchevent.Attendance_Link1__c != '')
                LunchLearnIds.add(lunchevent.id);
        }
        eventWithLunchLearnEvent = [SELECT Id, Lunch_and_Learn_Event__c, StartDateTime, OwnerId, EndDateTime FROM Event WHERE Lunch_and_Learn_Event__c IN :LunchLearnIds];
        for (Event events : eventWithLunchLearnEvent) {
            lunchEventMap.put(events.Lunch_and_Learn_Event__c, events);
        }
        for (LunchAndLearnEvent__c lunchevent : newLandLList) {
            if (lunchevent.StartDateTime__c != null && (newLandLMap.get(lunchevent.id).StartDateTime__c != oldLandLMap.get(lunchevent.id).StartDateTime__c)) {
                if (lunchEventMap.get(lunchevent.id) != null)
                    lunchEventMap.get(lunchevent.id).StartDateTime = lunchevent.StartDateTime__c;
                system.debug('lunchEventMap.get(lunchevent.id).StartDateTime' + lunchEventMap.get(lunchevent.id).StartDateTime);
            }
            if (lunchevent.EndDateTime__c != null && (newLandLMap.get(lunchevent.id).EndDateTime__c != oldLandLMap.get(lunchevent.id).EndDateTime__c)) {
                if (lunchEventMap.get(lunchevent.id) != null)
                    lunchEventMap.get(lunchevent.id).EndDateTime = lunchevent.EndDateTime__c;
                system.debug('lunchEventMap.get(lunchevent.id).EndDateTime' + lunchEventMap.get(lunchevent.id).EndDateTime);
            }
            if (lunchevent.OwnerId != null && (newLandLMap.get(lunchevent.id).OwnerId != oldLandLMap.get(lunchevent.id).OwnerId)) {
                if (lunchEventMap.get(lunchevent.id) != null)
                    lunchEventMap.get(lunchevent.id).OwnerId = lunchevent.OwnerId;
            }
        }
        if (lunchEventMap.values().size() > 0) {
            update lunchEventMap.values();
        }
    }
}