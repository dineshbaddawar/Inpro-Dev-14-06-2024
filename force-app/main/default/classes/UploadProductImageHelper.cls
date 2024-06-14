public with sharing class UploadProductImageHelper
{
    @AuraEnabled()
    public static string getProductCode(String productId){      
        Product2 product = [SELECT ProductCode FROM Product2 WHERE Id = :productId];
        return product.ProductCode;
    }

    @AuraEnabled()
    public static string getProductImageId(String productId){      
        Product2 product = [SELECT ProductCode, DisplayUrl FROM Product2 WHERE Id = :productId];
        if (product.DisplayUrl != null && product.DisplayUrl != '')
        {
            string id = product.DisplayUrl.replace('https://' + DomainCreator.getOrgMyDomainHostname().replace('.my.salesforce.com','').replace('.salesforce.com','') + '.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=', '');
           
            id = id.replace('&operationContext=CHATTER','');
            return id;
        }
        else
        {
            return '';
        }
    }

    @AuraEnabled()
    public static string getProductImage(String contentVersionId){     
        if (contentVersionId != '')
        {
            try{
                ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData, Origin, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId ORDER BY CreatedDate DESC LIMIT 1];

                if (cv == null)
                {
                    return null;
                }
                else
                {
                    return EncodingUtil.base64Encode(cv.VersionData);
                }
            }catch(Exception ex)
            {
                return null;
            }
        } 
        else return null;
    }

    @AuraEnabled()
    public static string getNewProductImage(String contentVersionId){      
        ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData, Origin, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

        //List<ContentDocument> listToDelete = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        //delete listToDelete;

        if (cv == null)
        {
            return null;
        }
        else
        {
            return EncodingUtil.base64Encode(cv.VersionData);
        }
    }

    @AuraEnabled()
    public static string deleteImage(String contentVersionId, string productId){      
        try
        {
            ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData, Origin, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

            //Remove previous version
            List<ContentDocument> listToDelete = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
            delete listToDelete;

            

            Product2 product = [SELECT Id, DisplayUrl FROM Product2 WHERE Id = :productId LIMIT 1];
            product.DisplayUrl = '';
            update product;

            return '';
        }
        catch(Exception ex)
        {
            return ex.getMessage() + ', ' + ex.getStackTraceString();
        }
    }

    @AuraEnabled()
    public static string saveProductImage(String contentVersionId, string productCode, String imageData){      
        try
        {
            ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData, Origin, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

            //Remove previous version
            List<ContentDocument> listToDelete = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
            delete listToDelete;

            //Create new version
            ContentVersion newCV = new ContentVersion();
            newCV.Title = productCode;
            newCV.VersionData = EncodingUtil.base64Decode(imageData);
            newCV.PathOnClient = productCode + '.jpg';
            newCV.Origin = 'H';
            insert newCV;

            //Get document id
            ContentVersion newCV2 = [SELECT Id, Title, PathOnClient, VersionData, Origin, ContentDocumentId FROM ContentVersion WHERE Id = :newCV.Id LIMIT 1];

            //Create library link
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Sample Images'].Id;
            cdl.ContentDocumentId = newCV2.ContentDocumentId;
            cdl.ShareType = 'I';
            insert cdl;

            Product2 product = [SELECT Id, DisplayUrl FROM Product2 WHERE ProductCode = :productCode LIMIT 1];
            product.DisplayUrl = 'https://' + DomainCreator.getOrgMyDomainHostname().replace('.my.salesforce.com','').replace('.salesforce.com','')  + 
                '.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=' + newCV2.Id + '&operationContext=CHATTER';
            update product;

            return newCV.Id;
        }
        catch(Exception ex)
        {
            return 'Error: ' + ex.getMessage() + ', ' + ex.getStackTraceString();
        }
    }
}