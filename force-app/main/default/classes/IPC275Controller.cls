public class IPC275Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}
    
    
    public IPC275Controller(){
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
                        if(line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.275')){
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            if(line.Description_2__c != null){
                                String[] descriptionParts = line.Description_2__c.split(' ');
                                String sixthWord = '';
                                if (descriptionParts.size() >= 7) {
                                    sixthWord = descriptionParts[6].trim();
                                    quoteLine.seventhWordForEndWall = sixthWord;
                                }
                            }
                            if(line.Description_2__c != null){
                                String[] descriptionParts = line.Description_2__c.split(' ');
                                String secondWord = '';
                                if (descriptionParts.size() >= 3) {
                                    secondWord = descriptionParts[2].trim();
                                    quoteLine.zeroWordForDim2 = secondWord;
                                }
                            }
                            if(line.Description_2__c != null){
                                String[] descriptionParts = line.Description_2__c.split(' ');
                                String fourthWord = '';
                                if (descriptionParts.size() >= 1) {
                                    fourthWord = descriptionParts[0].trim();
                                    quoteLine.fourWordForDim3 = fourthWord;
                                }
                            }
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('screw-On') || line.Description.containsIgnoreCase('screw On') || line.Description.containsIgnoreCase('srw On')){
                                    quoteLine.MountingScrew = checked;
                                }
                                if(line.Description.containsIgnoreCase('cement-On') || line.Description.containsIgnoreCase('cement On') || line.Description.containsIgnoreCase('cmt On')){
                                    quoteLine.MountingCementON = checked;
                                }
                            }
                            if(line.Item_Number__c != null){
                                if(line.Item_Number__c.containsIgnoreCase('GT') &&  line.Item_Number__c.containsIgnoreCase('SS')){
                                    quoteLine.FinishGT = checked;
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
                            if(line.Operator__c != null){
                                if(line.Operator__c.containsIgnoreCase('16') ){
                                    quoteLine.sixteen = checked;  
                                    quoteLine.fourteen = unchecked;  
                                    quoteLine.eighteen = unchecked;  
                                }
                                if(line.Operator__c.containsIgnoreCase('14')){
                                    quoteLine.sixteen = unchecked;  
                                    quoteLine.fourteen = checked;  
                                    quoteLine.eighteen = unchecked;  
                                } 
                                if(line.Operator__c.containsIgnoreCase('18')){
                                    quoteLine.sixteen = unchecked;  
                                    quoteLine.fourteen = unchecked;  
                                    quoteLine.eighteen = checked;  
                                } 
                            }
                            lines.add(quoteLine);
                            quoteLine.quoteLineItem = line;
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
        public String FinishGT {get;set;}
        public String AlloyTypeZero {get;set;}
        public String AlloyTypeFour {get;set;}
        public string seventhWordForEndWall {get;set;}
        public string zeroWordForDim2 {get;set;}
        public string fourWordForDim3 {get;set;}
        public string sixteen {get;set;}
        public string eighteen {get;set;}
        public string fourteen {get;set;}
        
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;} 
    }
}