@isTest
public with sharing class UploadProductImageHelperTest 
{
    @testSetup static void setup(){
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;

        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, ProductCode = 'Bronze', DisplayUrl = '');
        string testUrl = '.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&' + 
                         'versionId=' + contentVersion_1.Id + '&operationContext=CHATTER';
        prod.DisplayUrl = testUrl;
        insert prod;

    }

    @isTest static void testGetProductCode_success() {
        Product2 product = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        String productCode = UploadProductImageHelper.getProductCode(product.Id);

        System.assertEquals(product.ProductCode, productCode);
    }

    @isTest static void testGetProductImageId_success() {
        Product2 product = [SELECT Id, DisplayUrl, ProductCode FROM Product2 LIMIT 1];

        string id = UploadProductImageHelper.getProductImageId(product.Id);

        System.assert(product.DisplayUrl.indexOf(id) != -1);
    }

    @isTest static void testGetProductImage_success() {
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion LIMIT 1];
        string blobStr = UploadProductImageHelper.getProductImage(cv.Id);
        string encodedData = EncodingUtil.base64Encode(cv.VersionData);
        System.assertEquals(encodedData, blobStr);
    }

    @isTest static void testGetNewProductImage_success() {
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion LIMIT 1];
        string blobStr = UploadProductImageHelper.getNewProductImage(cv.Id);
        string encodedData = EncodingUtil.base64Encode(cv.VersionData);
        System.assertEquals(encodedData, blobStr);
    }

    @isTest static void testDeleteImage_success() {
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;

        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Silver', IsActive = true, ProductCode = 'Silver', DisplayUrl = '');
        string testUrl = '.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&' + 
                         'versionId=' + contentVersion_1.Id + '&operationContext=CHATTER';
        prod.DisplayUrl = testUrl;
        insert prod;

        string nothing = UploadProductImageHelper.deleteImage(contentVersion_1.Id, prod.Id);

        Product2 prodUpdated = [SELECT Id, DisplayUrl FROM Product2 WHERE Id = :prod.Id];

        System.assertEquals(null, prodUpdated.DisplayUrl);
    }

    @isTest static void testSaveProductImage_success() {
        String text = 'Unit Test ContentVersion Body';
        Blob bodyBlob = Blob.valueOf(text);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;

        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Silver', IsActive = true, ProductCode = 'Silver', DisplayUrl = '');
        string testUrl = '.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&' + 
                         'versionId=' + contentVersion_1.Id + '&operationContext=CHATTER';
        prod.DisplayUrl = testUrl;
        insert prod;

        String imageData = EncodingUtil.base64Encode(bodyBlob);
        Blob encodedData = EncodingUtil.base64Decode(imageData);

        string newId = UploadProductImageHelper.saveProductImage(contentVersion_1.Id, prod.ProductCode, imageData);

        ContentVersion cvNew = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :newId];
        String versionDataText = cvNew.VersionData.toString();
        
        System.assertEquals(text, versionDataText);
    }
}