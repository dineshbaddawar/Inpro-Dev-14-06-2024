public without sharing class LandLAddAttendeesBulkController {
    
    @AuraEnabled
    public static EventWrapper getLunchAndLearnEvent(String eventId) {
        LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();
        system.debug('eventId'+eventId);
        if(!String.isBlank(eventId)) {
            evt = [Select Id, Name,Course_Name__r.Name, Start_Formatted__c,Related_To__c,
                   Presenter_User__c,Presenter_User__r.Name,Presenter_User__r.Email,
                   EndDateTime__c,Is_Ongoing__c
                   from LunchAndLearnEvent__c where Id =: eventId];
        }
        system.debug('evt'+evt);
        EventWrapper ew = new EventWrapper();
        ew.PresenterName = evt.Presenter_User__r.Name;
        ew.PresenterEmail = evt.Presenter_User__r.Email;
        ew.Name = evt.Name;
        ew.IsOngoing = evt.Is_Ongoing__c;
        if(evt.Related_To__c != null)
            ew.IsAnotherLocation = false;
        else 
            ew.IsAnotherLocation = true;
        
        String regclosemsg = Label.L_L_Registration_Closed_Message;
        regclosemsg = regclosemsg.replaceAll('###PRESENTEREMAIL###', ew.PresenterEmail);
        regclosemsg = regclosemsg.replaceAll('###PRESENTERNAME###', ew.PresenterName);
        
        ew.RegistrationCompleteMessage = regclosemsg;
        return ew;
    }
    
    @AuraEnabled
    public static List<Standards_Body__c> getStandardBodyList(string eventId) {
        
        LunchAndLearnEvent__c evt = [Select Id, Name,Course_Name__c,Course_Name__r.Name,Start_Formatted__c 
                                     from LunchAndLearnEvent__c where Id =: eventId];
        Course__c courseObj = [SELECT Id, Name,
                               (select Id,Standards_Body__c
                                FROM Standards_Bodies_Covered__r)
                               FROM Course__c where Id=: evt.Course_Name__c];
        Set<Id> stdBodyIdSet = new Set<Id>();
        for(Standards_Bodies_Covered__c sbr:courseObj.Standards_Bodies_Covered__r){
            stdBodyIdSet.add(sbr.Standards_Body__c);
        }
        
        List<Standards_Body__c> standardBodyList =[SELECT Id, Name FROM Standards_Body__c
                                                   where Id in: stdBodyIdSet
                                                   order by Name];
        return standardBodyList;
    }
    
    @AuraEnabled
    public static List<AttendeeWrapper> getAttendees(String eventId) {
        
        LunchAndLearnEvent__c evt = [Select Id, Name,Course_Name__c,Course_Name__r.Name,Start_Formatted__c 
                                     from LunchAndLearnEvent__c where Id =: eventId];
        Course__c courseObj = [SELECT Id, Name,
                               (select Id,Standards_Body__c
                                FROM Standards_Bodies_Covered__r)
                               FROM Course__c where Id=: evt.Course_Name__c];
        Set<Id> stdBodyIdSet = new Set<Id>();
        for(Standards_Bodies_Covered__c sbr:courseObj.Standards_Bodies_Covered__r){
            stdBodyIdSet.add(sbr.Standards_Body__c);
        }
        List<Standards_Body__c> standardBodyList =[SELECT Id, Name FROM Standards_Body__c
                                                   where Id in:stdBodyIdSet
                                                   order by Name];
        
        List<AttendeeWrapper> attendeeList = new List<AttendeeWrapper>();
        
        List<Id> contactIdList = new List<Id>();
        List<Id> LeadIdList = new List<Id>();
        for(Event_Attendee__c attendee : [Select Id,Lead__c,Contact__c from Event_Attendee__c
                                          where LunchAndLearnEvent__c =: eventId]) {
                                              if(attendee.Contact__c != null)
                                                  contactIdList.add(attendee.Contact__c);
                                              else if(attendee.Lead__c != null)
                                                  leadIdList.add(attendee.Lead__c);
                                          }
        
        Map<Id,List<Standards_Bodies_Registered__c>> stdBodyRegMap = new Map<Id,List<Standards_Bodies_Registered__c>>();
        for(Standards_Bodies_Registered__c sbr:[SELECT Id, Name, Registration_Number__c, 
                                                Standards_Body__c, Lead__c, Contact__c,
                                                Standards_Body__r.Id,Standards_Body__r.Name
                                                FROM Standards_Bodies_Registered__c
                                                where 
                                                Standards_Body__r.Id in :stdBodyIdSet
                                                AND
                                                (Contact__c in :contactIdList or Lead__c in :LeadIdList)]){
                                                    if(sbr.Contact__c != null){
                                                        if(stdBodyRegMap.containsKey(sbr.Contact__c)){
                                                            List<Standards_Bodies_Registered__c> existList = stdBodyRegMap.get(sbr.Contact__c);
                                                            existList.add(sbr);
                                                            stdBodyRegMap.put(sbr.Contact__c,existList);
                                                        }
                                                        else{
                                                            List<Standards_Bodies_Registered__c> newList = new List<Standards_Bodies_Registered__c>();
                                                            newList.add(sbr);
                                                            stdBodyRegMap.put(sbr.Contact__c,newList);
                                                        }
                                                    }
                                                    else if(sbr.Lead__c != null){
                                                        if(stdBodyRegMap.containsKey(sbr.Lead__c)){
                                                            List<Standards_Bodies_Registered__c> existList = stdBodyRegMap.get(sbr.Lead__c);
                                                            existList.add(sbr);
                                                            stdBodyRegMap.put(sbr.Lead__c,existList);
                                                        }
                                                        else{
                                                            List<Standards_Bodies_Registered__c> newList = new List<Standards_Bodies_Registered__c>();
                                                            newList.add(sbr);
                                                            stdBodyRegMap.put(sbr.Lead__c,newList);
                                                        }
                                                    }
                                                }
        
        for(Event_Attendee__c attendee : [Select Id,Lead__c,Contact__c,FirstName__c,CompanyOrAccount__c,
                                          LastName__c,Email__c,Email_Opt_In__c,CreatedDate
                                          from Event_Attendee__c
                                          where LunchAndLearnEvent__c =: eventId
                                          order by CreatedDate]) {
                                              AttendeeWrapper aw = new AttendeeWrapper();
                                              aw.AttendeeId =attendee.Id;
                                              aw.FirstName = attendee.FirstName__c;
                                              aw.LastName =attendee.LastName__c;
                                              aw.EmailAddress = attendee.Email__c;
                                              aw.Company = attendee.CompanyOrAccount__c;
                                              aw.EmailOptIn = attendee.Email_Opt_In__c;
                                              aw.EditOrSave = false;
                                              aw.NewRow = false;
                                              
                                              List<StandardBodyWrapper> sbwList = new List<StandardBodyWrapper>();
                                              
                                              for(Standards_Body__c sb:standardBodyList){
                                                  StandardBodyWrapper sbw = new StandardBodyWrapper();
                                                  sbw.FieldLabel = sb.Name;
                                                  sbw.StandardBodyRecordId = sb.Id;
                                                  sbw.RegistrationNumber = '';
                                                  
                                                  if(stdBodyRegMap.containsKey(attendee.Contact__c)){
                                                      for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(attendee.Contact__c)){
                                                          if(sbr.Standards_Body__r.Id == sb.Id){
                                                              sbw.RegistrationNumber = sbr.Registration_Number__c;
                                                              break;
                                                          }
                                                      }
                                                  }
                                                  else if(stdBodyRegMap.containsKey(attendee.Lead__c)){
                                                      for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(attendee.Lead__c)){
                                                          if(sbr.Standards_Body__r.Id == sb.Id){
                                                              sbw.RegistrationNumber = sbr.Registration_Number__c;
                                                              break;
                                                          }
                                                      }
                                                  }
                                                  sbwList.add(sbw);
                                              }
                                              aw.StandardBodies = sbwList;
                                              attendeeList.add(aw);
                                          }
        
        
        return attendeeList;
    }
    
    @AuraEnabled
    public static AttendeeWrapper addRow(String eventId) {
        LunchAndLearnEvent__c evt = [Select Id, Name,Course_Name__c,Course_Name__r.Name,Start_Formatted__c 
                                     from LunchAndLearnEvent__c where Id =: eventId];
        Course__c courseObj = [SELECT Id, Name,
                               (select Id,Standards_Body__c
                                FROM Standards_Bodies_Covered__r)
                               FROM Course__c where Id=: evt.Course_Name__c];
        Set<Id> stdBodyIdSet = new Set<Id>();
        for(Standards_Bodies_Covered__c sbr:courseObj.Standards_Bodies_Covered__r){
            stdBodyIdSet.add(sbr.Standards_Body__c);
        }
        List<Standards_Body__c> standardBodyList =[SELECT Id, Name FROM Standards_Body__c
                                                   where Id in:stdBodyIdSet
                                                   order by Name];
        
        AttendeeWrapper wrapperObj = new AttendeeWrapper();
        
        List<StandardBodyWrapper> sbwList = new List<StandardBodyWrapper>();
        
        for(Standards_Body__c sb:standardBodyList){
            StandardBodyWrapper sbw = new StandardBodyWrapper();
            sbw.FieldLabel = sb.Name;
            sbw.StandardBodyRecordId = sb.Id;
            sbw.RegistrationNumber = '';
            sbwList.add(sbw);
        }
        wrapperObj.StandardBodies = sbwList;
        return wrapperObj;
    }
    
    @AuraEnabled
    public static void deleteAttendee(String attendeeId) {
        Event_Attendee__c evtAttendee = [select Lead__c,Contact__c from Event_Attendee__c
                                         where Id =: attendeeId ];
        delete evtAttendee;
    }
    
    
    @AuraEnabled
    public static void createNewAttendee(AttendeeWrapper attendee,String eventId) {
        system.debug('attendee'+attendee);
        
        LunchAndLearnEvent__c evt  = [Select Id, Name,Course_Name__r.Name,Course_Name__c,
                                      Start_Formatted__c,Related_To__c,Related_To__r.Name,Location__c  
                                      from LunchAndLearnEvent__c where Id =: eventId];
        
        List<Event_Attendee__c> existEventAttendeeList = new List<Event_Attendee__c>();
        
        List<Contact> exstContactList = new List<Contact>();
        List<Lead> exstLeadList = new List<Lead>();
        if(attendee.EmailAddress != null && attendee.EmailAddress != ''){
            exstContactList = [Select Id,Name,Email,
                                             (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                                              from Standards_Bodies_Registered__r)
                                             from Contact where Email = :attendee.EmailAddress];
            exstLeadList = [Select Id,Name,Email,
                                       (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                                        from Standards_Bodies_Registered__r)
                                       from Lead where Email = :attendee.EmailAddress];
            existEventAttendeeList = [SELECT Id, Name, Contact__c, Email__c, Lead__c, 
                                      LunchAndLearnEvent__c
                                      FROM Event_Attendee__c 
                                      where LunchAndLearnEvent__c =: eventId
                                      AND Email__c =: attendee.EmailAddress];
        }
        List<Standards_Bodies_Registered__c> stdRegisteredToInsert = new List<Standards_Bodies_Registered__c>();
        List<Standards_Bodies_Registered__c> stdRegisteredToUpdate = new List<Standards_Bodies_Registered__c>();
        
        if(exstContactList.size() > 0){
            Contact exstContact = exstContactList[0];
            exstContact.FirstName = attendee.FirstName;
            exstContact.LastName = attendee.LastName;
            update exstContact;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                boolean isExist = false;
                for(Standards_Bodies_Registered__c sbr:exstContact.Standards_Bodies_Registered__r){
                    if(sbr.Standards_Body__r.Id == sbw.StandardBodyRecordId && sbw.RegistrationNumber != ''){
                        isExist = true;
                        sbr.Registration_Number__c = sbw.RegistrationNumber;
                        stdRegisteredToUpdate.add(sbr);
                        break;
                    }
                }
                if(!isExist && sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Contact__c =exstContact.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }

            if(existEventAttendeeList.size() > 0){
                Event_Attendee__c existingAttendee= existEventAttendeeList[0];
                existingAttendee.Contact__c = exstContact.Id;
                existingAttendee.Course__c =evt.Course_Name__c;
                existingAttendee.LunchAndLearnEvent__c=eventid;
                existingAttendee.Status__C='Pre-Registered';
                existingAttendee.Created_from_Site__c =true; 
                existingAttendee.Email_Opt_In__c = attendee.EmailOptIn;
                update existingAttendee;
            }
            else{
                Event_Attendee__c newAttendee= new Event_Attendee__c();
                newAttendee.Contact__c = exstContact.Id;
                newAttendee.Course__c =evt.Course_Name__c;
                newAttendee.LunchAndLearnEvent__c=eventid;
                newAttendee.Status__C='Pre-Registered';
                newAttendee.Created_from_Site__c =true; 
                newAttendee.Email_Opt_In__c = attendee.EmailOptIn;
                insert newAttendee;
            }
        }
        
        else if(exstLeadList.size() > 0){
            Lead exstLead = exstLeadList[0];
            exstLead.FirstName = attendee.FirstName;
            exstLead.LastName = attendee.LastName;
            exstLead.Company = attendee.Company;
            update exstLead;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                boolean isExist = false;
                for(Standards_Bodies_Registered__c sbr:exstLead.Standards_Bodies_Registered__r){
                    if(sbr.Standards_Body__r.Id == sbw.StandardBodyRecordId && sbw.RegistrationNumber != ''){
                        isExist = true;
                        sbr.Registration_Number__c = sbw.RegistrationNumber;
                        stdRegisteredToUpdate.add(sbr);
                        break;
                    }
                }
                if(!isExist && sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Lead__c =exstLead.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }
            
            if(existEventAttendeeList.size() > 0){
                Event_Attendee__c existingAttendee= existEventAttendeeList[0];
                existingAttendee.Lead__c = exstLead.Id;
                existingAttendee.Course__c =evt.Course_Name__c;
                existingAttendee.LunchAndLearnEvent__c=eventid;
                existingAttendee.Status__C='Pre-Registered';
                existingAttendee.Created_from_Site__c =true;
                existingAttendee.Email_Opt_In__c = attendee.EmailOptIn;
                update existingAttendee;
            }
            else{
                Event_Attendee__c newAttendee= new Event_Attendee__c();
                newAttendee.Lead__c = exstLead.Id;
                newAttendee.Course__c =evt.Course_Name__c;
                newAttendee.LunchAndLearnEvent__c=eventid;
                newAttendee.Status__C='Pre-Registered';
                newAttendee.Created_from_Site__c =true;
                newAttendee.Email_Opt_In__c = attendee.EmailOptIn;
                insert newAttendee;
            }
        }
        
        else if(evt.Related_To__c != null){
            Contact newContact = new Contact();
            newContact.FirstName = attendee.FirstName;
            newContact.LastName = attendee.LastName;
            newContact.AccountId = evt.Related_To__c;
            newContact.Email = attendee.EmailAddress;
            insert newContact;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                if(sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Contact__c =newContact.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }
            
            Event_Attendee__c newAttendee= new Event_Attendee__c();
            newAttendee.Contact__c = newContact.Id;
            newAttendee.Course__c =evt.Course_Name__c;
            newAttendee.LunchAndLearnEvent__c=eventid;
            newAttendee.Status__C='Pre-Registered';
            newAttendee.Created_from_Site__c =true; 
            newAttendee.Email_Opt_In__c = attendee.EmailOptIn;
            insert newAttendee;
        }
        
        else{
            Lead newLead = new Lead();
            newLead.FirstName = attendee.FirstName;
            newLead.LastName = attendee.LastName;
            newLead.Company = attendee.Company;
            newLead.Email = attendee.EmailAddress;
            insert newLead;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                if(sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Lead__c =newLead.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }
            
            Event_Attendee__c newAttendee= new Event_Attendee__c();
            newAttendee.Lead__c = newLead.Id;
            newAttendee.Course__c =evt.Course_Name__c;
            newAttendee.LunchAndLearnEvent__c=eventid;
            newAttendee.Status__C='Pre-Registered';
            newAttendee.Created_from_Site__c =true; 
            newAttendee.Email_Opt_In__c = attendee.EmailOptIn;
            insert newAttendee;
        }
        
        if(stdRegisteredToInsert.size() > 0)
            insert stdRegisteredToInsert;
        if(stdRegisteredToUpdate.size() > 0)
            update stdRegisteredToUpdate;
    }
    
    
    @AuraEnabled
    public static void editAttendee(AttendeeWrapper attendee) {
        Event_Attendee__c evtAttendee = [select Lead__c,Contact__c,Email_Opt_In__c
                                         from Event_Attendee__c
                                         where Id =: attendee.AttendeeId ];
    
        List<Standards_Bodies_Registered__c> stdRegisteredToInsert = new List<Standards_Bodies_Registered__c>();
        List<Standards_Bodies_Registered__c> stdRegisteredToUpdate = new List<Standards_Bodies_Registered__c>();
        
        if(evtAttendee.Contact__c != null){
            Contact con = [Select Id,Name,Email,
                           (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                            from Standards_Bodies_Registered__r)
                           from Contact where Id=: evtAttendee.Contact__c];
            
            con.FirstName = attendee.FirstName;
            con.LastName = attendee.LastName;
            con.Email = attendee.EmailAddress;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                boolean isExist = false;
                for(Standards_Bodies_Registered__c sbr:con.Standards_Bodies_Registered__r){
                    if(sbr.Standards_Body__r.Id == sbw.StandardBodyRecordId && sbw.RegistrationNumber != ''){
                        isExist = true;
                        sbr.Registration_Number__c = sbw.RegistrationNumber;
                        stdRegisteredToUpdate.add(sbr);
                        break;
                    }
                }
                if(!isExist && sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Contact__c =con.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }
            
            update con;
        }
        else if(evtAttendee.Lead__c != null){
            Lead led = [Select Id,Name,Email,
                        (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                         from Standards_Bodies_Registered__r)
                        from Lead where Id=: evtAttendee.Lead__c];
            led.FirstName = attendee.FirstName;
            led.LastName = attendee.LastName;
            led.Email = attendee.EmailAddress;
            led.Company =attendee.Company;
            
            for(StandardBodyWrapper sbw:attendee.StandardBodies){
                boolean isExist = false;
                for(Standards_Bodies_Registered__c sbr:led.Standards_Bodies_Registered__r){
                    if(sbr.Standards_Body__r.Id == sbw.StandardBodyRecordId && sbw.RegistrationNumber != ''){
                        isExist = true;
                        sbr.Registration_Number__c = sbw.RegistrationNumber;
                        stdRegisteredToUpdate.add(sbr);
                        break;
                    }
                }
                if(!isExist && sbw.RegistrationNumber != ''){
                    Standards_Bodies_Registered__c sbrNew = new Standards_Bodies_Registered__c();
                    sbrNew.Lead__c =led.Id;
                    sbrNew.Registration_Number__c = sbw.RegistrationNumber;
                    sbrNew.Standards_Body__c = sbw.StandardBodyRecordId;
                    stdRegisteredToInsert.add(sbrNew);
                }
            }
            
            update led;
        }
        evtAttendee.Email_Opt_In__c = attendee.EmailOptIn;
        update evtAttendee;
        
        if(stdRegisteredToInsert.size() > 0)
            insert stdRegisteredToInsert;
        if(stdRegisteredToUpdate.size() > 0)
            update stdRegisteredToUpdate;
    }
    
    
    
    public class StandardBodyWrapper{
        @AuraEnabled
        public String FieldLabel {get;set;}
        @AuraEnabled
        public String StandardBodyRecordId {get;set;}
        @AuraEnabled
        public String RegistrationNumber {get;set;}
    }
    
    public class AttendeeWrapper{
        @AuraEnabled
        public String AttendeeId {get;set;}
        @AuraEnabled
        public String FirstName {get;set;}
        @AuraEnabled
        public String LastName {get;set;}
        @AuraEnabled
        public String EmailAddress {get;set;}
        @AuraEnabled
        public String Company {get;set;}
        @AuraEnabled
        public Boolean EmailOptIn {get;set;}
        @AuraEnabled
        public Boolean EditOrSave {get;set;}
        @AuraEnabled
        public Boolean NewRow {get;set;}
        @AuraEnabled
        public List<StandardBodyWrapper> StandardBodies {get;set;}
       
        public AttendeeWrapper() {
            this.AttendeeId ='';
            this.FirstName = '';
            this.LastName ='';
            this.EmailAddress = '';
            this.Company='';
            this.EmailOptIn = false;
            this.EditOrSave = true;
            this.NewRow = true;
        }
    }
    
    public class EventWrapper{
        @AuraEnabled
        public String PresenterName {get;set;}
        @AuraEnabled
        public String PresenterEmail {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Boolean IsAnotherLocation{get;set;}
        @AuraEnabled
        public Boolean IsOngoing {get;set;}
        @AuraEnabled
        public String RegistrationCompleteMessage {get;set;}
    }
    
}