/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      Schedule class to run the batch class to 
*				send out emails.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
************************************************************/
global class scheduledBatchableEmailSend implements Schedulable{
    
    public static String sched = '0 0 * * * ?'; 
    global static String scheduleMe() {
        scheduledBatchableEmailSend sc = new scheduledBatchableEmailSend(); 
        return System.schedule('CertificateEmails Schedule job', sched, sc);
    }
    
    global void execute(SchedulableContext sc) {
        
        BatchSendCertificates batch = new BatchSendCertificates();
        Database.executeBatch(batch);          
    }
}