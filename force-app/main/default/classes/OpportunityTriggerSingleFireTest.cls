@IsTest
public class OpportunityTriggerSingleFireTest {
    
    public static testmethod void testTriggerFlags () {

        // Before insert
        System.assertEquals(true, OpportunityTriggerSingleFire.isBeforeInsertFirstRun());
        System.assertEquals(false, OpportunityTriggerSingleFire.isBeforeInsertFirstRun());

        // Before update
        System.assertEquals(true, OpportunityTriggerSingleFire.isBeforeUpdateFirstRun());
        System.assertEquals(false, OpportunityTriggerSingleFire.isBeforeUpdateFirstRun());

        // After insert
        System.assertEquals(true, OpportunityTriggerSingleFire.isAfterInsertFirstRun());
        System.assertEquals(false, OpportunityTriggerSingleFire.isAfterInsertFirstRun());

        // After update
        System.assertEquals(true, OpportunityTriggerSingleFire.isAfterUpdateFirstRun());
        System.assertEquals(false, OpportunityTriggerSingleFire.isAfterUpdateFirstRun());
        
    }

}