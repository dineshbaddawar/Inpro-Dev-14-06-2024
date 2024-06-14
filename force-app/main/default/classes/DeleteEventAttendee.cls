/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:   DeleteEventAttendeeTest
* ==========================================================================
* Purpose:      This is the Controller Class for DeleteEventAttendee  
*				vf page which is used for deletion of the Event Attendees.
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/

public class DeleteEventAttendee {
    public List<CampaignMemberWrapper> listMemberWrapper {get; set;} 
    public LunchAndLearnEvent__c LunchAndLearnEventName {get;set;}
    public string lunchlearnname{get;set;}
    
    public DeleteEventAttendee(ApexPages.StandardController controller){
        id LunchAndLearnEvent = apexPages.currentPage().getParameters().get('id');
        listMemberWrapper  =new List<CampaignMemberWrapper>();
        list<Event_Attendee__c> Members =new list<Event_Attendee__c>();
        LunchAndLearnEventName = [SELECT Id, Name FROM LunchAndLearnEvent__c where Id =: LunchAndLearnEvent];
        lunchlearnname = LunchAndLearnEventName.Name ;
        Members = [SELECT Id, Name, FirstName__c, LastName__C, Title__c, Email__c,LunchAndLearn_AIA_Number__c,LunchAndLearnEvent__c FROM Event_Attendee__c where LunchAndLearnEvent__c =: LunchAndLearnEvent ];
        for(Event_Attendee__c cm : Members)
        {
            listMemberWrapper.add(new CampaignMemberWrapper(cm));
        }
    }
    
    public PageReference processSelected() {
        
        List<Event_Attendee__c> CampaignMemTodelete = new List<Event_Attendee__c>();
        for(CampaignMemberWrapper cmw: listMemberWrapper) 
        {
            if(cmw.selected  == true)
            {
                CampaignMemTodelete.add(cmw.CampaignMe);
            }
        }
        if(CampaignMemTodelete.size() > 0 )
        {
            Delete CampaignMemTodelete;
        }
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public class CampaignMemberWrapper
    {
        public Event_Attendee__c CampaignMe {get; set;}
        public Boolean selected {get; set;}
        public CampaignMemberWrapper(Event_Attendee__c Member) 
        {
            CampaignMe = Member;
            selected = false;
        }
    }
    
}