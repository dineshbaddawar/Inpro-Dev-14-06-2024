public without sharing class LandLRegistrationPageController {
    
    @AuraEnabled
    public static EventWrapper getLunchAndLearnEvent(String eventId) {
        EventWrapper ew = new EventWrapper();
        LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();
        system.debug('eventId'+eventId);
        if(!String.isBlank(eventId)) {
            evt = [Select Id, Name,Course_Name__r.Name, Start_Formatted__c,
                   Presenter_User__c,Presenter_User__r.Name,Presenter_User__r.Email,
                   EndDateTime__c,Is_Ongoing__c,Course_Name__r.Id,StartDateTime__c,
                   Related_To__c,Related_To__r.Name,Location__c
                   from LunchAndLearnEvent__c where Id =: eventId];
            
            Course__c courseObj = [SELECT Id, Name,Provider_Name__c,Provider_Logo_URL__c,
                                   (SELECT Id, Name, Course__c, Provider_ID_for_this_Course__c,
                                    Standards_Body__r.Name,Course_Id__c,Standards_Body__r.Logo_URL__c
                                    FROM Standards_Bodies_Covered__r)
                                   FROM Course__c where Id=:evt.Course_Name__r.Id];
            system.debug('courseObj'+courseObj);
            String provNumber='';
            String courseId='';
            List<String> logoUrls = new List<String>();
            for(Standards_Bodies_Covered__c sbc:courseObj.Standards_Bodies_Covered__r){
                courseId = courseId + sbc.Standards_Body__r.Name + ' - ' +sbc.Course_Id__c + ', ';
                provNumber = provNumber + sbc.Standards_Body__r.Name + ' - ' +sbc.Provider_ID_for_this_Course__c + ', ';
                logoUrls.add(sbc.Standards_Body__r.Logo_URL__c);
            }
            provNumber = provNumber.removeEnd(', ');
            courseId = courseId.removeEnd(', ');
            
            ew.PresenterName = evt.Presenter_User__r.Name;
            ew.PresenterEmail = evt.Presenter_User__r.Email;
            ew.Provider = courseObj.Provider_Name__c;
            ew.IsOngoing = evt.Is_Ongoing__c;
            ew.ProviderNumber = provNumber;
            ew.CourseName = courseObj.Name;
            ew.CourseId = courseId;
            ew.ProviderLogoUrls = logoUrls;
            ew.EventDate = evt.StartDateTime__c.month()+'/'+evt.StartDateTime__c.day()+'/'+evt.StartDateTime__c.year();
            ew.CompanyLogo=courseObj.Provider_Logo_URL__c;
            system.debug('ew.CompanyLogo'+ew.CompanyLogo);
            if(evt.Related_To__c != null)
                ew.IsAnotherLocation = false;
            else 
                ew.IsAnotherLocation = true;
            
            String regclosemsg = Label.L_L_Registration_Closed_Message;
            regclosemsg = regclosemsg.replaceAll('###PRESENTEREMAIL###', ew.PresenterEmail);
            regclosemsg = regclosemsg.replaceAll('###PRESENTERNAME###', ew.PresenterName);
            
            ew.RegistrationOverMessage = regclosemsg;
        }
        
        return ew;
        
    }
    
    
    @AuraEnabled
    public static List<StandardBodyWrapper> getStandardBodyWrapper(String eventId) {
        
        List<StandardBodyWrapper> wrapperList = new List<StandardBodyWrapper>();
        LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();
        system.debug('eventId'+eventId);
        if(!String.isBlank(eventId)) {
            evt = [Select Id, Name,Course_Name__r.Name, Start_Formatted__c,
                   Presenter_User__c,Presenter_User__r.Name,Presenter_User__r.Email,
                   EndDateTime__c,Is_Ongoing__c,Course_Name__r.Id,StartDateTime__c
                   from LunchAndLearnEvent__c where Id =: eventId];
            
            Course__c courseObj = [SELECT Id, Name,
                                   (SELECT Id, Name, Course__c, Provider_ID_for_this_Course__c,
                                    Standards_Body__r.Name
                                    FROM Standards_Bodies_Covered__r)
                                   FROM Course__c where Id=:evt.Course_Name__r.Id];
            
            for(Standards_Bodies_Covered__c sbc:courseObj.Standards_Bodies_Covered__r){
                StandardBodyWrapper sb = new StandardBodyWrapper();
                sb.FieldLabel = sbc.Standards_Body__r.Name + ' Membership Number';
                sb.StandardBodyRecordId = sbc.Standards_Body__r.Id;
                sb.RegistrationNumber = '';
                wrapperList.add(sb);
            }
        }
        
        return wrapperList;        
    }
    
    
    @AuraEnabled
    public static void createNewAttendee(String eventId,String FName,String LName,String Company,String EmailAddress,Boolean ProjectFollowUp,Boolean OptIn,List<StandardBodyWrapper> SBwrapperList) {
        
        LunchAndLearnEvent__c evt  = [Select Id, Name,Course_Name__r.Name,Course_Name__c,
                                      Start_Formatted__c,Related_To__c,Related_To__r.Name,Location__c 
                                      from LunchAndLearnEvent__c where Id =: eventId];
        system.debug('EmailAddress'+EmailAddress);
        
        List<Event_Attendee__c> existEventAttendeeList = new List<Event_Attendee__c>();
        
        List<Contact> exstContactList = new List<Contact>();
        List<Lead> exstLeadList = new List<Lead>();
        if(EmailAddress != null && EmailAddress != ''){
            exstContactList = [Select Id,Name,Email,
                               (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                                from Standards_Bodies_Registered__r)
                               from Contact where Email = :EmailAddress];
            exstLeadList = [Select Id,Name,Email,
                            (Select Registration_Number__c,Standards_Body__c,Standards_Body__r.Id
                             from Standards_Bodies_Registered__r)
                            from Lead where Email = :EmailAddress];
            existEventAttendeeList = [SELECT Id, Name, Contact__c, Email__c, Lead__c, 
                                      LunchAndLearnEvent__c
                                      FROM Event_Attendee__c 
                                      where LunchAndLearnEvent__c =: eventId
                                      AND Email__c =: EmailAddress];
        }
        
        List<Standards_Bodies_Registered__c> stdRegisteredToInsert = new List<Standards_Bodies_Registered__c>();
        List<Standards_Bodies_Registered__c> stdRegisteredToUpdate = new List<Standards_Bodies_Registered__c>();
        
        if(exstContactList.size() > 0){
            Contact exstContact = exstContactList[0];
            exstContact.FirstName = FName;
            exstContact.LastName = LName;
            update exstContact;
            
            for(StandardBodyWrapper sbw:SBwrapperList){
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
                existingAttendee.LunchAndLearnEvent__c=eventId;
                existingAttendee.Status__c='Attended';
                existingAttendee.Created_from_Site__c =true; 
                existingAttendee.Email_Opt_In__c = OptIn;
                existingAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
                update existingAttendee;
            }
            else{
                Event_Attendee__c newAttendee= new Event_Attendee__c();
                newAttendee.Contact__c = exstContact.Id;
                newAttendee.Course__c =evt.Course_Name__c;
                newAttendee.LunchAndLearnEvent__c=eventId;
                newAttendee.Status__c='Attended';
                newAttendee.Created_from_Site__c =true; 
                newAttendee.Email_Opt_In__c = OptIn;
                newAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
                insert newAttendee;                
            }
        }
        
        else if(exstLeadList.size() > 0){
            Lead exstLead = exstLeadList[0];
            exstLead.FirstName = FName;
            exstLead.LastName =LName;
            exstLead.Email = EmailAddress;
            update exstLead;
            
            for(StandardBodyWrapper sbw:SBwrapperList){
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
                existingAttendee.Status__C='Attended';
                existingAttendee.Created_from_Site__c =true;
                existingAttendee.Email_Opt_In__c = OptIn;
                existingAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
                update existingAttendee;
            }
            else{
                Event_Attendee__c newAttendee= new Event_Attendee__c();
                newAttendee.Lead__c = exstLead.Id;
                newAttendee.Course__c =evt.Course_Name__c;
                newAttendee.LunchAndLearnEvent__c=eventid;
                newAttendee.Status__C='Attended';
                newAttendee.Created_from_Site__c =true;
                newAttendee.Email_Opt_In__c = OptIn;
                newAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
                insert newAttendee; 
            }
            
        }
        
        else if(evt.Related_To__c != null){
            Contact newContact = new Contact();
            newContact.FirstName = FName;
            newContact.LastName = LName;
            newContact.AccountId = evt.Related_To__c;
            newContact.Email = EmailAddress;
            insert newContact;
            
            for(StandardBodyWrapper sbw:SBwrapperList){
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
            newAttendee.Status__C='Attended';
            newAttendee.Created_from_Site__c =true; 
            newAttendee.Email_Opt_In__c = OptIn;
            newAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
            insert newAttendee;
        }
        
        else{
            Lead newLead = new Lead();
            newLead.FirstName = FName;
            newLead.LastName = LName;
            newLead.Company = Company;
            newLead.Email = EmailAddress;
            insert newLead;
            
            for(StandardBodyWrapper sbw:SBwrapperList){
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
            newAttendee.Status__C='Attended';
            newAttendee.Created_from_Site__c =true; 
            newAttendee.Email_Opt_In__c = OptIn;
            newAttendee.Follow_up_with_a_Project__c = ProjectFollowUp;
            insert newAttendee;
        }
        
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
    
    
    public class EventWrapper{
        @AuraEnabled
        public String PresenterName {get;set;}
        @AuraEnabled
        public String PresenterEmail {get;set;}
        @AuraEnabled
        public String Provider {get;set;}
        @AuraEnabled
        public String ProviderNumber {get;set;}
        @AuraEnabled
        public String CourseName {get;set;}
        @AuraEnabled
        public String CourseId {get;set;}
        @AuraEnabled
        public String EventDate {get;set;}
        @AuraEnabled
        public String CompanyLogo {get;set;}
        @AuraEnabled
        public Boolean IsOngoing {get;set;}
        @AuraEnabled
        public Boolean IsAnotherLocation{get;set;}
        @AuraEnabled
        public List<String> ProviderLogoUrls {get;set;}
        @AuraEnabled
        public String RegistrationOverMessage {get;set;}
    }
    
    
}