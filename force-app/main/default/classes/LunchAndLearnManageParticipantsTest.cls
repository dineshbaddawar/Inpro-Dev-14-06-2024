@isTest
public with sharing class LunchAndLearnManageParticipantsTest {
  @isTest
  public static void makeDataTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    List<Account> acct = [SELECT Id FROM Account];
    List<Course__c> course = [SELECT Id FROM Course__c];
    List<LunchAndLearnEvent__c> lunchEvent = [SELECT Id FROM LunchAndLearnEvent__c];
    List<Lead> leads = [SELECT Id FROM Lead];
    List<Contact> contacts = [SELECT Id FROM Contact];
    List<Event_Attendee__c> attendees = [SELECT Id FROM Event_Attendee__c];
    System.assertEquals(1, acct.size(), 'wrong number of accounts');
    System.assertEquals(1, course.size(), 'wrong number of courses');
    System.assertEquals(1, lunchEvent.size(), 'wrong number of LL events');
    System.assertEquals(10, leads.size(), 'wrong number of leads');
    System.assertEquals(10, contacts.size(), 'wrong number of contacts');
    System.assertEquals(20, attendees.size(), 'wrong number of attendees');
  }

  @isTest
  public static void getLunchAndLearnEventTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    String eventId = getEventId();
    LunchAndLearnEvent__c testEvent = LunchAndLearnManageParticipants.getLunchAndLearnEvent(
      eventId
    );
    List<Event_Attendee__c> attendees = testEvent.Event_Attendees__r;
    System.assertNotEquals(null, testEvent);
    System.assertEquals(20, attendees.size(), 'wrong number of attendees'); 
  }

  @isTest
  public static void makeEventAttendeeTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
  
    String eventId = getEventId();
    String courseId = getCourseId();
    String leadId = getLeadId();
    String contactId = getContactId();

    List<Event_Attendee__c> attendees = getAttendees();
    System.assertEquals(20, attendees.size(), 'wrong number of attendees');

    Map<String, String> input = new Map<String, String>();
    input.put('LunchAndLearnEvent__c', eventId);
    input.put('Course__c', courseId);
    input.put('Lead__c', leadId);
    LunchAndLearnManageParticipants.makeEventAttendee(input);
    attendees = getAttendees();
    System.assertEquals(21, attendees.size(), 'wrong number of attendees');

    input.put('Lead__c', '');
    input.put('Contact__c', contactId);
    LunchAndLearnManageParticipants.makeEventAttendee(input);
    attendees = getAttendees();
    System.assertEquals(22, attendees.size(), 'wrong number of attendees');
  }

  @isTest
  public static void getOrgURLTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
    String testUrl = LunchAndLearnManageParticipants.getOrgURL();
    System.assertEquals(orgUrl, testUrl, 'urls do not match');
  }

  @isTest
  public static void deleteAttendeesTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    List<Event_Attendee__c> attendees = getAttendees();
    Integer count = attendees.size();
    System.assert(count > 0, 'at least one attendee record should exist');

    Map<String, Event_Attendee__c> attendeeMap = new Map<String, Event_Attendee__c>(attendees);
    Set<String> idSet = attendeeMap.keySet();
    List<String> idList = new List<String>();
    idList.addAll(idSet);
    LunchAndLearnManageParticipants.deleteAttendees(idList);
    attendees = getAttendees();
    count = attendees.size();
    System.assertEquals(0, count, 'no attendee records should exist');
  }

  @isTest
  public static void searchContactsTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    List<Contact> contacts = [SELECT Id FROM Contact];
    Integer count = contacts.size();
    String query = 'test';
    List<Contact> searchedContacts = LunchAndLearnManageParticipants.searchContacts(query);
    Integer searchedSize = searchedContacts.size();
    System.assertEquals(5, searchedSize, 'method returned incorrect number of contacts');
  }

  @isTest
  public static void searchLeadsTest() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    List<Lead> leads = [SELECT Id FROM Lead];
    Integer count = leads.size();
    String query = 'test';
    List<Lead> searchedLeads = LunchAndLearnManageParticipants.searchLeads(query);
    Integer searchedSize = searchedLeads.size();
    System.assertEquals(5, searchedSize, 'method returned incorrect number of leads');
  }

  private static String getEventId() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    LunchAndLearnEvent__c lunchEvent = [SELECT Id FROM LunchAndLearnEvent__c LIMIT 1];
    return lunchEvent.Id;
  }

  private static String getCourseId() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    Course__c course = [SELECT Id FROM Course__c LIMIT 1];
    return course.Id;
  }

  private static String getContactId() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    Contact contact = [SELECT Id FROM Contact LIMIT 1];
    return contact.Id;
  }

  private static String getLeadId() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    Lead lead = [SELECT Id FROM Lead LIMIT 1];
    return lead.Id;
  }

  private static List<Event_Attendee__c> getAttendees() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    List<Event_Attendee__c> attendees = [SELECT Id FROM Event_Attendee__c];
    return attendees;
  }

  @TestSetup
  static void makeData() {
  
    Test.setMock(WebServiceMock.class, new sfdataTest());
    
    Account acct = new Account(Name = 'Test Account');
    insert acct;

    Course__c course = new Course__c(Name = 'Test Course');
    insert course;

    BitlyAccessToken__c Credentials = new BitlyAccessToken__c(Name = 'Credentials');
    insert Credentials;

    LunchAndLearnEvent__c lunchEvent = new LunchAndLearnEvent__c(
      Related_To__c = acct.Id,
      Course_Name__c = course.Id,
      StartDateTime__c = Datetime.now(),
      EndDateTime__c = Datetime.now().addHours(1)
    );
    insert lunchEvent;

    List<Lead> leads = new List<Lead>();
    for (Integer i = 0; i < 10; i++) {
      Lead lead = new Lead(Lastname = 'test', Company = 'test');
      leads.add(lead);
    }
    insert leads;

    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 10; i++) {
      Contact contact = new Contact(Lastname = 'test', AccountId = acct.id);
      contacts.add(contact);
    }
    insert contacts;

    List<Event_Attendee__c> attendees = new List<Event_Attendee__c>();
    for (Contact c : contacts) {
      Event_Attendee__c attendee = new Event_Attendee__c(
        Contact__c = c.Id,
        Course__c = course.Id,
        LunchAndLearnEvent__c = lunchEvent.Id
      );
      attendees.add(attendee);
    }
    for (Lead l : leads) {
      Event_Attendee__c attendee = new Event_Attendee__c(
        Lead__c = l.Id,
        Course__c = course.Id,
        LunchAndLearnEvent__c = lunchEvent.Id
      );
      attendees.add(attendee);
    }
    insert attendees;
  }
}