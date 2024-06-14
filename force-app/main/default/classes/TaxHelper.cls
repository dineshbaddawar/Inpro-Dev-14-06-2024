public inherited sharing class TaxHelper {
   public sfTax.CalcTaxResults CalcTax(List<sfTax.TaxProduct> Products, Decimal FreightTaxableAmount, sfTax.TaxAddress Address) {
      sfTax.ServiceSoap soap = new sfTax.ServiceSoap();
      soap.timeout_x = 120000;
      sfTax.ArrayOfTaxProduct taxProductArray = new sfTax.ArrayOfTaxProduct();
      taxProductArray.TaxProduct = Products;
      return soap.CalculateTax(taxProductArray, FreightTaxableAmount, Address, 'dsj8U73_3nv3Dhba'); 
   }

   @AuraEnabled
   public static void UpdateQuoteTaxById(String QuoteId)
   {
      updateTax(Id.valueOf(QuoteId));
   }

   @invocablemethod
   public static void updateQuoteTax(List<ID> IDs)
   {
      updateTax(IDs[0]);
   }

   private static void updateTax(Id id)
   {
      TaxHelper taxHelper = new TaxHelper();
      String quoteId = String.valueOf(id);

      List<QuoteLineItem> quoteLineItems = [SELECT Alternate__c, Subtotal, Price_Per_Unit__c, Quantity 
                                            FROM QuoteLineItem 
                                            WHERE Subtotal > 0 and QuoteId = :quoteId AND Taxable__c = true 
                                            ORDER BY Alternate__c];

      Quote quote = [SELECT Id, Status, ShippingCity, ShippingCountry, ShippingCountryCode, ShippingPostalCode, 
                            ShippingState, ShippingStateCode, ShippingStreet,
                            Opportunity.Building_Owner_Parent__c, Opportunity.Building_Owner_Parent__r.Customer_Number__c
                     FROM Quote 
                     WHERE Id = :quoteId];

      List<Regional_Tax__c> taxes =   [SELECT Id, Total_Tax_Rate__c, Country__c, State__c, Tax_Type__c
                                     FROM Regional_Tax__c
                                     WHERE Country__c = :quote.ShippingCountry
                                     AND State__c = :quote.ShippingState];

      if (taxes.size() > 0)
      {
         Regional_Tax__c regionalTax = taxes.get(0);

         List<Alternate__c> alternates = [SELECT Id, Product_Tax__c, Tax_Percent__c, Freight_Tax__c, 
                                                 Total_Material__c, Freight_Amount__c
                                          FROM Alternate__c
                                          WHERE QuoteId__c = :quoteId];

         for(Alternate__c alt : alternates)
         {
            alt.Product_Tax__c = alt.Total_Material__c * regionalTax.Total_Tax_Rate__c * .01;
            alt.Tax_Percent__c = regionalTax.Total_Tax_Rate__c;

            if (quote.Opportunity.Building_Owner_Parent__c != null && 
                quote.Opportunity.Building_Owner_Parent__r.Customer_Number__c == '755515' &&
                alt.Freight_Amount__c != null)
            {
               alt.Freight_Tax__c = alt.Freight_Amount__c * regionalTax.Total_Tax_Rate__c * .01;
            }
         }

         update alternates;

         Quote q = new Quote();
         q.Id = quoteId;
         q.Automation_Date_Time__c = Datetime.now();
         q.Tax_Updated__c = Datetime.now();
         update q;
      }
      else
      {
         Map<string,List<sfTax.TaxProduct>> alternateGroups = new Map <string, List <sfTax.TaxProduct>>();
         for (QuoteLineItem so: quoteLineItems) 
         {
            string AlternateId = so.Alternate__c;

            sfTax.TaxProduct product = new sfTax.TaxProduct();
            product.Amount = so.Subtotal;
            product.UnitPrice = so.Price_Per_Unit__c;
            product.Quantity = so.Quantity;

            if (alternateGroups.ContainsKey(AlternateId)) {
               alternateGroups.get(AlternateId).add(product);
            }
            else 
            {
               List<sfTax.TaxProduct> taxProducts = new List<sfTax.TaxProduct>();
               taxProducts.add(product);
               alternateGroups.put(AlternateId, taxProducts);
            }
         }

         sfTax.TaxAddress address = new sfTax.TaxAddress();
         address.City = (string)quote.ShippingCity;
         address.PostalCode = (string)quote.ShippingPostalCode;
         address.Country = (string)quote.ShippingCountryCode;
         address.StreetAddress1 = (string)quote.ShippingStreet;
         address.StreetAddress2 = '';
         address.State = (string)quote.ShippingStateCode;

         List<Alternate__c> alternatesToUpdate = new List<Alternate__c>();

         List<Alternate__c> altList = [SELECT Freight_Amount__c, Id FROM Alternate__c WHERE QuoteId__c = :quoteId];

         sfTax.ServiceSoap soap = new sfTax.ServiceSoap();
         soap.timeout_x = 120000;
         
         for (Alternate__c alt: altList)
         {
            Alternate__c altUpdate = new Alternate__c();
            altUpdate.Id = alt.Id;

            decimal freightAmount = alt.Freight_Amount__c;

            if(freightAmount == null)
                  freightAmount = 0;

            List<sfTax.TaxProduct> taxProducts = alternateGroups.get(altUpdate.Id);

            sfTax.ArrayOfTaxProduct taxProductArray = new sfTax.ArrayOfTaxProduct();
            taxProductArray.TaxProduct = taxProducts;
            sfTax.CalcTaxResults results = soap.CalculateTax(taxProductArray, freightAmount, address, 'dsj8U73_3nv3Dhba');

            if(results.Status)
            {
               altUpdate.Product_Tax__c = results.TotalTax;
               altUpdate.Tax_Percent__c = results.TaxPercent * 100;
               altUpdate.Freight_Tax__c = results.TotalFreightTax;
               alternatesToUpdate.add(altUpdate);
            }
            else {
               system.debug(results.Message);
            }
         }

         update alternatesToUpdate;

         try
         {
            if (Approval.isLocked(quote.Id) && quote.Status == 'Approved')
            {
               Approval.UnlockResult result = Approval.unlock(quote.Id);
               if (result.isSuccess())
               {
                  quote.Tax_Updated__c = Datetime.now();
                  update quote;
               }
               else{
                  for(Database.Error err : result.getErrors())
                  {
                     System.debug('The following error has occurred.');
                     System.debug(err.getStatusCode() + ': ' + err.getMessage());
                     System.debug('Quote fields that affected this error: ' + err.getFields());
                  }
               }
            }
            else{
               quote.Tax_Updated__c = Datetime.now();
               update quote;
            }
         }
         catch(Exception ex)
         {
            System.debug('The following error has occurred.');
            System.debug(ex.getMessage() + ': ' + ex.getStackTraceString());
         }
      }
   }

   @AuraEnabled
   public static List<Alternate__c> getQuoteTaxFromButton(String quoteId)
   {
      TaxHelper taxHelper = new TaxHelper(); 

      List<QuoteLineItem> qlis = [SELECT Alternate__c, Subtotal 
                                  FROM QuoteLineItem 
                                  WHERE subtotal > 0 and QuoteId = :quoteId AND Taxable__c = true 
                                 ORDER BY Alternate__c];

      Quote quote = [SELECT Id, Status, ShippingCity, ShippingCountry, ShippingCountryCode, ShippingPostalCode, 
                            ShippingState, ShippingStateCode, ShippingStreet 
                     FROM Quote 
                     WHERE Id = :quoteId];
      
      Map<string,List<sfTax.TaxProduct>> alternateGroups = new Map <string, List <sfTax.TaxProduct>>();

      for (QuoteLineItem qli: qlis) 
      {
         string AlternateId = qli.Alternate__c;

         sfTax.TaxProduct product = new sfTax.TaxProduct();
         product.Amount = qli.Subtotal;

         if (alternateGroups.ContainsKey(AlternateId)) {
            alternateGroups.get(AlternateId).add(product);
         }
         else 
         {
            List<sfTax.TaxProduct> taxProducts = new List<sfTax.TaxProduct>();
            taxProducts.add(product);
            alternateGroups.put(AlternateId, taxProducts);
         }
      }

      sfTax.TaxAddress address = new sfTax.TaxAddress();
      address.City = quote.ShippingCity;
      address.PostalCode = quote.ShippingPostalCode;
      address.Country = quote.ShippingCountryCode;
      address.StreetAddress1 = quote.ShippingStreet;
      address.StreetAddress2 = '';
      address.State = quote.ShippingState;

      List<Alternate__c> alternatesToUpdate = new List<Alternate__c>();

      List<Alternate__c> altList = [SELECT Freight_Amount__c, Id FROM Alternate__c WHERE QuoteId__c = :quoteId];

      for (Alternate__c alt: altList)
      {    
         Alternate__c innerAlt = new Alternate__c();
         innerAlt.Id = alt.Id;

         decimal freightAmount = alt.Freight_Amount__c;

         if(freightAmount == null)
               freightAmount = 0;

         List<sfTax.TaxProduct> taxProducts = alternateGroups.get(innerAlt.Id);

         sfTax.CalcTaxResults results = taxHelper.CalcTax(taxProducts, freightAmount, address);
         if(results.Status)
         {
            innerAlt.Product_Tax__c = results.TotalTax;
            innerAlt.Tax_Percent__c = results.TaxPercent * 100;
            innerAlt.Freight_Tax__c = results.TotalFreightTax;
            alternatesToUpdate.add(innerAlt);
         }
         else {
            return null;
         }
      }
      return alternatesToUpdate;
   }

   @AuraEnabled
   public static string updateAlternateTax(List<Alternate__c> alternatesToUpdate, string quoteId){
      try {
         update alternatesToUpdate;

         Quote q = new Quote();
         q.Id = quoteId;
         q.Automation_Date_Time__c = Datetime.now();
         q.Tax_Updated__c = Datetime.now();
         update q;
         return 'The quote has been updated with the following tax percent: ' + alternatesToUpdate[0].Tax_Percent__c + '%.';

      } catch (Exception e) {
         return e.getMessage();
      }
   }

}