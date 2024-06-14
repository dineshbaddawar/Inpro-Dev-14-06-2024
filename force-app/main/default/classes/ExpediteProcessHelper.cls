public with sharing class ExpediteProcessHelper {
    @AuraEnabled
    public static Boolean IsValidApprover(string currentUserId, string recordId, string approvalStage, string expediteCreatedById, string expediteManagerEmail) {
        
        //retrieve current user email
        string currentUserEmail = '';
        string Query = 'SELECT Email FROM User where Id = :currentUserId LIMIT 1';
        List<User> currentUser = Database.query(Query);
        if(currentUser.size() > 0)
            currentUserEmail = currentUser[0].Email;
        else
            return false;     

        //check if valid user based on approvalStage and backups              
        if(approvalStage == 'Manager')
        {         
            if(currentUserEmail == expediteManagerEmail)
                return true;
            else{
                //backup logic
                Query = 'SELECT DelegatedApproverId, Id FROM User WHERE Id = :expediteManagerEmail LIMIT 1';          
                List<User> expediteManagerUser = Database.query(Query);
                if(expediteManagerUser.size() > 0)
                {
                    if(expediteManagerUser[0].DelegatedApproverId != null && (expediteManagerUser[0].DelegatedApproverId == currentUserId))
                        return true;
                    else 
                        return false;  
                }
                else
                    return false; 
            }                  
        }
        else if (approvalStage == 'Requestor')
        {
            if(expediteCreatedById == currentUserId)
                return true;
            else {
                //backup logic
                Query = 'SELECT DelagatedApproverId, Id FROM User where Id = :expediteCreatedById LIMIT 1';
                List<User> createdByUsers = Database.query(Query);
                if(createdByUsers.size() > 0)
                {
                    if(createdByUsers[0].DelegatedApproverId != null)
                    {
                        if(createdByUsers[0].DelegatedApproverId == currentUserId)
                            return true;
                        else 
                            return false;
                    }
                    else 
                        return false;
                }
                else 
                    return false;
            }
        }
        else
        {
            string backupINStatement = '(';
            Query = 'SELECT Email__c FROM Expedite_Approver__c WHERE Inactive__c = false AND Buyer_Planner__c = :approvalStage';   
            List<Expedite_Approver__c> expediteApprovers = Database.query(Query);
            if(expediteApprovers.size() > 0)
            {
                for(Expedite_Approver__c ea : expediteApprovers)
                {
                    if((ea.Email__c).contains(currentUserEmail))
                        return true;
                    else {
                        if(ea.Email__c != null && ea.Email__c != '')
                            backupINStatement += ('\'' + ea.Email__c + '\',');                     
                    }
                }
                //backup logic
                backupINStatement = backupINStatement.substring(0,backupINStatement.length() - 1);
                backupINStatement += ')';
                Query = 'SELECT DelegatedApproverId, Id FROM User WHERE Email IN ' + backupINStatement;
                List<User> buyerPlannerApproverUsers = Database.query(Query);
                if(buyerPlannerApproverUsers.size() > 0)
                {
                    for(User u : buyerPlannerApproverUsers)
                    {
                        if(u.DelegatedApproverId == currentUserId)
                            return true;
                    }
                }
                else 
                    return false;
            }                          
            else
                return false;     
        }
        return false;      
    }

    @AuraEnabled
    public static List<Expedite_Request__c> GetCurrentExpedite(string expediteId)
    {
        try {
            String Query = 'SELECT Current_Step__c, Division__c, Location__c, Expedite_Part_Number__c, NetSuite_ID__c FROM Expedite_Request__c WHERE Id = :expediteId LIMIT 1';
            List<Expedite_Request__c> expedite = Database.query(Query);
            return expedite;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  

    @AuraEnabled
    public static List<Expedite_Approval_Step__c> GetCurrentApprovalStep(string recordId)
    {
        try {
            String Query = 'SELECT Approval_Stage__c, Approver__c, Status__c, Expedite_Request__c, NetSuite_ID__c, Expedite_Request__r.NetSuite_ID__c, Expedite_Request__r.CreatedById, Expedite_Request__r.Approving_Manager__r.Email__c, Expedite_Request__r.Status__c FROM Expedite_Approval_Step__c WHERE Id = :recordId LIMIT 1';
            List<Expedite_Approval_Step__c> expediteApprovalStep = Database.query(Query);
            return expediteApprovalStep;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  

    @AuraEnabled
    public static List<User> GetCurrentUser(string userId)
    {
        try {
            String Query = 'SELECT Email, Profile.Name FROM User WHERE Id = :userId LIMIT 1';
            List<User> currentUser = Database.query(Query);
            return currentUser;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Expedite_Supplier_Option__c> GetSupplierOptions(string expediteId)
    {
        try {
            String Query = 'SELECT Id, Selected_Option__c FROM Expedite_Supplier_Option__c WHERE Expedite_Request__c = :expediteId';
            List<Expedite_Supplier_Option__c> expediteSupplierOptions = Database.query(Query);
            return expediteSupplierOptions;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static List<Expedite_Approval_Step__c> GetCurrentApprovalStep(string expediteId)
    // {
    //     try {
    //         String Query = 'SELECT Id, NetSuite_ID__c FROM Expedite_Approval_Step__c WHERE Expedite_Request__c = :expediteId and Status__c = \'Submitted\' LIMIT 1';
    //         List<Expedite_Approval_Step__c> currentApprovalStep = Database.query(Query);
    //         return currentApprovalStep;

    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    @AuraEnabled
    public static string ExecuteExpediteAction(string actionType, string expediteId, string notes, string currentUserEmail, string currentStepNetSuiteID, string expediteNetSuiteID, string currentStepId, string currentStepApprovalStage)
    {
        try {
            if(currentStepApprovalStage == 'Requestor')
            {
                String Query = 'SELECT Id FROM Expedite_Approval_Step__c WHERE Expedite_Request__c = :expediteId AND Approval_Stage__c != \'Requestor\' AND Status__c = \'Submitted\'';
                List<Expedite_Approval_Step__c> expediteApprovalStep = Database.query(Query); 
                if(expediteApprovalStep != null && expediteApprovalStep.size() > 0)
                    return 'Error: Other approval steps need to be processed before doing the final approval. Please refer to the expedite request to see who needs to be contacted.';
            }
            
            sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
            service.timeout_x = 120000;
            return service.ExecuteExpediteProcessingAction('dsj8U73_3nv3Dhba', actionType, expediteId, notes, currentUserEmail, currentStepNetSuiteID, expediteNetSuiteID, currentStepId); 

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future(callout=true)
    public static void UpdateNetSuiteSupplierOption(string netSuiteSupplierOptionInternalId, Boolean selected, string netSuiteExpediteInternalId, Decimal cost)
    {
        try {
            sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
            service.timeout_x = 120000;

            Double costDouble = 0;
            if(cost != null && selected)
                costDouble = cost.doubleValue();
            service.UpdateSupplierOptionInNetSuite('dsj8U73_3nv3Dhba', netSuiteSupplierOptionInternalId, selected, netSuiteExpediteInternalId, costDouble);  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }

    @future(callout=true)
    public static void UpdateNetSuiteExpeditePartNumber(string expeditePartNumber, string netsuiteExpediteId)
    {
        try {
            sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
            service.timeout_x = 120000;

            service.UpdateExpeditePartNumberInNetSuite('dsj8U73_3nv3Dhba', expeditePartNumber, netsuiteExpediteId);  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }
}