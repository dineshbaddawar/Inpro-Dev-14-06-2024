@isTest
public with sharing class ChangeRequestFormHelperTest {
    @isTest
    static void processTest() {
        
        Account account = new Account();
        account.Name = 'Test';
        account.AccountNumber = '123';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Building Owner').getRecordTypeId();
        insert account;

        Account accountRetrieved =  ChangeRequestFormHelper.GetAccount(account.Id);
        List<Contact> contactsRetrieved =  ChangeRequestFormHelper.GetContacts(account.Id);
        ChangeRequestFormHelper.AccountPicklistResult picklistResult = ChangeRequestFormHelper.GetAccountPicklistValues();
        List<RecordType> recordTypes = ChangeRequestFormHelper.GetRecordTypes('Account');
        List <LookupSearchResult> lookupTerritoryResult = ChangeRequestFormHelper.TerritorySearch('MW03');
        List <LookupSearchResult> lookupContactResult = ChangeRequestFormHelper.ContactSearch('Everett');
        List <LookupSearchResult> lookupAccountResult = ChangeRequestFormHelper.AccountSearch('IT TEST');
        //List <LookupSearchResult> lookupUserResult = ChangeRequestFormHelper.UserSearch('Everett');
    }   
}