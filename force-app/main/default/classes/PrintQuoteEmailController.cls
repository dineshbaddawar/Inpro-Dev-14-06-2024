public without sharing class PrintQuoteEmailController {
    
    public class EmailTemplateWrp{
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String bodyStr{get;set;}
    }

    @AuraEnabled
    public static String getEmailBody(String emailTemplateId){ 
        EmailTemplate emailTemp = 
            [
                SELECT 
                    Id, 
                    Body, 
                    HtmlValue,
                    Name 
                FROM EmailTemplate
                WHERE Id=: emailTemplateId OR Name =: emailTemplateId
            ];
        EmailTemplateWrp emailWrp = new EmailTemplateWrp();
        emailWrp.bodyStr = String.isNotBlank(emailTemp.HtmlValue) ? emailTemp.HtmlValue : emailTemp.Body;
        User currentuser = [Select Id, Signature from User Where Id=:UserInfo.getUserId()];
        //String emailsignature = currentuser.Signature.replaceAll('\r\n|\n|\r','</br>');
           // emailWrp.bodyStr = emailWrp.bodyStr + '</br>'  + emailsignature;
        emailWrp.id = emailTemplateId;
        Map<String, Object> resMap = new Map<String, Object>();
        resMap.put('status', true);
        resMap.put('emailWrp', emailWrp);
        return JSON.serializePretty(resMap);
    }

    @AuraEnabled
    public static String getFilesList(String reqStr){ 
        List<ContentVersion> contentVersionList = 
            [
                SELECT 
                    Id, 
                    Title, 
                    Description, 
                    FileType, 
                    ContentSize, 
                    FileExtension, 
                    CreatedDate 
                FROM ContentVersion
                ORDER BY CreatedDate desc
            ];
        Map<String, Object> resMap = new Map<String, Object>();
        resMap.put('status', true);
        resMap.put('contentVersionList', contentVersionList);
        return JSON.serializePretty(resMap);
    }

    @AuraEnabled
    public static String getContactList(String emailList){ 
        List<String> emails = emailList.split(',');
        System.debug('emails..'+emails);
        List<Contact> contactList = 
            [
                SELECT 
                    Id, 
                    Name,
                    Email 
                FROM Contact
                Where Email IN: emails OR Name IN: emails
                ORDER BY Name asc
            ];
        Map<String, Object> resMap = new Map<String, Object>();
        resMap.put('status', true);
        resMap.put('contactList', contactList);
        if(emailList.contains('CurrentUser')){
            resMap.put('userInfo', new Map<String, String>{
                'Id' => UserInfo.getUserId(),
                'Name' => UserInfo.getName(),
                'Email' => UserInfo.getUserEmail()
            });
        }

        if(emailList.contains('Territory Manager')){
            contactList.clear();

            string quoteId = emails.get(emails.size()-1);
            List<Quote> quoterec = [SELECT Id, Territory_Manager__c,OpportunityId,Opportunity.OwnerId FROM Quote where Id=:quoteId];
            //emails.add(quoterec[0].Territory_Manager__c);
            List<User> teritoryUserList = 
                [
                    SELECT  
                        Id,
                        Name,
                        Email
                    FROM User
                    WHERE Name=: quoterec[0].Territory_Manager__c
                ];
            resMap.put('TerritoryManager', new Map<String, String>{
                'Id' => teritoryUserList[0].Id,
                'Name' => teritoryUserList[0].Name,
                'Email' => teritoryUserList[0].Email
            });

          
        }
        if(emailList.contains('OpportunityOwner')){
            contactList.clear();

            string quoteId = emails.get(emails.size()-1);
            List<Quote> quoterec = [SELECT Id, Territory_Manager__c,OpportunityId,Opportunity.OwnerId FROM Quote where Id=:quoteId];
            List<User> opportunityowneruserlist = 
            [
                SELECT  
                    Id,
                    Name,
                    Email
                FROM User
                WHERE Id=: quoterec[0].Opportunity.OwnerId
            ];
        resMap.put('Opportunityowner', new Map<String, String>{
            'Id' => opportunityowneruserlist[0].Id,
            'Name' => opportunityowneruserlist[0].Name,
            'Email' => opportunityowneruserlist[0].Email
        });
        }
        return JSON.serializePretty(resMap);
    }
    
    @AuraEnabled
    public static String sendEmail(String reqStr){ 

        /*Map<String,Object> reqData = (Map<String,Object>) JSON.deserializeUntyped(reqStr);        
        String bccContacts = String.valueOf(reqData.get('bccContacts'));
        String ccContacts = String.valueOf(reqData.get('ccContacts'));
        String toContacts = String.valueOf(reqData.get('toContacts'));
        String subject = String.valueOf(reqData.get('subject'));
        String emailTemplateBody = String.valueOf(reqData.get('emailTemplateBody'));
        String selectedFiles = String.valueOf(reqData.get('selectedFiles'));
        String fromAddress = String.valueOf(reqData.get('fromAddress'));

        List<String> bccContactIds = String.isNotBlank(bccContacts) ?  bccContacts.split(',') : new List<String>();
        List<String> ccContactIds = String.isNotBlank(ccContacts)  ?    ccContacts.split(',') : new List<String>();
        List<String> toContactIds = String.isNotBlank(toContacts) ?  toContacts.split(',') : new List<String>();
        List<String> selectedFileIds = String.isNotBlank(selectedFiles) ?  selectedFiles.split(',') : new List<String>();

        Map<String,Object> res = new Map<String,Object>();
        List<OrgWideEmailAddress> orgWideAddressList = [
            SELECT 
                Id, 
                Address, 
                DisplayName 
            FROM OrgWideEmailAddress 
            where Address =: fromAddress
            LIMIT 1
        ];
        System.debug('orgWideAddressList..'+orgWideAddressList);

        List<Contact> bccContactsList = 
            [
                SELECT  
                    Id,
                    Email
                FROM Contact
                WHERE Id IN: bccContactIds
            ];
        
        List<Contact> ccContactsList = 
            [
                SELECT  
                    Id,
                    Email
                FROM Contact
                WHERE Id IN: ccContactIds
            ];
        
        List<Contact> toContactsList = 
            [
                SELECT  
                    Id,
                    Email
                FROM Contact
                WHERE Id IN: toContactIds
            ];

        List<ContentVersion> files = 
            [
                SELECT
                        Id,
                        Title, 
                        PathOnClient, 
                        FileType,
                        VersionData 
                    FROM ContentVersion
                    WHERE Id IN: selectedFileIds
                    ORDER BY CreatedDate DESC 
            ];

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(!bccContactIds.isEmpty()){
            message.setBccAddresses(bccContactIds);
        }
        if(!ccContactIds.isEmpty()){
            message.setCcAddresses(ccContactIds);
        }
        if(!toContactIds.isEmpty()){
            message.setToAddresses(toContactIds);
        }

        // Attach files to the message
        if(!files.isEmpty()){           
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for (ContentVersion file: files) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(file.PathOnClient);
                efa.setBody(file.VersionData);
                //efa.setContentType(file.);
                attachments.add(efa);
            }
            message.setFileAttachments(attachments);
        }
        message.setSubject(subject);
        message.setHtmlBody(emailTemplateBody);       
        //message.setOrgWideEmailAddressId(orgWideAddressList[0].Id);
        messages.add(message);
        try {
            Messaging.sendEmail(messages);
            res.put('status', true);
        } catch (Exception e) {
            res.put('status', false);
        }
        return JSON.serializePretty(res);  */
        return null;
    }
  

}