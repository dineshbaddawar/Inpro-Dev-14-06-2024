public with sharing class IPC255Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricExperssion { get; set; }
    public String isMetricDrywallThickness{ get; set;}
    public String isMetricEndWallHeight1 { get; set;}
    public String isMetricEndWallHeight2 { get; set;}
    public String isMetricEndWallHeight3 { get; set;}
    public String isMetricEndWallHeight4 { get; set;}
     public String checked = '333';
    public String unchecked = 'fff';
    
    public IPC255Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
            System.debug('quoteId === >'+quoteId);
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricExperssion = '(cm):';
                isMetricDrywallThickness = 'e.g.(1.5875cm,1.5875cm show above)';
                isMetricEndWallHeight1 = '1.2192m';
                isMetricEndWallHeight2 = '2.4384m';
                isMetricEndWallHeight3 = '2.7432m';
                isMetricEndWallHeight4 = '3.048m';
                
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricExperssion = '(in.):';
                isMetricDrywallThickness = 'e.g.(5/8",5/8" show above)';
                
                isMetricEndWallHeight1 = '4';
                isMetricEndWallHeight2 = '8';
                isMetricEndWallHeight3 = '9';
                isMetricEndWallHeight4 = '10';
               
            }

             System.debug('isMetric Exp === >'+isMetric);
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line != null && line.Document_Name__c != null && line.Document_Name__c.containsIgnoreCase('IPC.255')) {
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
                                customLine.DescriptionLower = (String)line.Description_2__c.toLowerCase();
                                String[] parts = customLine.DescriptionLower.split(' ');
                                String firstPart = parts[0].trim();
                                if(firstPart.contains('4')){
                                    customLine.WallHeight1 = checked;
                                }
                                else if(firstPart.contains('8')){ 
                                    customLine.WallHeight2 = checked;
                                }
                                else if(firstPart.contains('9')){
                                    customLine.WallHeight3 = checked;
                                }
                                else if(firstPart.contains('10')){
                                    customLine.WallHeight4 = checked;
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
             System.debug('BlankForm Exp === >'+BlankForm);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            BlankForm = true;
        }
    }

    public IPC255Controller() {
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
        public String WallHeight1 { get; set; }
        public String WallHeight2 { get; set; }
        public String WallHeight3 { get; set; }
        public String WallHeight4 { get; set; }
        public String colorName { get; set; }
        public String colorNumber { get; set; }
       
    }
}