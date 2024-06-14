@isTest
private class OpportunityNewQuoteHelperTest {

    @TestSetup
    static void makeData(){
        List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');
		Contact contact = new Contact();
        contact.Email = 'test@inprocorp.com';
        contact.AccountId = accounts.get(0).Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;
        Opportunity opp = new Opportunity();
        opp.AccountId = accounts.get(0).Id;
        opp.Name = 'Test';
        opp.StageName = 'Estimating';
        opp.CloseDate = Datetime.now().date();
        insert opp;
        Bidder__c oppBidder = new Bidder__c();
        oppBidder.Bidder__c = accounts.get(0).Id;
        insert oppBidder;
        Contract__c contract = new Contract__c();
        insert contract;
    }

    @isTest static void OpportunityNewQuoteHelperTest() {
        Opportunity opp = OpportunityNewQuoteHelper.getOpportunity([SELECT Id FROM Opportunity LIMIT 1].Id);
        List<Account> accAddress = OpportunityNewQuoteHelper.getAccountAddress([SELECT Id FROM Account LIMIT 1].Id);
        List<Bidder__c> oppBidders = OpportunityNewQuoteHelper.getOpportunityBidders([SELECT Id FROM Bidder__c LIMIT 1].Id);
        List<Contact> contacts = OpportunityNewQuoteHelper.getContacts([SELECT Id FROM Account LIMIT 1].Id);
        List<Contract__c> contracts = OpportunityNewQuoteHelper.getContracts([SELECT Id FROM Contract__c LIMIT 1].Id);
        Boolean isEstimator = OpportunityNewQuoteHelper.isUserEstimator('0056g000005OkrhAAC');
        
        string createQuoteResult = OpportunityNewQuoteHelper.createQuote('Chicago', 'United States', '53150', 'Wisconsin', '123 Real Street', 'Quote', '0034V00002rM9koQAC', 
                                                                         'a274V000000kKmQQAU', Date.today(), 'a2T4V000001wWtfUAE', 'New Quote Test',
                                                                         '0056g000005OkrhAAC', '0016g000009eq6yAAA', '0016g000009eq6yAAA', 'Standard', '1', 'Chicago', 
                                                                         'US', '53150', 'WI', '123 Real Street', 'a2E4V000004c8IbUAI', 'MWa2E4V000004c8IbUAI', '0016g000009eq6yAAA');

    }
}