public with sharing class NewConstructionProjectHelper 
{
    @AuraEnabled
    public static string CreateConstructionProject(string jsonFields){
        Construction_Project__c cp = (Construction_Project__c)JSON.deserialize(jsonFields,Construction_Project__c.class);

        insert cp;

        return cp.Id;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> ContactFilterSearch(String searchTerm, String accountId) {
        if (accountId == '' || accountId == null)
        {
            return new List<LookupSearchResult>();
        }
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:contact';
        List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE AccountId = :accountId AND Name LIKE :key LIMIT 50];

        for (Contact contact : contacts) {

            String fullname = contact.Name;
            String id = contact.Id;
            String subtitle = contact.Email;
                
            results.add(new LookupSearchResult(id, 'contact', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> TerritorySearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';
        List<Territory__c> territories = [SELECT Id, Name, Area__c FROM Territory__c WHERE Name LIKE :key LIMIT 50];

        for (Territory__c territory : territories) {

            String fullname = territory.Name;
            String id = territory.Id;
            String subtitle = territory.Area__c;
                
            results.add(new LookupSearchResult(id, 'territory', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List<String> GetPicklistValues(string objectName, string fieldName){
        return picklist_values(objectName,fieldName);
    }

    @AuraEnabled
    public static List<String> GetDependentPicklistValues(string objectName, string fieldName, string value){

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        Schema.SObjectField objectField = mfields.get(fieldName);
        Map<String,List<String>> allValues = getDependentPicklistValues(objectField);
        return allValues.get(value);
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

    private static String getPicklistValue(String object_name, String field_name, String label)
    {
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive() && entry.getLabel() == label) return entry.getValue();
            }
        }
        return '';
    }

    //Copied from https://salesforceprofs.com/how-to-get-dependent-picklist-values-in-apex/
    private static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
}