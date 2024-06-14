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
global class ConstructionProjectGeolocationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ConstructionProjectGeolocationBatch b = new ConstructionProjectGeolocationBatch();
        Database.executebatch(b);
    }
}