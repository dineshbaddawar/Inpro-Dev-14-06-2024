trigger TaskTrigger on Task (after update, before insert) {
    for(Task task:Trigger.new)
    {
        if(trigger.isAfter && trigger.isUpdate)
        {
            if(WebserviceTriggerProxy.firstRun)
            {
                Task oldTask = Trigger.oldMap.get(task.Id);
                CustomNotificationFromApex cn = new CustomNotificationFromApex();
                Set<String> recipientsIds = new Set<String>();

                if(task.Status == 'Completed' && oldTask.Status != 'Completed')
                {
                    //WebserviceTriggerProxy.firstRun = false;
                    if(task.Type == 'SDR' || task.Type == 'Estimating Task')
                    {
                        string whatId = task.WhatId;
                        Opportunity opp = [SELECT Name, Id, Project_Number__c, StageName, Territory_Manager__c, Rating__c, 
                                                  OwnerId, Estimating_Divisional_Status__c, Auditor__c, Division__c
                                           FROM Opportunity 
                                           WHERE Id = :whatId LIMIT 1];
                        Quote quote;
                        
                        if (opp == null) //related to changed to quote
                        {
                            quote = [SELECT Name, Id, OpportunityId, Version_Description__c FROM Quote WHERE Id = :whatId LIMIT 1];
                            opp =  [SELECT Name, Id, StageName, Rating__c, OwnerId, Estimating_Divisional_Status__c, Auditor__c, Division__c
                                    FROM Opportunity 
                                    WHERE Id = :quote.OpportunityId LIMIT 1];
                        }
                        //Tasks will autocomplete on close of an opp - don't fire off emails in this case
                        if (opp.StageName != 'Closed Lost' && opp.StageName != 'Closed Won' && opp.StageName != 'Closed No Bid' &&
                            (opp.Auditor__c == null || (opp.Auditor__c != null && opp.Estimating_Divisional_Status__c == 'Estimate Complete')))
                        {
                            String Title = '';
                            String Body = '';        
                            String notificationBody = '';
                            recipientsIds = new Set<String>();
                            String targetId = task.Id;
                            string userId = task.CreatedById; 
                            string opportunityOwnerId = opp.OwnerId;                       
                            recipientsIds.add(userId);
                            
                            String oppNameSubject = (opp.Project_Number__c != null && opp.Project_Number__c != '' ? '(' + opp.Project_Number__c + ') ' : '') + opp.Name;

                            if (task.Estimate_Type__c != null && task.Estimate_Type__c == 'SDR'){
                                Title = 'SDR Estimate Task Complete for ' + oppNameSubject;
                                Body = 'Please use this link to get the appropriate Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '">' + opp.Name + '</a><br><br>';
                                    
                                if (quote != null)
                                {
                                    Body += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + quote.Id + '">' + quote.Name + '</a><br><br>' +
                                            'Version Description: ' + quote.Version_Description__c + '<br><br>';
                                    notificationBody += quote.Name + ', Version Description: ' + quote.Version_Description__c + '.';
                                }
                                Body += 'Confidence Level: ' + opp.Rating__c + '<br><br>';
                                notificationBody += ' Confidence Level: ' + opp.Rating__c;

                                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">Task</a>' + '<br><br>'; 

                                Body += 'Comments: <br>' + task.Description + '<br><br>'; 
                                notificationBody += ' ' + task.Description;

                                Body += 'Shop drawings can be found in the Opportunity Files section (if present).';
                                notificationBody += 'Shop drawings can be found in the Opportunity Files section (if present).';

                            }
                            else if (task.Type == 'Estimating Task' && task.Estimate_Type__c == 'Revision'){
                                Title = 'ESR Estimate Task Complete for ' + oppNameSubject;

                                Body = 'Please use this link to get the appropriate Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '">' + opp.Name + '</a><br><br>';
                                    
                                if (quote != null)
                                {
                                    Body += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + quote.Id + '">' + quote.Name + '</a><br><br>' +
                                            'Version Description: ' + quote.Version_Description__c + '<br><br>';
                                    notificationBody += quote.Name + ', Version Description: ' + quote.Version_Description__c + '.';
                                }
                                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">Task</a><br><br>';
                                Body += 'Confidence Level: ' + opp.Rating__c + '<br><br>';
                                Body += 'Comments: <br>' + task.Description;
                                notificationBody += 'Confidence Level: ' + opp.Rating__c + '. ';
                                notificationBody += 'Comments: ' + task.Description;
                            }
                            else if (task.Type == 'Estimating Task' && task.Estimate_Type__c == 'New' && opp.Auditor__c == null || opp.Auditor__c != null && opp.Estimating_Divisional_Status__c == 'Estimate Complete'){
                                Title = 'Take-Off Estimate Task Complete for ' + oppNameSubject;
                                Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\">Opportunity: ' + opp.Name + '</a><br><br>';    
                                Body += opp.Name + '. Please review the Bid, Divisional Bidders and determine pricing.<br><br>';
                                notificationBody += 'Please review the Bid, Divisional Bidders and determine pricing. ';
                                Body += '<br><br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">Task</a>' + '<br><br>'; 
                                Body += 'Comments: <br>' + task.Description;
                                notificationBody += 'Comments: ' + task.Description;         
                            }
                            else{
                                Title = 'Estimate Task Complete for ' + oppNameSubject;      
                                Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\">Opportunity: ' + opp.Name + '</a><br><br>';    
                                notificationBody += opp.Name + '. ';
                                Body += 'Please review the Bid, Divisional Bidders and determine pricing.<br><br>';
                                notificationBody += 'Please review the Bid, Divisional Bidders and determine pricing. ';
                                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">Task</a>' + '<br><br>';
                                Body += 'Comments: <br>' + task.Description;
                                notificationBody += 'Comments: ' + task.Description;
                            }                   
                            List<User> userList = new List<User>();
                            if(opp.Division__c != null && opp.Division__c == 'SignScape')
                            {
                                userList = [SELECT DelegatedApproverId, Email, UserRole.Name FROM User WHERE Id = :userId];
                                if(userList.size() > 0)
                                {
                                    if(userList[0].UserRole != null && userList[0].UserRole.Name != null && userList[0].UserRole.Name != null)
                                    {
                                        if(userList[0].UserRole.Name == 'CCS' || userList[0].UserRole.Name == 'SEC')
                                            userList = [SELECT DelegatedApproverId, Email FROM User WHERE Id = :opportunityOwnerId];
                                    }
                                }
                            }
                            else {
                                userList = [SELECT DelegatedApproverId, Email FROM User WHERE Id = :opportunityOwnerId];
                            }
                            
                            if(userList.size() > 0)
                            {
                                string EmailTo = userList[0].Email;
                                string EmailCC = '';

                                if(task.Audit_Needed__c && task.Auditor_Assigned__c != null)
                                {
                                    User user = [SELECT Id, Email FROM User WHERE Id = :task.Auditor_Assigned__c];
                                    EmailTo = user.Email;
                                    //remove the sales rep for estimating audit tasks
                                    recipientsIds.clear();
                                    recipientsIds.add(user.Id);
                                }
                                if(userList[0].DelegatedApproverId != null)
                                {
                                    String deletegatedApproverId = userList[0].DelegatedApproverId;
                                    User user = [SELECT Id, Email FROM User WHERE Id = :deletegatedApproverId];
                                    EmailCC = user.Email;
                                    recipientsIds.add(user.Id);
                                }

                                cn.notifyUsers(recipientsIds, targetId, Title, notificationBody);   
                                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);

                            }
                        }
                    }
                    else if(task.Type == 'Quote Request' || task.Type == 'Doc Update')
                    {
                        String relatedToId = task.WhatId;

                        if(relatedToId != null && (relatedToId.startsWith('006') || relatedToId.startsWith('0Q0')))
                        {
                            recipientsIds = new Set<String>();
                            String targetId = task.Id;
                            String recipientId = '';
                            
                            //related to an opp
                            if(relatedToId.startsWith('006'))
                            {
                                List<Opportunity> oppList = [SELECT OwnerId, Estimator__c  FROM Opportunity WHERE Id = :relatedToId];
                                if(oppList.size() > 0)
                                {
                                    if(oppList[0].OwnerId != null && task.Type != 'Doc Update')
                                    {
                                        recipientId = oppList[0].OwnerId;
                                        recipientsIds.add(recipientId);
                                    }
                                    if(oppList[0].Estimator__c != null && task.Type == 'Doc Update')
                                    {
                                        recipientId = oppList[0].Estimator__c;  
                                        recipientsIds.add(recipientId);                             
                                    }
                                } 
                            }
                            //related to a quote
                            else if (relatedToId.startsWith('0Q0'))
                            {
                                List<Quote> quoteList = [SELECT Opportunity.OwnerId  FROM Quote WHERE Id = :relatedToId];
                                if(quoteList.size() > 0)
                                {
                                    if(quoteList[0].Opportunity.OwnerId != null)
                                    {
                                        recipientId = quoteList[0].Opportunity.OwnerId;
                                        recipientsIds.add(recipientId);
                                    }
                                } 
                            }
                            
                            if(recipientId != '')
                            {
                                //lookup backup
                                List<User> backupList = [SELECT DelegatedApproverId  FROM User WHERE Id = :recipientId];
                                if(backupList.size() > 0)
                                {
                                    if(backupList[0].DelegatedApproverId != null)
                                        recipientsIds.add(backupList[0].DelegatedApproverId);
                                }

                                String Title = task.Type + ' Task Complete';
                                String Body =  task.Subject + ' completed, see it by clicking here.';                     
                                cn.notifyUsers(recipientsIds, targetId, Title, Body);
                                
                            }
                        }
                    }
                    else if((task.LastModifiedById != task.CreatedById) && ((task.Type == 'Account Detail Change' || task.Type == 'Credit Terms Change' || task.Type == 'Line of Credit Change') || task.Type == 'Install' || (task.Type == 'Quote Action Request' && task.Subject.contains('Custom Part Number Request')) || task.Type == 'Manager Pricing Request'))
                    {                
                        String Title = '';
                        String Body = '';        
                        recipientsIds = new Set<String>();
                        String targetId = task.Id;    
                        string userId = task.CreatedById;         
                        recipientsIds.add(userId);
                        if(task.Auditor_Assigned__c != null)
                            recipientsIds.add(task.Auditor_Assigned__c); 
                        
                        if(task.Type != null)
                            Title = task.Type + ' Task Complete';
                        else {
                            Title = 'Task Complete';
                        }
                        Body =  task.Subject + ' completed, see it by clicking here.';                     
                        cn.notifyUsers(recipientsIds, targetId, Title, Body);     
                        
                        List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :userId];

                        if(userList.size() > 0)
                        {                    
                            string EmailTo = userList[0].Email;
                            string EmailCC = '';
                            string deletegatedApproverId = userList[0].DelegatedApproverId;
                            if(deletegatedApproverId != null)
                            {
                                EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;
                            }

                            string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id;  
                                    
                                Body = Body + 
                                '<br><a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + task.Subject + '</a>';
                                if(task.Type != null && (task.Type == 'Account Detail Change' || task.Type == 'Credit Terms Change' || task.Type == 'Line of Credit Change') && task.WhatId != null)
                                {
                                    string accountUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.WhatId;  
                                    Body = Body + 
                                        '<br><a style=\"font-size:20px\" href=\"' + accountUrl + '\">Account</a>';
                                }
                
                            EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                        }
                    }            
                }   
            }
                           
            //Assign the Opp Estimator if the owner changes on a new estimate task
            Task oldTask = Trigger.oldMap.get(task.Id);
            if(task.Type == 'Estimating Task' && task.OwnerId != oldTask.OwnerId && task.Estimate_Type__c == 'New' && 
               task.OwnerId.getSobjectType() == User.getSObjectType())
            {
                string whatId = task.WhatId;
                List<Opportunity> oppList = [SELECT Id, Estimator__c FROM Opportunity WHERE Id = :whatId LIMIT 1];
                if(oppList.size() != 0)
                {
                    Opportunity opp = oppList[0];
                    opp.Estimator__c = task.OwnerId;

                    update opp;
                }
            }
        }
        if(trigger.isBefore && trigger.isInsert)
        {          
            if(task.RecordTypeId == Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CCS_Request').getRecordTypeId())
            {
                Date d = System.today();
                Datetime dt = (DateTime)d;
                String dayOfWeek = dt.format('EEEE');
                if(task.Type == 'Submittals' || task.Type == 'CSR Request')
                {
                    if(dayOfWeek == 'Sunday')
                         task.ActivityDate = system.Date.today().addDays(2);
                    else if (dayOfWeek == 'Monday')
                        task.ActivityDate = system.Date.today().addDays(2);
                    else if (dayOfWeek == 'Tuesday')
                        task.ActivityDate = system.Date.today().addDays(2);
                    else if (dayOfWeek == 'Wednesday')
                        task.ActivityDate = system.Date.today().addDays(2);
                    else if (dayOfWeek == 'Thursday')
                        task.ActivityDate = system.Date.today().addDays(2);
                    else if (dayOfWeek =='Friday')
                        task.ActivityDate = system.Date.today().addDays(4);
                    else if (dayOfWeek == 'Saturday')
                        task.ActivityDate = system.Date.today().addDays(3);
                    else {
                        task.ActivityDate = system.Date.today().addDays(0);    
                    }                    
                }
                else 
                {
                    if(dayOfWeek == 'Sunday')
                        task.ActivityDate = system.Date.today().addDays(1);
                    else if (dayOfWeek == 'Monday')
                        task.ActivityDate = system.Date.today().addDays(1);
                    else if (dayOfWeek == 'Tuesday')
                        task.ActivityDate = system.Date.today().addDays(1);
                    else if (dayOfWeek == 'Wednesday')
                        task.ActivityDate = system.Date.today().addDays(1);
                    else if (dayOfWeek == 'Thursday')
                        task.ActivityDate = system.Date.today().addDays(1);
                    else if (dayOfWeek == 'Friday')
                        task.ActivityDate = system.Date.today().addDays(3);
                    else if (dayOfWeek == 'Saturday')
                        task.ActivityDate = system.Date.today().addDays(2);
                    else {
                        task.ActivityDate = system.Date.today().addDays(0);    
                    }
                }
            }
        }
    }    
}