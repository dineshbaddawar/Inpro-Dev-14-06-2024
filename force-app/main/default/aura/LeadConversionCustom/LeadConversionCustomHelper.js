({
    getUser : function(component, event, helper) {
        //debugger;
        var action=component.get("c.getUser");
        action.setCallback(this, function(a){ 
            component.set("v.Userstring", a.getReturnValue());
        });
        $A.enqueueAction(action); 
    }, 
    
    
    getRecordTypes : function(component, event, helper) {
        var getRecordTypes=component.get("c.getRecordTypes");
        getRecordTypes.setParams({
            leadId : component.get("v.recordId")
        });
        
        getRecordTypes.setCallback(this, function(a){
            //debugger;
            component.set("v.AccountRecordTypes", a.getReturnValue().AccountRecTypes);
            component.set("v.ContactRecordTypes", a.getReturnValue().ContactRecTypes);
            component.set("v.AccountRecordType", a.getReturnValue().defAccRecType);
            component.set("v.ContactRecordType", a.getReturnValue().defConRecType);
            console.log(a.getReturnValue());
        });
        $A.enqueueAction(getRecordTypes); 
        
    }, 
    
    
    getStageValues : function(component, event, helper) {
        var action1 = component.get("c.getStageValues");   
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var custs = [];
                var conts = response.getReturnValue();
                for ( var key in conts ) {
                    custs.push({value:conts[key], key:key});
                }
                component.set("v.StatusList", custs);
               
                
                window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our preferred value
                        component.find("status").set("v.value","Converted");
                        component.set("v.Status", "Converted");
                    }));
                
            } 
        });           
        $A.enqueueAction(action1); 
    }, 
    
    populatefields: function(component, event, helper) {
        //debugger;
        var action1 = component.get("c.getLeadDetails");   
        action1.setParams({
                leadId : component.get("v.recordId")
            });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var response = response.getReturnValue();
                
                if(response.marketSegment ==null ||response.accountRecordType == null){
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       				 "title": "Validation Error!",
                     "type" : 'error',
        			"message": "'Market Segment' and 'Account Record Type To Create' fields are required to convert the lead"
    				});
    				toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                
                if(response.marketSegment =='Hospitality' && response.ultimateParentAccount == null && response.nationalTerritory == null ){
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       				 "title": "Validation Error!",
                     "type" : 'error',
        			"message": "National Territory is required for a Hospitality Account without an Ultimate Parent. Either add a Parent Account to this record or select a National Territory."
    				});
    				toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
        
                component.set("v.accountName", response.accountName);
                component.set("v.contactName", response.contactName);
                component.set("v.contactFirstName", response.contactFirstName);
                component.set("v.contactLastName", response.contactLastName);
                component.set("v.contactEmail", response.contactEmail);
                component.set("v.contactPhone", response.contactPhone);
                component.set("v.contactTitle", response.contactTitle);
                
                component.set("v.accBillingStreet", response.accountBillingStreet);
                component.set("v.accBillingCity", response.accountBillingCity);
                component.set("v.accBillingState", response.accountBillingState);
                component.set("v.accBillingPostalCode", response.accountBillingPostalCode);
                component.set("v.accBillingCountry", response.accountBillingCountry);
                component.set("v.accPhone", response.accountPhone);
                component.set("v.accFax", response.accountFax);
                component.set("v.accWebsite", response.accountWebsite);
            } 
        });           
        $A.enqueueAction(action1); 
    },
    
   
    getDuplicates: function(component, event, helper) {
        //debugger;
        var action1 = component.get("c.allowDuplicates");   
        action1.setParams({
            leadId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var response = response.getReturnValue();
                component.set("v.dupContactsList", response.contactDupList);
                component.set("v.dupAccountsList", response.accountDupList);
                component.set("v.AllowAccountDupes", response.allowAccDupe);
                component.set("v.AllowContactDupes", response.allowAccDupe);
            } 
        });           
        $A.enqueueAction(action1); 
    },

    getCustomObjects: function(component, event, helper) {
        //debugger;
        var action1 = component.get("c.getCustomObjectsFromMetadata");
        action1.setParams({
            leadId : component.get("v.recordId"),
            selFilter:component.get("v.selectedFilter"),
            useFilter:component.get("v.useFilters")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var response = response.getReturnValue();
                component.set("v.customObjects", response);
                helper.initCustomObjects(component, event, helper);
                if (response != null && response.length > 0) {
                    helper.turnOnSpinner(component, event, helper);
                    console.log('received custom objects:');
                    console.log(JSON.stringify(response));
                } else {
                    helper.turnOffSpinner(component, event, helper);
                }
            } else if (state === "ERROR") {
              console.log("Response of ERROR receieved from controller on getCustomObjectsFromMetadata.  Error info follows (if provided):")
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      console.log("Error message: " +
                               errors[0].message);
                  }
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      "title": "Field error:",
                      "message": errors[0].message
                  });
                  toastEvent.fire();
              }
           } else {
                console.log("There was a bad response from the controller on getCustomObjectsFromMetadata.  JSON as follows:");
                console.log(JSON.stringify(response));
           }
        });           
        $A.enqueueAction(action1); 
    },
    
    getFilters: function(component, event, helper) {
        //debugger;
        var action1 = component.get("c.getFilterWrapper");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var response = response.getReturnValue();
                component.set("v.useFilters", response.useFilter);
                if(response.useFilter == true){
                    component.set("v.filters", response.filterValues);
                    component.set("v.selectedFilter", response.defaultFilter);
                    component.set("v.filterLabel", response.filterLabel);
                }
                helper.getCustomObjects(component,event,helper);
            } 
        });           
        $A.enqueueAction(action1); 
    },

    // purpose of this is to tag custom objects with isLoaded, isSubmitted and isCreate properties
    // as well as setup the component to be in a proper 'loading' state:
    initCustomObjects: function(component, event, helper) {

        var cusObjs = component.get("v.customObjects");

        cusObjs.forEach(c => {
           c.isLoaded = false;
           c.isSubmitted = false;
          // c.isCreate = true;
        });

        //var cusObjs = component.set("v.customObjects");
    },

    processIsLoaded: function(component,event,helper){
        var cusObjs = component.get("v.customObjects");
        var passed = true;

        cusObjs.forEach(c => {
           if (!c.isLoaded) {
               passed = false;
           }
        });

        console.log('processIsLoaded: ' + passed);
        if (passed) {
            helper.turnOffSpinner(component, event, helper);
        }
        component.set("v.isFullyLoaded", passed);
    },

    processIsFullySubmitted: function(component, event, helper) {
        var complete = true;  // default to true and test scenarios:

        if (component.get("v.isAccountContactComplete") == false) {
            complete = false;
        } else {
            var customObjects = component.get("v.customObjects");
            customObjects.forEach(c => {
                if (c.isCreate) {  // if we are even creating this object
                    if (c.isSubmitted == false) {
                        complete = false;
                    }
                }
            });
        }

        console.log('helper.processIsFullySubmitted(): ' + complete);
        if (complete) {
            // turn off our spinner:
            helper.turnOffSpinner(component, event, helper);
            component.set('v.isFullySubmitted', complete);
        } else { // else, keep our submissions going:
            helper.handleSavingCustomObjects(component, event, helper);
        }
    },

    getCustomObjectFromLabel: function(component, event, helper, label) {
        // resolve our custom form we are dealing with:
        var cusObj = null;
        var cusObjs = component.get("v.customObjects");

        cusObjs.forEach(c => {
           if (c.Label == label) {
               cusObj = c;
           }
        });
        return cusObj;
    },

    processLoadedCallback: function(component, event, helper) {
        var cusObj = helper.getCustomObjectFromLabel(component, event, helper, event.getParam('componentLabel'));
        cusObj.isLoaded = true;
        console.log("in processLoadedCallback for: " + cusObj.Label);

        helper.processIsLoaded(component, event, helper);
    },

    processSubmittedCallback: function(component, event, helper) {
        var cusObj = helper.getCustomObjectFromLabel(component, event, helper, event.getParam('componentLabel'));
        console.log("in processSubmittedCallback for: " + cusObj.Label);
        cusObj.isSubmitted = true;  // flag our object as submitted

        // add object to our completed objects list (this is important for summary screen as well as handling dependencies)
        var created = {
                 Id: event.getParam('recordId'),
                 objName: cusObj.ObjectAPIName,
                 Name: cusObj.Label
             };
        helper.appendCreatedObject(component, event, helper, created);

        helper.processIsFullySubmitted(component, event, helper);
    },

    processErrorCallback: function(component, event, helper) {
        var cusObj = helper.getCustomObjectFromLabel(component, event, helper, event.getParam('componentLabel'));
        console.log("in processErrorCallback for: " + cusObj.Label);
        // in error, turn off our spinner so user can return to their component:
        helper.turnOffSpinner(component, event, helper);
        helper.scrollToTop(component, event, helper);
    },

    turnOnSpinner: function(component,event,helper){
        component.set("v.showSpinner", true);
    },

    turnOffSpinner: function(component,event,helper){
        component.set("v.showSpinner", false);
    },

    appendCreatedObject : function(component, event, helper, newObject) {
        console.log("appending created object to creation array: ");
        console.log(JSON.stringify(newObject));
        var objArr = component.get("v.createdRecords");
         //************************************|| newObject.objName.toUpperCase()=='PROGRAM__C'
        if(newObject.objName == 'Opportunity' ){

            console.log("############# New action :created object to creation array: ");
        	console.log(JSON.stringify(component.get("v.createdRecords")));
        	var objArray = JSON.stringify(component.get("v.createdRecords"));
            var newObj = JSON.stringify(newObject);
            var action1 = component.get("c.insertBidderRecords");   
                action1.setParams({
                    objArray : objArray,
                    newObj:newObj,
                    leadId:component.get("v.recordId"),
                });
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                     console.log('###state',state);
                    if (state === "SUCCESS") {                
                        var response = response.getReturnValue();
                        console.log('###response',response);
                        
                    } 
                    else if (state === "ERROR") {
                    	var errors = response.getError();
                    	console.log('@@@errors'+errors);
                	}
                    else {
                        console.log("There was a bad response:");
                    	console.log(JSON.stringify(response));
                    }
                    
                });           
                $A.enqueueAction(action1); 
            }
            //************************************
        objArr.push(newObject);
    },

    handleSavingCustomObjects: function(component, event, helper) {

        debugger;
        var customObjects = component.get("v.customObjects");
       // var customObjectForms = component.find("CustomObjectForm");
         var customObjectForms =component.find("CustomObjectFormDiv").find({ instancesOf : "c:CustomObjectForLeadConversion" });
        console.log('CustomObjectForm:'+customObjectForms.length);
        var createdObjects = component.get("v.createdRecords");
        
        // we don't use a forEach here because we need to break after submitting first eligible form:
        var counterVar =0;
        for (var i = 0; i < customObjectForms.length; i++) {
            var cus = customObjectForms[i];
            var cusObj = customObjects[i];
            console.log('handleCustomObjects: ' + cusObj.Label + " -- create? " + cusObj.isCreate);
            if ((cusObj.isCreate || cus.get('v.useDuplicate') ) && !cusObj.isSubmitted) {

                if (!cus.get('v.useDuplicate') ) {
                    // handle resolving any dependency IDs:
                    cusObj.customFields.forEach( f => {
                       if (f.hasDependency) {
                           f.sourceFieldValue = helper.resolveDependency(component, event, helper, f.sourceField);
                       }
                    });
                }

                helper.turnOnSpinner(component, event, helper);
                cus.submitCustomForm();
                break; // abort after submitting this form -- we chain customs together
            } else {
                console.log('skipping creation of : ' + cusObj.Label);
                counterVar++;
            }
        }
        //
        // save handleSavingCustomObjects
        if(counterVar == customObjectForms.length){
           component.set("v.isFullySubmitted",true);
        }
        //-------------------------------------
       

    },

    resolveDependency : function(component, event, helper, objectLabel) {
        var objArr = component.get("v.createdRecords");
        var oid = null;
        objArr.forEach(obj => {
           if (obj.Name == objectLabel) {
               console.log('Resolved dependency for -- ' + objectLabel + ':' + obj.Id);
               oid = obj.Id;
           }
        });

        if (oid != null) {
            return oid;
        }

        console.log('could not resolve dependency for label: ' + objectLabel + ' -- dump of objects created as follows');
        console.log(JSON.stringify(objArr));
        return '';
    },
    scrollToTop: function(component, event, helper){
        console.log("Fired scrollToTop");
        window.scrollTo(0, 0);
    },
    expandcontact: function(component,event,helper){

        $A.util.addClass(component.find("shrinkedcontact"), 'invisible');
        $A.util.removeClass(component.find("expandedcontact"), 'invisible');

    },

    expandaccount: function(component,event,helper){

        $A.util.addClass(component.find("shrinkedaccount"), 'invisible');
        $A.util.removeClass(component.find("expandedaccount"), 'invisible');

    }
})