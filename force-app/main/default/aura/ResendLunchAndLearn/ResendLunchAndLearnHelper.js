({
	getEvent : function(component) {
		var eventRecord = component.get("v.recordId");
        component.set("v.loading",true);
        
        console.log('record Id: ' + recordId);
        console.log('getEvent Id: ' + eventRecord);
        var action = component.get("c.getLunchAndLearnEvent");
        action.setParams({ 
            "eventId" : eventRecord
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('get event response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('event result: ' + result);
                component.set("v.lncLrnEvent",result);
                console.log('finish get event');
            } else if (state === "ERROR") {
                console.log('get event response error');
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
		var eventRecord = component.get("v.recordId");
        component.set("v.loading",true);
        
        console.log('record Id: ' + recordId);
        console.log('getAttendee Id: ' + eventRecord);
        
        var action = component.get("c.getAttendees");
        action.setParams({ 
            "eventId" : eventRecord
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            debugger;
            console.log('get attendees response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var results = response.getReturnValue();
                console.log('attendees result: ' + results);
                component.set("v.attendees",results);
                console.log('finish get attendees');
            } else if (state === "ERROR") {
                console.log('get attendees response error');
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

    getTheme : function(component) {
        console.log('get theme');
        
        var action = component.get("c.getUIThemeDescription");
        action.setCallback(this, function(response) {
            console.log('theme callback');
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log('theme: ' + response.getReturnValue());
                component.set("v.userTheme", response.getReturnValue());
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
        });
        $A.enqueueAction(action);
    },

    doResend : function(component) {
        component.set("v.classicMessage", null);
        var attendees = component.get("v.attendees");
        var recordId = component.get("v.lncLrnEvent")["Id"];

        component.set("v.loading",true);
        var myUserContext = component.get("v.userTheme");
        
        var action = component.get("c.doEventLevelResend");
        action.setParams({ 
            "attendeeListJSON" : JSON.stringify(attendees)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('resend attendees response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('resend attendees result: ' + result);

                if(result === 'Certificates confirmed and emails resent successfully.') {

                    if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                        console.log('lightning success: ' + result);
                    //if (myUserContext == 'Theme4t') {
                        // The Visualforce page is in S1 or Lightning Experience
                        //sforce.one.navigateToSObject(component.get("v.recordId"));
                        var toastEvent = $A.get("e.force:showToast");
                        //debugger;
                        console.log('TE: ' + toastEvent);
                        if (toastEvent === undefined) {
                            component.set("v.classicMessage", result);
                            var urlEvent = $A.get("e.force:navigateToURL");
                            if (urlEvent === undefined) {
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        window.location = '/' + recordId;
                                    }), 5000
                                );
                            }
                            else{
                                urlEvent.setParams({
                                    "url": "/" + recordId
                                });
                                urlEvent.fire();
                            }
                           
                        } else {
                            toastEvent.setParams({
                                "title": "Resend Successful!",
                                "type": "success",
                                "message": result
                            });
                            toastEvent.fire();
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
                        
                    } else if (myUserContext == 'Theme3') {
                        console.log('classic success: ' + result);
                        component.set("v.classicMessage", result);

                        window.setTimeout(
                            $A.getCallback(function() {
                                window.parent.location = '/' + recordId;
                            }), 5000
                        );
                        // The Visualforce page is  running in Classic
                    } else {
                        component.set("v.classicMessage", result);

                        console.log("Unsupported theme");  
                        window.setTimeout(
                            $A.getCallback(function() {
                                window.parent.location = '/' + recordId;
                            }), 5000
                        );
                    }
                } else {
                    if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                    //if (myUserContext == 'Theme4t') {
                        // The Visualforce page is in S1 or Lightning Experience
                        //sforce.one.navigateToSObject(component.get("v.recordId"));
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent === undefined) {
                            component.set("v.classicMessage", result);
                            var urlEvent = $A.get("e.force:navigateToURL");
                            if (urlEvent === undefined) {
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        window.location = '/' + recordId;
                                    }), 5000
                                );
                            }
                            else{
                                urlEvent.setParams({
                                    "url": "/" + recordId
                                });
                                urlEvent.fire();
                            }
                            
                        } else {
                            toastEvent.setParams({
                                "title": "Error",
                                "type": "error",
                                "message": result
                            });
                            toastEvent.fire();
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
                       
                        component.set("v.classicMessage", result);
                    } else if (myUserContext == 'Theme3') {
                        component.set("v.classicMessage", result);
                        // The Visualforce page is  running in Classic
                    } else {
                        component.set("v.classicMessage", result);
                    }
                }

                console.log('finish resend attendees');
            } else if (state === "ERROR") {
                console.log('resend attendees response error');
                var errors = response.getError();
                if (errors) {
                    console.log('error check');
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }

                    console.log('theme: ' + myUserContext);
                    if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                    //if (myUserContext == 'Theme4t') {
                        // The Visualforce page is in S1 or Lightning Experience
                        //sforce.one.navigateToSObject(component.get("v.recordId"));
                        var toastEvent = $A.get("e.force:showToast");
                        
                        if (toastEvent === undefined) {
                            component.set("v.classicMessage", message);
                            var urlEvent = $A.get("e.force:navigateToURL");
                            if (urlEvent === undefined) {
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        window.location = '/' + recordId;
                                    }), 5000
                                );
                            }
                            else{
                                urlEvent.setParams({
                                    "url": "/" + recordId
                                });
                                urlEvent.fire();
                            }
                            
                        } else {
                            toastEvent.setParams({
                                "title": "Error",
                                "type": "error",
                                "message": message
                            });
                            toastEvent.fire();
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
                    } else if (myUserContext == 'Theme3') {
                        console.log('set message: ' + message);
                        component.set("v.classicMessage", message);
                        // The Visualforce page is  running in Classic
                    } else {
                        component.set("v.classicMessage", message);
                    }
                }
            }
            component.set("v.loading",false);
        });
        $A.enqueueAction(action);
    }, 

    goToRecord : function(component, recordId) {
        var myUserContext = component.get("v.userTheme");
        console.log('theme: ' + myUserContext);
        console.log('id: ' + recordId);
        if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            // The Visualforce page is in S1 or Lightning Experience
            //sforce.one.navigateToSObject(component.get("v.recordId"));
            console.log("Lightning theme");  
          /*  var urlEvent = $A.get("e.force:navigateToURL");
             urlEvent.setParams({
                "url": "/" + recordId
            });
            urlEvent.fire();*/
            
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
            // The Visualforce page is  running in Classic
            window.parent.location = '/' + recordId;
        } else {
            console.log("Unsupported theme");  
            window.parent.location = '/' + recordId; 
        }
    }
})