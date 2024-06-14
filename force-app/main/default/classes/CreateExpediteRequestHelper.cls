public with sharing class CreateExpediteRequestHelper {
    @AuraEnabled
    public static List <item> GetOrderItems(string orderNumber) {
        List <item> orderItemList = new List <item> ();       
        // sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
        // service.timeout_x = 120000;
        // sfExpedite.RetrieveOrderItemsResult results = service.RetrieveOrderItems('dsj8U73_3nv3Dhba', orderNumber);
        // if(results != null && results.Items != null)
        //     for (sfExpedite.OrderItem retrievedItem: results.Items.OrderItem) {
        //         item itm = new item();
        //         itm.ItemNumber = retrievedItem.ItemNumber;
        //         itm.Description = retrievedItem.Description;
        //         itm.Quantity = retrievedItem.Quantity;
        //         itm.QuantityOnHand = retrievedItem.QuantityOnHand; 
        //         itm.BackorderQuantity = retrievedItem.BackorderQuantity;                  
        //         orderItemList.Add(itm);
        // }           
        return orderItemList;
    }

    @AuraEnabled
    public static string RetrievalByOrder(string orderNumber) {                        
        sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
        service.timeout_x = 120000;
        string results = service.RetrievalByOrder('dsj8U73_3nv3Dhba', orderNumber);     
        return results;  
    }

    @AuraEnabled
    public static string RetrievalByQuote(string quoteId) {
                        
        sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
        service.timeout_x = 120000;
        string results = service.RetrievalByQuote('dsj8U73_3nv3Dhba', quoteId);       
        return results; 
    }  

    @AuraEnabled
    public static string RetrievalByCustomerNumber(string customerNumber) {
                        
        sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
        service.timeout_x = 120000;
        return service.RetrievalByCustomerNumber('dsj8U73_3nv3Dhba', customerNumber); 
    }

    @AuraEnabled
    public static List <LookupSearchResult> ManagerSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';

        string Query =  'SELECT Id, Name, Email__c FROM Expedite_Approver__c WHERE Inactive__c = false AND (Name LIKE :key OR Email__c LIKE :key) AND Type__c = \'Manager\' LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String managerName = (String) so.get('Name');
            String email = (String)so.get('Email__c'); 
            String managerId = (String) so.get('Id');
            String subtitle = email;
            results.add(new LookupSearchResult(managerId, 'Account', icon, managerName, subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List <LookupSearchResult> QuoteSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';

        string Query =  'SELECT Id, Name, QuoteNumber FROM Quote WHERE Name LIKE :key LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String icon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String quoteName = (String) so.get('Name');
            String quoteId = (String) so.get('Id');
            String subtitle = (String) so.get('QuoteNumber');
            // if(so.get('Account.Customer_Number__c') != null)
            //     subtitle = (String) so.get('Account.Customer_Number__c');
            results.add(new LookupSearchResult(quoteId, 'Quote', icon, quoteName, subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List<Expedite_Approver__c> RetrieveManagerList() {
        // Prepare query paramters

        string Query =  'SELECT Id, Name, Email__c FROM Expedite_Approver__c WHERE Inactive__c = false AND Type__c = \'Manager\' ORDER BY NAME';          
        List<Expedite_Approver__c> approvers = Database.query(Query);
        return approvers; 
    }
    
    @AuraEnabled
    public static SalesforceCreationResult CreateExpediteRequest(string approvingManagerId, Boolean changingMOT, Boolean chargingExpediteFee, string currentMOT, Date currentShipDate, string currentStep,
                                     string customerNumber, string division, Boolean expediteEntireOrder, Decimal expediteFeeAmount, string expeditePartNumber,
                                     string expediteReason, string expediteReasonNotes, string name, string newMOT, Date orderEntryDate, string orderNumber,
                                     Boolean productIsInStock, Date proposedDate, string quoteNumber, string status, List<item> orderItems, string manageName, string quoteId) {        
            
        try{
            SalesforceCreationResult result = new SalesforceCreationResult();
                Expedite_Request__c expediteRequest = new Expedite_Request__c();
                expediteRequest.Approving_Manager__c = approvingManagerId;
                expediteRequest.Changing_MOT__c = changingMOT;
                expediteRequest.Charging_an_Expedite_Fee__c = chargingExpediteFee;
                expediteRequest.Current_MOT__c = currentMOT;
                if(currentShipDate != null)
                    expediteRequest.Current_Ship_Date__c = currentShipDate;
                expediteRequest.Current_Step__c = currentStep;
                expediteRequest.Customer_Number__c = customerNumber;
                expediteRequest.Division__c = division;
                expediteRequest.Expedite_Entire_Order__c = expediteEntireOrder;
                expediteRequest.Expedite_Fee_Amount__c = expediteFeeAmount;
                expediteRequest.Expedite_Part_Number__c = expeditePartNumber;
                expediteRequest.Expedite_Reason__c = expediteReason;
                expediteRequest.Expedite_Reason_Notes__c = expediteReasonNotes;
                expediteRequest.New_MOT__c = newMOT;
                if(orderEntryDate != null)
                    expediteRequest.Order_Entry_Date__c = orderEntryDate;
                expediteRequest.Order_Number__c = orderNumber;
                expediteRequest.Product_is_in_Stock__c = productIsInStock;
                if(proposedDate != null)
                    expediteRequest.Proposed_Date__c = proposedDate;
                expediteRequest.Quote_Number__c = quoteNumber;
                expediteRequest.Status__c = status;
                expediteRequest.Name = name;
                if(quoteId != null && quoteId != '')
                    expediteRequest.Quote__c = quoteId;

                insert expediteRequest;
                result.ExpediteID = expediteRequest.Id;
                List<Expedite_Item__c> expediteItemsToAdd = new List<Expedite_Item__c>();
                for(item itm : orderItems)
                {  
                    if(itm.Selected)   
                    {             
                        Expedite_Item__c expediteItem = new Expedite_Item__c();
                        expediteItem.Expedite_Request__c = expediteRequest.Id;
                        expediteItem.Include_in_Expedite__c = itm.Selected;
                        expediteItem.Quantity__c = itm.Quantity;
                        expediteItem.Item_Number__c = itm.ItemNumber;
                        expediteItem.Name = itm.ItemNumber;
                        expediteItem.Description__c = itm.Description;
                        expediteItemsToAdd.add(expediteItem);
                    }            
                }
                if(expediteItemsToAdd.size() > 0)
                    insert expediteItemsToAdd;
                
                // Expedite_Approval_Step__c step = new Expedite_Approval_Step__c();
                // step.Name = 'Manager Approval Step';
                // step.Status__c = 'Submitted';
                // step.Approval_Stage__c = 'Manager';
                // step.Expedite_Request__c = expediteRequest.Id;
                // insert step;
                //result.ApprovalStepID = step.Id;
                           
                result.Message = 'Success!';
                return result;
        }
        catch(Exception ex)
        {
            SalesforceCreationResult result = new SalesforceCreationResult();
            result.Message = 'Error! ' + ex.getMessage();
            return result;
        }
    }

    @AuraEnabled
    public static string CreateNetSuiteExpediteRequest(string expediteName, string orderNumber, string division, string customerNumber, 
            string location, string managerId, string expediteSalesforceId, string expediteReason, string requestorId, string expediteProposedDate,
            string expediteFeeAmount, string newMOT, string expediteReasonNotes, string quoteId, decimal orderTotal) {        
            
        try{   
            string managerEmail = '';

            String Query =  'SELECT Email__c FROM Expedite_Approver__c where Id = :managerId';
            List<Expedite_Approver__c> approvers = Database.query(Query);              
            managerEmail = approvers[0].Email__c;

            String requestorEmail =  [SELECT Email FROM User where Id = :requestorId].Email;

            sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
            service.timeout_x = 120000;
            return service.FinishExpediteCreationProcess('dsj8U73_3nv3Dhba', expediteName, orderNumber, division, customerNumber, 
            location, managerEmail, expediteSalesforceId, expediteReason, requestorEmail, expediteProposedDate, expediteFeeAmount,
            newMOT, expediteReasonNotes, quoteId, orderTotal);                       
         }
        catch(Exception ex)
        {
            return 'Error! ' + ex.getMessage();
        }
    }



    public class item {
        @AuraEnabled
        public string ItemNumber {get;set;}
        @AuraEnabled
        public string Description {get;set;}
        @AuraEnabled
        public decimal Quantity {get;set;}
        @AuraEnabled
        public decimal QuantityOnHand {get;set;}
        @AuraEnabled
        public decimal BackorderQuantity {get;set;} 
        // @AuraEnabled
        // public decimal LineUniqueKey {get;set;}    
        @AuraEnabled
        public Boolean Selected {get;set;}   
    }

    public class SalesforceCreationResult
    {
        @AuraEnabled
        public string ApprovalStepID {get;set;}
        @AuraEnabled
        public string ExpediteID {get;set;}
        @AuraEnabled
        public string Message {get;set;}
    }
}