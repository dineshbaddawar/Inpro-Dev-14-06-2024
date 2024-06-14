public with sharing class EcomRegisterUserHelper {
    
        @AuraEnabled
        public static string registerUser(string recordId, string userId) {

            try {                
            
                string results = 'Contact registered.';
                string cQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordId LIMIT 1';
                Contact contact = Database.query(cQuery);            

                if (contact.Email != null && contact.Email != '') {

                    sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                    service.timeout_x = 120000;
                    results = service.ActivateResetEcommerce(recordId, userId, 'dsj8U73_3nv3Dhba');   
                    
                    contact.Ecommerce__c = true;
                    update contact;  
                    //TODO: enable the EPIServer API for dev
                                                               
                }
                else
                   results = 'Contact is missing an email.';

               return results;

            } catch (Exception ex) {
                return JSON.serialize(ex);
            }
        }
        
        @AuraEnabled
        public static string registerStoreFrontUser(string storeFrontId, string contactId, string customerAccountId, string userId) {

            try {                
            
                string sfId = '';
                List<Storefront__c> storeFronts = [SELECT Contact__c, Storefront_Account__c, Id
                FROM Storefront__c
                WHERE Contact__c = :contactId AND Storefront_Account__c = :storeFrontId
                LIMIT 1];

                if(storeFronts.size() == 0)
                {
                    Storefront__c front = new Storefront__c();
                    front.Contact__c = contactId;
                    front.Storefront_Account__c = storeFrontId;
                    front.Customer_Account__c = customerAccountId;

                    insert front;
                    sfId = front.Id;
                }
                else {
                    sfId = storeFronts[0].Id;
                }                

               return sfId;

            } catch (Exception ex) {
                return ex.getMessage() + ex.getStackTraceString();
            }
        }

        @AuraEnabled
        public static string callWebsiteRegisterAPI(string storeFrontId, string userId) {

            try {                
            
                string results = 'Contact registered.';
                // string cQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId LIMIT 1';
                // Contact contact = Database.query(cQuery);            

                // if (contact.Email != null && contact.Email != '') {

                    sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                    service.timeout_x = 120000;
                    results = service.ActivateResetEcommerce(storeFrontId, userId, 'dsj8U73_3nv3Dhba');                                                                  
                // }
                // else
                //    results = 'Contact is missing an email.';

               return results;

            } catch (Exception ex) {
                return ex.getMessage() + ex.getStackTraceString();
            }
        }


        @AuraEnabled(Cacheable = true)
        public static List <LookupSearchResult> contactSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
            // Prepare query paramters
            String key = searchTerm + '%';       
    
            string Query =  'SELECT Name, AccountId, Account.Customer_Number__c, Id, Email FROM Contact WHERE Name like :key or Email like :key LIMIT 50';          
    
            // Prepare results
            List<LookupSearchResult> results = new List <LookupSearchResult>();
    
            String accountIcon = 'standard:account';
            for (sObject so: Database.Query(Query)) {
                String contactName = (String) so.get('Name') + ' - ' +  (String)so.get('Email');                
                String contactId = (String)so.get('Id');
                String subtitle = ''; //(String) so.get('Account.Customer_Number__c');
                results.add(new LookupSearchResult(contactId, 'Contact', accountIcon, contactName, subtitle));
            }
    
            // sort all results on name
            results.sort();
    
            return results;
        }

        @AuraEnabled
        public static string getStoreFrontAccounts(){
           List<AggregateResult> storeFrontAccounts = [SELECT Storefront_Account__c, Storefront_Account__r.Name,
           Storefront_Account__r.Customer_Number__c, Storefront_Account__r.Id
             FROM Storefront__c
             GROUP BY Storefront_Account__c,Storefront_Account__r.Name,
           Storefront_Account__r.Customer_Number__c,Storefront_Account__r.Id];
           return JSON.serialize(storeFrontAccounts);
        }

        @AuraEnabled
        public static List<AccountContactRelation> getCustomerAccounts(string contactId){
           List<AccountContactRelation> customerAccounts = 
           [SELECT AccountId, Account.Name, Account.Customer_Number__c
           FROM AccountContactRelation
           WHERE ContactId = :contactId];
           return customerAccounts;
        }
}