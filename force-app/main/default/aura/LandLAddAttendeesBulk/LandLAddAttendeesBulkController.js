({
    doInit : function(component, event, helper) {
        helper.getEventAttendees(component);
        helper.getEvent(component);
    },
    editRow : function(component, event, helper) {
        var clickedAttendeeId= event.currentTarget.dataset.id;
        clickedAttendeeId = clickedAttendeeId.replace('Edit','');
        
        var attendeeList = component.get("v.attendeeList");
        for(var i=0;i<attendeeList.length;i++){
            if(attendeeList[i].AttendeeId == clickedAttendeeId){
                attendeeList[i].EditOrSave = true;
                break;
            }
        }
        component.set("v.attendeeList",attendeeList);
    },
    addNewRow : function(component, event, helper) {
        
        var eventRecord = component.get("v.lunchandLearnId");
        component.set("v.loading",true);
        var action = component.get("c.addRow");
        action.setParams({ 
            "eventId" : eventRecord
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                var attendeeList = component.get("v.attendeeList");
                attendeeList.push(result);
                component.set("v.attendeeList",attendeeList);
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
    saveRow : function(component, event, helper) {
        var clickedAttendeeId= event.currentTarget.dataset.id;
        clickedAttendeeId = clickedAttendeeId.replace('Save','');
        var attendeeList = component.get("v.attendeeList");
        var attendee;
        var index=0;
        for(var i=0;i<attendeeList.length;i++){
            if(attendeeList[i].AttendeeId == clickedAttendeeId){
                attendee =attendeeList[i];
                index = i+1;
                break;
            }
        }
        
        var isError = false;
        var errorMessage = $A.get("$Label.c.L_L_Bulk_Attendee_Required_Field_Error_Message")+' '+index+' :<br/>';
        if(attendee.FirstName == '' || attendee.FirstName == null){
            errorMessage = errorMessage  + $A.get("$Label.c.L_L_First_Name")+'<br/>';
            isError =  true;
        }
        
        if(attendee.LastName == '' || attendee.LastName == null){
            errorMessage = errorMessage  + $A.get("$Label.c.L_L_Last_Name")+'<br/>';
            isError =  true;
        }
        
        if(attendee.EmailAddress == '' || attendee.EmailAddress == null){
            errorMessage = errorMessage  + $A.get("$Label.c.L_L_Email")+'<br/>';
            isError =  true;
        }
        
        component.set("v.isError",isError);
        component.set("v.errorMessage",errorMessage);
        
        if(!isError){
            component.set("v.loading",true);
            
            var action = component.get("c.editAttendee");
            action.setParams({ 
                "attendee" : attendee
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == "SUCCESS") {
                    var result = response.getReturnValue();
                    helper.getEventAttendees(component);
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
        }
      
        
    },
    saveNewRow: function(component, event, helper) {
        var index = event.currentTarget.dataset.id;
        index = index.replace('-index','');
        var attendeeList = component.get("v.attendeeList");
        var attendee = attendeeList[parseInt(index)];
        var recordId = component.get("v.lunchandLearnId");
        
        
        var row = parseInt(index)+1;
        var isError = false;
        var errorMessage = $A.get("$Label.c.L_L_Bulk_Attendee_Required_Field_Error_Message")+' '+index+' :<br/>';
        if(attendee.FirstName == '' || attendee.FirstName == null){
            errorMessage = errorMessage + $A.get("$Label.c.L_L_First_Name")+'<br/>';
            isError =  true;
        }
        
        if(attendee.LastName == '' || attendee.LastName == null){
            errorMessage = errorMessage + $A.get("$Label.c.L_L_Last_Name")+'<br/>';
            isError =  true;
        }
        
        if(attendee.EmailAddress == '' || attendee.EmailAddress == null){
            errorMessage = errorMessage + $A.get("$Label.c.L_L_Email")+'<br/>';
            isError =  true;
        }
        
        component.set("v.isError",isError);
        component.set("v.errorMessage",errorMessage);
        
        if(!isError){
            component.set("v.loading",true);
            
            var action = component.get("c.createNewAttendee");
            action.setParams({ 
                "attendee" : attendee,
                "eventId" : recordId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == "SUCCESS") {
                    var result = response.getReturnValue();
                    helper.getEventAttendees(component);
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
        }
    },
    CancelEdit : function(component, event, helper) {
        /*var clickedAttendeeId= event.currentTarget.dataset.id;
        clickedAttendeeId = clickedAttendeeId.replace('Cancel','');
        
        var attendeeList = component.get("v.attendeeList");
        for(var i=0;i<attendeeList.length;i++){
            if(attendeeList[i].AttendeeId == clickedAttendeeId){
                attendeeList[i].EditOrSave = false; 
                break;
            }
        }
        component.set("v.attendeeList",attendeeList);*/
        helper.getEventAttendees(component);
    },
    deleteRow : function(component, event, helper) {
        var clickedAttendeeId= event.currentTarget.dataset.id;
        clickedAttendeeId = clickedAttendeeId.replace('Delete','');
        
        component.set("v.loading",true);
            
            var action = component.get("c.deleteAttendee");
            action.setParams({ 
                "attendeeId" : clickedAttendeeId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == "SUCCESS") {
                    var result = response.getReturnValue();
                    helper.getEventAttendees(component);
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

})