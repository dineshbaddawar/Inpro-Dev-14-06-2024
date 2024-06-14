public with sharing class ContractHelper {
    public void contractFollowUp() {
    //    if reviewed/sent for 2 weeks, push it into follow up
    //     send email every week if in follow up status
    //     assign back to contract queue (parent record)
        String versionQuery = 'SELECT Inpro_Contract__c, Status__c, Id, CreatedById, LastModifiedDate ' +
                              'FROM Contract_Version__c ' + 
                              'WHERE Status__c IN ( \'Follow Up\', \'Reviewed/Sent\' ) and Inpro_Contract__r.Hide_From_Queue__c = true';

        List<Contract_Version__c> contractVersions = Database.query(versionQuery);

        for (Contract_Version__c cv : contractVersions) {
            Date startDate = date.newinstance(cv.LastModifiedDate.year(),cv.LastModifiedDate.month(),cv.LastModifiedDate.day()); 
            Date dueDate = Date.today();
            Integer numberDays = startDate.daysBetween(dueDate);

            if(cv.Status__c == 'Follow Up')
            {
                if(numberDays >= 7)
                {
                    Contract__c contract = new Contract__c();
                    contract.Id = cv.Inpro_Contract__c;
                    contract.Hide_From_Queue__c = false;
                    update contract;
                }
            }
            else if(cv.Status__c == 'Reviewed/Sent') 
            {                
                if(numberDays >= 14)
                {
                    Contract__c contract = new Contract__c();
                    contract.Id = cv.Inpro_Contract__c;
                    contract.Hide_From_Queue__c = false;
                    update contract;
                }
            }
        }
    }

    @AuraEnabled
    public static List<Quote> getOpportunityContracts(String opportunityId){
        String Query = 'SELECT Inpro_Contract__r.Account__r.Name, Inpro_Contract__r.Id, Inpro_Contract__r.Name, Inpro_Contract__r.Contract_Name__c, Inpro_Contract__r.Original_PO_Contract_No__c, Inpro_Contract__r.Account__c,  Inpro_Contract__r.Status__c, Inpro_Contract__r.CreatedDate, Inpro_Contract__r.Executed_Contract_Amount__c, Inpro_Contract__r.Pending_Contract_Amount__c FROM Quote WHERE OpportunityId = :opportunityId AND Inpro_Contract__c != null';
        List<Quote> Contracts = Database.query(Query);
        return Contracts;    
    }

    @AuraEnabled
    public static List<Order> getOrders(String poNumber, String accountId){
        String Query = 'SELECT Id, NetSuite_TranId__c, PoNumber, AccountId, Account.Name, Status, Terms__c, Account.Customer_Number__c, EffectiveDate, Exp_Ship_Date__c, Total_Cost__c FROM Order WHERE AccountId = :accountId AND PoNumber = :poNumber';
        List<Order> orders = Database.query(Query);
        return orders;    
    }

    @AuraEnabled
    public static List<Contract__c> getContract(String recordId){
        String Query = 'SELECT Id, Account__c, Original_PO_Contract_No__c, Customer_Number__c FROM Contract__c where Id = :recordId';
        List<Contract__c> contracts = Database.query(Query);
        return contracts;    
    }

    @AuraEnabled
    public static string loadContractTotals(String recordId){
        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;   
        return service.retrieveContractTotals(recordId, 'dsj8U73_3nv3Dhba');    
    }
}