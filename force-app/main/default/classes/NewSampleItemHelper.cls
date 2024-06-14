public with sharing class NewSampleItemHelper {
    @AuraEnabled
    public static Sample_Request__c GetSampleRequest(string recordId){
        return [SELECT Id, Division__c, Name FROM Sample_Request__c WHERE Id = :recordId];
    }

    @AuraEnabled
    public static List<Sample_Request_Item__c> GetSampleRequestItems(string recordId){
        return [SELECT Id, Sample_Product__r.Name, Name, Quantity__c, Available_Inventory__c, 
                       Item_Cost__c, Product_Is_Active__c , Div_Abbreviation__c, Sample_Product__r.ProductCode
                FROM Sample_Request_Item__c 
                WHERE Sample_Request__c = :recordId];
    }

    @AuraEnabled
    public static List<ContentVersion> GetProducts(string names)
    {
        try{
            return Database.query('SELECT Id, ProductCode, DisplayUrl FROM Product2 WHERE ProductCode IN (' + names + ')');
        }catch(Exception ex)
        {
            return new List<ContentVersion>();
        }
    }

    @AuraEnabled
    public static string DeleteSampleRequestItems(List<string> itemList){
        List<Sample_Request_Item__c> sris = [SELECT Id FROM Sample_Request_Item__c WHERE Id IN :itemList];

        if (sris.size() > 0)
        {
            delete sris;
        }
        return 'Success';
    }

    @AuraEnabled
    public static string CreateSampleRequestItem(string sampleRequestId, string productId, string quantity){
        Sample_Request_Item__c sri = new Sample_Request_Item__c();

        sri.Sample_Request__c = sampleRequestId;
        sri.Sample_Product__c = productId;
        sri.Quantity__c = Decimal.valueOf(quantity);

        insert sri;

        return 'Success';
    }

    @AuraEnabled
    public static string CreateSampleRequestItems(string sampleRequestId, List<string> productIds, List<string> quantities){

        List<Sample_Request_Item__c> sris = new List<Sample_Request_Item__c>();
        
        for(Integer i = 0; i < productIds.size(); i++)
        {
            Sample_Request_Item__c sri = new Sample_Request_Item__c();

            sri.Sample_Request__c = sampleRequestId;
            sri.Sample_Product__c = productIds[i];
            sri.Quantity__c = Decimal.valueOf(quantities[i]);

            sris.add(sri);
        }

        insert sris;

        return 'Success';
    }

    @AuraEnabled
    public static List<String> GetProductFamilyPicklist(){
        return picklist_values('Product2','Family');
    }

    @AuraEnabled
    public static List<String> GetDivisionPicklist(){
        return picklist_values('Product2','Division__c');
    }

    private static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getLabel());}
            }
        }
        return values;
    }

    @AuraEnabled
    public static List<Product2> AdvancedProductSearch(String name, String division, String productFamily, String searchPage){
        String key = '%' + name + '%';
        String query = 'SELECT Id, Name, Description, Division__c, Family, Available_Inventory__c, ProductCode FROM Product2 ';
        String subQuery = 'IsActive = true';
        Integer skipCount = (Integer.valueOf(searchPage)-1) * 50;
        if (division != null && division != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Division__c = \'' + division + '\' ';
        }
        if (productFamily != null && productFamily != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Family = \'' + productFamily + '\' ';
        }
        if (name != null && name != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Name LIKE \'' + key + '\' ';
        }
        subQuery += (subQuery != '' ? ' AND ' : '') + 'Family IN (\'Literature\',\'Promotional\',\'Samples\',\'Color Sample\',\'Fabric Sample\') ';
        query += (subQuery != '' ? ' WHERE ' + subQuery : '') + ' ORDER BY Name ASC';

        List<Product2> results = Database.query(query);

        Integer count = 1; //offset sucks hard
        Integer startRecord = 1 * ((Integer.valueOf(searchPage)-1) * 50);
        Integer endRecord = startRecord + 50;
        List<Product2> temp = new List<Product2>();
        for(Product2 p : results)
        {
            if (count >= startRecord && count < endRecord)
            {
                temp.add(p);
            }
            count++;
        }
        return temp;
    }

    @AuraEnabled
    public static Integer AdvancedProductSearchGetPageCount(String name, String division, String productFamily){
        String key = '%' + name + '%';
        String query = 'SELECT Id, Name, Description, Division__c, Family, Available_Inventory__c, ProductCode FROM Product2 ';
        String subQuery = 'IsActive = true';
        if (division != null && division != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Division__c = \'' + division + '\' ';
        }
        if (productFamily != null && productFamily != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Family = \'' + productFamily + '\' ';
        }
        if (name != null && name != '')
        {
            subQuery += (subQuery != '' ? ' AND ' : '') + 'Name LIKE \'' + key + '\' ';
        }
        subQuery += (subQuery != '' ? ' AND ' : '') + 'Family IN (\'Literature\',\'Promotional\',\'Samples\',\'Color Sample\',\'Fabric Sample\') ';
        query += (subQuery != '' ? ' WHERE ' + subQuery : '') + ' ORDER BY Name ASC';


        List<Product2> results = Database.query(query);

        Integer pages = Math.ceil(results.size() / 50.0).intValue();
        return pages == 0 ? 1 : pages;
    }
}