public with sharing class QuickConfigHelper {


    @AuraEnabled()
    public static List <qProduct> getExistingProductList(string recordId, string cache) {

        List<qProduct> qProductList = new List<qProduct>();
        String productIcon = 'standard:account';       
        integer page = 0;
        Boolean loadMore = true;        

        while (loadMore) 
        {
            loadMore = false;
            sfdata.ArrayOfExpConfiguration results = getConfigs(recordId, page); 
            page++;   
            List<qProduct> qProducts = getProducts(results);
                if(results != null && results.ExpConfiguration != null)
                {
                    sfdata.ExpConfiguration config = results.ExpConfiguration[0];
                    if(config.MoreRecords)
                    {
                        loadMore = true;
                    }
                }
               for (qProduct qp : qProducts) {
                   qProductList.add(qp);
               } 
        } 

        return qProductList;
    }  

    private static sfdata.ArrayOfExpConfiguration getConfigs(string recordId, integer page)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        sfdata.ArrayOfExpConfiguration results = service.LoadConfiguration(recordId, page, 'dsj8U73_3nv3Dhba');
        return results;
    }

     private static List<qProduct> getProducts(sfdata.ArrayOfExpConfiguration results) {
        List<qProduct> qProductList = new List<qProduct>();
        if(results != null && results.ExpConfiguration != null)
        for (sfdata.ExpConfiguration config: results.ExpConfiguration) {            
            if(config.Options != null && config.Options.ExpOption != null)
                for (sfdata.ExpOption option: config.Options.ExpOption) {
                    qProduct product = new qProduct();
                    product.Id = option.rId;
                    product.rId = option.rId;
                    product.Name = option.ItemNumber;
                    product.Color = option.ColorCode;
                    product.Quantity = option.Qty;
                    product.Description = option.Note;
                    product.AlternateId = config.ID;
                    product.rAlternateId = config.ID;
                    product.AlternateName = config.Name;                
                    product.PickSequence = option.PickSequence;                    
                    product.ColorPalette = option.acColorPallette;
                    product.bpColorCode = option.bpColorCode;
                    product.bpColorPallette = option.bpColorPallette;
                    product.txColorCode = option.txColorCode;
                    product.txColorPallette = option.txColorPallette;
                    product.acColorCode = option.acColorCode;
                    product.acColorPallette = option.acColorPallette;
                    product.fpColorCode = option.fpColorCode;
                    product.fpColorPallette = option.fpColorPallette;
                    product.AccentColor = option.AccentColor;
                    product.MountingType = option.MountingType;
                    product.FontType = option.FontType;
                    product.FontSize = option.FontSize;
                    product.HorizontalAlign = option.HorizontalAlign;
                    product.VerticalAlign = option.VerticalAlign; 

                    // string ItemNum = option.ColorCode;
                    // String Query = 'select id, color_number__c, color_palette__c, name from item_color__c where color_number__c = :ItemNum LIMIT 1';
                    // for (sObject so: Database.Query(Query)) {                              
                    //     product.ColorPalette = (String) so.get('color_palette__c');
                    // }
                    
                    qProductList.Add(product);
            }
        }
        return qProductList;     
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> colorsearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';      
        String Query = 'select id, color_number__c, color_palette__c, name from item_color__c where (name like :key or color_number__c like :key)';

        if (secondarySearchTerm != '') {
            Query += ' and color_palette__c = :secondarySearchTerm';
        }

        Query += ' LIMIT 50';
        // Prepare results
        List < LookupSearchResult > results = new List < LookupSearchResult > ();

        String colorIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String colorName = (String)so.get('name');
            String ColorPalette = (String) so.get('color_palette__c');
            String colorId = (String) so.get('id');
            String colorNumber = (String)so.get('color_number__c');  
            String subtitle = 'Color' + colorNumber == null ? '' : ' • ' + colorNumber;       
            if(colorNumber != null && colorNumber != '' && colorNumber.length() > 1)     
                colorName += '-' + colorNumber;
                
            results.add(new LookupSearchResult(colorId, 'item_color__c', colorIcon, colorName, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> productsearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';
        //String Query = 'select productcode, id , Item_Number__c from product2 where productcode like :key LIMIT 50';

        string Query =  'SELECT Color_Pallette__c, Color_Pallette_2__c, Color_Pallette_3__c, Color_Pallette_4__c, ' +
          'Color_Pallette_5__c, Color_Pallette_6__c, CatId__c, CatId_ProductCode__c, ProductCode__c, Id, Division__c, Option_description__c ' +
          'FROM Item_Pallette__c where  catid__c != \'Qualifications\' and ProductCode__c like :key order by ProductCode__c LIMIT 50';

        // Prepare results
        List<LookupSearchResult> results = new List <LookupSearchResult>();

        String productIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String productName = (String)so.get('ProductCode__c');
            String ColorPalette = (String)so.get('Color_Pallette__c'); //TODO: Get This from SalesForce once the property exists
            String productId = (String)so.get('Id');
            String Description = (String)so.get('Option_description__c');
            String subtitle = ColorPalette; //'Product' + productName == null ? '' : ' • ' + productName;
            results.add(new LookupSearchResult(productId, 'Item_Pallette__c', productIcon, productName, subtitle,Description));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled()
    public static string saveConfiguration(string recordId, List <qProduct> products) 
    {
        try {
            recordId.trim(); //fails on null - for testing
            //group products by alternate
            Map<integer,List<qProduct>> alternateGroups = new Map <integer, List <qProduct>>();
            for (qProduct product: products) {
                if (alternateGroups.ContainsKey(product.AlternateId)) {
                    alternateGroups.get(product.AlternateId).add(product);
                } else {
                    List < qProduct > productList = new List < qProduct > ();
                    productList.add(product);
                    alternateGroups.put(product.AlternateId, productList);
                }
            }

            //create the soap object
            //sfdata.ArrayOfExpConfiguration configWrapper = new sfdata.ArrayOfExpConfiguration();
            List<ExpConfiguration> configList = new List <ExpConfiguration> ();
            for (integer key: alternateGroups.keySet()) 
            {   
                List<qProduct> plist = alternateGroups.get(key);
                ExpConfiguration config = new ExpConfiguration();                
                config.Options = new List<ExpOption>();               
                config.RemovedOptions = new List<ExpOption>();
                List <ExpOption> options = new List<ExpOption> ();
                List <ExpOption> removedOptions = new List<ExpOption> ();
                integer pickSeq = 0;
                for (qProduct qProduct: plist) {
                    
                    ExpOption option = new ExpOption();                            
                    option.Qty = qProduct.Quantity;
                    
                    option.Note = qProduct.Description;
                    if(option.Note == null) option.Note = '';
                    option.ColorCode = qproduct.Color;                                       
                    option.ItemNumber = qproduct.Name;
                    option.rId = qproduct.rId;                   
                    config.Name = qProduct.AlternateName;
                    config.ID = qProduct.rAlternateId;
                    option.Discount = 0;

                    option.bpColorCode = qproduct.bpColorCode;
                    option.bpColorPallette = qproduct.bpColorPallette;
                    option.txColorCode = qproduct.txColorCode;
                    option.txColorPallette = qproduct.txColorPallette;
                    option.acColorCode = qproduct.acColorCode;
                    option.acColorPallette = qproduct.acColorPallette;
                    option.fpColorCode = qproduct.fpColorCode;
                    option.fpColorPallette = qproduct.fpColorPallette;
                    option.AccentColor = qproduct.AccentColor;
                    option.MountingType = qproduct.MountingType;
                    option.FontType = qproduct.FontType;
                    option.FontSize = qproduct.FontSize;
                    option.HorizontalAlign = qproduct.HorizontalAlign;
                    option.VerticalAlign = qproduct.VerticalAlign;       

                    if(qProduct.IsRemoved)
                    {
                        option.PickSequence =  0;
                        //only remove existing opions
                        if(qProduct.rId != '00000000-0000-0000-0000-000000000000')
                            removedOptions.add(option);
                    }
                    else
                    {
                        pickSeq++;
                        option.PickSequence = pickSeq;
                        options.add(option);
                    }
                }
                config.Options = options;
                config.removedOptions = removedOptions;
                config.MadeChanges = true;      
                
                configList.add(config);
            }

            //call webservice
            String json = JSON.serialize(configList);
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
            service.timeout_x = 120000;
            String results = service.saveConfiguration(recordId, json, 'dsj8U73_3nv3Dhba');
            return  results; 
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static string getDivision(String recordId){
        String Query = 'SELECT Division__c FROM Quote where id = :recordId  LIMIT 1';
        List<Quote> QuoteList = Database.query(Query);
        String DivisionName = QuoteList[0].Division__C;
        return DivisionName;    
    }    

    @AuraEnabled
    public static List <LookupSearchResult> productSignSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {

        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfString sResults = service.RetrieveSigns(searchTerm, 'dsj8U73_3nv3Dhba');

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String productIcon = 'standard:account';
        Integer ID = 0;
        if(sResults != null && sResults.string_x != null)
        for (String product : sResults.string_x) 
        {    
            ID = ID +1;   
            String productName = product; 
            String productId = '1' ;//+ ID;           
            try{
                results.add(new LookupSearchResult(productId, 'signs', productIcon, productName, product));
            }catch(Exception ex){
                results.add(new LookupSearchResult(null, 'signs', productIcon, productName, product));
            }
            
        }

        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getMountingTypes() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveMountingTypes('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getFontSizes() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveFontSizes('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getFontTypes() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveFontTypes('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getHorizontalJustifications() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveHorizontalJustifications('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getVerticalJustifications() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveVerticalJustifications('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getCollections() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveCollections('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getProductionTypes() {
        // Prepare query paramters
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.ArrayOfSignOption sResults = service.RetrieveProductionTypes('dsj8U73_3nv3Dhba');
        // Prepare results
        List<string> results = new List<string>();
        if(sResults != null && sResults.SignOption != null)
        for (sfData.SignOption option : sResults.SignOption) 
        {                  
            results.add(option.LabelField);
        }
        // sort all results on name
        results.sort();
        return results;
    }

    @AuraEnabled()
    public static string createAsyncProcess(String recordId, String UserId){

        try {
            recordId.trim(); //fails on null - for testing
            String Query = 'SELECT Id, Name FROM AsyncProcess__c WHERE ObjectId__c = :recordId AND Status__c = \'In-Process\' and Name = \'Save Quote\' LIMIT 1';
            List<AsyncProcess__c> asyncList = Database.query(Query);
            
            if(asyncList.size() == 0)
            {
                AsyncProcess__c asyncProcess = new AsyncProcess__c();                
                asyncProcess.CreatedDate__c = Datetime.now();                
                //asyncProcess.Log__c = '';
                asyncProcess.Name = 'Save Quote';
                asyncProcess.ObjectId__c = recordId;                
                asyncProcess.Status__c = 'In-Process';                   
                insert asyncProcess;       
                return 'success';
            }
            else {
                return 'Save in progress, you will be notified when it is finished. (Bell icon in the upper right corner)';
                }
        } catch (Exception ex) {
            return JSON.serialize(ex); 
        }
    }

    @AuraEnabled()
    public static string cancelAsyncProcess(String recordId, String UserId){

        try {
            recordId.trim(); //fails on null - for testing
            String Query = 'SELECT Id, Name FROM AsyncProcess__c WHERE ObjectId__c = :recordId AND Status__c = \'In-Process\' and Name = \'Save Quote\' LIMIT 1';
            List<AsyncProcess__c> asyncList = Database.query(Query);
            
            if(asyncList.size() != 0)
            {
                AsyncProcess__c asyncProcess = new AsyncProcess__c();                
                asyncProcess.Id = asyncList[0].Id;
                asyncProcess.Status__c = 'Complete';                   
                update asyncProcess;     
            }
                
            return 'success';
        } catch (Exception ex) {
            return JSON.serialize(ex); 
        }
    }

    public class qProduct {
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string rId {get;set;}
        @AuraEnabled
        public string Name {get;set;}
        @AuraEnabled
        public string Color {get;set;}
        @AuraEnabled
        public decimal Quantity {get;set;}
        @AuraEnabled
        public string Description {get;set;}
        @AuraEnabled
        public string AlternateName { get;set;}
        @AuraEnabled
        public integer AlternateId { get;set;}
        @AuraEnabled
        public integer rAlternateId { get;set;}
        @AuraEnabled
        public string DisplayName { get;  set; }
        @AuraEnabled
        public string ColorPalette { get; set; }       
        //after
        @AuraEnabled
        public integer PickSequence { get; set; }    
        @AuraEnabled
        public string Description2 { get; set; }
        @AuraEnabled
        public string CompetitorColor { get; set; }
        @AuraEnabled
        public string bpColorCode { get; set; }
        @AuraEnabled
        public string fpColorCode { get; set; }
        @AuraEnabled
        public string txColorCode { get; set; }
        @AuraEnabled
        public string acColorCode { get; set; }
        @AuraEnabled
        public string HorizontalAlign { get; set; }
        @AuraEnabled
        public string VerticalAlign { get; set; }
        @AuraEnabled
        public string FontSize { get; set; }
        @AuraEnabled
        public string FontType { get; set; }
        @AuraEnabled
        public string bpColorPallette { get; set; }
        @AuraEnabled
        public string fpColorPallette { get; set; }
        @AuraEnabled
        public string txColorPallette { get; set; }
        @AuraEnabled
        public string acColorPallette { get; set; }
        @AuraEnabled
        public string MountingType { get; set; }
        @AuraEnabled
        public string AccentColor { get; set; }
        @AuraEnabled
        public string NormalProductAccentColor { get; set; }
        @AuraEnabled
        public string ProductionType { get; set; }
        @AuraEnabled
        public string Collection { get; set; }
        @AuraEnabled
        public string CustombpColor { get; set; }
        @AuraEnabled
        public string CustomfpColor { get; set; }
        @AuraEnabled
        public string CustomtxColor { get; set; }        
        @AuraEnabled
        public string NoteCB { get; set; }
        @AuraEnabled
        public string LetterCodeCB { get; set; }
        @AuraEnabled
        public string CategoryID { get; set; }
        @AuraEnabled
        public string LetterCode { get; set; }
        @AuraEnabled
        public Boolean IsRemoved { get; set; }
    }

    public class qColor {
        @AuraEnabled
        public string Id {
            get;
            set;
        }
        @AuraEnabled
        public string Name {
            get;
            set;
        }
        @AuraEnabled
        public string ColorPalette {
            get;
            set;
        }
    }

    //used for soap call
    public class ExpConfiguration
    {
        public string Name { get; set; }
        public integer ID { get; set; }
        public List<ExpOption> Options { get; set; }
        public List<ExpOption> RemovedOptions { get; set; }
        public Boolean MadeChanges { get; set; }
    }

    public class ExpOption
    {
        public string ItemNumber { get; set; }
        public string ColorCode { get; set; }
        public decimal Qty { get; set; }
        public integer PickSequence { get; set; }
        public string Description { get; set; }
        public string Description2 { get; set; }
        public string Note { get; set; }
        public string rId { get; set; }
        public string CompetitorColor { get; set; }
        public string bpColorCode { get; set; }
        public string fpColorCode { get; set; }
        public string txColorCode { get; set; }
        public string acColorCode { get; set; }
        public string HorizontalAlign { get; set; }
        public string VerticalAlign { get; set; }
        public string FontSize { get; set; }
        public string FontType { get; set; }
        public string bpColorPallette { get; set; }
        public string fpColorPallette { get; set; }
        public string txColorPallette { get; set; }
        public string acColorPallette { get; set; }
        public string MountingType { get; set; }

        public string AccentColor { get; set; }
        public string NormalProductAccentColor { get; set; }
        public string ProductionType { get; set; }
        public string Collection { get; set; }
        public string CustombpColor { get; set; }
        public string CustomfpColor { get; set; }
        public string CustomtxColor { get; set; }
        public string AlternateName { get; set; }
        public string NoteCB { get; set; }
        public string LetterCodeCB { get; set; }
        public string CategoryID { get; set; }
        public string LetterCode { get; set; }        
        public String DiscountType {get;set;}
        public Decimal Discount{get;set;}
    }
}