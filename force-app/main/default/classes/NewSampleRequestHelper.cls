public with sharing class NewSampleRequestHelper 
{
    @AuraEnabled
    public static string CreateSampleRequest(string accountId, string opportunityId, string contactId, string leadId,
        string desiredShippingMethod, string shipTo, string sampleType,
        string addressStreet, string addressCity, string addressState, string addressZip, string addressCountry)
    {
        Sample_Request__c sr = new Sample_Request__c();
        if (accountId != '' && accountId != null)
        {
            sr.Account__c = accountId;
        }
        if (contactId != '' && contactId != null)
        {
            sr.Contact__c = contactId;
        }
        if (leadId != '' && leadId != null)
        {
            sr.Lead__c = leadId;
        }
        if (opportunityId != '')
        {
            sr.Opportunity__c = opportunityId;
        }

        if (desiredShippingMethod == 'UPS Ground') desiredShippingMethod = 'UPS_GROUND';
        else if (desiredShippingMethod == 'UPS Next Day') desiredShippingMethod = 'UPS_NEXT_DAY_AIR';
        else if (desiredShippingMethod == 'UPS Second Day Air') desiredShippingMethod = 'UPS_SECOND_DAY_AIR';
        else if (desiredShippingMethod == 'UPS Third Day Select') desiredShippingMethod = 'UPS_THREE_DAY_SELECT';
        else if (desiredShippingMethod == 'USPS - Priority') desiredShippingMethod = 'Priority';
        sr.Desired_Shipping_Method__c = desiredShippingMethod;

        if (shipTo == 'Other - Enter Address Manually') shipTo = 'Other_Enter_Address_Manually';

        sr.Ship_To__c = shipTo;
        sr.Type__c = sampleType;
        sr.Street_Address__c = addressStreet;
        sr.City__c = addressCity;
        sr.State__c = addressState;
        sr.Postal_Code__c = addressZip;
        sr.Country__c = addressCountry;
        insert sr;
        //string screeningResult = DeniedPartyHelper.RunScreeningLogic(accountId);
        return sr.Id;
    }

    @AuraEnabled
    public static Contact GetContactDetails(string recordId){
        return [SELECT Id, AccountId, Name, Account.Name, Lead__c FROM Contact WHERE Id = :recordId LIMIT 1];
    }

    @AuraEnabled
    public static Lead GetLeadDetails(string recordId){
        return [SELECT Id, Name FROM Lead WHERE Id = :recordId LIMIT 1];
    }

    @AuraEnabled
    public static List<string> GetAddress(string shipTo, string accountId, string contactId, string leadId)
    {
        List<String> address = new List<string>();
        if (shipTo == 'Account - Billing')
        {
            if (accountId == '') return new List<string>{'','','','',''};
            else {
                Account account = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountryCode FROM Account Where Id = :accountId];
                address.add(account.BillingStreet == null ? '' : account.BillingStreet); 
                address.add(account.BillingCity == null ? '' : account.BillingCity);
                address.add(account.BillingState == null ? '' : account.BillingState);
                address.add(account.BillingPostalCode == null ? '' : account.BillingPostalCode);
                address.add(account.BillingCountryCode == null ? '' : account.BillingCountryCode);
                return address;
            }
        }
        else if (shipTo == 'Account - Shipping')
        {
            if (accountId == '') return new List<string>{'','','','',''};
            else {
                Account account = [SELECT ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountryCode FROM Account Where Id = :accountId];
                address.add(account.ShippingStreet == null ? '' : account.ShippingStreet);
                address.add(account.ShippingCity == null ? '' : account.ShippingCity);
                address.add(account.ShippingState == null ? '' : account.ShippingState);
                address.add(account.ShippingPostalCode == null ? '' : account.ShippingPostalCode);
                address.add(account.ShippingCountryCode == null ? '' : account.ShippingCountryCode);
                return address;
            }
        }
        else if (shipTo == 'Contact - Contact\'s Address')
        {
            if (contactId == '') return new List<string>{'','','','',''};
            else {
                Contact contact = [SELECT OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountryCode FROM Contact Where Id = :contactId];

                address.add(contact.OtherStreet == null ? '' : contact.OtherStreet);
                address.add(contact.OtherCity == null ? '' : contact.OtherCity);
                address.add(contact.OtherState == null ? '' : contact.OtherState);
                address.add(contact.OtherPostalCode == null ? '' : contact.OtherPostalCode);
                address.add(contact.OtherCountryCode == null ? '' : contact.OtherCountryCode);
                return address;
            }
        }
        else if (shipTo == 'Lead - Mailing')
        {
            if (leadId == '') return new List<string>{'','','','',''};
            else {
                Lead lead = [SELECT Street, City, State, PostalCode, CountryCode FROM Lead Where Id = :leadId];
                
                address.add(lead.Street == null ? '' : lead.Street);
                address.add(lead.City == null ? '' : lead.City);
                address.add(lead.State == null ? '' : lead.State);
                address.add(lead.PostalCode == null ? '' : lead.PostalCode);
                address.add(lead.CountryCode == null ? '' : lead.CountryCode);
                return address;
            }
        }
        else if (shipTo == 'Inpro Europe')
        {
            return new List<string>{'','','','',''};
        }
        else
        {
            return new List<string>{'','','','',''};
        }
    }
    @AuraEnabled
    public static List<Contact> GetContactsFromAccounts(string accountId, string opportunityId){
        List<Contact> allContacts = new List<Contact>();

        Set<Contact> uniqueContacts = new Set<Contact>();
        
        if (accountId != '')
        {
            //uniqueContacts.addAll([SELECT Name, Id, Account.Name, Account.Customer_Number__c FROM Contact WHERE AccountId = :accountId]);
            List<Contact> related = [SELECT Id, Name, Account.Name, Account.Customer_Number__c FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accountId) AND Inactive_Contact__c = false];
            for(Contact c : related){
                uniqueContacts.add(c);     
            }
        }
        if (opportunityId != '')
        {
            Opportunity opportunity = [SELECT Id, AccountId, Building_Owner__c, Building_Owner_Parent__c FROM Opportunity WHERE Id = :opportunityId];
            if (opportunity.AccountId != null)
            {
                List<Contact> contacts = [SELECT Id, Name, Account.Name, Account.Customer_Number__c FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :opportunity.AccountId) AND Inactive_Contact__c = false];
                for(Contact c : contacts){
                    if (!uniqueContacts.contains(c))
                    {
                        uniqueContacts.add(c); 
                    }    
                }
            }
            if (opportunity.Building_Owner__c != null)
            {
                List<Contact> contacts = [SELECT Id, Name, Account.Name, Account.Customer_Number__c FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :opportunity.Building_Owner__c) AND Inactive_Contact__c = false];
                for(Contact c : contacts){
                    if (!uniqueContacts.contains(c))
                    {
                        uniqueContacts.add(c); 
                    }    
                }
            }
            if (opportunity.Building_Owner_Parent__c != null)
            {
                List<Contact> contacts = [SELECT Id, Name, Account.Name, Account.Customer_Number__c FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :opportunity.Building_Owner_Parent__c) AND Inactive_Contact__c = false];
                for(Contact c : contacts){
                    if (!uniqueContacts.contains(c))
                    {
                        uniqueContacts.add(c); 
                    }    
                }
            }
        }

        allContacts.addAll(uniqueContacts);
        allContacts.sort();

        return allContacts;
    }

    @AuraEnabled(Cacheable = true)
    public static string GetAccountName(string recordId)
    {
        return [SELECT Name FROM Account WHERE Id = :recordId].Name;
    }

    
    @AuraEnabled(Cacheable = true)
    public static Opportunity GetOpportunity(string recordId)
    {
        return [SELECT Name, AccountId, Account.Name, Converted_Lead__c FROM Opportunity WHERE Id = :recordId];
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> ContactSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds, 
        string accountId, string opportunityId) 
    {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:contact';
        String opportunityAccountId = '';
        if (opportunityId != '')
        {
            string oppAccountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;
            opportunityAccountId = oppAccountId;
        }
        List<Contact> contacts;
        if (accountId != '' && opportunityAccountId == '')
        {
            contacts = [SELECT Id, Name, Email FROM Contact WHERE Name LIKE :key AND AccountId = :accountId AND Inactive_Contact__c = false LIMIT 50];
        }
        else if (accountId == '' && opportunityAccountId != '')
        {
            contacts = [SELECT Id, Name, Email FROM Contact WHERE Name LIKE :key AND AccountId = :opportunityAccountId AND Inactive_Contact__c = false LIMIT 50];
        }
        else
        {
            contacts = [SELECT Id, Name, Email FROM Contact WHERE Name LIKE :key AND (AccountId = :accountId OR AccountId = :opportunityAccountId) AND Inactive_Contact__c = false LIMIT 50];
        }
       
        for (Contact contact : contacts) {

            String fullname = contact.Name;
            String id = contact.Id;
            String subtitle = contact.Email;
                
            results.add(new LookupSearchResult(id, 'contact', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> OpportunitySearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:opportunity';
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE Name LIKE :key OR Project_Number__c LIKE :key LIMIT 50];

        for (Opportunity opportunity : opportunities) {

            String fullname = opportunity.Name;
            String id = opportunity.Id;
            String subtitle = '';
                
            results.add(new LookupSearchResult(id, 'opportunity', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List<String> GetDesiredShippingMethodPicklist(){
        return picklist_values('Sample_Request__c','Desired_Shipping_Method__c');
    }

    @AuraEnabled
    public static List<String> GetShipToPicklist(){
        return picklist_values('Sample_Request__c','Ship_To__c');
    }

    @AuraEnabled
    public static List<String> GetTypePicklist(){
        return picklist_values('Sample_Request__c','Type__c');
    }

    private static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue() + '|' + entry.getLabel());}
            }
        }
        return values;
    }
}