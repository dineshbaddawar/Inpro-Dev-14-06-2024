global class ScheduledBatchSendCertificates implements Schedulable{
    
    public static String sched = '0 0 * * * ?'; 
    
    global static String scheduleMe() {
        ScheduledBatchSendCertificates sc = new ScheduledBatchSendCertificates(); 
        return System.schedule('CertificateEmails Schedule job', sched, sc);
    }
    
    global void execute(SchedulableContext sc) {
        
        BatchSendCertificates batch = new BatchSendCertificates();
        Database.executeBatch(batch);          
    }
}