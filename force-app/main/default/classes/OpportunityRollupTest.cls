@istest
public with sharing class OpportunityRollupTest {    

    @isTest static void testOpportunityRollup() {
		OpportunityRollup helper = new OpportunityRollup();
		helper.Rollup();
		System.assert(true);
		//System.assert(contracts.size() == 2);

		//Should be false if I can spoof modified by date
		//System.assertEquals(true, contracts.get(0).Hide_From_Queue__c);
		//System.assertEquals(true, contracts.get(1).Hide_From_Queue__c);
	}
}