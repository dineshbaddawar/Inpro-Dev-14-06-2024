global with sharing class EmailSendHelper {
    @invocablemethod
public static void sendEmail (List<EmailSendDTO> EmailDTOList)
{
    if (Test.isRunningTest()) return;
    
    try {           
        Boolean isProduction = GlobalHelper.IsProductionOrg();

        if(EmailDTOList.size() == 0)
            return;
        
        EmailSendDTO  emailDto = EmailDTOList[0];

       
        List<string> ccAddress = new List<string>();
        if(emailDto.CCEmail != null && emailDto.CCEmail != '')
            ccAddress.add(emailDto.CCEmail);

        EmailTemplate et;
        //emailDto.TemplateName ='Lead_Notification_Test';
        if(emailDto.TemplateName != null && emailDto.TemplateName != '')
         et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:emailDto.TemplateName];

        if (emailDto.TemplateName == 'New_lead_Assignment_2nd_Notification' || 
            emailDto.TemplateName =='lead_Assignment_3rd_Notification' || 
            emailDto.TemplateName =='lead_Assignment_4th_Notification')
        {
            Lead lead = [SELECT Id, Status FROM Lead WHERE Id = :emailDto.RecordId];
            if (lead.Status != 'MQL')
            {
                return; //Do not send additional notifications if lead is disqualified
            }
        }
        List<User> userList;
        if(emailDto.UserId != null)
            userList = [SELECT DelegatedApproverId, Email, ManagerId  FROM User  WHERE Id = :emailDto.UserId LIMIT 1];
        else
            userList = [SELECT DelegatedApproverId, Email, ManagerId  FROM User  WHERE Email = :emailDto.ToEmail LIMIT 1];        

        List<string> toAddress = new List<string>();
        

        if(userList.size() > 0)
        {                    
            if(emailDto.ToEmail == null || emailDto.ToEmail == '')
                emailDto.ToEmail = userList[0].Email;
            toAddress.add(emailDto.ToEmail);
            //string EmailTo = userList[0].Email;
            string EmailCC = '';
            string deletegatedApproverId = userList[0].DelegatedApproverId;
            if(deletegatedApproverId != null)
            {
                EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId LIMIT 1].Email;
                ccAddress.add(EmailCC);
            }

            if(emailDto.IncludeManager != null && emailDto.IncludeManager)
            {
                string managerID = userList[0].ManagerId;
                if(managerID != null)
                {
                    List<User> mList = [SELECT Email FROM User  WHERE Id = :managerID LIMIT 1];
                    if(mList.size() > 0)
                        ccAddress.add(mList[0].Email);
                }
            }
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(et != null && et.Id != null)
                mail.setTemplateId(et.Id);
              else 
                mail.setHtmlBody(emailDto.Body);

            mail.setToAddresses(toAddress);
            if(ccAddress != null && ccAddress.size() > 0)
            mail.setCcAddresses(ccAddress);
            if(!isProduction)
                mail.bccaddresses = new String[] { 'dsieraski@inprocorp.com'};
            mail.setSubject(emailDto.Subject);
            mail.setTargetObjectId(emailDto.UserId);
            mail.setWhatId(emailDto.RecordId);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);      

            if(emailDto.SendFromSystemAccount != null && emailDto.SendFromSystemAccount)  
            {                  
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'crm365@inprocorp.com'];
                if(owea.size() > 0)
                    mail.setOrgWideEmailAddressId(owea[0].Id);
            }
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);

        try {            
            Messaging.sendEmail(allmsg);
            return;
        } catch (Exception e) {
            system.debug('Error sending email:');
            system.debug(e);
            system.debug(e.getStackTraceString());
            //sendEmail('dsieraski@inprocorp.com', '', 'Salesforce - Email Send Error', e.getMessage() + ' Email: ' + emailDto.ToEmail );            
        }
    } catch (Exception ex) {
      system.debug('Error creating email:');
      system.debug(ex);      
      system.debug(ex.getStackTraceString());
    }
}

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> contactSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';       

        string Query =  'SELECT Name, AccountId, Id, Email FROM Contact WHERE Name like :key and AccountId = :secondarySearchTerm LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List <LookupSearchResult>();

        String accountIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {
            String contactName = (String) so.get('Name');
            String Email = (String)so.get('Email'); 
            String contactId = (String)so.get('Id');
            String subtitle = Email;
            results.add(new LookupSearchResult(contactId, 'Contact', accountIcon, contactName, subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <Account> getAccountInfo(String accountId) {        
        string Query =  'SELECT Customer_Number__c FROM Account WHERE Id = :accountId LIMIT 1';          
        List<Account> accountList = Database.Query(Query);
        return accountList;
    }

    @AuraEnabled()
    public static string sendEmailAsCRM365(string EmailTo, string EmailCC, string Subject, string Body)
    {     
        if (Test.isRunningTest()) return 'The email was sent successfully.';

        try {
            
        
        Boolean isProduction = GlobalHelper.IsProductionOrg();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { EmailTo };
        if(EmailCC != '')
            message.ccaddresses = new String[] { EmailCC };
        if(!isProduction)
            message.bccaddresses = new String[] { 'dsieraski@inprocorp.com', 'eleptich@inprocorp.com', 'bsibley@inprocorp.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = Body;
        message.setOrgWideEmailAddressId([SELECT Address, Id FROM OrgWideEmailAddress WHERE Address = 'crm365@inprocorp.com' LIMIT 1].Id);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            return 'The email was sent successfully.';
        } else {
            return 'The email failed to send: ' + results[0].errors[0].message;
        }
    } catch (Exception ex) {
        return 'The email was not sent successfully.';   
    }
    }

    @AuraEnabled()
    public static string sendEmail(string EmailTo, string EmailCC, string Subject, string Body)
    {  
        if (Test.isRunningTest()) return 'The email was sent successfully.';

        try {            
        
        Boolean isProduction = GlobalHelper.IsProductionOrg();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { EmailTo };
        if(EmailCC != '' && EmailCC.indexOf(',') == -1)
        {
            message.ccaddresses = new String[] { EmailCC };
        }
        else if (EmailCC != '' && EmailCC.indexOf(',') != -1)
        {
            message.ccaddresses = EmailCC.split(',');
        }

        if(!isProduction)
            message.bccaddresses = new String[] { 'dsieraski@inprocorp.com', 'eleptich@inprocorp.com', 'bsibley@inprocorp.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = Body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            return 'The email was sent successfully.';
        } else {
            return 'The email failed to send: ' + results[0].errors[0].message;
        }
        } catch (Exception ex) {
            return 'The email was not sent successfully.'; 
        }
    }

    @AuraEnabled()
    public static string sendEmailMultipleRecipients(List<string> EmailTo, string EmailCC, string Subject, string Body)
    {   
        if (Test.isRunningTest()) return 'The email was sent successfully.';

        try {
            
        
        Boolean isProduction = GlobalHelper.IsProductionOrg();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = EmailTo;
        if(EmailCC != '')
            message.ccaddresses = new String[] { EmailCC };
        if(!isProduction)
            message.bccaddresses = new String[] { 'dsieraski@inprocorp.com', 'eleptich@inprocorp.com', 'bsibley@inprocorp.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = Body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            return 'The email was sent successfully.';
        } else {
            return 'The email failed to send: ' + results[0].errors[0].message;
        }
    } catch (Exception ex) {
        return 'The email was not sent successfully.';
    }
    }

    global class EmailSendDTO {        
        @InvocableVariable
        global ID UserId;
        @InvocableVariable
        global string ToEmail;        
        @InvocableVariable
        global string CCEmail;
        @InvocableVariable
        global string Subject;
        @InvocableVariable
        global string Body;
        @InvocableVariable
        global ID RecordId;    
        @InvocableVariable
        global string TemplateName;
        @InvocableVariable
        global boolean IncludeManager;
        @InvocableVariable
        global boolean SendFromSystemAccount;
      }

}