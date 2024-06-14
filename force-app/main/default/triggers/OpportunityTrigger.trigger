trigger OpportunityTrigger on Opportunity (before insert, after insert, after update) {

    
    // Allium - 2022-07-13 - Joe Bunda
    // Prior functionality moved to OpportunityTriggerHelper.afterUpdate().

    
    // Allium - 2022-06-29 - Joe Bunda
    if (trigger.isBefore) {

        if (trigger.isInsert) {
            if (OpportunityTriggerSingleFire.isBeforeInsertFirstRun()) {
                if (!Test.isRunningTest()) OpportunityTriggerHelper.beforeInsert(trigger.new);
            }
        }

    }



    if (trigger.isAfter) {

        if (trigger.isInsert) { 
            if (OpportunityTriggerSingleFire.isAfterInsertFirstRun()) {
                if (!Test.isRunningTest()) OpportunityTriggerHelper.afterInsert(trigger.new);
            }
        }

        if (trigger.isUpdate) {
            if (OpportunityTriggerSingleFire.isAfterUpdateFirstRun()) {
                if (!Test.isRunningTest()) OpportunityTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
                if (!Test.isRunningTest()) OpportunityContactRoleUtility.updateContactRolesForOpportunities(trigger.new);
            }
        }

        
    }

    
    for(Opportunity opp:Trigger.new)
    {
        if (Trigger.oldMap != null && Trigger.oldMap.get(opp.Id) != null)
        {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            CustomNotificationFromApex cn = new CustomNotificationFromApex();
            Set<String> recipientsIds = new Set<String>();
            
            try
            {
                if (opp.Auditor__c != null && 
                    opp.Estimating_Divisional_Status__c == 'Estimate Complete' && 
                    oldOpp.Estimating_Divisional_Status__c == 'In Audit')
                {
                    String oppNameSubject = (opp.Project_Number__c != null && opp.Project_Number__c != '' ? '(' + opp.Project_Number__c + ') ' : '') + opp.Name;
        
                    String Title = 'Take-Off Estimate Task Complete for ' + oppNameSubject;
                    String Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\">Opportunity: ' + opp.Name + '</a>' +   
                                opp.Name + '. Please review the Bid, Divisional Bidders and determine pricing.<br><br>';
                    
                    String notificationBody = 'Please review the Bid, Divisional Bidders and determine pricing. ';
        
                    Task task = [SELECT Id, Description, Audit_Needed__c, Auditor_Assigned__c 
                                FROM Task 
                                WHERE WhatId = :opp.Id AND Status = 'Completed' AND Auditor_Assigned__c != null
                                ORDER BY CreatedDate DESC 
                                LIMIT 1];
                    
                    string approvalComments = OpportunityTriggerHelper.updateAuditTaskDescription(opp);

                    Body += '<br><br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\">Task</a>' + '<br><br>'; 
                    Body += 'Comments: <br>' + task.Description;
                    notificationBody += 'Comments: ' + task.Description;    
                    
                    List<User> userList = [SELECT DelegatedApproverId, Email FROM User WHERE Id = :opp.OwnerId];
                    
                    if(userList.size() > 0)
                    {
                        string EmailTo = userList[0].Email;
                        string EmailCC = '';
        
                        recipientsIds.add(opp.OwnerId);

                        if(userList[0].DelegatedApproverId != null)
                        {
                            String deletegatedApproverId = userList[0].DelegatedApproverId;
                            User user = [SELECT Id, Email FROM User WHERE Id = :deletegatedApproverId];
                            EmailCC = user.Email;
                            recipientsIds.add(user.Id);
                        }
        
                        String targetId = task.Id;
        
                        cn.notifyUsers(recipientsIds, targetId, Title, notificationBody);   
                        EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                    }

                    //Notify auditee to complete quote

                    recipientsIds.clear();
                    recipientsIds.add(opp.Estimator__c);
                    string targetId = opp.Id;

                    User estimator = [SELECT Email FROM User WHERE Id = :opp.Estimator__c];
                    Title = 'Estimate Audit approved for ' + oppNameSubject;
                    Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\">Opportunity: ' + opp.Name + '</a>' +   
                                '<br><br> Please activate your quote under this opportunity.<br><br>Approval Notes: ' + approvalComments;
                    
                    notificationBody = 'Please activate your quote under this opportunity. Approval Notes: ' + approvalComments;

                    cn.notifyUsers(recipientsIds, targetId, Title, notificationBody);   
                        EmailSendHelper.sendEmail(estimator.Email, '', Title, Body);
                }
            }
            catch(Exception ex)
            {
                cn.notifyUsers(recipientsIds, opp.Id, 'Opp update Error', ex.getMessage() + '...' + ex.getStackTraceString());  

                recipientsIds.clear();
                recipientsIds.add([SELECT Id FROM User WHERE Name = 'Ben Sibley'].Id);
                EmailSendHelper.sendEmail([SELECT Id FROM User WHERE Name = 'Ben Sibley'].Email, '', 
                    'Opp update Error', ex.getMessage() + '...' + ex.getStackTraceString());
            }
        }
    }
}