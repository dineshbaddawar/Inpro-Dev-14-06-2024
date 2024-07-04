public class IPC1225Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}
    public IPC1225Controller() {
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
                        if(line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.1225')){
                            if(line.Item_Number__c !=null){
                                String itemNumberString = line.Item_Number__c;
                                if (itemNumberString != null && itemNumberString.length() < 4) {
                                    quoteLine.ItemNumber = line.Item_Number__c;
                                }else{
                                    String last4Chars = itemNumberString.substring(itemNumberString.length() - 4);
                                    Boolean isNumeric = true;
                                    try {
                                        Decimal.valueOf(last4Chars);
                                    } catch (Exception e) { 
                                        isNumeric = false;
                                    }
                                    if (isNumeric){
                                        quoteLine.ItemNumber =  itemNumberString.substring(0, itemNumberString.length() - 5);
                                    }else{
                                        quoteLine.ItemNumber = line.Item_Number__c;
                                    }
                                }
                            }
                            if(line.Color__c !=null){
                                quoteLine.colorName = line.Color__c;
                            }
                            if(line.Quantity !=null){
                                quoteLine.QuantyValue = line.Quantity;
                            }
                            if(line.Custom_Angle__c !=null){
                                quoteLine.CustomAngleValue = line.Custom_Angle__c;
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
        public String ItemNumber {get;set;}
        public String colorName {get;set;}
        public Decimal QuantyValue {get;set;}
        public String CustomAngleValue {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}