@isTest
class PrintQuoteEmailControllerTest {
    @isTest
    static void testPrintQuoteEmailController() {

        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');

        Contact contact = new Contact(
            AccountId = accounts.get(0).Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Quote/Bid Complete',
            CloseDate = Date.today(),
            Pricebook2Id = pricebookId,
            AccountId = accounts.get(0).id
            );
        insert opp;

        Quote quote = new Quote (
            Name = 'test value',
            OpportunityId = opp.Id
        );
        insert quote;
        Contact contactObj = new Contact (
            AccountId = accounts.get(0).Id,
            FirstName = 'test value',
            LastName = 'test value'
        );
        insert contactObj;

        EmailTemplate emailTemp = 
            [
                SELECT 
                    Id, 
                    Body, 
                    HtmlValue,
                    Name 
                FROM EmailTemplate
                ORDER BY Createddate desc limit 1
            ];
        
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;

        Test.startTest();
        PrintQuoteEmailController.getEmailBody(emailTemp.Id);
        PrintQuoteEmailController.getFilesList(null);
        //PrintQuoteEmailController.getContactList('test@test.com,CurrentUser,Territory Manager,OpportunityOwner,'+quote.Id);

        new lwcMultiLookupController();
        lwcMultiLookupController.getResults('Contact', 'email', 'test', new List<string>());
        Test.stopTest();


    }
}