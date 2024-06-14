({
    doInit : function(component, event, helper) {
        helper.getUser(component,event,helper);
        helper.getRecordTypes(component,event,helper);
        helper.getStageValues(component,event,helper);
        helper.populatefields(component,event,helper);
        
        helper.getDuplicates(component,event,helper);
        helper.getFilters(component,event,helper);

        // init our created records with a dummy empty array:
        var objArr=[];
        component.set("v.createdRecords",objArr);

       // force account/contact open by default
       helper.expandcontact(component, event, helper);
       helper.expandaccount(component, event, helper);

    },
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    toggleaccount: function(component,event,helper){
        if($A.util.hasClass(component.find("shrinkedaccount"), "invisible")){
            $A.util.addClass(component.find("expandedaccount"), 'invisible');
            $A.util.removeClass(component.find("shrinkedaccount"), 'invisible');
        }
        else {
            $A.util.addClass(component.find("shrinkedaccount"), 'invisible');
            $A.util.removeClass(component.find("expandedaccount"), 'invisible');
        }
    },
    togglecontact: function(component,event,helper){
        debugger;
        
        if($A.util.hasClass(component.find("expandedcontact"), "invisible")){
            $A.util.addClass(component.find("shrinkedcontact"), 'invisible');
            $A.util.removeClass(component.find("expandedcontact"), 'invisible');
        }
        else {
            $A.util.addClass(component.find("expandedcontact"), 'invisible');
            $A.util.removeClass(component.find("shrinkedcontact"), 'invisible');
        }
    },
    
    expandcontact: function(component,event,helper){
        $A.util.addClass(component.find("shrinkedcontact"), 'invisible');
        $A.util.removeClass(component.find("expandedcontact"), 'invisible');
    },
    
    expandaccount: function(component,event,helper){
        $A.util.addClass(component.find("shrinkedaccount"), 'invisible');
        $A.util.removeClass(component.find("expandedaccount"), 'invisible');
    },
    
    
    toggleSections:function(component,event,helper){
        debugger;
        var id = event.currentTarget.dataset.id;
        var parent=document.getElementById("shrinked"+id);
        var className=parent.className;
        if(className.includes('invisible'))
            parent.classList.remove("invisible");
        else
            parent.classList.add("invisible");
        
        var newDiv=document.getElementById("expanded"+id);
        var newclassName=newDiv.className;
        if(newclassName.includes('invisible'))
            newDiv.classList.remove("invisible");
        else
            newDiv.classList.add("invisible");
    },
    
    
    contactNameChanged: function(component,event,helper){
        debugger;
        var fname=component.get("v.contactFirstName");
        var lname=component.get("v.contactLastName");
        var name=fname+' '+lname;
        component.set("v.contactName",name);
    },
    
    dupeAccSelected:function(component,event,helper){
        debugger;
        component.set('v.dupeAccId', event.getSource().get('v.value'));
        debugger;
    },
    
    dupeConSelected:function(component,event,helper){
        debugger;
        component.set('v.dupeConId', event.getSource().get('v.value'));
        debugger;
    },
    
    
    ConSelected:function(component,event,helper){
        debugger;
        if(event.getSource().get('v.value') == 'Create New')
        	component.set('v.NewContact',true);
        else
            component.set('v.NewContact', false);
        debugger;
    },
    
    AccSelected:function(component,event,helper){
        debugger;
        if(event.getSource().get('v.value') == 'Create New')
        	component.set('v.NewAccount',true);
        else
            component.set('v.NewAccount', false);
    },
    
    reRenderCustomObjects: function(component,event,helper){
        // refresh our custom object view if a filter change has occurred
        var lastFilter = component.get('v.lastFilter');
        var selectedFilter = component.get('v.selectedFilter');

        if (lastFilter != selectedFilter) {
            helper.getCustomObjects(component, event, helper);
            component.set('v.lastFilter', selectedFilter);
        }
	},
    
    convertLead: function(component,event,helper){
			
        // lock filter picklist now because it could be a disaster once objects start saving
        component.set('v.lockFilter', true);
        component.set("v.errorMsg",false);

        // if accounts/contacts complete, we can go ahead and save custom objects:
        if (component.get('v.isAccountContactComplete')) {
            helper.handleSavingCustomObjects(component, event, helper);
            return;
        } else {


            var accountname='';
            var conFname='';
            var conLname='';
            var conTitle='';
            var conEmail='';
            var conPhone='';
            var accRecordType='';
            var conRecordType='';
            var existAccId='';
            var existConId='';
            var createCon=false;
            var createAcc=false;
            var leadId=component.get("v.recordId");
            var lookupAcc=component.get("v.Account");
            var lookupCon=component.get("v.contact");
            var usr =component.get("v.Userstring");

            if(component.get("v.NewAccount") == true ){
                createAcc=true;
                accountname=component.get("v.accountName");
                accRecordType=component.get("v.AccountRecordType");
            }
            else{
                if(lookupAcc != null)
                    existAccId=lookupAcc.val;
                else
                    existAccId=component.get("v.dupeAccId");
            }
                conFname=component.get("v.contactFirstName");
                conLname=component.get("v.contactLastName");
                conEmail=component.get("v.contactEmail");
                conPhone=component.get("v.contactPhone");
                conTitle=component.get("v.contactTitle");

            if(component.get("v.NewContact") == true ){
                createCon=true;                
                conRecordType=component.get("v.ContactRecordType");
            }
            else{
                if(lookupCon != null)
                    existConId=lookupCon.val;
                else
                    existConId=component.get("v.dupeConId");
            }

            var action1 = component.get("c.convertLeadrecord");
            action1.setParams({
                convStatus:component.get("v.Status"),
                leadId:component.get("v.recordId"),
                accName : accountname,
                accRecordType:accRecordType,
                confName:conFname,
                conlName:conLname,
                conEmail:conEmail,
                conPhone:conPhone,
                conTitle:conTitle,
                conRecordType:conRecordType,
                existAccid:existAccId,
                existConId:existConId,
                createAcc:createAcc,
                createCon:createCon,
                accBillingStreet:component.get("v.accBillingStreet"),
                accBillingCity:component.get("v.accBillingCity"),
                accBillingState:component.get("v.accBillingState"),
            	accBillingPostalCode:component.get("v.accBillingPostalCode"),
            	accBillingCountry:component.get("v.accBillingCountry"),
            	accPhone:component.get("v.accPhone"),
            	accFax:component.get("v.accFax"),
            	accWebsite:component.get("v.accWebsite"),
                userId:usr.val
            });
            
            
            action1.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var resp=response.getReturnValue();
                    component.set('v.convertedAccid',resp.convAccount.Id);
                    component.set('v.convertedConid',resp.convContact.Id);
                    component.set('v.convertedAccount',resp.convAccount);
                    component.set('v.convertedContact',resp.convContact);
                    component.set('v.createdContactId', resp.convContact.Id);
                    component.set('v.createdAccountId',resp.convAccount.Id);
                    component.set('v.isAccountContactComplete', true);
                    
                    var objArr=[];
                    objArr.push({
                        Id:resp.convAccount.Id,
                        objName:"Account",
                        Name:"Account"
                    });
                    objArr.push({
                        Id:resp.convContact.Id,
                        objName:"Contact",
                        Name: "Contact"
                    });
                    ///--------------------
                     objArr.push({
                        Id:component.get("v.recordId"),
                        objName:"Lead",
                        Name: "Lead"
                    });
                    //--------------------
                    helper.appendCreatedObject(component, event, helper, objArr[0]);
                    helper.appendCreatedObject(component, event, helper, objArr[1]);
                    //--------------
                    helper.appendCreatedObject(component, event, helper, objArr[2]);
                    
                    // submit our custom object forms:
                    helper.handleSavingCustomObjects(component, event, helper);
                    helper.turnOffSpinner(component, event, helper);
                }
                else if (state === "ERROR") {
                    console.log("Response of ERROR receieved from controller on getCustomObjectsFromMetadata.  Error info follows (if provided):")
                    var errors = response.getError();
                    var message='';
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            message=errors[0].message;
                        }
                        if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            message=errors[0].pageErrors[0].message;
                        }
                        helper.turnOffSpinner(component, event, helper);
                        component.set("v.errorMsg",true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Field error:",
                            "message": message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("There was a bad response from the controller on getCustomObjectsFromMetadata.  JSON as follows:");
                    console.log(JSON.stringify(response));
                    component.set("v.errorMsg",true);
                }
            });
            helper.turnOnSpinner(component, event, helper);
            $A.enqueueAction(action1);
        }
        
    },

    customFormEventFired: function(cmp, event, helper) {

        // pull our base params so we can log to console:
        var wasSuccess = event.getParam('wasSuccess');
        var type = event.getParam('type');
        var label = event.getParam('componentLabel');
        
        
     //   var errorMsg = event.getParam('errorMsg');
        console.log('CustomFormEventFired-- ' + label + " - " + type + ": success=" + wasSuccess);

        // call our handlers based on the type of event fired:
        if (type == "loaded") {
            helper.processLoadedCallback(cmp, event, helper);
        } else if (type == "submitted") {
            helper.processSubmittedCallback(cmp, event, helper);
        } else if (type == "error") {
            cmp.set("v.errorMsg",true);
            helper.processErrorCallback(cmp, event, helper);
        }
        
    },
               
    navigateToRecord: function(component,event,helper){
        var recordId = event.currentTarget.dataset.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    handleAccountLinkClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.createdAccountId")
        });
        navEvt.fire();
    },

    handleContactLinkClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.createdContactId")
        });
        navEvt.fire();
    }

            
            
            
})