public class LandLAdvancedRegistrationController {
    
    @AuraEnabled
    public static LunchAndLearnEvent__c getLunchAndLearnEvent(String eventId) {
        LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();
        system.debug('eventId'+eventId);
        if(!String.isBlank(eventId)) {
            evt = [Select Id, Name,Course_Name__r.Name, Start_Formatted__c from LunchAndLearnEvent__c where Id =: eventId];
        }
        system.debug('evt'+evt);
        return evt;
    }
    
    @AuraEnabled
    public static List<AttendeeWrapper> getAttendees(String eventId) {
        List<AttendeeWrapper> attendeeList = new List<AttendeeWrapper>();
        
        if(!String.isBlank(eventId)) {
            for(Event_Attendee__c attendee : [Select Id, FirstName__c, LastName__c, Email__c,Status__c,Attended__c
                                              from Event_Attendee__c
                                              where LunchAndLearnEvent__c =: eventId]) {
                                                  attendeeList.add(new AttendeeWrapper(attendee));
                                              }
        }
        return attendeeList;
    }
    
    @AuraEnabled
    public static void updateAttendance(String attendeeId,boolean attended) {
        Event_Attendee__c attendee = [Select Id,Attended__c,Status__c
                                      from Event_Attendee__c
                                      where Id =: attendeeId];
        attendee.Attended__c = attended;
        if(attended)
            attendee.Status__c='Attended';
        else
            attendee.Status__c='Pre-Registered';
        update attendee;
    }
    
    public class AttendeeWrapper {
        @AuraEnabled
        public String eventAttendeeId {get;set;}
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String fullName {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public Boolean Attended {get;set;}
        
        public AttendeeWrapper(Event_Attendee__c attendee) {
            this.eventAttendeeId = attendee.Id;
            this.firstName = attendee.FirstName__c;
            this.lastName = attendee.LastName__c;
            this.fullName = this.firstName + ' ' + this.lastName;
            this.email = attendee.Email__c;
            if(attendee.Status__c == 'Attended')
                this.Attended = true;
            else
                this.Attended = false;
        }
    }
    
}