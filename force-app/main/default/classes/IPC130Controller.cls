public with sharing class IPC130Controller {
    public CustomFormWrapper customForm { get; set; }
    public Boolean BlankForm { get; set; }

    public IPC130Controller(ApexPages.StandardController controller) {
        customForm = new CustomFormWrapper();
        customForm.quoteLines = new List<CustomQuoteLineItem>();
        String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        if (quoteId == null) {
            BlankForm = true;   
        } else if (String.isNotEmpty(quoteId)) {
            customForm.quoteRecord = CustomFormHelper.GetQuoteData(quoteId);
            List<QuoteLineItem> quoteLines = CustomFormHelper.GetQuoteLineData(quoteId);
            if (quoteLines != null && quoteLines.size() > 0) {
                List<CustomQuoteLineItem> lines = new List<CustomQuoteLineItem>();
                for (QuoteLineItem line : quoteLines) {
                    if (line.Document_Name__c != null && line.Document_Name__c.startsWithIgnoreCase('IPC.130')) {
                        CustomQuoteLineItem customLine = new CustomQuoteLineItem();
                        if (!String.isBlank(line.Color__c)) {
                            customLine.Color = line.Color__c;
                            customLine.colorName = line.Color__c.split('-')[0].trim();
                            String last4 = line.Color__c.right(4);
                            customLine.colorNumber = last4.isNumeric() ? last4 : null;
                        }
                        if (line.Quantity != null) {
                            customLine.Quantity = (Decimal) line.Quantity;
                        }
                        if (line.Width__c != null) {
                            customLine.Width = line.Width__c;
                        }
                        if (line.Height__c != null) {
                            customLine.Height = line.Height__c;
                        }
                        if (line.Operator__c != null) {
                            customLine.Operator = line.Operator__c;
                        }
                        if (line.Document_Name__c != null) {
                            customLine.DocumentName = line.Document_Name__c;
                        }
                        if (line.Vendor__c != null) {
                            customLine.vendor = line.Vendor__c;
                        }
                        if (line.Pattern__c != null) {
                            customLine.Pattern = line.Pattern__c;
                        }
                        if (line.Room_Location__c != null) {
                            customLine.RoomLocation = line.Room_Location__c;
                        }
                        if (line.Mounting_Type__c != null) {
                            customLine.MountingType = line.Mounting_Type__c;
                        }
                        if (line.Fabric_Width__c != null) {
                            customLine.FabricWidth = line.Fabric_Width__c;
                        }
                        if (line.Fabric_Vertical_Repeat__c != null) {
                            customLine.FabricVerticalRepeat = line.Fabric_Vertical_Repeat__c;
                        }
                        if (line.Sewing_Type__c != null) {
                            customLine.SewingType = line.Sewing_Type__c;
                        }
                        if (line.Fullness__c != null) {
                            customLine.Fullness = line.Fullness__c;
                        }
                        if (line.Ripple_Fold_Tape_Clear__c != null) {
                            customLine.RippleFoldTapeClear = line.Color_7__c;
                        }
                        if (line.Draw_Type__c != null) {
                            customLine.DrawType = line.Draw_Type__c;
                        }
                        if (line.Master_Carrier__c != null) {
                            customLine.MasterCarrier = line.Master_Carrier__c;
                        }
                        if (line.Return__c != null) {
                            customLine.returnSize = line.Return__c;
                        }
                        if (line.Lining__c != null) {
                            customLine.Lining = line.Lining__c;
                        }
                        if (line.Weights__c != null) {
                            customLine.Weights = line.Weights__c;
                        }
                        if (line.Rod_Part_Number__c != null) {
                            customLine.RodPartNumber = line.Rod_Part_Number__c;
                        }
                        lines.add(customLine);
                    }
                }
                customForm.quoteLines = lines;
                BlankForm = customForm.quoteLines.size() > 0 ? false : true;
            } else {
                BlankForm = true;
            }
        }
    }
    public class CustomFormWrapper {
        public Quote quoteRecord { get; set; }
        public List<CustomQuoteLineItem> quoteLines { get; set; }
    }
    public class CustomQuoteLineItem {
        public Decimal Quantity { get; set; }
        public Decimal Width { get; set; }
        public Decimal Height { get; set; }
        public String Operator { get; set; }
        public String DocumentName { get; set; }
        public String vendor { get; set; }
        public String Pattern { get; set; }
        public String Color { get; set; }
        public String colorName { get; set; }
        public String colorNumber { get; set; }
        public String RoomLocation { get; set; }
        public String MountingType { get; set; }
        public Decimal FabricWidth { get; set; }
        public Decimal FabricVerticalRepeat { get; set; }
        public String SewingType { get; set; }
        public String Fullness { get; set; }
        public String RippleFoldTapeClear { get; set; }
        public String DrawType { get; set; }
        public String MasterCarrier { get; set; }
        public Decimal returnSize { get; set; }
        public String Lining { get; set; }
        public String Weights { get; set; }
        public String RodPartNumber { get; set; }
    }
}