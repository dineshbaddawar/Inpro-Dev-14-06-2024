public with sharing class OpportunityHelper {
    
    @AuraEnabled
    public static  List<Opportunity> getOpportunities(string accountId){
        List<Opportunity> opps = [SELECT Id, Name, Opportunity_Number__c, StageName, CreatedDate, 
                                         Amount, Probability, Rating__c, CloseDate,
                                         Street_Address__c, City__c, State__c, Zip__c
                                  FROM Opportunity
                                  WHERE AccountId = :accountId
                                  ORDER BY CloseDate desc
                                  LIMIT 20];

        return opps;
    }
    @AuraEnabled
    public static List<Opportunity> getBuildingOwnerOpportunities(string accountId){
        List<Opportunity> opps = [SELECT Id, Name, Opportunity_Number__c, StageName, CreatedDate, 
                                         Amount, Probability, Rating__c, CloseDate,
                                         Street_Address__c, City__c, State__c, Zip__c
                                  FROM Opportunity
                                  WHERE Building_Owner__c = :accountId
                                  ORDER BY CloseDate desc
                                  LIMIT 20];

        return opps;
    }
}