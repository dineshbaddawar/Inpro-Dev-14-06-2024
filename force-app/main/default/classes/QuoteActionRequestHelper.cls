public with sharing class QuoteActionRequestHelper {
    @AuraEnabled
    public static string getQuoteAction(string TaskId){
        try {
            Quote_Action__c qa = [SELECT Id, QuoteId__c, OwnerId, Type__c, ApproverId__c, Subject__c, Comments__c, Status__c, TaskId__c FROM Quote_Action__c WHERE TaskId__c = :TaskId LIMIT 1];
            return JSON.serialize(qa);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getOpportunityEstimatingStatus(string QuoteId){
        String oppId = [SELECT Id, OpportunityId FROM Quote WHERE Id = :QuoteId].OpportunityId;
        String status = [SELECT Id, Estimating_Divisional_Status__c FROM Opportunity WHERE Id = :oppId].Estimating_Divisional_Status__c;

        return status;
    }
    @AuraEnabled
    public static string approveEstimateQuote(string QuoteId){
        Quote quote = [SELECT Id, Status, BidQuote__c, OpportunityId FROM Quote WHERE Id = :QuoteId];


        if (quote.BidQuote__c != 'Bid' && quote.BidQuote__c != 'Quote' && (quote.Status == 'Draft' || quote.Status == 'Rejected'))
        {
            Opportunity opp = [SELECT Name, Id,OwnerId, Estimating_Divisional_Status__c FROM Opportunity WHERE Id = :quote.OpportunityId];

            if(opp.Estimating_Divisional_Status__c != 'In Audit')
            {
                if (opp.Estimating_Divisional_Status__c != 'Estimate Complete')
                {
                    opp.Estimating_Divisional_Status__c = 'Estimate Complete';
                    update opp;
                }
                
                quote.Status = 'Approved';
                quote.Locked__c = true;
                update quote;


                string Title = 'Estimate Task Complete for ' + opp.Name;      
                string Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\">Opportunity: ' +
                 opp.Name + '</a><br><br>';    
                Body += 'Please review the Bid, Divisional Bidders and determine pricing.<br><br>';            
               
                Set<String> recipientsIds = new Set<String>();
                String targetId = opp.Id;                
                string opportunityOwnerId = opp.OwnerId;                       
                recipientsIds.add(opp.OwnerId);
                
                CustomNotificationFromApex cn = new CustomNotificationFromApex();

                List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :opportunityOwnerId];
                        
                if(userList.size() > 0)
                {
                    string EmailTo = userList[0].Email;
                    string EmailCC = '';
                   
                    
                    if(userList[0].DelegatedApproverId != null)
                    {
                        String deletegatedApproverId = userList[0].DelegatedApproverId;                        
                        User user = [SELECT Id, Email  FROM User  WHERE Id = :deletegatedApproverId];
                        EmailCC = user.Email;
                        recipientsIds.add(user.Id);
                    }

                    cn.notifyUsers(recipientsIds, targetId, Title, Body);   
                    EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                }

                return 'Success';
            }
            else {
                return 'Quotes tied to an opportunity that is "In Audit" status cannot be activated.';
            }
        }
        else{
            return 'This is not an estimate quote - no action taken.';
        }
    }

    @AuraEnabled
    public static string getQuoteLineItemsWithSignSchedules(string QuoteId){
        try {
            List<QuoteLineItem> qlis = [SELECT Id, QuoteId, SignScheduleId__c,Description,Description_2__c,Item_Number__c,Quantity 
                                        FROM QuoteLineItem 
                                        WHERE QuoteId = :QuoteId AND SignScheduleId__c != null];
            return JSON.serialize(qlis);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getQuoteName(string QuoteId)
    {
        try {
            String Query = 'SELECT QuoteNumber, Name, Account_Name_Formula__c FROM Quote WHERE Id = :QuoteId LIMIT 1';
            Quote quote = (Quote)Database.query(Query);
            return quote.Name + ' - ' + quote.Account_Name_Formula__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getQuoteStatus(string QuoteId){
        String Query = 'SELECT Status FROM Quote WHERE Id = :QuoteId LIMIT 1';
        Quote quote = (Quote)Database.query(Query);
        return quote.Status;
    }

    @AuraEnabled
    public static string getUsers(){
        try {
            String Query = 'SELECT FirstName, LastName, Username, Id FROM User where IsActive = true ORDER BY Username';
            sObject[] results = Database.query(Query);
            return JSON.serialize(results);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> userSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';      
        String Query = 'select id, name, username from user where name like :key';

        Query += ' LIMIT 50';
        // Prepare results
        List < LookupSearchResult > results = new List < LookupSearchResult > ();

        String userIcon = 'standard:user';
        for (sObject so: Database.Query(Query)) {

            String fullname = (String)so.get('name');
            String userId = (String) so.get('id');
            String subtitle = (String)so.get('username');
                
            results.add(new LookupSearchResult(userId, 'user', userIcon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static string createIllustrationChangeRequest(string QuoteId, string OrderNumber, string Comments, string Selected){
        try {
            if (Selected != null && Selected != '')
            {
                string subject = 'Illustration Change Requested By: ' + UserInfo.getName() + ' (' + OrderNumber + ')';

                Task tsk = new Task();
                tsk.Subject = subject;
                tsk.Status = 'Open';
                tsk.Priority = 'Normal';
                tsk.WhatId = QuoteId;
                tsk.Description = 'Requester comments: ' + Comments + '\r\n\r\n Pending manufacturing approval or rejection.';
                tsk.OwnerId = UserInfo.getUserId();
                tsk.Type = 'Illustration Change Request';
                string taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Quote Action Request').getRecordTypeId();
                tsk.RecordTypeId = taskRecordTypeId;
                insert tsk;
    
                Quote_Action__c quoteAction = new Quote_Action__c();
                quoteAction.Name = subject;
                quoteAction.QuoteId__c = QuoteId;
                quoteAction.Type__c = 'Illustration Change Request';
                quoteAction.Requester_Comments__c = Comments;
                quoteAction.Order_Number__c = OrderNumber;
                quoteAction.OwnerId = UserInfo.getUserId();
                quoteAction.Status__c = 'Pending';
                quoteAction.TaskId__c = tsk.Id;
                quoteAction.QuoteLineItemIds__c = Selected;
                insert quoteAction;

                sendSSManufacturingEmail(tsk.Id, 2);
                
                return 'Task created successfully and Email sent.';
            }else{
                throw new AuraHandledException('A Sign Schedule does not exist for this Quote');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createSignScheduleChangeRequest(string QuoteId, string OrderNumber, string Comments){
        try {
            QuoteLineItem qli = [SELECT Id, SignScheduleId__c, QuoteId FROM QuoteLineItem WHERE QuoteId = :QuoteId LIMIT 1];
            if (qli != null)
            {
                string subject = 'Sign Schedule Change Requested By: ' + UserInfo.getName() + ' (' + OrderNumber + ')';

                Task tsk = new Task();
                tsk.Subject = subject;
                tsk.Status = 'Open';
                tsk.Priority = 'Normal';
                tsk.WhatId = QuoteId;
                tsk.Description = Comments;
                tsk.OwnerId = UserInfo.getUserId();
                tsk.Type = 'Sign Schedule Change Request';
                string taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Quote Action Request').getRecordTypeId();
                tsk.RecordTypeId = taskRecordTypeId;
                insert tsk;
    
                Quote_Action__c quoteAction = new Quote_Action__c();
                quoteAction.Name = subject;
                quoteAction.QuoteId__c = QuoteId;
                quoteAction.Type__c = 'Sign Schedule Change Request';
                quoteAction.Requester_Comments__c = Comments;
                quoteAction.Order_Number__c = OrderNumber;
                quoteAction.OwnerId = UserInfo.getUserId();
                quoteAction.Status__c = 'Pending';
                quoteAction.TaskId__c = tsk.Id;
                insert quoteAction;

                sendSSManufacturingEmail(tsk.Id, 1);
                
                return 'Task created successfully and Email sent.';
            }else{
                throw new AuraHandledException('A Sign Schedule does not exist for this Quote');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string sendSSManufacturingEmail(string TaskId, Integer requestType)
    {
        Quote_Action__c qa = [SELECT Id, Comments__c, Order_Number__c, TaskId__c, Requester_Comments__c FROM Quote_Action__c WHERE TaskId__c = :TaskId LIMIT 1];

        string ssManufacturingEmail = 'SSManufacturingApprovers@inprocorp.com';
        string port = '34815';
        Boolean isBeta = true;

        if (URL.getSalesforceBaseUrl().toExternalForm().indexOf('beta') == -1)
        {
            isBeta = false;
            port = '34915';
        }

        string subject = '';
        string body = '';
        if (requestType == 1)
        {
            subject = 'Sign Schedule Change Requested By: ' + UserInfo.getName() + ' (' + qa.Order_Number__c + ')';
            body = UserInfo.getName() + ' has requested to change the Sign Schedule for Order Number: ' + qa.Order_Number__c +
                                            '<br><br>Requested On: ' + Datetime.now().format('MM-dd-YYYY') + '<br><br>'
                                            + '<a style=\'font-size:20px\' href=\'https://sl.inprocorp.com:' + port + '/SignScheduleChangeRequest/Approve?quoteActionId=' + qa.Id +'\'>Approve Request</a>' + '<br><br>'
                                            + '<a style=\'font-size:20px\' href=\'https://sl.inprocorp.com:' + port + '/SignScheduleChangeRequest/Reject?quoteActionId=' + qa.Id +'\'>Reject Request</a>' + '<br><br>'
                                            //+ '<a style=\'font-size:20px\' href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + qa.TaskId__c  + '\'>View Request (Salesforce Users Only)</a>' + '<br><br>'
                                            + 'Notes:<br>' + qa.Comments__c;
        }
        else if (requestType == 2)
        {
            subject = 'Illustration Change Requested By: ' + UserInfo.getName() + ' (' + qa.Order_Number__c + ')';
            body = UserInfo.getName() + ' has requested Illustration Changes for Order Number: ' + qa.Order_Number__c +
                                            '<br><br>Requested On: ' + Datetime.now().format('MM-dd-YYYY') + '<br><br>'
                                            + '<a style=\'font-size:20px\' href=\'https://sl.inprocorp.com:' + port + '/IllustrationChangeRequest/Index?quoteActionId=' + qa.Id +'\'>View Request</a>' + '<br><br>'
                                            //+ '<a style=\'font-size:20px\' href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + qa.TaskId__c  + '\'>View Request (Salesforce Users Only)</a>' + '<br><br>'
                                            + 'Notes:<br>' + qa.Requester_Comments__c;
        }
        
        

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.bccaddresses = new String[] { 'bsibley@inprocorp.com' };
        message.ccaddresses = new String[] { UserInfo.getUserEmail() };
        message.toaddresses = new String[] { ssManufacturingEmail };
        if (isBeta)
        {
            message.subject = 'Sandbox: ' + subject;
        }
        else{
            message.subject = subject;
        }
        
        message.htmlbody = body;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        if (!Test.isRunningTest()) Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        return 'Success';
    }

    @AuraEnabled
    public static string createQuoteAction(string QuoteId, string Type, string OrderNumber, string Comments, string ApprovingManagerId, string RouteType,string AssignUserId){
        try {
            if (Type == '')
            {
                return 'Quote Action type not provided!';
            }
            if (AssignUserId == '')
            {
                return 'Assignee not provided!';
            }
            User createdBy = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            String quoteName = getQuoteName(QuoteId);
            String taskDescription = '- Add part number(s) through action button on top of page or in the comments section. \r\n';

            //Create task
            Task tsk = new Task();
            tsk.Subject = 'Custom Part Number Request - ' + quoteName;
            tsk.Status = 'Open';
            tsk.Priority = 'Normal';
            tsk.WhatId = QuoteId;
            tsk.OwnerId = AssignUserId;
            tsk.CreatedBy = createdBy;

            if (ApprovingManagerId != '')
            {
                User approver = [SELECT Id, FirstName, LastName FROM User WHERE Id = :AssignUserId];
                taskDescription += '- Notify manager, ' + approver.FirstName + ' ' + approver.LastName +
                                  ', by clicking on the Notify button. \r\n' +
                                  '- Approving manager, approve by clicking Mark Complete or reject by clicking the Reject button.';
            }
            else{
                taskDescription += '- Click on the Mark Complete on the quote action to complete this task.';
            }

            if (Comments != '')
            {
                taskDescription += '\r\n======\r\n' + 'Comments provided by requester: ' + Comments;
            }
            
            tsk.Description = taskDescription;

            tsk.Type = 'Quote Action Request';
            string taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Quote Action Request').getRecordTypeId();
            tsk.RecordTypeId = taskRecordTypeId;
            tsk.ActivityDate = Date.today().addDays(1);
            insert tsk;

            Quote_Action__c quoteAction = new Quote_Action__c();
            quoteAction.Name = 'Custom Part Number Request [' + QuoteId + ']';
            quoteAction.QuoteId__c = QuoteId;
            quoteAction.Type__c = Type;
            quoteAction.Comments__c = Comments;
            quoteAction.OwnerId = AssignUserId;
            quoteAction.Status__c = 'Pending';
            quoteAction.TaskId__c = tsk.Id;
            quoteAction.Order_Number__c = OrderNumber;
            quoteAction.CreatedBy = createdBy;

            if (ApprovingManagerId != '') //Manager logic
            {
                quoteAction.ApproverId__c = ApprovingManagerId;
            }

            insert quoteAction;

            return JSON.serialize(tsk);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void completeQuoteAction(string id){ //for THG's QuoteAndBidController
        try {
            completeQuoteAction(id,'');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void completeQuoteAction(string TaskId, string Notes){
        try {
            Quote_Action__c qa = [SELECT Id, QuoteId__c, ApproverId__c, Comments__c, TaskId__c FROM Quote_Action__c WHERE TaskId__c = :TaskId LIMIT 1];
            qa.Status__c = 'Complete';

            Task task = [SELECT Id, Description, Subject, OwnerId FROM Task WHERE Id = :TaskId];

            if (qa.ApproverId__c != null)
            {
                qa.Comments__c = '(' + getCurrentLocalTime() + ') APPROVED, NOTES: ' + Notes + '\r\n======\r\n' + qa.Comments__c;
                task.Description = '(' + getCurrentLocalTime() + ') APPROVED, NOTES: ' + Notes + '\r\n======\r\n' + task.Description;
            }
            else
            {
                qa.Comments__c = '(' + getCurrentLocalTime() + ') COMPLETED' + '\r\n======\r\n' + qa.Comments__c;
                task.Description = '(' + getCurrentLocalTime() + ') COMPLETED' + '\r\n======\r\n' + task.Description;
            }
            
            update qa;

            task.Status = 'Completed';
            update task;

            User owner = [SELECT Id, Email FROM User WHERE Id = :task.OwnerId];

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.bccaddresses = new String[] { 'bsibley@inprocorp.com' };
            message.ccaddresses = new String[] { UserInfo.getUserEmail() };
            message.toaddresses = new String[] { owner.Email };

            if (qa.ApproverId__c != null)
            {
                User approver = [SELECT Id, Email FROM User WHERE Id = :qa.ApproverId__c];
                message.toaddresses.add(approver.Email);
            }
            message.subject = task.Subject + ' has been completed by ' + UserInfo.getName();
            message.htmlbody = '<a style=\'font-size:20px\' href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + qa.TaskId__c  + '\'>View Request</a><br><br>Comments: <br>' + task.Description.replace('======','<br>======<br>');
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            
            if (!Test.isRunningTest()) Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void rejectQuoteAction(string TaskId, string Notes){
        try {
            String Query = 'SELECT Id, QuoteId__c, Comments__c, TaskId__c FROM Quote_Action__c WHERE TaskId__c = :TaskId LIMIT 1';
            Quote_Action__c qa = (Quote_Action__c)Database.query(Query);
            qa.Comments__c = '(' + getCurrentLocalTime() + ') REJECTION NOTES: ' + Notes + '\r\n======\r\n' + qa.Comments__c;
            qa.Status__c = 'Rejected';
            update qa;

            Task task = [SELECT Id, Description FROM Task WHERE Id = :TaskId LIMIT 1];
            task.Description = '(' + getCurrentLocalTime() + ') REJECTION NOTES: ' + Notes + '\r\n======\r\n' + task.Description;
            update task;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateQuoteActionPending(string TaskId){
        try {
            String Query = 'SELECT Id, QuoteId__c, Comments__c, TaskId__c FROM Quote_Action__c WHERE TaskId__c = :TaskId LIMIT 1';
            Quote_Action__c qa = (Quote_Action__c)Database.query(Query);
            qa.Comments__c = '(' + getCurrentLocalTime() + ') Approver Notified. ' + '\r\n======\r\n' + qa.Comments__c;
            qa.Status__c = 'Pending';
            update qa;

            Task task = [SELECT Id, Description FROM Task WHERE Id = :TaskId LIMIT 1];
            task.Description = '(' + getCurrentLocalTime() + ') Approver Notified. ' + '\r\n======\r\n' + task.Description;
            update task;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static string getCurrentLocalTime()
    {
        return Datetime.now().format('MM/dd/yyyy h:mm a');
    }
}