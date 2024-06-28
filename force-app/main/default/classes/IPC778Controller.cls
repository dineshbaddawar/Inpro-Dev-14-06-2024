public class IPC778Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public String formattedDate { get; private set; }
    public IPC778Controller() {
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
             Date  currentDate = Date.today();
            formattedDate = currentDate.format();
            if(quoteId == null){
                BlankForm = true;
            }else if(String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        if ( line.Item_Number__c !=null && (line.Item_Number__c.startsWithIgnoreCase('DSPDP') || line.Item_Number__c.startsWithIgnoreCase('DSF1P') || line.Item_Number__c.startsWithIgnoreCase('DSF3P'))) {
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            if(line.Color__c !=null){
                                quoteLine.colorName = line.Color__c;
                            }else{
                                quoteLine.colorName = '';
                            }
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
        public String colorName {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}