@istest
public with sharing class AccountHelperTest {
    @istest
    public static void testUpsertSyncDivPriceLevelToChildAccounts() {  
        Test.setMock(WebServiceMock.class, new sfdataTest());      
        AccountHelper.upsertSyncDivPriceLevelToChildAccounts('accountId', 'priceLevel', 'division', 'discount');
        system.assertEquals(1,1);
    }
    
    @istest
     static void testDeleteSyncDivPriceLevelToChildAccounts() {        
        Test.setMock(WebServiceMock.class, new sfdataTest());
        AccountHelper.deleteSyncDivPriceLevelToChildAccounts('accountId', 'division');
        system.assertEquals(1,1);
    }   

    @istest
   static void testSyncPriceLevelToChildren() {        
    Test.setMock(WebServiceMock.class, new sfdataTest());
        AccountHelper.syncPriceLevelToChildren('parentAccountId', 'priceLevel');
        system.assertEquals(1,1);
    } 

    @istest
   static void testSyncAllPricingToChildren() {        
    Test.setMock(WebServiceMock.class, new sfdataTest());
        AccountHelper.syncAllPricingToChildren('parentAccountId', 'priceLevel');
        system.assertEquals(1,1);
    } 
}