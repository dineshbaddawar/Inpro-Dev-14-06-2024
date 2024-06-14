trigger TaskPostCreateTrigger on Task (after insert) {

   if(trigger.isAfter) 
    for(Task task:Trigger.new)
    {
        string Title = '';
        string  Body = '';
        EmailSendHelper emailHelper = new EmailSendHelper();
        if(task.Type != null && task.Type == 'Quote Action Request')
        {
            if (task.Subject != null && task.Subject.startsWith('Custom Part Number Request')) 
            {        
                try 
                {
                    List<String> toEmails = new List<String>();
                    List<User> ownerList = [SELECT DelegatedApproverId, Email, Name  FROM User  WHERE Id = :task.ownerid LIMIT 1];
                    List<User> createdbyList = [SELECT DelegatedApproverId, Email, Name  FROM User  WHERE Id = :task.createdbyid LIMIT 1];
                   
                    toEmails.add(ownerList[0].Email);

                    if(ownerList[0].DelegatedApproverId != null)
                    {
                        String deletegatedApproverId = ownerList[0].DelegatedApproverId;
                        String BackupEmail = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId LIMIT 1].Email;
                        toEmails.add(BackupEmail);
                    }                               

                    Title = 'New Custom Part Number Request from ' + createdbyList[0].Name;                
                    Body += 'Please review the custom part number request below.<br><br>';                
                    Body += 'Comments: ' + task.Description;
                    Body += '<br><br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">'+task.Subject+'</a>'; 
                    EmailSendHelper.sendEmailMultipleRecipients(toEmails, createdbyList[0].Email, Title, Body);                                                         
                } 
                catch (Exception ex) {
                    
                }   
            }
        }

        if(task.Type != null && task.Type == 'Manager Pricing Request')
        {
            try {
                List<String> toEmails = new List<String>();
                List<User> ownerList = [SELECT DelegatedApproverId, Email, Name  FROM User  WHERE Id = :task.ownerid LIMIT 1];
                toEmails.add(ownerList[0].Email);
                if(ownerList[0].DelegatedApproverId != null)
                {    
                    String deletegatedApproverId = ownerList[0].DelegatedApproverId;           
                    String BackupEmail = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId LIMIT 1].Email;
                    toEmails.add(BackupEmail);
                }
                List<User> createdbyList = [SELECT DelegatedApproverId, Email, Name  FROM User  WHERE Id = :task.createdbyid LIMIT 1];
                Title = 'New Custom Pricing Request from '+ createdbyList[0].Name;                
                Body += 'Please review the custom pricing request below.<br><br>';            
                Body +=  'Comments: ' + task.Description;
                Body += '<br><br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">'+task.Subject+'</a>'; 
                EmailSendHelper.sendEmailMultipleRecipients(toEmails, createdbyList[0].Email, Title, Body);
            } catch (Exception ex) {
                 
            }
        }
    }
}