({
    doInit : function(component, event, helper) {

        var cusObj = component.get('v.cusObj');
        component.set('v.cusFields', cusObj.customFields);
       // return;
    },

    toggleSections:function(cmp,event,helper){
        helper.toggleSections(cmp, event, helper);
    },

    // when radio buttons change, toggle the isCreate property of our custom object to reflect the selected value:
    handleRadio : function(cmp, evt, helper){
         var radio = evt.getSource().get('v.value');
         cmp.set('v.objectRadio', radio);
         var cObj = cmp.get('v.cusObj');
         if (radio == 'Create New') {
            cObj.isCreate = true;
         } else {
            cObj.isCreate = false;
         }
         if (radio == 'Choose Existing') {
             cmp.set('v.useDuplicate', true);
         } else {
             cmp.set('v.useDuplicate', false);
         }
    },
    
    // when radio buttons change, toggle the isCreate property of our custom object to reflect the selected value:
    handleDupeRadio : function(cmp, evt, helper){
         var radio = evt.getSource().get('v.value');
         cmp.set('v.selectedDuplicate', radio);
         var cObj = cmp.get('v.cusObj');
         if (radio == 'Create New') {
            cObj.isCreate = true;
         } else {
            cObj.isCreate = false;
         }
    },

    submitForm : function(cmp, evt, helper) {

        var cusObj = cmp.get('v.cusObj');
        var cusFields = cmp.get('v.cusFields');
		debugger;

        // if we are processing a duplicate, go ahead and fire the success event here
        // with our selected duplicate
        if (cmp.get('v.useDuplicate')) {
            // pull recordid of our duplicate:
            var recordid = cmp.get('v.selectedDuplicate');

            // if a dupe record wasn't chosen yet:
            if (recordid == '') {
                helper.fireErrorMessage(cmp, evt, helper, "If selecting 'Choose Existing' then you must select an existing record");
                return;
            }

            // dupe record was chosen...build event and submit dupe:
             var compEvents = cmp.getEvent("customComponentEvent");  // begin building event:
             compEvents.setParams({
                 "wasSuccess"     : true,
                 "type"           : "submitted",
                 "recordId"       : recordid,
                 "componentLabel" : cusObj.Label,
                 "wasExistingRecord" : true
             });

             // set our recordId in our component:
             cmp.set('v.recordId', recordid);

             // toggle our completed property to mask the form:
             cmp.set('v.isCompleted', true);
             cmp.set('v.completedAction', 'Selected Existing ' + cusObj.Label);
             console.log('submitForm: ' + cusObj.Label + ' returning a duplicate selection: ' + recordid);
             compEvents.fire();
            return;
        }


        console.log("fired child submitForm: " + cusObj.Label + " -- data:");
        console.log(JSON.stringify(cusFields));

        // force error off (if it was on)
        cmp.set('v.showError', false);

        var form = cmp.find('editForm');
        var depCounter = 1;

        // resolve dependencies
        cusFields.forEach( f => {
         if (f.hasDependency) {
             cmp.set('v.dep' + depCounter + 'Name', f.destField);
             cmp.set('v.dep' + depCounter + 'Value', f.sourceFieldValue);
             cmp.set('v.dep' + depCounter + 'Exists', true);
             console.log("submitForm - filled dependency " + depCounter + ' -- ' + cmp.get('v.dep' + depCounter + 'Name') +
                            ":" + cmp.get('v.dep' + depCounter + 'Value'));
             depCounter += 1;
         }
        });


        // do any client side validation (we do this for 'Name' fields as we can't mark those required, they get filled with Id if left empty)
        for(var i = 0; i < cusFields.length; i++) {
             var f = cusFields[i];
             if (f.destField == "Name" || f.destField == "name") {  // if 'Name' field:
                if (helper.getInputFieldValue(cmp, evt, helper, f.destField) == '') {  // if no value set
                    helper.fireErrorMessage(cmp, evt, helper, f.destField + " cannot be empty");
                    return;  // exit since we hit bubbled error
                }
             }
        }


        // submit form:  if dependency exists, we MUST delay a time period (100ms) to let Aura process and bind properly:
        if (cmp.get('v.dep1Exists')) {
            window.setTimeout(
                $A.getCallback(function() {
                    form.submit();
                }), 100
            );
        } else {
            form.submit();
        }
    },

    onLoaded: function(cmp,event,helper){
        console.log('onLoaded fired for: ' + cmp.get("v.cusObj.Label"));

        helper.forceSectionOpen(cmp, event, helper);  // make our section open by default

        // Look up event
        var compEvents = cmp.getEvent("customComponentEvent");
       	compEvents.setParams({ 
            "wasSuccess"     : true,
            "type"           : "loaded",
            "componentLabel" : cmp.get("v.cusObj.Label")
        });
        compEvents.fire();                
    },
    onError: function(cmp,event,helper){
        console.log('onError fired for: ' + cmp.get("v.cusObj.Label"));
        console.log(JSON.stringify(event.getParams()));
        // Look up event
        var compEvents = cmp.getEvent("customComponentEvent");
       	compEvents.setParams({
            "wasSuccess"     : false,
            "type"           : "error",
            "componentLabel" : cmp.get("v.cusObj.Label")
        });

        // parse out and display our error message:
        var msg = "";
        var error = null;
        var errors = event.getParams();
        if (errors["output"] != null) {
            var output = errors["output"];
            if (output["errors"] != null && output["errors"].length > 0) {
                error = output["errors"][0];
            } else if (output["fieldErrors"] != null) {
                var keys = Object.keys(output["fieldErrors"]);
                if (keys.length > 0) {
                    error = output["fieldErrors"][keys[0]][0];
                }
            }
        }
        if (error != null) {
            if (error["errorCode"] == "DUPLICATES_DETECTED") {
                msg = "Duplicate Rule Match: " + error["duplicateRecordError"]["matchResults"][0]["matchRule"];
            } else if (error["errorCode"] == "REQUIRED_FIELD_MISSING") {
                msg = error["message"];
            } else {  // if not these 2, default to whatever msg is left:
                msg = error["message"];
            }
        } else {
            msg = "unknown message format --  please see log.console entry";
        }


        // display our error message
        cmp.set("v.errorMessage", msg);
        cmp.set('v.showError', true);


        // make sure our section is open so error can be seen:
        helper.forceSectionOpen(cmp, event, helper);

        compEvents.fire();
    },    
    onSuccess: function(cmp,event,helper){
		debugger;
        var params = event.getParams();
        var recordid= params.response.id;


        console.log('onSuccess fired for: ' + cmp.get("v.cusObj.Label"));
        // Look up event
        var compEvents = cmp.getEvent("customComponentEvent");
        compEvents.setParams({
            "wasSuccess"     : true,
            "type"           : "submitted",
            "recordId"       : recordid,
            "componentLabel" : cmp.get("v.cusObj.Label")
        });



        // set our recordId in our component:
        cmp.set('v.recordId', recordid);
        // toggle our completed property to mask the form:
        cmp.set('v.isCompleted', true);
        cmp.set('v.completedAction', cmp.get("v.cusObj.Label") + ' Created');

        compEvents.fire();
        return;

    },
    handleLinkClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    }
})