trigger SignSchedulePostCreate on Sign_Schedule__c (after insert) {

    if (Trigger.isAfter) {
        for(Sign_Schedule__c s : Trigger.New) {
            
            if(s.OriginatingSignScheduleId__c != null)
            {
                List<Sign_Schedule_Item__c> signScheduleItems = 
                [SELECT Index__c, Line10Font__c, Line10__c, Line11Font__c, Line11__c, Line12Font__c,
                        Line12__c, Line13Font__c, Line13__c, Line14Font__c, Line14__c, Line15Font__c,
                        Line15__c, Line16Font__c, Line16__c, Line17Font__c, Line17__c, Line18Font__c, Line18__c,
                        Line19Font__c, Line19__c, Line1Font__c, Line1__c, Line20Font__c, Line20__c, Line2Font__c, Line2__c, Line3Font__c, 
                        Line3__c, Line4Font__c, Line4__c, Line5Font__c, Line5__c, Line6Font__c, Line6__c, Line7Font__c, Line7__c, 
                        Line8Font__c, Line8__c, Line9Font__c, Line9__c,  Missing_Configuration_Info__c, 
                        PictoURL__c, SavedReferenceID__c, SavedToCRM__c,  Text_Too_Tall__c, Text_Too_Wide__c,Formatted_Sign_Schedule__c
                FROM Sign_Schedule_Item__c
                WHERE SignScheduleId__c = :s.OriginatingSignScheduleId__c];

                List<Sign_Schedule_Item__c> newSSIList = new List<Sign_Schedule_Item__c>();

                for (Sign_Schedule_Item__c ssi : signScheduleItems) {
                    ssi.id = null;
                    ssi.SignScheduleId__c = s.Id;
                    newSSIList.add(ssi);
                }

                insert newSSIList;

            }            
        }
    }
}