public with sharing class IPC256Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public String isMetricExperssion { get; set; }
    public String isMetricAngleBox1 { get; set;}
    public String isMetricAngleBox2 { get; set;}
    public String isMetricWingbox1 { get; set;}
    public String isMetricWingbox2 { get; set;}
    public String isMetricWingbox3 { get; set;}
    public String isMetricWingbox4 { get; set;}
    public String isMetricWingbox5 { get; set;}
     public String checked = '333';
    public String unchecked = 'fff';
    
    public IPC256Controller(ApexPages.StandardController controller) {
        try {
            String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            String isMetricValue = ApexPages.currentPage().getParameters().get('isMetric'); 
            System.debug('quoteId === >'+quoteId);
            if(quoteId == null){
                quoteId = controller.getId();
            }
            if((isMetricValue == 'true')||(isMetricValue == 'True')){
                isMetric = true;
                isMetricExperssion = '(cm):';
                isMetricAngleBox1 = 'Available in 6.35cm Wings with 90° Angle Only';
                isMetricAngleBox2 = '(135° available only in 6.35cm Wings)';
                isMetricWingbox1 = '1.905cm';
                isMetricWingbox2 = '2.8575cm';
                isMetricWingbox3 = '3.81cm';
                isMetricWingbox4 = '5.08cm';
                isMetricWingbox5 = '6.35cm';
            }  if((isMetricValue == 'False')||(isMetricValue == 'false')||(isMetricValue == null) || (String.isBlank(isMetricValue))){
                isMetric = false;
                isMetricExperssion = '(in.):';
                isMetricAngleBox1 = 'Available in 2-1/2" Wings with 90° Angle Only';
                isMetricAngleBox2 = '(135° available only in 2-1/2" Wings)';
               isMetricWingbox1 = '3/4"';
               isMetricWingbox2 = '1 1/8"';
               isMetricWingbox3 = '1 1/2"';
               isMetricWingbox4 = '2"';
               isMetricWingbox5 = '2 1/2"';
            }

             System.debug('isMetric Exp === >'+isMetric);
            if (String.isNotEmpty(quoteId)) {
                customForm = new CustomFormWrapper();
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
                if (quoteLines != null) {
                    customForm.quoteLines = new List<CustomQuoteLineItem>();
                    for (QuoteLineItem line : quoteLines) {
                        system.debug('Line == >'+line.Item_Number__c);
                        if (line != null && line.Item_Number__c != null && line.Item_Number__c.startsWith('POLY') && !line.Item_Number__c.endsWith('F')) {

                            CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                            if (line.Quantity != null) {
                                customLine.Quantity = (Integer)line.Quantity;
                            }
                            if (line.Length__c != null) {
                                customLine.Length = (Decimal)line.Length__c;
                            }
                             
                            if(line.Description != null){
                                if(line.Description.containsIgnoreCase('90 deg') ){
                                    customLine.Description90 = checked;  
                                }
                                if(line.Description.containsIgnoreCase('135 deg')){
                                    customLine.Description135 = checked;
                                } 
                                customLine.DescriptionLower = (String)line.Description.toLowerCase();
                                String[] parts = customLine.DescriptionLower.split('x');
                                String firstPart = parts[0].trim();
                                if(firstPart.contains('3/4"')){
                                    customLine.WingBox1 = checked;
                                }
                                if(firstPart.contains('1 1/8"')){ 
                                    customLine.WingBox2 = checked;
                                }
                                if(firstPart.contains('1 1/2"')){
                                    customLine.WingBox3 = checked;
                                }
                                if(firstPart.contains('2 1/2"')){
                                    customLine.WingBox5 = checked;
                                }
                                else if(firstPart.contains('2"')){
                                    customLine.WingBox4 = checked;
                                }

                            }
                            if(line.Description_2__c != null){
                                if(line.Description_2__c.containsIgnoreCase('90 deg') ){
                                    customLine.Description90 = checked;  
                                }
                                if(line.Description_2__c.containsIgnoreCase('135 deg')){
                                    customLine.Description135 = checked;
                                } 
                                customLine.DescriptionLower = (String)line.Description_2__c.toLowerCase();
                                String[] parts = customLine.DescriptionLower.split('x');
                                String firstPart = parts[0].trim();
                                if(firstPart.contains('3/4"')){
                                    customLine.WingBox1 = checked;
                                }
                                else if(firstPart.contains('1 1/8"')){ 
                                    customLine.WingBox2 = checked;
                                }
                                else if(firstPart.contains('1 1/2"')){
                                    customLine.WingBox3 = checked;
                                }
                                else if(firstPart.contains('2 1/2"')){
                                    customLine.WingBox5 = checked;
                                }
                                else if(firstPart.contains('2"')){
                                    customLine.WingBox4 = checked;
                                }
                            }
                            if(line.Item_Number__c != null){
                                if(line.Item_Number__c.containsIgnoreCase('BN') ){
                                    customLine.ItemNumberWithBN = checked;  
                                }else{
                                    customLine.ItemNumberWithoutBN = checked; 
                                }
                               
                            }
                            if(line.Mounting_Type__c != null){
                                if(line.Mounting_Type__c.containsIgnoreCase('Screws') || line.Mounting_Type__c.containsIgnoreCase('Nails')){
                                    customLine.MountingOpt1 = checked;
                                    customLine.MountingOpt2 = unchecked;  
                                    customLine.MountingOpt3 = unchecked;  
                                }
                                if(line.Mounting_Type__c.containsIgnoreCase('No Holes')){
                                    customLine.MountingOpt1 = unchecked;
                                    customLine.MountingOpt2 = checked;  
                                    customLine.MountingOpt3 = unchecked;  
                                } 
                                if(line.Mounting_Type__c.containsIgnoreCase('Tape')){
                                    customLine.MountingOpt1 = unchecked;
                                    customLine.MountingOpt2 = unchecked;  
                                    customLine.MountingOpt3 = checked;  
                                } 
                            }
                            
                            customForm.quoteLines.add(customLine);
                           
                        }
                    }
                     System.debug('Size Exp === >'+ customForm.quoteLines.size());
                }
                BlankForm = customForm.quoteLines.isEmpty();
            } else {
                BlankForm = true;
            }
             
        } catch (Exception e){ 
           System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            BlankForm = true;
        }
    }

    public IPC256Controller() {
        customForm = new CustomFormWrapper();
    }

    public class CustomFormWrapper {
        public Quote quoteRecord { get; set; }
        public List<CustomQuoteLineItem> quoteLines { get; set; }

        public CustomFormWrapper() {
            quoteRecord = new Quote();
            quoteLines = new List<CustomQuoteLineItem>();
        }
    }

    public class CustomQuoteLineItem {
        public Integer Quantity { get; set; }
        public Decimal Length { get; set; }
        public String Description90 { get; set; }
        public String Description135 { get; set; }
        public String MountingOpt1 { get; set; }
        public String MountingOpt2 { get; set; }
        public String MountingOpt3 { get; set; }
        public String ItemNumberWithBN { get; set; }
        public String ItemNumberWithoutBN { get; set; }
        public String DescriptionLower { get; set; }
        public String WingBox1 { get; set; }
        public String WingBox2 { get; set; }
        public String WingBox3 { get; set; }
        public String WingBox4 { get; set; }
        public String WingBox5 { get; set; }
       
    }
}