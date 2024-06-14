({
    doInit: function(component, event, helper) {
        if(component.get("v.formType") =="For Customer"){
            component.set("v.isInternal",false);
        }
        
        // alert(component.get("v.isInternal"));
        console.log("toAddress",component.get("v.toAddress"));
        console.log("ccAddress",component.get("v.ccAddress"));
        console.log("bccAddress",component.get("v.bccAddress"));
        console.log("emailSubject",component.get("v.emailSubject"));
        console.log("emailBody",component.get("v.emailBody"));
        console.log("paymentTerms",component.get("v.paymentTerms"));
        console.log("creditType",component.get("v.creditType"));
        var showsendbutton = component.get('v.showSendEmail');
        var isinternal = component.get('v.isInternal');
        if(showsendbutton && !isinternal){
            $A.enqueueAction(component.get('c.sendEmailwithFlowParam'));
        }
       
        
    },
    handleChange : function(component, event, helper) {
        // When an option is selected, navigate to the next screen
        var quoteId 			= 	component.get("v.quoteId");
        var docType 			= 	component.get("v.documentType");
        var formType			= 	component.get("v.formType");
        var taxable				=	component.get("v.taxable");
        //var metric				=	component.get("v.displayInMetric");
        var	metric				=	'false';
        var print				=	component.get("v.printGrandTotal");
        var alternates 			= 	component.get("v.AlternateList");
        var grandTotalWithTax 	= 	component.get("v.grandTotalWithTax");
        var grandTotal 			= 	component.get("v.grandTotal");
        var urlstring ='';
        
        
        var contactName		= 	component.get("v.contactName");
        var contactEmail	= 	component.get("v.contactEmail");
        var contactPhone	= 	component.get("v.contactPhone");
        var fax				=	component.get("v.contactFax");
        var toAddress		= 	component.get("v.toAddress");
        var ccAddress		= 	component.get("v.ccAddress");
        var bccAddress		= 	component.get("v.bccAddress");
        var emailSubject	= 	component.get("v.emailSubject");
        var hideQtys		= 	component.get("v.hideQtys");
        var PONumber		= 	component.get("v.PONumber");
        var shipToAddress	= 	component.get("v.shipToAddress");
        var paymentTerms	= 	component.get("v.paymentTerms");
        var jobReference	= 	component.get("v.jobReference");
        var ourReference	= 	component.get("v.ourReference");
        var creditType		= 	component.get("v.creditType");
        var shppingTerms	= 	component.get("v.shppingTerms");
        var material		= 	component.get("v.material");
        var submittalVersion = 	component.get("v.submittalVersion");
         var isinternal 	= component.get('v.isInternal');
        if(docType =='Pro Forma'){
            urlstring ='Quote_ProForma_PDF';
        }
        else if(docType =='Pro Forma Letter of Credit'){
            urlstring ='Quote_ProFormaInvoiceForLetterCredit_PDF';
        }
            else if(docType =='Pro Forma Wire Transfer'){
                urlstring ='Quote_ProFormaInvoiceWireTransfer';
            }
                else if(docType =='Quote w/ Pricing'){
                    urlstring ='Quote_w_Pricing_PDF';
                }
                    else if(docType =='Bid Format'){
                        urlstring ='Quote_Bid_Format_PDF';
                    }
                        else if(docType =='Quote w Lump Sum Pricing'){
                            urlstring ='Quote_w_LumpSumPricing_PDF';
                        }
                            else{}
        
        var alternateString ='';
        for (var x in alternates) {
            alternateString += alternates[x].Id + ",";
        }
        if(paymentTerms){
            paymentTerms =paymentTerms.replaceAll('%', '--p');
        }
        urlstring +='?quoteId='+quoteId;
        urlstring +='&taxable='+taxable;
        urlstring +='&metric='+metric;
        urlstring +='&print='+print;
        
        urlstring +='&totalwTax='+grandTotalWithTax;
        urlstring +='&total='+grandTotal;
        urlstring +='&alternates='+alternateString;
        
        urlstring +='&contactName='+contactName;
        
        urlstring +='&contactEmail='+contactEmail;
        urlstring +='&contactPhone='+contactPhone;
        urlstring +='&fax='+fax;
        urlstring +='&toAddress='+toAddress;
        urlstring +='&ccAddress='+ccAddress;
        urlstring +='&bccAddress='+bccAddress;
        urlstring +='&emailSubject='+emailSubject;
        urlstring +='&hideQtys='+hideQtys;
        urlstring +='&shipToAddress='+shipToAddress;
        urlstring +='&paymentTerms='+paymentTerms;
        urlstring +='&shppingTerms='+shppingTerms;
        urlstring +='&jobReference='+jobReference;
        urlstring +='&ourReference='+ourReference;
        urlstring +='&creditType='+creditType;
        
        urlstring +='&material='+material;
        urlstring +='&submittalVersion='+submittalVersion;
        urlstring +='&internal='+isinternal;
        var url = "/apex/"+urlstring; 
        console.log('urlString = ' + url);        
        window.open(url, '_blank');  
        
        
    },
    sendEmailwithFlowParam: function(component, event, helper){
        component.set("v.Spinner", true); 
        console.log('sendEmail2');
        // When an option is selected, navigate to the next screen
  		var quoteId 			= 	component.get("v.quoteId");
        var docType 			= 	component.get("v.documentType");
        var formType			= 	component.get("v.formType");
        var taxable				=	component.get("v.taxable");
       	// var metric				=	component.get("v.displayInMetric");
        var	metric				=	'false';
        var print				=	component.get("v.printGrandTotal");
        var alternates 			= 	component.get("v.AlternateList");
        var grandTotalWithTax 	= 	component.get("v.grandTotalWithTax");
        var grandTotal 			= 	component.get("v.grandTotal");
        var urlstring ='';
        
        
        var contactName		= 	component.get("v.contactName");
        var contactEmail	= 	component.get("v.contactEmail");
        var contactPhone	= 	component.get("v.contactPhone");
        var fax				=	component.get("v.contactFax");
        var toAddress		= 	component.get("v.toAddress");
        var ccAddress		= 	component.get("v.ccAddress");
        var bccAddress		= 	component.get("v.bccAddress");
        var emailSubject	= 	component.get("v.emailSubject");
        var hideQtys		= 	component.get("v.hideQtys");
        var PONumber		= 	component.get("v.PONumber");
        var shipToAddress	= 	component.get("v.shipToAddress");
        var paymentTerms	= 	component.get("v.paymentTerms");
        var jobReference	= 	component.get("v.jobReference");
        var ourReference	= 	component.get("v.ourReference");
        var creditType		= 	component.get("v.creditType");
        var shppingTerms	= 	component.get("v.shppingTerms");
        var material		= 	component.get("v.material");
        var submittalVersion = 	component.get("v.submittalVersion");
        var isinternal 		= component.get('v.isInternal');
        
        var docName ='';
        if(docType =='Pro Forma'){
            urlstring ='Quote_ProForma_PDF';
            docName = 'Quote ProForma PDF';
        }
        else if(docType =='Pro Forma Letter of Credit'){
            urlstring ='Quote_ProFormaInvoiceForLetterCredit_PDF';
            docName = 'Quote ProFormaInvoiceForLetterCredit PDF';
        }
            else if(docType =='Pro Forma Wire Transfer'){
                urlstring ='Quote_ProFormaInvoiceWireTransfer';
                docName = 'Quote ProFormaInvoiceWireTransfer PDF';
            }
                else if(docType =='Quote w/ Pricing'){
                    urlstring ='Quote_w_Pricing_PDF';
                    docName = 'Quote w Pricing PDF';
                }
                    else if(docType =='Bid Format'){
                        urlstring ='Quote_Bid_Format_PDF';
                        docName = 'Quote Bid Format PDF';
                    }
                        else if(docType =='Quote w Lump Sum Pricing'){
                            urlstring ='Quote_w_LumpSumPricing_PDF';
                             docName = 'Quote w LumpSumPricing PDF';
                        }
                            else{}
        
        var alternateString ='';
        for (var x in alternates) {
            alternateString += alternates[x].Id + ",";
        }
        if(paymentTerms){
            paymentTerms =paymentTerms.replaceAll('%', '--p');
        }
        urlstring +='?quoteId='+quoteId;
        urlstring +='&taxable='+taxable;
        urlstring +='&metric='+metric;
        urlstring +='&print='+print;
        
        urlstring +='&totalwTax='+grandTotalWithTax;
        urlstring +='&total='+grandTotal;
        urlstring +='&alternates='+alternateString;
        
        urlstring +='&contactName='+contactName;
        
        urlstring +='&contactEmail='+contactEmail;
        urlstring +='&contactPhone='+contactPhone;
        urlstring +='&fax='+fax;
        urlstring +='&toAddress='+toAddress;
        urlstring +='&ccAddress='+ccAddress;
        urlstring +='&bccAddress='+bccAddress;
        urlstring +='&emailSubject='+emailSubject;
        urlstring +='&hideQtys='+hideQtys;
        urlstring +='&shipToAddress='+shipToAddress;
        urlstring +='&paymentTerms='+paymentTerms;
        urlstring +='&shppingTerms='+shppingTerms;
        urlstring +='&jobReference='+jobReference;
        urlstring +='&ourReference='+ourReference;
        urlstring +='&creditType='+creditType;
        
        urlstring +='&material='+material;
        urlstring +='&submittalVersion='+submittalVersion;
        urlstring +='&internal='+isinternal;
        var url = "/apex/"+urlstring; 
       console.log('urlString = ' + url);
      
        
        console.log('sendEmail3');

        /* New Flow Params */
        var bccSelectedContacts = component.get('v.bccSelectedContacts');
        var ccSelectedContacts = component.get('v.ccSelectedContacts');
        var toSelectedContacts = component.get('v.toSelectedContacts');
        var subject = component.get('v.subject');
        var selectedFiles = component.get('v.selectedFiles');

        var reqObj = {
            bccContacts : bccSelectedContacts,
            ccContacts :  ccSelectedContacts,
            toContacts :  toSelectedContacts,
            subject : subject,
            emailTemplateBody : component.get("v.emailBody"),
            selectedFiles : selectedFiles
        }
       // console.log('@@@@@reqObj',JSON.stringify(reqObj));
        var action = component.get("c.sendQuoteEmailwFlowParam");
        action.setParams({ 
            url : url,
            quoteId : component.get("v.quoteId"),
            emailbody :component.get("v.emailBody"),
            ccAddress: component.get("v.ccAddress"),
            toAddress: component.get("v.toAddress"),
            bccAddress: component.get("v.bccAddress"),
            emailSubject: component.get("v.emailSubject"),
            docName: docName,
            reqStr : JSON.stringify(reqObj)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state = ', state);   
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                component.set("v.Spinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'The email has been sent successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                var navigate = component.get("v.navigateFlow");
                navigate("NEXT");
            }
            else if (state === "INCOMPLETE") {
                alert("INCOMPLETE");
                console.log("INCOMPLETE");
                component.set("v.Spinner", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error, your action is INCOMPLETE',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            component.set("v.Spinner", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");alert("Unknown error");
                        
                        component.set("v.Spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Unknown error',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
        });
        $A.enqueueAction(action);
    },
    sendEmail: function(component, event, helper){
        /*
        component.set("v.Spinner", true); 
        console.log('sendEmail');
        var quoteId 	= 	component.get("v.quoteId");
        var docType 	= 	component.get("v.documentType");
        var formType	= 	component.get("v.formType");
        var taxable		=	component.get("v.taxable");
        var metric		=	component.get("v.displayInMetric");
        var print		=	component.get("v.printGrandTotal");
        var alternates 	= 	component.get("v.AlternateList");
        var urlstring ='';
        if(docType =='Pro Forma'){
            urlstring ='Quote_ProForma_PDF';
        }
        else if(docType =='Pro Forma Letter of Credit'){
            urlstring ='Quote_ProFormaInvoiceForLetterCredit_PDF';
        }
            else if(docType =='Pro Forma Wire Transfer'){
                urlstring ='Quote_w_Pricing_PDF'
            }
                else if(docType =='Quote w/ Pricing'){
                    urlstring ='Quote_w_Pricing_PDF'
                }
                    else if(docType =='Bid Format'){
                        urlstring ='Quote_Bid_Format_PDF';
                    }
                        else if(docType =='Quote w Lump Sum Pricing'){
                            urlstring ='Quote_w_LumpSumPricing_PDF';
                        }
                            else{}
        var alternateString ='';
        for (var x in alternates) {
            alternateString += alternates[x].Id + ",";
        }
        
        urlstring +='?quoteId='+quoteId;
        urlstring +='&taxable='+taxable;
        urlstring +='&metric='+metric;
        urlstring +='&print='+print;
        urlstring +='&alternates='+alternateString;
        
        
        var url = "/apex/"+urlstring; 
        console.log('urlString = ' + url);        
        ///   window.open(url, '_blank');  
        
        
        
        var action = component.get("c.sendQuoteEmail");
        action.setParams({ 
            url : url,
            quoteId : component.get("v.quoteId"),
            quotebidderList: component.get("v.QuoteBidderList"),
            emailbody :component.get("v.emailBody")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                component.set("v.Spinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'The email has been sent successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "INCOMPLETE") {
                alert("INCOMPLETE");
                console.log("INCOMPLETE");
                component.set("v.Spinner", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error, your action is INCOMPLETE',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            component.set("v.Spinner", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");alert("Unknown error");
                        
                        component.set("v.Spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Unknown error',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
        });
        $A.enqueueAction(action);
        
        */
    },
    
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showConfirmDialog', false);
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
})