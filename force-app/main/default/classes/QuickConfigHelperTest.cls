@istest
public with sharing class QuickConfigHelperTest {

    @testSetup static void setup(){

		String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;
		
		Division__c dwDiv = new Division__c(
			Name = 'Door & Wall'
		);
		insert dwDiv;

		List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');
        
		Contact contact = new Contact(
            AccountId = accounts.get(0).Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
			Division_Lookup__c = dwDiv.Id
		);
		insert opp;

		Quote quote = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id,
			Division_Lookup__c = dwDiv.Id,
			Status = 'Approved'
		);
		insert quote;

        AsyncProcess__c ap = new AsyncProcess__c(
            ObjectId__c = quote.Id,
            Status__c = 'In-Process',
            Name = 'Save Quote'
        );
        insert ap;

        Test.startTest();
    }

    // @istest 
    // static void testGetExistingProductList() {
    //     // This causes a fake response to be generated
    //     Test.setMock(WebServiceMock.class, new sfdataTest());
    //     // Call the method that invokes a callout       
    //     item_color__c color = createTestColor('405');
    //     Item_Pallette__c item = createItemPallette('405');

    //     Test.startTest();

    //     List<QuickConfigHelper.qProduct> productList = new List<QuickConfigHelper.qProduct>();       
    //     productList = QuickConfigHelper.getExistingProductList('1', '');
    //     // Verify that a fake result is returned
    //     System.assertEquals(1, productList.size());
    //     System.assertEquals('405', productList[0].Name);
    // }
    
    @istest 
    static void testSaveConfiguration() {
       // This causes a fake response to be generated
       Test.setMock(WebServiceMock.class, new sfdataTest());

        Id [] fixedResults = new Id[1];
        Product2 product1 = createTestProduct('406');
        Item_Pallette__c item = createItemPallette('406');
        fixedResults.add(product1.Id);
        Product2 product2 = createTestProduct('407');
        Item_Pallette__c item2 = createItemPallette('407');
        fixedResults.add(product2.Id);
        Test.startTest();
        // Call the method that invokes a callout
        List<QuickConfigHelper.qProduct> productList = new List<QuickConfigHelper.qProduct>();    
        productList.add(generateqProduct(false));
        productList.add(generateqProduct(true));
        string result = QuickConfigHelper.saveConfiguration('1',productList);
        // Verify that a fake result is returned       
        System.assertEquals('true', result);
    }

    @isTest
    static void search_should_return_Color() {
        Id [] fixedResults = new Id[1];
        item_color__c color = createTestColor('blue');
        fixedResults.add(color.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        string secondarySearch = 'test';
        List<LookupSearchResult> results = QuickConfigHelper.colorsearch('bl', secondarySearch, selectedIds);
        System.assertEquals(1, results.size());
        System.assertEquals(color.Id, results.get(0).getId());
    }

    @isTest
    static void search_should_not_return_selected_Color() {
        Id [] fixedResults = new Id[1];
        item_color__c color1 = createTestColor('blue');
        fixedResults.add(color1.Id);
        item_color__c color2 = createTestColor('red');
        fixedResults.add(color2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        string secondarySearch = '';
        selectedIds.add(color2.Id);
        List<LookupSearchResult> results = QuickConfigHelper.colorsearch('bl',secondarySearch, selectedIds);
        System.assertEquals(1, results.size());
        System.assertEquals(color1.Id, results.get(0).getId());
    }

    @isTest
    static void search_should_return_Product() {
        Id [] fixedResults = new Id[1];
        Product2 product = createTestProduct('405');
        Item_Pallette__c item = createItemPallette('405');
        fixedResults.add(product.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        string secondarySearch = '';
        List<LookupSearchResult> results = QuickConfigHelper.productsearch('40', secondarySearch, selectedIds);
        System.assertEquals(1, results.size());
        System.assertEquals(item.Id, results.get(0).getId());
    }

    @isTest
    static void search_should_not_return_selected_Product() {
        Id [] fixedResults = new Id[1];
        Product2 product1 = createTestProduct('406');
        Item_Pallette__c item = createItemPallette('406');
        fixedResults.add(product1.Id);
        Product2 product2 = createTestProduct('407');
        Item_Pallette__c item2 = createItemPallette('407');
        fixedResults.add(product2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        string secondarySearch = '';
        selectedIds.add(product2.Id);
        List<LookupSearchResult> results = QuickConfigHelper.productsearch('406',secondarySearch, selectedIds);
        System.assertEquals(1, results.size());
        System.assertEquals(item.Id, results.get(0).getId());
    }

    @isTest
    static void testGetDivision(){
        String query = 'Select Id from Quote Limit 1';
        Quote quote = Database.query(query);
        String results = QuickConfigHelper.getDivision(quote.Id);

        String query2 = 'Select Name from Division__c LIMIT 1';
        String name = ((Division__c)Database.query(query2)).Name;

        System.assertEquals(name,results);
    }

    @isTest
    static void testProductSignSearch(){
        Test.setMock(WebServiceMock.class, new sfdataTest());

        List<LookupSearchResult> results = QuickConfigHelper.productSignSearch('Te', '', new List<string>());

        LookupSearchResult result = results.get(0);
        result.getSubtitle();
        result.getSubtitle2();
        result.getTitle();
        result.getSObjectType();
        result.getId();
        result.getIcon();
        result.compareTo(result);
        System.assertEquals(1, results.size());
    }

    @isTest
    static void testGetMountingTypes(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getMountingTypes();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetFontSizes(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getFontSizes();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetFontTypes(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getFontTypes();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetHorizontalJustifications(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getHorizontalJustifications();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetVerticalJustifications(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getVerticalJustifications();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetCollections(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getCollections();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testGetProductionTypes(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        List<string> results = QuickConfigHelper.getProductionTypes();

        System.assertEquals(1, results.size());
        System.assertEquals('Test', results.get(0));
    }

    @isTest
    static void testCreateAsyncProcess_createProcess(){
        String results = QuickConfigHelper.createAsyncProcess('recordId', 'UserId');

        System.assertEquals('success',results);
    }

    @isTest
    static void testCreateAsyncProcess_foundProcess(){
        String quoteId = [SELECT Id FROM Quote LIMIT 1].Id;

        String results = QuickConfigHelper.createAsyncProcess(quoteId,null);

        System.assert(results.indexOf('Save in progress') != -1);
    }

    @isTest
    static void testCancelAsyncProcess_success()
    {
        string processId = String.valueOf([SELECT ID FROM AsyncProcess__c LIMIT 1].Id);
        string result = QuickConfigHelper.cancelAsyncProcess(processId, '');
        System.assertEquals('success', result);
    }
    
    private static Item_Pallette__c createItemPallette(String name){
        Item_Pallette__c item = new Item_Pallette__c(ProductCode__c = name);
        insert item;
        return item;
    }

    private static Product2 createTestProduct(String name) {
        Product2 product = new Product2(Name = name, productcode = name);
        insert product;
        return product;
    }

    private static item_color__c createTestColor(String name) {
        item_color__c color = new item_color__c(Name = name, color_palette__c = 'test', color_number__c = '12345');
        insert color;
        return color;
    }

    private static QuickConfigHelper.qProduct generateqProduct(Boolean isRemoved){
        QuickConfigHelper.qProduct product = new QuickConfigHelper.qProduct();
        product.Id = '12345';
        product.rId = '12345';
        product.Name = 'Test';
        product.Color = 'White';
        product.Quantity = 1;
        product.Description = 'Test';
        product.AlternateName = 'Alt 1';
        product.AlternateId = 12345;
        product.rAlternateId = 12345;
        product.DisplayName = 'Test Help';
        product.ColorPalette = 'Color';
        product.PickSequence = 1;
        product.Description2 = 'Test';
        product.CompetitorColor = 'White';
        product.bpColorCode = '';
        product.fpColorCode = '';
        product.txColorCode = '';
        product.acColorCode = '';

        product.HorizontalAlign = '';
        product.VerticalAlign = '';
        product.FontSize = '';
        product.FontType = '';

        product.bpColorPallette = '';
        product.fpColorPallette = '';
        product.txColorPallette = '';
        product.acColorPallette = '';

        product.MountingType = '';
        product.AccentColor = '';
        product.NormalProductAccentColor = '';
        product.ProductionType = '';

        product.Collection = '';
        product.CustombpColor = '';
        product.CustomfpColor = '';
        product.CustomtxColor = '';

        product.NoteCB = '';
        product.LetterCodeCB = '';
        product.CategoryID = '';
        product.LetterCode = '';
        product.IsRemoved = isRemoved;

        return product;
    }
}