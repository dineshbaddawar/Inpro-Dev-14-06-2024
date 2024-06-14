public with sharing class IPC076Controller {
    public CustomFormWrapper customForm {get;set;}
    private String checked = '333';
    private String unchecked = 'fff';

    public IPC076Controller() 
    { 
        customForm = new CustomFormWrapper(); 
        String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
        if (String.isNotEmpty(quoteId)) 
        {
            customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
            List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);
            if (quoteLineItems.size() > 0)
            {
                List<QuoteLineItem> filteredItems = FilterIPC076(quoteLineItems);
                if (filteredItems.size() > 0)
                {
                    List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
                    for (QuoteLineItem line : filteredItems) 
                    {
                        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
                        quoteLine.quoteLineItem = line;

                        quoteLine.materialThickness = line.Description.split(' ')[0].trim();
                        quoteLine.colorName = line.Color__c.split('-')[0].trim();
                        String last4 = line.Color__c.right(4);
                        quoteLine.colorNumber = last4.isNumeric() ? last4 : '';
                        quoteLine.peelStickAdhYes = HasAdhesive(line.Description) ? checked : unchecked;
                        quoteLine.peelStickAdhNo = HasNoAdhesive(line.Description) ? checked : unchecked;

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
    }

    public List<QuoteLineWrapper> ReturnBlankQuoteLine()
    {
        QuoteLineItem blankLineItem = new QuoteLineItem(Description = ' ');
        QuoteLineWrapper blankWrapper = new QuoteLineWrapper();
        blankWrapper.quoteLineItem = blankLineItem;
        blankWrapper.peelStickAdhYes = unchecked;
        blankWrapper.peelStickAdhNo = unchecked;
        List<QuoteLineWrapper> lines = new List<QuoteLineWrapper>();
        lines.add(blankWrapper);
        return lines;
    }

    public static List<QuoteLineItem> FilterIPC076(List<QuoteLineItem> quoteLines)
    {
        List<QuoteLineItem> filteredQuoteLines = new List<QuoteLineItem>();
        for (QuoteLineItem line : quoteLines) 
        {
            if(line.Item_Number__c.startsWith('DW-BEND'))
            {
                filteredQuoteLines.add(line);
            }
        }
        return filteredQuoteLines;
    }

    public static Boolean HasAdhesive(String description)
    {
        if (description.length() < 5) return false;
        List<String> AdhYes = new List<String>{'w/ adh', 'w/adh', 'w adh'};
        for (String entry : AdhYes)
        {
            if (description.toLowerCase().contains(entry)) return true;
        }
        return false;
    }

    public static Boolean HasNoAdhesive(String description)
    {
        if (description.length() < 5) return false;
        List<String> AdhNo = new List<String>{'w/o adh', 'w/oadh'};
        for (String entry : AdhNo)
        {
            if (description.toLowerCase().contains(entry)) return true;
        }
        return false;
    }

    public class QuoteLineWrapper
    {
        public QuoteLineItem quoteLineItem {get;set;}
        public String materialThickness {get;set;}
        public String colorName {get;set;}
        public String colorNumber {get;set;}
        public String peelStickAdhYes {get;set;}
        public String peelStickAdhNo {get;set;}
    }

    public class CustomFormWrapper
    {
        public Quote quoteRecord {get;set;}
        public List<QuoteLineWrapper> quoteLines {get;set;}
    }
}