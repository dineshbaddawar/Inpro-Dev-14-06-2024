trigger OrderRequestTrigger on Order_Request__c (after update, before insert) {
   
        //TODO: Restructure this into a bulkified friendly trigger w/ a trigger handler.
        if(Trigger.new.size() == 1)
        {      
            Order_Request__c orderRequest = Trigger.new[0];

            if(trigger.isBefore && trigger.isInsert)
            {    String accountBillingCountry = '';
                //WebserviceTriggerProxy.firstRun = false;  
                    List<Account> accountList =
                    [SELECT Available_Credit__c, BillingCountry
                    FROM Account
                    WHERE Id = :orderRequest.Account__c LIMIT 1];

                decimal accountAvailableCredit = 0;
                if(accountList.size() > 0)
                {
                    Account acc = accountList[0];
                    if(acc.BillingCountry != null)
                        accountBillingCountry = acc.BillingCountry;
                    if(acc.Available_Credit__c != null)
                        accountAvailableCredit = acc.Available_Credit__c;
                }
               
                if (orderRequest.Required_Approvals__c != null && (orderRequest.Required_Approvals__c.contains('Credit Hold') || orderRequest.Required_Approvals__c.contains('Over Contract') || orderRequest.Required_Approvals__c.contains('Contract Not Executed')))
                {
                    orderRequest.Approval_Status__c = 'Submitted';
                }  
                else if(orderRequest.Approval_Status__c == null &&                 
                (                     
                                (
                                    (orderRequest.Payment_Mode__c == null || 
                                    orderRequest.Payment_Mode__c != 'Credit Card') &&
                                    orderRequest.Order_Amount__c >= 7500
                                )
                            || 
                                (    
                                accountList.size() > 0 &&
                                 //accountList[0].Available_Credit__c != null  &&              
                                (orderRequest.Order_Amount__c > accountAvailableCredit)                               
                                && 
                                (orderRequest.Payment_Mode__c == null ||
                                orderRequest.Payment_Mode__c != 'Credit Card')                 
                                )
                            || 
                                (
                                orderRequest.Order_Amount__c >= 10000 && 
                                orderRequest.Payment_Mode__c != null &&
                                orderRequest.Payment_Mode__c == 'Credit Card' && 
                                orderRequest.Quote_Source__c == 'eCommerce'
                                )
                    )                  
                ) 
                {                
                    orderRequest.Approval_Status__c = 'Submitted';
                                        
                    List<Group> groupList = [SELECT Id FROM Group WHERE Name = 'Finance Queue'];
                    if(groupList.size() > 0)
                    {
                        orderRequest.OwnerId = groupList[0].Id;
                    }

                    // List<User> userList = new List<User>();              
                    // if(orderRequest.Approval_Status__c == 'Submitted')                      
                    //     userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :orderRequest.CreditApproverId__c];
                    // if(userList.size() > 0)
                    // {   
                    //     if(userList[0].DelegatedApproverId != null && userList[0].DelegatedApproverId != '')
                    //     {
                    //         string EmailTo = '';
                    //         string EmailCC = '';
                    //         string deletegatedApproverId = userList[0].DelegatedApproverId;

                    //         String Title = 'Order Request Approval Pending';
                    //         String Body = orderRequest.Name + ' submitted, see it by clicking here.';         
                    //         string userId = orderRequest.CreatedById;         
                                        
                    //         if(deletegatedApproverId != null)
                    //             EmailTo = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;

                    //         string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + orderRequest.Id;            
                    //             Body = Body + 
                    //             '<br><a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + orderRequest.Name + '</a>';
                
                    //         EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                    //     }
                    // }
                }           
                else 
                {
                    String queueName = 'Customer Care Queue';
                    orderRequest.Approval_Status__c = 'Approved';

                    if(accountBillingCountry != '' && accountBillingCountry != 'United States' && accountBillingCountry != 'US')
                        queueName = 'International Queue';

                    // List<User> createdByUsers = [SELECT Id, Name FROM User WHERE Id = :orderRequest.CreatedById];
                    // if(createdByUsers.size() > 0)
                    // {
                    //     if(createdByUsers[0].Name == 'CRM System Account')
                    //     {
                            //assign to CCS queue only for ECOMM
                            List<Group> ccsGroupList = [SELECT Id FROM Group WHERE Name = :queueName];
                            if(ccsGroupList.size() > 0)
                            {
                                orderRequest.OwnerId = ccsGroupList[0].Id;
                            }
                        //}
                    //}
                }                
            }
            //WebserviceTriggerProxy.firstRun = false;

            if(trigger.isAfter && trigger.isUpdate)
            {
                Order_Request__c oldOrderRequest = Trigger.oldMap.get(orderRequest.Id);
                if(((orderRequest.Approval_Status__c == 'Approved' && oldOrderRequest.Approval_Status__c != 'Approved') || (orderRequest.Approval_Status__c == 'Rejected' && oldOrderRequest.Approval_Status__c != 'Rejected')) && orderRequest.LastModifiedById != orderRequest.CreatedById)
                {
                    //WebserviceTriggerProxy.firstRun = false;
                    List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :orderRequest.CreatedById];
                    if(userList.size() > 0)
                    {
                        string EmailTo = userList[0].Email;
                        //string EmailTo = 'eleptich@inprocorp.com';
                        string EmailCC = '';
                        string deletegatedApproverId = userList[0].DelegatedApproverId;

                        String Title = '';
                        if(orderRequest.Approval_Status__c == 'Approved')
                            Title = 'Order Request Approved';
                        else if(orderRequest.Approval_Status__c == 'Rejected')
                            Title = 'Order Request Rejected';

                        String Body = '';
                        if(orderRequest.Approval_Status__c == 'Approved')
                            Body = orderRequest.Name + ' has been approved, see it by clicking here.';
                        else if(orderRequest.Approval_Status__c == 'Rejected')
                            Body = orderRequest.Name + ' has been rejected, see it by clicking here.';       

                        string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + orderRequest.Id;            
                                Body = Body + 
                                '<br><a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + orderRequest.Name + '</a>';

                        Body += '<br/>' + orderRequest.Order_Request_Comments__c;

                        if(userList[0].DelegatedApproverId != null)
                        {                                                                  
                            if(deletegatedApproverId != null)
                                EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;                                                            
                        }
                        EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                    }
                }
            }           
        }
    
}