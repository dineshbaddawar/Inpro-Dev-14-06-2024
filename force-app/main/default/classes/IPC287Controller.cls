public class IPC287Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    public string isIncreseHeight {get;set;}
    
    public IPC287Controller() {
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
                 isIncreseHeight = '80'; 
            }else if(String.isNotEmpty(quoteId)){
                 isIncreseHeight = '70';
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.287')){
                            quoteLine.quoteLineItem = line;
                            lines.add(quoteLine);
                        }                        
                    }
                    customForm.quoteLines = lines;
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
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}