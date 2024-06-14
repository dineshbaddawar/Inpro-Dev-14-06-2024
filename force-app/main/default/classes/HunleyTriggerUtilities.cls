/************************************************************
* Created by:   The Hunley Group
* Created on:   7/7/2020
* ===========================================================
* Test Class:
* ===========================================================
* Purpose:
*   Basic Trigger Utilities for avoiding recursion and checking if trigger is disabled
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/7/2020       THG - JP       Created 
*************************************************************/
public with sharing class HunleyTriggerUtilities {
    
    private static Map<String, boolean> tracker = new Map<String, boolean>();
    
    public static boolean runOnce(String triggerName){
        if (tracker.containsKey(triggerName)) {
            system.debug('CheckRecursive: Returning FALSE for - ' + triggerName);
            return false;
        }
        tracker.put(triggerName, true);
        return true;
    }
    
    // Use this to bypass the runOnce restriction (primarily useful in test classes where the trigger is executed many times in the
    // transaction scope
    public static void resetRun(String triggerName) {
        if (tracker.containsKey(triggerName)) {
            tracker.remove(triggerName);
        }
    }
}