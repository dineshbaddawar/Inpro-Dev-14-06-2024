@isTest
private class CreateExpediteRequestHelperTest {
    @isTest static void testGetOrderItems() {
        List<CreateExpediteRequestHelper.item> results = CreateExpediteRequestHelper.GetOrderItems('12345');
    }

    @isTest static void testManagerSearch() {
        List<LookupSearchResult> results = CreateExpediteRequestHelper.ManagerSearch('12345', '12345',new List<String>());
    }

    @isTest static void testCreateExpediteRequest() {
        CreateExpediteRequestHelper.SalesforceCreationResult results = CreateExpediteRequestHelper.CreateExpediteRequest('12345', false, false, '12345', Date.newInstance(2020, 2, 17), 'Submitted',
        '123456', 'IPC', true, 123, 'DW-EXPEDITE-2M | Manufacturing Expedite',
        'Test', 'Test Notes', 'New Expedite', '', Date.newInstance(2020, 2, 17), '1234567',
        true, Date.newInstance(2020, 2, 17), '1029382', 'Submitted', new List<CreateExpediteRequestHelper.item>(), 'Everett Leptich', '');
    }   
}