({
    getEvent : function(component) {
        var recordId = component.get("v.lunchandLearnId");
        component.set("v.loading",true);
        
        var action = component.get("c.getLunchAndLearnEvent");
        action.setParams({ 
            "eventId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.lunchandLearnEventRecord",result);
                component.set("v.isEventPast",!result.IsOngoing);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var message = $A.get("$Label.c.L_L_Resend_Certificate_Error_Message");
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = $A.get("$Label.c.L_L_Resend_Certificate_Error_Message");
                    }
                    component.set("v.isError",true);
                    component.set("v.errorMessage",message);
                }
            }
            component.set("v.loading",false);
        });
        $A.enqueueAction(action);
    },
    getStandardBodyWrapper : function(component) {
        var recordId = component.get("v.lunchandLearnId");
        component.set("v.loading",true);
        
        var action = component.get("c.getStandardBodyWrapper");
        action.setParams({ 
            "eventId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.StandardBodyList",result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var message = $A.get("$Label.c.L_L_Resend_Certificate_Error_Message");
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = $A.get("$Label.c.L_L_Resend_Certificate_Error_Message");
                    }
                    component.set("v.isError",true);
                    component.set("v.errorMessage",message);
                }
            }
            component.set("v.loading",false);
        });
        $A.enqueueAction(action);
    },
    toggleHelper : function(component,event) {
        var toggleText = component.find("tooltip");
        $A.util.toggleClass(toggleText, "toggle");
    }
})