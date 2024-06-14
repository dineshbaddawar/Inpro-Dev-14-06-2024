public with sharing class IPC139Controller {
    public CustomFormWrapper customForm {get;set;}
    private String checked = '333';
    private String unchecked = 'fff';
    public Boolean BlankForm {get;set;}
    public Boolean isMetric { get; set; }
    
    public IPC139Controller() {
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if(isMetricValue == null){
                isMetric = false;
            }
            if(isMetricValue == 'False' || isMetricValue == 'false'){
                isMetric = false;
            }
            if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                isMetric = true;
            }
            if (String.isNotEmpty(quoteId) || quoteId !=null) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineItem> filteredItems = quoteLineItems;
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : filteredItems) {
                        if(line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.139')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            quoteLine.quoteLineItem = line;
                            quoteLine.materialThickness =String.valueOf(line.Item_Number__c);
                            if(line.Quantity !=null){
                                quoteLine.QliQuantity= line.Quantity;
                            }
                            if(line.Custom_Angle__c !=null){
                                quoteLine.CustomAngle= line.Custom_Angle__c;
                            }
                            if(line.Color__c !=null){
                                if(line.Color__c.contains('-')){
                                    quoteLine.colorName = String.valueOf(line.Color__c.split('-')[0].trim());
                                }else{
                                    quoteLine.colorName = line.Color__c;
                                }
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }else{
                                quoteLine.colorName  ='';
                            }
                            
                            // For YES
                            if (isMetric == false) {
                                if (line.Description_2__c != null && line.Description_2__c.toLowerCase().contains('tape-on') || (line.Description != null && line.Description.toLowerCase().contains('tape-on'))) {
                                    quoteLine.checkYesTrue = '333';
                                } else {
                                    quoteLine.checkYesTrue = 'fff';
                                }
                            }
                            if (isMetric == true) {
                                if (line.Metric_Description_2__c != null && line.Metric_Description_2__c.toLowerCase().contains('tape-on') || (line.Metric_Description_1__c != null && line.Metric_Description_1__c.toLowerCase().contains('tape-on'))) {
                                    quoteLine.checkYesTrue = '333';
                                } else {
                                    quoteLine.checkYesTrue = 'fff';
                                }
                            }
                            
                            // For NO
                            if (isMetric == false) {
                                if ((line.Description_2__c != null && line.Description_2__c.toLowerCase().contains('no tape')) ||(line.Description != null && line.Description.toLowerCase().contains('no tape'))) {
                                    quoteLine.checkNoTrue = '333';
                                } else {
                                    quoteLine.checkNoTrue = 'fff';
                                }
                            }
                            
                            if (isMetric == true) {
                                if ((line.Metric_Description_2__c != null && line.Metric_Description_2__c.toLowerCase().contains('no tape')) ||  (line.Metric_Description_1__c != null && line.Metric_Description_1__c.toLowerCase().contains('no tape'))) {
                                    quoteLine.checkNoTrue = '333';
                                } else {
                                    quoteLine.checkNoTrue = 'fff';
                                }
                            }
                            
                            lines.add(quoteLine);
                        }else{
                            
                        }
                    }
                    if(lines.size()>0){
                        customForm.quoteLines = lines;
                    }else{
                        BlankForm = true;
                    }
                    
                }else {
                    BlankForm = true;
                }
            }
            if (quoteId == null) { 
                BlankForm = true;
            } else {
                //  BlankForm = false;
            }
            System.debug('BlankForm == >'+BlankForm);
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    public class QuoteLineWrapper{
        public QuoteLineItem quoteLineItem {get;set;}
        public String materialThickness {get;set;}
        public String colorName {get;set;}
        public String CustomAngle {get;set;}
        public Decimal QliQuantity {get;set;}
        public String colorNumber {get;set;}
        public String checkYesTrue {get;set;}
        public String checkNoTrue {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}