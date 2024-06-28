public with sharing class IPC1013Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricThickness{ get; set;}
    public String isMetricWainscot { get; set;}
    public String isMetricCeling { get; set;}
    public String isMetricFullWainscot { get; set;}
    public String checked = '333';
    public String unchecked = 'fff';
    
    
    public IPC1013Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricThickness = '1.016mm, 1.524mm';
                isMetricWainscot = '111.76cm W x 120.65cm H';
                isMetricCeling = '111.76cm W x 238.76cm H';
                isMetricFullWainscot = '238.76cm W x 120.65cm H';
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricThickness = '.040(3/64"), .60(1/16")';
                isMetricWainscot = '44" W x 47 ½"H';
                isMetricCeling = '44" W x 94"H';
                isMetricFullWainscot = '94" W x 47 ½"H';
            }
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    system.debug('line.quoteLines '+quoteLines);
                    for (QuoteLineItem line : quoteLines) {
                        
                        if (line != null && line.Document_Name__c != null && line.Document_Name__c.containsIgnoreCase('IPC.1013')) {
                            system.debug('line.itemNumber '+line.Item_Number__c);
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Color__c != null && !String.isBlank(line.Color__c)) {
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? String.valueOf(last4) : null;
                            }
                            
                            if(line.Description_2__c != null){
                                customLine.DescriptionLower = (String)line.Description_2__c;
                                String[] parts = customLine.DescriptionLower.split(' ');
                                String firstPart = parts[0].trim();
                                customLine.Thickness = firstPart;
                            }
                            if(line.Item_Number__c != null){
                                customLine.ItemNumber = line.Item_Number__c;
                                if(line.Item_Number__c.contains('HW')){
                                    customLine.ShowAImage = true;
                                }else{
                                    customLine.ShowAImage = false;
                                }
                                if(line.Item_Number__c.contains('FW')){
                                    customLine.ShowBImage = true;
                                }else{
                                    customLine.ShowBImage = false;
                                }
                                if(line.Item_Number__c.contains('FC')){
                                    customLine.ShowCImage = true;
                                }else{
                                    customLine.ShowCImage = false;
                                }
                            }
                            customForm.quoteLines.add(customLine);
                        }
                    }
                }
                BlankForm = customForm.quoteLines.isEmpty();
            } else {
                BlankForm = true;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            BlankForm = true;
        }
    }
    
    public IPC1013Controller() {
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
        public Integer Quantity { get; set; }
        public String DescriptionLower { get; set; }
        public String colorName { get; set; }
        public String colorNumber { get; set; }
        public String Thickness { get; set; }
        public String ItemNumber { get; set; }
        public Boolean ShowAImage {get;set;}
        public Boolean ShowBImage {get;set;}
        public Boolean ShowCImage {get;set;}
        
    }
}