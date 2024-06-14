public with sharing class IPC298Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricExperssion { get; set; }
    public String isMetricGAuge { get; set; }
    public String isMetricHeight { get; set; }

    public IPC298Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
system.debug(isMetricValue);
            

            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricExperssion = '(cm):';
                isMetricGAuge = '2.032mm';
                isMetricHeight = '(Max Height 304.8cm)';
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricExperssion = '(in.):';
                isMetricGAuge = '.080';
                isMetricHeight = '(Max Height 120")';
            }

            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);

                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line.Item_Number__c != null && line.Item_Number__c.containsIgnoreCase('DW-ALM-C')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Description_2__c != null) {
                                customLine.Description2 = (String)line.Description_2__c;
                            }
                            if (line.Item_Number__c != null) {
                                customLine.ItemNumber = (String)line.Item_Number__c;
                            }
                            if (line.Description_2__c != null && (line.Description_2__c.containsIgnoreCase('deg') || line.Description_2__c.containsIgnoreCase('De'))) {
                                String[] descriptionParts = line.Description_2__c.split(' ');
                                if (descriptionParts.size() >= 1) {
                                    customLine.Wing1 = descriptionParts[0].trim();
                                }
                                if (descriptionParts.size() >= 3) {
                                    customLine.Wing2 = descriptionParts[2].trim();
                                }
                                if (descriptionParts.size() >= 5) {
                                    customLine.Height = descriptionParts[4].trim();
                                }
                                if (descriptionParts.size() >= 6) {
                                    customLine.AngleId = descriptionParts[5].trim();
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
            BlankForm = true;
        }
    }

    public IPC298Controller() {
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
        public String AngleId { get; set; }
        public String Height { get; set; }
        public String Wing2 { get; set; }
        public String Wing1 { get; set; }
        public String ItemNumber { get; set; }
        public String Description2 { get; set; }
    }
}