trigger OpportunityPreCreateTrigger on Opportunity (before insert) {

    /* 
    // Joe B - Original logic preserved for posterity. 
    // Moved to OpportunityTriggerHelper.beforeInsert() and optimzed.

    for(Opportunity opp:Trigger.new)
    {
        if (opp.Is_Estimate_Required__c == true)
        {
            opp.Estimating_Divisional_Status__c = 'Queued';
        }
        else{
            opp.Estimating_Divisional_Status__c = 'Not Required';
        }

        if (opp.Construction_Project__c != null)
        {
            Construction_Project__c cp = [SELECT Id, HCA_Project_Number__c, A_E_Project_Number__c
                                          FROM Construction_Project__c 
                                          WHERE Id = :opp.Construction_Project__c 
                                          LIMIT 1];
            if (cp.HCA_Project_Number__c != '')
            {
                opp.HCA_Project_Number__c = cp.HCA_Project_Number__c;
            }
            if (cp.A_E_Project_Number__c != '')
            {
                opp.A_E_Project_Number__c = cp.A_E_Project_Number__c;
            }
        }
    }
    */
}