public with sharing class NewBidderHelper {

    @AuraEnabled
    public static List<Account> GetAccountsOnConstructionProject(string recordId){
        Construction_Project__c cp = [SELECT Id, Ultimate_Parent__c, Parent_Account__c, General_Contractor__c, 
                                             Project_Owner_Company__c, Architect_Firm__c, Building_Owner__c
                                      FROM Construction_Project__c
                                      WHERE Id = :recordId];
        List<Id> accIds = new List<Id>();
        if (cp.Ultimate_Parent__c != null) accIds.add(cp.Ultimate_Parent__c);
        if (cp.Parent_Account__c != null) accIds.add(cp.Parent_Account__c);
        if (cp.General_Contractor__c != null) accIds.add(cp.General_Contractor__c);
        if (cp.Project_Owner_Company__c != null) accIds.add(cp.Project_Owner_Company__c);
        if (cp.Architect_Firm__c != null) accIds.add(cp.Architect_Firm__c);
        if (cp.Building_Owner__c != null) accIds.add(cp.Building_Owner__c);

        return [SELECT Id,Name FROM Account WHERE Id IN :accIds ORDER BY Name ASC];
    }

    @AuraEnabled
    public static string CreateContact(string firstName, string lastName, string email, string ownerId, string accountId)
    {
        try{
            Contact c = new Contact();
            c.FirstName = firstName;
            c.LastName = lastName;
            c.Email = email;
            c.OwnerId = ownerId;
            c.AccountId = accountId;
    
            Account a = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry 
                         FROM Account
                         WHERE Id = :accountId];

            c.MailingStreet = a.ShippingStreet;
            c.MailingCity = a.ShippingCity;
            c.MailingState = a.ShippingState;
            c.MailingPostalCode = a.ShippingPostalCode;
            c.MailingCountry = a.ShippingCountry;

            insert c;
    
            return c.Id;
        }catch(Exception ex)
        {
            return 'Error! ' + ex.getMessage() + ': ' + ex.getStackTraceString();
        }
    }

    @AuraEnabled
    public static List<Division__c> GetDivisionPicklist(){
        return [SELECT Id, Name FROM Division__c];
    }

    @AuraEnabled
    public static List<String> GetDivSectionPicklist(){
        return picklist_values('Bidder__c','Div_Section__c');
    }

    @AuraEnabled
    public static List<String> GetPricingGroupPicklist(){
        return picklist_values('Bidder__c','Pricing_Group__c');
    }

    @AuraEnabled
    public static List<String> GetSourcePicklist(){
        return picklist_values('Bidder__c','Source__c');
    }

    @AuraEnabled
    public static List<String> GetInstallationTypePicklist(){
        return picklist_values('Bidder__c','Installation_Type__c');
    }
    
    @AuraEnabled
    public static List<String> GetQuoteStatusPicklist(){
        return picklist_values('Bidder__c','Quote_Status__c');
    }

    @AuraEnabled
    public static List<Account> GetAccountSearch(String input)
    {
        string searchInput = '%' + input + '%';
        List<Account> results = [SELECT Id, Name, Inactive__c, Customer_Number__c, Territory_Lookup__r.Name, Phone,
                                        RecordType.Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                                FROM Account 
                                WHERE Name like :searchInput 
                                   OR ShippingPostalCode like :searchInput 
                                   OR Customer_Number__c like :searchInput
                                   OR Phone like :searchInput LIMIT 50];
        return results;
    }

    @AuraEnabled
    public static User GetCurrentUser(string userId)
    {
        return [SELECT Email, Name FROM User WHERE Id = :userId LIMIT 1];
    }


    @AuraEnabled
    public static List<string> CreateBidder(string constructionProjectId, string accountId, string contactId, string pricingGroup, 
        string quoteStatus, string source, string installationType, string quoteBidRequestDate, 
        string quoteBidDueDate, List<string> divisions, string divSection)
    {
        try
        {
            List<string> ids = new List<string>();
            List<Bidder__c> bidders = new List<Bidder__c>();
            for(string division: divisions){
                Bidder__c bidder = new Bidder__c();
                
                bidder.Construction_Project__c = constructionProjectId;
                bidder.Bidder__c = accountId;
                bidder.Contact__c = contactId;
                bidder.Source__c = source;
                bidder.Division__c = [SELECT Name FROM Division__c WHERE Id = :division].Name;

                if (pricingGroup != null) bidder.Pricing_Group__c = pricingGroup;
                if (quoteStatus != null) bidder.Quote_Status__c = quoteStatus;
                if (installationType != null) bidder.Installation_Type__c = installationType;
                if (quoteBidRequestDate != null)bidder.ITB_Request_Date__c = date.valueOf(quoteBidRequestDate);
                if (quoteBidDueDate != null) bidder.ITB_Due_Date__c = date.valueOf(quoteBidDueDate);
                if (bidder.Division__c == 'Clickeze') bidder.Div_Section__c = divSection;

                bidders.add(bidder);
            }

            insert bidders;

            for(Bidder__c bidder : bidders)
            {
                ids.add(bidder.Id);
            }

            return ids;
        }
        catch(Exception ex)
        {
            return new List<string>{'Failure',ex.getMessage(),ex.getStackTraceString()};
        }
    }

    private static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getLabel());}
            }
        }
        return values;
    }
}