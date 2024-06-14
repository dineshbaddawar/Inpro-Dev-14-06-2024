public class IPC2343Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    
    public IPC2343Controller() {
        try{
            String thickness;
            String fourZero;
            String sixZero;
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if (isMetricValue == 'False' || isMetricValue == 'false' || isMetricValue == null) {
                isMetric = false;
                thickness = 'available - minimums and/or set-ups apply.';
                fourZero = '.040"';
                sixZero ='.060"';
            }
            if (isMetricValue == 'True' || isMetricValue == 'true') {
                isMetric = true;
                thickness = '2.032mm available - minimums and/or set-ups apply.';
                fourZero = '1.016mm';
                sixZero ='1.524mm';
            }

            customForm.isMetricExpressionForThickness = thickness;
            customForm.isMetricExpressionFourZero = fourZero;
            customForm.isMetricExpressionSixZero = thickness;
            if(quoteId == null){
                BlankForm = true;
            }
            else if(String.isNotEmpty(quoteId)) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                        if(line.Item_Number__c.startsWithIgnoreCase('K41') || line.Item_Number__c.startsWithIgnoreCase('K42')){
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                        lines.add(quoteLine);
                        customForm.quoteLines = lines;
                        }
                    }
                    if(customForm.quoteLines.size() > 0){
                        BlankForm = false;
                    }else{
                        BlankForm = true;
                    }    
                }else{
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
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
        public String isMetricExpressionFourZero {get;set;}
        public String isMetricExpressionSixZero {get;set;}
        public String isMetricExpressionForThickness {get;set;}
    }
}