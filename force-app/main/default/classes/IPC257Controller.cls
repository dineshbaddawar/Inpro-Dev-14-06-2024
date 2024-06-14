public with sharing class IPC257Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricExperssion { get; set; }
    public String isMetricCornerExp1 { get; set; }
    public String isMetricCornerExp2 { get; set; }
    public String isMetricGauge16 { get; set; }
    public String isMetricGauge18 { get; set; } 
    public String isMetricThickness { get; set;} 
    public String isMetricAngle { get; set;}
    public String isMetricWing { get; set;}
     public String checked = '333';
    public String unchecked = 'fff';
    
    public IPC257Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
            System.debug('quoteId === >'+quoteId);
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricExperssion = '(cm):';
                isMetricGauge16 = '16 = .1524cm'; 
                isMetricGauge18 = '18 = .1194cm (custom*)';
                isMetricThickness = '1.5875cm';
                isMetricAngle = '(45°-179° (.3175cm R), 90°-179° (1.905cm R)';
                isMetricWing = '(Min. 3.81cm(.3175cm R), Min. 5.715cm (1.905cm R); Max 25.4cm)';
                isMetricCornerExp1 = '.3175cm (Max. Height304.8cm)*';
                isMetricCornerExp2 = '1.905cm (Max. Height 304.8)*';
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricExperssion = '(in.):';
                isMetricGauge16 = '16 = .060'; 
                isMetricGauge18 = '18 = .047" (custom*)';
                isMetricThickness = '5/8"';
               isMetricAngle = '(45°-179° (1/8" R), 90°-179° (3/4" R)';
                isMetricWing = '(Min. 1-1/2" (1/8" R), Min. 2-1/4" (3/4" R); Max 10")';
                isMetricCornerExp1 = '1/8" (Max. Height 120")*';
                isMetricCornerExp2 = '3/4" (Max. Height 120")*';
            }

             System.debug('isMetric Exp === >'+isMetric);
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        if (line != null && line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.257')) {
                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Brackets__c != null) {
                                customLine.Wing1 = (String)line.Brackets__c;
                            }
                            if (line.Custom_Angle__c != null) {
                                customLine.AngleID = (String)line.Custom_Angle__c;
                            }
                            if (line.Brackets_2__c != null) {
                                customLine.Wing2 = (String)line.Brackets_2__c;
                            }

                            if (line.Height__c != null) {
                                customLine.Height = (Decimal)line.Height__c;
                            }
                            if(line.Alloy_Type__c != null){
                                if(line.Alloy_Type__c.containsIgnoreCase('430') ){
                                    customLine.AlloyType430 = checked;  
                                }
                                if(line.Alloy_Type__c.containsIgnoreCase('304') && line.Alloy_Type__c != null){
                                    customLine.AlloyType304 = checked;
                                } 
                            }
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('1/8') ){
                                    customLine.Description1of8 = checked;  
                                }
                                if(line.Description.containsIgnoreCase('3/4')){
                                    customLine.Description3of4 = checked;
                                } 
                            }
                            if(line.Operator__c != null){
                                if(line.Operator__c.containsIgnoreCase('16') ){
                                    customLine.sixteen = checked;  
                                    customLine.eighteen = unchecked;  
                                }
                                if(line.Operator__c.containsIgnoreCase('18')){
                                    customLine.sixteen = unchecked; 
                                    customLine.eighteen = checked;  
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
            BlankForm = true;
        }
    }

    public IPC257Controller() {
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
        public String Wing1 { get; set; }
        public String Wing2 { get; set; }
        public String AngleID { get; set; }
        public Decimal Height { get; set; }
        public String AlloyType430 { get; set; }
        public String AlloyType304 { get; set; }
        public String Description1of8 { get; set; }
        public String Description3of4 { get; set; }
        public String sixteen { get; set; }
        public String Angle { get; set; }
        public String eighteen { get; set; }
       
    }
}