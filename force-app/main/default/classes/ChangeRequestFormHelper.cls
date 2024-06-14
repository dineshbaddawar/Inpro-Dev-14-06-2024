public with sharing class ChangeRequestFormHelper {
    
    @AuraEnabled
    public static Account GetAccount(string recordId){
        try {
            Account a = 
                [SELECT Name, AKA_Former_Name__c, ParentId, Parent.Name, Customer_Number__c, Dodge_Company_ID__c, Inactive__c, CIA__c, 
                        Sync_GPO_Pricing__c, Sync_Price_Level__c, Market_Segment__c, Sub_Segment__c, ARC_FAC__c, Category__c,
                        Level__c, National_Territory__c, Territory_Lookup__c, Price_Level__c, Phone, Website, Balance__c,
                        Credit_Application_Received__c, Available_Credit__c, of_Open_Orders__c, Open_Order_Value__c,
                        Credit_Hold__c, Credit_Limit__c, Payment_Terms__c, Hard_Copy_PO_Required__c, NetSuite_Add_Date__c,
                        Last_Call_Date__c, Last_Call_or_Visit_Date__c, Last_Visit_Date__c, Last_Sample_Date__c, Collector__r.Name,
                        Description, Collector__c, Invoice_Email__c, Salesforce_Maps_Overridden_Finance__c, V_A_T_Number__c,
                        Point_of_Contact__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStreet,
                        BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet, Status__c, 
                        Territory_Lookup__r.Name, Point_of_Contact__r.Name, RecordTypeId, Lock_Price_Level__c
                FROM Account 
                WHERE Id = :recordId];
            return a;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Contact> GetContacts(string accountId){
        try {
            List<Contact> a = 
                [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Phone, Name
                FROM Contact 
                WHERE AccountId = :accountId ORDER BY Name];
            return a;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AccountPicklistResult GetAccountPicklistValues(){
        try {
            AccountPicklistResult result = new AccountPicklistResult();
            result.arcFacOptions = new List<string>();
            result.marketSegmentOptions = new List<string>();
            result.subSegmentOptions = new List<string>();
            result.categoryOptions = new List<string>();
            result.levelOptions = new List<string>();
            result.nationalTerritoryOptions = new List<string>();
            result.priceLevelOptions = new List<string>();
            result.stateOptions = new List<string>();
            result.countryOptions = new List<string>();
            result.paymentTermsOptions = new List<string>();
           
            Schema.DescribeFieldResult arcFacFieldResult = Account.ARC_FAC__c.getDescribe();
            List<Schema.PicklistEntry> arcFacPle = arcFacFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : arcFacPle){
                result.arcFacOptions.add(pickListVal.getLabel());
            }

            // Schema.DescribeFieldResult marketSegmentFieldResult = Account.Market_Segment__c.getDescribe();
            // List<Schema.PicklistEntry> marketSegmentPle = marketSegmentFieldResult.getPicklistValues();
            // for( Schema.PicklistEntry pickListVal : marketSegmentPle){
            //     result.marketSegmentOptions.add(pickListVal.getLabel());
            // }

            // Schema.DescribeFieldResult subSegmentFieldResult = Account.Sub_Segment__c.getDescribe();
            // List<Schema.PicklistEntry> subSegmentPle = subSegmentFieldResult.getPicklistValues();
            // for( Schema.PicklistEntry pickListVal : subSegmentPle){
            //     result.subSegmentOptions.add(pickListVal.getLabel());
            // }

            Schema.DescribeFieldResult categoryFieldResult = Account.Category__c.getDescribe();
            List<Schema.PicklistEntry> categoryPle = categoryFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : categoryPle){
                result.categoryOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult levelFieldResult = Account.Level__c.getDescribe();
            List<Schema.PicklistEntry> levelPle = levelFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : levelPle){
                result.levelOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult nationalTerritoryFieldResult = Account.National_Territory__c.getDescribe();
            List<Schema.PicklistEntry> nationalTerritoryPle = nationalTerritoryFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : nationalTerritoryPle){
                result.nationalTerritoryOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult priceLevelFieldResult = Account.Price_Level__c.getDescribe();
            List<Schema.PicklistEntry> priceLevelPle = priceLevelFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : priceLevelPle){
                result.priceLevelOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult stateFieldResult = Account.BillingState.getDescribe();
            List<Schema.PicklistEntry> statePle = stateFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : statePle){
                result.stateOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult countryFieldResult = Account.BillingCountry.getDescribe();
            List<Schema.PicklistEntry> countryPle = countryFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : countryPle){
                result.countryOptions.add(pickListVal.getLabel());
            }

            Schema.DescribeFieldResult paymentTermsResult = Account.Payment_Terms__c.getDescribe();
            List<Schema.PicklistEntry> paymentTermsPle = paymentTermsResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : paymentTermsPle){
                result.paymentTermsOptions.add(pickListVal.getLabel());
            }
            
            // Account a = 
            // [SELECT Market_Segment__c, Sub_Segment__c, ARC_FAC__c, Category__c,
            //         Level__c, National_Territory__c, Price_Level__c,
            //         BillingState, BillingCountry, Payment_Terms__c
            // FROM Account 
            // LIMIT 1];
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<RecordType> GetRecordTypes(string sObjectType){
        try {
            List<RecordType> accRecordTypes = 
                [SELECT Name, Id
                FROM RecordType
                WHERE SobjectType = :sObjectType];
            return accRecordTypes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PermissionResult GetCurrentUser(string userId){
        try {
            User u = 
                [SELECT Id, Profile.Name, userRole.Name
                FROM User 
                WHERE Id = :userId];
            List<PermissionSetAssignment> permissions = GetUserPermissionSets(userId);
            PermissionResult pr = new PermissionResult();
            if(permissions != null)
                pr.permissionSets = permissions;
            if(u != null)
                pr.retrievedUser = u;
            return pr;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled()
    public static List<PermissionSetAssignment> GetUserPermissionSets(String userId){         
        String qQuery = 'SELECT PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId';
        List<PermissionSetAssignment> permissions = Database.query(qQuery);
        return permissions;    
    }

    @AuraEnabled
    public static string ProcessAccountChanges(ChangeProperties changeProperties, List<AccountContact> selectedContacts, Boolean syncContactPhone, Boolean syncContactAddress, String userId){
        try {
            // if(1 == 1)
            //  return 'Error: ' + changeProperties.phoneNumber;
            Account a = 
                [SELECT Name, AKA_Former_Name__c, ParentId, Parent.Name, Customer_Number__c, Dodge_Company_ID__c, Inactive__c, CIA__c, 
                        Sync_GPO_Pricing__c, Sync_Price_Level__c, Market_Segment__c, Sub_Segment__c, ARC_FAC__c, Category__c,
                        Level__c, National_Territory__c, Territory_Lookup__c, Price_Level__c, Phone, Website, Balance__c,
                        Credit_Application_Received__c, Available_Credit__c, of_Open_Orders__c, Open_Order_Value__c,
                        Credit_Hold__c, Credit_Limit__c, Payment_Terms__c, Hard_Copy_PO_Required__c, NetSuite_Add_Date__c,
                        Last_Call_Date__c, Last_Call_or_Visit_Date__c, Last_Visit_Date__c, Last_Sample_Date__c, Collector__r.Name,
                        Description, Collector__c, Invoice_Email__c, Salesforce_Maps_Overridden_Finance__c, V_A_T_Number__c,
                        Point_of_Contact__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStreet,
                        BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet, Status__c, 
                        Territory_Lookup__r.Name, Point_of_Contact__r.Name, RecordTypeId, Lock_Price_Level__c
                FROM Account 
                WHERE Id = :changeProperties.recordId];

            List<Change_Request_Detail__c> changeDetails = new List<Change_Request_Detail__c>();
            String contactIDString = '';

            Boolean hasNationalAccountUpdatePriv = false;
            Boolean hasParentAccountUpdatePriv = false;
            Boolean isManager = false;
            Boolean needsFinanceApproval = false;
            Boolean needsNationalAccountApproval = false; 
            Boolean isPriceLevelAdmin = false;
            String previousMarketSegment;
            String previousSubSegment;

            if(a.Market_Segment__c != null)
                previousMarketSegment = a.Market_Segment__c;
            if(a.Sub_Segment__c != null)
                previousSubSegment = a.Sub_Segment__c;

            PermissionResult permissionResults = GetCurrentUser(userId);
            if(permissionResults != null && permissionResults.retrievedUser.userRole != null && (permissionResults.retrievedUser.userRole.Name).contains('Exec'))
                isManager = true;

            List<PermissionSetAssignment> userPermissionSets = new List<PermissionSetAssignment>();
            userPermissionSets = GetUserPermissionSets(userId);           

            if(userPermissionSets != null && userPermissionSets.size() > 0)
            {
                for(PermissionSetAssignment p : userPermissionSets)
                {
                    if(p.PermissionSet.Name == 'National_Account_Updates')
                        hasNationalAccountUpdatePriv = true;
                    if(p.PermissionSet.Name == 'Parent_Account_Changes')
                        hasNationalAccountUpdatePriv = true;
                    if(p.PermissionSet.Name == 'Price_Level_Admin')
                        isPriceLevelAdmin = true;
                }
            }

            a.Dodge_Company_ID__c = changeProperties.dodgeCompanyId;
            if(hasNationalAccountUpdatePriv || isManager)
            {
                if(changeProperties.priceLevel != null && changeProperties.priceLevel != '' && changeProperties.priceLevel != 'Please Select' && changeProperties.priceLevel != 'undefined')
                    a.Price_Level__c = changeProperties.priceLevel;
                else {
                    a.Price_Level__c = null;
                }
                if(a.Market_Segment__c == changeProperties.marketSegment && changeProperties.marketSegment != null && changeProperties.marketSegment != '' && changeProperties.marketSegment != 'Please Select' && changeProperties.marketSegment != 'undefined')
                {
                    if(changeProperties.level != null && changeProperties.level != '' && changeProperties.level != 'Please Select' && changeProperties.level != 'undefined')
                        a.Level__c = changeProperties.level;
                    else {
                        a.Level__c = null;
                    }
                    if(changeProperties.nationalTerritory != null && changeProperties.nationalTerritory != '' && changeProperties.nationalTerritory != 'Please Select' && changeProperties.nationalTerritory != 'undefined')
                        a.National_Territory__c = changeProperties.nationalTerritory;
                    else {
                        a.National_Territory__c = null; 
                    }
                }
                a.Sync_Price_Level__c = changeProperties.syncPriceLevel;
                if(changeProperties.parentId != null && changeProperties.parentId != '')
                    a.parentId = changeProperties.parentId;
                else {
                    a.parentId = null;
                }
            }
            if (isPriceLevelAdmin)
            {
                if(changeProperties.priceLevel != null && changeProperties.priceLevel != '' && changeProperties.priceLevel != 'Please Select' && changeProperties.priceLevel != 'undefined')
                    a.Price_Level__c = changeProperties.priceLevel;
                else {
                    a.Price_Level__c = null;
                }
                a.Lock_Price_Level__c = changeProperties.lockPriceLevel;
            }
            if (hasNationalAccountUpdatePriv)
            {
                if(changeProperties.parentId != null && changeProperties.parentId != '')
                    a.parentId = changeProperties.parentId;
                else {
                    a.parentId = null;
                }
            }
            a.Invoice_Email__c = changeProperties.invoiceEmail;
            a.CIA__c = changeProperties.cia;
            a.Sync_GPO_Pricing__c = changeProperties.syncGPOPricing;                              

            // if(changeProperties.arcFac != null && changeProperties.arcFac != '' && changeProperties.arcFac != 'Please Select' && changeProperties.arcFac != 'undefined')
            //     a.ARC_FAC__c = changeProperties.arcFac;
            // else {
            //     a.ARC_FAC__c = null;
            // }

            if(changeProperties.category != null && changeProperties.category != '' && changeProperties.category != 'Please Select' && changeProperties.category != 'undefined')
                a.Category__c = changeProperties.category;
            else {
                a.Category__c = null;
            }

            a.AKA_Former_Name__c = changeProperties.formerName;
            a.Phone = changeProperties.phoneNumber;
            a.Website = changeProperties.website;
            a.Description = changeProperties.description;               
            a.V_A_T_Number__c = changeProperties.vatNumber;

            if(changeProperties.marketSegment != null && previousMarketSegment == null)
                a.Market_Segment__c = changeProperties.marketSegment;
            if(changeProperties.subSegment != null && previousSubSegment == null)
                a.Sub_Segment__c = changeProperties.subSegment;

            if(changeProperties.pointOfContactId != null && changeProperties.pointOfContactId != '')
                a.Point_of_Contact__c = changeProperties.pointOfContactId;
            else {
                a.Point_of_Contact__c = null; 
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            if(selectedContacts != null && selectedContacts.size() > 0 && (syncContactPhone || syncContactAddress))
            {                    
                for(AccountContact ac : selectedContacts)
                {
                    if(ac.Selected != null && ac.Selected)
                    {
                        contactIDString += (ac.Id + ',');
                        Contact c = new Contact();
                        c.Id = ac.Id;
                        if(syncContactPhone)
                            c.Phone = changeProperties.phoneNumber;
                        if(syncContactAddress && ((changeProperties.profileName == 'Inpro - Finance' || changeProperties.profileName == 'System Administrator') || a.Status__c != 'Customer'))
                        {
                            c.MailingStreet = changeProperties.shippingStreetAddress;
                            c.MailingCity = changeProperties.shippingCity;
                            if(changeProperties.shippingState != null && changeProperties.shippingState != null && changeProperties.shippingState != 'Please Select')                                   
                                c.MailingState = changeProperties.shippingState;
                            else
                                c.MailingState = null;
                            c.MailingPostalCode = changeProperties.shippingZipCode;
                            if(changeProperties.shippingCountry != null && changeProperties.shippingCountry != null && changeProperties.shippingCountry != 'Please Select')
                                c.MailingCountry = changeProperties.shippingCountry;
                            else
                                c.MailingCountry = null;
                        }
                        contactsToUpdate.add(c);
                    }
                }
            }

            if ((changeProperties.profileName == 'Inpro - Finance' || changeProperties.profileName == 'System Administrator') || (a.Status__c != 'Approved' && a.Status__c != 'Customer')) 
            {
                a.Name = changeProperties.name;

                if(changeProperties.parentId != null && changeProperties.parentId != '')
                    a.parentId = changeProperties.parentId;
                else {
                    a.parentId = null;
                }
                      
                a.Customer_Number__c = changeProperties.customerNumber;
                a.Inactive__c = changeProperties.inactive;
                a.Sync_Price_Level__c = changeProperties.syncPriceLevel;
                a.RecordTypeId = ChangeProperties.recordTypeId;
                
                if(changeProperties.marketSegment != null && changeProperties.marketSegment != '' && changeProperties.marketSegment != 'Please Select' && changeProperties.marketSegment != 'undefined')
                    a.Market_Segment__c = changeProperties.marketSegment;
                else
                    a.Market_Segment__c = null;
                
                if(changeProperties.subSegment != null && changeProperties.subSegment != '' && changeProperties.subSegment != 'Please Select' && changeProperties.subSegment != 'undefined')
                    a.Sub_Segment__c = changeProperties.subSegment;
                else {
                    a.Sub_Segment__c = null;
                }               

                if(changeProperties.level != null && changeProperties.level != '' && changeProperties.level != 'Please Select' && changeProperties.level != 'undefined')
                    a.Level__c = changeProperties.level;
                else {
                    a.Level__c = null;
                }

                if(changeProperties.nationalTerritory != null && changeProperties.nationalTerritory != '' && changeProperties.nationalTerritory != 'Please Select' && changeProperties.nationalTerritory != 'undefined')
                    a.National_Territory__c = changeProperties.nationalTerritory;
                else {
                    a.National_Territory__c = null; 
                }

                if(changeProperties.collectorId != null && changeProperties.collectorId != '')
                    a.Collector__c = changeProperties.collectorId;
                else {
                    a.Collector__c = null;
                }

                if(changeProperties.priceLevel != null && changeProperties.priceLevel != '' && changeProperties.priceLevel != 'Please Select' && changeProperties.priceLevel != 'undefined')
                    a.Price_Level__c = changeProperties.priceLevel;
                else {
                    a.Price_Level__c = null;
                }                
                
                if(changeProperties.balance != null && changeProperties.balance != '')
                    a.Balance__c = Decimal.valueOf(changeProperties.balance);
                else {
                    a.Balance__c = null;    
                }
                
                if(changeProperties.creditApplicationReceived != null && changeProperties.creditApplicationReceived != '')
                    a.Credit_Application_Received__c = Date.valueOf(changeProperties.creditApplicationReceived);
                else {
                    a.Credit_Application_Received__c = null;
                }

                if(changeProperties.availableCredit != null && changeProperties.availableCredit != '')
                    a.Available_Credit__c = Decimal.valueOf(changeProperties.availableCredit);
                else {
                    a.Available_Credit__c = null;
                }

                if(changeProperties.numberOfOpenOrders != null && changeProperties.numberOfOpenOrders != '')
                    a.of_Open_Orders__c = Decimal.valueOf(changeProperties.numberOfOpenOrders);
                else {
                    a.of_Open_Orders__c = null;
                }

                if(changeProperties.openOrderValue != null && changeProperties.openOrderValue != '')
                    a.Open_Order_Value__c = Decimal.valueOf(changeProperties.openOrderValue);
                else {
                    a.Open_Order_Value__c = null;
                }

                a.Credit_Hold__c = changeProperties.creditHold;

                if(changeProperties.openOrderValue != null && changeProperties.openOrderValue != '')
                    a.Credit_Limit__c = Decimal.valueOf(changeProperties.creditLimit);
                else {
                    a.Credit_Limit__c = null;
                }

                if(changeProperties.paymentTerms != null && changeProperties.paymentTerms != '' && changeProperties.paymentTerms != 'Please Select' && changeProperties.paymentTerms != 'undefined')
                    a.Payment_Terms__c = changeProperties.paymentTerms;
                else {
                    a.Payment_Terms__c = null;
                }

                a.Hard_Copy_PO_Required__c = changeProperties.hardCopyPORequired;

                if(changeProperties.netsuiteAddDate != null && changeProperties.netsuiteAddDate != '')
                    a.NetSuite_Add_Date__c = Date.valueOf(changeProperties.netsuiteAddDate);
                else {
                    a.NetSuite_Add_Date__c = null;
                }

                if(changeProperties.lastCallDate != null && changeProperties.lastCallDate != '')
                    a.Last_Call_Date__c = Date.valueOf(changeProperties.lastCallDate);
                else {
                    a.Last_Call_Date__c = null;
                }

                if(changeProperties.lastVisitDate != null && changeProperties.lastVisitDate != '')
                    a.Last_Visit_Date__c = Date.valueOf(changeProperties.lastVisitDate); 
                else {
                    a.Last_Visit_Date__c = null;
                }              

                if(changeProperties.lastSampleRequestDate != null && changeProperties.lastSampleRequestDate != '')
                    a.Last_Sample_Date__c = Date.valueOf(changeProperties.lastSampleRequestDate);
                else {
                    a.Last_Sample_Date__c = null;
                }               

                if(changeProperties.territoryId != null && changeProperties.territoryId != '')
                    a.Territory_Lookup__c = changeProperties.territoryId;
                else {
                    a.Territory_Lookup__c = null;
                }

                a.Salesforce_Maps_Overridden_Finance__c = changeProperties.salesforceMapsOverridden;
                a.ShippingStreet = changeProperties.shippingStreetAddress;
                a.ShippingCity = changeProperties.shippingCity;
                a.ShippingPostalCode = changeProperties.shippingZipCode;
                
                if(changeProperties.shippingState != null && changeProperties.shippingState != '' && changeProperties.shippingState != 'Please Select' && changeProperties.shippingState != 'undefined')
                    a.ShippingState = changeProperties.shippingState;
                else {
                    a.ShippingState = null;
                }

                if(changeProperties.shippingCountry != null && changeProperties.shippingCountry != '' && changeProperties.shippingCountry != 'Please Select' && changeProperties.shippingCountry != 'undefined')
                    a.ShippingCountry = changeProperties.shippingCountry;
                else {
                    a.ShippingCountry = null;
                }

                a.BillingStreet = changeProperties.billingStreetAddress;
                a.BillingCity = changeProperties.billingCity;
                a.BillingPostalCode = changeProperties.billingZipCode;

                if(changeProperties.billingState != null && changeProperties.billingState != '' && changeProperties.billingState != 'Please Select' && changeProperties.billingState != 'undefined')
                    a.BillingState = changeProperties.billingState;
                else {
                    a.BillingState = null;
                }

                if(changeProperties.billingCountry != null && changeProperties.billingCountry != '' && changeProperties.billingCountry != 'Please Select' && changeProperties.billingCountry != 'undefined')
                    a.BillingCountry = changeProperties.billingCountry;
                else {
                    a.BillingCountry = null;  
                }               

                update a;
               
                if(contactsToUpdate.size() > 0)
                {
                    update contactsToUpdate;
                }                
            }
            else if (a.Status__c == 'Approved')
            {
                a.Name = changeProperties.name;
                a.RecordTypeId = changeProperties.recordTypeId;

                a.CIA__c = changeProperties.cia;
                a.Sync_GPO_Pricing__c = changeProperties.syncGPOPricing;
                
                if(changeProperties.marketSegment != null && changeProperties.marketSegment != '' && changeProperties.marketSegment != 'Please Select' && changeProperties.marketSegment != 'undefined')
                {
                    a.Market_Segment__c = changeProperties.marketSegment;
                }               
                else
                    a.Market_Segment__c = null;

                if(changeProperties.nationalTerritory != null && changeProperties.nationalTerritory != '' && changeProperties.nationalTerritory != 'Please Select' && changeProperties.nationalTerritory != 'undefined')
                {
                    a.National_Territory__c = changeProperties.nationalTerritory;
                }
                else 
                    a.National_Territory__c = null;

                if(changeProperties.level != null && changeProperties.level != '' && changeProperties.level != 'Please Select' && changeProperties.level != 'undefined')
                {
                    a.Level__c = changeProperties.level;
                }
                else 
                    a.Level__c = null;

                if(changeProperties.subSegment != null && changeProperties.subSegment != '' && changeProperties.subSegment != 'Please Select' && changeProperties.subSegment != 'undefined')
                    a.Sub_Segment__c = changeProperties.subSegment;
                else {
                    a.Sub_Segment__c = null;
                }                

                a.ShippingStreet = changeProperties.shippingStreetAddress;
                a.ShippingCity = changeProperties.shippingCity;
                a.ShippingPostalCode = changeProperties.shippingZipCode;
                
                if(changeProperties.shippingState != null && changeProperties.shippingState != '' && changeProperties.shippingState != 'Please Select' && changeProperties.shippingState != 'undefined')
                    a.ShippingState = changeProperties.shippingState;
                else {
                    a.ShippingState = null;
                }

                if(changeProperties.shippingCountry != null && changeProperties.shippingCountry != '' && changeProperties.shippingCountry != 'Please Select' && changeProperties.shippingCountry != 'undefined')
                    a.ShippingCountry = changeProperties.shippingCountry;
                else {
                    a.ShippingCountry = null;
                }

                a.BillingStreet = changeProperties.billingStreetAddress;
                a.BillingCity = changeProperties.billingCity;
                a.BillingPostalCode = changeProperties.billingZipCode;

                if(changeProperties.billingState != null && changeProperties.billingState != '' && changeProperties.billingState != 'Please Select' && changeProperties.billingState != 'undefined')
                    a.BillingState = changeProperties.billingState;
                else {
                    a.BillingState = null;
                }

                if(changeProperties.billingCountry != null && changeProperties.billingCountry != '' && changeProperties.billingCountry != 'Please Select' && changeProperties.billingCountry != 'undefined')
                    a.BillingCountry = changeProperties.billingCountry;
                else {
                    a.BillingCountry = null;  
                }                            

                update a; 
                
                if(contactsToUpdate.size() > 0)
                {
                    update contactsToUpdate;
                }
                
                if(changeProperties.inactive != a.Inactive__c){
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'BOOLEAN';
                    crd.Field_Schema_Name__c = 'Inactive__c';
                    crd.New_Field_Value__c = String.valueOf(changeProperties.inactive);
                    crd.Old_Field_Value__c = String.valueOf(a.Inactive__c);
                    changeDetails.add(crd);
                    needsFinanceApproval = true;
                }
            }
            else if (a.Status__c == 'Customer')
            {                
                update a;

                if(changeProperties.name != a.Name)
                {
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'Name';
                    crd.New_Field_Value__c = changeProperties.name;
                    crd.Old_Field_Value__c = a.Name;
                    changeDetails.add(crd);
                    needsFinanceApproval = true;
                }

                if(changeProperties.recordTypeId != a.RecordTypeId)
                {
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'RecordTypeId';
                    crd.New_Field_Value__c = changeProperties.recordTypeId;
                    crd.Old_Field_Value__c = a.RecordTypeId;
                    crd.Reference_Field_Name__c = changeProperties.recordTypeName;
                    changeDetails.add(crd);
                    needsFinanceApproval = true;
                }

                if(changeProperties.parentId != a.parentId)
                {   
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'REFERENCE';
                    crd.Field_Schema_Name__c = 'parentId';
                    crd.New_Field_Value__c = changeProperties.parentId;
                    crd.Old_Field_Value__c = a.parentId;
                    crd.Reference_Field_Name__c = changeProperties.parentName;
                    crd.Reference_Field_Link__c =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeProperties.parentId;
                    changeDetails.add(crd);  
                    needsFinanceApproval = true;            
                }

                if(changeProperties.inactive != a.Inactive__c){
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'BOOLEAN';
                    crd.Field_Schema_Name__c = 'Inactive__c';
                    crd.New_Field_Value__c = String.valueOf(changeProperties.inactive);
                    crd.Old_Field_Value__c = String.valueOf(a.Inactive__c);
                    changeDetails.add(crd);
                    needsFinanceApproval = true;
                } 
                
                if(changeProperties.marketSegment != a.Market_Segment__c && previousMarketSegment != null)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'PICKLIST';
                    crd.Field_Schema_Name__c = 'Market_Segment__c';
                    crd.New_Field_Value__c = changeProperties.marketSegment;
                    crd.Old_Field_Value__c = a.Market_Segment__c;
                    changeDetails.add(crd);     
                    needsFinanceApproval = true;
                    
                    if(changeProperties.nationalTerritory != a.National_Territory__c && changeProperties.nationalTerritory != 'Please Select')
                    {
                        Change_Request_Detail__c crd2 = new Change_Request_Detail__c();
                        crd2.Field_Data_Type__c = 'PICKLIST';
                        crd2.Field_Schema_Name__c = 'National_Territory__c';
                        crd2.New_Field_Value__c = changeProperties.nationalTerritory;
                        crd2.Old_Field_Value__c = a.National_Territory__c;
                        changeDetails.add(crd2);
                    }
                    if(changeProperties.level != a.Level__c && changeProperties.level != 'Please Select')
                    {
                        Change_Request_Detail__c crd2 = new Change_Request_Detail__c();
                        crd2.Field_Data_Type__c = 'PICKLIST';
                        crd2.Field_Schema_Name__c = 'Level__c';
                        crd2.New_Field_Value__c = changeProperties.level;
                        crd2.Old_Field_Value__c = a.Level__c;
                        changeDetails.add(crd2);
                    }
                }               

                if(changeProperties.subSegment != a.Sub_Segment__c && previousSubSegment != null)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'PICKLIST';
                    crd.Field_Schema_Name__c = 'Sub_Segment__c';
                    crd.New_Field_Value__c = changeProperties.subSegment;
                    crd.Old_Field_Value__c = a.Sub_Segment__c;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.shippingStreetAddress != a.ShippingStreet)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'ShippingStreet';
                    crd.New_Field_Value__c = changeProperties.shippingStreetAddress;
                    crd.Old_Field_Value__c = a.ShippingStreet;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.shippingCity != a.ShippingCity)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'ShippingCity';
                    crd.New_Field_Value__c = changeProperties.shippingCity;
                    crd.Old_Field_Value__c = a.ShippingCity;
                    changeDetails.add(crd);    
                    needsFinanceApproval = true;           
                }

                if(changeProperties.shippingZipCode != a.ShippingPostalCode)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'ShippingPostalCode';
                    crd.New_Field_Value__c = changeProperties.shippingZipCode;
                    crd.Old_Field_Value__c = a.ShippingPostalCode;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.shippingState != a.ShippingState)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'ShippingState';
                    crd.New_Field_Value__c = changeProperties.shippingState;
                    crd.Old_Field_Value__c = a.ShippingState;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.shippingCountry != a.ShippingCountry)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'ShippingCountry';
                    crd.New_Field_Value__c = changeProperties.shippingCountry;
                    crd.Old_Field_Value__c = a.ShippingCountry;
                    changeDetails.add(crd); 
                    needsFinanceApproval = true;              
                }

                if(changeProperties.billingStreetAddress != a.BillingStreet)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'BillingStreet';
                    crd.New_Field_Value__c = changeProperties.billingStreetAddress;
                    crd.Old_Field_Value__c = a.BillingStreet;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.billingCity != a.BillingCity)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'BillingCity';
                    crd.New_Field_Value__c = changeProperties.billingCity;
                    crd.Old_Field_Value__c = a.BillingCity;
                    changeDetails.add(crd);    
                    needsFinanceApproval = true;           
                }

                if(changeProperties.billingZipCode != a.BillingPostalCode)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'BillingPostalCode';
                    crd.New_Field_Value__c = changeProperties.billingZipCode;
                    crd.Old_Field_Value__c = a.BillingPostalCode;
                    changeDetails.add(crd);    
                    needsFinanceApproval = true;           
                }

                if(changeProperties.billingState != a.BillingState)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'BillingState';
                    crd.New_Field_Value__c = changeProperties.billingState;
                    crd.Old_Field_Value__c = a.BillingState;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(changeProperties.billingCountry != a.BillingCountry)
                { 
                    Change_Request_Detail__c crd = new Change_Request_Detail__c();
                    crd.Field_Data_Type__c = 'STRING';
                    crd.Field_Schema_Name__c = 'BillingCountry';
                    crd.New_Field_Value__c = changeProperties.billingCountry;
                    crd.Old_Field_Value__c = a.BillingCountry;
                    changeDetails.add(crd);   
                    needsFinanceApproval = true;            
                }

                if(contactsToUpdate.size() > 0)
                {
                    update contactsToUpdate;
                }   
            }
            else 
                return 'Error: The user/account states do not support an account update.';

            List<String> toEmails = new List<String>();
            List<GroupInfo> groupInfo = new List<GroupInfo>();
            string groupIdInClause = '';
            if(changeDetails.size() > 0)
            {
                //create the change request
                Change_Request__c cr = new Change_Request__c();
                cr.Record_ID__c = changeProperties.recordId;
                cr.Record_Type__c = 'Account';
                cr.Account__c = changeProperties.recordId;
                cr.Sync_to_Contact_Addresses__c = syncContactAddress;
                cr.Sync_to_Contact_Phone_Numbers__c = syncContactPhone;
                if(contactIDString != null && contactIDString != '')
                    contactIDString = contactIDString.substring(0, contactIDString.length() - 1);
                cr.Contact_Sync_IDs__c = contactIDString;
                insert cr;

                //create the change request details
                for(Change_Request_Detail__c cd : changeDetails)
                {
                    cd.Change_Request__c = cr.Id;
                }
                insert changeDetails;

                // String Query = 'SELECT Id, Name FROM Group WHERE Name IN (\'Finance Approvers\',\'National Account Approvers\')';
                // List<Group> groups = Database.query(Query);
                // if(groups.size() > 0)  
                // {
                //     for(Group g : groups)
                //     {
                //         GroupInfo gi = new GroupInfo();
                //         gi.groupId = g.Id;
                //         gi.groupName = g.Name;
                //         groupInfo.add(gi);
                //     }
                // }          

                if(needsFinanceApproval || needsNationalAccountApproval)
                {
                    List<Change_Request_Approval_Step__c> approvalSteps = new List<Change_Request_Approval_Step__c>();
                    if(needsFinanceApproval)
                    {
                        Change_Request_Approval_Step__c step = new Change_Request_Approval_Step__c();
                        step.Approval_Type__c = 'Finance';
                        step.Change_Request__c = cr.Id;
                        approvalSteps.add(step); 
                        
                        // for(GroupInfo gi : groupInfo)
                        // {
                        //     if(gi.groupName == 'Finance Approvers')
                        //         groupIdInClause += '\'' + gi.groupId + '\',';
                        // }
                    }
                    // if(needsNationalAccountApproval)
                    // {
                    //     Change_Request_Approval_Step__c step = new Change_Request_Approval_Step__c();
                    //     step.Approval_Type__c = 'National Account';
                    //     step.Change_Request__c = cr.Id;
                    //     approvalSteps.add(step);

                    //     for(GroupInfo gi : groupInfo)
                    //     {
                    //         if(gi.groupName == 'Finance Approvers')
                    //             groupIdInClause += '\'' + gi.groupId + '\',';
                    //     }
                    // }
                    insert approvalSteps;

                    // if(groupIdInClause != '')
                    //     groupIdInClause = groupIdInClause.substring(0,groupIdInClause.length() - 1);
                }

                //String userApproverQuery = 'SELECT Id, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN (' + groupIdInClause + '))';
                //List<User> approvers = Database.query(userApproverQuery);
                //if(approvers.size() > 0)  
                //{
                //    for(User u : approvers)
                //    {
                //        toEmails.add(u.Email);
                //    }
                //}
            }

            //String body = 'An account change request has been submitted for the following record. Please follow the link below to review the account in question.<br/> <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + changeProperties.recordId + '">' + a.Name + '</a>';
            //EmailSendHelper.sendEmailMultipleRecipients(toEmails, 'eleptich@inprocorp.com', 'Account Change Requested', body);           
            
            if(changeDetails.size() > 0)
                return 'Success! Change Request Submitted.';
            else
                return 'Success!';

        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static List <LookupSearchResult> TerritorySearch(String searchTerm) {
        // Prepare query paramters
        String key = searchTerm + '%';

        string Query =  'SELECT Id, Name FROM Territory__c WHERE Name LIKE :key LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String territoryName = (String) so.get('Name');
            String territoryId = (String) so.get('Id');
            String subtitle = 'Territory';
            // if(so.get('Account.Customer_Number__c') != null)
            //     subtitle = (String) so.get('Account.Customer_Number__c');
            results.add(new LookupSearchResult(territoryId, 'Territory__c', icon, territoryName, subtitle));
        }

        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled
    public static List <LookupSearchResult> ContactSearch(String searchTerm) {
        // Prepare query paramters
        String key = searchTerm + '%';

        string Query =  'SELECT Id, Name FROM Contact WHERE Name LIKE :key LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String contactName = (String) so.get('Name');
            String contactId = (String) so.get('Id');
            String subtitle = 'Point of Contact';
            // if(so.get('Account.Customer_Number__c') != null)
            //     subtitle = (String) so.get('Account.Customer_Number__c');
            results.add(new LookupSearchResult(contactId, 'Contact', icon, contactName, subtitle));
        }

        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled
    public static List <LookupSearchResult> AccountSearch(String searchTerm) {
        // Prepare query paramters
        String key = searchTerm + '%';

        string Query =  'SELECT Id, Name FROM Account WHERE Name LIKE :key LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String accountName = (String) so.get('Name');
            String accountId = (String) so.get('Id');
            String subtitle = 'Parent Account';
            // if(so.get('Account.Customer_Number__c') != null)
            //     subtitle = (String) so.get('Account.Customer_Number__c');
            results.add(new LookupSearchResult(accountId, 'Account', icon, accountName, subtitle));
        }

        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled
    public static List <LookupSearchResult> UserSearch(String searchTerm) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';

        string Query =  'SELECT Id, Name FROM User WHERE FullName LIKE :key LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String userName = (String) so.get('Name');
            String userId = (String) so.get('Id');
            String subtitle = 'Collector';
            // if(so.get('Account.Customer_Number__c') != null)
            //     subtitle = (String) so.get('Account.Customer_Number__c');
            results.add(new LookupSearchResult(userId, 'User', icon, userName, subtitle));
        }

        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled
    public static List<String> GetMarketSegmentValues(string recordTypeId){
        if(recordTypeId == '0126g000000l4B9AAI') //General Contractor
        {
            return new List<String>{
                'Contractor',
                'Distributor',
                'Property Management',
                'Real Estate Development'
            };
        }
        else if (recordTypeId == '0126g000000l4A1AAI') //Architect/Specifier/Consultant
        {
            return new List<String>{
                'Architectural Firm',
                'Interior Design Firm'
            };
        }
        else if (recordTypeId == '0126g000000l4A6AAI') //Building Owner
        {
            return new List<String>{
                'Commercial Office',
                'Education',
                'Entertainment',
                'Government (Non VA)',
                'Healthcare',
                'Hospitality',
                'Industrial',
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
        else if (recordTypeId == '0126g000000l4AuAAI') //Competitor
        {
            return new List<String>{
                'Competitor'
            };
        }
        else if (recordTypeId == '0126g000000l4B4AAI') //Distributor
        {
            return new List<String>{
                'Distributor'
            };
        }
        else if (recordTypeId == '0124V000001q74UQAQ') //GPO
        {
            return new List<String>{
                'Group Purchasing Organization'
            };
        }
        else if (recordTypeId == '0126g000000l4AzAAI') //Specialty Contractor
        {
            return new List<String>{
                'Contractor'
            };
        }
        else {
            return new List<String>();
        }
    }
    
    public class AccountPicklistResult
    {
      @AuraEnabled  
      public List<string> marketSegmentOptions;
      @AuraEnabled  
      public List<string> subSegmentOptions;
      @AuraEnabled  
      public List<string> arcFacOptions;
      @AuraEnabled  
      public List<string> categoryOptions;
      @AuraEnabled  
      public List<string> levelOptions;
      @AuraEnabled  
      public List<string> nationalTerritoryOptions;
      @AuraEnabled  
      public List<string> priceLevelOptions;
      @AuraEnabled  
      public List<string> paymentTermsOptions;
      @AuraEnabled  
      public List<string> countryOptions;
      @AuraEnabled  
      public List<string> stateOptions;

    }

    public class ChangeProperties
    {
        @AuraEnabled
        public string profileName { get; set; }
        @AuraEnabled
        public string recordTypeId { get; set; }
        @AuraEnabled
        public string recordTypeName { get; set; }
        @AuraEnabled
        public string recordId { get; set; }
        @AuraEnabled
        public string name { get; set; }
        @AuraEnabled
        public string formerName { get; set; }
        @AuraEnabled
        public string parentId { get; set; }
        @AuraEnabled
        public string parentName { get; set; }
        @AuraEnabled
        public string customerNumber { get; set; }
        @AuraEnabled
        public string dodgeCompanyId { get; set; }
        @AuraEnabled
        public Boolean inactive { get; set; }
        @AuraEnabled
        public Boolean cia { get; set; }
        @AuraEnabled
        public Boolean syncGPOPricing { get; set; }
        @AuraEnabled
        public Boolean syncPriceLevel { get; set; }
        @AuraEnabled
        public string marketSegment { get; set; }
        @AuraEnabled
        public string subSegment { get; set; }
        @AuraEnabled
        public string arcFac { get; set; }
        @AuraEnabled
        public string category { get; set; }
        @AuraEnabled
        public string level { get; set; }
        @AuraEnabled
        public string nationalTerritory { get; set; }
        @AuraEnabled
        public string territoryId { get; set; }
        @AuraEnabled
        public string territoryName { get; set; }
        @AuraEnabled
        public string priceLevel { get; set; }
        @AuraEnabled
        public string phoneNumber { get; set; }
        @AuraEnabled
        public string website { get; set; }
        @AuraEnabled
        public string balance { get; set; }
        @AuraEnabled
        public string creditApplicationReceived { get; set; }
        @AuraEnabled
        public string availableCredit { get; set; }
        @AuraEnabled
        public string numberOfOpenOrders { get; set; }
        @AuraEnabled
        public string openOrderValue { get; set; }
        @AuraEnabled
        public Boolean creditHold { get; set; }
        @AuraEnabled
        public string creditLimit { get; set; }
        @AuraEnabled
        public string paymentTerms { get; set; }
        @AuraEnabled
        public Boolean hardCopyPORequired { get; set; }
        @AuraEnabled
        public string netsuiteAddDate { get; set; }
        @AuraEnabled
        public string lastCallDate { get; set; }
        @AuraEnabled
        public string lastVisitDate { get; set; }
        @AuraEnabled
        public string lastCallOrVisitDate { get; set; }
        @AuraEnabled
        public string lastSampleRequestDate { get; set; }
        @AuraEnabled
        public string description { get; set; }
        @AuraEnabled
        public string collectorId { get; set; }
        @AuraEnabled
        public string collectorName { get; set; }
        @AuraEnabled
        public string invoiceEmail { get; set; }
        @AuraEnabled
        public Boolean salesforceMapsOverridden { get; set; }
        @AuraEnabled
        public string shippingStreetAddress { get; set; }
        @AuraEnabled
        public string shippingCity { get; set; }
        @AuraEnabled
        public string shippingZipCode { get; set; }
        @AuraEnabled
        public string shippingState { get; set; }
        @AuraEnabled
        public string shippingCountry { get; set; }
        @AuraEnabled
        public string billingStreetAddress { get; set; }
        @AuraEnabled
        public string billingCity { get; set; }
        @AuraEnabled
        public string billingZipCode { get; set; }
        @AuraEnabled
        public string billingState { get; set; }
        @AuraEnabled
        public string billingCountry { get; set; }
        @AuraEnabled
        public string vatNumber { get; set; }
        @AuraEnabled
        public string pointOfContactId { get; set; }
        @AuraEnabled
        public string pointOfContactName { get; set; }
        @AuraEnabled
        public Boolean lockPriceLevel { get; set; }
    }

    public class AccountContact {
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string MailingStreet {get;set;}
        @AuraEnabled
        public string MailingCity {get;set;}
        @AuraEnabled
        public string MailingState {get;set;}
        @AuraEnabled
        public string MailingPostalCode {get;set;}
        @AuraEnabled
        public string MailingCountry {get;set;}
        @AuraEnabled
        public string Phone {get;set;}
        @AuraEnabled
        public Boolean Selected {get;set;}
    }

    public class PermissionResult
    {
        @AuraEnabled
        public User retrievedUser {get;set;}
        @AuraEnabled
        public List<PermissionSetAssignment> permissionSets {get;set;}
    }
    public class GroupInfo
    {
        @AuraEnabled
        public string groupId {get;set;}
        @AuraEnabled
        public string groupName {get;set;}
    }
}