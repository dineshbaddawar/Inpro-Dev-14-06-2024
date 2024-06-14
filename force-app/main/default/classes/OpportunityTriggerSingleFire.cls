/************************************************************
* Created by:   Allium
* Created on:   7/21/2022
* ===========================================================
* Test Class:   OpportunityTriggerSingleFireTest
* ===========================================================
* Purpose:      Contains flags for each context of the OpportunityTrigger
*               to be read at runtime, in order to prevent duplicate
*               execution.
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/21/2022     Allium - Joe B  Created
*************************************************************/

public without sharing class OpportunityTriggerSingleFire {
    
    private static Boolean firstBeforeInsertRun  = true;
    private static Boolean firstBeforeUpdateRun  = true;
    private static Boolean firstAfterInsertRun   = true;
    private static Boolean firstAfterUpdateRun   = true;

    public static Boolean isBeforeInsertFirstRun () {
        if (firstBeforeInsertRun) {
            firstBeforeInsertRun = false;
            return true;
        }
        else {
            return false;
        }
    }

    public static Boolean isBeforeUpdateFirstRun () {
        if (firstBeforeUpdateRun) {
            firstBeforeUpdateRun = false;
            return true;
        }
        else {
            return false;
        }
    }

    public static Boolean isAfterInsertFirstRun () {
        if (firstAfterInsertRun) {
            firstAfterInsertRun = false;
            return true;
        }
        else {
            return false;
        }
    }

    public static Boolean isAfterUpdateFirstRun () {
        if (firstAfterUpdateRun) {
            firstAfterUpdateRun = false;
            return true;
        }
        else {
            return false;
        }
    }

}