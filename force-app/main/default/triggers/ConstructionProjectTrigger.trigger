trigger ConstructionProjectTrigger on Construction_Project__c (before insert,before update,after insert,after update) {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            ConstructionProjectTriggerHandler handler = new ConstructionProjectTriggerHandler(trigger.New,trigger.newMap);
            handler.beforeInsert();
        } 
        else if (trigger.isUpdate) {
            ConstructionProjectTriggerHandler handler = new ConstructionProjectTriggerHandler(trigger.NewMap, trigger.oldMap);
            handler.beforeUpdate();
        }
    } 
    else if(trigger.isAfter) {
        if(trigger.isInsert) {
            ConstructionProjectTriggerHandler handler = new ConstructionProjectTriggerHandler(trigger.new,trigger.newMap);
            handler.afterInsert();
        }
    } 
}