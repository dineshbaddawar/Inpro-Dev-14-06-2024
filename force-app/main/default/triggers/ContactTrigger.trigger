trigger ContactTrigger on Contact (before insert, after insert, before update) {

    if(Trigger.New.size() == 1)
    {
        if (trigger.isInsert)
        {
            if (trigger.isBefore) {
                for(Contact contact:Trigger.new)
                {    
                    if(contact.Is_Lead_Account_Request__c == true || contact.LeadSource == 'eCommerce')
                    {                              
                        contact.Ecommerce__c = true;           
                        
                    }
                }
            }
            else if(trigger.isAfter && trigger.isInsert) {    
                for(Contact c:Trigger.new)
                {    
                    if(c.Is_Lead_Account_Request__c == true || c.LeadSource == 'eCommerce')
                    {   
                        List<Account> accountList = [SELECT Point_of_Contact__c  FROM Account WHERE Id = :c.AccountId LIMIT 1];
                        if(accountList.size() > 0)
                        {                       
                            if(accountList[0].Point_of_Contact__c != null)
                            {
                                Account a = new Account();
                                a.Id = c.AccountId;
                                a.Point_of_Contact__c = c.Id;
                                update a;
                            }
                        }

                        if(c.Email != null && c.Email != '')
                        {
                            WebserviceTriggerProxy.ApproveEcomRegistration(c.Email);
                        }     

                        //Run validation on new contact
                        if (!Test.isRunningTest())
                        {
                            AddressValidationHelper.ValidateAddressOneTrigger(c.Id, 'Contact');
                            AddressValidationHelper.ValidateAddressTwoTrigger(c.Id, 'Contact');
                        }
                    }       
                }
            }
        }
    }
        if (trigger.isUpdate)
        {
            for(Contact c : Trigger.New)
                {

                    if(c.Is_Lead_Account_Request__c == true || c.LeadSource == 'eCommerce')
                    {                              
                        c.Ecommerce__c = true;           

                        if(c.Email != null && c.Email != '')
                        {
                            WebserviceTriggerProxy.ApproveEcomRegistration(c.Email);
                        }     
                        
                    }

                    Contact oldContact = Trigger.oldMap.get(c.Id);
                    // if Mailing address changed
                    if (oldContact.MailingCity != c.MailingCity ||
                        oldContact.MailingCountry != c.MailingCountry ||
                        oldContact.MailingPostalCode != c.MailingPostalCode ||
                        oldContact.MailingState != c.MailingState ||
                        oldContact.MailingStateCode != c.MailingStateCode ||
                        oldContact.MailingStreet != c.MailingStreet)
                    {
                        c.Mailing_Address_Validated__c = 'Not Valid';//reset validation
                        if(!Test.isRunningTest())
                        {
                            AddressValidationHelper.ValidateAddressOneTrigger(c.Id, 'Contact');
                        }
                    }
        
                    // if Contact address changed
                    if (oldContact.OtherCity != c.OtherCity ||
                        oldContact.OtherCountry != c.OtherCountry ||
                        oldContact.OtherPostalCode != c.OtherPostalCode ||
                        oldContact.OtherState != c.OtherState ||
                        oldContact.OtherStateCode != c.OtherStateCode ||
                        oldContact.OtherStreet != c.OtherStreet)
                    {
                        c.Contact_Address_Validated__c = 'Not Valid';//reset validation
                        if(!Test.isRunningTest())
                        {
                            AddressValidationHelper.ValidateAddressTwoTrigger(c.Id, 'Contact');
                        }
                    }
                }
        }
       
}