trigger AccountPostUpdate on Account (after update) {   
    if(System.IsBatch() == false && System.isFuture() == false)
    {
       
        List<Contact> contacts = [SELECT Id, Contact_Address_same_as_Account_Address__c, AccountId 
                                  FROM Contact
                                  WHERE AccountId IN :Trigger.newMap.keySet() 
                                    AND Contact_Address_same_as_Account_Address__c = true];

        List<GPO_Association__c> gList = [SELECT Id, Account__c, Inactive__c FROM GPO_Association__c WHERE Account__c IN :Trigger.newMap.keySet() AND Inactive__c = false];

        for(Account a : Trigger.New) {        
            Account oldAccount = Trigger.oldMap.get(a.Id);        
            if (Trigger.isUpdate) {    
                try{
                    
                    if(oldAccount.ShippingCity != a.ShippingCity || oldAccount.ShippingCountry != a.ShippingCountry || oldAccount.ShippingPostalCode != a.ShippingPostalCode
                       || oldAccount.ShippingState != a.ShippingState || oldAccount.ShippingStreet != a.ShippingStreet
                       || oldAccount.BillingCity != a.BillingCity || oldAccount.BillingCountry != a.BillingCountry || oldAccount.BillingPostalCode != a.BillingPostalCode
                       || oldAccount.BillingState != a.BillingState || oldAccount.BillingStreet != a.BillingStreet)
                    {
                        AddressValidationHelper.AddressValidationFuture('account', a.Id, a.ShippingStreet, a.ShippingCity, a.ShippingState, a.ShippingPostalCode, a.BillingStreet, a.BillingCity, a.BillingState, a.BillingPostalCode);
                    }                                           

                    //Notify Lead owner if Lead source is one of the following marketing
                    if (oldAccount.Status__c != 'Approved' && a.Status__c == 'Approved' &&
                        a.Lead__c != null)
                    {
                        Lead lead = [SELECT Id, Name, OwnerId, LeadSource, Products_Interested_in__c, All_Products_of_Interest__c,
                                            Rep_Request_Description__c, Seminar_Requested__c, Contact_Us_Description__c, 
                                            Requested_Item__c, Quote_Description__c, Product_Page__c
                                     FROM Lead 
                                     WHERE Id = :a.Lead__c];

                        //EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'Account update fired for Beta', 'account lead?' + a.Lead__c + '<br>account lead source? ' + lead.LeadSource);
                    
                        if ((lead.LeadSource == 'eCommerce' || lead.LeadSource == 'Google AdWords' || 
                            lead.LeadSource == 'Marketing' || lead.LeadSource == 'Purchased List'  || lead.LeadSource == 'Webinar' ||
                            lead.LeadSource == 'Website'  || lead.LeadSource == 'EDI'))
                        {
                            User user = [SELECT Email FROM User WHERE Id = :lead.OwnerId];
                            string EmailTo = '';
                            if (user != null)
                            {
                                EmailTo = user.Email;
                            }
                            
                            string AccountNumber = a.Customer_Number__c;                     
                            string AccountName = a.Name;
                            string accountUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id;            
                            string leadUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Lead__c;   

                            string EmailCC = 'bsibley@inprocorp.com';
                            string Subject = 'Account Approved ' + AccountNumber;            
                            string Body = 'Account <a style=\"font-size:20px\" href=\"' + accountUrl + '\">' + AccountNumber + ' - ' + AccountName + '</a>' + '<br>' +
                                        'Lead: <a style=\"font-size:20px\" href=\"' + leadUrl + '\">' + lead.Name + '</a>' + '<br>';

                            try{
                                Construction_Project__c cp = [SELECT Id, Name FROM Construction_Project__c WHERE Converted_Lead__c = :a.Lead__c LIMIT 1];
                                if (cp != null)
                                {
                                    string cpUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cp.Id;   
    
                                    Body += 'Construction Project: <a style=\"font-size:20px\" href=\"' + cpUrl + '\">' + cp.Name + '</a>' + '<br>';
                                }
                            }
                            catch(Exception ex)
                            {

                            }
                            
                            try
                            {
                                List<Opportunity> opps = [SELECT Id, Name, Division__c FROM Opportunity WHERE Converted_Lead__c = :a.Lead__c];
                                if (opps.size() > 0)
                                {
                                    for(Opportunity opp: opps)
                                    {
                                        string oppUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;   

                                        Body += opp.Division__c + ' Opportunity: <a style=\"font-size:20px\" href=\"' + oppUrl + '\">' + opp.Name + '</a>' + '<br>';
                                    }
                                }
                            }
                            catch(Exception ex)
                            {

                            }
                            

                            string lead1 = (lead.Products_Interested_in__c != null && lead.Products_Interested_in__c != '' ? lead.Products_Interested_in__c : 'N/A');
                            string lead2 = (lead.All_Products_of_Interest__c != null&& lead.All_Products_of_Interest__c != '' ? lead.All_Products_of_Interest__c : 'N/A');
                            string lead3 = (lead.Rep_Request_Description__c != null && lead.Rep_Request_Description__c != ''? lead.Rep_Request_Description__c : 'N/A');
                            string lead4 = (lead.Seminar_Requested__c != null && lead.Seminar_Requested__c != ''? lead.Seminar_Requested__c : 'N/A');
                            string lead5 = (lead.Contact_Us_Description__c != null && lead.Contact_Us_Description__c != ''? lead.Contact_Us_Description__c : 'N/A');
                            string lead6 = (lead.Requested_Item__c != null && lead.Requested_Item__c != ''? lead.Requested_Item__c : 'N/A');
                            string lead7 = (lead.Quote_Description__c != null && lead.Quote_Description__c != ''? lead.Quote_Description__c : 'N/A');
                            string lead8 = (lead.Product_Page__c != null && lead.Product_Page__c != ''? lead.Product_Page__c : 'N/A');

                            Body += '<hr><br><h2>Web Form Request Data</h2><br>' + 
                                    '<table>' +
                                    '<tr><td><b>Latest Product Interest in:</b></td><td>' + lead1 + '</td></tr>' +
                                    '<tr><td><b>All Products of Interest:</b></td><td> ' + lead2 + '</td></tr>' +
                                    '<tr><td><b>Rep Request Description:</b></td><td> ' + lead3 + '</td></tr>' +
                                    '<tr><td><b>Seminar Requested:</b></td><td> ' + lead4 + '</td></tr>' +
                                    '<tr><td><b>Contact Us Description:</b></td><td> ' + lead5 + '</td></tr>' +
                                    '<tr><td><b>Requested Item:</b></td><td> ' + lead6 + '</td></tr>' +
                                    '<tr><td><b>Quote Description:</b></td><td> ' + lead7 + '</td></tr>' +
                                    '<tr><td><b>Product Page:</b></td><td> ' + lead8 + '</td></tr>' +
                                    '</table>';

                            EmailSendHelper.sendEmail(EmailTo, EmailCC, Subject, Body);
                        }
                    }
                } catch(Exception ex){
                    EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'Failure on Lead Email', ex.getMessage() + '<br>' + ex.getStackTraceString());
                }
                
                
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
                }

                if((oldAccount.Price_Level__c != null && a.Price_Level__c != null) && 
                    oldAccount.Price_Level__c != a.Price_Level__c && oldAccount.Sync_Price_Level__c == a.Sync_Price_Level__c && a.Sync_Price_Level__c == true 
                    && Trigger.New.size() == 1)
                {
                    AccountHelper.syncPriceLevelToChildren(a.Id, a.Price_Level__c);
                }
                else if ((oldAccount.Price_Level__c != null && a.Price_Level__c != null) && oldAccount.Sync_Price_Level__c != a.Sync_Price_Level__c && a.Sync_Price_Level__c == true
                        && Trigger.New.size() == 1)
                {
                    AccountHelper.syncAllPricingToChildren(a.Id, a.Price_Level__c);
                }
                
                //11-12-2021 -- Commented out since we only want accounts with orders going to NetSuite
                // if status changes to 'Approved', push the Account to NetSuite
                //if (a.Status__c == 'Approved' && a.Status__c != oldAccount.Status__c) {           
                //    WebserviceTriggerProxy.AddAccountToNetSuite(a.Id);       
                //}
                
                //Sync GPOs on change of the parent account
                // if(a.ParentId != null)
                // {
                //     //if the parent account changes, expire all GPO associations and create new ones based on the parent account
                //     if(oldAccount.ParentId != a.ParentId && a.Sync_GPO_Pricing__c)
                //     {
                //         if(gList.size() != 0){
                //             //int gpoAssociationsDeactivatedCount = 0;
                //             List<GPO_Association__c> GPOAssociationsToUpdate = new List<GPO_Association__c>();
                //             for(GPO_Association__c ga : gList){
                //                 if (ga.Account__c == a.Id)
                //                 {
                //                     GPO_Association__c existingGPOAssociation = new GPO_Association__c();
                //                     existingGPOAssociation.Expiration_Date__c = system.today();
                //                     existingGPOAssociation.Inactive__c = true;
                //                     existingGPOAssociation.Id = ga.Id;
                //                     GPOAssociationsToUpdate.Add(existingGPOAssociation);
                //                     //gpoAssociationsDeactivatedCount++;
                //                 }
                //             }
                //             update GPOAssociationsToUpdate;

                //             // if(gpoAssociationsDeactivatedCount > 0)
                //             // {
                //             //     String Title = 'Parent Account Changed (GPO Associations Deactivated)';
                //             //     String Body = '';
                //             //     Body = '<br><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '\">Account: ' + a.Name + '</a><br/><br/>';    
                //             //     Body += 'Parent account changed on the linked account. Existing GPO Associations have been deactivated.';
                //             //     String EmailTo = 'alange@inprocorp.com';
                //             //     String EmailCC = '';
                //             //     EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                //             // }
                //         }

                //         //retrieve parent account
                //         List<Account> aList = [SELECT Id, Price_Level__c FROM Account WHERE Id =: a.ParentId];

                //         //check for existing parent account GPO Associations
                //         List<GPO_Association__c> ParentGPOList = 
                //             [SELECT Id, Sync_GPO_Association__c, Group_Purchasing_Organization__c, Division__c, 
                //                     Membership_ID__c, Name, Effective_Date__c, Expiration_Date__c, Account__c
                //                     FROM GPO_Association__c 
                //                     WHERE Sync_GPO_Association__c = TRUE 
                //                       AND Inactive__c = FALSE 
                //                       AND Account__c =: aList[0].Id];

                //         List<GPO_Association__c> GPOAssociationsToCreate = new List<GPO_Association__c>();

                //         for(GPO_Association__c parentGA : ParentGPOList)
                //         {
                //             // create the GPO Association if it doesn't exist
                //             GPO_Association__c gpoAssociation = 
                //                 new GPO_Association__c(Group_Purchasing_Organization__c = parentGA.Group_Purchasing_Organization__c, 
                //                                         Division__c = parentGA.Division__c, 
                //                                         Effective_Date__c = system.today(),
                //                                         Expiration_Date__c = parentGA.Expiration_Date__c,
                //                                         Account__c = a.Id);
                //             GPOAssociationsToCreate.Add(gpoAssociation);                        
                //         }

                //         insert GPOAssociationsToCreate;
                //     }
                // } 

                if(a.ParentId != oldAccount.ParentId)
                { 
                    List<Account> aList = [SELECT Id, Customer_Type__c,Price_Level__c, Customer_Number__c, Name FROM Account WHERE Id =: a.ParentId Limit 1];
                    List<Account> oldAList = [SELECT Id, Customer_Type__c,Price_Level__c, Customer_Number__c, Name FROM Account WHERE Id =: oldAccount.ParentId Limit 1];

                    string AccountNumber = a.Customer_Number__c;                     
                    string AccountName = a.Name;    

                    string ParentAccountNumber = '';                                
                    string ParentAccountName = ''; 
                    string PriceLevel = '';
                    string CustomerType = '';

                    if(aList.size() > 0)
                    {
                        ParentAccountNumber = aList[0].Customer_Number__c;  
                        ParentAccountName = aList[0].Name;   
                        PriceLevel = aList[0].Price_Level__c;
                        CustomerType = aList[0].Customer_Type__c; 
                    }

                    string PreParentAccountName = '';
                    string PreCustomerType = '';
                    string PreParentAccountNumber = '';
                    string PrePriceLevel = '';

                    if(oldAlist.size() > 0)
                    {
                        PreParentAccountName = oldAlist[0].Name;
                        PreCustomerType = oldAlist[0].Customer_Type__c;
                        PreParentAccountNumber = oldAlist[0].Customer_Number__c;
                        PrePriceLevel = oldAlist[0].Price_Level__c;
                    }

                    if (PreParentAccountNumber == '609792' || PreParentAccountNumber == '669396' || PreParentAccountNumber == '470379' ||
                        ParentAccountNumber == '609792' || ParentAccountNumber == '470379' || ParentAccountNumber == '669396')
                    {
                        string EmailTo = 'alange@inprocorp.com';
                        string EmailCC = 'dsieraski@inprocorp.com';
                        string Subject = 'Parent Account Changed: ' + AccountNumber;            

                        string requestUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id;            
                        
                        string Body = '<a style=\"font-size:20px\" href=\"' + requestUrl + '\">' + AccountNumber + ' - ' + AccountName + '</a>' + '<br>' +
                            '<br>';
                            Body += 'New Parent Account: ' + ParentAccountNumber + ' - ' + ParentAccountName + '<br>';
                            Body += 'Customer Type: ' + CustomerType + '<br>';
                            Body += 'Price Level: ' + PriceLevel + '<br>' +
                            '<br>';
                            Body += 'Old Parent Account: ' + PreParentAccountNumber + ' - ' + PreParentAccountName + '<br>';
                            Body += 'Customer Type: ' + PreCustomerType + '<br>';
                            Body += 'Price Level: ' + PrePriceLevel + '<br>' +
                            '<br>';
                        
                        EmailSendHelper.sendEmail(EmailTo, EmailCC, Subject, Body);
                    }
                }
                // if (a.Block_GPO_Sync__c)
                // {
                //     List<Account> accounts = new List<Account>();
                //     Account acc  = new Account(Id = a.Id);
                //     acc.Block_GPO_Sync__c = false;
                //     accounts.add(acc);
                //     UPDATE accounts;                                   
                // }
            }
        }
    }
}