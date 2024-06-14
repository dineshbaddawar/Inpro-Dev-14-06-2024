public with sharing class DeniedPartyHelper {
    @AuraEnabled
    public static DeniedPartyResult CheckDeniedPartyStatus(string accountId){
        
        try {
            Account account = [SELECT Id, ECUSTOMS__IM_Status__c, ECUSTOMS__RPS_Status__c, Name FROM Account WHERE Id = :accountId];
            
            DeniedPartyResult d = new DeniedPartyResult();
            String rpsStatus = '';
            if(account.ECUSTOMS__IM_Status__c != null && account.ECUSTOMS__IM_Status__c != 'Cleared' && account.ECUSTOMS__IM_Status__c != '')
            {
                d.isAccountBlocked = true;
                if(account.ECUSTOMS__RPS_Status__c != null)
                    rpsStatus = account.ECUSTOMS__RPS_Status__c;
                d.message = 'Warning: This account (' + account.Name + ') is marked as a denied party. This is strictly an informational notification as of now. Please proceed as you normally would.'; //and must be reviewed/cleared before this action is taken. RPS Status Level: ' + rpsStatus;
            }    
            else 
            {
                d.isAccountBlocked = false;
                d.message = '';
            }                       

            d.hasRetrievalErrorOccurred = false;
            return d;
        }
        catch(Exception ex)
        {
            DeniedPartyResult d = new DeniedPartyResult();
            d.isAccountBlocked = false;
            d.hasRetrievalErrorOccurred = true;
            d.message = ex.getMessage();
            return d;
        }
    }

    @AuraEnabled
    public static Quote RetrieveQuote(string quoteId){
        
        try {
            Quote quote = [SELECT Id, AccountId FROM Quote WHERE Id = :quoteId];                     
            return quote;
        }
        catch(Exception ex)
        {
            Quote quote = new Quote();
            return quote;
        }
    }

    @AuraEnabled
    public static string RunScreeningLogic(string accountId){
        try 
        {
            Account account = [SELECT Id, ECUSTOMS__IM_Status__c, ECUSTOMS__RPS_Status__c FROM Account WHERE Id = :accountId];  
            if(account != null)
            {
                if(account.ECUSTOMS__RPS_Status__c == null || account.ECUSTOMS__RPS_Status__c == '' || account.ECUSTOMS__RPS_Status__c == 'Pending')
                {
                    account.ECUSTOMS__Screening_Trigger__c = true;
                    update account;
                    return 'Success! Screening Initiated.';
                }
                else 
                    return 'Success! No Screening Needed.';
            }
            else {
                return 'Error: There was an error retrieving the account.';
            }
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DeniedPartyResult
    {
        @AuraEnabled
        public string message { get; set; }
        @AuraEnabled
        public Boolean isAccountBlocked { get; set; }
        @AuraEnabled
        public Boolean hasRetrievalErrorOccurred { get; set; } 
    }
}