/*************************************************************
* Created by:   The Hunley Group
* Created on:   7/19/2018
* ===========================================================
* Test Class:   TBD
* =========================================================== 
* Purpose:      This class will schedule the AccountGeolocationBatch class.
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/19/2018     THG - PS        Created
************************************************************/
global class AccountGeolocationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountGeolocationBatch b = new AccountGeolocationBatch();
        Database.executebatch(b);
    }
}