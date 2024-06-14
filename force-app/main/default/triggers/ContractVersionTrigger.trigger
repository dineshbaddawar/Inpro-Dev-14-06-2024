trigger ContractVersionTrigger on Contract_Version__c (before insert, after update, after insert) {
    if(Trigger.isBefore)
    {
        // for(Contract_Version__c version:Trigger.new)
        // {             
        //     String ContractId = version.Inpro_Contract__c;
        //     if(version.Name != null)
        //     {                
        //         String Query = 'SELECT Inpro_Contract__r.Name, Id FROM Contract_Version__c  WHERE Inpro_Contract__c = :ContractId';
        //         List<Contract_Version__c> arList = Database.query(Query);
        //         Integer cvNumber = arList.size() + 1;
        //         version.Name = 'CV-' + cvNumber;                    
        //     }
        // }
    }
    else if (Trigger.isUpdate)
    {
        try{
            for(Contract_Version__c version:Trigger.new)
            { 
                Contract__c c = new Contract__c();
                Contract_Version__c oldContractVersion = Trigger.oldMap.get(version.Id);
                if(version.Status__c == 'Completed' && oldContractVersion.Status__c != version.Status__c)
                {
                    String contractId = version.Inpro_Contract__c;
                    String contractName = [SELECT Name  FROM Contract__c WHERE Id = :contractId].Name;

                    //Update status to Activated and hide from queue                
                    c.Id = version.Inpro_Contract__c;
                    c.Status__c = 'Activated';
                    c.Hide_From_Queue__c = true;
                    c.Executed_Date__c = system.today();

                    //Email ISR
                    string createdById = version.CreatedById;
                    List<string> EmailTo = new List<string>();
                    string EmailCC = '';
                    string Subject = 'Contract Complete - ' + contractName;
                    string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + version.Inpro_Contract__c;            
                    string Body = '';
                    string quoteId = '';
                    if(version.Quote__c != null)
                        quoteId = version.Quote__c;                                   

                    List<Quote> quoteList = [SELECT Opportunity.OwnerId, Opportunity_Name__c, Opportunity.Id, Name, Id FROM Quote WHERE Id = :quoteId ORDER BY LastModifiedDate DESC LIMIT 1];                    
                    List<Contract_Sales_Role__c> salesRoles = [SELECT Sales_Contact__r.Email FROM Contract_Sales_Role__c WHERE Inpro_Contract__c = :contractId];

                    if(salesRoles.size() > 0)
                    {
                        for (Integer i = 0; i < salesRoles.size(); i++) {
                            if(salesRoles[i].Sales_Contact__r.Email != null && salesRoles[i].Sales_Contact__r.Email != '')
                                EmailTo.add(salesRoles[i].Sales_Contact__r.Email);
                        }
                    }

                    Body = 'The following contract has been completed: ' +
                           '<a style=\"font-size:20px\" href=\"' + recordUrl + '\">Contract</a><br/><br/>'; 
                           if(quoteList.size() > 0 && quoteList[0].Opportunity.OwnerId != null && quoteList[0].Opportunity.Id != null)
                           {
                                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + quoteList[0].Opportunity.Id + '\">Opportunity</a><br/><br/>' + 
                                '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + quoteList[0].Id + '\">Quote</a><br/><br/>';
                           } 
                           Body += 'Executed contracts/COs will be attached on the opportunity under contract files. '; 

                    List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :createdById];
                    if(userList.size() > 0)
                    {
                        EmailTo.add(userList[0].Email);
                        if(userList[0].DelegatedApproverId != null)
                        {
                            string deletegatedApproverId = userList[0].DelegatedApproverId;
                            EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;
                        }

                        if(quoteList[0].Opportunity_Name__c != null)
                            Subject += ' - ' + quoteList[0].Opportunity_Name__c + ' (' + quoteList[0].Name + ')';

                        EmailSendHelper.sendEmailMultipleRecipients(EmailTo, EmailCC, Subject, Body);        
                    }
                                    
                    // //Notify contract version creator
                    // String Title = '';
                    // String nBody = '';        
                    // Set<String> recipientsIds = new Set<String>();
                    // String targetId = version.Id;             
                    // recipientsIds.add(version.CreatedById);
                    // CustomNotificationFromApex cn = new CustomNotificationFromApex();
                    // Title = 'Contract Complete';
                    // nBody =  version.Name + ' completed, see it by clicking here.';                     
                    // cn.notifyUsers(recipientsIds, targetId, Title, nBody);   

                }
                else if (version.Status__c == 'Follow Up' || version.Status__c == 'Reviewed/Sent')
                {                
                    c.Id = version.Inpro_Contract__c;
                    c.Hide_From_Queue__c = true;                
                }   
                else if(version.Status__c == 'Submitted')
                {
                    string ContractName = '';
                    String ContractId = version.Inpro_Contract__c;
                            
                    String Query = 'SELECT Inpro_Contract__r.Name, Id FROM Contract_Version__c  WHERE Inpro_Contract__c = :ContractId';
                    List<Contract_Version__c> arList = Database.query(Query);            
                    ContractName = arList[0].Inpro_Contract__r.Name;  
                    
                    c.Id = ContractId;
                    c.Status__c = 'In Process';
                    c.Hide_From_Queue__c = false;                                    
        
                    string contractAdminId = [SELECT Contract_Admin__c  FROM Contract__c  WHERE Id = :ContractId].Contract_Admin__c;
                    if(contractAdminId != null)
                    {
                        string EmailTo = '';
                        string EmailCC = '';
                        string Subject = 'New Contract Version - ' + ContractName;
                        string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ContractId;            
                        string Body = 'A new contract version has been created click here to view it: ' + 
                        '<a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + ContractName + '</a>';             
        
                        List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :contractAdminId];
                        if(userList.size() > 0)
                        {
                            EmailTo = userList[0].Email;
                            string deletegatedApproverId = userList[0].DelegatedApproverId;
                            if(deletegatedApproverId != null)
                            {
                                EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;
                            }
        
                        //  EmailSendHelper.sendEmail(EmailTo, EmailCC, Subject, Body);
        
        
                            String Title = '';
                            String tBody = '';        
                            Set<String> recipientsIds = new Set<String>();
                            String targetId = ContractId;             
                            recipientsIds.add(contractAdminId);
                            if(deletegatedApproverId != '')
                            {
                                recipientsIds.add(deletegatedApproverId);
                            }
                            CustomNotificationFromApex cn = new CustomNotificationFromApex();
                            Title = 'New Contract Version Created';
                            tBody =  ContractName + ' has a new contract version, see it by clicking here.';                     
                            //cn.notifyUsers(recipientsIds, targetId, Subject, 'A new contract version has been created click here to view it: ' + ContractName);   
                        }
                    }
                }
                else if (version.Status__c == 'Draft')
                {
                    c.Status__c = 'Draft';
                }
                
                c.Id = version.Inpro_Contract__c;
                c.Urgent__c = version.Urgent__c;
                c.Contract_Version_Status__c = version.Status__c;
                if(version.Status__c == 'Submitted' && oldContractVersion.Status__c != 'Submitted')
                    c.Contract_Version_Submittal_Date__c = system.today();
                update c;
            }   
        }
        catch(Exception ex)
        {
            string EmailTo = 'eleptich@inprocorp.com';
            string EmailCC = 'dsieraski@inprocorp.com';
            string Subject = 'ContractVersionTriggerIssue';           
            string Body = ex.getMessage();
            EmailSendHelper.sendEmail(EmailTo, EmailCC, Subject, Body);  
        }
    }    
}