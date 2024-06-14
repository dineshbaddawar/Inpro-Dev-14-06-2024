public with sharing class ChangeRequestProcessHelper {
    
    @AuraEnabled
    public static string FinishProcessingChangeRequest(String changeRequestId, String action, String notes, List<String> selectedApprovalStepIds, List<String> selectedApprovalStepTypes, String userId) {
        try {
            Account updatedAccount = new Account();
            String customerNumber = '';
            String customerName = '';

            //Retrieve Current Change Request
            List<Change_Request__c> changeRequests = [SELECT Record_Type__c, Status__c, Record_ID__c, CreatedBy.Email, CreatedBy.Id, Id, Contact_Sync_IDs__c, Sync_to_Contact_Addresses__c, Sync_to_Contact_Phone_Numbers__c
            FROM Change_Request__c
            WHERE Id = :changeRequestId];

            if(changeRequests == null || changeRequests.size() == 0)
                return 'Error: The Change Request could not be found.';

            if(changeRequests[0].Record_Type__c.toLowerCase() == 'account')
            {
                updatedAccount = [SELECT Id, Phone, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Customer_Number__c,Name
                FROM Account
                WHERE Id = :changeRequests[0].Record_ID__c];

                if(updatedAccount != null)
                {
                    customerNumber = updatedAccount.Customer_Number__c;
                    customerName = updatedAccount.Name;
                }
            }
       
            if(action == 'Approve')
            { 
                Boolean approvingFinanceFields = false;
                Boolean approvingNationalAccountFields = false;

                if(selectedApprovalStepTypes != null)
                {
                    for(String s : selectedApprovalStepTypes) 
                    {
                        if(s == 'Finance')
                            approvingFinanceFields = true;
                        else if (s == 'National Account')
                            approvingNationalAccountFields = true;
                    }
                }
                
                if(selectedApprovalStepIds != null)
                {
                    List<Change_Request_Approval_Step__c> approvalStepsToUpdate = new List<Change_Request_Approval_Step__c>();
                    for(String s : selectedApprovalStepIds)
                    {
                        Change_Request_Approval_Step__c aStep = new Change_Request_Approval_Step__c();
                        aStep.Id = s;
                        aStep.Status__c = 'Approved';
                        aStep.Processing_Notes__c = notes;
                        aStep.Processed_By__c = userId;
                        aStep.Processed_On__c = Datetime.now();
                        approvalStepsToUpdate.add(aStep);
                    }
                    update approvalStepsToUpdate;
                }

                SObject record = Schema.getGlobalDescribe().get(changeRequests[0].Record_Type__c).newSObject();
                record.Id = changeRequests[0].Record_ID__c;

                List<Change_Request_Detail__c> rejectedChangeRequestDetails = new List<Change_Request_Detail__c>();
                //Retrieve Change Request Details
                List<Change_Request_Detail__c> changeRequestDetails = [SELECT Field_Data_Type__c, Field_Schema_Name__c, New_Field_Value__c, Reject_Change__c, Old_Field_Value__c
                                                        FROM Change_Request_Detail__c
                                                        WHERE Change_Request__c = :changeRequestId];
                
                if(changeRequestDetails != null && changeRequestDetails.size() > 0)
                {
                    for(Change_Request_Detail__c cr : changeRequestDetails)
                    {
                        if(cr.Reject_Change__c != null && !cr.Reject_Change__c)
                        {
                            // if(cr.Field_Schema_Name__c == 'ParentId')
                            // {
                            //     if(approvingNationalAccountFields)
                            //     {
                            //         if(cr.New_Field_Value__c != null)
                            //             record.put(cr.Field_Schema_Name__c, String.valueOf(cr.New_Field_Value__c));
                            //         else {
                            //             record.put(cr.Field_Schema_Name__c, null);
                            //         }
                            //     }
                            // }
                            // else 
                            // {
                            if (approvingFinanceFields)
                            {
                                if(cr.Field_Data_Type__c == 'CURRENCY' || cr.Field_Data_Type__c == 'DECIMAL' || cr.Field_Data_Type__c == 'NUMBER')
                                {
                                    if(cr.New_Field_Value__c != null)
                                        record.put(cr.Field_Schema_Name__c, Decimal.valueOf(cr.New_Field_Value__c));
                                    else {
                                        record.put(cr.Field_Schema_Name__c, null);
                                    }
                                }
                                else if(cr.Field_Data_Type__c == 'BOOLEAN')
                                {
                                    if(cr.New_Field_Value__c != null)
                                        record.put(cr.Field_Schema_Name__c, Boolean.valueOf(cr.New_Field_Value__c));
                                    else {
                                        record.put(cr.Field_Schema_Name__c, null);
                                    }
                                }
                                else if(cr.Field_Data_Type__c == 'PICKLIST' || cr.Field_Data_Type__c == 'STRING' || cr.Field_Data_Type__c == 'REFERENCE')
                                {
                                    if(cr.New_Field_Value__c != null)
                                        record.put(cr.Field_Schema_Name__c, String.valueOf(cr.New_Field_Value__c));
                                    else {
                                        record.put(cr.Field_Schema_Name__c, null);
                                    }
                                }
                                else if(cr.Field_Data_Type__c == 'DATE')
                                {
                                    if(cr.New_Field_Value__c != null)
                                        record.put(cr.Field_Schema_Name__c, Date.valueOf(cr.New_Field_Value__c));
                                    else {
                                        record.put(cr.Field_Schema_Name__c, null);
                                    }
                                }  
                            } 
                            //}
                        }
                        else {
                            rejectedChangeRequestDetails.add(cr);
                        }                
                    }
                    update record;                                              
                    
                    if(changeRequests[0].Record_Type__c.toLowerCase() == 'account' && changeRequests[0].Contact_Sync_IDs__c != null && 
                        changeRequests[0].Contact_Sync_IDs__c != '' && (changeRequests[0].Sync_to_Contact_Addresses__c || changeRequests[0].Sync_to_Contact_Phone_Numbers__c))
                    {
                        if(changeRequests[0].Record_Type__c.toLowerCase() == 'account')
                        {
                            updatedAccount = [SELECT Id, Phone, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Customer_Number__c,Name
                            FROM Account
                            WHERE Id = :changeRequests[0].Record_ID__c];

                            if(updatedAccount != null)
                            {
                                customerNumber = updatedAccount.Customer_Number__c;
                                customerName = updatedAccount.Name;
                            }
                        }
                        if(updatedAccount != null)
                        {
                            List<Contact> contactsToUpdate = new List<Contact>();
                            String[] contactIDSplit = (changeRequests[0].Contact_Sync_IDs__c).split(',');
                            for(String s : contactIDSplit)
                            {
                                Contact c = new Contact();
                                c.Id = s;
                                if(changeRequests[0].Sync_to_Contact_Phone_Numbers__c)
                                    c.Phone = updatedAccount.Phone;
                                if(changeRequests[0].Sync_to_Contact_Addresses__c)
                                {
                                    c.MailingStreet = updatedAccount.ShippingStreet;
                                    c.MailingCity = updatedAccount.ShippingCity;
                                    c.MailingState = updatedAccount.ShippingState;
                                    c.MailingPostalCode = updatedAccount.ShippingPostalCode;
                                    c.MailingCountry = updatedAccount.ShippingCountry;
                                }
                                contactsToUpdate.add(c);
                            }
                            update contactsToUpdate;
                        }
                    }
                }
                //Send Email to Requestor
                String EmailTo = changeRequests[0].CreatedBy.Email;
                String EmailCC = '';
                
                String Title = 'Change Request Approved (' + customerName + ' - ' + customerNumber + ')';
                if(rejectedChangeRequestDetails.size() > 0)
                    Title = 'Change Request PARTIALLY Approved (' + customerName + ' - ' + customerNumber + ')';
                
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeRequests[0].Record_ID__c; 
                String changeRequestUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeRequestId; 
                
                String Body = 'The change request you requested has been approved. ';
                if(rejectedChangeRequestDetails.size() > 0)
                {
                    Body = 'The change request you requested has been PARTIALLY approved.';                       
                }
                Body += '<br/><br/>' + 'Notes: ' + notes + '<br/><br/>' + 
                                '<a style=\"font-size:20px\" href=\"' + recordUrl + '\">Account Link</a>' + '<br/><br/>' + 
                                '<a style=\"font-size:20px\" href=\"' + changeRequestUrl + '\">Change Request Link</a>';
                
                if(rejectedChangeRequestDetails.size() > 0)
                {
                    Body += '<br/><br/><b>Rejected Changes:</b><br/><br/><table style="border: 1px solid #dddddd; padding: 8px; width:500px;"><tr><th style="text-align: left; background-color: #dddddd;">Field</th><th style="text-align: left; background-color: #dddddd;">Old Value</th><th style="text-align: left; background-color: #dddddd;">Requested Value</th></tr>';
                    for(Change_Request_Detail__c d : rejectedChangeRequestDetails)
                    {
                        Body = Body + '<tr><td>' + d.Field_Schema_Name__c + '</td><td>' + d.Old_Field_Value__c + '</td><td>' + d.New_Field_Value__c + '</td></tr>';
                    }
                    Body += '</table>';
                }

                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);             
            }
            else if (action == 'Reject') {             
                if(selectedApprovalStepIds != null)
                {
                    List<Change_Request_Approval_Step__c> approvalStepsToUpdate = new List<Change_Request_Approval_Step__c>();
                    for(String s : selectedApprovalStepIds)
                    {
                        Change_Request_Approval_Step__c aStep = new Change_Request_Approval_Step__c();
                        aStep.Id = s;
                        aStep.Status__c = 'Rejected';
                        aStep.Processing_Notes__c = notes;
                        aStep.Processed_By__c = userId;
                        aStep.Processed_On__c = Datetime.now(); 
                        approvalStepsToUpdate.add(aStep);
                    }
                    update approvalStepsToUpdate;
                }

                //Send Email to Requestor
                String EmailTo = changeRequests[0].CreatedBy.Email;
                String EmailCC = '';
                String Title = 'Change Request Rejected (' + customerName + ' - ' + customerNumber + ')';
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeRequests[0].Record_ID__c; 
                String changeRequestUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeRequestId; 
                String Body = 'The change request you requested has been rejected. <br/><br/>' + 'Notes: ' + notes + '<br/><br/>' + 
                                '<a style=\"font-size:20px\" href=\"' + recordUrl + '\">Account Link</a>' + '<br/><br/>' + 
                                '<a style=\"font-size:20px\" href=\"' + changeRequestUrl + '\">Change Request Link</a>';
                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                
            }
            else {
                return 'Error: The action parameter is not correct.';
            }

            //Check Approval Steps Post Update
            String Query = 'SELECT Id, Status__c FROM Change_Request_Approval_Step__c WHERE Change_Request__c = :changeRequestId';
            List<Change_Request_Approval_Step__c> steps = Database.query(Query);
            if(steps.size() > 0)
            {
                Integer openCount = 0;
                Integer approvedCount = 0;
                Integer rejectedCount = 0;

                for(Change_Request_Approval_Step__c step : steps)
                {
                    if(step.Status__c == 'Approved')
                        approvedCount++;
                    if(step.Status__c == 'Rejected')
                        rejectedCount++;
                    if(step.Status__c == 'Open')
                        openCount++;
                }

                if(openCount == 0)
                {
                    if(approvedCount > 0 && rejectedCount == 0)
                    {
                        changeRequests[0].Status__c = 'Approved';
                        update (Change_Request__c)changeRequests[0];
                    }
                    else if (approvedCount == 0 && rejectedCount > 0)
                    {
                        changeRequests[0].Status__c = 'Rejected';
                        update (Change_Request__c)changeRequests[0];
                    }
                    else if (approvedCount > 0 && rejectedCount > 0)
                    {
                        changeRequests[0].Status__c = 'Partially Approved';
                        update (Change_Request__c)changeRequests[0];
                    }
                }
            }  
            return 'Success!';                         
        } 
        catch (Exception ex) 
        {                    
            return 'Error: There was an error processing the change request. ' + ex.getMessage();
        }    
    }

    @AuraEnabled
    public static UserDetail RetrieveCurrentUserInfo(String userId){
        UserDetail ud = new UserDetail();
        ud.isFinanceApprover = false;
        ud.isNationalAccountApprover = false;
        ud.message = 'Success!';
        
        try {
            String Query = 'SELECT Id, Name FROM Group WHERE Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userId) AND Name IN (\'National Account Approvers\',\'Finance Approvers\')';
            List<Group> Groups = Database.query(Query);
            if(Groups.size() > 0)            
            {
                for(Group g : Groups)
                {
                    if(g.Name == 'Finance Approvers')
                        ud.isFinanceApprover = true;
                    else if (g.Name == 'National Account Approvers')
                        ud.isNationalAccountApprover = true;
                }
                return ud;
            }
            else {
                return ud;
            }
        } catch (Exception ex) {
            ud.message = 'Error: There was an error retrieving the user info.';
                return ud;
        }
    }

    @AuraEnabled
    public static List<Change_Request_Approval_Step__c> RetrievePendingApprovals(String changeRequestId){   
        List<Change_Request_Approval_Step__c> approvalSteps = new List<Change_Request_Approval_Step__c>();
        try {   
            String Query = 'SELECT Id, Name, Approval_Type__c, Processed_On__c, Processed_By__c, Status__c, Processing_Notes__c FROM Change_Request_Approval_Step__c WHERE Change_Request__c = :changeRequestId';
            List<Change_Request_Approval_Step__c> steps = Database.query(Query);
            if(steps.size() > 0)            
                return steps;
            else {
                return approvalSteps;
            }
        } catch (Exception ex) {
            return approvalSteps;
        }
    }

    public class UserDetail
    {
        @AuraEnabled
        public Boolean isFinanceApprover {get;set;}
        @AuraEnabled
        public Boolean isNationalAccountApprover {get;set;}    
        @AuraEnabled
        public string message {get;set;}    
    }
}