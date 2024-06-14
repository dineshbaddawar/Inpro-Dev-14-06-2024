public with sharing class GPOHelper {
        
    @future (callout = true)
    public static void syncGPOAssociationToChildren(String gpoAssociationId) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.SyncGPOAssociationToChildAccounts('dsj8U73_3nv3Dhba', gpoAssociationId);
    }

    public class GPOAssociationDTO
    {
        @InvocableVariable
        public string gpoAssociationId;
        @InvocableVariable
        public string gpoId;
        @InvocableVariable
        public string divisionId;
        @InvocableVariable
        public string membershipId;
        @InvocableVariable
        public string effectiveDate;
        @InvocableVariable
        public string expirationDate;
        @InvocableVariable
        public string accountId;
        @InvocableVariable
        public string isInactive;
    }
    
}