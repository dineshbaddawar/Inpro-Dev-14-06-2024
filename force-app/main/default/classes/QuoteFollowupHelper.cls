global with sharing class QuoteFollowupHelper {

    @invocablemethod
    public static void sendQuoteFollowUp(List<QuoteSendDTO> QuoteSendDTOList)
    {
        try {
                system.debug('DTO SIZE: ' + QuoteSendDTOList.size());
                if(QuoteSendDTOList != null && QuoteSendDTOList.size() > 0)
                {
                    QuoteSendDTO dto  = QuoteSendDTOList[0];        
                    List<String> Ids = dto.PrintQuoteIds.split(',');

                    //get the quotes from the print quote Ids
                    List<Print_Quote__c> printQuoteList = [SELECT OwnerId, Quote__c,  Contact_Email__c,Owner.Email,To_Address__c,BCC_Address__c,CC_Address__c
                    FROM Print_Quote__c
                    WHERE Id in :Ids];       
                    system.debug('Print Quote List SIZE: ' + printQuoteList.size());
                    Map<Id,Print_Quote__c> printQuoteMap = new Map<Id,Print_Quote__c>();

                    List<ID> quoteIds = new List<ID>();
                    for (Print_Quote__c q : printQuoteList) {
                        quoteIds.add(q.Quote__c);                
                        printQuoteMap.put(q.Quote__c, q);
                    }

                    //check if the quotes have had any activity recently
                    AggregateResult[] taskList = [SELECT Quote__c, Count(Id)
                    FROM Task
                    WHERE WhatId IN :quoteIds
                    AND ( CreatedDate > :dto.StartDate 
                        OR ( LastModifiedDate > :dto.StartDate AND Status = 'Completed') )
                    Group BY Quote__c
                    limit 200];
                    system.debug('Start Time: '+ dto.StartDate );
                    system.debug('Task List Size: ' + taskList.size());
                    
                    AggregateResult[] eventList = [SELECT Quote__c, Count(Id)
                    FROM Event
                    WHERE WhatId IN :quoteIds
                    AND CreatedDate > :dto.StartDate                         
                    Group BY Quote__c
                    limit 200];
                    system.debug('Event List Size: ' + eventList.size());

                    //create the final list of quotes
                    List<ID> finalQuoteIds = new List<ID>();
                    for (AggregateResult t : taskList) {
                        String qId = string.valueOf( t.get('Quote__c'));                
                        finalQuoteIds.add(qId);
                    }
                    for (AggregateResult e : eventList) {
                        String qId = string.valueOf(e.get('Quote__c'));
                        finalQuoteIds.add(qId);
                    }

                    for (ID removedId : finalQuoteIds) {
                        printQuoteMap.remove(removedId);
                    }

                    system.debug('Final Quote SIZE: ' + printQuoteMap.size());
                    finalQuoteIds = new List<ID>();
                    for ( Id key : printQuoteMap.keySet()) {
                        finalQuoteIds.add(key);
                    }


                    //get quote info
                    List<Quote> quoteList = [SELECT Id, OwnerId, Name, Opportunity_Name__c, ISR_Task_Trigger__c, Opportunity.OwnerId, OpportunityId, Opportunity.Name,
                                                    opportunity.Owner.Email, opportunity.Owner.Rich_Signature__c
                                            FROM Quote WHERE Id in :finalQuoteIds];

                if(quoteList != null && quoteList.size() > 0)
                { 
                        // get quote pdf files     
                        Map<Id,List<ContentVersion>> attachmentMap = new Map<Id,List<ContentVersion>>();
                        List<ContentVersion> attachments = new List<ContentVersion>();
                        List<ID> docLinkIds = new List<ID>();
                        Map<ID,ID> docLinkMap = new MAP<ID,ID>();
                        List<ContentDocumentLink> docLinks =  [SELECT Id, ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId in :quoteIds];
                        system.debug('doc link size: ' + docLinks.size());
                        if (docLinks.size() > 0)
                        {
                            for(ContentDocumentLink docLink : docLinks )
                            {
                                docLinkIds.add(docLink.ContentDocumentId);
                                docLinkMap.put(docLink.ContentDocumentId,docLink.LinkedEntityId);
                            }

                            attachments = 
                                [SELECT Id, Title, ContentDocumentId, PathOnClient, FileType, FileExtension,CreatedDate
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId IN :docLinkIds  
                                    ORDER BY CreatedDate DESC 
                                    LIMIT 1000];                
                                    system.debug('attachments size: ' + attachments.size());
                                for (ContentVersion Version : attachments) 
                                {             
                                        ID documentLinkId = docLinkMap.get(Version.ContentDocumentId);
                                        if (attachmentMap.containsKey(documentLinkId)) 
                                        {
                                            attachmentMap.get(documentLinkId).add(Version);
                                        }         
                                        else
                                        {
                                            List<ContentVersion> versions = new List<ContentVersion>();
                                            versions.add(Version);
                                            attachmentMap.put(documentLinkId, versions);
                                        }
                                }                      
                        }            
                        
                        //changes based on day            
                        string body = '';    
                        system.debug('Days: ' + dto.Days);
                        if (dto.Days == '5')
                        {                
                            body = 'Hi there, I hope all is well! Thanks again for giving me the opportunity to quote this project! If everything looks good, ' +
                                   'we can get it going for you. Or if you\'d like me to change something, please let me know, and I\'ll revise it and get it back to you right away for your approval.' +
                                   '<br/><br/>Thanks again and have an awesome day!';                                
                        }
                        else if (dto.Days == '30')
                        {               
                            body = 'Hi there, I hope all is well! I am following up on the attached quote as it\'s been a '+ 
                                   'little while since we last connected on it. If everything looks good and you\'d like to proceed, please let me know and '+
                                   'we will enter your order. If there\'s something that you would like me to change, please drop me a note, and I will adjust '+
                                   'the quote accordingly and get it back to you right away for your approval. We look forward to working with you on this project!'+
                                   '<br/><br/>Thanks, and have a great day,';
                        }
                        else if (dto.Days == '80')
                        {               
                            body = 'Hi there, I hope this note finds you doing well! The attached quote you requested is set to expire in the next 10 days, '+ 
                                    'so I wanted to see if this was something you still need to get rolling. We could lock this down now to insulate you from future price increases if you would like. '+ 
                                    'Please let me know how you would like me to proceed, and I will take care of it accordingly. '+ 
                                    'I\'m happy to answer any questions and would love to work with you on this project!'+
                                    '<br/><br/>Thanks, and have a great day,';
                        }
                        else {                            
                            body = 'Hi there, I hope all is well! Thanks again for giving me the opportunity to quote this project! If everything looks good, ' +
                                   'we can get it going for you. Or if you\'d like me to change something, please let me know, and I\'ll revise it and get it back to you right away for your approval.' +
                                   '<br/><br/>Thanks again and have an awesome day!';  
                        }

                        system.debug('Body: ' + body);

                        //create email messages
                        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>(); 
                                
                            for (quote quote : quoteList) 
                            {                                
                                try 
                                {
                                    Print_Quote__c pq = printQuoteMap.get(quote.Id);
                                    List<ContentVersion> versions =  attachmentMap.get(quote.Id);
                                    string subject = quote.Opportunity.Name;
                                    //get email fields
                                    String CC = '';
                                    if(pq.CC_Address__c != null)
                                    {  
                                        CC =  pq.CC_Address__c;                                       
                                    }

                                    String BCC = '';
                                    if(pq.BCC_Address__c != null)
                                          BCC = pq.BCC_Address__c;

                                    String contactEmail = pq.To_Address__c;
                                    
                                    //attachments from map
                                    string docName = quote.Name + ' ' + quote.Opportunity_Name__c;
                                    List<ContentVersion> attachmentsToSend = new List<ContentVersion>();                                    
                                    if(versions != null)
                                    {
                                        for (ContentVersion cv : versions) {
                                            if(cv.Title == docName && attachmentsToSend.size() == 0)
                                            {
                                                attachmentsToSend.add(cv);
                                            }
                                        }
                                    }             
                                    if(pq.To_Address__c != null && attachmentsToSend.size() > 0)                           
                                        allmsg.add(CreateEmailMessage(pq, quote, attachmentsToSend,contactEmail, CC, BCC, subject, body));  
                                  } 
                                  catch (Exception ex)
                                  {
                                    system.debug(ex.getMessage() + ex.getStackTraceString());
                                  }
                            }                
                            system.debug('Sending Emails: ' + allmsg.size());
                            if(allmsg.size() > 0)
                            Messaging.SendEmailResult results = Messaging.sendEmail(allmsg)[0];     
                    }
                }
            } catch (Exception ex) {
                system.debug(ex.getMessage() + ex.getStackTraceString());
            }
    }

    
    public static Messaging.SingleEmailMessage CreateEmailMessage(Print_Quote__c printQuote, Quote quote, List<ContentVersion> attachments, 
        string ToAddress, string CcAddress, string BccAddress, string Subject, string BodyHtml)
    {
        string[] toAddresses = new string[]{};
        if (ToAddress != '')toAddresses = toAddress.split(',');
        string[] ccAddresses = new string[]{};
        if (CcAddress != '')ccAddresses = CcAddress.split(',');
        string[] bccAddresses = new string[]{};
        if (BccAddress != '')bccAddresses = BccAddress.split(',');        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();             
        bccAddresses.add('mdaniel@inprocorp.com');   
        bccAddresses.add('ngreenwald@inprocorp.com');   
           if(GlobalHelper.IsProductionOrg() == false)
           {
                for (Integer i = 0; i < toAddresses.size(); i++) {
                    toAddresses[i] = toAddresses[i]+ '.invalid';
                }

                for (Integer i = 0; i < ccAddresses.size(); i++) {
                    ccAddresses[i] = ccAddresses[i]+ '.invalid';
                }          
                
                for (Integer i = 0; i < bccAddresses.size(); i++) {
                    bccAddresses[i] = bccAddresses[i]+ '.invalid';
                }           

                List<string> devToAddresses = new List<string>();
                devToAddresses.add('mdaniel@inprocorp.com');
                message.toaddresses = devToAddresses;
                  BodyHtml += 'TO: ';
                  BodyHtml += string.join(toAddresses,',');      
                  if (ccAddresses.size() > 0)
                  {
                    BodyHtml += 'CC: ';
                    BodyHtml += string.join(ccAddresses,',');           
                  }              
          }
          else 
          {
              message.toaddresses = toAddresses;    
              if (ccAddresses.size() > 0) message.ccaddresses = ccAddresses;
          }          

          if(quote.opportunity.Owner.Rich_Signature__c != null)
            BodyHtml += '<br/><br/>' + quote.opportunity.Owner.Rich_Signature__c;        
            if (bccAddresses.size() > 0) message.bccaddresses = bccAddresses;
        
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = '<html><head><style>p{margin-top:2px;margin-bottom:2px;}</style></head><body>' + BodyHtml + '</body></html>';
        //message.setTargetObjectId(QuoteId);            
        
        message.setReplyTo(quote.opportunity.Owner.Email);
        message.setSenderDisplayName(quote.opportunity.Owner.Email);
        message.setWhatId(quote.Id);
        message.setSaveAsActivity(true);
        
        if (attachments.size() > 0)
        {
            List<Id> fileIds = new List<Id>();
            List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion file : attachments)
            {               
                fileIds.add(file.Id);
                //message.htmlbody += '<br><a href="' + file.PathOnClient + '">' + efa.fileName + '</a>';
            }
            //message.setFileAttachments(efas);
            message.setEntityAttachments(fileIds);
        }

      return message;      
    }

    @AuraEnabled
    public static string SendEmail(Print_Quote__c printQuote, Quote quote, List<ContentVersion> attachments, 
        string ToAddress, string CcAddress, string BccAddress, string Subject, string BodyHtml)
    {
        string[] toAddresses = new string[]{};
        if (ToAddress != '')toAddresses = toAddress.split(',');
        string[] ccAddresses = new string[]{};
        if (CcAddress != '')ccAddresses = CcAddress.split(',');
        string[] bccAddresses = new string[]{};
        if (BccAddress != '')bccAddresses = BccAddress.split(',');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.toaddresses = toAddresses;
        if (ccAddresses.size() > 0) message.ccaddresses = ccAddresses;
        if (bccAddresses.size() > 0) message.bccaddresses = bccAddresses;
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = '<html><head><style>p{margin-top:2px;margin-bottom:2px;}</style></head><body>' + BodyHtml + '</body></html>';
        //message.setTargetObjectId(QuoteId);
        User user = [SELECT Email FROM User WHERE Id = :quote.OwnerId]; 
        
        message.setReplyTo(user.Email);
        message.setWhatId(quote.Id);
        message.setSaveAsActivity(true);
        
        if (attachments.size() > 0)
        {
            List<Id> fileIds = new List<Id>();
            List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion file : attachments)
            {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.fileName = file.Title+'.'+file.FileExtension;
                efa.body =file.VersionData;
                efas.add(efa);
                fileIds.add(file.Id);
                //message.htmlbody += '<br><a href="' + file.PathOnClient + '">' + efa.fileName + '</a>';
            }
            //message.setFileAttachments(efas);
            message.setEntityAttachments(fileIds);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(message);

        try {
            Messaging.SendEmailResult results = Messaging.sendEmail(allmsg)[0];
            if (results.success){
                return '';
            } 
            else return results.errors[0].getMessage();
        } catch (Exception e) {
            return e.getMessage() + ': ' + e.getStackTraceString();       
        }
    }

    public void QuoteFollowupHelper() {
        List<Task> tasksToCreate = new List<Task>();
        List<Quote> quotes = 
            [SELECT Id, Opportunity.OwnerId, LastModifiedDate, OpportunityId
            FROM Quote 
            //WHERE LastModifiedDate < LAST_N_DAYS:5 AND LastModifiedDate >= LAST_N_DAYS:6
            WHERE ISR_Task_Trigger__c = false
            AND Requires_Follow_Up__c = true
            AND Opportunity.StageName = 'Negotiation'
            AND Status = 'Sent To Customer'];
                            
        //Make sure quote follow up tasks do not already exist on opportunity

        for (Quote quote : quotes) {
            quote.ISR_Task_Trigger__c = true;

            //add follow up task to list
            Task t = new Task();
            t.Subject = 'Follow Up Task';
            t.OwnerId = quote.Opportunity.OwnerId;
            t.Status = 'Open';
            t.WhatId = quote.OpportunityId;
            t.Type = 'Quote Follow Up';
            t.Description = ' Please review this quote.';
            
            tasksToCreate.add(t);
            //due date is 5 business days out after sent to customer
        }

        if(quotes != null && quotes.size() != 0)
        {
            update quotes;
        }
            
        if(tasksToCreate != null && tasksToCreate.size() != 0)
        {
            //Do not notify user of new task
            Database.DMLOptions dm = new Database.DMLOptions();
            dm.EmailHeader.TriggerUserEmail = false;
            database.insert(tasksToCreate, dm);
        }
            
    }

    public void QuoteFollowupHelper(string quoteId)
    {
        Quote quote = [SELECT Id, OpportunityId, Opportunity.OwnerId, LastModifiedDate
                        FROM Quote 
                        //WHERE LastModifiedDate < LAST_N_DAYS:5 AND LastModifiedDate >= LAST_N_DAYS:6
                        WHERE ISR_Task_Trigger__c = false
                        AND Requires_Follow_Up__c = true
                        AND Opportunity.StageName = 'Negotiation'
                        AND Status = 'Sent To Customer'
                        AND Id = :quoteId];
        
        List<Task> existingFollowUps = [SELECT Id, Type FROM Task WHERE Type = 'Quote Follow Up' AND WhatId = :quote.OpportunityId];

        if (quote != null && existingFollowUps.size() == 0)
        {
            //Make sure quote follow up tasks do not already exist on opportunity

            quote.ISR_Task_Trigger__c = true;

            //add follow up task to list
            Task t = new Task();
            t.Subject = 'Follow Up Task';
            t.OwnerId = quote.Opportunity.OwnerId;
            t.Status = 'Open';
            t.WhatId = quote.OpportunityId;
            t.Type = 'Quote Follow Up';
            t.Description = ' Please review this quote.';
            //due date is 5 business days out after sent to customer

            update quote;

            Database.DMLOptions dm = new Database.DMLOptions();
            dm.EmailHeader.TriggerUserEmail = false;
            database.insert(t, dm);
        }
    }

    global class QuoteSendDTO {        
        @InvocableVariable
        global string PrintQuoteIds;
        @InvocableVariable
        global string Days;    
        @InvocableVariable
        global Date StartDate;      
      }
}