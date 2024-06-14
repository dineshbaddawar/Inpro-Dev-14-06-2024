({
	doInit : function(component, event, helper) {
        console.log('start init');
		helper.getConProj(component);
        helper.getSubstitutionRequests(component);
        helper.getAccountRecordTypes(component);
        //helper.getContractorAccounts(component);
        var themeValue = component.get("v.userTheme");
        if(!themeValue.length>0) {
            helper.getTheme(component);
        } else {
            console.log('theme initialized: ' + themeValue);
        }
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    updateSelectedText: function(component, event, helper) {
        const selectedRows = event.getParam('selectedRows');
        component.set("v.selectedSubLineItems", selectedRows);
    },

    updateSelectedRecordTypes: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
            
        }
        debugger;
        component.set("v.selectedRecordTypes", setRows);
    },

    updateSelectedAccountTypes: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
            
        }
        component.set("v.selectedAccountTypes", setRows);
    },

    goToPrevious : function(component, event, helper) {
        const currentStep =  component.get("v.currentStep");
        let stepChange = 1;

        // if only one record type, skip second step
        if(currentStep == 3) {
            const recTypes = component.get('v.recordTypeData');
            if (recTypes.length === 1) {
                stepChange++;
            }
        }
        // do not decrement if on first step
        if(currentStep != 1) {
            const nextStep = Number.parseInt(currentStep) - stepChange;
            component.set("v.currentStep", nextStep.toString());
        }       
    },

    next : function(component, event, helper) {
        let currentStep =  component.get("v.currentStep");
		debugger;
        // Skip second step if only one account record type is available
        if( currentStep == 1) {
            const recTypes = component.get('v.recordTypeData');
            if (recTypes.length === 1) {
                // set the record type value
                const rt = [ recTypes[0] ];
                component.set("v.selectedRecordTypes", rt);
                // increase steps by two
                let nextStep = Number.parseInt(currentStep) + 2;
                component.set("v.currentStep", nextStep.toString());
                helper.getAccountTypes(component)
            }
            else{
                var nextStep = Number(currentStep)+ 1;
                component.set("v.currentStep", nextStep.toString());
            }
        } else if(currentStep!=3){
            var nextStep = Number(currentStep)+ 1;
            component.set("v.currentStep", nextStep.toString());
        }
        
    },

    chooseAccountType : function(component, event, helper) {
        var currentStep =  component.get("v.currentStep");
        if(currentStep == 2){
            var nextStep = Number(currentStep)+ 1;
            component.set("v.currentStep", nextStep.toString());
            helper.getAccountTypes(component);
        }
        
    },

    submit : function(component, event, helper) {
        var currentStep =  component.get("v.currentStep");
        if(currentStep == 3){
            var nextStep = Number(currentStep)+ 1;
            component.set("v.currentStep", nextStep.toString());
            helper.getContractorAccounts(component);
        }
        
    },
    
    goToOpp : function(component, event, helper) {
        helper.goToRecord(component, component.get("v.recordId"));
    },
    
    goToAccount : function(component, event, helper) {
      	var accountId = event.currentTarget.getAttribute("data-attriVal");
        console.log('account Id: ' + accountId);
        helper.goToRecord(component, accountId);
    },
    
    assignOpp : function(component, event, helper) {
        helper.doAssignOpp(component);
    },

    searchAccounts : function(component, event, helper) {
        var acctName = component.get("v.accountName");

        if(acctName.length >= 2) {
            helper.getContractorAccounts(component);
        } else {
            $A.util.removeClass(component.find("searchResults"), "slds-is-open");
        }
    },

    addAcct : function(component, event, helper) {
        console.log('start manual add');

        $A.util.removeClass(component.find("searchResults"), "slds-is-open");

        var acctId = event.getParam("AccountId"); 

        console.log('start loop: ' + acctId);

        var manualList = component.get("v.manuallyAdded");
        var acctList = component.get("v.accountList");

        var newAcctWrap;
        var acctResults = component.get("v.acctSearchResults");
        for(var a = 0; a<acctResults.length; a++){//for(var index in acctResults) {
            console.log('looping');
            //if(acctResults[index]['acct']['Id'] === acctId) {
            if(acctResults[a]['acct']['Id'] === acctId) {
                console.log('match');
                var matchedAcct = acctResults[a];//var matchedAcct = acctResults[index];
                matchedAcct['toAssign'] = true;
                console.log('set to true: ' + matchedAcct['toAssign']);

                var inManualList = false;

                for(var i = 0; i<manualList.length; i++){//var manualIndex in manualList) {
                    if(manualList[i]['acct']['Id'] === acctId) {//if(manualList[manualIndex]['acct']['Id'] === acctId) {
                        inManualList = true;
                        console.log('already in manual');
                    }
                }

                if(inManualList === false) {
                    manualList.push(matchedAcct);
                    console.log('add to manual: ' + manualList);
                }

                var inAcctList = false;

                for(var b = 0; b<acctList.length; b++){//for(var acctIndex in acctList) {
                    //console.log('check acct Id: ' + acctList[b]['acct']['Id']);
                    //console.log('check Id: ' + acctId);
                    if(acctList[b]['acct']['Id'] === acctId) {//if(acctList[acctIndex]['acct']['Id'] === acctId) {
                        inAcctList = true;
                        var newAcct = acctList[b];
                        newAcct['toAssign'] = true;
                        acctList[b] = newAcct;
                        console.log('set existing acct to true');
                    }
                }

                if(inAcctList === false) {
                    acctList.unshift(matchedAcct);
                    console.log('add to accts: ' + acctList);
                }
            }
        }

        component.set("v.manuallyAdded", manualList);
        console.log('put manual lists');
        component.set("v.accountList", acctList);
        console.log('put account list');
    }
})