public with sharing class IPC176Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }


    public IPC176Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            
            
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteLines = new List<CustomQuoteLineItem>();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);

                if (quoteLines != null) {
                    for (QuoteLineItem line : quoteLines) {
                        if (line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.176')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (!String.isBlank(line.Color__c)) {
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? last4 : null;
                            }
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Item_Number__c != null) {
                                customLine.ItemNumber = (String)line.Item_Number__c;
                            }
                            if (line.Custom_Angle__c != null) {
                                customLine.customAngle = (String)line.Custom_Angle__c;
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

    public IPC176Controller() {
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
        public String customAngle { get; set; }
        public String ItemNumber { get; set; }
    }
}