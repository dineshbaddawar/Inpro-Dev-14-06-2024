public class IPC211Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}
    
    public IPC211Controller() {
        try {
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if (isMetricValue == null || !isMetricValue.equalsIgnoreCase('false')) {
                isMetric = false;
            } 
            if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                isMetric = true;
            }
            if (quoteId == null) {
                BlankForm = true;
            }
            else if(String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0) {
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                    for (QuoteLineItem line : quoteLineItems) {
                        if (line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.211')) {
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            quoteLine.currentDate = System.today();
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
        } catch (Exception e) {
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }        
    }
    
    public class QuoteLineWrapper{
        public QuoteLineItem quoteLineItem {get;set;}
        public String colorName {get;set;}
        public String colorNumber {get;set;}
        public Date currentDate {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}