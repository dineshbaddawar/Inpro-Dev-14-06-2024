public with sharing class FreightQuoteHelper 
{
    @AuraEnabled()
    public static string validateShippingAddress(string recordId) 
    {
        Quote q = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Quote WHERE Id = :recordId];

        if (q.ShippingCountry != null && q.ShippingCountry != '')
        {            
            if(q.ShippingCountry == 'United States' || q.ShippingCountry == 'US')
            {
                if(q.ShippingPostalCode == null || q.ShippingPostalCode == '')
                {
                    ZipCodeLookupResultAC returnResult = new ZipCodeLookupResultAC();
                    returnResult.Message = 'Error: There is no shipping zip code specified for this quote';
                    returnResult.Status = false;
                    return JSON.serialize(returnResult); 
                }
                else {
                    sfdata.ZipCodeLookupResult result = (sfdata.ZipCodeLookupResult)JSON.deserialize(AddressValidationHelper.ZipCodeLookup(q.ShippingPostalCode), sfdata.ZipCodeLookupResult.class);
                    
                    ZipCodeLookupResultAC returnResult = new ZipCodeLookupResultAC();
                    if(result.Message != null)
                        returnResult.Message = result.Message;
                    else {
                        returnResult.Message = '';
                    }
                    if(result.Status != null)
                        returnResult.Status = result.Status;
                    else {
                        
                    }
                    if(result.City != null)
                        returnResult.RetrievedCity = result.City;
                    else {
                        returnResult.RetrievedCity = '';
                    }
                    if(result.State != null)
                        returnResult.RetrievedState = result.State;
                    else {
                        returnResult.RetrievedState = '';
                    }
                    if(q.ShippingCity != null)
                        returnResult.OriginalCity = q.ShippingCity;
                    else {
                        returnResult.OriginalCity = '';
                    }
                    if(q.ShippingState != null)
                        returnResult.OriginalState = q.ShippingState;
                    else {
                        returnResult.OriginalState = '';
                    }

                    if (result.Status == true && (result.City.toLowerCase() != q.ShippingCity || AddressValidationHelper.GetStateFullName(result.State) != AddressValidationHelper.GetStateFullName(q.ShippingState)))
                    {
                        returnResult.Status = false;
                        returnResult.Message = 'City and state mismatch';
                    }
                    return JSON.serialize(returnResult);
                }                
            } 
            else {
                ZipCodeLookupResultAC result = new ZipCodeLookupResultAC();
                result.Status = true;
                result.Message = 'Address Validation Bypassed as the shipping address in not from the US.';
                return JSON.serialize(result);
            }                                            
        }
        else
        {
            ZipCodeLookupResultAC result = new ZipCodeLookupResultAC();
            result.Status = false;
            result.Message = 'Error: The Shipping Address\' country is blank. Please complete the quote\'s shipping address and then reload this app.';
            return JSON.serialize(result);
        }           
    }
    
    @AuraEnabled()
    public static string getTerrZipWarning(string recordId) 
    {
        Quote q = [SELECT ShippingPostalCode FROM Quote WHERE Id = :recordId];

        if (q.ShippingPostalCode != '')
        {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;        
            string result =  service.GetTerrZipWarning(q.ShippingPostalCode);

            return result;
        }
        else
        {
            return '';
        }
    }

    @AuraEnabled(continuation=true)
    public static List<FreightQuote> getFreightQuoteByAlternate(string alternateId, string cache) 
    {
        Alternate__c alt =  [SELECT  Id, Name__c, QuoteId__c, Manual_Freight_Quote_Request_Link__c
                             FROM Alternate__c
                             WHERE Id = :alternateId];

        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        sfdata.ArrayOfQuote results = service.GetFreightQuote(alt.QuoteId__c, alt.Id, 'dsj8U73_3nv3Dhba');

        List<FreightQuote> fQuoteList = new List<FreightQuote>();
        
        try{
            if(results != null && results.Quote != null)
            {                
                try 
                {
                    for (sfdata.Quote quote: results.Quote) 
                    {
                        FreightQuote fQuote = new FreightQuote();
                        fQuote.AlternateId = quote.AlternateId;
                        fQuote.CarrierCode = quote.CarrierCode;
                        fQuote.CarrierDetail = quote.CarrierDetail;
                        fQuote.Alternate = quote.Alternate;   
                        fQuote.OptionId = quote.OptionId;
                        fQuote.Charge = quote.Charge;
                        fQuote.TotalCharge = quote.TotalCharge;
                        fQuote.AlternateLabel = quote.AlternateLabel;
                        fQuote.TimeInTransit = quote.TimeInTransit;
                        fQuote.TimeInTransitDesc = quote.TimeInTransitDesc;                            
                        fQuote.GroupName = quote.GroupName;     
                        fQuote.Selected = quote.Selected;                    
                        fQuote.IsFreight = quote.IsFreight;                    
                        fQuote.LiftGate = quote.LiftGate;                    
                        fQuote.LiftGateChrg = quote.LiftGateChrg;   
                        fQuote.FreightCarrierId = quote.FreightCarrierId;
                        fQuote.HasLiftGate = false;
                        if(quote.LiftGateChrg > 0)                 
                            fQuote.HasLiftGate = true;
                        if(quote.CarrierCode == 'NegotiatedFreight')    
                            fQuote.IsNegotiatedFreight = true;
                        else 
                            fquote.IsNegotiatedFreight = false;
                        if(quote.CarrierCode == 'MFQ')    
                        {
                            fQuote.IsMFQ = true;
                            fQuote.ManualFreightQuoteURL = alt.Manual_Freight_Quote_Request_Link__c;
                        }
                        else 
                            fquote.IsMFQ = false;
                        fquote.TrafficNotes = '';
                        fquote.ManualFreightQuoteID = quote.ManualFreightQuoteID;
                        fquote.RushRequested = false;
                        fquote.ShippingDescription = quote.ShippingDescription;                            
                        fquote.ManualFreightQuotes = new List<MFQ>();
                        if(quote.ManualFreightQuotes != null &&  quote.ManualFreightQuotes.ManualFreightQuote != null)
                        {
                            for (sfData.ManualFreightQuote mfq : quote.ManualFreightQuotes.ManualFreightQuote) 
                            {
                                MFQ fq = new MFQ();
                                fq.ID = mfq.ID;
                                fq.Carrier = mfq.Carrier;
                                fq.Amount = mfq.Amount;
                                fq.UpdatedBy = mfq.UpdatedBy;
                                fq.UpdatedOn = mfq.UpdatedOn;
                                fq.AltNo = mfq.AltNo;
                                fq.Rev = mfq.Rev;
                                fquote.ManualFreightQuotes.Add(fq);
                            }
                        }      
                        fquote.ShowFreightOptions = false;    
                        fquote.DriverWait = quote.DriverWait;                            
                        fquote.DriverWaitChrg = quote.DriverWaitChrg;
                        fquote.InsideDelivery = quote.InsideDelivery;
                        fquote.InsideDeliveryChrg = quote.InsideDeliveryChrg;
                        fquote.LoadingDock = quote.LoadingDock;
                        fquote.LoadingDockChrg = quote.LoadingDockChrg;
                        fquote.ServiceCall = quote.ServiceCall;
                        fquote.ServiceCallChrg = quote.ServiceCallChrg;
                        fquote.ServiceCallNote = quote.ServiceCallNote;
                        fquote.GroupLabel = quote.GroupLabel;
                        fQuoteList.Add(fQuote);                        
                    }
                } 
                catch (Exception ex) {
                    fQuoteList.addAll(getDefaultOptions(alt));
                }
            }
        }
        catch(Exception ex)
        {

        }

        return fQuoteList;
    }

    @AuraEnabled
    public static List<Alternate__c> getAlternates(string recordId)
    {
        return [SELECT  Id, Name__c, Freight_Amount__c, Manual_Freight_Quote_Request_Link__c
                FROM Alternate__c
                WHERE QuoteId__c = :recordId];
    } 
    
    @AuraEnabled
    public static List<FreightQuote> getFreightQuote(string recordId, string cache) 
    {
        List<FreightQuote> fQuoteList = new List<FreightQuote>();
          
        List<Alternate__c> alts = [SELECT  Id, Name__c, Manual_Freight_Quote_Request_Link__c
                                    FROM Alternate__c
                                    WHERE QuoteId__c = :recordId];

        for (Alternate__c alt : alts) 
        {
            try 
            {   
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;        
                sfdata.ArrayOfQuote results = service.GetFreightQuote(recordId,alt.Id, 'dsj8U73_3nv3Dhba');
        
                if(results != null && results.Quote != null)
                {                
                    try 
                    {
                        for (sfdata.Quote quote: results.Quote) 
                        {
                            FreightQuote fQuote = new FreightQuote();
                            fQuote.AlternateId = quote.AlternateId;
                            fQuote.CarrierCode = quote.CarrierCode;
                            fQuote.CarrierDetail = quote.CarrierDetail;
                            fQuote.Alternate = quote.Alternate;   
                            fQuote.OptionId = quote.OptionId;
                            fQuote.Charge = quote.Charge;
                            fQuote.TotalCharge = quote.TotalCharge;
                            fQuote.AlternateLabel = quote.AlternateLabel;
                            fQuote.TimeInTransit = quote.TimeInTransit;
                            fQuote.TimeInTransitDesc = quote.TimeInTransitDesc;                            
                            fQuote.GroupName = quote.GroupName;     
                            fQuote.Selected = quote.Selected;                    
                            fQuote.IsFreight = quote.IsFreight;                    
                            fQuote.LiftGate = quote.LiftGate;                    
                            fQuote.LiftGateChrg = quote.LiftGateChrg;   
                            fQuote.FreightCarrierId = quote.FreightCarrierId;
                            fQuote.HasLiftGate = false;
                            if(quote.LiftGateChrg > 0)                 
                                fQuote.HasLiftGate = true;
                            if(quote.CarrierCode == 'NegotiatedFreight')    
                                fQuote.IsNegotiatedFreight = true;
                            else 
                                fquote.IsNegotiatedFreight = false;
                            if(quote.CarrierCode == 'MFQ')    
                                {
                                    fQuote.IsMFQ = true;
                                    fQuote.ManualFreightQuoteURL = alt.Manual_Freight_Quote_Request_Link__c;
                                }
                            else 
                                fquote.IsMFQ = false;
                            fquote.TrafficNotes = '';
                            fquote.ManualFreightQuoteID = quote.ManualFreightQuoteID;
                            fquote.RushRequested = false;
                            fquote.ShippingDescription = quote.ShippingDescription;                            
                            fquote.ManualFreightQuotes = new List<MFQ>();
                            if(quote.ManualFreightQuotes != null &&  quote.ManualFreightQuotes.ManualFreightQuote != null)
                            {
                                for (sfData.ManualFreightQuote mfq : quote.ManualFreightQuotes.ManualFreightQuote) 
                                {
                                    MFQ fq = new MFQ();
                                    fq.ID = mfq.ID;
                                    fq.Carrier = mfq.Carrier;
                                    fq.Amount = mfq.Amount;
                                    fq.UpdatedBy = mfq.UpdatedBy;
                                    fq.UpdatedOn = mfq.UpdatedOn;
                                    fq.AltNo = mfq.AltNo;
                                    fq.Rev = mfq.Rev;
                                    fquote.ManualFreightQuotes.Add(fq);
                                }
                            }      
                            fquote.ShowFreightOptions = false;    
                            fquote.DriverWait = quote.DriverWait;                            
                            fquote.DriverWaitChrg = quote.DriverWaitChrg;
                            fquote.InsideDelivery = quote.InsideDelivery;
                            fquote.InsideDeliveryChrg = quote.InsideDeliveryChrg;
                            fquote.LoadingDock = quote.LoadingDock;
                            fquote.LoadingDockChrg = quote.LoadingDockChrg;
                            fquote.ServiceCall = quote.ServiceCall;
                            fquote.ServiceCallChrg = quote.ServiceCallChrg;
                            fquote.ServiceCallNote = quote.ServiceCallNote;
                            fquote.GroupLabel = quote.GroupLabel;
                            fQuoteList.Add(fQuote);                        
                        }
                    } 
                    catch (Exception ex) {
                        fQuoteList.addAll(getDefaultOptions(alt));
                    }
                }
            } 
            catch (Exception ex)
            {
                
            }
        }  

        return fQuoteList;
    } 

    private static List<FreightQuote> getDefaultOptions(Alternate__c alt)
    {
        List<FreightQuote> fQuoteList = new List<FreightQuote>();

        FreightQuote fQuote = new FreightQuote();
        fQuote.AlternateId = alt.Id;
        fQuote.OptionId = generateGuid();
        fQuote.IsFreight  = true;
        fQuote.CarrierCode = 'MFQ';            
        fQuote.CarrierDetail = 'Manual Freight Quote';
        fQuote.TimeInTransit = 'N/A';
        fQuote.TimeInTransitDesc = 'N/A';             
        fQuote.Charge = 0;
        fQuote.TotalCharge = 0;
        fQuote.AlternateLabel = alt.Name__c;
        fQuote.GroupName = alt.Name__c;                                         
        fQuote.LiftGateChrg = 0;               
        fQuote.HasLiftGate = false;                        
        fQuote.IsNegotiatedFreight = false;            
        fQuote.IsMFQ = true;            
        fQuote.TrafficNotes = '';            
        fQuote.RushRequested = false;                  
        fQuote.ShowFreightOptions = false;                
        fQuote.DriverWaitChrg = 0;            
        fQuote.InsideDeliveryChrg = 0;            
        fQuote.LoadingDockChrg = 0;            
        fQuote.ServiceCallChrg = 0;   
        fQuote.Selected = false;    
        fQuote.LiftGate = false;
        fQuote.LoadingDock = false;
        fQuote.DriverWait= false;
        fQuote.ServiceCall= false;
        fQuote.InsideDelivery     = false;                   
        fQuoteList.Add(fQuote);

        FreightQuote fQuote1 = new FreightQuote();
        fQuote1.AlternateId = alt.Id;
        fQuote1.OptionId = generateGuid();
        fQuote1.IsFreight  = true;
        fQuote1.CarrierCode = 'NegotiatedFreight';            
        fQuote1.CarrierDetail = 'Negotiated Freight';
        fQuote1.TimeInTransit = 'N/A';
        fQuote1.TimeInTransitDesc = 'N/A';             
        fQuote1.Charge = 0;
        fQuote1.TotalCharge = 0;
        fQuote1.AlternateLabel = alt.Name__c;
        fQuote1.GroupName = alt.Name__c;                                         
        fQuote1.LiftGateChrg = 0;               
        fQuote1.HasLiftGate = false;                        
        fQuote1.IsNegotiatedFreight = true;            
        fQuote1.IsMFQ = false;            
        fQuote1.TrafficNotes = '';            
        fQuote1.RushRequested = false;                  
        fQuote1.ShowFreightOptions = false;                
        fQuote1.DriverWaitChrg = 0;            
        fQuote1.InsideDeliveryChrg = 0;            
        fQuote1.LoadingDockChrg = 0;            
        fQuote1.ServiceCallChrg = 0;   
        fQuote1.Selected = false;  
        fQuote1.LiftGate = false;
        fQuote1.LoadingDock = false;
        fQuote1.DriverWait= false;
        fQuote1.ServiceCall= false;
        fQuote1.InsideDelivery     = false;                       
        fQuoteList.Add(fQuote1);

        FreightQuote fQuote2 = new FreightQuote();
        fQuote2.AlternateId = alt.Id;
        fQuote2.OptionId = generateGuid();
        fQuote2.IsFreight  = true;
        fQuote2.CarrierCode = 'RFO';            
        fQuote2.CarrierDetail = 'Remove Freight from Alt.';
        fQuote2.TimeInTransit = 'N/A';
        fQuote2.TimeInTransitDesc = 'N/A';             
        fQuote2.Charge = 0;
        fQuote2.TotalCharge = 0;
        fQuote2.AlternateLabel = alt.Name__c;
        fQuote2.GroupName = alt.Name__c;                                         
        fQuote2.LiftGateChrg = 0;               
        fQuote2.HasLiftGate = false;                        
        fQuote2.IsNegotiatedFreight = false;            
        fQuote2.IsMFQ = false;            
        fQuote2.TrafficNotes = '';            
        fQuote2.RushRequested = false;                  
        fQuote2.ShowFreightOptions = false;                
        fQuote2.DriverWaitChrg = 0;            
        fQuote2.InsideDeliveryChrg = 0;            
        fQuote2.LoadingDockChrg = 0;            
        fQuote2.ServiceCallChrg = 0;   
        fQuote2.Selected = false;      
        fQuote2.LiftGate = false;
        fQuote2.LoadingDock = false;
        fQuote2.DriverWait= false;
        fQuote2.ServiceCall= false;
        fQuote2.InsideDelivery     = false;          
        fQuoteList.Add(fQuote2);

        return fQuoteList;
    }
    
    @AuraEnabled()
    public static Boolean saveFreightQuote(List<FreightQuote> FreightQuotes)
    {
        List<Alternate__c> alternatesToUpdate = new List<Alternate__c>();

        //Bulkify

        string fcIds = '';
        string altIds = '';
        for(FreightQuote fQuote : FreightQuotes)
        {
            fcIds += '\'' + fQuote.CarrierCode + '\',';
            altIds += '\'' + fQuote.AlternateId + '\',';
        }
        fcIds = fcIds.substring(0,fcIds.length()-1);
        altIds = altIds.substring(0,altIds.length()-1);

        string freightCarrierSQL = 'SELECT Id, Name, Carrier_Code__c FROM Freight_Carrier__c where Carrier_Code__c IN (' + fcIds + ')';
        List<Freight_Carrier__c> freightCarriers  = Database.query(freightCarrierSQL);

        string altSQL = 'SELECT Id From Alternate__c WHERE Id IN (' + altIds + ')';
        List<Alternate__c> alternates = Database.query(altSQL);
        for (FreightQuote fQuote : FreightQuotes) 
        {
            string cCode = fQuote.CarrierCode;
            Freight_Carrier__c freightCarrier = null;
            Alternate__c alternate = null;
            for (Freight_Carrier__c fc : freightCarriers)
            {
                if (fc.Carrier_Code__c == fQuote.CarrierCode)
                {
                    freightCarrier = fc;
                }
            }

            for (Alternate__c alt : alternates)
            {
                if (alt.Id == fQuote.AlternateId)
                {
                    alternate = alt;
                }
            }
            
            if (fQuote.CarrierCode != 'MFQ' && fQuote.CarrierCode != 'RFO' && fQuote.CarrierCode != 'NegotiatedFreight')
            {
                alternate.Freight_Amount__c = fQuote.TotalCharge
                    + (fQuote.LiftGate && fQuote.LiftGateChrg != null ? fQuote.LiftGateChrg : 0)
                    + (fQuote.LoadingDock && fQuote.LoadingDockChrg != null ? fQuote.LoadingDockChrg : 0)
                    + (fQuote.DriverWait && fQuote.DriverWaitChrg != null ? fQuote.DriverWaitChrg : 0)
                    + (fQuote.ServiceCall && fQuote.ServiceCallChrg != null ? fQuote.ServiceCallChrg : 0)
                    + (fQuote.InsideDelivery && fQuote.InsideDeliveryChrg != null ? fQuote.InsideDeliveryChrg : 0); 
                alternate.Id = fQuote.AlternateId;
                alternate.Driver_Wait_Charge__c = fQuote.DriverWaitChrg;
                alternate.Driver_Wait__c = fQuote.DriverWait;
                alternate.Inside_Delivery_Charge__c = fQuote.InsideDeliveryChrg;
                alternate.Inside_Delivery__c = fQuote.InsideDelivery;
                alternate.Lift_Gate_Charge__c = fQuote.LiftGateChrg;
                alternate.Lift_Gate__c = fQuote.LiftGate;
                alternate.Loading_Dock_Charge__c = fQuote.LoadingDockChrg;
                alternate.Loading_Dock__c = fQuote.LoadingDock;
                // alternate.Service_Call__c = fQuote.ServiceCall;
                alternate.Service_Call_Charge__c = fQuote.ServiceCallChrg;
                alternate.Service_Call_Note__c = fQuote.ServiceCallNote;
                alternate.Quoted_From_Location__c = fQuote.QuotedFromLocation;                    
                //get carrier code
                if(freightCarrier != null)
                    alternate.Freight_Carrier__c = freightCarrier.Id; 
                else if(fQuote.FreightCarrierId != null)                   
                    alternate.Freight_Carrier__c = fQuote.FreightCarrierId;
                alternate.Manual_Freight_Quote_ID__c = null;
            }
            else if(fQuote.CarrierCode == 'MFQ')
            {
                alternate.Manual_Freight_Quote_ID__c = fQuote.ManualFreightQuoteID;
                alternate.Manual_Shipping_Description__c = fQuote.ShippingDescription;  
                string mfqUpdateResult = UpdateManualFreightQuote(fQuote.AlternateId, fQuote.ManualFreightQuoteID);                       
            }
            else if (fQuote.CarrierCode == 'NegotiatedFreight')
            {
                alternate.Freight_Carrier__c = fQuote.FreightCarrierId;
                alternate.Freight_Amount__c = fQuote.TotalCharge;
            }
            else if(fQuote.CarrierCode == 'RFO')
            {
                alternate.Freight_Amount__c = 0; //Should there be a total charge field?     
                alternate.Id = fQuote.AlternateId;
                alternate.Driver_Wait_Charge__c = 0;
                alternate.Driver_Wait__c = false;
                alternate.Inside_Delivery_Charge__c = 0;
                alternate.Inside_Delivery__c = false;
                alternate.Lift_Gate_Charge__c = 0;
                alternate.Lift_Gate__c = false;
                alternate.Loading_Dock_Charge__c = 0;
                alternate.Loading_Dock__c = false;
                alternate.Service_Call__c = false;
                alternate.Service_Call_Charge__c = 0;
                alternate.Service_Call_Note__c = null;
                alternate.Quoted_From_Location__c = null;
                    //get carrier code
                //alternate.Freight_Carrier__c = null;
                alternate.Freight_Carrier__c = null;
                //alternate.Carrier = fQuote.FreightCarrierId;
                //alternate.CarrierCode = fQuote.CarrierCode;
                alternate.Manual_Freight_Quote_ID__c = null;
                //alternate.Freight_Code__c = null;
            }
            alternatesToUpdate.add(alternate);               
        }
        update alternatesToUpdate;                       
             
        return true;
    }

    @AuraEnabled()
    public static Boolean saveAlternateGroupName(List<FreightQuote> FreightQuotes)
    {
        List<Alternate__c> alternatesToUpdate = new List<Alternate__c>();

        for (FreightQuote fQuote : FreightQuotes) 
        {
            string altParam = fQuote.AlternateId;
            String Query = 'SELECT Id, Freight_Group_Name__c ' +                
                            'FROM Alternate__c ' +
                            'WHERE Id = :altParam LIMIT 1';
            Alternate__c alternate = Database.query(Query);

                alternate.Freight_Group_Name__c = fQuote.GroupName; //Should there be a total charge field?     
                alternate.Id = fQuote.AlternateId;
                
            alternatesToUpdate.add(alternate);               
        }
            
        update alternatesToUpdate;
        return true;           
    }

    @AuraEnabled()
    public static Boolean updateQuoteShippingAddress(String quoteId, String city, String state)
    {
       Quote q = new Quote();
       q.Id = quoteId;
       q.ShippingCity = city;
       q.ShippingState = state;
     
        update q;
        return true;           
    }

    @AuraEnabled(Cacheable = true)
    public static List<Freight_Carrier__c> getFreightCarriers()
    {
        String Query = 'SELECT Id, Name, Carrier_Code__c, MSCRM_ID__c, Tracking_Number_Link__c  FROM Freight_Carrier__c';
        List<Freight_Carrier__c> freightCarriers = Database.query(Query);
        return freightCarriers;    
    }

    @AuraEnabled
    public static string RequestManualFreightQuote(string alternateId, string quoteId, string userId, 
                                                    string notes, Boolean isRush, string shippingDescription) 
    {
                          
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        Integer rush = 0;
        if (isRush) {
            rush = 1;    
        }
    
        string uQuery = 'SELECT Email  FROM User  WHERE Id = :userId';
        List<User> Users = Database.query(uQuery);
        string emailAddress = Users[0].Email;

        String results = service.RequestManualFreightQuote(alternateId, quoteId, emailAddress, notes, rush,'dsj8U73_3nv3Dhba');

        if(alternateId != 'alternateid')
        {
        Alternate__c alternate = new Alternate__c();
        alternate.Id = alternateId;
        alternate.Manual_Shipping_Description__c = shippingDescription;
        update alternate;
        }

        return results;
    }  

    @AuraEnabled
    public static string UpdateManualFreightQuote(string alternateId, string manualFreightQuoteID) {
                        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        String results = service.UpdateManualFreightQuote(alternateId, manualFreightQuoteID, 'dsj8U73_3nv3Dhba');
        return results;
    }
    
    @AuraEnabled
    public static string removeAlternateFreight(string alternateId){
        try {
            Alternate__c alt = [SELECT Id, Freight_Amount__c, Driver_Wait_Charge__c, Driver_Wait__c,
                                    Inside_Delivery_Charge__c, Inside_Delivery__c, Lift_Gate_Charge__c, Lift_Gate__c,
                                    Loading_Dock_Charge__c, Loading_Dock__c, Service_Call__c, Service_Call_Charge__c,
                                    Service_Call_Note__c, Quoted_From_Location__c, Freight_Carrier__c, Manual_Freight_Quote_ID__c
                                FROM Alternate__c 
                                WHERE Id = :alternateId];

            alt.Freight_Amount__c = 0; //Should there be a total charge field?     
            alt.Driver_Wait_Charge__c = 0;
            alt.Driver_Wait__c = false;
            alt.Inside_Delivery_Charge__c = 0;
            alt.Inside_Delivery__c = false;
            alt.Lift_Gate_Charge__c = 0;
            alt.Lift_Gate__c = false;
            alt.Loading_Dock_Charge__c = 0;
            alt.Loading_Dock__c = false;
            alt.Service_Call__c = false;
            alt.Service_Call_Charge__c = 0;
            alt.Service_Call_Note__c = null;
            alt.Quoted_From_Location__c = null;
            alt.Freight_Carrier__c = null;
            alt.Manual_Freight_Quote_ID__c = null;
            alt.Manual_Shipping_Description__c = null;

            update alt;
            
            return '';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    
    public class FreightQuote{
        @AuraEnabled
        public string OptionId { get; set; }
        @AuraEnabled
        public Boolean IsFreight { get; set; }
        @AuraEnabled
        public string AlternateId { get; set; }
        @AuraEnabled
        public string Alternate { get; set; }
        //@AuraEnabled
        //public integer AlternateNumber { get; set; }
        @AuraEnabled
        public string CarrierCode { get; set; }
        // @AuraEnabled
        // public string CarrierServiceCode { get; set; }
        // @AuraEnabled
        // public string CarrierTransitCode { get; set; }
        @AuraEnabled
        public string CarrierDetail { get; set; }
        // @AuraEnabled
        // public decimal BillingWeight { get; set; }
        @AuraEnabled
        public string TimeInTransit { get; set; }
        @AuraEnabled
        public string TimeInTransitDesc { get; set; }
        // @AuraEnabled
        // public string ETA { get; set; }
        @AuraEnabled
        public decimal Charge { get; set; }
        // @AuraEnabled            
        // public decimal Cost { get; set; }
        @AuraEnabled
        public decimal LiftGateChrg { get; set; }
        @AuraEnabled
        public decimal LoadingDockChrg { get; set; }
        @AuraEnabled
        public decimal DriverWaitChrg { get; set; }
        @AuraEnabled
        public decimal InsideDeliveryChrg { get; set; }
        @AuraEnabled
        public decimal ServiceCallChrg { get; set; }
        @AuraEnabled
        public string QuotedFromLocation { get; set; }
        // @AuraEnabled
        // public integer SortOrder { get; set; }
        //TODO: Define this class
        @AuraEnabled
        public List<MFQ> ManualFreightQuotes { get; set; }
        @AuraEnabled
        public string FreightCarrierId { get; set; }
        @AuraEnabled
        public string ServiceCallNote { get; set; }
        @AuraEnabled
        public string ManualFreightQuoteID { get; set; }
        @AuraEnabled
        public string ManualFreightQuoteURL {get;set;}
        @AuraEnabled
        public string ShippingDescription { get; set; }
        // @AuraEnabled
        // public Boolean HasMixedShippingLocations { get; set; }
        // @AuraEnabled
        // public Boolean HasCustomProducts { get; set; }
        // @AuraEnabled
        // public Boolean HasZeroWeightItems { get; set; }
        // @AuraEnabled
        // public Boolean HasDropShipItems { get; set; }
        // @AuraEnabled
        // public string ShippingLocationName { get; set; }
        // @AuraEnabled
        // public string QuotedFromLocationName { get; set; }
        @AuraEnabled
        public string AlternateLabel { get; set; }
        // @AuraEnabled
        // public decimal AlternateTotalWeight { get; set; }            
        @AuraEnabled
        public string GroupName { get; set; }
        // @AuraEnabled
        // public decimal GroupWeight { get; set; }
            @AuraEnabled
            public string GroupLabel { get; set; }
        // @AuraEnabled
        // public Boolean InstallationQuote { get; set; }
        @AuraEnabled
        public Boolean Selected { get; set; }
        @AuraEnabled
        public Boolean LiftGate { get; set; }
        @AuraEnabled
        public Boolean LoadingDock { get; set; }
        @AuraEnabled
        public Boolean DriverWait { get; set; }
        @AuraEnabled
        public Boolean InsideDelivery { get; set; }
        @AuraEnabled
        public Boolean ServiceCall { get; set; }
        @AuraEnabled
        public decimal TotalCharge { get; set; }
        @AuraEnabled
        public Boolean HasLiftGate { get; set; }
        @AuraEnabled
        public Boolean IsNegotiatedFreight {get;set;}
        @AuraEnabled
        public Boolean IsMFQ {get;set;}
        @AuraEnabled
        public string TrafficNotes {get;set;}
        @AuraEnabled
        public Boolean RushRequested {get;set;}
        @AuraEnabled
        public Boolean ShowFreightOptions {get;set;}
    }

    public class MFQ{
        @AuraEnabled
        public String ID {get;set;}
        @AuraEnabled
        public String Carrier {get;set;}
        @AuraEnabled
        public String Amount{get;set;}
        @AuraEnabled
        public String UpdatedBy{get;set;}
        @AuraEnabled
        public String UpdatedOn{get;set;}
        @AuraEnabled
        public String AltNo{get;set;}
        @AuraEnabled
        public String Rev{get;set;}
    }   
    
    public class ZipCodeLookupResultAC{
        @AuraEnabled
        public Boolean Status {get;set;}
        @AuraEnabled
        public String Message {get;set;}
        @AuraEnabled
        public String RetrievedCity{get;set;}
        @AuraEnabled
        public String RetrievedState {get;set;}
        @AuraEnabled
        public String OriginalCity {get;set;}
        @AuraEnabled
        public String OriginalState {get;set;}
    }  

    public static String generateGuid()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }
}