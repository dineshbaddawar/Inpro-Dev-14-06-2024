public class IPC074Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String checked = '333';
    public String unchecked = 'fff';
    
    public IPC074Controller() {
        try {
            String HeightHorizontal;
            String WidthHorizontal;
            String HeightVertcial;
            String WidthVertcial;
            String Tolerance;
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');

            if (isMetricValue == 'False' || isMetricValue == 'false' || isMetricValue == null) {
                isMetric = false;
                Tolerance = 'Tolerance: +.060"/-0';
                HeightHorizontal = 'Max. 48"';
                WidthHorizontal = 'Max. 120';
                HeightVertcial = 'Max. 120';
                WidthVertcial = 'Max. 120';
            }
            if (isMetricValue == 'True' || isMetricValue == 'true') {
                isMetric = true;
                Tolerance = 'Tolerance: +0.1524cm/-0';
                HeightHorizontal = 'Max. 121.92cm';
                WidthHorizontal = 'Max. 304.8cm';
                HeightVertcial = 'Max. 304.8cm';
                WidthVertcial = 'Max. 121.92cm';
            }
            customForm.isMetricExperssionTolerance = Tolerance;
            customForm.isMetricHeightHorizontal = HeightHorizontal;
            customForm.isMetricHeightVertical = HeightVertcial;
            customForm.isMetricWidthHorizontal = WidthHorizontal;
            customForm.isMetricWidthVertical = WidthVertcial;

            if (quoteId == null) {
                BlankForm = true;
            } 
            else if(String.isNotEmpty(quoteId)) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLineItems.size() > 0) {
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.074')){
                            quoteLine.quoteLineItem = line;
                            if (line.Color__c != null) {
                                quoteLine.colorName = line.Color__c.split('-')[0].trim();
                                String last4 = line.Color__c.length() >= 4 ? line.Color__c.substring(line.Color__c.length() - 4) : '';
                                quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                            }
                            if (line.Description != null) {
                                String[] descriptionParts = line.Description.split(' ');
                                String firstWord = '';
                                if (descriptionParts.size() >= 1) {
                                    firstWord = descriptionParts[0].trim();
                                    quoteLine.materialThickness = firstWord;
                                }
                                if(line.Description.containsIgnoreCase('w/ adh') || line.Description.containsIgnoreCase('w/adh') || line.Description.containsIgnoreCase('w adh')){
                                    quoteLine.peelStickAdh = checked;
                                    quoteLine.peelStickNotAdh = unchecked;
                                }else{
                                    quoteLine.peelStickNotAdh = checked;
                                    quoteLine.peelStickAdh = unchecked;
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
                } else {
                    BlankForm = true;
                }
            }
            
        } catch (Exception e) {
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public class QuoteLineWrapper {
        public QuoteLineItem quoteLineItem { get; set; }
        public String colorName { get; set; }
        public String colorNumber { get; set; }
        public String materialThickness { get; set; }
        public String peelStickAdh { get; set; }
        public String peelStickNotAdh { get; set; }
    }
    
    public class CustomFormWrapper {
        public Quote quoteRecord { get; set; }
        public List<QuoteLineWrapper> quoteLines { get; set; }
        public string isMetricExperssionTolerance {get;set;}
        public string isMetricHeightHorizontal {get;set;}
        public string isMetricWidthHorizontal {get;set;}
        public string isMetricHeightVertical {get;set;}
        public string isMetricWidthVertical {get;set;}
    }
}