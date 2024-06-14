trigger ExpediteSupplierOptionTrigger on Expedite_Supplier_Option__c (after update) {
    for(Expedite_Supplier_Option__c supplierOption:Trigger.new)
    {
        Expedite_Supplier_Option__c oldSupplierOption = Trigger.oldMap.get(supplierOption.Id);

        if(supplierOption.Selected_Option__c != oldSupplierOption.Selected_Option__c)
        {
            List<Expedite_Request__c> expediteList =
            [SELECT NetSuite_ID__c
            FROM Expedite_Request__c
            WHERE Id = :supplierOption.Expedite_Request__c LIMIT 1];

            if(supplierOption.Selected_Option__c)
            {
                expediteList[0].Expedite_Fee_Amount__c = supplierOption.Cost__c + (supplierOption.Cost__c * 0.1);
                update expediteList;
            }

            ExpediteProcessHelper.UpdateNetSuiteSupplierOption(supplierOption.NetSuite_ID__c, supplierOption.Selected_Option__c, expediteList[0].NetSuite_ID__c, supplierOption.Cost__c);
        }
    }
}