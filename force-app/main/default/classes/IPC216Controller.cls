public with sharing class IPC216Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }

    public IPC216Controller(ApexPages.StandardController controller) {
        customForm = new CustomFormWrapper();
        customForm.quoteLines = new List<CustomQuoteLineItem>();

        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric');
            
            if (quoteId == null) {
                BlankForm = true;
            } else if (String.isNotEmpty(quoteId)) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);

                if (isMetricValue == null) {
                    isMetric = false;
                } else if (isMetricValue.toLowerCase() == 'false') {
                    isMetric = false;
                } else if (isMetricValue.toLowerCase() == 'true') {
                    isMetric = true;
                }

                if (quoteLines != null && quoteLines.size() > 0) {
                    List<CustomQuoteLineItem> lines = new List<CustomQuoteLineItem>();
                    Integer count = 1;
                    for (QuoteLineItem line : quoteLines) {
                        if (line.Item_Number__c != null && (line.Item_Number__c.startsWithIgnoreCase('K41') || line.Item_Number__c.startsWithIgnoreCase('K42')) ) {
                            if (!line.Item_Number__c.contains('T') || !line.Item_Number__c.contains('B')) {
   
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (!String.isBlank(line.Color__c)) {
                                customLine.Color = line.Color__c;
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? last4 : null;
                            }
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Item_Number__c != null) {
                                customLine.ItemNumber = line.Item_Number__c;
                            }
                            customLine.SerialNo = count++;
                            lines.add(customLine);
                        }
                    }
                    }
                    customForm.quoteLines = lines;
                    BlankForm = customForm.quoteLines.size() > 0 ? false : true;
                } else {
                    BlankForm = true;
                }
            }
        } catch (Exception e) {
            System.debug('Exception in IPC216Controller: ' + e.getMessage());
            BlankForm = true;
        }
    }

    public IPC216Controller() {
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
        public String ItemNumber { get; set; }
        public String Color { get; set; }
        public Integer SerialNo { get; set; }
    }
}