public class IPC254Controller {
    public CustomFormWrapper customForm {get;set;}
    public String checked = '333';
    public String unchecked = 'fff';
    public Boolean isMetric {get;set;}
    public Boolean BlankForm {get;set;}
    
    public IPC254Controller() {
        try{
            String guageValueForSevenFOur;
            String guageValueForSixZero;
            String guageValueForFourSeven;
            String Message;
            String InchesOrCM;
            String WingMessage;
            String radiusEightOrFive;
            String radiusFOurOrFive;
            String CornerGuard;
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            if(isMetricValue == 'False' || isMetricValue == 'false' || isMetricValue == null){
                isMetric = false;
                guageValueForSevenFOur = '14 = .074';
                guageValueForSixZero = '16 = .060';
                guageValueForFourSeven = '18 = .047';
                message = 'Heavy Duty Adhesive provided for cement-on.  Hardware provided for screw-on: #6 x 1-1/4 in. Phillips flat head self-tapping screws and ¼ in. plastic alligator anchor.';
                InchesOrCM = '(in.):';
                WingMessage = '(Min = 1" * (1/8" R) or 2" (3/4" R). Max = 24")';
                radiusEightOrFive = '1/8';
                radiusFOurOrFive = '3/4' ;
                CornerGuard = '(1/8 in. R:  Min=45°  Max=179°; ¾ in. R: Min=90°  Max=135°; Tolerance +/- 2° w/ 10° tapered edges)';
                
            }
            if(isMetricValue == 'True' ||isMetricValue == 'true' ){
                isMetric = true;
                guageValueForSevenFOur = '14 = .1880cm';
                guageValueForSixZero = '16 = .1524cm';
                guageValueForFourSeven = '18 = .1194cm';
                message = 'Heavy Duty Adhesive provided for cement-on.  Hardware provided for screw-on: #6 x 3.175 cm. Phillips flat head self-tapping screws and .635 cm. plastic alligator anchor.';
                InchesOrCM = '(cm.):';
                WingMessage = '(Min = 3.81cm (.3175cm R) or 5.08cm (1.905cm R). Max = 60.96cm)';
                radiusEightOrFive = '.3175cm';
                radiusFOurOrFive = '1.905cm' ;
                CornerGuard = '(.3175 cm. R:  Min=45°  Max=179°; 1.905 cm. R: Min=90°  Max=135°; Tolerance +/- 2° w/ 10° tapered edges)';
            }
            customForm.isMetricExperssionForGuageZeroSevenFour = guageValueForSevenFOur;
            customForm.isMetricExperssionForGuageZeroSixZero = guageValueForSixZero;
            customForm.isMetricExperssionForGuageZeroFourSeven = guageValueForFourSeven;
            customForm.isMetricExperssionMessage = message;
            customForm.isMetricExperssionCentiMeterOrInches = InchesOrCM;
            customForm.isMetricExperssionWngMessage = WingMessage;
            customForm.isMetricExperssionCornerRadiusEight = radiusEightOrFive;
            customForm.isMetricExperssionCornerRadiusFour = radiusFOurOrFive;
            customForm.isMetricExperssionCornerGuardAngle = CornerGuard;

            if(quoteId == null){
                BlankForm = true;
            }else if(String.isNotEmpty(quoteId)){
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0){
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                    for (QuoteLineItem line : quoteLineItems) {
                        system.debug('Document Name == >'+line.document_Name__c);
                        if(line.document_Name__c != null && line.document_Name__c.startsWithIgnoreCase('IPC.254')){
                            quoteLine.quoteLineItem = line;
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
                                if(line.Item_Number__c.containsIgnoreCase('SS')){
                                    if(line.Item_Number__c.containsIgnoreCase('GT')  ){
                                        quoteLine.FinishGT = checked;
                                    }
                                    else 
                                    {
                                        quoteLine.FinishSS = checked;
                                    }
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
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
        public string isMetricExperssionForGuageZeroSevenFour {get;set;}
        public string isMetricExperssionForGuageZeroSixZero {get;set;}
        public string isMetricExperssionForGuageZeroFourSeven {get;set;}
        public string isMetricExperssionMessage {get;set;}
        public string isMetricExperssionCentiMeterOrInches {get;set;}
        public string isMetricExperssionWngMessage {get;set;}
        public string isMetricExperssionCornerRadiusEight {get;set;}
        public string isMetricExperssionCornerRadiusFour {get;set;}
        public string isMetricExperssionCornerGuardAngle {get;set;}
    }
}