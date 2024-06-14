public class QuoteBidPDFController {
    public QuoteBidWrapper quoteDetails {get;set;}
    public CurrencyType_History__c currencyTypeHistory {get;set;}
    public boolean IsCAD {get;set;}

    public QuoteBidPDFController(){
        try
        {
            quoteDetails = new QuoteBidWrapper(); 
            String quoteId = Apexpages.currentPage().getParameters().get('quoteId');
            Id printQuoteId = Id.valueOf(Apexpages.currentPage().getParameters().get('printQuoteId'));
            String alternatesStr = Apexpages.currentPage().getParameters().get('alternates');
            List<String> alternateList = alternatesStr.split(',');
            
            DescribeSObjectResult describeResult = printQuoteId.getSObjectType().getDescribe();
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );

            quoteDetails.printQuote = Database.query('SELECT ' + String.join(fieldNames,',') +
                ' FROM Print_Quote__c WHERE Id = \'' + printQuoteId + '\'');
                
            string fileName = quoteDetails.printQuote.Project__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
            
            try{
                currencyTypeHistory = [SELECT ConversionRate__c 
                                FROM CurrencyType_History__c 
                                WHERE IsActive__c = true AND CurrencyIsoCode = 'CAD' 
                                LIMIT 1];
            }catch(Exception ex)
            {
                //ignore
            }
            

            IsCAD = quoteDetails.printQuote.Currency_Code__c == 'CAD';

            quoteDetails.hideQtyColumnWidth = 
                quoteDetails.printQuote.Form_Type__c == 'Quote_w_Lump_Sum_Pricing' && quoteDetails.printQuote.Is_Hiding_Qty__c ? '2' : '3';

            quoteDetails.quoteRecord = [SELECT Id, Name, PO_Number__c,Division__c,ContactId,Contact.Name, Contact.LastName,Contact.Phone,Contact.Email,Contact.fax,
                                            QuoteNumber,Revision_Number__c, OpportunityId, LineItemCount, Subtotal, TotalPrice, 
                                            ShippingStreet,Status, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, 
                                            ShippingCountryCode, QuoteToStreet, QuoteToCity, QuoteToState, ShippingAddress, QuoteToPostalCode, QuoteToCountry,
                                            QuoteToStateCode, QuoteToCountryCode, BidQuote__c, Inpro_Document_Number__c,Account.Customer_Number__c,
                                            Account.Payment_Terms__c,Primary_Bidder__r.Customer_Number__c, Primary_Bidder__c,
                                            Primary_Bidder__r.Name,Primary_Bidder__r.Phone,Primary_Bidder__r.Fax,Primary_Bidder__r.Payment_Terms__c,
                                            Primary_Bidder__r.BillingStreet, Primary_Bidder__r.BillingCity,Project__c,
                                            Primary_Bidder__r.BillingState, Primary_Bidder__r.BillingPostalCode, Primary_Bidder__r.BillingCountry, 
                                            Primary_Bidder__r.BillingStateCode, Primary_Bidder__r.BillingCountryCode,Type__c,GrandTotal,
                                            CurrencyIsoCode, Introduction__c,Qualifications__c, Ending__c, Primary_Bidder__r.ParentId,
                                            Quote_Estimating_Notes__c 
                                        FROM Quote 
                                        WHERE Id = :quoteId];

            quoteDetails.isSignScape = quoteDetails.quoteRecord.Division__c == 'SignScape';
            quoteDetails.isAscend =  quoteDetails.quoteRecord.Division__c == 'Ascend';

            quoteDetails.qualifications = [SELECT Id, Name, Quote__c, Sequence__c, Description__c 
                                        FROM Qualification__c
                                        WHERE Quote__c =: Id.valueOf(quoteId) AND Qualification_Type__c <> 'Estimating' 
                                        ORDER BY Sequence__c ASC];
            quoteDetails.estimatingQualifications = [SELECT Id, Name, Quote__c, Sequence__c, Description__c 
                                                    FROM Qualification__c
                                                    WHERE Quote__c =: Id.valueOf(quoteId) AND Qualification_Type__c =: 'Estimating' 
                                                    ORDER BY Sequence__c ASC];

            quoteDetails.opportunityRecord= [SELECT Id, Project_Number__c, Owner.Name,Owner.Email, Spec_Status__c 
                                            FROM Opportunity 
                                            WHERE Id =:quoteDetails.quoteRecord.OpportunityId];

            List<Regional_Tax__c> tax =  [SELECT Id, Total_Tax_Rate__c, Country__c, State__c, Tax_Type__c
                                    FROM Regional_Tax__c
                                    WHERE Country__c = :quoteDetails.quoteRecord.ShippingCountry
                                    AND State__c = :quoteDetails.quoteRecord.ShippingState];
            
            if (tax != null && tax.size() > 0)
            {
                quoteDetails.taxType  = tax.get(0).Tax_Type__c;
            }

            quoteDetails.alternatesMap = new Map<string,QuoteLineItemWrapper>();

            List<Alternate__c> alternates = [SELECT Id, Name__c, Freight_Amount__c FROM Alternate__c WHERE Id IN :alternateList];

            for( QuoteLineItem Item:[SELECT Id, LineNumber,Quote_Note__c, Note__c,Alternate__r.Freight_Amount__c,Product2.Name,
                                            Product2.ProductCode,QuoteId,product2.Description, Quantity, UnitPrice, Discount, Description, 
                                            Subtotal, TotalPrice, Product_Description__c,Alternate__c,Alternate__r.Total_Material__c, 
                                            Alternate__r.Freight_Tax__c, Alternate__r.Total_incl_Freight_No_Tax__c,Alternate__r.Total_incl_Freight_Tax__c, 
                                            Alternate_Name__c, Alternate_Number__c, Color__c,Color_2__c,Color_3__c,Color_4__c,Color_5__c,
                                            Color_6__c,Color_7__c,Unit_of_Measure__c,Alternate__r.Product_Tax__c,
                                            Alternate__r.Name__c,Alternate__r.Freight_Carrier__c, Alternate__r.Freight_Carrier__r.Name,Alternate__r.Tax_Percent__c,
                                            Alternate__r.Total_incl_Shipping_Tax__c,Alternate__r.Total_Cost__c,Price_Per_Unit__c,
                                            Alternate__r.Show_Unit_Pricing__c,Metric_Description_1__c,Description_2__c,Custom_Part_Number__c, 
                                            Alternate__r.Manual_Shipping_Description__c, Alternate__r.Freight_Group_Name__c,
                                            Alternate__r.Lift_Gate__c, Alternate__r.Lift_Gate_Charge__c, Alternate__r.Driver_Wait__c, Alternate__r.Driver_Wait_Charge__c,
                                            Alternate__r.Inside_Delivery__c, Alternate__r.Inside_Delivery_Charge__c, Alternate__r.Loading_Dock__c,
                                            Alternate__r.Group_Sequence_Number__c, Alternate__r.Sequence_Number__c, Alternate__r.Total_Weight__c,
                                            Alternate__r.Loading_Dock_Charge__c, Alternate__r.Service_Call__c, Alternate__r.Service_Call_Charge__c, Item_Number__c
                                    FROM QuoteLineItem 
                                    WHERE Product2.Name != 'output' AND is_Parent__c = true 
                                    AND QuoteId =:Id.valueOf(quoteId) AND Alternate__c IN: alternatelist 
                                    ORDER BY Alternate__r.Sequence_Number__c ASC, Sequence_Number__c ASC])
            {           
                if(Item.Quote_Note__c != null) Item.Quote_Note__c ='Notes: ' + Item.Quote_Note__c;
                if(Item.Note__c != null) Item.Note__c ='Notes: ' + Item.Note__c;
                if(quoteDetails.alternatesMap.containsKey(Item.Alternate__c))
                {
                    QuoteLineItemWrapper existingAlternate = new QuoteLineItemWrapper();
                    existingAlternate = quoteDetails.alternatesMap.get(Item.Alternate__c);
                    existingAlternate.totalWeight = Item.Alternate__r.Total_Weight__c;
                    //Double check to make sure to get freight from the one same-name alt that has it
                    if (Item.Alternate__r.Freight_Carrier__c != null) 
                    {
                        existingAlternate.freightCarrier =  MapFreightName(Item.Alternate__r);


                    }
                    if(Item.Alternate__r.Freight_Group_Name__c != null)
                    {
                        existingAlternate.groupName = Item.Alternate__r.Freight_Group_Name__c;
                        quoteDetails.printQuote.Has_Freight_Groups__c = true;
                    }
                    else 
                    {
                        existingAlternate.groupName = '';
                    }

                    existingAlternate.quoteItems.add(CreateQuoteLineItemMock(Item));

                    
                    
                    quoteDetails.alternatesMap.put(item.Alternate__c,existingAlternate);
                }
                else
                {
                    QuoteLineItemWrapper newAlternate = CreateQuoteLineItemWrapper(Item);
                    newAlternate.totalWeight = Item.Alternate__r.Total_Weight__c;
                    newAlternate.quoteItems.add(CreateQuoteLineItemMock(Item));
                    
                    quoteDetails.alternatesMap.put(item.Alternate__c,newAlternate);
                }
            }

            //SAME NAME LOGIC
            RemapSameNameAlternates();
            //END SAME NAME LOGIC

            quoteDetails.groupMap = new List<FreightGroupWrapper>();

            for(QuoteLineItemWrapper alt : quoteDetails.alternatesMap.values())
            {
                Boolean foundWrapper = false;
                for (FreightGroupWrapper wrapper : quoteDetails.groupMap)
                {
                    if (wrapper.groupName == alt.groupName && wrapper.groupName != null && wrapper.groupName != '')
                    {
                        foundWrapper = true;
                        FreightGroupWrapper existingGroup = wrapper;
                        if(alt.freightCarrier != null)
                            existingGroup.freightCarrier = alt.freightCarrier;
                        if(alt.totalInclTax != null)
                            existingGroup.totalInclTax += alt.totalInclTax;
                        if(alt.alternateTotal != null)
                            existingGroup.groupTotal += alt.alternateTotal;
                        if(alt.subTotal != null)
                            existingGroup.subTotal += alt.subTotal;
                        if(alt.alternateTotalwTax != null)
                            existingGroup.groupTotalwTax += alt.alternateTotalwTax;
                        if(alt.freightAmount != null)
                            existingGroup.freightAmount += alt.freightAmount;
                        if(alt.freightTax != null)
                            existingGroup.freightTax += alt.freightTax;
                        if(alt.productTax != null)
                            existingGroup.productTax += alt.productTax;
                        if (alt.totalWeight != null)
                            existingGroup.totalWeight += alt.totalWeight;
                        existingGroup.groupName = alt.groupName;
                        existingGroup.alternates.add(alt);
                        break;
                        //quoteDetails.groupMap.put(alt.groupName,existingGroup);
                    }
                }
                if (!foundWrapper)
                {
                    FreightGroupWrapper newGroup = new FreightGroupWrapper();
                    newGroup.sequenceNumber = alt.groupSequenceNumber;
                    newGroup.freightCarrier = alt.freightCarrier;
                    newGroup.taxPercent = alt.taxPercent;
                    newGroup.totalInclTax = alt.totalInclTax;
                    newGroup.groupTotal = alt.alternateTotal;
                    newGroup.subTotal = alt.subTotal;
                    newGroup.groupTotalwTax = alt.alternateTotalwTax;
                    newGroup.freightAmount = alt.freightAmount;
                    newGroup.freightTax = alt.freightTax;
                    newGroup.productTax = alt.productTax;
                    newGroup.totalWeight = alt.totalWeight;
                    newGroup.showUnitPricing = alt.showUnitPricing;
                    newGroup.ManualShippingDescription = alt.ManualShippingDescription;
                    newGroup.isGroup =  alt.groupName != null && alt.groupName != '';
                    newGroup.otherName = alt.alternateName;
                    newGroup.groupName = alt.groupName;
                    newGroup.alternates = new List<QuoteLineItemWrapper>();
                    newGroup.alternates.add(alt);
                    newGroup.alternates.sort();

                    quoteDetails.groupMap.add(newGroup);
                }
            }

            quoteDetails.groupMap.sort();


            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName + '.pdf');

            quoteDetails.printingUser = [Select Id ,Alias from User where Id=:UserInfo.getUserId()].Alias;
        }
        catch(Exception ex)
        {
            throw new OtherException(ex.getMessage() + ex.getStackTraceString());
        }
    }

    private String MapFreightName(Alternate__c alternate)
    {
        String name = alternate.Freight_Carrier__c == null ? '(TBD)' : alternate.Freight_Carrier__r.Name;

        if (alternate.Lift_Gate__c)
        {
            name += ' with Lift Gate';
        }
        
        if (alternate.Driver_Wait__c)
        {
            name += ' with Driver Wait';
        } 
        if (alternate.Inside_Delivery__c)
        {
            name += ' with Inside Delivery';
        } 
        if (alternate.Loading_Dock__c)
        {
            name += ' with Loading Dock';
        } 
        if (alternate.Service_Call__c)
        {
            name += ' with Service Call';
        } 

        return name;
    }

    public class AlternateGroupDTO
    {
        public Integer freightCount {get;set;}
        public List<QuoteLineItemWrapper> alternates {get;set;}
    }

    private void RemapSameNameAlternates()
    {
        Map<string, AlternateGroupDTO> altFreightMap = new Map<string, AlternateGroupDTO>();

        for(QuoteLineItemWrapper alt : quoteDetails.alternatesMap.values())
        {
            if (!altFreightMap.containsKey(alt.alternateName))
            {
                AlternateGroupDTO dto = new AlternateGroupDTO();
                dto.alternates = new List<QuoteLineItemWrapper>{ alt};
                dto.freightCount = alt.freightAmount > 0 ? 1 : 0;
                altFreightMap.put(alt.alternateName == null ? '' : alt.alternateName, dto);
            }
            else
            {
                AlternateGroupDTO dto = altFreightMap.get(alt.alternateName);
                dto.alternates.add(alt);
                dto.freightCount = alt.freightAmount > 0 ? dto.freightCount + 1 : dto.freightCount;
                altFreightMap.put(alt.alternateName == null ? '' : alt.alternateName, dto);
            }
        }

        EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'Test', JSON.serialize(altFreightMap));
        Map<string,QuoteLineItemWrapper> newAlternateMap = new Map<string,QuoteLineItemWrapper>();

        for(AlternateGroupDTO dto : altFreightMap.values())
        {
            if (dto.freightCount <= 1)
            {
                QuoteLineItemWrapper newAlternate;
                for(QuoteLineItemWrapper alt : dto.alternates)
                {
                    if (newAlternate == null)
                    {
                        newAlternate = alt;
                    }
                    else
                    {
                        newAlternate.alternateTotal += alt.alternateTotal;
                        newAlternate.alternateTotalwTax += alt.alternateTotalwTax;
                        newAlternate.productTax += alt.productTax;
                        newAlternate.freightAmount += alt.freightAmount;
                        newAlternate.totalWeight += alt.totalWeight;
                        newAlternate.subTotal += alt.subTotal;
                        newAlternate.freightCarrier = alt.freightCarrier != '' && alt.freightCarrier != '(TBD)' ? alt.freightCarrier : newAlternate.freightCarrier;
                        newAlternate.freightTax += alt.freightTax;
                        newAlternate.quoteItems.addAll(alt.quoteItems);
                    }
                }

                newAlternateMap.put(newAlternate.alternateName, newAlternate);
            }
            else
            {
                Integer spaces = 0;
                for(QuoteLineItemWrapper alt : dto.alternates)
                {
                    alt.alternateName = GenerateMockName(spaces++, alt.alternateName);
                    newAlternateMap.put(alt.alternateName, alt);
                }
            }
        }

        quoteDetails.alternatesMap = newAlternateMap;

        quoteDetails.AddsTotal = 0;
        quoteDetails.DeductsTotal = 0;
        for(QuoteLineItemWrapper alt : quoteDetails.alternatesMap.values())
        {
            if (alt != null)
            {
                if (quoteDetails.printQuote.Is_Taxable__c)
                {
                    if (alt.alternateTotal > 0) quoteDetails.AddsTotal += alt.alternateTotalwTax;
                    else quoteDetails.DeductsTotal += alt.alternateTotalwTax;
                }
                else
                {
                    if (alt.alternateTotal > 0) quoteDetails.AddsTotal += alt.alternateTotal;
                    else quoteDetails.DeductsTotal += alt.alternateTotal;
                }
            }
        }
    }

    private String GenerateMockName(Integer length, string Name)
    {
        Integer index = 0;
        while (index < length + 1)
        {
            Name += ' ';
            index ++;
        }

        return Name;
    }

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    private QuoteLineItemMock CreateQuoteLineItemMock(QuoteLineItem Item)
    {
        QuoteLineItemMock mock = new QuoteLineItemMock();
        mock.CustomPartNumber = Item.Custom_Part_Number__c;
        mock.ItemNumber = Item.Item_Number__c;
        mock.Description = Item.Description;
        mock.Description2 = Item.Description_2__c;
        mock.Note = Item.Note__c;
        mock.Color = Item.Color__c;
        mock.Color2 = Item.Color_2__c;
        mock.Color3 = Item.Color_3__c;
        mock.Color4 = Item.Color_4__c;
        mock.Color5 = Item.Color_5__c;
        mock.Color6 = Item.Color_6__c;
        mock.Color7 = Item.Color_7__c;
        mock.UnitofMeasure = Item.Unit_of_Measure__c;
        mock.UnitPrice = Item.UnitPrice;
        mock.Quantity = Item.Quantity;
        mock.TotalPrice = Item.TotalPrice;
        
        if (IsCAD && currencyTypeHistory != null) //INPRO CANADA
        {
            mock.UnitPrice *= currencyTypeHistory.ConversionRate__c;
            mock.TotalPrice = mock.UnitPrice * mock.Quantity;
        }

        return mock;
    }

    private QuoteLineItemWrapper CreateQuoteLineItemWrapper(QuoteLineItem Item)
    {
        QuoteLineItemWrapper newAlternate = new QuoteLineItemWrapper();
        newAlternate.quoteItems = new List<QuoteLineItemMock>();

        if (Item.Alternate__r.Freight_Carrier__c != null)
        {
            newAlternate.freightCarrier = Item.Alternate__r.Freight_Carrier__r.Name;
        }
        else
        {
            newAlternate.freightCarrier = '(TBD)';
        }

        
        newAlternate.taxPercent = Item.Alternate__r.Tax_Percent__c == null ? 0: Item.Alternate__r.Tax_Percent__c ;
        newAlternate.totalInclTax = Item.Alternate__r.Total_incl_Shipping_Tax__c;
        newAlternate.totalWeight = Item.Alternate__r.Total_Weight__c;
        newAlternate.alternateTotal = Item.Alternate__r.Total_incl_Freight_No_Tax__c;
        newAlternate.subTotal = Item.Alternate__r.Total_Material__c;
        newAlternate.alternateTotalwTax = (Item.Alternate__r.Total_incl_Freight_Tax__c == null ? 0 : Item.Alternate__r.Total_incl_Freight_Tax__c);
        newAlternate.freightAmount = Item.Alternate__r.Freight_Amount__c == null ? 0 : item.Alternate__r.Freight_Amount__c ;
        newAlternate.freightTax = Item.Alternate__r.Freight_Tax__c == null? 0:Item.Alternate__r.Freight_Tax__c;
        newAlternate.productTax = Item.Alternate__r.Product_Tax__c == null? 0:Item.Alternate__r.Product_Tax__c;
        

        if (IsCAD && currencyTypeHistory != null) //INPRO CANADA
        {
            newAlternate.alternateTotal *= currencyTypeHistory.ConversionRate__c;
            newAlternate.subTotal *= currencyTypeHistory.ConversionRate__c;
            newAlternate.freightAmount *= currencyTypeHistory.ConversionRate__c;
            newAlternate.freightTax *= currencyTypeHistory.ConversionRate__c;
            newAlternate.productTax *= currencyTypeHistory.ConversionRate__c;
            newAlternate.alternateTotalwTax *= currencyTypeHistory.ConversionRate__c;
        }

        newAlternate.freightCarrier = MapFreightName(Item.Alternate__r);
        
        newAlternate.showUnitPricing = Item.Alternate__r.Show_Unit_Pricing__c;
        newAlternate.ManualShippingDescription = Item.Alternate__r.Manual_Shipping_Description__c;
        newAlternate.groupSequenceNumber = Integer.valueOf(Item.Alternate__r.Group_Sequence_Number__c);
        newAlternate.sequenceNumber = Integer.valueOf(Item.Alternate__r.Sequence_Number__c);
        if(Item.Alternate__r.Freight_Group_Name__c != null)
        {
            newAlternate.groupName = Item.Alternate__r.Freight_Group_Name__c;
            quoteDetails.printQuote.Has_Freight_Groups__c = true;
        }
        else 
        {
            newAlternate.groupName = ''; 
        }

        newAlternate.alternateName = Item.Alternate__r.Name__c;
        newAlternate.alternateId = Item.Alternate__c;

        return newAlternate;
    }

    public class QuoteBidWrapper{
        public List<FreightGroupWrapper> groupMap {get;set;}
        public Map<string,QuoteLineItemWrapper> alternatesMap {get;set;}

        public Print_Quote__c printQuote {get;set;}
        public string hideQtyColumnWidth {get;set;}

        public Opportunity opportunityRecord {get;set;}
        public Quote quoteRecord {get;set;}
        public List<Qualification__c> qualifications {get;set;}
        public List<Qualification__c> estimatingQualifications {get;set;}
        public string printingUser {get;set;}
        public string taxType {get;set;}
        public Decimal AddsTotal {get;set;}
        public Decimal DeductsTotal {get;set;}
        public Boolean isSignScape {get;set;}
        public Boolean isAscend {get;set;}
    }
    
    public class QuoteLineItemWrapper implements Comparable{
        
        public List<QuoteLineItemMock> quoteItems {set;get;}
        public string shipping{get;set;}
        public string freightCarrier{get;set;}
        public string shippingIncluded {get;set;}
        public Decimal taxPercent {get;set;}
        public Decimal alternateTotal {get;set;}
        public decimal alternateTotalwTax {get;set;}
        public Decimal totalWeight {get;set;}
        public Decimal totalInclTax {get;set;}
        public decimal freightAmount {get;set;}
        public decimal subTotal {get;set;}
        public decimal freightTax {get;set;}
        public decimal productTax{get;set;}
        public boolean showUnitPricing{get;set;}
        public string ManualShippingDescription {get;set;}
        public string groupName {get;set;}
        public Integer groupSequenceNumber {get;set;}
        public Integer sequenceNumber {get;set;}
        public string alternateName {get;set;}
        public string alternateId {get;set;}

        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            FreightGroupWrapper other = (FreightGroupWrapper)compareTo;
    
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.sequenceNumber> other.sequenceNumber) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.sequenceNumber < other.sequenceNumber) {
                // Set return value to a negative value.
                returnValue = -1;
            }
    
            return returnValue;       
        }
    }
    
    public class QuoteLineItemMock{
        public string CustomPartNumber {get;set;}
        public string ItemNumber {get;set;}
        public string Description {get;set;}
        public string Description2 {get;set;}
        public string Note {get;set;}
        public string Color {get;set;}
        public string Color2 {get;set;}
        public string Color3 {get;set;}
        public string Color4 {get;set;}
        public string Color5 {get;set;}
        public string Color6 {get;set;}
        public string Color7{get;set;}
        public string UnitOfMeasure {get;set;}
        public Decimal UnitPrice {get;set;}
        public Decimal TotalPrice {get;set;}
        public Decimal Quantity {get;set;}
    }

    public class FreightGroupWrapper implements Comparable
    {
        public Integer sequenceNumber {get;set;}
        public List<QuoteLineItemWrapper> alternates {set;get;}
        public string shipping{get;set;}
        public string freightCarrier{get;set;}
        public string shippingIncluded {get;set;}
        public Decimal taxPercent {get;set;}
        public Decimal groupTotal{get;set;}
        public decimal groupTotalwTax{get;set;}
        public Decimal totalInclTax {get;set;}
        public decimal freightAmount {get;set;}
        public decimal subTotal {get;set;}
        public decimal freightTax {get;set;}
        public decimal productTax {get;set;}
        public decimal totalWeight {get;set;}
        public boolean showUnitPricing {get;set;}
        public string ManualShippingDescription {get;set;}
        public string groupName {get;set;}
        public boolean isGroup {get;set;}
        public string otherName {get;set;}

        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            FreightGroupWrapper other = (FreightGroupWrapper)compareTo;
    
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if ((this.isGroup && other.isGroup) || (!this.isGroup && !other.isGroup))
            {
                if (this.sequenceNumber> other.sequenceNumber) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (this.sequenceNumber < other.sequenceNumber) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }
            }
            else if (!this.isGroup)
            {
                returnValue = 1;
            }
            else if (!other.isGroup)
            {
                returnValue = -1;
            }
    
            return returnValue;       
        }
    }
}