public class IPC3090Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    
    public IPC3090Controller() {
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
            }else if(String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : quoteLineItems) {
                        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.3090')){
                            quoteLine.quoteLineItem = line;
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('screw On') || line.Description.containsIgnoreCase('screw')  || line.Description.containsIgnoreCase('Screw-On')  || line.Description.containsIgnoreCase('srw On')){
                                    quoteLine.MountingScrew = checked;
                                }
                                if(line.Description.containsIgnoreCase('cement On') || line.Description.containsIgnoreCase('cement') || line.Description.containsIgnoreCase('cement-On') || line.Description.containsIgnoreCase('cmt On')){
                                    quoteLine.MountingCementON = checked;
                                }
                                if(line.Description.containsIgnoreCase('1/8')){
                                    quoteLine.radiusEight = checked;
                                }
                                if(line.Description.containsIgnoreCase('3/4')){
                                    quoteLine.radiusFour = checked;
                                }
                            }                            
                            if(line.Item_Number__c != null){
                                if(!line.Item_Number__c.containsIgnoreCase('GT') && (line.Item_Number__c.containsIgnoreCase('SS') || line.Item_Number__c.containsIgnoreCase('SAS'))){
                                    quoteLine.FinishGT = checked;
                                }
                            }
                            if(line.Alloy_Type__c != null){
                                if(line.Alloy_Type__c.startsWithIgnoreCase('430')){
                                    quoteLine.AlloyTypeZero = checked;  
                                    quoteLine.AlloyTypeFour = unchecked;
                                }
                                if(line.Alloy_Type__c.startsWithIgnoreCase('304')){
                                    quoteLine.AlloyTypeFour = checked;
                                    quoteLine.AlloyTypeZero = unchecked;
                                } 
                            }
                            if(line.Operator__c != null){
                                if(line.Operator__c.containsIgnoreCase('14')){
                                    quoteLine.guageFourteen = checked;
                                    
                                }
                                if(line.Operator__c.containsIgnoreCase('16')){
                                    quoteLine.guagesixteen = checked;
                                }
                                if(line.Operator__c.containsIgnoreCase('18')){
                                    quoteLine.guageEighteen = checked;
                                }
                                if(line.Operator__c.containsIgnoreCase('20')){
                                    quoteLine.guageTwenty = checked;
                                }
                            }
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
            System.debug('BlankForm === >'+BlankForm);
        }catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }        
    }
    
    public class QuoteLineWrapper{
        public QuoteLineItem quoteLineItem {get;set;}
        public String MountingScrew {get;set;}
        public String MountingCementON {get;set;}
        public String FinishGT {get;set;}
        public String AlloyTypeZero {get;set;}
        public String AlloyTypeFour {get;set;}
        public string guageFourteen {get;set;}
        public string guagesixteen {get;set;}
        public string guageEighteen {get;set;}
        public string guageTwenty {get;set;}
        public string radiusEight {get;set;}
        public string radiusFour {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}