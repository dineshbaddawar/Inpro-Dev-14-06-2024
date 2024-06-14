public with sharing class IPC080Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String metricExpression { get; set; }
    
    public IPC080Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                metricExpression = '10.16 cm';
            }
            if((isMetricValue == 'False')||(isMetricValue == 'false')){
                isMetric = false;
                metricExpression= '4';
            }
            if(isMetricValue == null){
                isMetric = false;
                metricExpression= '4';
            }
            
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null && quoteLines.size() > 0) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line != null && line.Item_Number__c != null && line.Item_Number__c.startsWithIgnoreCase('DW-BEND')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            customLine.Description = line.Description != null ? line.Description : null;
                            if (line.Color__c != null && !String.isBlank(line.Color__c)) {
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? String.valueOf(last4) : null;
                            }
                            customLine.Quantity = line.Quantity != null ? (Integer) line.Quantity : null;
                            customLine.ItemNumber = line.Item_Number__c != null ? (String) line.Item_Number__c : null;
                            customForm.quoteLines.add(customLine);
                        }
                    }
                    
                } BlankForm = customForm.quoteLines.size() > 0 ? false : true;
            } else {
                BlankForm = true;
            }
        } catch (Exception e) {
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
    }
    
    public IPC080Controller() {
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
        public String Description { get; set; }
        public String colorName { get; set; }
        public String colorNumber { get; set; }
        public String ItemNumber { get; set; }
        public Integer Quantity { get; set; }
    }
}