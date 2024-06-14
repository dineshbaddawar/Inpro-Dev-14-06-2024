trigger AsyncProcessTrigger on AsyncProcess__c (after update, after insert) 
{
    if(Trigger.isUpdate)
    {
        for(AsyncProcess__c ap:Trigger.new)
        {
            String Title = '';
            String Body = '';
            String recordId = ap.ObjectId__c;
            Set<String> recipientsIds = new Set<String>();
            String targetId = ap.ObjectId__c; //'0Q06C000000PLA1SAO';
            //recipientsIds.add('0056g000004ah22AAA'); //david
            //recipientsIds.add('0056g000001a8vGAAQ');	//matt		
            recipientsIds.add(ap.CreatedById);
            recipientsIds.add(ap.OwnerId);
            String QuoteNumber = '';
            CustomNotificationFromApex cn = new CustomNotificationFromApex();          

            if(ap.Status__c == 'Complete' && ap.Name == 'Save Quote')
            {          
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);
            
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                
                if (!Test.isRunningTest()) {
                    try{
                        QuoteComparisonHelper.VerifyAddDeductQuote(recordId);
                    }catch(Exception ex)
                    {
                        CopyQuoteHelper.verifyConfiguration(recordId);
                    }
                    
                }
                
                Title = 'Quote Save Complete';
                Body = 'Your quote ' +  QuoteNumber + ' has finished saving, see it by clicking here.';                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                //delete [select id from AsyncProcess__c where id in :Trigger.new];
            }
            else if (ap.Status__c == 'Error' && ap.Name == 'Save Quote')
            {            
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);                  
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                Title = 'Quote Save Failed';
                Body = 'Your quote ' +  QuoteNumber + ' has failed saving, please review Experlogix for errors. Error: ' + ap.Log__c;                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);    
            }
            else if(ap.Status__c == 'Complete' && ap.Name == 'SignPro')
            {          
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);
            
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                        
                Title = 'SignPro Complete';
                Body = 'Your SignPro for Quote: ' +  QuoteNumber + ' has finished saving, see it by clicking the files tab..';                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                delete [select id from AsyncProcess__c where id in :Trigger.new];
            }
            else if (ap.Status__c == 'Error' && ap.Name == 'SignPro')
            {            
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);                  
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                Title = 'SignPro Failed';
                Body = 'Your SignPro for Quote: ' +  QuoteNumber + ' has failed saving, Error: ' + ap.Log__c;                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);    
            }
            else if(ap.Status__c == 'Complete' && ap.Name == 'SignScheduleUpload')
            {          
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);
            
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                        
                Title = 'SignSchedule Upload Complete';
                Body = 'Your SignSchedule Upload for Quote: ' +  QuoteNumber + ' has finished.';                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                delete [select id from AsyncProcess__c where id in :Trigger.new];
            }
            else if (ap.Status__c == 'Error' && ap.Name == 'SignScheduleUpload')
            {            
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);                  
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                Title = 'SignSchedule Upload Failed';
                Body = 'Your SignSchedule Upload for Quote: ' +  QuoteNumber + ' has failed. Error: ' + ap.Log__c;                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);    
            }
            else if(ap.Status__c == 'Complete' && ap.Name == 'Print Quote')
            {          
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);
            
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }

                //Begin Email logic

                string userId = '';
                List<String> toList = new List<String>();
                List<String> ccList = new List<String>();
                List<String> bccList = new List<String>();
                String subject = '';
                String htmlBody = '';
                String attachmentIds = '';
                try{
                    //See SalesforceData/helper/CustomFormHelper.cs for how this is composed
                    String[] logStr = ap.Log__c.split('---');
                    
                    for(String log : logStr)
                    {
                        if (log.indexOf(':TO:') != -1)
                        { //Build To Addresses
                            String[] temp = log.substring(4).split(',');
                            for(String t : temp)
                            {
                                if (t != '')
                                {
                                    toList.add(t);
                                }
                            }
                        }
                        else if (log.indexOf(':CC:') != -1)
                        { //Build CC Addresses
                            String[] temp = log.substring(4).split(',');
                            for(String t : temp)
                            {
                                if (t != '')
                                {
                                    ccList.add(t);
                                }
                            }
                        }
                        else if (log.indexOf(':BCC:') != -1)
                        { //Build BCC Addresses
                            String[] temp = log.substring(5).split(',');
                            for(String t : temp)
                            {
                                if (t != '')
                                {
                                    bccList.add(t);
                                }
                            }
                        }
                        else if (log.indexOf(':SUBJECT:') != -1)
                        {
                            subject = log.substring(9);
                        }
                        else if (log.indexOf(':BODY:') != -1)
                        {
                            htmlBody = log.substring(6);
                        }
                        else if (log.indexOf(':ATTACHMENT:') != -1)
                        {
                            attachmentIds = log.substring(12);
                        }
                        else if (log.indexOf(':USER:') != -1)
                        {
                            userId = log.substring(6);
                        }
                    }
                
                    string sender = [select email from user where id =:userId limit 1].email;
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = toList;
                    if (ccList.size() > 0) message.ccaddresses = ccList;
                    if (bccList.size() > 0) message.bccaddresses = bccList;
                    message.optOutPolicy = 'FILTER';
                    message.subject = subject;
                    message.htmlbody = htmlBody;
                    message.setReplyTo(sender);
                    message.setSenderDisplayName(sender);
                    
                    //At least one attachment should always be available
                    //Create attachment and link it to activity on send
                    if (attachmentIds != '')
                    {
                        attachmentIds = attachmentIds.substring(0, attachmentIds.length()-1); //remove last comma
                        string Query2 = 'SELECT Title, PathOnClient, FileType, FileExtension, VersionData FROM ContentVersion WHERE Id IN (' + AttachmentIds + ')';
                        List<ContentVersion> files = Database.query(Query2);
                        List<Id> fileIds = new List<Id>();
                        List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
                        for(ContentVersion file : files)
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
                    
                    //Save to quote
                    message.setSaveAsActivity(true);
                    message.whatid = ap.objectId__c;

                    //Send email
                    Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                    if (results[0].success) {
                        
                        Title = 'Print Quote Custom Forms Email Complete';
                        Body = 'Your Email with Custom Forms for Quote: ' +  QuoteNumber + ' has finished.';                     
                        cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                        delete [select id from AsyncProcess__c where id in :Trigger.new];
                    } else {
                        Title = 'Print Quote Custom Forms Email Failure';
                        Body = results[0].errors[0].message;                
                        cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                    }
                    
                }
                catch(Exception ex)
                {
                    Title = 'Print Quote Custom Forms Email Failure';
                    Body = ex.getMessage() + ' - ' + attachmentIds + ' - ' + ex.getStackTraceString();                
                    cn.notifyUsers(recipientsIds, targetId, Title, Body);  
                }
            }
            else if (ap.Status__c == 'Error' && ap.Name == 'Print Quote')
            {            
                String Query = 'SELECT QuoteNumber FROM Quote WHERE Id = :recordId LIMIT 1';
                List<Quote> quoteList = Database.query(Query);                  
                if(quoteList.size() > 0 && quoteList[0] != null && quoteList[0].QuoteNumber != null)
                {
                    QuoteNumber = quoteList[0].QuoteNumber;
                }
                Title = 'Print Quote Custom Forms Email Failed';
                Body = 'Your Email with Custom Forms for Quote: ' +  QuoteNumber + ' has failed. Error: ' + ap.Log__c;                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);    
            }
        }
    }
    else if(Trigger.isInsert)
    {   
        if(Trigger.new.size() == 1)
        {
            List<Lead> leadsToUpdate = new List<lead>();
            //for now run when it's only one record getting updated.
            AsyncProcess__c ap = Trigger.new[0];  
            if(ap.objectType__c != null && ap.objectType__c == 'Lead')
            {
                List<Lead> leads = [SELECT Id, Status, Date_Assigned_to_User__c, Lead_Notification_Sent__c, 
                                        OwnerId, CreatedById, IsConverted 
                                    FROM lead 
                                    WHERE id = :ap.ObjectId__c LIMIT 1];

                if(leads.size() > 0)
                {
                    Lead l = leads[0];

                    if (l.Lead_Notification_Sent__c == false && 
                        l.OwnerId.to15().startsWith('005') &&
                        l.OwnerId != l.CreatedById &&
                        l.IsConverted == false &&
                        l.Status != 'Disqualified')
                    {
                        Lead lead = new Lead();
                        lead.Id = l.Id;
                        lead.Date_Assigned_to_User__c = Datetime.now();
                        lead.Lead_Notification_Sent__c = true;
                        //this field seems redudant
                        //lead.Lead_Owner_s_Manager__c =
                        leadsToUpdate.add(lead);
                        EmailSendHelper.EmailSendDTO emailDTO = new EmailSendHelper.EmailSendDTO();
                        List<EmailSendHelper.EmailSendDTO> emailDTOList = new List<EmailSendHelper.EmailSendDTO>();
                        emailDTO.UserId = l.OwnerId;                    
                        emailDTO.RecordId = l.Id;    
                        emailDTO.TemplateName = 'New_lead_Assignment_1st_Notification';
                        emailDTO.IncludeManager = false;      
                        emailDTOList.add(emailDTO);
                        EmailSendHelper.sendEmail(emailDTOList);
                    } 

                    if(leadsToUpdate.size() > 0)
                    {
                        update leadsToUpdate;
                    }
                }

                delete [SELECT Id FROM AsyncProcess__c WHERE Id IN :Trigger.new];
            }
        }
    }
}