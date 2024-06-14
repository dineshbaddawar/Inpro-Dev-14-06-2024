public with sharing class AccountUpdateAddressHelper {
    
    @AuraEnabled
    public static Account GetAccountAddress(string recordId){
        return [SELECT Id, Phone, ShippingStreet, ShippingCity, ShippingState, 
                    ShippingPostalCode, ShippingCountry
                FROM Account
                WHERE Id = :recordId LIMIT 1];
    }

    @AuraEnabled
    public static List<Contact> GetContacts(string accountId){
        return [SELECT Id, Name, MailingStreet, MailingCity, MailingState, Title,
                    MailingPostalCode, Phone, MobilePhone, Inactive_Contact__c
                FROM Contact 
                WHERE AccountId = :accountId];
    }

    @AuraEnabled
    public static string UpdateShippingAddress(string accountId, string shippingStreet, string shippingCity, 
    string shippingState, string shippingZip, string shippingCountry, string phone){
        try 
        {
            Account account = [SELECT ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Phone
                               FROM Account WHERE Id = :accountId];

            account.ShippingStreet = shippingStreet;
            account.ShippingCity = shippingCity;
            account.ShippingState = shippingState;
            account.ShippingPostalCode = shippingZip;
            account.ShippingCountry = shippingCountry;
            account.Phone = phone;
            update account;

            return 'Success';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string UpdateContacts(List<Contact> contacts){
        try{
            update contacts;

            return 'Success';
        }catch(Exception ex)
        {
            return ex.getMessage() + ': ' + ex.getStackTraceString();
        }
    }
}