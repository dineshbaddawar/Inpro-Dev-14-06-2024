({
    doInit : function(component, event, helper) {
        var locale = $A.get("$Locale.language");
        helper.getEvent(component);
        helper.getStandardBodyWrapper(component);
    },
    closeEmailModal : function(component, event, helper) {
        component.set("v.showEmailModal",false);
    },
    createRegistration : function(component, event, helper) {
        var recordId = component.get("v.lunchandLearnId");
        var standardBody = component.get("v.StandardBodyList");
        var firstName = component.get("v.FirstName");
        var lastName = component.get("v.LastName");
        var EmailAddress = component.get("v.EmailAddress");
        var ProjectFollowUp = component.get("v.ProjectFollowUp");
        var OptIn = component.get("v.OptIn");
        var Company = component.get("v.Company");
        var landlRecord = component.get("v.lunchandLearnEventRecord");
        
        var isError = false;
        var errorMessage = $A.get("$Label.c.L_L_Required_Field_Error_Message")+'<br/>';
        if(firstName == '' || firstName == null){
            errorMessage = errorMessage + $A.get("$Label.c.L_L_First_Name")+'<br/>';
            isError =  true;
        }
        
        if(lastName == '' || lastName == null){
            errorMessage = errorMessage + $A.get("$Label.c.L_L_Last_Name")+ '<br/>';
            isError =  true;
        }
        
        if(landlRecord.IsAnotherLocation){
            if(Company == '' || Company == null){
                errorMessage = errorMessage +$A.get("$Label.c.L_L_Company")+ '<br/>';
                isError =  true;
            }
        }
        
        component.set("v.isError",isError);
        component.set("v.errorMessage",errorMessage);
        
        if(!isError){
            
            if(EmailAddress == '' || EmailAddress == null){
                isError =  true;
            }
            
            if(!isError){
                component.set("v.loading",true);
                var action = component.get("c.createNewAttendee");
                action.setParams({ 
                    "eventId" : recordId,
                    "FName" :firstName,
                    "LName" :lastName,
                    "Company":Company,
                    "EmailAddress" :EmailAddress,
                    "ProjectFollowUp" :ProjectFollowUp,
                    "OptIn" :OptIn,
                    "SBwrapperList" :standardBody,
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state == "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.isSuccess",true);
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
            else{
                component.set("v.showEmailModal",true);
            }
            
        }
    },
    nextRegistration : function(component, event, helper) {
        location.reload();
    },
    display : function(component, event, helper) {
        helper.toggleHelper(component, event);
    },
    
    displayOut : function(component, event, helper) {
        helper.toggleHelper(component, event);
    },
    createRegistrationWithoutEmail : function(component, event, helper) {
        component.set("v.loading",true);
        var recordId = component.get("v.lunchandLearnId");
        var standardBody = component.get("v.StandardBodyList");
        var firstName = component.get("v.FirstName");
        var lastName = component.get("v.LastName");
        var ProjectFollowUp = component.get("v.ProjectFollowUp");
        var OptIn = component.get("v.OptIn");
        var Company = component.get("v.Company");
        var landlRecord = component.get("v.lunchandLearnEventRecord");
        
        var action = component.get("c.createNewAttendee");
        action.setParams({ 
            "eventId" : recordId,
            "FName" :firstName,
            "LName" :lastName,
            "Company":Company,
            "EmailAddress" :'',
            "ProjectFollowUp" :ProjectFollowUp,
            "OptIn" :OptIn,
            "SBwrapperList" :standardBody,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isSuccess",true);
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