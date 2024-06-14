public with sharing class AccountValidationHelper {

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
    public static sfdata.ValidateAddressResult ValidateAddressOne(string recordId, string objectName){
        string BusinessName = '';
        string Street1 = '';
        string Street2 = '';
        string City = '';
        string State = '';
        string Zip = '';

        sfdata.ValidateAddressResult result;

        if (objectName == 'Account')
        {
            Account account = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id = :recordId];
            result = ValidateAddress('', account.ShippingStreet, '', account.ShippingCity, account.ShippingState, account.ShippingPostalCode);
        }

        return result;
    }

    @AuraEnabled
    public static sfdata.ValidateAddressResult ValidateAddressTwo(string recordId, string objectName){
        string BusinessName = '';
        string Street1 = '';
        string Street2 = '';
        string City = '';
        string State = '';
        string Zip = '';

        sfdata.ValidateAddressResult result;

        if (objectName == 'Account')
        {
            Account account = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id = :recordId];
            result = ValidateAddress('', account.BillingStreet, '', account.BillingCity, account.BillingState, account.BillingPostalCode);
        }

        return result;
    }

    @AuraEnabled
    public static sfdata.ValidateAddressResult ValidateAddress(string BusinessName, string Street1, string Street2,
        string City, string State, string ZipCode) 
    {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        
        return service.VerifyAddress(BusinessName, Street1, Street2, City, State, ZipCode);
    }
}