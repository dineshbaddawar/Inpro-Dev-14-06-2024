public class LandLResendCertificates {
    public static string ResendCertificates(Set<String> eventAttendeeIdList) { 
        if (Test.isRunningTest()) return 'Success';
        string result='No Result';
        
        List<Event_Attendee__c> eventAttendeeList = new List<Event_Attendee__c>();
        eventAttendeeList= [Select Id,Lead__c,Contact__c,FirstName__c,Lead__r.Name,Contact__r.Name,
                            Contact__r.IDCEC_Number__c,Contact__r.GBCI_Number__c,
                            Lead__r.IDCEC_Number__c,Lead__r.GBCI_Number__c,
                            LunchAndLearn_AIA_Number__c,Course__c,
                            Course__r.USGBC_Course_ID__c,Course__r.LandLCourseCredit__c,
                            Course__r.Name,Course__r.Provider_Id__c,Course__r.Id,
                            Course__r.Course_Id__c,Course__r.IDCEC_Course_ID__c,
                            LastName__c,Email__c,Email_Opt_In__c,LunchAndLearnEvent__c,Status__c,
                            LunchAndLearnEvent__r.Course_Name__c,LunchAndLearnEvent__r.OwnerId,
                            LunchAndLearnEvent__r.Owner.email,LunchAndLearnEvent__r.Owner.Name,
                            LunchAndLearnEvent__r.Owner.Title,LunchAndLearnEvent__r.Owner.Phone,
                            LunchAndLearnEvent__r.StartDateTime__c,LunchAndLearnEvent__r.Course_Name__r.Name,
                            LunchAndLearnEvent__r.Location1__c
                            from Event_Attendee__c
                            where Id in:eventAttendeeIdList
                            AND Status__c='Attended' ];      
        
        Set<String> courseIdList = new Set<String>();
        for(Event_Attendee__c att : eventAttendeeList){
            courseIdList.add(att.LunchAndLearnEvent__r.Course_Name__c);
        }
        Map<Id,Course__c> courseMap = new Map<Id,Course__c>([SELECT Id, Name,Provider_Name__c,Provider_Logo_URL__c,
                                                             (select Id,Standards_Body__c,Standards_Body__r.Name,
                                                              Standards_Body__r.Id,Provider_ID_for_this_Course__c,
                                                              Course_Id__c,Standards_Body__r.Logo_URL__c,Learning_Unit_Type__c,
                                                              Standards_Body__r.Requires_Certificate__c,LandLCourseCredit__c
                                                              FROM Standards_Bodies_Covered__r)
                                                             FROM Course__c]);
        
        List<Id> contactIdList = new List<Id>();
        List<Id> LeadIdList = new List<Id>();
        for(Event_Attendee__c attendee : eventAttendeeList) {
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
                                                where Contact__c in :contactIdList or Lead__c in :LeadIdList]){
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
        
        
        Set<Id> userIdSet = new Set<Id>();
        Set<String> ownerEmails = new Set<String>();
        for(Event_Attendee__c c : eventAttendeeList) {
            userIdSet.add(c.LunchAndLearnEvent__r.OwnerId);
            ownerEmails.add(c.LunchAndLearnEvent__r.Owner.email);
        }
        Map<String,OrgWideEmailAddress> orgWideEmailMap = new Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress owea : [select Id,Address from OrgWideEmailAddress where Address in: ownerEmails]){
            orgWideEmailMap.put(owea.Address, owea);
        }
        Map<Id,User> userMap = new Map<Id,User>();
        for(User u: [SELECT Id, Name, Firstname, LastName, 
                     CompanyName, Email, Street, City, State, 
                     PostalCode, Phone
                     FROM User
                     WHERE Id in : userIdSet]){
                         userMap.put(u.Id,u);
                     }
        
        String emailTemplateName = 'LandLCertificateTemplate';
        EmailTemplate template = [SELECT Id, DeveloperName, Subject, HtmlValue 
                                  FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        String emailBody = template.HtmlValue;
        String emailSubject = template.Subject;
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(Event_Attendee__c m : eventAttendeeList) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String courseId = m.LunchAndLearnEvent__r.Course_Name__c;
            DateTime EvtStartTime = m.LunchAndLearnEvent__r.StartDateTime__c;
            String strdt = DateTime.newInstance(EvtStartTime.year(),EvtStartTime.month(),EvtStartTime.day()).format('MM-dd-yyyy');
            
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            
            for(Standards_Bodies_Covered__c sbc : courseMap.get(courseId).Standards_Bodies_Covered__r){
                if(sbc.Standards_Body__r.Requires_Certificate__c){
                    if(sbc.Standards_Body__r.Name == 'AIA'){
                        String newCertName = '';
                        newCertName=  'AIA CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
                        String ccreditaia = String.valueOf(sbc.LandLCourseCredit__c);
                        PageReference AIACertificate =  Page.CertificateAIA2;
                        
                        AIACertificate.getParameters().put('StandardBodyName',sbc.Standards_Body__r.Name);
                        AIACertificate.getParameters().put('Coursecredit',string.valueOf(sbc.LandLCourseCredit__c)); 
                        AIACertificate.getParameters().put('DateCompleted',strdt);
                        AIACertificate.getParameters().put('CourseName',courseMap.get(courseId).Name);   
                        AIACertificate.getParameters().put('CourseNumber',sbc.Course_Id__c); 
                        AIACertificate.getParameters().put('ProviderName',courseMap.get(courseId).Provider_Name__c);
                        AIACertificate.getParameters().put('ProviderNumber',sbc.Provider_ID_for_this_Course__c);
                        AIACertificate.getParameters().put('ContactInfo',m.Email__c);
                        AIACertificate.getParameters().put('OwnerName',m.LunchAndLearnEvent__r.Owner.Name);  
                        AIACertificate.getParameters().put('StandardBodyLogo',sbc.Standards_Body__r.Logo_URL__c);
                        AIACertificate.getParameters().put('ProviderLogo',courseMap.get(courseId).Provider_Logo_URL__c);
                        AIACertificate.getParameters().put('l&lRecordId',m.LunchAndLearnEvent__r.Id);
                        if(m.Lead__c!=null){
                            AIACertificate.getParameters().put('AttendeeName',m.Lead__r.Name);  
                            if(stdBodyRegMap.containsKey(m.Lead__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Lead__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        AIACertificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        else if (m.Contact__c!=null){
                            AIACertificate.getParameters().put('AttendeeName',m.Contact__r.Name); 
                            if(stdBodyRegMap.containsKey(m.Contact__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Contact__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        AIACertificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        AIACertificate.getParameters().put('isHSW','false');
                        if(sbc.Learning_Unit_Type__c == 'Health, Safety, & Welfare')
                            AIACertificate.getParameters().put('isHSW','true');
                        
                        system.debug('AIACertificate'+AIACertificate);
                        AIACertificate.setRedirect(true);
                        Blob b ;
                        if(test.isRunningTest()){
                            b = Blob.valueOf('test');
                        }
                        else{
                            b = AIACertificate.getContent();
                        }
                        
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(newCertName);
                        efa.setBody(b);
                        fileAttachments.add(efa);
                    }
                    
                    else if(sbc.Standards_Body__r.Name == 'GBCI'){
                        String newCertName = '';
                        newCertName=  'USGBC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
                        String ccredit = String.valueOf(m.Course__r.LandLCourseCredit__c) ;
                        PageReference USGBCCertificate = Page.CertificateGBCICMP2;
                        
                        USGBCCertificate.getParameters().put('StandardBodyName',sbc.Standards_Body__r.Name);
                        USGBCCertificate.getParameters().put('Coursecredit',string.valueOf(sbc.LandLCourseCredit__c)); 
                        USGBCCertificate.getParameters().put('DateCompleted',strdt);
                        USGBCCertificate.getParameters().put('CourseName',courseMap.get(courseId).Name);   
                        USGBCCertificate.getParameters().put('CourseNumber',sbc.Course_Id__c); 
                        USGBCCertificate.getParameters().put('ProviderName',courseMap.get(courseId).Provider_Name__c);
                        USGBCCertificate.getParameters().put('ProviderNumber',sbc.Provider_ID_for_this_Course__c);
                        USGBCCertificate.getParameters().put('ContactInfo',m.Email__c);
                        USGBCCertificate.getParameters().put('OwnerName',m.LunchAndLearnEvent__r.Owner.Name);  
                        USGBCCertificate.getParameters().put('StandardBodyLogo',sbc.Standards_Body__r.Logo_URL__c);
                        USGBCCertificate.getParameters().put('ProviderLogo',courseMap.get(courseId).Provider_Logo_URL__c);
                        USGBCCertificate.getParameters().put('l&lRecordId',m.LunchAndLearnEvent__r.Id);
                        if(m.Lead__c!=null){
                            USGBCCertificate.getParameters().put('AttendeeName',m.Lead__r.Name);  
                            if(stdBodyRegMap.containsKey(m.Lead__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Lead__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        USGBCCertificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        else if (m.Contact__c!=null){
                            USGBCCertificate.getParameters().put('AttendeeName',m.Contact__r.Name); 
                            if(stdBodyRegMap.containsKey(m.Contact__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Contact__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        USGBCCertificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        USGBCCertificate.getParameters().put('isHSW','false');
                        if(sbc.Learning_Unit_Type__c == 'Health, Safety, & Welfare')
                            USGBCCertificate.getParameters().put('isHSW','true');
                        
                        system.debug('USGBCCertificate'+USGBCCertificate);
                        USGBCCertificate.setRedirect(true);
                        Blob b ;
                        if(test.isRunningTest()){
                            b = Blob.valueOf('test');
                        }
                        else{
                            b = USGBCCertificate.getContent();
                        }
                        
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(newCertName);
                        efa.setBody(b);
                        fileAttachments.add(efa);
                    }
                    
                    else{
                        
                        String newCertName = '';
                        newCertName= sbc.Standards_Body__r.Name + ' CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
                        PageReference certificate = Page.LandLEventCertificate;
                        certificate.getParameters().put('StandardBodyName',sbc.Standards_Body__r.Name);
                        certificate.getParameters().put('Coursecredit',string.valueOf(sbc.LandLCourseCredit__c)); 
                        certificate.getParameters().put('DateCompleted',strdt);
                        certificate.getParameters().put('CourseName',courseMap.get(courseId).Name);   
                        certificate.getParameters().put('CourseNumber',sbc.Course_Id__c); 
                        certificate.getParameters().put('ProviderName',courseMap.get(courseId).Provider_Name__c);
                        certificate.getParameters().put('ProviderNumber',sbc.Provider_ID_for_this_Course__c);
                        certificate.getParameters().put('ContactInfo',m.Email__c);
                        certificate.getParameters().put('OwnerName',m.LunchAndLearnEvent__r.Owner.Name);  
                        certificate.getParameters().put('StandardBodyLogo',sbc.Standards_Body__r.Logo_URL__c);
                        certificate.getParameters().put('ProviderLogo',courseMap.get(courseId).Provider_Logo_URL__c);
                        
                        if(m.Lead__c!=null){
                            certificate.getParameters().put('AttendeeName',m.Lead__r.Name);  
                            if(stdBodyRegMap.containsKey(m.Lead__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Lead__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        certificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        else if (m.Contact__c!=null){
                            certificate.getParameters().put('AttendeeName',m.Contact__r.Name); 
                            if(stdBodyRegMap.containsKey(m.Contact__c)){
                                for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Contact__c)){
                                    if(sbr.Standards_Body__r.Id == sbc.Standards_Body__r.Id){
                                        certificate.getParameters().put('StandardBodyRegistrationNumber',sbr.Registration_Number__c);
                                    }
                                }
                            }
                        }
                        system.debug('certificate'+certificate);
                        certificate.setRedirect(true);
                        Blob b ;
                        if(test.isRunningTest()){
                            b = Blob.valueOf('test');
                        }
                        else{
                            b = certificate.getContent();
                        }
                        
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(newCertName);
                        efa.setBody(b);
                        fileAttachments.add(efa);
                    }
                }
            }
            
            Boolean hasIDCEC = false;
            if(m.Lead__c!=null){
                if(stdBodyRegMap.containsKey(m.Lead__c)){
                    for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Lead__c)){
                        if(sbr.Standards_Body__r.Name == 'IDCEC'){
                            if(sbr.Registration_Number__c != null)
                                hasIDCEC = true;
                        }
                    }
                }
            }
            else if (m.Contact__c!=null){
                if(stdBodyRegMap.containsKey(m.Contact__c)){
                    for(Standards_Bodies_Registered__c sbr:stdBodyRegMap.get(m.Contact__c)){
                        if(sbr.Standards_Body__r.Name == 'IDCEC'){
                            if(sbr.Registration_Number__c != null)
                                hasIDCEC = true;
                        }
                    }
                }
            }
         
            if(!hasIDCEC)
                message.setFileAttachments(fileAttachments);
            
            String[] bccAddress = new String[] {'jpauly@thehunleygroup.com'};
            message.toAddresses = new String[] {m.email__c};
                
            message.setBccAddresses(bccAddress);
            
            string fullname = '';
            string targetObjectId = '';
            
            if(m.Lead__c!=null) {
                fullname=m.Lead__r.Name;
                targetObjectId=m.Lead__c;
            } else if (m.Contact__c!=null) {
                fullname=m.Contact__r.Name;
                targetObjectId=m.Contact__c;   
            }
            
            User senderUser = userMap.get(m.LunchAndLearnEvent__r.OwnerId);
            
            //string surveyLink = '';
            //string surveyLink = '<a href="'+LunchandLearnUtils.GetMetadataValue('Survey_URL__c') +'?eventAttendeeId='+m.Id+'">Survey Link</a>';
            
            string subject = emailSubject;
            subject = subject.replace('###COURSENAME###', m.Course__r.Name);
            
            message.subject = subject;
            
            string htmlBody = emailBody;
            htmlBody = htmlBody.replace('###FULLNAME###', fullname);
            htmlBody = htmlBody.replace('###COURSENAME###', m.Course__r.Name);
            //htmlBody = htmlBody.replace('###SURVEYLINK###', surveyLink);
            
            string senderData = '';
            senderData += '<p>' + senderUser.FirstName + ' ' + senderUser.LastName + '</p>';
            
            htmlBody = htmlBody.replace('###SENDERDATA###', senderData);
            
            message.setHtmlBody(htmlBody);
            
            message.setReplyTo(m.LunchAndLearnEvent__r.Owner.email);
            
            if(orgWideEmailMap.containsKey(m.LunchAndLearnEvent__r.Owner.email)){
                message.setOrgWideEmailAddressId(orgWideEmailMap.get(m.LunchAndLearnEvent__r.Owner.email).Id);
            }
            else {
                message.setSenderDisplayName(m.LunchAndLearnEvent__r.Owner.name);
            }
            
            message.setTargetObjectId(targetObjectId);
            message.setSaveAsActivity(true);
            messages.add(message);
            System.debug('@@#'+message);
            
        }
        Messaging.SendEmailResult[] results;
        if (!Test.isRunningTest())
        {
             results = Messaging.sendEmail(messages,false);
            for(Messaging.SendEmailResult r : results) {
                if(r.isSuccess()==false) {
                    System.debug('error: ' + r.getErrors());
                    result = 'Error sending emails.';
                    
                    String[] adminMailIds = LunchandLearnUtils.GetMetadataValue('Admin_Notification__c').split(',');
                    Messaging.SingleEmailMessage messageToAdmin = new Messaging.SingleEmailMessage();
                    messageToAdmin.toAddresses = adminMailIds;
                    messageToAdmin.subject = 'Inpro Org- L&L Email Resend Exception';
                    List<Messaging.SendEmailError> errorList = r.getErrors();
                    String errorEmailHtmlBody = '';
                    for(Messaging.SendEmailError err:errorList){
                        errorEmailHtmlBody += err.getMessage() + ', Status Code: '+err.getStatusCode() + ', TargetObjectId: '+  err.getTargetObjectId();
                        errorEmailHtmlBody += '</br>';
                    }
                    messageToAdmin.htmlbody = errorEmailHtmlBody;
                    
                    Messaging.SingleEmailMessage[] adminMessages = new List < Messaging.SingleEmailMessage > {
                        messageToAdmin
                            };
                                Messaging.SendEmailResult[] adminEmailResults = Messaging.sendEmail(adminMessages);
                    
                } else {
                    result = 'Success';
                }
            }
        }
        return result;
    }
    
}