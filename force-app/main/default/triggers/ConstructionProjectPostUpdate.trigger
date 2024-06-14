trigger ConstructionProjectPostUpdate on Construction_Project__c (after update) {

    for(Construction_Project__c c : Trigger.New) {        
        Construction_Project__c oldConstructionProject = Trigger.oldMap.get(c.Id);        
        if (Trigger.isUpdate) {      
            if (oldConstructionProject.Internal_Project_Folder_c__c != c.Internal_Project_Folder_c__c)
            {
                List<Opportunity> opps = [SELECT Id, Internal_Project_Folder__c FROM Opportunity WHERE Construction_Project__c = :c.Id];
                if (opps.size() > 0)
                {
                    for(Opportunity o : opps)
                    {
                        //Only update opportunity value if it didn't have one or it had the same old value from the CP
                        if(o.Internal_Project_Folder__c == '' || 
                           o.Internal_Project_Folder__c == oldConstructionProject.Internal_Project_Folder_c__c)
                        {
                            o.Internal_Project_Folder__c = c.Internal_Project_Folder_c__c;
                        }
                    }
                    update opps;
                }
            } 
            if ((c.ZIP__c != null && c.ZIP__c != oldConstructionProject.ZIP__c) 
                ||
                (c.Country__c != null &&  c.Country__c != oldConstructionProject.Country__c)
                ||
                (c.State_Code__c != null && c.State_Code__c != oldConstructionProject.State_Code__c) ){ //Capture international changes
                    if (!Test.isRunningTest() && System.IsBatch() == false && System.isFuture() == false) 
                        TerritoryHelper.updateRecordTerritory('Construction_Project__c', c.Id, c.ZIP__c, c.State_Code__c,c.Country_Code__c);
            }
            Construction_Project__c oldCP = Trigger.oldMap.get(c.Id);

            if(c.Zip__c != oldCP.Zip__c && c.Zip__c != null && c.Zip__c != '')
                AddressValidationHelper.ZipCodeLookupFuture(c.Zip__c, 'construction_project__c', c.Id);

            if (c.HCA_Project_Number__c != oldCP.HCA_Project_Number__c ||
            c.A_E_Project_Number__c != oldCP.A_E_Project_Number__c)
            {
                List<Opportunity> opps = [SELECT Id, HCA_Project_Number__c, Construction_Project__c 
                                          FROM Opportunity
                                          WHERE Construction_Project__c = :c.Id];

                List<Opportunity> oppsToUpdate = new List<Opportunity>();
                for(Opportunity o : opps)
                {
                    o.HCA_Project_Number__c = c.HCA_Project_Number__c;
                    o.A_E_Project_Number__c = c.A_E_Project_Number__c;
                    oppsToUpdate.add(o);                    
                }
                update oppsToUpdate;
            }
        }
    }
}