public with sharing class IPC251Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String MetricExpression { get; set; }
    public String isMetricWidth { get; set; }
    public String isMetricHeight { get; set; }

    public IPC251Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric');
            
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricWidth = '(1.905cm Min.)';
                metricExpression = '(cm):';
                isMetricHeight = '(304.80cm Max.*)';
            }
            if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricHeight ='(120" Max.*)';
                isMetricWidth = '(3/4" Min. )';
                metricExpression= '(in.):';
            }

            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);

                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line != null && line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.251')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = line.Quantity;
                            }
                            if (line.Width__c != null) {
                                customLine.Width = line.Width__c;
                            }
                            if (line.Height__c != null) {
                                customLine.Height = line.Height__c;
                            }
                            if (line.Brackets__c != null) {
                                customLine.Brackets = line.Brackets__c;
                            }
                            if (line.Brackets_2__c != null) {
                                customLine.Brackets2 = line.Brackets_2__c;
                            }
                            if (line.Alloy_Type__c != null) {
                                customLine.AlloyType = line.Alloy_Type__c;
                            }
                            if (line.Operator__c != null) {
                                customLine.Operator = line.Operator__c;
                            }
                            if (line.Document_Name__c != null) {
                                customLine.DocumentName = line.Document_Name__c;
                            }
                            if (line.Description != null) {
                                if (line.Description.containsIgnoreCase('screw-On') || line.Description.containsIgnoreCase('screw On') || line.Description.containsIgnoreCase('srw-on') || line.Description.containsIgnoreCase('srw On')) {
                                    customLine.MountingScrew = '333';
                                }
                                if (line.Description.containsIgnoreCase('cement-On') || line.Description.containsIgnoreCase('cement On') || line.Description.containsIgnoreCase('cmt-on') || line.Description.containsIgnoreCase('cmt On')) {
                                    customLine.MountingCementON = '333';
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

    public IPC251Controller() {
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
        public Decimal Quantity { get; set; }
        public Decimal Width { get; set; }
        public Decimal Height { get; set; }
        public String Brackets { get; set; }
        public String AlloyType { get; set; }
        public String Brackets2 { get; set; }
        public String Operator { get; set; }
        public String MountingScrew { get; set; }
        public String DocumentName { get; set; }
        public String MountingCementON { get; set; }
    }
}