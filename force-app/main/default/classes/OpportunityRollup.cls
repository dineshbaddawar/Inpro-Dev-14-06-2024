public with sharing class OpportunityRollup {
    public void Rollup() {

        //logic removed from quote automation, if the quote is moved into the approved stage, update the opp
        //Do this nightly, consider the fact the status will most likely move into a different stage
       Datetime Yesterday = Date.today().addDays(-1);
       List<Quote> quoteToRollup = [SELECT Id, GrandTotal, OpportunityId, Opportunity.StageName, Name
                                    FROM Quote
                                    WHERE Status IN ('Approved', 'Sent To Customer', 'Order Requested', 'Ordered' ) 
                                    AND Opportunity.StageName NOT IN 
                                    ('Quote/Bid Complete', 'Closed', 'Estimating')
                                    AND OpportunityId != null
                                    AND LastModifiedDate >= :Yesterday];

        set<string> opId = new set<string>();
       List<Opportunity> OppsToUpdate = new List<Opportunity>();
                for (Quote quote : quoteToRollup) {
                    Opportunity op = new Opportunity();
                    op.Id = quote.OpportunityId;
                    
                    op.StageName = 'Quote/Bid Complete';
                    op.Amount = quote.GrandTotal;
                    op.Most_Recent_Quote__c = quote.Name;               

                    if(!opId.contains(op.Id))
                    {
                        OppsToUpdate.add(op);
                        opId.add(op.Id);
                    }
                }                

            if(OppsToUpdate.size() > 0)    
                update OppsToUpdate;
    }
}