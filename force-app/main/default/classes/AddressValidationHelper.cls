public with sharing class AddressValidationHelper {

    @AuraEnabled
    public static string GetObjectNameById(string recordId){
        String objectName = '';
        //Get prefix from record ID
        //This assumes that you have passed at least 3 characters
        String myIdPrefix = String.valueOf(recordId).substring(0,3);
            
        //Get schema information
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            
        //Loop through all the sObject types returned by Schema
        for(Schema.SObjectType stype : gd.values()){

            //if (!sObj.contains('__')) to exclude managed package objects

            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            System.debug('Prefix is ' + prefix);
                
            //Check if the prefix matches with requested prefix
            if(prefix!=null && prefix.equals(myIdPrefix)){
                objectName = r.getName();
                System.debug('Object Name! ' + objectName);
                break;
            }
        }

        return objectName;
    }
    
    @AuraEnabled
    public static string GetCountries(){
        try {
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            return JSON.serialize(ple);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string UpdateAddress(string recordId, string objectName, string ValidationType, string Street1, string Street2,
        string City, string State, string ZipCode, Boolean isFirstAddress)
    {
        try{
            State = State == null ? '' : GetStateFullName(State);
            if (objectName.toLowerCase() == 'account')
            {
                if (isFirstAddress)
                {
                    Account account = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                                              Shipping_Address_Validated__c
                                       FROM Account
                                       WHERE Id = :recordId];
    
                    account.Id = recordId;
                    account.ShippingStreet = Street1 + '\r\n' + Street2;
                    account.ShippingCity = City;
                    account.ShippingState = State;
                    account.ShippingPostalCode = ZipCode;
                    account.Shipping_Address_Validated__c = ValidationType;
                    update account;
                }
                else{
                    Account account = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                              Billing_Address_Validated__c
                                       FROM Account
                                       WHERE Id = :recordId];
    
                    account.Id = recordId;
                    account.BillingStreet = Street1 + '\r\n' + Street2;
                    account.BillingCity = City;
                    account.BillingState = State;
                    account.BillingPostalCode = ZipCode;
                    account.Billing_Address_Validated__c = ValidationType;
                    update account;
                }
            }
            else if (objectName.toLowerCase() == 'contact')
            {
                if (isFirstAddress)
                {
                    Contact contact = [SELECT Id,MailingStreet, MailingCity, MailingState, MailingPostalCode, Mailing_Address_Validated__c
                                    FROM Contact
                                    WHERE Id = :recordId];
                    contact.MailingStreet = Street1 + '\r\n' + Street2;
                    contact.MailingCity = City;
                    if(State.length() == 2)
                        contact.MailingState = State;
                    else
                        contact.MailingState = State;
                    contact.MailingPostalCode = ZipCode;
                    contact.Mailing_Address_Validated__c = ValidationType;
                    update contact;
                }
                else {
                    Contact contact = [SELECT Id, OtherStreet, OtherCity, OtherState, OtherPostalCode, Contact_Address_Validated__c
                                    FROM Contact
                                    WHERE Id = :recordId];
                    contact.OtherStreet = Street1 + '\r\n' + Street2;
                    contact.OtherCity = City;
                    if(State.length() == 2)
                        contact.OtherState = State;
                    else
                        contact.OtherState = State;
                    contact.OtherPostalCode = ZipCode;
                    contact.Contact_Address_Validated__c = ValidationType;
                    update contact;
                }
            }
            else if (objectName.toLowerCase() == 'sample_request__c')
            {
                Sample_Request__c sample = [SELECT Id, Street_Address__c, City__c, State__c, Postal_Code__c, Address_Validated__c
                                            FROM Sample_Request__c WHERE Id = :recordId];
                sample.Street_Address__c = Street1 + '\r\n' + Street2;
                sample.City__c = City;
                if(State.length() == 2)
                    sample.State__c = State;
                else 
                    sample.State__c = State;
                sample.Postal_Code__c = ZipCode;
                sample.Address_Validated__c = ValidationType;
                update sample;
            }
            else if (objectName.toLowerCase() == 'construction_project__c')
            {
                Construction_Project__c constructionProject = [SELECT Id, Street_Address__c, City__c, State__c, ZIP_or_Postal_Code__c, 
                                                               Country__c FROM Construction_Project__c WHERE Id = :recordId];
                
                constructionProject.Street_Address__c = Street1 + '\r\n' + Street2;
                constructionProject.City__c = City;
                if(State.length() == 2)
                    constructionProject.State__c = State;
                else 
                    constructionProject.State__c = State;
                constructionProject.ZIP_or_Postal_Code__c = ZipCode;
                //constructionProject.Country__c = Country;
                update constructionProject;

            }
            else if (objectName.toLowerCase() == 'opportunity')
            {
                Opportunity opp = [SELECT Id, Street_Address__c, City__c, State__c, Zip__c, 
                                   Country__c FROM Opportunity WHERE Id = :recordId];
                
                opp.Street_Address__c = Street1 + '\r\n' + Street2;
                opp.City__c = City;
                if(State.length() == 2)
                    opp.State__c = State;
                else 
                    opp.State__c = State;
                opp.Zip__c = ZipCode;
                //opp.Country__c = Country;
                update opp;
            }
            else if (objectName.toLowerCase() == 'quote')
            {
                Quote quote = [SELECT AdditionalStreet, AdditionalCity, AdditionalState, AdditionalPostalCode, 
                         AdditionalCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                         FROM Quote
                         WHERE Id =: recordId];
                
                if(isFirstAddress)
                {
                    if(Street2 != null)
                        quote.AdditionalStreet = Street1 + '\r\n' + Street2;
                    else
                        quote.AdditionalStreet = Street1;
                    quote.AdditionalCity = City;
                    if(State.length() == 2)
                        quote.AdditionalState = State;
                    else 
                        quote.AdditionalState = State;
                    quote.AdditionalPostalCode = ZipCode;
                    //quote.AdditionalCountry = Country;
                }
                else 
                {
                    if(Street2 != null)
                        quote.ShippingStreet = Street1 + '\r\n' + Street2;
                    else {
                        quote.ShippingStreet = Street1;
                    }
                    quote.ShippingCity = City;
                    if(State.length() == 2)
                        quote.ShippingState = State;
                    else 
                        quote.ShippingState = State;
                    quote.ShippingPostalCode = ZipCode;
                    //quote.ShippingCountry = Country;
                }
                update quote;
            }
    
            return '';
        }catch(Exception ex)
        {
            if (ex.getMessage().indexOf('Please select a state from the list of valid states') != -1)
            {
                return 'Please select a state from the list of valid states. Verify country and state/province on account form.';
            }
            else return ex.getMessage();
        }
        
    }

    @AuraEnabled
    public static string ValidateAddressOne(string recordId, string objectName, Boolean updateAddress, 
        string Line1, string Line2, string City, string State, string Zip){

        sfdata.ValidateAddressResult result;

        if (updateAddress)
        {
            result = ValidateAddress('', Line1, Line2, City, State, Zip);
        }
        else if (objectName.toLowerCase() == 'account')
        {
            Account account = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id = :recordId];
            result = ValidateAddress('', account.ShippingStreet, '', account.ShippingCity, account.ShippingState, account.ShippingPostalCode);
        }
        else if (objectName.toLowerCase() == 'contact')
        {
            Contact contact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, Mailing_Address_Validated__c
                               FROM Contact
                               WHERE Id = :recordId];
            result = ValidateAddress('', contact.MailingStreet, '', contact.MailingCity, contact.MailingState, contact.MailingPostalCode);
        }
        else if (objectName.toLowerCase() == 'sample_request__c')
        {
            Sample_Request__c sample = [SELECT Id, Street_Address__c, City__c, State__c, Postal_Code__c, Address_Validated__c
                                        FROM Sample_Request__c WHERE Id = :recordId];
            result = ValidateAddress('', sample.Street_Address__c, '', sample.City__c, sample.State__c, sample.Postal_Code__c);
        }

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static string ValidateAddressTwo(string recordId, string objectName, Boolean updateAddress, 
        string Line1, string Line2, string City, string State, string Zip){

        sfdata.ValidateAddressResult result;

        if (updateAddress)
        {
            result = ValidateAddress('', Line1, Line2, City, State, Zip);
        }
        else if (objectName.toLowerCase() == 'account')
        {
            Account account = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id = :recordId];
            result = ValidateAddress('', account.BillingStreet, '', account.BillingCity, account.BillingState, account.BillingPostalCode);
        }
        else if (objectName.toLowerCase() == 'contact')
        {
            Contact contact = [SELECT Id, OtherStreet, OtherCity, OtherState, OtherPostalCode, Contact_Address_Validated__c
                               FROM Contact
                               WHERE Id = :recordId];
            result = ValidateAddress('', contact.OtherStreet, '', contact.OtherCity, contact.OtherState, contact.OtherPostalCode);
        }

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static sfdata.ValidateAddressResult ValidateAddress(string BusinessName, string Street1, string Street2,
        string City, string State, string ZipCode) 
    {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        
        sfdata.ValidateAddressResult result = service.VerifyAddress(BusinessName, Street1, Street2, City, State, ZipCode);

        return result;
    }

    @AuraEnabled
    public static string ValidateAddressJSON(string BusinessName, string Street1, string Street2,
        string City, string State, string ZipCode) 
    {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        
        sfdata.ValidateAddressResult result = service.VerifyAddress(BusinessName, Street1, Street2, City, State, ZipCode);

        return JSON.serialize(result);
    }

    @future (callout=true)
    public static void ValidateAddressMap(List<Id> shippingMap, List<Id> billingMap)
    {
        for(Id id : shippingMap)
        {
            ValidateAddressOne(id, 'Account', false,'','','','','');
        }
        for(Id id : billingMap)
        {
            ValidateAddressTwo(id, 'Account', false,'','','','','');
        }
    }

    @future (callout=true)
    public static void ValidateAddressOneTrigger(string recordId, string objectName){
        try{
            string a = ValidateAddressOne(recordId, objectName.toLowerCase(), false,'','','','','');
            sfdata.ValidateAddressResult result = (sfdata.ValidateAddressResult)JSON.deserialize(a, sfdata.ValidateAddressResult.class);
            if (result.ResultCode == 0)
            {
                if (objectName.toLowerCase() == 'account')
                {
                    Account obj = [SELECT Id, Shipping_Address_Validated__c FROM Account WHERE Id = :recordId];
                    obj.Shipping_Address_Validated__c = 'Validated';
                    update obj;
                }
                else if (objectName.toLowerCase() == 'contact')
                {
                    Contact obj = [SELECT Id, Mailing_Address_Validated__c FROM Contact WHERE Id = :recordId];
                    obj.Mailing_Address_Validated__c = 'Validated';
                    update obj;
                }
                else if (objectName.toLowerCase() == 'sample_Request__c')
                {
                    Sample_Request__c obj = [SELECT Id, Address_Validated__c FROM Sample_Request__c WHERE Id = :recordId];
                    obj.Address_Validated__c = 'Validated';
                    update obj;
                }
            }
        }catch(Exception ex)
        {
            //ignore
        }
        
    }

    @future (callout=true)
    public static void ValidateAddressTwoTrigger(string recordId, string objectName){
        try{
            string a = ValidateAddressTwo(recordId, objectName.toLowerCase(), false,'','','','','');
        sfdata.ValidateAddressResult result = (sfdata.ValidateAddressResult)JSON.deserialize(a, sfdata.ValidateAddressResult.class);
        if (result.ResultCode == 0)
        {
            if (objectName.toLowerCase() == 'account')
            {
                Account obj = [SELECT Id, Billing_Address_Validated__c FROM Account WHERE Id = :recordId];
                obj.Billing_Address_Validated__c = 'Validated';
                update obj;
            }
            else if (objectName.toLowerCase() == 'contact')
            {
                Contact obj = [SELECT Id, Contact_Address_Validated__c FROM Contact WHERE Id = :recordId];
                obj.Contact_Address_Validated__c = 'Validated';
                update obj;
            }
        }
        }catch(Exception ex)
        {
            //ignore
        }
    }

    @AuraEnabled
    public static AddressRetrievalResult RetrieveRecordAddressInfo(String objectName, String recordId)
    {
        AddressRetrievalResult result = new AddressRetrievalResult();
        if (objectName.toLowerCase() == 'sample_request__c')
        {
            Sample_Request__c obj = [SELECT Street_Address__c, City__c, State__c, Postal_Code__c, Country__c
            FROM Sample_Request__c
            WHERE Id =: recordId];
            
            RetrievedAddress addressOne = new RetrievedAddress();
            if(obj.Street_Address__c != null)
                addressOne.streetAddress1 = obj.Street_Address__c;
            else {
                addressOne.streetAddress1 = '';
            }
            if(obj.City__c != null)
                addressOne.city = obj.City__c;
            else {
                addressOne.city = '';
            }
            if(obj.State__c != null)
                addressOne.state = obj.State__c;
            else {
                addressOne.state = '';
            }
            if(obj.Postal_Code__c != null)
                addressOne.zipCode = obj.Postal_Code__c;
            else {
                addressOne.zipCode = '';
            }
            if(obj.Country__c != null)
                addressOne.country = obj.Country__c;
            else {
                addressOne.country = '';
            }
            result.addressOne = addressOne;
            result.message = 'Success!';
            result.status = true;
            
        }
        else if (objectName.toLowerCase() == 'opportunity')
        {
            Opportunity obj = [SELECT Street_Address__c, State_Code__c, State__c, Country_Code__c, Country__c, City__c, Zip__c
            FROM Opportunity
            WHERE Id =: recordId];

            RetrievedAddress addressOne = new RetrievedAddress();
            if(obj.Street_Address__c != null)
                addressOne.streetAddress1 = obj.Street_Address__c;
            else {
                addressOne.streetAddress1 = '';
            }
            if(obj.City__c != null)
                addressOne.city = obj.City__c;
            else {
                addressOne.city = '';
            }
            if(obj.State__c != null)
                addressOne.state = obj.State__c;
            else {
                addressOne.state = '';
            }
            if(obj.Zip__c != null)
                addressOne.zipCode = obj.Zip__c;
            else {
                addressOne.zipCode = '';
            }
            if(obj.Country__c != null)
                addressOne.country = obj.Country__c;
            else {
                addressOne.country = '';
            }

            result.addressOne = addressOne;
            result.message = 'Success!';
            result.status = true;
        }
        else if (objectName.toLowerCase() == 'construction_project__c')
        {
            Construction_Project__c obj = [SELECT Street_Address__c, City__c, Country__c, Country_Code__c, State__c, State_Code__c, ZIP__c
            FROM Construction_Project__c
            WHERE Id =: recordId];

            RetrievedAddress addressOne = new RetrievedAddress();
            if(obj.Street_Address__c != null)
                addressOne.streetAddress1 = obj.Street_Address__c;
            else {
                addressOne.streetAddress1 = '';
            }
            if(obj.City__c != null)
                addressOne.city = obj.City__c;
            else {
                addressOne.city = '';
            }
            if(obj.State__c != null)
                addressOne.state = obj.State__c;
            else {
                addressOne.state = '';
            }
            if(obj.Zip__c != null)
                addressOne.zipCode = obj.Zip__c;
            else {
                addressOne.zipCode = '';
            }
            if(obj.Country__c != null)
                addressOne.country = obj.Country__c;
            else {
                addressOne.country = '';
            }

            result.addressOne = addressOne;
            result.message = 'Success!';
            result.status = true;
        }
        else if (objectName.toLowerCase() == 'quote')
        {
            Quote obj = [SELECT AdditionalStreet, AdditionalCity, AdditionalState, AdditionalPostalCode, 
                         AdditionalCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                         FROM Quote
                         WHERE Id =: recordId];

            RetrievedAddress addressOne = new RetrievedAddress();
            if(obj.AdditionalStreet != null)
                addressOne.streetAddress1 = obj.AdditionalStreet;
            else {
                addressOne.streetAddress1 = '';
            }
            if(obj.AdditionalCity != null)
                addressOne.city = obj.AdditionalCity;
            else {
                addressOne.city = '';
            }
            if(obj.AdditionalState != null)
                addressOne.state = obj.AdditionalState;
            else {
                addressOne.state = '';
            }
            if(obj.AdditionalPostalCode != null)
                addressOne.zipCode = obj.AdditionalPostalCode;
            else {
                addressOne.zipCode = '';
            }
            if(obj.AdditionalCountry != null)
                addressOne.country = obj.AdditionalCountry;
            else {
                addressOne.country = '';
            }

            RetrievedAddress addressTwo = new RetrievedAddress();
            if(obj.ShippingStreet != null)
                addressTwo.streetAddress1 = obj.ShippingStreet;
            else {
                addressTwo.streetAddress1 = '';
            }
            if(obj.ShippingCity != null)
                addressTwo.city = obj.ShippingCity;
            else {
                addressTwo.city = '';
            }
            if(obj.ShippingState != null)
                addressTwo.state = obj.ShippingState;
            else {
                addressTwo.state = '';
            }
            if(obj.ShippingPostalCode != null)
                addressTwo.zipCode = obj.ShippingPostalCode;
            else {
                addressTwo.zipCode = '';
            }
            if(obj.ShippingCountry != null)
                addressTwo.country = obj.ShippingCountry;
            else {
                addressTwo.country = '';
            }

            result.addressTwo = addressTwo;
            result.addressOne = addressOne;
            result.message = 'Success!';
            result.status = true;
        }        
        // else if(objectName.toLowerCase() == 'account')
        // {
        //     Account obj = [];
        // }
        // else if (objectName.toLowerCase() == 'contact')
        // {
        //     Contact obj = [];
        // }
        return result;
    }

    @AuraEnabled
    public static string ZipCodeLookup(string zipCode) {        
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            sfdata.ZipCodeLookupResult result = service.ZipCodeLookupSatori(zipCode,'dsj8U73_3nv3Dhba'); 
            if(result.State != null)
                result.State = GetStateFullName(result.State);
            return JSON.serialize(result); 
    }

    @future (callout=true)
    public static void ZipCodeLookupFuture(string zipCode, string recordType, Id recordId) {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ZipCodeLookupResult result = service.ZipCodeLookupSatori(zipCode,'dsj8U73_3nv3Dhba'); 
        if(result.State != null)
            result.State = GetStateFullName(result.State);

        if(result.Status == true)
        {
            if(recordType.toLowerCase() == 'opportunity')
            {
                Opportunity o = new Opportunity();
                o.Id = recordId;
                if(result.City != null && result.City != '')
                    o.City__c = result.City;
                if(result.State != null && result.State != '')
                    o.State__c = result.State;
                update o;
            }
            else if(recordType.toLowerCase() == 'construction_project__c')
            {
                Construction_Project__c cp = new Construction_Project__c();
                cp.Id = recordId;
                if(result.City != null && result.City != '')
                    cp.City__c = result.City;
                if(result.State != null && result.State != '')
                    cp.State__c = result.State;
                update cp;
            }
        }           
    }

    @future (callout=true)
    public static void AddressValidationFuture(string recordType, Id recordId, string address1Street, string address1City,
    string address1State, string address1ZipCode, string address2Street, string address2City, string address2State, string address2ZipCode) {        
        try {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;       
            if(recordType == 'account')
            {
                Boolean accountNeedsUpdate = false;
                Account a = new Account();
                a.Id = recordId;

                // sfdata.ZipCodeLookupResult zipResult1 = service.ZipCodeLookupSatori(address1ZipCode,'dsj8U73_3nv3Dhba');
                // if(zipResult1.Status == true)
                // { 
                //     if(zipResult1.State != null)
                //         zipResult1.State = GetStateFullName(zipResult1.State);           
                //     if(zipResult1.State != null && zipResult1.State != '')
                //     {
                //         a.ShippingState = zipResult1.State;
                //         address1State = zipResult1.State;
                //     }
                //     if(zipResult1.City != null && zipResult1.City != '')
                //     {
                //         a.ShippingCity = zipResult1.City;
                //         address1City = zipResult1.City;
                //     }
                // }

                // sfdata.ZipCodeLookupResult zipResult2 = service.ZipCodeLookupSatori(address2ZipCode,'dsj8U73_3nv3Dhba');
                // if(zipResult2.Status == true)
                // { 
                //     if(zipResult2.State != null)
                //         zipResult2.State = GetStateFullName(zipResult2.State);           
                //     if(zipResult2.State != null && zipResult2.State != '')
                //     {
                //         a.ShippingState = zipResult2.State;
                //         address1State = zipResult2.State;
                //     }
                //     if(zipResult2.City != null && zipResult2.City != '')
                //     {
                //         a.ShippingCity = zipResult2.City;
                //         address1City = zipResult2.City;
                //     }
                // }

                sfdata.ValidateAddressResult addressValidationResult1;
                if(address1Street == null)
                    address1Street = '';
                if(address1City == null)
                    address1City = '';
                if(address1State == null)
                    address1State = ''; 
                if(address1ZipCode == null)
                    address1ZipCode = '';    
                addressValidationResult1 = ValidateAddress('', address1Street, '', address1City, address1State, address1ZipCode);
                if (addressValidationResult1.ResultCode == 0)
                    a.Shipping_Address_Validated__c = 'Validated';
                else {
                    if(addressValidationResult1.ResultCode == 22)
                    {
                        if(addressValidationResult1.City != null && addressValidationResult1.City != '')
                            a.ShippingCity = addressValidationResult1.City;
                        if(addressValidationResult1.State != null && addressValidationResult1.State != '')
                            a.ShippingState = GetStateFullName(addressValidationResult1.State);
                        a.Shipping_Address_Validated__c = 'Validated';
                    }
                    else
                        a.Shipping_Address_Validated__c = 'Not Valid';
                }

                sfdata.ValidateAddressResult addressValidationResult2;
                addressValidationResult2 = ValidateAddress('', address2Street, '', address2City, address2State, address2ZipCode);
                if (addressValidationResult2.ResultCode == 0)
                    a.Billing_Address_Validated__c = 'Validated';
                else {
                    if(addressValidationResult2.ResultCode == 22)
                    {
                        if(addressValidationResult2.City != null && addressValidationResult2.City != '')
                            a.BillingCity = addressValidationResult2.City;
                        if(addressValidationResult2.State != null && addressValidationResult2.State != '')
                            a.BillingState = GetStateFullName(addressValidationResult2.State);
                        a.Billing_Address_Validated__c = 'Validated';
                    }
                    else
                        a.Billing_Address_Validated__c = 'Not Valid';
                }
                update a;
            }   
        } catch (Exception ex) {
                
        }     
    }

    public class AddressRetrievalResult
    {
        @AuraEnabled  
        public RetrievedAddress addressOne;
        @AuraEnabled  
        public RetrievedAddress addressTwo;
        @AuraEnabled  
        public String message;
        @AuraEnabled  
        public Boolean status;
        
    }

    public class RetrievedAddress
    {
        @AuraEnabled  
        public String streetAddress1;
        @AuraEnabled  
        public String streetAddress2;
        @AuraEnabled  
        public String city;
        @AuraEnabled  
        public String state;
        @AuraEnabled  
        public String zipCode;
        @AuraEnabled  
        public String country;
    } 

    public static string GetStateFullName(string state)
    {
        if (state == 'AL') return 'Alabama';
        if (state == 'AK') return 'Alaska';
        if (state == 'AZ') return 'Arizona';
        if (state == 'AR') return 'Arkansas';
        if (state == 'CA') return 'California';
        if (state == 'CO') return 'Colorado';
        if (state == 'CT') return 'Connecticut';
        if (state == 'DE') return 'Delaware';
        if (state == 'FL') return 'Florida';
        if (state == 'GA') return 'Georgia';
        if (state == 'HI') return 'Hawaii';
        if (state == 'ID') return 'Idaho';
        if (state == 'IL') return 'Illinois';
        if (state == 'IN') return 'Indiana';
        if (state == 'IA') return 'Iowa';
        if (state == 'KS') return 'Kansas';
        if (state == 'KY') return 'Kentucky';
        if (state == 'LA') return 'Louisiana';
        if (state == 'ME') return 'Maine';
        if (state == 'MD') return 'Maryland';
        if (state == 'MA') return 'Massachusetts';
        if (state == 'MI') return 'Michigan';
        if (state == 'MN') return 'Minnesota';
        if (state == 'MS') return 'Mississippi';
        if (state == 'MO') return 'Missouri';
        if (state == 'MT') return 'Montana';
        if (state == 'NE') return 'Nebraska';
        if (state == 'NV') return 'Nevada';
        if (state == 'NH') return 'New Hampshire';
        if (state == 'NJ') return 'New Jersey';
        if (state == 'NM') return 'New Mexico';
        if (state == 'NY') return 'New York';
        if (state == 'NC') return 'North Carolina';
        if (state == 'ND') return 'North Dakota';
        if (state == 'OH') return 'Ohio';
        if (state == 'OK') return 'Oklahoma';
        if (state == 'OR') return 'Oregon';
        if (state == 'PA') return 'Pennsylvania';
        if (state == 'RI') return 'Rhode Island';
        if (state == 'SC') return 'South Carolina';
        if (state == 'SD') return 'South Dakota';
        if (state == 'TN') return 'Tennessee';
        if (state == 'TX') return 'Texas';
        if (state == 'UT') return 'Utah';
        if (state == 'VT') return 'Vermont';
        if (state == 'VA') return 'Virginia';
        if (state == 'WA') return 'Washington';
        if (state == 'WV') return 'West Virginia';
        if (state == 'WI') return 'Wisconsin';
        if (state == 'WY') return 'Wyoming';
        if (state == 'PR') return 'Puerto Rico';
        else return state;
    }
}