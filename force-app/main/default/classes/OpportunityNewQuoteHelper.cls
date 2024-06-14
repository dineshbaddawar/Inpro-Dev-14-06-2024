public with sharing class OpportunityNewQuoteHelper {
    @AuraEnabled
    public static string createQuote(string additionalCity, string additionalCountry, string additionalPostalCode, string additionalState, string additionalStreet, string bidQuote,
                                     string contactId, string divisionLookup, Date expirationDate, string inproContract, string name, string oppownersManager,
                                     string opportunityId, string ownerId, string primaryBidder, string priority, string revisionNumber,
                                     string shippingCity, string shippingCountryCode, string shippingPostalCode, string shippingStateCode, string shippingStreet, string versionDescription, string quoteRecipientId) {        
            
        try{
                
                Quote quote = new Quote();
                quote.AdditionalCity = additionalCity;
                quote.AdditionalCountry = additionalCountry;
                quote.AdditionalPostalCode = additionalPostalCode;
                quote.AdditionalState = additionalState;
                quote.AdditionalStreet = additionalStreet;
                quote.BidQuote__c = bidQuote;
                if(contactId != null && contactId != '')
                    quote.ContactId = contactId;
                quote.Division_Lookup__c = divisionLookup;
                quote.ExpirationDate = expirationDate;
                if(inproContract != null && inproContract != '')
                    quote.Inpro_Contract__c = inproContract;
                quote.Name = name;
                if(oppownersManager != null && oppownersManager != '')
                    quote.Opp_Owner_s_Manager__c = oppownersManager;
                quote.OpportunityId = opportunityId;
                if(ownerId != null && ownerId != '')
                quote.OwnerId = ownerId;
                // if(buildingOwner != null && buildingOwner != '')
                //     quote.Building_Owner__c = buildingOwner;                
                quote.Priority__c = priority;
                quote.Revision_Number__c = decimal.valueOf(revisionNumber);
                quote.ShippingCity = shippingCity;
                quote.ShippingCountryCode = shippingCountryCode;
                quote.ShippingPostalCode = shippingPostalCode;
                quote.ShippingStateCode = shippingStateCode;
                quote.ShippingStreet = shippingStreet;
                // if(buildingOwnerParent != null && buildingOwnerParent != '')
                //     quote.Building_Owner_Parent__c = buildingOwnerParent;
                quote.Version_Description__c = versionDescription;           
                quote.Primary_Bidder__c = quoteRecipientId;

                Opportunity Opportunity = [SELECT Building_Owner__r.Customer_Number__c, 
                                                  Building_Owner__r.Parent.Customer_Number__c, Building_Owner__r.Parent.Parent.Customer_Number__c,
                                                  Building_Owner_Parent__r.Customer_Number__c, Building_Owner_Parent__r.Parent.Customer_Number__c
                                           FROM Opportunity
                                           WHERE Id = :opportunityId];
                Account acc = [SELECT Customer_Number__c, Parent.Customer_Number__c, Parent.Parent.Customer_Number__c
                                             FROM Account WHERE Id = :quoteRecipientId];

                string cn1 = Opportunity.Building_Owner__r.Customer_Number__c == null ? '' : Opportunity.Building_Owner__r.Customer_Number__c;
                string cn2 = Opportunity.Building_Owner_Parent__r.Customer_Number__c == null ? '' : Opportunity.Building_Owner_Parent__r.Customer_Number__c;
                string cn3 = acc.Customer_Number__c == null ? '' : acc.Customer_Number__c;
                string cn4 = acc.Parent.Customer_Number__c == null ? '' : acc.Parent.Customer_Number__c;
                string cn5 = acc.Parent.Parent.Customer_Number__c == null ? '' : acc.Parent.Parent.Customer_Number__c;
                string cn6 = Opportunity.Building_Owner__r.Parent.Customer_Number__c == null ? '' : Opportunity.Building_Owner__r.Parent.Customer_Number__c;
                string cn7 = Opportunity.Building_Owner__r.Parent.Parent.Customer_Number__c == null ? '' : Opportunity.Building_Owner__r.Parent.Parent.Customer_Number__c;
                string cn8 = Opportunity.Building_Owner_Parent__r.Customer_Number__c == null ? '' : Opportunity.Building_Owner_Parent__r.Customer_Number__c;
                string cn9 = Opportunity.Building_Owner_Parent__r.Parent.Customer_Number__c == null ? '' : Opportunity.Building_Owner_Parent__r.Parent.Customer_Number__c;

                quote.Pricing_Account_Numbers_Flick__c = 
                    cn1 + ';' +
                    cn2 + ';' +
                    cn3 + ';' +
                    cn4 + ';' +
                    cn5 + ';' +
                    cn6 + ';' +
                    cn7 + ';' +
                    cn8 + ';' +
                    cn9 + ';';

                insert quote;
              //  string screeningResult = DeniedPartyHelper.RunScreeningLogic(quoteRecipientId);

                return quote.Id;
        }
        catch(Exception ex)
        {
            system.debug('Error! ' + ex.getMessage());
            return 'Error! ' + ex.getMessage();
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
        Opportunity opp = 
            [SELECT Id, Account.Id, Account.Name, Account.Status__c, 
                Construction_Project__c, Is_Estimate_Required__c, Project_Number__c, City__c, 
                Country__c, Zip__c, State__c, Street_Address__c, Division_Lookup__r.Id, Owner.Manager.Id,
                Owner.IsActive, OwnerId, Country_Code__c, State_Code__c, Building_Owner__c, 
                Building_Owner_Parent__c, Building_Owner__r.Name 
             FROM Opportunity 
             WHERE Id = :recordId 
             LIMIT 1];
        return opp;    
    }

    @AuraEnabled
    public static Construction_Project__c getConstructionProject(String Id){
        return [SELECT Id, General_Contractor__r.Id FROM Construction_Project__c WHERE Id = :Id];
    }
    @AuraEnabled
    public static List<Account> getAccountAddress(String accountId){
        String Query = 'SELECT Id, ShippingCity, ShippingStreet, ShippingCountryCode, ShippingPostalCode, ShippingStateCode FROM Account WHERE Id = :accountId LIMIT 1';
        List<Account> Accounts = Database.query(Query);
        return Accounts;    
    }

    @AuraEnabled
    public static List<Bidder__c> getOpportunityBidders(String opportunityId){
        List<Bidder__c> Bidders = 
            [SELECT Id, Bidder__r.Id, Bidder__r.Name 
            FROM Bidder__c 
            WHERE Opportunity__c = :opportunityId AND (Bidder__r.Status__c = 'Customer' OR Bidder__r.Status__c = 'Approved') 
            ORDER BY Bidder__r.Name];

        return Bidders;    
    }

    @AuraEnabled
    public static List<Contact> getContacts(string accountId)
    {
        // List<Bidder__c> bidders = 
        //     [SELECT Id, Bidder__c
        //     FROM Bidder__c 
        //     WHERE Opportunity__c = :id AND (Bidder__r.Status__c = 'Customer' OR Bidder__r.Status__c = 'Approved') 
        //     ORDER BY Bidder__r.Name];

        // List<Id> bidderIds = new List<Id>();
        
        // for(Bidder__c bidder : bidders)
        // {
        //     bidderIds.add(bidder.Bidder__c);
        // }

        // if(buildingOwnerId != null && buildingOwnerId != '' && !bidderIds.contains(buildingOwnerId))
        //     bidderIds.add(buildingOwnerId);
        // if(originalBidderId != null && originalBidderId != '' && !bidderIds.contains(originalBidderId))
        //     bidderIds.add(originalBidderId);

        List<Contact> Contacts = 
            [SELECT Id, Name 
            FROM Contact 
            WHERE AccountId = :accountId AND Inactive_Contact__c = false
            ORDER BY Name];

        return Contacts;    
    }

    @AuraEnabled
    public static List<Contract__c> getContracts(String accountId){
        String Query = 'SELECT Id, Name, Contract_Name__c, Account__r.Name FROM Contract__c WHERE Account__c = :accountId AND Status__c != \'Rejected\'';
        List<Contract__c> Contracts = Database.query(Query);
        return Contracts;    
    }

    @AuraEnabled
    public static Boolean isUserEstimator(String userId){
        String Query = 'SELECT Id FROM Profile WHERE Name = \'Inpro - Estimating\'';
        List<Profile> Profiles = Database.query(Query);
        if(Profiles.size() > 0)            
        {
            string estimatingProfileId = Profiles[0].Id;
            String Query2 = 'SELECT Id FROM User WHERE Id = :userId AND ProfileId = :estimatingProfileId';
            List<User> Users = Database.query(Query2);
            if(Users.size() > 0)            
            {
                return true;
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }
}