public inherited sharing class OrderRequestRouteHelper {
    
    @AuraEnabled()
    public static List<User> RetrieveUserInfo(String userId){    
        string oQuery =  'SELECT Name, Id, Profile.Name FROM User WHERE Id = :userId LIMIT 1';
        List<User> users = Database.query(oQuery);              
        return users; 
    }

    @AuraEnabled()
    public static List<Order_Request__c> RetrieveRecordInfo(String recordId){    
        string oQuery =  'SELECT Name, Id, Order_Request_Comments__c, Approval_Status__c, Requires_Over_Contract_Approval__c, CreatedById FROM Order_Request__c WHERE Id = :recordId LIMIT 1';
        List<Order_Request__c> orders = Database.query(oQuery);              
        return orders; 
    }

    @AuraEnabled()
    public static string UpdateOrderRequestStatusAndNotes(String status, String recordId, String orderRequestComments, Boolean updateStatus){    
        try 
        {
            Order_Request__c o = new Order_Request__c();
            o.Id = recordId;
            if(updateStatus == true)
                o.Approval_Status__c = status;

            if(orderRequestComments != null && orderRequestComments != '')
                o.Order_Request_Comments__c = orderRequestComments;

            update o;
            return 'Success!';
        } 
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled()
    public static string RouteOrderRequest(String recordId, String action, String userName, String userId, String orderRequestComments, String userComments, Boolean requiresOverContractApproval, String createdById){    
       if(action == 'Approve')
       {
            String queueName = 'Customer Care Queue';

            string rQuery =  'SELECT Id, Account__r.BillingCountry FROM Order_Request__c WHERE Id = :recordId';
            List<Order_Request__c> orderRequests = Database.query(rQuery);
            if(orderRequests.size() > 0)
            {
                Order_Request__c request = orderRequests[0];
                if(request.Account__r != null && request.Account__r.BillingCountry != 'United States' && request.Account__r.BillingCountry != 'US')
                    queueName = 'International Queue';
            }

            string oQuery =  'SELECT Id FROM Group WHERE Name = :queueName';
            List<Group> queues = Database.query(oQuery);
            if(queues.size() > 0)
            {
                Order_Request__c o = new Order_Request__c();
                o.Id = recordId;
                o.OwnerId = queues[0].Id;
                o.Approval_Status__c = 'Approved';
                o.Order_Request_Comments__c = '(' + Datetime.now().addHours(-5) + ') ' + userName + ' Approved: ' + userComments + '\n' + orderRequestComments;
                update o;
            }
            else {
                return 'Error: The Customer Care Queue record could not be found.';
            }           
       }
       else if (action == 'Reject')
       {
            string orderRequestQuery =  'SELECT CreatedById FROM Order_Request__c WHERE Id = :recordId';
            List<Order_Request__c> orderRequests = Database.query(orderRequestQuery);
            if(orderRequests.size() > 0)
            {
                Order_Request__c currentOrderRequest = orderRequests[0];

                Order_Request__c o = new Order_Request__c();
                o.Id = recordId;
                o.OwnerId = currentOrderRequest.CreatedById;
                o.Approval_Status__c = 'Rejected';
                o.Order_Request_Comments__c = '(' + Datetime.now().addHours(-5) + ') ' + userName + ' Rejected: ' + userComments + '\n' + orderRequestComments;
                update o; 
            }
            else {
                return 'Error: The current order request could not be found.';
            }
       }
       else if (action == 'Resubmit For Approval')
       {
            string oQuery =  'SELECT Id FROM Group WHERE Name = \'Finance Queue\'';
            List<Group> queues = Database.query(oQuery);
            if(queues.size() > 0)
            {
                Order_Request__c o = new Order_Request__c();
                o.Id = recordId;
                o.OwnerId = queues[0].Id;
                o.Approval_Status__c = 'Submitted';
                o.Order_Request_Comments__c = '(' + Datetime.now().addHours(-5) + ') ' + userName + ' Resubmitted: ' + userComments + '\n' + orderRequestComments;
                update o;              
            }
            else {
                return 'Error: The Finance Queue record could not be found.';
            }  
       }
       else {
           return 'Error: Action Not Defined.';
       }

       //removed requiresOverContractApproval from conditional statement
       if(createdById != null && createdById != '' && (action == 'Reject' || action == 'Approve' || action == 'Resubmit For Approval'))
       {
            List<String> emailToList = new List<String>();
            String subject = '';
            if(action == 'Approve')
                subject = 'The Order Request you have Requested Has Been APPROVED';
            else if(action == 'Reject')
                subject = 'The Order Request you have Requested Has Been REJECTED';
            else if(action == 'Resubmit For Approval') 
                subject = 'The Following Order Request has been RESUBMITTED';

            String Body = '';
            Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '\">Order Request</a><br/><br/>';
            Body += 'Comments:<br/>';
            Body += userComments;

            if(action == 'Reject' || action == 'Approve')
            {
                String UserQuery = 'SELECT Id, CreatedBy.Email FROM Order_Request__c WHERE Id = :recordId LIMIT 1';
                List<Order_Request__c> users = Database.query(UserQuery);
                if(users != null && users.size() > 0)
                { 
                    Order_Request__c u = users[0];
                    emailToList.add(u.CreatedBy.Email);
                 }
            }
            else if(action == 'Resubmit For Approval')
            {
                emailToList.add('ntabat@inprocorp.com');
                emailToList.add('rprice@inprocorp.com');
                emailToList.add('ehabermehl@inprocorp.com');
                emailToList.add('kpoulson@inprocorp.com');

                CustomNotificationFromApex cn = new CustomNotificationFromApex();
                Set<String> financeApproverSet = new Set<String>();

                String financeUserQuery = 'SELECT Id FROM User WHERE Email = \'ntabat@inprocorp.com\' OR Email = \'rprice@inprocorp.com\' OR Email = \'ehabermehl@inprocorp.com\' OR Email = \'kpoulson@inprocorp.com\'';
                List<User> financeUsers = Database.query(financeUserQuery);
                if(financeUsers != null && financeUsers.size() > 0)
                {
                    for(User usr : financeUsers)
                    {
                        financeApproverSet.add(usr.Id);
                    }
                    cn.notifyUsers(financeApproverSet, recordId, 'Order Request RESUBMITTED For Over Contract Approval', 'The following request has been resubmitted for over contract approval.');
                }
            }

            EmailSendHelper.sendEmailMultipleRecipients(emailToList, '', subject, Body);            
       }
        if(action == 'Resubmit For Approval')
            return 'Successfully Resubmitted!';
        else if (action == 'Approve')
            return 'Successfully Approved!';
        else if (action == 'Reject')
            return 'Successfully Rejected!';
        else
            return 'Error: Incorrect action specified.';
    }
}