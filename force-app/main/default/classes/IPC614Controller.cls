public with sharing class IPC614Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm { get; set; }
    public IPC614Controller(ApexPages.StandardController controller){
        try{
            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            if (quoteId == null) {
                BlankForm = true;
            } 
            else if (String.isNotEmpty(quoteId) || quoteId !=null) {
                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
                List<QuoteLineItem> filterQLI = new List<QuoteLineItem>();
                if (quoteLineItems.size() > 0) {
                    for (QuoteLineItem line : quoteLineItems) {
                        if(line.Item_Number__c != null && line.Item_Number__c.startsWithIgnoreCase('PWP-PNLVL')){
                            if(line.description !=null){
                                String lowerDesc = line.description.toLowerCase();
                                if (lowerDesc.contains('vert grain')) {
                                    line.description = 'Vertical';
                                } else if (lowerDesc.contains('hor grain')) {
                                    line.description = 'Horizontal';
                                } else {
                                    line.description = '';
                                }
                            }
                            filterQLI.add(line);
                        }
                    }
                    if(filterQLI.size()>0){
                        customForm.quoteLines = filterQLI;
                        BlankForm = false;
                    }else{
                        BlankForm = true;
                    }
                }else{
                    BlankForm = true;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    public class CustomFormWrapper{
        public Quote quoteRecord {get;set;}
        public List<QuoteLineItem> quoteLines {get;set;}
    }
}