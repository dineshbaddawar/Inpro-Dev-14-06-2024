public with sharing class IPC3211Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricExperssion { get; set; }
    public String isMetricGauge1 { get; set;}
    public String isMetricGauge2 { get; set;}
    public String isMetricGauge3 { get; set;}
     public String checked = '333';
    public String unchecked = 'fff';
    
    public IPC3211Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
            System.debug('quoteId === >'+quoteId);
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricExperssion = '(cm):';
                isMetricGauge1 = '14 = .1880cm';
                isMetricGauge2 = '16 = .1524cm';
                isMetricGauge3 = '18 = .1194cm';
                
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricExperssion = '(in.):';
                isMetricGauge1 = '14 = .074"';
                isMetricGauge2 = '16 = .060"(Standard)';
                isMetricGauge3 = '18 = .047"';
                
               
            }

             System.debug('isMetric Exp === >'+isMetric);
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line != null && line.Document_Name__c != null && line.Document_Name__c.containsIgnoreCase('IPC.3211')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Brackets__c != null) {
                                customLine.Bracket = (String)line.Brackets__c;
                            }
                            if (line.Brackets_2__c != null) {
                                customLine.Bracket2 = (String)line.Brackets_2__c;
                            }
                            if (line.Height__c != null) {
                                customLine.Height = (Decimal)line.Height__c;
                            }
                            if (line.Width__c != null) {
                                customLine.Width = (Decimal)line.Width__c;
                            }
                            if(line.Item_Number__c != null) {
                                if((line.Item_Number__c.contains('SS') || line.Item_Number__c.contains('SAS')) && !line.Item_Number__c.contains('GT')) {
                                    customLine.SteelType = checked;
                                }
                            }

                            if(line.Alloy_Type__c != null) {
                                if(line.Alloy_Type__c.contains('430')) {
                                    customLine.AllyType430 = checked;
                                }
                                if(line.Alloy_Type__c.contains('304')) {
                                    customLine.AllyType304 = checked;
                                }
                            }
                            if(line.Operator__c != null) {
                                if(line.Operator__c.contains('14')) {
                                    customLine.Operator14 = checked;
                                }
                                if(line.Operator__c.contains('16')) {
                                    customLine.Operator16 = checked;
                                }
                                if(line.Operator__c.contains('18')) {
                                    customLine.Operator18 = checked;
                                }
                            }
                            if (line.Description != null) {
                                if (line.Description.containsIgnoreCase('screw-On') || line.Description.containsIgnoreCase('screw On') || line.Description.containsIgnoreCase('srw-on') || line.Description.containsIgnoreCase('srw On')) {
                                    customLine.MountingScrew = checked;
                                }
                                if (line.Description.containsIgnoreCase('cement-On') || line.Description.containsIgnoreCase('cement On') || line.Description.containsIgnoreCase('cmt-on') || line.Description.containsIgnoreCase('cmt On')) {
                                    customLine.MountingCementON = checked;
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

    public IPC3211Controller() {
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
        public String Bracket { get; set; }
        public String Bracket2 { get; set; }
        public Decimal Height { get; set; }
        public Decimal Width { get; set; }
        public String SteelType { get; set; }
        public String AllyType430 { get; set; }
        public String AllyType304 { get; set; }
        public String Operator14 { get; set; }
        public String Operator16 { get; set; }
        public String Operator18 { get; set; }
        public String MountingScrew { get; set; }
        public String MountingCementON { get; set; }
       
    }
}