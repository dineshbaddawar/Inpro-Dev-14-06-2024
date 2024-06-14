public with sharing class AccountNewOpportunityHelper {

    @AuraEnabled
    public static Account GetAccountDetails(string accountId){
        Account account = [SELECT Id, Name, ParentId, AccountNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
            ShippingCountry, RecordTypeId, Category__c, Market_Segment__c, Sub_Segment__c FROM Account WHERE Id = :accountId];
        return account;
    }

    @AuraEnabled
    public static Construction_Project__c GetConstructionProject(string recordId){
        try {
            Construction_Project__c cp = 
                [SELECT Id, General_Contractor__c, Architect_Firm__c, Building_Owner__c, Bid_Date_GC_to_Owner__c,
                    Street_Address__c, City__c, State__c, ZIP__c, Country__c, Market_Segment__c, Sub_Segment__c
                FROM Construction_Project__c 
                WHERE Id = :recordId];
            return cp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string GetConstructionProjectAccountId(string recordId){
        try {
            Construction_Project__c cp = [SELECT Id, General_Contractor__c, Architect_Firm__c, Building_Owner__c FROM Construction_Project__c WHERE Id = :recordId];
            string B = cp.Building_Owner__c == null ? '' : cp.Building_Owner__c;
            string A = cp.Architect_Firm__c == null ? '' : cp.Architect_Firm__c;
            string C = cp.General_Contractor__c == null ? '' : cp.General_Contractor__c;
            
            if (A != '' && B == '' && C == '') return A;
            else if (A == '' && B != '' && C == '') return B;
            else if (A == '' && B == '' && C != '') return C;
            else if (A != '' && B != '' && C == '') return A;
            else if (A == '' && B != '' && C != '') return C;
            else if (A != '' && B != '' && C != '') return C;
            else if (A != '' && B == '' && C != '') return c;
            else return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Account GetParentAccountDetails(string accountId)
    {
        Account account = [SELECT Id, ParentId FROM Account Where Id = :accountId];
        if (account.ParentId != null)
        {
            Account parentAccount = [SELECT Id, Name, AccountNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
                ShippingCountry, RecordTypeId, Category__c, Market_Segment__c, Sub_Segment__c FROM Account WHERE Id = :account.ParentId];
            return parentAccount;
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static string GetRecordTypeWrapper(){
        string arcId = GetRecordTypeId('Architect_Specifier');
        string boId = GetRecordTypeId('Building_Owner');
        string comId = GetRecordTypeId('Competitor');
        string disId = GetRecordTypeId('Distributor');
        string gcId = GetRecordTypeId('General_Contractor');
        string scId = GetRecordTypeId('Specialty_Contractor');
        string gpoId = GetRecordTypeId('Group_Purchasing_Organization');
        return JSON.serialize(new AccountRecordTypeWrapper(arcId,boId,comId,disId,gcId,scId,gpoId));
    }
    @AuraEnabled
    public static string GetRecordTypeId(String name){
        Id buildingOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(name).getRecordTypeId();
        return String.valueOf(buildingOwnerRecordTypeId);
    }

    @AuraEnabled
    public static string GetBuildingOwnerRecordTypeId(){
        Id buildingOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Building_Owner').getRecordTypeId();
        return String.valueOf(buildingOwnerRecordTypeId);
    }

    @AuraEnabled
    public static string CreateOpportunity(String buildingOwner, String buildingOwnerParent, String originalAccount, string constructionProject, string bidderContact, 
        String buildingOwnerContactRequired, String buildingOwnerContact, String division,
        String opportunityName, String divSection, String marketSegment, String estCloseDate, String subSegment, String oppDate,
        String leadSource, String estimateRequired, String leadSourceDetails, String largeProject,
        String isrComments, String isOpportunity, String category, 
        Boolean isBuildingOwner,
        String addressStreet, String addressCity, String addressState, String addressZip, String addressCountry,
        Boolean needsTerritoryReview,
        String userId, String arcFac)
    {
        try{
            //Check missing fields
            String errorMessage = '';
            Boolean hasError = false;

            if (!isBuildingOwner && ((addressCountry == 'Australia' || addressCountry == 'Canada' || addressCountry == 'China' || 
            addressCountry == 'Ireland' || addressCountry == 'Italy' || addressCountry == 'United States')&& (addressState == null || addressState.trim() == '')))
            {
                hasError = true;
                errorMessage += '\r\n Please provide a state/province value.';
            }
            if (!isBuildingOwner && addressZip.trim() == '')
            {
                hasError = true;
                errorMessage += '\r\n Please provide a zipcode value.';
            }
            if (!isBuildingOwner && addressCountry.trim() == '')
            {
                hasError = true;
                errorMessage += '\r\n Please provide a country value.';
            }
            if (division == null || division.trim() == ''){
                hasError = true;
                errorMessage += '\r\n Division is missing.';
            }
            if (bidderContact == '' || bidderContact == null){
                hasError = true;
                errorMessage += '\r\n Bidder contact is missing.';
            }
            if (marketSegment == '' || marketSegment == null){
                hasError = true;
                errorMessage += '\r\n Market Segment is missing.';
            }
            if (subSegment == '' || subSegment == null){
                hasError = true;
                errorMessage += '\r\n Sub-Segment is missing.';
            }
            if (estCloseDate == '' || estCloseDate == null){
                hasError = true;
                errorMessage += '\r\n Est. Close Date is missing.';
            }
            if ((oppDate == '' || oppDate == null) && estimateRequired == 'false'){
                hasError = true;
                errorMessage += '\r\n Bid Date, GC to Owner is missing.';
            }
            if (opportunityName == '' || opportunityName == null){
                hasError = true;
                errorMessage += '\r\n Opportunity Name is missing.';
            }
            
            if (division == [SELECT Id,Name FROM Division__c WHERE Name = 'Clickeze'].Id && (divSection == '' || divSection == null))
            {
                hasError = true;
                errorMessage += '\r\n Clickeze requires a Div Section.';
            }
            if ((division == [SELECT Id,Name FROM Division__c WHERE Name = 'IPC'].Id || division == [SELECT Id,Name FROM Division__c WHERE Name = 'Clickeze'].Id) && (arcFac == '' || arcFac == null))
            {
                hasError = true;
                errorMessage += '\r\n IPC/Clickeze requires a Arc/Fac.';
            }

            if (hasError)
            {
                return 'Error! Some fields are missing:\r\n' + errorMessage;
            }
            else {                 
                //If all required fields are present, create opportunity.
                string divisionName = [SELECT Id, Name FROM Division__c WHERE Id = :division].Name;
                Opportunity opp = new Opportunity();
                opp.Building_Owner__c = buildingOwner;
                opp.Building_Owner_Parent__c = buildingOwnerParent;
                opp.AccountId = originalAccount;
                opp.Construction_Project__c = constructionProject;
                opp.Contact__c = bidderContact;
                opp.Division__c = divisionName;
                opp.Name = opportunityName;
                opp.Div_Section__c = divSection;

                //Opp Owner assignment logic
                Account acc = [SELECT Id, Territory_Lookup__c, ARC_FAC__c, ShippingPostalCode, ShippingState FROM Account WHERE Id = :originalAccount];
                string territoryId;
                if (acc.Territory_Lookup__c == null && addressCountry != 'United States'&& addressCountry != 'Canada')
                {
                    opp.OwnerId = userId;
                }
                territoryId = TerritoryHelper.getTerritoryId(addressZip, addressState);
                
                opp.Market_Segment__c = getPicklistValue('Opportunity','Market_Segment__c',marketSegment);
                if (estCloseDate != null ) opp.CloseDate = date.valueOf(estCloseDate);
                opp.Sub_Segment__c = subSegment;
                if (oppDate != null) 
                    opp.Bid_Date_GC_to_Owner__c = DateTime.ValueofGmt(oppDate.replace('T', ' '));//date.valueOf(oppDate);
                if (needsTerritoryReview) opp.Territory_Review_Needed__c = true;
                if (territoryId != null && territoryId != '') opp.Territory__c = territoryId;
                opp.LeadSource = leadSource;
                opp.Is_Estimate_Required__c = estimateRequired == 'true';
                opp.Lead_Source_Details__c = leadSourceDetails;
                opp.Large_Project__c = largeProject == 'true';
                opp.ISR_Comments__c = isrComments;
                opp.Is_Opportunity__c = isOpportunity;
                
                opp.Street_Address__c = addressStreet;
                opp.City__c = addressCity;
                if(addressState != null)
                    opp.State__c = addressState;
                opp.Zip__c = addressZip;
                opp.Country__c = addressCountry;
                opp.ARC_FAC__c = arcFac;
                if(buildingOwnerContactRequired == 'true' && buildingOwnerContact != null && buildingOwnerContact != '')
                {
                    opp.Building_Owner_Contact__c = buildingOwnerContact;
                } 

                if (category != null) opp.Category__c = category;
                if (estimateRequired == 'true') opp.StageName = 'Estimating';
                else opp.StageName = 'Quoting/Bidding';
                insert opp;

                if (constructionProject != null && constructionProject != '')
                {
                    List<Bidder__c> divisionalBidders = GetDivisionalBidders(constructionProject, divisionName);

                    if(divisionalBidders != null && divisionalBidders.size() > 0)
                    {
                        for(Bidder__c b : divisionalBidders)
                        {
                            b.Opportunity__c = opp.Id;
                        }
                        update divisionalBidders;
                    }
                }
                List<Id> ids = new List<Id>();
                ids.add(Id.valueOf(opp.Id));
                if (!Test.isRunningTest()) TerritoryHelper.updateTerritory('Opportunity', opp.Zip__c, opp.State__c, opp.Country__c, ids);
                //string screeningResult = DeniedPartyHelper.RunScreeningLogic(originalAccount);
                return opp.Id;
            }
        }
        catch(Exception ex)
        {
            return 'Error! ' + ex.getMessage() + ', ' + ex.getStackTraceString();
        }
    }

    @AuraEnabled
    public static List<Contact> GetContactsFromAccounts(string buildingOwner, string originalAccount){
        List<Contact> allContacts = new List<Contact>();

        Set<Contact> uniqueContacts = new Set<Contact>();
        
        if (originalAccount != null && originalAccount != '')
        {
            uniqueContacts.addAll([SELECT Name, Id FROM Contact WHERE AccountId = :originalAccount AND Inactive_Contact__c = false]);
        }
        else 
        {
            if (buildingOwner != null && buildingOwner != '')
            {
                uniqueContacts.addAll([SELECT Name, Id FROM Contact WHERE AccountId = :buildingOwner AND Inactive_Contact__c = false]);
            }
            if (originalAccount != null && originalAccount != '')
            {
                uniqueContacts.addAll([SELECT Name, Id FROM Contact WHERE AccountId = :originalAccount AND Inactive_Contact__c = false]);
            }
        }

        allContacts.addAll(uniqueContacts);
        allContacts.sort();

        return allContacts;
    }

    @AuraEnabled
    public static List<Division__c> GetDivisions(){
        List<Division__c> divisions = [SELECT Id, Name FROM Division__c WHERE Active__c = true ORDER BY Name ASC];
        return divisions;
    }

    @AuraEnabled
    public static List<Bidder__c> GetDivisionalBidders(string constructionProjectId, string division){
        List<Bidder__c> bidders = [SELECT Id, Name FROM Bidder__c WHERE Construction_Project__c = :constructionProjectId and Division__c = :division];
        return bidders;
    }

    @AuraEnabled
    public static List<String> GetDivSections(){
        return picklist_values('Opportunity','Div_Section__c');
    }

    @AuraEnabled
    public static List<String> GetLeadSources(){
        return picklist_values('Opportunity','LeadSource');
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> AccountBuildingOwnerParentSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds)
    {
        return AccountSearchQuery(searchTerm, secondarySearchTerm, selectedIds, true, true);
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> AccountBuildingOwnerSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds)
    {
        return AccountSearchQuery(searchTerm, secondarySearchTerm, selectedIds, false, true);
    }
    
    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> AccountSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        return AccountSearchQuery(searchTerm, secondarySearchTerm, selectedIds, false, false);
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> ContactSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:contact';
        List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Name LIKE :key  AND Inactive_Contact__c = false LIMIT 50];

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
    public static List <LookupSearchResult> UserSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';
        List<User> users = [SELECT Id, Name, Email FROM User WHERE Name LIKE :key LIMIT 50];

        for (User user : users) {

            String fullname = user.Name;
            String id = user.Id;
            String subtitle = user.Email;
                
            results.add(new LookupSearchResult(id, 'user', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> ConstructionProjectSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';      
        String Query = 'select id, name, Parent_Account__c from construction_project__c where name like :key';

        Query += ' LIMIT 50';
        // Prepare results
        List < LookupSearchResult > results = new List < LookupSearchResult > ();

        String icon = 'custom:custom24';
        for (sObject so: Database.Query(Query)) {

            String fullname = (String)so.get('name');
            String id = (String) so.get('id');
            String subtitle = (String)so.get('Parent_Account__c');
                
            results.add(new LookupSearchResult(id, 'construction_project__c', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List<String> GetMarketSegments(string accountId){  
        Account test = [SELECT Id, RecordType.Name FROM Account WHERE Id = :accountId];
        //return picklist_values('Account','Market_Segment__c');
        return new List<String>{
            'Commercial Office',
            'Education',
            'Entertainment',
            'Government (Non VA)',
            'Healthcare',
            'Hospitality',
            'Industrial',
            'Interior Design Firm',
            'Maritime Industries',
            'Mixed Use',
            'Multifamily',
            'Religious Organization',
            'Residential',
            'Restaurant',
            'Retail',
            'Transit'
        };
    }

    @AuraEnabled
    public static List<String> GetCategories(){
        return picklist_values('Account','Category__c');
    }

    @AuraEnabled
    public static List<String> GetCountries(){
        return country_values();
    }

    @AuraEnabled
    public static List<String> GetStates(string country){
        return get_state_values(country);
    }

    @AuraEnabled
    public static List<String> GetSubSegmentValues(string marketSegment){
        Map<String,List<String>> allValues = getDependentPicklistValues(Account.Sub_Segment__c);
        return allValues.get(marketSegment);
    }

    //Helper Methods
    private static List<LookupSearchResult> AccountSearchQuery(string SearchTerm, string secondarySearchTerm, List<String> selectedIds, Boolean IsParent, Boolean IsBuildingOwner)
    {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';      
        String Query = 'select id, name, Customer_Number__c from account where Inactive__c = false and (name like :key or Customer_Number__c like :key)';
        if (isBuildingOwner)
        {
            Query += ' AND RecordType.Name = \'Building Owner\'';
        } 
        if (isParent)
        {
            Query += ' AND Is_Parent__c = true';
        }

        Query += ' LIMIT 50';
        // Prepare results
        List < LookupSearchResult > results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String fullname = (String)so.get('name');
            String id = (String) so.get('id');
            String subtitle = (String)so.get('Customer_Number__c');
                
            results.add(new LookupSearchResult(id, 'account', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }
    
    public static String[] get_state_values(string country){
        String[] states = new String[]{};
        if (country == 'Australia')
        {
            states.add('Australian Capital Territory|ACT');
            states.add('New South Wales|NSW');
            states.add('Northern Territory|NT');
            states.add('Queensland|QLD');
            states.add('South Australia|SA');
            states.add('Tasmania|TAS');
            states.add('Victoria|VIC');
            states.add('Western Australia|WA');
        }
        else if (country == 'Canada' || country == 'CA')
        {
            states.add('Alberta|AB');
            states.add('British Columbia|BC');
            states.add('Manitoba|MB');
            states.add('New Brunswick|NB');
            states.add('Newfoundland and Labrador|NL');
            states.add('Nova Scotia|NS');
            states.add('Northwest Territories|NT');
            states.add('Nunavut|NU');
            states.add('Ontario|ON');
            states.add('Prince Edward Island|PE');
            states.add('Quebec|QC');
            states.add('Saskatchewan|SK');
            states.add('Yukon Territories|YT');
        }
        else if (country == 'China')
        {
            states.add('Beijing|11');
            states.add('Tianjin|12');
            states.add('Hebei|13');
            states.add('Shanxi|14');
            states.add('Nei Mongol|15');
            states.add('Liaoning|21');
            states.add('Jilin|22');
            states.add('Heilongjiang|23');
            states.add('Shanghai|31');
            states.add('Jiangsu|32');
            states.add('Zhejiang|33');
            states.add('Anhui|34');
            states.add('Fujian|35');
            states.add('Jiangxi|36');
            states.add('Shandong|37');
            states.add('Henan|41');
            states.add('Hubei|42');
            states.add('Hunan|43');
            states.add('Guangdong|44');
            states.add('Guangxi|45');
            states.add('Hainan|46');
            states.add('Chongqing|50');
            states.add('Sichuan|51');
            states.add('Guizhou|52');
            states.add('Yunnan|53');
            states.add('Xizang|54');
            states.add('Shaanxi|61');
            states.add('Gansu|62');
            states.add('Qinghai|63');
            states.add('Ningxia|64');
            states.add('Xinjiang|65');
            states.add('Chinese Taipei|71');
            states.add('Hong Kong|91');
            states.add('Macao|92');
        }
        else if (country == 'Ireland')
        {
            states.add('Clare|CE');
            states.add('Cavan|CN');
            states.add('Cork|CO');
            states.add('Carlow|CW');
            states.add('Dublin|D');
            states.add('Donegal|DL');
            states.add('Galway|G');
            states.add('Kildare|KE');
            states.add('Kilkenny|KK');
            states.add('Kerry|KY');
            states.add('Longford|LD');
            states.add('Louth|LH');
            states.add('Limerick|LK');
            states.add('Leitrim|LM');
            states.add('Laois|LS');
            states.add('Meath|MH');
            states.add('Monaghan|MN');
            states.add('Mayo|MO');
            states.add('Offaly|OY');
            states.add('Roscommon|RN');
            states.add('Sligo|SO');
            states.add('Tipperary|TA');
            states.add('Waterford|WD');
            states.add('Westmeath|WH');
            states.add('Wicklow|WW');
            states.add('Wexford|WX');
        }
        else if (country == 'Italy')
        {
            states.add('Agrigento|AG');
            states.add('Alessandria|AL');
            states.add('Ancona|AN');
            states.add('Aosta|AO');
            states.add('Ascoli Piceno|AP');
            states.add('L\'Aquila|AQ');
            states.add('Arezzo|AR');
            states.add('Asti|AT');
            states.add('Avellino|AV');
            states.add('Bari|BA');
            states.add('Bergamo|BG');
            states.add('Biella|BI');
            states.add('Belluno|BL');
            states.add('Benevento|BN');
            states.add('Bologna|BO');
            states.add('Brindisi|BR');
            states.add('Brescia|BS');
            states.add('Barletta-Andria-Trani|BT');
            states.add('Bolzano|BZ');
            states.add('Cagliari|CA');
            states.add('Campobasso|CB');
            states.add('Caserta|CE');
            states.add('Chieti|CH');
            states.add('Carbonia-Iglesias|CI');
            states.add('Caltanissetta|CL');
            states.add('Cuneo|CN');
            states.add('Como|CO');
            states.add('Cremona|CR');
            states.add('Cosenza|CS');
            states.add('Catania|CT');
            states.add('Catanzaro|CZ');
            states.add('Enna|EN');
            states.add('Forlì-Cesena|FC');
            states.add('Ferrara|FE');
            states.add('Foggia|FG');
            states.add('Florence|FI');
            states.add('Fermo|FM');
            states.add('Frosinone|FR');
            states.add('Genoa|GE');
            states.add('Gorizia|GO');
            states.add('Grosseto|GR');
            states.add('Imperia|IM');
            states.add('Isernia|IS');
            states.add('Crotone|KR');
            states.add('Lecco|LC');
            states.add('Lecce|LE');
            states.add('Livorno|LI');
            states.add('Lodi|LO');
            states.add('Latina|LT');
            states.add('Lucca|LU');
            states.add('Monza and Brianza|MB');
            states.add('Macerata|MC');
            states.add('Messina|ME');
            states.add('Milan|MI');
            states.add('Mantua|MN');
            states.add('Modena|MO');
            states.add('Massa and Carrara|MS');
            states.add('Matera|MT');
            states.add('Naples|NA');
            states.add('Novara|NO');
            states.add('Nuoro|NU');
            states.add('Ogliastra|OG');
            states.add('Oristano|OR');
            states.add('Olbia-Tempio|OT');
            states.add('Palermo|PA');
            states.add('Piacenza|PC');
            states.add('Padua|PD');
            states.add('Pescara|PE');
            states.add('Perugia|PG');
            states.add('Pisa|PI');
            states.add('Pordenone|PN');
            states.add('Prato|PO');
            states.add('Parma|PR');
            states.add('Pistoia|PT');
            states.add('Pesaro and Urbino|PU');
            states.add('Pavia|PV');
            states.add('Potenza|PZ');
            states.add('Ravenna|RA');
            states.add('Reggio Calabria|RC');
            states.add('Reggio Emilia|RE');
            states.add('Ragusa|RG');
            states.add('Rieti|RI');
            states.add('Rome|RM');
            states.add('Rimini|RN');
            states.add('Rovigo|RO');
            states.add('Salerno|SA');
            states.add('Siena|SI');
            states.add('Sondrio|SO');
            states.add('La Spezia|SP');
            states.add('Syracuse|SR');
            states.add('Sassari|SS');
            states.add('Savona|SV');
            states.add('Taranto|TA');
            states.add('Teramo|TE');
            states.add('Trento|TN');
            states.add('Turin|TO');
            states.add('Trapani|TP');
            states.add('Terni|TR');
            states.add('Trieste|TS');
            states.add('Treviso|TV');
            states.add('Udine|UD');
            states.add('Varese|VA');
            states.add('Verbano-Cusio-Ossola|VB');
            states.add('Vercelli|VC');
            states.add('Venice|VE');
            states.add('Vicenza|VI');
            states.add('Verona|VR');
            states.add('Medio Campidano|VS');
            states.add('Viterbo|VT');
            states.add('Vibo Valentia|VV');
        }
        else if (country == 'United States' || country == 'US')
        {
            states.add('Armed Forces Americas|AA');
            states.add('Armed Forces Europe|AE');
            states.add('Alaska|AK');
            states.add('Alabama|AL');
            states.add('Armed Forces Pacific|AP');
            states.add('Arkansas|AR');
            states.add('American Samoa|AS');
            states.add('Arizona|AZ');
            states.add('California|CA');
            states.add('Colorado|CO');
            states.add('Connecticut|CT');
            states.add('District of Columbia|DC');
            states.add('Delaware|DE');
            states.add('Florida|FL');
            states.add('Federated Micronesia|FM');
            states.add('Georgia|GA');
            states.add('Guam|GU');
            states.add('Hawaii|HI');
            states.add('Iowa|IA');
            states.add('Idaho|ID');
            states.add('Illinois|IL');
            states.add('Indiana|IN');
            states.add('Kansas|KS');
            states.add('Kentucky|KY');
            states.add('Louisiana|LA');
            states.add('Massachusetts|MA');
            states.add('Maryland|MD');
            states.add('Maine|ME');
            states.add('Marshall Islands|MH');
            states.add('Michigan|MI');
            states.add('Minnesota|MN');
            states.add('Missouri|MO');
            states.add('Northern Mariana Islands|MP');
            states.add('Mississippi|MS');
            states.add('Montana|MT');
            states.add('North Carolina|NC');
            states.add('North Dakota|ND');
            states.add('Nebraska|NE');
            states.add('New Hampshire|NH');
            states.add('New Jersey|NJ');
            states.add('New Mexico|NM');
            states.add('Nevada|NV');
            states.add('New York|NY');
            states.add('Ohio|OH');
            states.add('Oklahoma|OK');
            states.add('Oregon|OR');
            states.add('Pennsylvania|PA');
            states.add('Puerto Rico|PR');
            states.add('Palau|PW');
            states.add('Rhode Island|RI');
            states.add('South Carolina|SC');
            states.add('South Dakota|SD');
            states.add('Tennessee|TN');
            states.add('Texas|TX');
            states.add('United States Minor Outlying Islands|UM');
            states.add('Utah|UT');
            states.add('Virginia|VA');
            states.add('US Virgin Islands|VI');
            states.add('Vermont|VT');
            states.add('Washington|WA');
            states.add('Wisconsin|WI');
            states.add('West Virginia|WV');
            states.add('Wyoming|WY');
        }
        return states;
    }

    public static String[] country_values()
    {
        Schema.sObjectType objType = Contact.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('MailingCountryCode').getDescribe().getPickListValues();

        List<SelectOption> options = new List<SelectOption>();
        String[] v2 = new String[]{};
        for (Schema.PicklistEntry v : values){
            v2.add(v.getLabel() + '|' + v.getValue());
        }
        return v2;
    }

    //Copied from https://developer.salesforce.com/forums/?id=906F0000000D6l3IAC
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

    private static String getPicklistValue(String object_name, String field_name, String label)
    {
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive() && entry.getLabel() == label) return entry.getValue();
            }
        }
        return '';
    }

    

    //Copied from https://salesforceprofs.com/how-to-get-dependent-picklist-values-in-apex/
    private static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
}