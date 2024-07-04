public class IPC782Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public String formattedDate { get; private set; }
    public IPC782Controller() {
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
                        System.debug('OutSide === >'+line.Item_Number__c);
                        if (line.Item_Number__c !=null && (line.Item_Number__c.startsWithIgnoreCase('DSWSPWL') || line.Item_Number__c.startsWithIgnoreCase('DSWSPWO'))) {
                            System.debug('Inside === >'+line.Item_Number__c);
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            if(line.Color__c !=null){
                                quoteLine.colorName = line.Color__c;
                            }else{
                                quoteLine.colorName = '';
                            }
                            if (line.Quantity != null) {
                                quoteLine.QuantityValue = (Decimal) line.Quantity;
                            }
                            if (line.Width__c != null) {
                                quoteLine.WidthValue = (Decimal) line.Width__c;
                            }
                             if (line.Length__c != null) {
                                quoteLine.LengthValue = (Decimal) line.Length__c;
                            }
                            quoteLine.quoteLineItem = line;
                            lines.add(quoteLine);
                        }                        
                    }
                    customForm.quoteLines = lines;
                    System.debug('Record Size == >'+customForm.quoteLines.size());
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
        public Decimal WidthValue { get; set; }
        public Decimal LengthValue { get; set; }
        public Decimal QuantityValue { get; set; }
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}