trigger AccountSubReqTrigger on Account (before insert, before update, after insert, after update) {
    if(System.IsBatch() == false && System.isFuture() == false)
    {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            AccountSubReqTriggerHandler handler = new AccountSubReqTriggerHandler(trigger.New,trigger.newMap);
            handler.beforeInsert();
        } else if (trigger.isUpdate) {
            AccountSubReqTriggerHandler handler = new AccountSubReqTriggerHandler(trigger.NewMap, trigger.oldMap);
            handler.beforeUpdate();
        }
    } 
     else if(trigger.isAfter) {
        if(trigger.isInsert) {
            AccountSubReqTriggerHandler handler = new AccountSubReqTriggerHandler(trigger.new, trigger.newMap);
            handler.afterInsert();
        } 
    }
} 
}