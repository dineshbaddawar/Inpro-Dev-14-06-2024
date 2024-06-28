public class IPC1646Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean BlankForm {get;set;}
    public Boolean isMetric { get; set; }
    public IPC1646Controller() {
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if (isMetricValue == null) {
                isMetric = false;
            }
            if (isMetricValue == 'False' || isMetricValue == 'false') {
                isMetric = false;
            }
            if (isMetricValue == 'True' || isMetricValue == 'true') {
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
                        if (line.Item_Number__c !=null && (line.Item_Number__c.startsWithIgnoreCase('SSWP') || line.Item_Number__c.startsWithIgnoreCase('DW-SSWP'))) {
                            QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                            if(line.Color__c !=null){
                                quoteLine.colorName = line.Color__c;
                            }else{
                                quoteLine.colorName = '';
                            }
                            quoteLine.quoteLineItem = line;
                            lines.add(quoteLine);
                            
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('304') && line.Description != null && line.Description.containsIgnoreCase('Wall Panel')){
                                quoteLine.AlloyThreeZeroFourForWall = checked;
                                quoteLine.AlloyThreeZeroFourForCorner = unchecked;
                            }
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('304') && line.Description != null && line.Description.containsIgnoreCase('Corner')){
                                quoteLine.AlloyThreeZeroFourForWall = unchecked;
                                quoteLine.AlloyThreeZeroFourForCorner = checked;
                            }
                            
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('18') && line.Description != null && line.Description.containsIgnoreCase('Wall Panel')){
                                quoteLine.Eighteen_Standard_Wall = checked;
                                quoteLine.Sixteen_Standard_Corner = unchecked;
                            }
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('16') && line.Description != null && line.Description.containsIgnoreCase('Corner')){
                                quoteLine.Eighteen_Standard_Wall = unchecked;
                                quoteLine.Sixteen_Standard_Corner = checked;
                            }
                            
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('16') && line.Description != null && line.Description.containsIgnoreCase('Wall Panel')){
                                quoteLine.Sixteen_Avaialable_Wall = checked;
                                quoteLine.Eighteen_Avaialable_Corner = unchecked;
                            }
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('18') && line.Description != null && line.Description.containsIgnoreCase('Corner')){
                                quoteLine.Sixteen_Avaialable_Wall = unchecked;
                                quoteLine.Eighteen_Avaialable_Corner = checked;
                            }
                            
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('20 ga') && line.Description != null && line.Description.containsIgnoreCase('Wall Panel')){
                                quoteLine.Twenty_Availaable_Smooth_Wall = checked;
                                quoteLine.Twenty_Avaialable_Corner = unchecked;
                            }
                            if(line.Description_2__c != null && line.Description_2__c.containsIgnoreCase('20 ga') && line.Description != null && line.Description.containsIgnoreCase('Corner')){
                                quoteLine.Twenty_Availaable_Smooth_Wall = unchecked;
                                quoteLine.Twenty_Avaialable_Corner = checked;
                            }
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
        public String AlloyThreeZeroFourForWall {get;set;}
        public String AlloyThreeZeroFourForCorner {get;set;}
        public String Eighteen_Standard_Wall {get;set;}
        public String Sixteen_Standard_Corner {get;set;}
        public String Sixteen_Avaialable_Wall {get;set;}
        public String Eighteen_Avaialable_Corner {get;set;}
        public String Twenty_Availaable_Smooth_Wall {get;set;}
        public String Twenty_Avaialable_Corner {get;set;}
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}