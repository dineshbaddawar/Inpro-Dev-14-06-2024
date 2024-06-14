({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfSampleRequests");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfSampleRequests = component.get("v.listOfSampleRequests");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfSampleRequests.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfSampleRequests[i].isChecked = true;
                component.set("v.selectedCount", listOfSampleRequests.length);
            } else {
                listOfSampleRequests[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfSampleRequests[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfSampleRequests", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfSampleRequests");
        var selectedRecords = [];
        var selectedRecordIds ='';
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked && allRecords[i].objSampleRequest.Status__c =='Approved' ) {
                selectedRecords.push(allRecords[i].objSampleRequest);
                selectedRecordIds += allRecords[i].objSampleRequest.Name +',';
            }
        }
        if(selectedRecordIds != ''){
            var urlString = "/apex/SampleRequestBulkTicketPrint?Ids="+selectedRecordIds; 
            console.log('urlString = ' + urlString);        
            window.open(urlString, '_blank');  
            helper.doGenratePDF(component, event,selectedRecords);
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            //
        }
        else{
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": "No Requests in Approved status"
                });
            toastEvent.fire();
        }
        
        //alert(JSON.stringify(selectedRecords));
    }
})