global class ScheduleContractFollowUp implements Schedulable {
    global void execute(SchedulableContext SC) {
      ContractHelper ch = new ContractHelper();
      ch.contractFollowUp();    
     }
}