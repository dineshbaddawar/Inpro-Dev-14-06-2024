public with sharing class IPC215Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}
    
    public IPC215Controller(ApexPages.StandardController controller) {        
        try{
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            string isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if (String.isNotEmpty(quoteId) || quoteId !=null) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if(isMetricValue == null){
                    isMetric = false;
                }
                if(isMetricValue == 'False' || isMetricValue == 'false'){
                    isMetric = false;
                }
                if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                    isMetric = true;
                } 
                if (quoteLines.size()>0) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    Integer count = 1;
                    for (QuoteLineItem line : quoteLines) {
                        CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                        if(line.Item_Number__c != null && ((line.Item_Number__c.startsWithIgnoreCase('K41'))||(line.Item_Number__c.startsWithIgnoreCase('K42')))){
                            if (!(String.isBlank(line.Color__c))) {
                                customLine.Color = (string)line.Color__c;
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? string.valueOf(last4) : null;
                            }
                            customLine.Quantity = (Integer)line.Quantity;
                            customLine.ItemNumber = (string)line.Item_Number__c;
                            customLine.SerialNo = count++;
                            customForm.quoteLines.add(customLine);
                        }
                    }
                }else {
                     BlankForm = true;
                }
            }
            if(quoteId == null){
              BlankForm = true;  
            }else{
                BlankForm = false;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    
    public IPC215Controller() {
        customForm = new CustomFormWrapper();
    }
    
    public class CustomFormWrapper {
        public Quote quoteRecord { get; set; }
        public List<CustomQuoteLineItem> quoteLines { get; set; }
        
        public CustomFormWrapper() {
            quoteRecord = new Quote();
            quoteLines = new List<CustomQuoteLineItem>();
        }
    }
    
    public class CustomQuoteLineItem {
        public String colorName { get; set; }
        public String colorNumber { get; set; }
        public Integer Quantity { get; set; }
        public string ItemNumber { get; set; }
        public String Color { get; set; }
        public Integer SerialNo { get; set; }
    }
}