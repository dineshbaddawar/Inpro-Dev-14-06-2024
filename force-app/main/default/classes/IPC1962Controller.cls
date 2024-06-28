public class IPC1962Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public String formattedDate { get; private set; }
    public IPC1962Controller() {
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
                        if (line.document_Name__c != null && line.document_Name__c.containsIgnoreCase('IPC.1962')) {
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            if(line.Quantity !=null){
                              quoteLine.Quantity = String.valueOf(line.Quantity);

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
        public string Quantity {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}