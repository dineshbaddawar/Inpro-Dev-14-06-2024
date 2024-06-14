trigger TaskBeforeUpdateTrigger on Task (before update) {
    for(Task task:Trigger.new)
    {
        if(task.Status == 'Completed' && Trigger.oldMap.get(task.Id).Status != 'Completed' && WebserviceTriggerProxy.firstRun)
        {
            Task oldTask = Trigger.oldMap.get(task.Id);
            if (task.Type == 'SDR')
            {
                task.Description = '===COMMENTS ON COMPLETE===\r\n\r\n' + task.Description + '\r\n\r\n' + '===COMMENTS BEFORE COMPLETE===\r\n\r\n' + oldTask.Description;

                //Ensure this doesn't exceed the long text area character limit
                if (task.Description.length() > 32000) task.Description = task.Description.substring(0, 32000);
            }
            else if(task.Type == 'Quote Action Request')
            {
                Quote_Action__c qa = [SELECT Id, ApproverId__c, Status__c, Comments__c FROM Quote_Action__c WHERE TaskId__c = :task.Id LIMIT 1];
                
                if(qa != null)
                {

                    if (qa.ApproverId__c != null && UserInfo.getUserId() != qa.ApproverId__c)
                    {
                        User approver = [SELECT FirstName, LastName, Id FROM User WHERE Id = :qa.ApproverId__c LIMIT 1];
                        
                        task.addError('This task can only be Marked Complete by the Approver, ' + approver.FirstName + ' ' + approver.LastName + '. Please click on the Notify button.');
                    }

                    task.Description = '(' + Datetime.now().format('MM/dd/yyyy h:mm a') + ') Completed by ' + UserInfo.getName() + '.\r\n======\r\n' + task.Description;
                    
                    qa.Status__c = 'Complete';
                    qa.Comments__c = '(' + Datetime.now().format('MM/dd/yyyy h:mm a') + ') Completed by ' + UserInfo.getName() + '.\r\n======\r\n' + qa.Comments__c;
                    
                    update qa;
                }
            }
            else if (task.Type == 'Illustration Change Request' || task.Type == 'Sign Schedule Change Request')
            {
                Quote_Action__c qa = [SELECT Id, ApproverId__c, Status__c FROM Quote_Action__c WHERE TaskId__c = :task.Id LIMIT 1];
                 if(qa != null)
                    if (qa.Status__c != 'Complete')
                    {
                        task.addError('This task can only be completed by Manufacturing.');
                    }
            }
        }
        else if (task.Status == 'Open' && Trigger.oldMap.get(task.Id).Status == 'Completed')
        {
            if(task.Type == 'Quote Action Request')
            {
                task.Description = '(' + Datetime.now().format('MM/dd/yyyy h:mm a') + ') Reopened by ' + UserInfo.getName() + '.\r\n======\r\n' + task.Description;
                Quote_Action__c qa = [SELECT Id, ApproverId__c, Status__c, Comments__c FROM Quote_Action__c WHERE TaskId__c = :task.Id LIMIT 1];
                if(qa != null)
                {
                    qa.Status__c = 'Pending';
                    qa.Comments__c = '(' + Datetime.now().format('MM/dd/yyyy h:mm a') + ') Reopened by ' + UserInfo.getName() + '.\r\n======\r\n' + qa.Comments__c;
                    
                    update qa;
                }
            }
        }
    }
}