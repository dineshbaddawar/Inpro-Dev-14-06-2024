public with sharing class IPC070Controller {
    public CustomFormWrapper customForm {get;set;}
    private String checked = '333';
    private String unchecked = 'fff';

    public IPC070Controller() 
    {
        customForm = new CustomFormWrapper(); 
        String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
        if (String.isNotEmpty(quoteId)) 
        {
            customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
            List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
            if (quoteLineItems.size() > 0)
            {
                List<QuoteLineItem> filteredItems = FilterIPC070(quoteLineItems);
                if (filteredItems.size() > 0)
                {
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : filteredItems) 
                    {
                        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                        quoteLine.quoteLineItem = line;

                        quoteLine.colorName = line.Color__c.split('-')[0].trim();
                        String last4 = line.Color__c.right(4);
                        quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                        quoteLine.check_855V = line.Item_Number__c.startsWith('855') ? checked : unchecked;
                        quoteLine.check_A855V = line.Item_Number__c.startsWith('A855') ? checked : unchecked;
                        quoteLine.check_1255V = line.Item_Number__c.startsWith('1255') ? checked : unchecked;
                        quoteLine.check_A1255V = line.Item_Number__c.startsWith('A1255') ? checked : unchecked;
                        quoteLine.check_1455V = line.Item_Number__c.startsWith('1455') ? checked : unchecked;
                        quoteLine.check_1655V = line.Item_Number__c.startsWith('1655') ? checked : unchecked;
                        quoteLine.check_5055V = line.Item_Number__c.startsWith('5055') ? checked : unchecked;

                        lines.add(quoteLine);
                    }
                    customForm.quoteLines = lines;
                }
                else 
                {
                    customForm.quoteLines = ReturnBlankQuoteLine();
                }
            }
            else 
            {
                customForm.quoteLines = ReturnBlankQuoteLine();
            }
        }
        else 
        {
            customForm.quoteLines = ReturnBlankQuoteLine();
        }
        
        system.debug('customForm.quoteLines::'+customForm.quoteLines.size());
    }

    public List<QuoteLineWrapper> ReturnBlankQuoteLine()
    {
        QuoteLineItem blankLineItem = new QuoteLineItem(Description = ' ', Item_Number__c = ' ');
        QuoteLineWrapper blankWrapper = new QuoteLineWrapper();
        blankWrapper.quoteLineItem = blankLineItem;
        blankWrapper.check_855V = unchecked;
        blankWrapper.check_A855V = unchecked;
        blankWrapper.check_1255V = unchecked;
        blankWrapper.check_A1255V = unchecked;
        blankWrapper.check_1455V = unchecked;
        blankWrapper.check_1655V = unchecked;
        blankWrapper.check_5055V = unchecked;
        List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
        lines.add(blankWrapper);
        return lines;
    }

    public static List<QuoteLineItem> FilterIPC070(List<QuoteLineItem> quoteLines)
    {
        List<QuoteLineItem> filteredQuoteLines = new List<QuoteLineItem>();
        for (QuoteLineItem line : quoteLines) 
        {
            if(line.Item_Number__c.startsWith('A855') || 
            line.Item_Number__c.startsWith('855') ||
            line.Item_Number__c.startsWith('1255') ||
            line.Item_Number__c.startsWith('A1255') ||
            line.Item_Number__c.startsWith('1455') ||
            line.Item_Number__c.startsWith('5055') ||
            line.Item_Number__c.startsWith('1655'))
            {
                filteredQuoteLines.add(line);
            }
        }
        return filteredQuoteLines;
    }

    public class QuoteLineWrapper
    {
        public QuoteLineItem quoteLineItem {get;set;}
        public String colorName {get;set;}
        public String colorNumber {get;set;}
        public String check_855V {get;set;}
        public String check_A855V {get;set;}
        public String check_1255V {get;set;}
        public String check_A1255V {get;set;}
        public String check_1455V {get;set;}
        public String check_1655V {get;set;}
        public String check_5055V {get;set;}
    }

    public class CustomFormWrapper
    {
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}