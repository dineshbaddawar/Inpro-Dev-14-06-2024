({
	doInit : function(component, event, helper) {
		
	},
    
    addManualAcct : function(component, event, helper) {
        var componentEvent = component.getEvent("ClickAccountResult");
        componentEvent.setParams({
            "AccountId" : component.get("v.AccountId")
        });
        componentEvent.fire();
    }
})