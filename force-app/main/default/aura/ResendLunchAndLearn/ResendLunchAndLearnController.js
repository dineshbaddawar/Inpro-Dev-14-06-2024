({
	doInit : function(component, event, helper) {
        helper.getEvent(component);
		helper.getAttendees(component);

        var initialTheme = component.get("v.userTheme");
        if(!initialTheme.length>0) {
            helper.getTheme(component);
        }
	},
    
    setResend : function(component, event, helper) {
        var inputCheckbox = evt.getSource().getLocalId();
        var inputValue = component.find(inputCheckbox);
        var outputCheckbox = component.find(inputCheckbox+'Output');
        outputCheckbox.set("v.value", ""+inputValue.get("v.value"));
    },

    cancelResend : function(component, event, helper) {
        var lunchEvent = component.get("v.lncLrnEvent");
		console.log('lunchEvent: ' + lunchEvent);
        console.log('lunchEvent Id: ' + lunchEvent["Id"]);
        helper.goToRecord(component, lunchEvent["Id"]);
    },

    completeResend : function(component, event, helper) {
        helper.doResend(component);
    },
    onselectAll: function(component, event, helper) {
        debugger;
        var checkCmp = component.find("selectAllCheckbox");
        if(checkCmp.get("v.value") == true){
            var attendees=component.get("v.attendees");
            for(var att in attendees)
                attendees[att].resend=true;
            component.set("v.attendees",attendees);
        }
        
    }
    
})