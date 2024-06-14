global class OpportunityRollupScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        OpportunityRollup opr = new OpportunityRollup();
         opr.Rollup();
          
     }
}