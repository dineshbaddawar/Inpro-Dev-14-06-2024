public with sharing class QuoteDiscountingHelper {
    @AuraEnabled
    public static List <qProduct> getExistingProductDiscounts(string recordId, string cache) {
        List <qProduct> qProductList = new List <qProduct> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfExpConfiguration results = service.GetQuoteDiscounts(recordId, 'dsj8U73_3nv3Dhba');
        if(results != null && results.ExpConfiguration != null)
        for (sfdata.ExpConfiguration config: results.ExpConfiguration) {
            if(config.Options != null && config.Options.ExpOption != null)
                for (sfdata.ExpOption option: config.Options.ExpOption) {
                    qProduct product = new qProduct();
                    product.Id = option.Id;
                    product.rId = option.rId;
                    product.Name = option.ItemNumber;
                    product.Color = option.ColorCode;
                    product.Quantity = option.Qty;
                    product.Description = option.Description;
                    product.AlternateId = config.ID;
                    product.rAlternateId = config.ID;
                    product.AlternateName = config.Name;                
                    product.PickSequence = option.PickSequence;
                    product.Description2 = option.Description2;                
                    product.UnitCost = option.UnitCost;
                    product.Yield = option.Yield;
                    product.CM = option.CM ;
                    product.Discount = option.Discount;
                    product.DiscountType = option.DiscountType;
                    product.HasContractPricing = option.HasContractPricing; 
                    product.BasePrice = option.BasePrice;
                    product.Price = option.Price;
                    product.QuoteDiscountMinimumCM = option.QuoteDiscountMinimumCM;
                    qProductList.Add(product);
            }
        }   
        return qProductList;
    }  

    @AuraEnabled
    public static string saveDiscounts(string recordId, List <qProduct> products) {


        //group products by alternate
        Map<integer,List<qProduct>> alternateGroups = new Map <integer, List <qProduct>>();
        for (qProduct product: products) {
            if (alternateGroups.ContainsKey(product.AlternateId)) {
                alternateGroups.get(product.AlternateId).add(product);
            } else {
                List < qProduct > productList = new List < qProduct > ();
                productList.add(product);
                alternateGroups.put(product.AlternateId, productList);
            }
        }

        //List<QuoteLineItem>
        //create the soap object      
        List<QuickConfigHelper.ExpConfiguration> configList = new List <QuickConfigHelper.ExpConfiguration> ();
        for (integer key: alternateGroups.keySet()) 
        {            
                List<qProduct> plist = alternateGroups.get(key);
                QuickConfigHelper.ExpConfiguration config = new QuickConfigHelper.ExpConfiguration();                
                config.Options = new List<QuickConfigHelper.ExpOption>();               
                config.RemovedOptions = new List<QuickConfigHelper.ExpOption>();
                List <QuickConfigHelper.ExpOption> options = new List<QuickConfigHelper.ExpOption> ();
                List <QuickConfigHelper.ExpOption> removedOptions = new List<QuickConfigHelper.ExpOption>();
                integer pickSeq = 0;
                for (qProduct qProduct: plist) {
                       
                    QuickConfigHelper.ExpOption option = new QuickConfigHelper.ExpOption();                            
                    option.Qty = qProduct.Quantity;
                    option.Note = qProduct.Description;
                    option.ColorCode = qproduct.Color;                                       
                    option.ItemNumber = qproduct.Name;
                    option.rId = qproduct.rId;                   
                    config.Name = qProduct.AlternateName;
                    config.ID = qProduct.rAlternateId;
                
                    if(qProduct.DiscountCM != 0)
                    {
                        option.Discount = qProduct.DiscountCM;
                        qProduct.DiscountType = 'CM';
                    }
                    else 
                    {
                        option.Discount = qProduct.Discount;                  
                    }
                    option.DiscountType = qProduct.DiscountType;     
                               
                    option.PickSequence = qProduct.PickSequence;                    
                    options.add(option);                
                                                }
                config.Options = options;
                config.removedOptions = removedOptions;
                config.MadeChanges = true;                
                configList.add(config);
        }

          //call webservice
          String json = JSON.serialize(configList);
          sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
          service.timeout_x = 120000;
          String results = service.BuildDiscountConfiguration(recordId, json, 'dsj8U73_3nv3Dhba');
          return  results; 
      //  return JSON.serialize(configWrapper);
      }
    

    public class qProduct {
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string rId {get;set;}
        @AuraEnabled
        public string Name {get;set;}
        @AuraEnabled
        public string Color {get;set;}
        @AuraEnabled
        public decimal Quantity {get;set;}
        @AuraEnabled
        public string Description {get;set;}
        @AuraEnabled
        public string AlternateName { get;set;}
        @AuraEnabled
        public integer AlternateId { get;set;}
        @AuraEnabled
        public integer rAlternateId { get;set;}
        @AuraEnabled
        public string DisplayName { get;  set; }
        @AuraEnabled
        public string ColorPalette { get; set; }       
        //after
        @AuraEnabled
        public integer PickSequence { get; set; }    
        @AuraEnabled
        public string Description2 { get; set; }
        @AuraEnabled
        public Decimal UnitCost { get; set; }
        @AuraEnabled
        public Decimal Yield { get; set; }
        @AuraEnabled
        public Decimal CM { get; set; }
        @AuraEnabled
        public Decimal QuoteDiscountMinimumCM { get; set; }        
        @AuraEnabled
        public Decimal Discount { get; set; }
        @AuraEnabled
        public String DiscountType { get; set; }
        @AuraEnabled
        public Boolean HasContractPricing { get; set; }
        @AuraEnabled
        public Decimal Price { get; set; }
        @AuraEnabled
        public Decimal BasePrice { get; set; }
        @AuraEnabled
        public Decimal DiscountCM { get; set; }
    }

}