public class IPC1225Controller {
    public CustomFormWrapper customForm {get;set;}
    public Boolean BlankForm {get;set;}
    public Boolean isMetric {get;set;}

    public IPC1225Controller() {
        try {
            Map<String, List<String>> partCategories = new Map<String, List<String>>{
                'HB' => System.Label.IPC1225PartNumber.split(';'),
                'HTCB' => System.Label.IPC1225PartNumberHorizontalTopCapBoard.split(';'),
                'VB' => System.Label.IPC1225PartNumberVerticalBoard.split(';'),
                'TSTC' => System.Label.IPC1225PartNumberTrimShoeTrimCap.split(';'),
                'ICPH' => System.Label.IPC1225PartNumberInsideCornerPartialHeight.split(';'),
                'OCPH' => System.Label.IPC1225PartNumberOutsideCornerPartialHeight.split(';'),
                'ICFH' => System.Label.IPC1225PartNumberInsideCornerFullHeight.split(';'),
                'OCFH' => System.Label.IPC1225PartNumberOutsidCornerFullHeight.split(';'),
                'DMVH' => System.Label.IPC1225PartNumberDecorativeMoldingVerticalHorizontal.split(';')
            };

            customForm = new CustomFormWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            String isMetricValue = Apexpages.currentPage().getParameters().get('isMetric');
            isMetric = (isMetricValue != null && (isMetricValue.toLowerCase() == 'true'));
            if (quoteId == null) {
                BlankForm = true;
            } else if (String.isNotEmpty(quoteId)) {
                initializeCustomFormMaps();
                Map<String, Map<String, List<QuoteLineWrapper>>> tempMaps = initializeTempMaps();

                customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
                List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quoteId);

                if (quoteLineItems.size() > 0) {
                    for (QuoteLineItem line : quoteLineItems) {
                        for (String category : partCategories.keySet()) {
                            for (String partStr : partCategories.get(category)) {
                                if (line.Item_Number__c != null && line.Item_Number__c.startsWithIgnoreCase(partStr)) {
                                    List<QuoteLineWrapper> newLines = tempMaps.get(category).get(partStr) != null ? tempMaps.get(category).get(partStr) : new List<QuoteLineWrapper>();
                                    QuoteLineWrapper quoteLine = createQuoteLineWrapper(line);
                                    newLines.add(quoteLine);
                                    tempMaps.get(category).put(partStr, newLines);
                                }
                            }
                        }
                    } 
                    assignTempMapsToCustomForm(tempMaps);
                    setBlankFlags();
                } else {
                    BlankForm = true;
                }
            }
        } catch (Exception e) {
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }        
    }

    public void initializeCustomFormMaps() {
        customForm.NewmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.HTCBmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.VBmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.TSTCmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.ICPHmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.OCPHmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.ICFHmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.OCFHmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
        customForm.DMVHmapOfPartNoQliWrapper = new Map<String, List<QuoteLineWrapper>>();
    }

    public Map<String, Map<String, List<QuoteLineWrapper>>> initializeTempMaps() {
        return new Map<String, Map<String, List<QuoteLineWrapper>>>{
            'HB' => new Map<String, List<QuoteLineWrapper>>(),
            'HTCB' => new Map<String, List<QuoteLineWrapper>>(),
            'VB' => new Map<String, List<QuoteLineWrapper>>(),
            'TSTC' => new Map<String, List<QuoteLineWrapper>>(),
            'ICPH' => new Map<String, List<QuoteLineWrapper>>(),
            'OCPH' => new Map<String, List<QuoteLineWrapper>>(),
            'ICFH' => new Map<String, List<QuoteLineWrapper>>(),
            'OCFH' => new Map<String, List<QuoteLineWrapper>>(),
            'DMVH' => new Map<String, List<QuoteLineWrapper>>()
        };
    }

    public QuoteLineWrapper createQuoteLineWrapper(QuoteLineItem line) {
        QuoteLineWrapper quoteLine = new QuoteLineWrapper();
        if (line.Color__c != null) {
            quoteLine.colorName = line.Color__c;
        }
        if (line.Quantity != null) {
            quoteLine.QuantyValue = line.Quantity;
        }
        if (line.Custom_Angle__c != null) {
            quoteLine.CustomAngleValue = line.Custom_Angle__c;
        }
        if (line.Material_Allocation_Note__c != null) {
            quoteLine.MaterialValue = line.Material_Allocation_Note__c;
        }
        return quoteLine;
    }

    public void assignTempMapsToCustomForm(Map<String, Map<String, List<QuoteLineWrapper>>> tempMaps) {
        customForm.NewmapOfPartNoQliWrapper = tempMaps.get('HB');
        customForm.HTCBmapOfPartNoQliWrapper = tempMaps.get('HTCB');
        customForm.VBmapOfPartNoQliWrapper = tempMaps.get('VB');
        customForm.TSTCmapOfPartNoQliWrapper = tempMaps.get('TSTC');
        customForm.ICPHmapOfPartNoQliWrapper = tempMaps.get('ICPH');
        customForm.OCPHmapOfPartNoQliWrapper = tempMaps.get('OCPH');
        customForm.ICFHmapOfPartNoQliWrapper = tempMaps.get('ICFH');
        customForm.OCFHmapOfPartNoQliWrapper = tempMaps.get('OCFH');
        customForm.DMVHmapOfPartNoQliWrapper = tempMaps.get('DMVH');
    }

    public void setBlankFlags() {
        customForm.isShowBlankHorizontalBoard = (customForm.NewmapOfPartNoQliWrapper == null || customForm.NewmapOfPartNoQliWrapper.size() == 0);
        customForm.isShowBlankHorizontalTopCapBoard = (customForm.HTCBmapOfPartNoQliWrapper == null || customForm.HTCBmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankVerticalBoard = (customForm.VBmapOfPartNoQliWrapper == null || customForm.VBmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankTrimShoeandTrimCap = (customForm.TSTCmapOfPartNoQliWrapper == null || customForm.TSTCmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankInsideCornerPartialHeight = (customForm.ICPHmapOfPartNoQliWrapper == null || customForm.ICPHmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankOutsideCornerPartialHeight = (customForm.OCPHmapOfPartNoQliWrapper == null || customForm.OCPHmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankInsideCornerFullHeight = (customForm.ICFHmapOfPartNoQliWrapper == null || customForm.ICFHmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankOutsidCornerFullHeight = (customForm.OCFHmapOfPartNoQliWrapper == null || customForm.OCFHmapOfPartNoQliWrapper.isEmpty());
        customForm.isShowBlankDecorativeMoldingVerticalandHorizontal = (customForm.DMVHmapOfPartNoQliWrapper == null || customForm.DMVHmapOfPartNoQliWrapper.isEmpty());
    }

    public class QuoteLineWrapper {
        public String colorName {get;set;}
        public Decimal QuantyValue {get;set;}
        public String CustomAngleValue {get;set;}
        public String MaterialValue {get;set;}
    }

    public class CustomFormWrapper {
        public Quote quoteRecord {get;set;}
        public Map<String, List<QuoteLineWrapper>> NewmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> HTCBmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> VBmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> TSTCmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> ICPHmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> OCPHmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> ICFHmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> OCFHmapOfPartNoQliWrapper {get;set;}
        public Map<String, List<QuoteLineWrapper>> DMVHmapOfPartNoQliWrapper {get;set;}
        public Boolean isShowBlankHorizontalBoard {get;set;}
        public Boolean isShowBlankHorizontalTopCapBoard {get;set;}
        public Boolean isShowBlankVerticalBoard {get;set;}
        public Boolean isShowBlankTrimShoeandTrimCap {get;set;}
        public Boolean isShowBlankInsideCornerPartialHeight {get;set;}
        public Boolean isShowBlankOutsideCornerPartialHeight {get;set;}
        public Boolean isShowBlankInsideCornerFullHeight {get;set;}
        public Boolean isShowBlankOutsidCornerFullHeight {get;set;}
        public Boolean isShowBlankDecorativeMoldingVerticalandHorizontal {get;set;}
    }
}