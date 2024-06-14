public with sharing class EstimatingNoTakeoffHelper {

    @AuraEnabled
    public static string getTaskStatus(string recordId){
        try {
            Task task = [SELECT Id,Status FROM Task WHERE Id = :recordId];
            return task.Status;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updateOpportunityAndTask(string recordId, string cancelReason, string comments, string estimatingHours){
        try {
            Task task = [SELECT Id, WhatId, Status,Estimated_Time_to_perform_Takeoff__c,Task_Cancellation_Reason__c 
                         FROM Task 
                         WHERE Id = :recordId];

            Opportunity opportunity = [SELECT Id,Name, Construction_Project__c, Project_Number__c, OwnerId, Estimating_Divisional_Status__c,
                                              StageName, Estimating_Hours__c, No_Bid_Reason__c, Territory_Manager__c 
                                       FROM Opportunity 
                                       WHERE Id = :task.WhatId];

            User owner = [SELECT Id,Name,Email, Manager.Email, ManagerId 
                          FROM User 
                          WHERE Id = :opportunity.OwnerId];

            User territoryManager = [SELECT Id,Name,Email,ManagerId, Manager.Email 
                                     FROM User 
                                     WHERE Id = :opportunity.Territory_Manager__c];
            
            task.Estimated_Time_to_perform_Takeoff__c = decimal.valueOf(estimatingHours);
            task.Status = 'Canceled';
            task.Task_Cancellation_Reason__c = cancelReason;
            task.Description  = comments;
            update task;

            opportunity.Estimating_Divisional_Status__c = 'No Takeoff';
            opportunity.Estimating_No_Takeoff_Reason__c = comments;
            opportunity.Estimating_Hours__c = decimal.valueOf(estimatingHours);
            update opportunity;

            String subject = 'Take-Off Estimate Task Complete - No Takeoff - ' + 
                (opportunity.Project_Number__c != '' ? '(' + opportunity.Project_Number__c + ') ' : '' ) 
                + opportunity.Name;

            String body = UserInfo.getName() + ' has marked the Estimating task as no takeoff.' +
                        '<br><br><b>Reason:</b> ' + comments + 
                        '<br><br><a style=\'font-size:20px\' href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id  + '\'>View Opportunity</a>';
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            List<String> ccAddresses = new List<String>();

            /*if (opportunity.Construction_Project__c != null)
            {
                Construction_Project__c constructionProject = [SELECT Id, Sales_Estimating_Coordinator__c, Sales_Estimating_Coordinator__r.Email 
                                                               FROM Construction_Project__c 
                                                               WHERE Id = :opportunity.Construction_Project__c];

                if (constructionProject.Sales_Estimating_Coordinator__c != null)
                {
                    ccAddresses.add(constructionProject.Sales_Estimating_Coordinator__r.Email);
                }
            }*/
            if (territoryManager != null)
            {
                ccAddresses.add(territoryManager.Email);
            } 
            if (territoryManager.ManagerId != null && territoryManager.Manager.Email != null)
            {
                ccAddresses.add(territoryManager.Manager.Email);
            } 
            if (owner.ManagerId != null && owner.Manager.Email != null)
            {
                ccAddresses.add(owner.Manager.Email);
            } 

            message.toAddresses = new String[] { owner.Email };
            message.ccaddresses = ccAddresses;
            message.optOutPolicy = 'FILTER';
            message.subject = subject;
            message.htmlbody = body;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results;
            try {                           
             results = Messaging.sendEmail(messages);
            } catch (Exception ex) {
                return ex.getMessage() + ' - ' + ex.getStackTraceString();
            }
    
            if (results[0].success) {
                return '';
            } else {
                return 'The email failed to send: ' + results[0].errors[0].message;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}