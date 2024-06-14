({
    closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	init : function(cmp, evt, helper) {
		var myPageRef = cmp.get("v.pageReference");
		if(myPageRef != null && myPageRef.state != null)
		{
			var currentRecordId = myPageRef.state.c__currentRecordId;
			var division = myPageRef.state.c__division;
			var divSection = myPageRef.state.c__divisionSection;
			console.log('current Record Id: ' + currentRecordId);
			cmp.set("v.currentRecordId", currentRecordId);
			cmp.set("v.divisionInput", division);
			cmp.set("v.divSectionInput", divSection);
		}
	}
})