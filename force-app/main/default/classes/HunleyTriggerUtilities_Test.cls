/************************************************************
* Created by:   The Hunley Group
* Created on:   7/22/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/22/2020       THG - JP    Created
*************************************************************/
@IsTest
private class HunleyTriggerUtilities_Test {
    @IsTest
    static void testBehavior() {

        String triggerName = 'LunchAndLearnEventTrigger';

        System.assert(HunleyTriggerUtilities.runOnce(triggerName) == true);
        
        System.assert(HunleyTriggerUtilities.runOnce(triggerName) == false);

        HunleyTriggerUtilities.resetRun(triggerName);
        System.assert(HunleyTriggerUtilities.runOnce(triggerName) == true);


    }
}