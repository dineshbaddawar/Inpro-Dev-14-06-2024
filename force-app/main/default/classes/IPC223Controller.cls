public with sharing class IPC223Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }

    public IPC223Controller(ApexPages.StandardController controller) {
        customForm = new CustomFormWrapper();
        customForm.quoteLines = new List<CustomQuoteLineItem>();
        
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');

            if (quoteId == null) {
                BlankForm = true;
            } else if (String.isNotEmpty(quoteId)) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null && quoteLines.size() > 0) {
                    List<CustomQuoteLineItem> lines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.223')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (!String.isBlank(line.Color__c)) {
                                customLine.Color = line.Color__c;
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? last4 : null;
                            }
                            if (line.Quantity != null) {
                                customLine.Quantity = (Decimal)line.Quantity;
                            }
                            if (line.Item_Number__c != null) {
                                customLine.ItemNumber = line.Item_Number__c;
                            }
                            if (line.Size__c != null) {
                                customLine.size = line.Size__c;
                            }
                            if (line.Type__c != null) {
                                customLine.type = line.Type__c;
                            }
                            if (line.Vendor__c != null) {
                                customLine.vendor = line.Vendor__c;
                            }
                            if (line.Pattern__c != null) {
                                customLine.patten = line.Pattern__c;
                            }
                            if (line.Document_Name__c != null) {
                                customLine.DocumentName = line.Document_Name__c;
                            }
                            if (line.Style__c != null) {
                                customLine.style = line.Style__c;
                            }
                            lines.add(customLine);
                        }
                    }
                    customForm.quoteLines = lines;
                    BlankForm = customForm.quoteLines.size() > 0 ? false : true;
                } else {
                    BlankForm = true;
                }
            }
        } catch (Exception e) {
            System.debug('Exception in IPC223Controller: ' + e.getMessage());
        
            BlankForm = true;
        }
    }

    public IPC223Controller() {
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
        public Decimal Quantity { get; set; }
        public String ItemNumber { get; set; }
        public String Color { get; set; }
        public String size { get; set; }
        public String type { get; set; }
        public String vendor { get; set; }
        public String patten { get; set; }
        public String DocumentName { get; set; }
        public String style { get; set; }
    }
}