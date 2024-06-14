trigger AccountPostCreate on Account (after insert) {
    if(System.IsBatch() == false && System.isFuture() == false)
    {
        if(!Test.isRunningTest())  
        {     
            for(Account a : Trigger.New) {
                // get the territory if not populated
                if(!Test.isRunningTest() && Trigger.New.size() == 1) 
                {
                    if (
                           a.Territory_Lookup__c == null &&                     
                            (
                                a.ShippingPostalCode != null ||
                                (a.ShippingCountryCode != null && a.ShippingCountryCode != 'US')
                            )
                       )
                    {
                        TerritoryHelper.updateRecordTerritory('Account', a.Id, a.ShippingPostalCode, a.ShippingStateCode,a.ShippingCountryCode);
                    }
                    AddressValidationHelper.ValidateAddressOneTrigger(a.Id, 'Account');
                    AddressValidationHelper.ValidateAddressTwoTrigger(a.Id, 'Account');
                }
                
                //Sync GPOs on change of the parent account
                // if(a.ParentId != null)
                // {
                    
                //     //retrieve parent account
                //     List<Account> aList = [select Id, Price_Level__c from Account where Id =: a.ParentId LIMIT 1];
                //     //check for existing parent account GPO Associations
                //     List<GPO_Association__c> ParentGPOList = [select Id, Sync_GPO_Association__c, Group_Purchasing_Organization__c, Division__c, Membership_ID__c, Name, Effective_Date__c, Expiration_Date__c from GPO_Association__c where Sync_GPO_Association__c = TRUE AND Inactive__c = FALSE AND Account__c =: aList[0].Id];
                //     List<GPO_Association__c> GPOAssociationsToCreate = new List<GPO_Association__c>();
                //     for(GPO_Association__c parentGA : ParentGPOList){
                //         // create the GPO Association if it doesn't exist
                //         GPO_Association__c gpoAssociation = new GPO_Association__c(Group_Purchasing_Organization__c = parentGA.Group_Purchasing_Organization__c, 
                //         Division__c = parentGA.Division__c, 
                //         //Membership_ID__c = parentGA.Membership_ID__c,
                //         Effective_Date__c = system.today(),
                //         Expiration_Date__c = parentGA.Expiration_Date__c,
                //         Account__c = a.Id);
                //         GPOAssociationsToCreate.Add(gpoAssociation);                  
                //     }
                //     insert GPOAssociationsToCreate;
                // } 

                if(a.AccountSource == 'eCommerce')
                {
                    if(a.Point_of_Contact__c == null)
                    {
                        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 1];
                        if(contacts.size() > 0)            
                        {
                            a.Point_of_Contact__c = contacts[0].Id;
                        }
                    }

                    User user1 = [SELECT Id FROM User WHERE LastName='System Account' LIMIT 1];            
                    // Create an approval request for the account
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Auto-submitted Ecommerce Request.');
                    req1.setObjectId(a.id);            
                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(user1.Id);             
                    // Submit the record to specific process and skip the criteria evaluation
                    req1.setProcessDefinitionNameOrId('Account_Approval_v2');

                    req1.setSkipEntryCriteria(true);
                    
                    // Submit the approval request for the account
                    Approval.ProcessResult result = Approval.process(req1);

                }

                if (a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Group_Purchasing_Organization').getRecordTypeId() &&
                    [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Allow_Creation_Edit_of_GPO_Associations'].size() > 0)
                {
                    User user1 = [SELECT Id FROM User WHERE LastName='System Account' LIMIT 1];            
                    // Create an approval request for the account
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Auto-submitted Ecommerce Request.');
                    req1.setObjectId(a.id);            
                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(user1.Id);             
                    // Submit the record to specific process and skip the criteria evaluation
                    req1.setProcessDefinitionNameOrId('Account_Approval_v2');

                    req1.setSkipEntryCriteria(true);
                    
                    // Approve the submitted request
                    Approval.ProcessResult result = Approval.process(req1);

                    // First, get the ID of the newly created item
                    List<Id> newWorkItemIds = result.getNewWorkitemIds();
                    
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Approving request.');
                    req2.setAction('Approve');
                    req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

                    // Use the ID from the newly created item to specify the item to be worked
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    
                    // Submit the request for approval
                    Approval.ProcessResult result2 =  Approval.process(req2);
                }                
            }
        }

        // if(Trigger.newMap > 1)
        // {
        //     Trigger.newmap.Keyset()
        //     //Todo: call bulk service call to update acounts
        // }
    }
}