({
	toggleSections : function(component, event, helper) {
        var id = component.get('v.cusObj').Label;
        var parent=document.getElementById("shrinked" + id);
        var className=parent.className;
        var isExpanded = false;
        if(className.includes('invisible')) {
            parent.classList.remove("invisible");
            isExpanded = false;
        } else {
            parent.classList.add("invisible");
            isExpanded = true;
        }

        var newDiv=document.getElementById("expanded" + id);
        var newclassName=newDiv.className;
        if(newclassName.includes('invisible'))
            newDiv.classList.remove("invisible");
        else
            newDiv.classList.add("invisible");

        // set chevron arrows:
        var onArrow = component.find("articleOn");
        var offArrow = component.find("articleOff");
        if (isExpanded) {
            $A.util.addClass(onArrow, 'slds-show');
            $A.util.addClass(offArrow, 'slds-hide');
            $A.util.removeClass(onArrow, 'slds-hide');
            $A.util.removeClass(offArrow, 'slds-show');
        } else {
            $A.util.removeClass(onArrow, 'slds-show');
            $A.util.removeClass(offArrow, 'slds-hide');
            $A.util.addClass(onArrow, 'slds-hide');
            $A.util.addClass(offArrow, 'slds-show');
        }
	},
	isSectionOpen : function(component, event, helper) {
        var id = component.get('v.cusObj').Label;
        var parent=document.getElementById("shrinked" + id);
        var className=parent.className;
        var isExpanded = false;
        if(className.includes('invisible')) {
            isExpanded = true;
        }
        return isExpanded;
    }, 
    forceSectionOpen: function(component, event, helper) {
        var isOpen = helper.isSectionOpen(component, event, helper);
        if (!isOpen) {
            helper.toggleSections(component, event, helper);
        }
    },
    fireErrorMessage : function(component, event, helper, errorMessage) {
         var cusObj = component.get('v.cusObj');

         var compEvents = component.getEvent("customComponentEvent");
         compEvents.setParams({
             "wasSuccess"     : false,
             "type"           : "error",
             "componentLabel" : cusObj.Label
         });

         // display our error message
         component.set("v.errorMessage", errorMessage);
         component.set('v.showError', true);

         // make sure our section is open so error can be seen:
         helper.forceSectionOpen(component, event, helper);

         compEvents.fire();

        return;
    },
    getInputFieldValue : function(component, event, helper, fieldName) {
        var cusFields = component.get('v.cusFields');
        for(var i = 0; i < cusFields.length; i++) {
             var f = cusFields[i];
             if (f.destField == fieldName) {
                 console.log('customObjectForLeadConversion.getInputFieldValue -- found value for ' + fieldName + ':' + f.sourceFieldValue);
                 return f.sourceFieldValue;
             }
        }
        return '';
    }
})