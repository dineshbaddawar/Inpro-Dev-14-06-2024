public class IPC252Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    
    public IPC252Controller() {
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
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.252')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('screw-On') || line.Description.containsIgnoreCase('screw On') || line.Description.containsIgnoreCase('srw On') || line.Description.containsIgnoreCase('srw-On')){
                                    quoteLine.MountingScrew = checked;
                                }
                                if(line.Description.containsIgnoreCase('cement-On') || line.Description.containsIgnoreCase('cement On') || line.Description.containsIgnoreCase('cmt On') || line.Description.containsIgnoreCase('cmt-On')){
                                    quoteLine.MountingCementON = checked;
                                }
                            }
                            if(line.Item_Number__c != null){
                                if(line.Item_Number__c.containsIgnoreCase('GT')  ){
                                    quoteLine.FinishGT = checked;
                                }
                                if(line.Item_Number__c.containsIgnoreCase('SS')){
                                    quoteLine.FinishSS = checked;
                                }
                            }
                            if(line.Alloy_Type__c != null){
                                if(line.Alloy_Type__c.containsIgnoreCase('430') ){
                                    quoteLine.AlloyTypeZero = checked;  
                                }
                                if(line.Alloy_Type__c.containsIgnoreCase('304') && line.Alloy_Type__c != null){
                                    quoteLine.AlloyTypeFour = checked;
                                } 
                            }
                            if(line.Custom_Angle__c != null){
                                if(line.Custom_Angle__c.containsIgnoreCase('87') ){
                                    quoteLine.AngleEightySeven = checked;  
                                }
                                if(line.Custom_Angle__c.containsIgnoreCase('90')){
                                    quoteLine.AngleNinty = checked;
                                } 
                                if(line.Custom_Angle__c.containsIgnoreCase('93')){
                                    quoteLine.AngleNintyThree = checked;
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
        }catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }        
    }
    
    public class QuoteLineWrapper{
        public QuoteLineItem quoteLineItem {get;set;}
        public String colorName {get;set;}
        public String colorNumber {get;set;}
        public String MountingScrew {get;set;}
        public String MountingCementON {get;set;}
        public String FinishSS {get;set;}
        public String FinishGT {get;set;}
        public String AlloyTypeZero {get;set;}
        public String AlloyTypeFour {get;set;}
        public String AngleEightySeven {get;set;}
        public String AngleNinty {get;set;}
        public String AngleNintyThree {get;set;}
        public string guageFourteen {get;set;}
        public string guagesixteen {get;set;}
        public string guageEighteen {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}