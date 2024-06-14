public class IPC225Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm { get; set; }
    public IPC225Controller() {
        try{ 
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            if (quoteId == null) {
                BlankForm = true;
            } else if (String.isNotEmpty(quoteId)) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.225')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c;
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            lines.add(quoteLine);
                        }
                    }
                     customForm.quoteLines = lines;
                    BlankForm = customForm.quoteLines.size() > 0 ? false : true;
                } else {
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
    }
}