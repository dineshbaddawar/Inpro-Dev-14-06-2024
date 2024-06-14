@isTest
private class ExpediteProcessHelperTest {
    
    @isTest static void testIsValidApprover() {
        Boolean results = ExpediteProcessHelper.IsValidApprover('12345', '12345', 'Manager', '12345', '12345');
        Boolean results2 = ExpediteProcessHelper.IsValidApprover('12345', '12345', 'Requestor', '12345', '12345');
        Boolean results3 = ExpediteProcessHelper.IsValidApprover('12345', '12345', 'Expeditor', '12345', '12345');
    }

    @isTest static void testGetCurrentExpedite() {
        List<Expedite_Request__c> results = ExpediteProcessHelper.GetCurrentExpedite('12345');
    }

    @isTest static void testGetCurrentApprovalStep() {
        List<Expedite_Approval_Step__c> results = ExpediteProcessHelper.GetCurrentApprovalStep('12345');
    }

    @isTest static void testGetCurrentUser() {
        List<User> results = ExpediteProcessHelper.GetCurrentUser('12345');
    }

    @isTest static void testGetSupplierOptions() {
        List<Expedite_Supplier_Option__c> results = ExpediteProcessHelper.GetSupplierOptions('12345');
    }
}