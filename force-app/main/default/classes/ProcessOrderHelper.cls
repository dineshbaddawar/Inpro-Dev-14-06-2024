public inherited sharing class ProcessOrderHelper {
    @AuraEnabled()
    public static List<string> getLocations(){    
        //TODO: get these from the service 
        List<string> Locations = new List<string>();
        Locations.add('APOLLO');
        Locations.add('AZ2');
        Locations.add('ClickEze - AZ');
        Locations.add('ClickEze - NC');
        Locations.add('ED12');
        Locations.add('FIRELINE AZ');
        Locations.add('Inpro Dubai');
        Locations.add('IPC N. Carolina');
        Locations.add('ITALY PG WAREHS');
        Locations.add('OUTSIDE INVENTORY SUPPLIERS');
        Locations.add('UNUSABLE PRODUCT');
        Locations.add('Deco Surf');
        Locations.add('NC Shades');
        return Locations;
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
      Order_Request__c ord = [SELECT Id, Opportunity__c FROM Order_Request__c WHERE Id = :recordId];
      Opportunity opp = [SELECT Id, Market_Segment__c FROM Opportunity WHERE Id = :ord.Opportunity__c];

      return opp;
    }

    @AuraEnabled()
    public static List<QuoteLineItem> getQuoteProducts(String recordId){

        string oQuery =  'SELECT Order_Source__c, QuoteId__c, Division__c FROM Order_Request__c WHERE Id = :recordId LIMIT 1';
        List<Order_Request__c> orderRequests = Database.query(oQuery);
        string quoteId = orderRequests[0].QuoteId__c;         
        string division =  orderRequests[0].Division__c;     
        String qQuery = '';  
          if(division == 'Clickeze Cubicles, Curtains, & Tracks' && orderRequests[0].Order_Source__c != 'E-Commerce')  
          {
              qQuery = 'SELECT ParentId__c, Alternate__r.Id,Alternate__r.Name,Alternate__r.Name__c, Id, Item_Number__c, Color__c, Description, Description_2__c, Price_Per_Unit__c, Quantity, Subtotal, Alternate__c, UnitPrice FROM QuoteLineItem WHERE  QuoteId = :quoteId';
              List<QuoteLineItem> quoteLineItems = Database.query(qQuery);
              List<QuoteLineItem> filteredLineItems = new List<QuoteLineItem>();
              for (QuoteLineItem qlm : quoteLineItems) {
                if(qlm.ParentId__c == qlm.Item_Number__c)
                    filteredLineItems.add(qlm);
              }
              return filteredLineItems;    
          }
          else
          {
            qQuery = 'SELECT Alternate__r.Id,Alternate__r.Name, Alternate__r.Name__c, Id, Item_Number__c, Color__c, Description, Description_2__c, Price_Per_Unit__c, Quantity, Subtotal, Alternate__c, UnitPrice FROM QuoteLineItem WHERE  QuoteId = :quoteId';
            List<QuoteLineItem> quoteLineItems = Database.query(qQuery);
            return quoteLineItems;    
         }
     
    }

    @AuraEnabled()
    public static Order_Request__c getOrderRequest(String recordId){
      List<Order_Request__c> orderRequests = 
       [SELECT QuoteId__r.Primary_Bidder__r.Customer_Number__c, Account__r.Status__c,
              QuoteId__c, Division__c, Account__r.Customer_Number__c, Account__c, Account__r.Inactive__c, Selected_Alternates__c
        FROM Order_Request__c 
        WHERE Id = :recordId LIMIT 1];         
        return  orderRequests[0];     
    }

    @AuraEnabled()
    public static string processOrder(string recordId, string quoteProducts, Boolean isMetric, string location, string userId ) {
          try {
              sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
              service.timeout_x = 120000;
              
              string uQuery = 'SELECT Email  FROM User  WHERE Id = :userId';
              List<User> Users = Database.query(uQuery);
              string userName = Users[0].Email.replace('@inprocorp.com','');

              string Environment = URL.getSalesforceBaseUrl().toExternalForm(); 
              sfdata.ProcessOrderStatus data  = service.ProcessOrder(recordId, quoteProducts, isMetric, location, userName, 'dsj8U73_3nv3Dhba');
              if (data.Status == true)
              {
                if(Environment.contains('beta') || Environment.contains('dev'))
                {
                    return 'http://srvdevempportal/MacolaStagingem10/OrderHeader.asp?OrdNo=' + data.OrderNumber;
                }
                else
                    return 'http://srvempportal/MacolaStagingem10/OrderHeader.asp?OrdNo=' + data.OrderNumber;
              }     
              else
                return data.Message;
            } catch (Exception ex) {
              if(ex.getMessage().contains('Web service callout failed: Encountered HTML Content when looking for'))
                return 'The web service timed out before returning a response, but there is a good chance that your order is still being created. Please check for it (in a minute or two) at http://srvempportal/MacolaStagingem10/UnverifiedOrders.asp';
              else 
                return ex.getMessage();
              }          
    }
}