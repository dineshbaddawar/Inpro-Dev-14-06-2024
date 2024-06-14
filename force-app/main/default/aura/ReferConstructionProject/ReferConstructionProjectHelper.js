({
	getConProj : function(component) {
        console.log('start get opp');
		var conProjId = component.get("v.recordId");
        component.set("v.loading",true);
        var action = component.get("c.getConProjRecord");
        action.setParams({ 
            "conProjId" : conProjId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('get opp response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('opp result: ' + result);
                component.set("v.currentOpp",result);

                if(result['Queue_Geolocation__c'] == true && component.get("v.geoCallout") == false) {
                    console.log('do geolocate');
                    this.doConfirmGeolocation(component);
                } else {
                    this.getContractorAccounts(component);
                }

                console.log('finish get opp');
            } else if (state === "ERROR") {
                console.log('get acct response error');
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
                component.set("v.loading",false);
            } else {
                component.set("v.loading",false);
            }
        });
        $A.enqueueAction(action);
        
	},
    
    getSubstitutionRequests: function(component) {
        
        component.set('v.columns', [
            {label: 'Product Family', fieldName: 'Product_FamilyG__c', type: 'text'},
            {label: 'Our Specified Product', fieldName: 'Our_Specified_Product__c', type: 'text'},
            {label: 'Specification Status', fieldName: 'Specification_Status__c', type: 'text'}
            
        ]);
        var conProjId = component.get("v.recordId");
        var action = component.get("c.getSubstitutionRequests");
        action.setParams({ 
            "conProjId" : conProjId 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                if(resp.length != 0){
                    var rows = response.getReturnValue();     
                    for (var i = 0; i < rows.length; i++) { 
                        var row = rows[i]; 
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.Substitute_Product_1__r) { 
                            row.Substitute_ProductName = row.Substitute_Product_1__r.Name; 
                        } 
                    } 
                    component.set('v.data', rows);
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccountRecordTypes: function(component) {
        
        component.set('v.recordTypeColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'}
        ]);
        var action = component.get("c.getAccountRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                if(resp.length != 0){
                    var rows = response.getReturnValue();     
                    component.set('v.recordTypeData', rows);
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccountTypes: function(component) {
        
        component.set('v.accountTypeColumns', [
            {label: 'Account Type',fieldName: 'acctType', type: 'text'}
        ]);
        var accRecTypes=component.get("v.selectedRecordTypes");
        var action = component.get("c.getAccountTypePLValues");
        action.setParams({ 
            "recTypes" : accRecTypes
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                if(resp.length != 0){
                    var rows = response.getReturnValue();     
                    component.set('v.accountTypeData', rows);
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getContractorAccounts : function(component) {
		var conProjId = component.get("v.recordId");
        var acctName = component.get("v.accountName");
        var accRecTypes=component.get("v.selectedRecordTypes");
        var accTypes=component.get("v.selectedAccountTypes");
        component.set("v.loading",true);
        var selSubLineItems=component.get("v.selectedSubLineItems");
        var action = component.get("c.getAccounts");
        action.setParams({ 
            "conProjId" : conProjId,
            "acctName" : acctName,
            "recTypes":accRecTypes,
            "accTypes":accTypes,
            "subLineItems":(selSubLineItems)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('get contractors response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var results = response.getReturnValue();
                console.log('contractor results: ' + results);
                if(acctName != '' && acctName != undefined) {
                    component.set("v.acctSearchResults", results);
                    $A.util.addClass(component.find("searchResults"),"slds-is-open");
                } else {
                    component.set("v.accountList", results);
                }
                console.log('finish get contractors');
                component.set("v.loading",false);
            } else if (state === "ERROR") {
                console.log('get acct response error');
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
                component.set("v.loading",false);
            } else {
                component.set("v.loading",false);
            }
            
        });
        $A.enqueueAction(action);
        
	},
    
    getTheme : function(component) {
        console.log('get theme');
        
        var action = component.get("c.getUIThemeDescription");
        action.setCallback(this, function(response) {
            console.log('theme callback');
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log('theme: ' + response.getReturnValue());
            	component.set("v.userTheme", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    doAssignOpp : function(component) {
    	var conProjId = component.get("v.recordId");
        var acctList = component.get("v.accountList");
        var myUserContext = component.get("v.userTheme");
        var selSubLineItems=component.get("v.selectedSubLineItems");
        component.set("v.loading",true);
        console.log('selSubLineItems' + selSubLineItems);
        console.log('opp Id: ' + conProjId);
        console.log('account list: ' + acctList);
        var accArr=[];
        var accWrapperList=[];
        for (var i = 0; i < acctList.length; i++) { 
            var row = acctList[i]; 
            if(row.toAssign == true ){
                accArr.push(row.acct.Id);
                accWrapperList.push(row);
            }
        }
        console.log('accArr',accArr);
        var action = component.get("c.doAssignOpp");
        action.setParams({ 
            "conProjId" : conProjId,
            "acctWrapList" : (accArr),
            "accountWrapperList":accWrapperList,
            "subLineItems":(selSubLineItems)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('do assign opp response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('do assign opp results: ' + result);
                var blankValue;
                component.set("v.accountName", blankValue);
                this.getContractorAccounts(component);
                console.log('finish do assign opp');

                var message;
                var title;
                var type;
                if(result === 'Success') {
                    title = 'Success';
                    type = 'success';
                    message = 'Project referred!';
                } else {
                    title = 'No Selections';
                    type = 'info';
                    message = 'No accounts were selected to refer.';
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "type": type,
                    "message": message
                });
                toastEvent.fire();
                
                //if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                if (myUserContext == 'Theme4t') {
                    console.log('theme 4 navigation');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }  else if (myUserContext == 'Theme3') {
                    console.log('theme 3 navigation');
                    this.goToRecord(component, component.get("v.recordId"));
                } else {
                    console.log('default naviagtion');
                    this.goToRecord(component, component.get("v.recordId"));
                }

                component.set("v.loading",false);
            } else if (state === "ERROR") {
                console.log('do assign lead response error');
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();

                    component.set("v.loading",false);
                }
            }
        });
        $A.enqueueAction(action);
        
	},
    
    goToRecord : function(component, recordId) {
        var myUserContext = component.get("v.userTheme");
        console.log('theme: ' + myUserContext);

        console.log('record id: ' + recordId);
        
        if (myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
        //if (myUserContext == 'Theme4t') {
            // The Visualforce page is in S1 or Lightning Experience
            //sforce.one.navigateToSObject(component.get("v.recordId"));
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/" + recordId
            });
            urlEvent.fire();
        } else if (myUserContext == 'Theme3') {
            // The Visualforce page is  running in Classic
            window.parent.location = '/' + recordId;
        } else {
            console.log("Unsupported theme");   
            window.parent.location = '/' + recordId;
        }
    },

    doConfirmGeolocation : function(component) {
        console.log('start confirm geolocation');
        var conProjId = component.get("v.recordId");
        component.set("v.loading",true);
        
        var action = component.get("c.confirmGeolocation");
        action.setParams({ 
            "conProjId" : conProjId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('confirm geo response: ' + state);
            if (component.isValid() && state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('confirm geo opp result: ' + result);
                component.set("v.currentOpp",result);
                console.log('finish confirm geo');

                component.set("v.geoCallout", true);
                console.log('geolocate done');

                this.getConProj(component);
            } else if (state === "ERROR") {
                console.log('confirm geo response error');
                var errors = response.getError();
                if (errors) {
                    var message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = 'Something went wrong! Please contact your Salesforce administrator or try again.';
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": message
                    });
                    toastEvent.fire();
                }
                component.set("v.loading",false);
            } else {
                component.set("v.loading",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecTypeCount : function(component) {
        const recTypes = component.get('v.recordTypeData');
        return recTypes.length;
    }
})