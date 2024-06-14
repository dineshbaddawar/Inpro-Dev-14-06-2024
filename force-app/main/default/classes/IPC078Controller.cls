public with sharing class IPC078Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }

    public IPC078Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');

            if (quoteId == null) {
                BlankForm = true;
            } else if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);

                if (quoteLines != null && !quoteLines.isEmpty()) {
                    List<CustomQuoteLineItem> lines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.078')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (!String.isBlank(line.Color__c)) {
                                customLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.right(4);
                                customLine.colorNumber = last4.isNumeric() ? String.valueOf(last4) : null;
                            }
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer) line.Quantity;
                            }
                            if (line.Item_Number__c != null) {
                                customLine.ItemNumber = (String) line.Item_Number__c;
                            }
                            if (line.Document_Name__c != null) {
                                customLine.DocumentName = (String) line.Document_Name__c;
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
            System.debug('Exception in IPC078Controller: ' + e.getMessage());
            BlankForm = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage()));
        }
    }

    public IPC078Controller() {
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
        public String DocumentName { get; set; }
    }
}