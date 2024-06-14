trigger SampleRequestItemPostCreate on Sample_Request_Item__c (after insert) {
    if(Trigger.isAfter) 
    { 
        if(Trigger.New.size() > 0)
        {
            Sample_Request_Item__c s = Trigger.New[0];
            List<Sample_Request__c> srList = [SELECT Lead__c, Contact__c, Type__c FROM Sample_Request__c WHERE Id = :s.Sample_Request__c LIMIT 1];
            List<Product2> spList = [SELECT Campaign__c, Family FROM Product2 WHERE Id = :s.Sample_Product__c LIMIT 1];

            if(spList != null && srList != null &&  spList.size() > 0 && srList.size() > 0)
            {

                    Product2   sp = spList[0];
                    Sample_Request__c   sr = srList[0];
            
                if(sp.Campaign__c != null &&   sr.Type__c == 'Web Request' && 
                (sp.Family == 'Literature' || sp.Family == 'Color Sample'|| sp.Family == 'Samples' || sp.Family == 'Fabric Sample'))
                {
                    if(sr.Lead__c != null)
                    {
                        //Lead__c //Contact__c
                        List<CampaignMember> campaignMembers =  [SELECT LeadId, CampaignId
                            FROM CampaignMember
                            WHERE LeadId = :sr.Lead__c
                            AND CampaignId = :sp.Campaign__c LIMIT 1];
                            if(campaignMembers == null || campaignMembers.size() == 0)
                            {
                                try 
                                {
                                    CampaignMember cm = new CampaignMember();
                                    cm.LeadId = sr.Lead__c;
                                    cm.CampaignId = sp.Campaign__c;
                                    cm.Status = 'Connected';
                                    insert cm;
                                }
                                 catch (Exception ex) 
                                {
                                    system.debug(ex.getMessage() + ex.getStackTraceString());
                                }
                            }
                    }

                    if(sr.Contact__c != null)
                    {
                        //Lead__c //Contact__c
                        List<CampaignMember> campaignMembers =  [SELECT LeadId, CampaignId
                            FROM CampaignMember
                            WHERE ContactId = :sr.Contact__c AND CampaignId = :sp.Campaign__c LIMIT 1];
                            if(campaignMembers == null ||campaignMembers.size() == 0)
                            {
                                try
                                {
                                    CampaignMember cm = new CampaignMember();
                                    cm.ContactId = sr.Contact__c;
                                    cm.CampaignId = sp.Campaign__c;
                                    cm.Status = 'Connected';
                                    insert cm;
                                }
                                catch (Exception ex) 
                                {
                                    system.debug(ex.getMessage() + ex.getStackTraceString());
                                }
                            }
                    }
                }
            }
        }
    }
}