public class IPC092Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    public string isMetricExperssionisProductView {get;set;}
    public string isMetricExperssionisWidthHeight {get;set;}
    public IPC092Controller() {
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            
            if(isMetricValue ==null || isMetricValue == 'false' || isMetricValue =='False' ){
                isMetric = false;
            }
            if(isMetricValue !=null &&  (isMetricValue == 'true' || isMetricValue =='True' )){
                isMetric =true;
            }
             if( isMetric == false){
                  isMetricExperssionisProductView = 'Tolerance: +.060\'\'/-0';
                  isMetricExperssionisWidthHeight = '(Max. 48\'\')';
             }
             if( isMetric == true){
                isMetricExperssionisProductView = 'Tolerance: +1.524mm/-0';
                isMetricExperssionisWidthHeight = '(Max. 121.92cm)';
             }
             if(quoteId == null){
                BlankForm = true;
            }else if (String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.092')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();

                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            if(line.Description != null){
                                String[] descriptionParts = line.description.split(' ');
                                String firstWord = descriptionParts[0];
                                quoteLine.isDescription = firstWord.trim();
                            }
                            // For NO
                            if (line.description != null && (line.description.toLowerCase().contains('w/o adh') || line.description.toLowerCase().contains('w/oadh'))) {
                                quoteLine.isNoCheckTrue = '333';
                            }else{
                                quoteLine.isNoCheckTrue = 'fff';
                            }
                            // For YES 
                            if (line.description != null && (line.description.toLowerCase().contains('w/ adh') || line.description.toLowerCase().contains('w/adh') || line.description.toLowerCase().contains('w adh'))) {
                                quoteLine.isYesCheckTrue = '333';
                            }else{
                                quoteLine.isYesCheckTrue = 'fff';
                            }
                            lines.add(quoteLine);
                        }else{
                            BlankForm = true;
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
        public String colorNumber {get;set;}
        public string isDescription {get;set;}
        public string isYesCheckTrue {get;set;}
        public string isNoCheckTrue {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}