public class IPC188Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    
    public IPC188Controller(){
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if(isMetricValue == 'False' || isMetricValue == 'false' || isMetricValue == null){
                isMetric = false;
            }
            if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                isMetric = true;
            }
            
            if(quoteId == null){
                BlankForm = true;
            }
            else if(String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems){
                        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                        if( line.Item_Number__c != null && line.Item_Number__c.startsWithIgnoreCase('DW-BEND')){
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('3/4')){
                                    quoteLine.checkboxTrue = checked;
                                    quoteLine.checkboxFalse = unchecked;
                                }else{
                                    quoteLine.checkboxTrue = unchecked;
                                    quoteLine.checkboxFalse = checked;
                                }
                                quoteLine.materailThickness = line.Description.split(' ')[0].trim();
                            }
                            lines.add(quoteLine);
                        } 
                    }
                    customForm.quoteLines = lines;
                    if(customForm.quoteLines.size() > 0){
                        BlankForm = false;
                    }else{
                        BlankForm = true;
                    } 
                }
                else{
                    BlankForm = true;
                }
            }
        }catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }        
    }
    
    public class QuoteLineWrapper{
        public QuoteLineItem quoteLineItem {get;set;}
        public String colorName {get;set;}
        public String colorNumber {get;set;}
        public String checkboxTrue {get;set;}
        public String checkboxFalse {get;set;}
        public String materailThickness {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}