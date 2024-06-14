public without sharing class LunchAndLearnManageParticipants {
  @AuraEnabled
  public static LunchAndLearnEvent__c getLunchAndLearnEvent(String eventId) {
    LunchAndLearnEvent__c lunchEvent = [
      SELECT
        Id,
        Related_To__c,
        Course_Name__c,
        (
          SELECT
            Id,
            Name,
            CompanyOrAccount__c,
            Contact__c,
            Email__c,
            Email_Opt_In__c,
            FirstName__c,
            LastName__c,
            Lead__c,
            Status__c,
            Follow_up_with_a_Project__c,
            LunchAndLearn_AIA_Number__c,
            GBCI_Number__c,
            IDCEC_Number__c
          FROM Event_Attendees__r
        )
      FROM LunchAndLearnEvent__c
      WHERE Id = :eventId
    ];
    return lunchEvent;
  }

  @AuraEnabled
  public static Event_Attendee__c makeEventAttendee(Map<String, String> input) {
    String eventId = input.get('LunchAndLearnEvent__c');
    String courseId = input.get('Course__c');
    String leadId = input.get('Lead__c');
    String contactId = input.get('Contact__c');

    Event_Attendee__c attendee = new Event_Attendee__c();
    attendee.LunchAndLearnEvent__c = eventId;
    attendee.Course__c = courseId;
    if (String.isNotBlank(leadId)) {
      attendee.Lead__c = leadId;
    } else {
      attendee.Contact__c = contactId;
    }
    attendee.Status__c = 'Attended';  
    insert attendee;

    Event_Attendee__c newAttendee = getSingleAttendee(attendee.Id);
    return newAttendee;
  }

  private static Event_Attendee__c getSingleAttendee(String recId) {
    List<String> attendeeIds = new List<String>{ recId };
    List<Event_Attendee__c> attendees = getEventAttendees(attendeeIds);
    Event_Attendee__c attendee = attendees[0];
    return attendee;
  }

  private static List<Event_Attendee__c> getEventAttendees(List<String> attendeeIds) {
    List<Event_Attendee__c> attendees = [
      SELECT
        Id,
        Name,
        CompanyOrAccount__c,
        Contact__c,
        Email__c,
        Email_Opt_In__c,
        FirstName__c,
        LastName__c,
        Lead__c,
        Status__c,
        Follow_up_with_a_Project__c,
        LunchAndLearn_AIA_Number__c,
        GBCI_Number__c,
        IDCEC_Number__c
      FROM Event_Attendee__c
      WHERE Id IN :attendeeIds
    ];
    return attendees;
  }

  @AuraEnabled
  public static String getOrgURL() {
    String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
    return orgUrl;
  }

  @AuraEnabled
  public static void deleteAttendees(List<String> attendeeIds) {
    Database.delete(attendeeIds);
  }

  @AuraEnabled(cacheable=true)
  public static List<Contact> searchContacts(String queryStr) {
    String formattedQuery = '%' + queryStr + '%';
    List<Contact> contacts = new List<Contact>();
    contacts = [
      SELECT Id, Email, Firstname, LastName, Name, AccountId, Account.Name
      FROM Contact
      WHERE
        Name LIKE :formattedQuery
        OR Email LIKE :formattedQuery 
        LIMIT 5
    ];
    return contacts;
  }

  @AuraEnabled(cacheable=true)
  public static List<Lead> searchLeads(String queryStr) {
    String formattedQuery = '%' + queryStr + '%';
    List<Lead> leads = new List<Lead>();
    leads = [
      SELECT Id, Email, Firstname, LastName, Name, Company
      FROM Lead
      WHERE
        Name LIKE :formattedQuery
        OR Company LIKE :formattedQuery
        OR Email LIKE :formattedQuery 
        LIMIT 5
    ];
    return leads;
  }
}