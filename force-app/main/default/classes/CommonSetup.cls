public with sharing class CommonSetup {

    public static PricebookEntry InsertProductAndPrice(String productName, Decimal unitPrice)
    {
        Product2 product = new Product2(Name = productName);
        insert product;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = pricebookId;
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = unitPrice;
        pricebookEntry.UseStandardPrice = false;
        insert pricebookEntry;

        return pricebookEntry;
    }

    public static Quote InsertQuote()
    {
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17 00:00:00'));
        insert opportunity;

        Quote quote = new Quote(Name = 'Quote1');
        quote.OpportunityId = opportunity.Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;

        return quote;
    }

}