public with sharing class EstimatingUploadHelper {
    @AuraEnabled
    public static List<Alternate__c> getAlternates(String recordId){
        String Query = 'SELECT Number__c, Name__c, Name FROM Alternate__c WHERE QuoteId__c = :recordId ORDER BY Number__c ASC NULLS LAST';
        List<Alternate__c> Alternates = Database.query(Query);
        return Alternates;    
    }

    @AuraEnabled
    public static string getDivision(String recordId){
        String Query = 'SELECT Division__c FROM Quote where id = :recordId LIMIT 1';
        List<Quote> QuoteList = Database.query(Query);
        String DivisionName = QuoteList[0].Division__C;
        return DivisionName;    
    }    

    @AuraEnabled
    public static  List<estProduct> importEstimate(string recordId, string fileId, Integer deduct, String division) {          
                
        if(division == '')
            division = 'DW';

        sfdata.ImportStatus results;        

        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;

        if(division == 'DW')
        {            
            results = service.EstimatingImportDW(fileId, deduct, 'dsj8U73_3nv3Dhba');  
            if (!results.Status) throw new CalloutException(results.Message);
        }
        else if (division == 'JM') 
        {         
            results = service.EstimatingImportJM(fileId, 'dsj8U73_3nv3Dhba');
            if (!results.Status) throw new CalloutException(results.Message);
        }        

        List<estProduct> productList = new List<estProduct>();      
    if(results.Products != null && results.Products.Product != null)
        for (sfdata.Product product : results.Products.Product) {
            estProduct prod = new estProduct();  
            if(product.ItemNumber != null)          
                prod.ItemNumber = product.ItemNumber;
            else   
                prod.ItemNumber = '';
            if(product.Quantity != null)
                prod.Quantity = product.Quantity;
            else 
                prod.Quantity = 0;
            if(product.Color != null)
              prod.Color = product.Color;
            else 
                prod.Color = '';
            if(product.Notes != null)
                prod.Notes = product.Notes;
            else 
                prod.Notes = '';
            if(product.Deduct != null)
                prod.Deduct = product.Deduct;
            else {
                prod.Deduct = false;
            }
            if(product.Description1 != null)
                prod.Description1 = product.Description1;
            else
                prod.Description1 = '';
            if(product.Description2 != null) 
                prod.Description2 = product.Description2;
            else 
                prod.Description2 = '';
            if(product.MetricDescription1 != null)
                prod.MetricDescription1 = product.MetricDescription1;
            else         
                prod.MetricDescription1 = '';
            if(product.MetricDescription2 != null)
                prod.MetricDescription2 = product.MetricDescription2;
            else 
                prod.MetricDescription2 = '';
            if(product.UnitCost != null)
            prod.UnitCost = product.UnitCost;
            else {
                prod.UnitCost = 0;
            }
            if(product.UnitWeight != null)
            prod.UnitWeight = product.UnitWeight;
            else {
                prod.UnitWeight = 0;
            }
            if(product.UOM != null)
            prod.UOM = product.UOM;
            else {
                prod.UOM = '';
            }
            if(product.ValidExperlogix != null)
                prod.ValidExperlogix = product.ValidExperlogix;
            else {
                prod.ValidExperlogix = true;
            }
            if(product.ValidMacola != null)
                prod.ValidMacola = product.ValidMacola;
            else
                prod.ValidMacola = true;
            if(product.ColorPallette != null)                
                prod.ColorPallette = product.ColorPallette;
            else
                prod.ColorPallette = '';
            if(product.Obsolete != null)
                prod.Obsolete = product.Obsolete;
            else {
                prod.Obsolete = '';
            }
            if(product.MismatchedColor != null)
                prod.MismatchedColor = product.MismatchedColor;
            else
                prod.MismatchedColor = false;
            if(product.IsSpecialPalette != null)
            prod.IsSpecialPalette = product.IsSpecialPalette;
            else {
                prod.IsSpecialPalette = false;
            }
            if(product.Width != null)
                prod.Width = product.Width;
                else {
                    prod.Width = 0;
                }
            if (product.Height != null)
            prod.Height = product.Height;
            else {
                prod.Height = 0;
            }
            if(product.AlternateName != null)
            prod.AlternateName = product.AlternateName;
            else {
                prod.AlternateName = '';
            }
            if(product.LetterCode != null)
            prod.LetterCode = product.LetterCode;
            else {
                prod.LetterCode = '';
            }
            if(product.Qty != null)
            prod.Qty = product.Qty;
            else {
                prod.Qty = '';
            }
            if(product.ValidProduct != null)
            prod.ValidProduct = product.ValidProduct;
            else {
                prod.ValidProduct = true;
            }
            if(product.ExperlogixNotes != null)            
            prod.ExperlogixNotes = product.ExperlogixNotes;
            else {
                prod.ExperlogixNotes = '';
            }
            productList.add(prod);
        }
        return productList;
    }  

    @AuraEnabled
    public static String writeConfiguration(String recordId,String alternateId, Boolean clearAlternate, String alternateName, List<estProduct> productList, 
    Boolean existingAlternates, Boolean createMaintenanceStock, Decimal maintenancePercent, Boolean newAlternate, String division)
    {
        // string quoteId, string alternateId, bool clearAlternate, string alternateName, 
        // List<Product> products, bool existingAlternates, bool createMaintenanceStock, decimal maintenancePercent, string token

        List<sfData.Product> newProductList = new List<sfData.Product>();      
        for (estProduct product : productList) {
            sfData.Product prod = new sfData.Product();
            prod.ItemNumber = product.ItemNumber;
            prod.Quantity = product.Quantity;
            prod.Color = product.Color;
            prod.Notes = product.Notes;
            prod.Deduct = product.Deduct;
            //start here
           prod.Description1 = product.Description1;
           prod.Description2 = product.Description2;
           prod.MetricDescription1 = product.MetricDescription1;
           prod.MetricDescription2 = product.MetricDescription2;

           if(product.UnitCost != null)
           prod.UnitCost = product.UnitCost;
           else 
           prod.UnitCost = 0;
           if(product.UnitWeight != null)
           prod.UnitWeight = product.UnitWeight;
           else           
           prod.UnitWeight = 0;
           prod.UOM = product.UOM;
            prod.ValidExperlogix = product.ValidExperlogix;
            if(product.ValidMacola != null)
           prod.ValidMacola = product.ValidMacola;
           else
           prod.ValidMacola = false;
           prod.ColorPallette = product.ColorPallette;
            prod.Obsolete = product.Obsolete;
            if(product.MismatchedColor != null)
           prod.MismatchedColor =  product.MismatchedColor;
           else
           prod.MismatchedColor = false; 
           if(product.IsSpecialPalette != null)
             prod.IsSpecialPalette = product.IsSpecialPalette;
           else
            prod.IsSpecialPalette =false;

            if(product.Width != null)
           prod.Width = product.Width;
           else
           prod.Width = 0;
           if(product.Height != null)
           prod.Height = product.Height;
           else           
           prod.Height = 0;
           
           prod.AlternateName = product.AlternateName;
           prod.LetterCode = product.LetterCode;
           prod.Qty = product.Qty;
           prod.ValidProduct = product.ValidProduct;
           prod.ExperlogixNotes = product.ExperlogixNotes;
            if(prod.ValidExperlogix != false)
                newProductList.add(prod);
        }        

        String json = JSON.serialize(newProductList);

        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.Result results;

        if(division == '')
        division = 'DW';


        if(division =='DW')  
        {      
        results = service.EstimatingWriteConfigsDW(recordId, alternateId, clearAlternate, alternateName, json, 
        existingAlternates, createMaintenanceStock, maintenancePercent, 'dsj8U73_3nv3Dhba');
        }
        else if (division == 'JM') 
        {
            results = service.EstimatingWriteConfigsJM(recordId, json, newAlternate, 'dsj8U73_3nv3Dhba');
        }
        

        if(results.Status == true)
        return 'true';
        else {
            if(results.Message != null)
                return results.Message;
                else {
                    return 'fail';
                }
        }
    }   
  
    public class estProduct    
    { 
        @AuraEnabled   
        public Integer ID {get;set;}
        @AuraEnabled   
        public String ItemNumber {get;set;}
        @AuraEnabled  
        public Decimal Quantity{get;set;}
        @AuraEnabled  
        public String Color{get;set;}
        @AuraEnabled  
        public String Notes{get;set;}
        @AuraEnabled  
        public Boolean Deduct{get;set;}
        @AuraEnabled  
        public String Description1{get;set;}
        @AuraEnabled  
        public String Description2{get;set;}
        @AuraEnabled  
        public String MetricDescription1{get;set;}
        @AuraEnabled  
        public String MetricDescription2{get;set;}
        @AuraEnabled  
        public Decimal UnitCost{get;set;}
        @AuraEnabled  
        public Decimal UnitWeight{get;set;}
        @AuraEnabled  
        public String UOM{get;set;}
        @AuraEnabled  
        public Boolean ValidExperlogix{get;set;}
        @AuraEnabled  
        public Boolean ValidMacola{get;set;}
        @AuraEnabled  
        public String ColorPallette{get;set;}
        @AuraEnabled  
        public String Obsolete{get;set;}
        @AuraEnabled  
        public Boolean MismatchedColor{get;set;}
        @AuraEnabled  
        public Boolean IsSpecialPalette{get;set;}
        @AuraEnabled  
        public Integer Width{get;set;}
        @AuraEnabled  
        public Integer Height{get;set;}
        @AuraEnabled  
        public string AlternateName { get; set; }
        @AuraEnabled  
        public string LetterCode { get; set; }
        @AuraEnabled  
        public string Qty { get; set; }
        @AuraEnabled  
        public Boolean ValidProduct { get; set; }
        @AuraEnabled  
        public string ExperlogixNotes { get; set; }
    }
}