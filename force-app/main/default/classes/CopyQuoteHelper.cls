public inherited sharing class CopyQuoteHelper {
    
    @AuraEnabled
    public static string copyQuote(string recordId, 
                                   string accountId, 
                                   List<Integer> configs, 
                                   Integer repriceOption, 
                                   Decimal repricePercent,
                                   Boolean newQuoteNumber, 
                                   string orderEditRequestId, 
                                   string quoteName, 
                                   string versionName, 
                                   string typex, 
                                   string contactId, 
                                   List<string> bidders, 
                                   string userId, 
                                   string revisionNumber,
                                   string parentAccountId,
                                   string ultimateParentAccountId,
                                   List <QuickConfigHelper.qProduct> products) {
        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfString bidderArray = new sfdata.ArrayOfString();
        bidderArray.string_x = bidders;
        sfdata.ArrayOfInt configArray = new sfdata.ArrayOfInt();
        
        List<QuoteLIneItem> lineItems = 
        [SELECT Alternate_Number__c,Alternate__r.Number__c
        FROM QuoteLineItem
        WHERE Alternate__r.Number__c in :configs
        AND QuoteId = :recordId and Alternate_Name__c != ''];

        Map<Integer, Integer> uniqueConfigs = new map<Integer, Integer>();
        for(QuoteLIneItem record: lineItems) {
            Integer x = Integer.valueOf(record.Alternate_Number__c);
            if(!uniqueConfigs.containsKey(x)) {
                uniqueConfigs.put(x, x);
            }
        }

        Integer[] uniqueList = uniqueConfigs.values();
        configArray.int_x = uniqueList;   

        String njson = '';
        if(products != null && products.size() > 0)
        {
                
            Map<string,List<QuickConfigHelper.qProduct>> alternateGroups = new Map <string, List<QuickConfigHelper.qProduct>>();
            for (QuickConfigHelper.qProduct product: products) {
                if (alternateGroups.ContainsKey(product.AlternateName)) {
                    alternateGroups.get(product.AlternateName).add(product);
                } else {
                    List <QuickConfigHelper.qProduct > productList = new List <QuickConfigHelper.qProduct > ();
                    productList.add(product);
                    alternateGroups.put(product.AlternateName, productList);
                }
            }

            //create the soap object
            //sfdata.ArrayOfExpConfiguration configWrapper = new sfdata.ArrayOfExpConfiguration();
            List<ExpConfiguration> configList = new List <ExpConfiguration> ();
            for (string key: alternateGroups.keySet()) 
            {   
                List<QuickConfigHelper.qProduct> plist = alternateGroups.get(key);
                ExpConfiguration config = new ExpConfiguration();                
                config.Options = new List<ExpOption>();               
                config.RemovedOptions = new List<ExpOption>();
                List <ExpOption> options = new List<ExpOption> ();
                List <ExpOption> removedOptions = new List<ExpOption> ();
                integer pickSeq = 0;
                for (QuickConfigHelper.qProduct qProduct: plist) {
                    
                    ExpOption option = new ExpOption();                            
                    option.Qty = qProduct.Quantity;                            
                    option.Note = String.valueOf( qProduct.AlternateId);     
                    if(option.Note == null) option.Note = '';
                    option.ColorCode = qproduct.Color;                                       
                    option.ItemNumber = qproduct.Name;
                    option.rId = qproduct.rId;                   
                    config.Name = qProduct.AlternateName;
                    config.ID = qProduct.rAlternateId;
                    option.Discount = 0;              
                    pickSeq++;
                    option.PickSequence = pickSeq;
                    options.add(option);                
                }

                config.Options = options;
                config.removedOptions = removedOptions;
                config.MadeChanges = true;      
                configList.add(config);
            }
            
             njson = JSON.serialize(configList);          
        }
        

         sfdata.Result result = service.CopyQuote(recordId, accountId, configArray, repriceOption,
          repricePercent, newQuoteNumber, orderEditRequestId,
          quoteName, versionName, typex, contactId, bidderArray, userId, 'dsj8U73_3nv3Dhba', revisionNumber,parentAccountId, ultimateParentAccountId,njson);
                                     
        String response = '';


         if (result != null && result.Status) {
            response = result.RecordID;     
         }
         else {
             response = result.Message;
         }

         return response;         
    }

    @AuraEnabled
    public static List<Alternate__c> getAlternates(String recordId){
       List<Alternate__c> Alternates = [SELECT Group_Name__c, Number__c, Name__c, Name FROM Alternate__c WHERE QuoteId__c = :recordId and Name__c != '' ORDER BY Number__c ASC NULLS LAST];         
        
        return Alternates;
    }

    @AuraEnabled
    public static List<Bidder__c> getBidders(String recordId){

        String opQuery = 'SELECT OpportunityId FROM Quote WHERE Id = :recordId LIMIT 1';
        List<Quote> Quotes = Database.query(opQuery);
        String OpportunityID = Quotes[0].OpportunityId;

        String bidQuery = 'SELECT Contact__c, Pricing_Group__c, Type__c, Quote_Status__c, Installation_Type__c, Opportunity__c, Bidder__r.Name, Contact__r.Name, Bidder__r.Customer_Number__c, Bidder__r.Type, Quote_Type__c ' +
                          'FROM Bidder__c WHERE Opportunity__c = :OpportunityID';

         //String bidQuery = 'SELECT Bidder_Account_Id__c, Name, Bidder__c, Pricing_Group__c, ' +
         //                  'MSCRM_ID__c, Id, Name, Bidder__r.Customer_Number__c, ' +
         //                  'Bidder__r.Name, Bidder__r.Type, Bidder__r.Id, Bidder__r.Id ' +
         //                  'FROM Bidder__c WHERE Opportunity__c = :OpportunityID';

        //String bidQuery =  'SELECT AccountId__c, Bidder_Name__c, Bidder__c, Pricing_Group__c, Primary__c, Quote__c, ' + 
        //                   'Status__c, MSCRM_ID__c, Id, Name, Inpro_Interiors__c, Bidder_Name__r.Bidder__r.Customer_Number__c, ' + 
        //                   'Bidder_Name__r.Bidder__r.Name, Bidder_Name__r.Bidder__r.Type, Bidder_Name__r.Bidder__r.Id FROM Quote_Bidder__c ' +
        //                   'where Quote__c = :recordId';

        List<Bidder__c> Bidders = Database.query(bidQuery);
        return Bidders;    
    }

    @AuraEnabled
    public static List<Quote> getQuote(String recordId){

        List<Quote> Quotes = [SELECT Primary_Bidder__r.Customer_Number__c, 
                                     Primary_Bidder__r.Name, 
                                     Parent_Account__r.Customer_Number__c, 
                                     Parent_Account__r.Name,                                      
                                     Primary_Bidder__c,
                                     Parent_Account__c,
                                     ContactId,
                                     Version_Description__c, Revision_Number__c, 
                                     AccountId, Account.Customer_Number__c, 
                                     Account.Name, Account.Inactive__c, BidQuote__c 
                              FROM Quote
                              WHERE Id = :recordId LIMIT 1];
         
        return Quotes;    
    }      

    @AuraEnabled
    public static List<Contact> getContacts(String accountId){
        String Query = 'SELECT FirstName, AccountId, Id, LastName, Name FROM Contact WHERE Inactive_Contact__c = false AND AccountId = :accountId ORDER by FirstName';
        List<Contact> Contacts = Database.query(Query);
        return Contacts;    
    }    

    @AuraEnabled
    public static Boolean hasBreakoutPermission(){
        
        // string userId = UserInfo.getUserId();
        // List<PermissionSetAssignment> pList = [SELECT PermissionSetId FROM PermissionSetAssignment
        // WHERE AssigneeId=:userId AND PermissionSet.Name = 'Copy_Quote_Breakout'];

        // if(pList.size() > 0)
             return true;
        // else
             //return false;             
    }    
    

    
    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> accountSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';
        //String Query = 'select productcode, id , Item_Number__c from product2 where productcode like :key LIMIT 50';

        string Query =  'SELECT Id, Name, Customer_Number__c FROM Account WHERE Inactive__c = false AND (Name LIKE :key OR Customer_Number__c LIKE :key) LIMIT 50';          

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String accountIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String accountName = (String) so.get('Name');
            String CustNum = (String)so.get('Customer_Number__c'); 
            String accountId = (String) so.get('Id');
            String subtitle = CustNum;
            results.add(new LookupSearchResult(accountId, 'Account', accountIcon, accountName, subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }
    
    @future(callout = true)
    public static void verifyConfiguration(String quoteId)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        service.VerifyConfiguration(quoteId, 'dsj8U73_3nv3Dhba');
    }

  //used for soap call
  public class ExpConfiguration
  {
      public string Name { get; set; }
      public integer ID { get; set; }
      public List<ExpOption> Options { get; set; }
      public List<ExpOption> RemovedOptions { get; set; }
      public Boolean MadeChanges { get; set; }
  }

  public class ExpOption
  {
      public string ItemNumber { get; set; }
      public string ColorCode { get; set; }
      public decimal Qty { get; set; }
      public integer PickSequence { get; set; }
      public string Description { get; set; }
      public string Description2 { get; set; }
      public string Note { get; set; }
      public string rId { get; set; }
      public string CompetitorColor { get; set; }
      public string bpColorCode { get; set; }
      public string fpColorCode { get; set; }
      public string txColorCode { get; set; }
      public string acColorCode { get; set; }
      public string HorizontalAlign { get; set; }
      public string VerticalAlign { get; set; }
      public string FontSize { get; set; }
      public string FontType { get; set; }
      public string bpColorPallette { get; set; }
      public string fpColorPallette { get; set; }
      public string txColorPallette { get; set; }
      public string acColorPallette { get; set; }
      public string MountingType { get; set; }

      public string AccentColor { get; set; }
      public string NormalProductAccentColor { get; set; }
      public string ProductionType { get; set; }
      public string Collection { get; set; }
      public string CustombpColor { get; set; }
      public string CustomfpColor { get; set; }
      public string CustomtxColor { get; set; }
      public string AlternateName { get; set; }
      public string NoteCB { get; set; }
      public string LetterCodeCB { get; set; }
      public string CategoryID { get; set; }
      public string LetterCode { get; set; }        
      public String DiscountType {get;set;}
      public Decimal Discount{get;set;}
  }
}