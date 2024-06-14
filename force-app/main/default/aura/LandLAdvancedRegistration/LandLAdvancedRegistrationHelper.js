({
    getEvent : function(component) {
        var recordId = component.get("v.recordId");
        component.set("v.loading",true);
        
        var action = component.get("c.getLunchAndLearnEvent");
        action.setParams({ 
            "eventId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.landlEventRecord",result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
            }
            component.set("v.loading",false);
        });
        $A.enqueueAction(action);
    },
    
    getAttendees : function(component) {
        var recordId = component.get("v.recordId");
        component.set("v.loading",true);
        var action = component.get("c.getAttendees");
        action.setParams({ 
            "eventId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var results = response.getReturnValue();
                component.set("v.attendees",results);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
            }
            component.set("v.loading",false);
        });
        $A.enqueueAction(action);
    },
    
})