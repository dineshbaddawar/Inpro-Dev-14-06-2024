public with sharing class IPC089Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }
    public Boolean isMetric { get; set; }
    public IPC089Controller(ApexPages.StandardController controller){
        try {
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
            if (String.isNotEmpty(quoteId) && quoteId != null) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List < QuoteLineItem > filter089QLIList = new List<QuoteLineItem>();
                if (CustomFormHelper.GetQuoteLineData(quoteId).size() > 0) {
                    for (QuoteLineItem line : CustomFormHelper.GetQuoteLineData(quoteId)) {
                        if (line.Document_Name__c != null) {
                            if (line.Document_Name__c.startsWithIgnoreCase('IPC.089')) {
                                filter089QLIList.add(line);
                            }
                        }
                    }
                    if (filter089QLIList.size() > 0) {
                        customForm.quoteLines = filter089QLIList;
                    }
                }
            }
            if (quoteId == null) {
                BlankForm = true;
            } else {
                BlankForm = false;
            }
        } catch (Exception e) {
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
    }
    
    public class CustomFormWrapper {
        public Quote quoteRecord { get; set; }
        public List < QuoteLineItem > quoteLines { get; set; }
    }
}