public class IPC043Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}
    public IPC043Controller() {
        try{
            String message;
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if(isMetricValue == null){
                isMetric = false;
                  message = 'Total width of dimension \'A\' will be 5" longer \n' +
                 'than the distance between End Caps – \n' +
                 'Dimension \'B\'.';
                 customForm.isMetricExperssion = message;
            }
            if(isMetricValue == 'False' || isMetricValue == 'false'){
                isMetric = false;
                 message = 'Total width of dimension \'A\' will be 5" longer \n' +
                 'than the distance between End Caps – \n' +
                 'Dimension \'B\'.';
                 customForm.isMetricExperssion = message;
            }
            if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                isMetric = true;
                  message = 'Total width of dimension \'A\' will be \n' +
                 '12.7cm longer than the distance between \n' +
                 'End Caps – Dimension \'B\'.';
                 customForm.isMetricExperssion = message;
            }
            if (String.isNotEmpty(quoteId) && quoteId !=null) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.Item_Number__c.startsWithIgnoreCase('6000V-CC')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            quoteLine.quoteLineItem = line;
                            if(line.Color__c != null){
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String first4 = line.Color__c.length() >= 4 ? line.Color__c.substring(0, 4) : '';
                                quoteLine.colorNumber = first4.isNumeric() ? first4 : '';
                            }
                            lines.add(quoteLine);
                        }
                    }
                    customForm.quoteLines = lines;
                }
            }
            if(quoteId == null){
                BlankForm = true;
            }else{
                BlankForm = false;
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
        public string isMetricExperssion {get;set;}
    }
}