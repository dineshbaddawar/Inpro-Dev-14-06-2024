@isTest
public with sharing class RelatedRecordNotificationHelperTest {
    @isTest static void relatedRecordsTest() {
        Boolean exists = RelatedRecordNotificationHelper.doRecordsExist('test', 'GPO_Association__c');
        System.assertEquals(exists, false);
    }
}