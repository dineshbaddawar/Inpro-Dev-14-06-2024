({
    doInit : function(component, event, helper) {
        helper.getEvent(component);
        helper.getAttendees(component);
    },
    markAttended : function(component, event, helper) {
        component.set("v.loading",true);
        var clickedAttendeeId= event.currentTarget.dataset.id;
        var attended = event.currentTarget.checked;
        
        var action = component.get("c.updateAttendance");
        action.setParams({ 
            "attendeeId" : clickedAttendeeId,
            "attended": attended
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var results = response.getReturnValue();
                helper.getAttendees(component);
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
    goBackToRecord : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var myUserContext = component.get("v.userTheme");
        if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            var urlEvent = $A.get("e.force:navigateToURL");
            if (urlEvent === undefined) {
                window.location = '/' + recordId;
            }
            else{
                urlEvent.setParams({
                    "url": "/" + recordId
                });
                urlEvent.fire();
            }
        } 
        else if (myUserContext == 'Theme3') {
            window.location = '/' + recordId;
        } else {
            window.location = '/' + recordId;
        }
    }
})