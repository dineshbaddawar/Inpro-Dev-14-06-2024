@isTest
public with sharing class GlobalHelperTest {
    
    @isTest static void testGetEndPoints()
	{   
        System.assertNotEquals(GlobalHelper.GetTaxEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetAllocationServiceEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetDataWareHouseEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetInproRCAEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetSfDataEndpoint(), '');
		System.assertNotEquals(GlobalHelper.GetSharepointDocumentMangementEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetExpediteEndpoint(), '');
        System.assertNotEquals(GlobalHelper.GetEDIServiceEndpoint(), '');
	}
}