@isTest
private class QuoteAndBidControllerTest {
    @isTest static void testSendQuoteEmailwFlowParam(){
        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        Account account = new Account();
        account.Name = 'IT Test';
        insert account;

        Contact contact = new Contact(
            AccountId = account.Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Quote/Bid Complete',
            CloseDate = Date.today(),
            Pricebook2Id = pricebookId,
            AccountId = account.id
        );
        insert opp;

        Quote quote = new Quote (
            Name = 'test value', 
            OpportunityId = opp.Id
        );
        insert quote;
         Contact contactObj = new Contact (
            AccountId =  account.Id, 
            FirstName = 'test value', 
            LastName = 'test value'
        );
        insert contactObj;

        
        Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate CZ',
            QuoteId__c = quote.Id
        );
        insert alt1;

        Quotelineitem quotelineitemObj = new Quotelineitem (
            Description = 'test value', 
            Alternate__c = alt1.Id, 
            Custom_Pricing_Requested__c = false, 
            Customer_Priced_On__c = 'test value', 
            Description_2__c = 'Test Value', 
            Document_Name__c = 'test value', 
            Is_Custom_Product__c = true, 
            Quantity = 1.1, 
            UnitPrice = 1.1,
            Item_Number__c = '123',
            ParentID__c = '123',
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            LineNumber__c = 1,
            Sequence_Number__c = 1,
            Alternate_Number__c = 1,
            Unit_Weight__c = 1
        );
        insert quotelineitemObj;
         Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
         ContentVersion contentVersion_1 = new ContentVersion(
                Title='SamplePDF', 
                PathOnClient ='Sample.PDF',
                VersionData = bodyBlob, 
                origin = 'H'
            );
        insert contentVersion_1;
        string url='/apex/Quote_w_Pricing_PDF?quoteId='+quote.Id+'&taxable=true&metric=false&print=false&totalwTax=41419.11&total=38042.81&alternates='+alt1.Id+','+quotelineitemObj.Id+','+quotelineitemObj.Id+'&contactName=Nishad K&contactEmail=nishad@test.com&contactPhone=+19745175423&fax=undefined&toAddress=undefined&ccAddress=undefined&bccAddress=undefined&emailSubject=undefined&hideQtys=undefined&shipToAddress=undefined&paymentTerms=undefined&shppingTerms=undefined&jobReference=undefined&ourReference=P-155977&creditType=undefined&material=undefined&submittalVersion=undefined';
        string quoteId= quote.Id;
        string emailbody='test emailbody';
        string ccAddress='test@test.com';
        string toAddress='test@test2.com';
        string bccAddress='test@test3.com';
        string emailSubject='test emailSubject';
        string docName='test doc'; 
        String reqStr='{"bccContacts":"test@test4.com","ccContacts":"test@test5.com","toContacts":"test@test6.com","subject":"test","emailTemplateBody":"","selectedFiles":"'+contentVersion_1.Id+'"}';
        QuoteAndBidController.sendQuoteEmailwFlowParam( url, quoteId, emailbody, ccAddress, toAddress,  bccAddress, emailSubject, docName,  reqStr);
        Test.startTest();
    }

}