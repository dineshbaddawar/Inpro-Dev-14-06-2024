({
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    setdefaultvalue :function(component, event , helper){
        var selItem = null;
        if(selItem.val){
            component.set("v.selItem",selItem);
        } 
        component.set("v.server_result",null);
    }
})