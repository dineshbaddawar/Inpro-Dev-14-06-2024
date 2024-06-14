({
    doInit: function(cmp) {
        var recordId =cmp.get("v.recordId");
        var urlString = "/apex/SampleRequestPrintTicket?Id="+recordId; 
        console.log('urlString = ' + urlString);        
        window.open(urlString, '_blank');  
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})