import {
    LightningElement,
    track,
    api
} from 'lwc';

import getOrderItems from '@salesforce/apex/CreateExpediteRequestHelper.GetOrderItems';
import retrievalByOrder from '@salesforce/apex/CreateExpediteRequestHelper.RetrievalByOrder';
import retrievalByQuote from '@salesforce/apex/CreateExpediteRequestHelper.RetrievalByQuote';
import retrievalByCustomerNumber from '@salesforce/apex/CreateExpediteRequestHelper.RetrievalByCustomerNumber';
import createExpediteRequest from '@salesforce/apex/CreateExpediteRequestHelper.CreateExpediteRequest';
import quoteSearch from '@salesforce/apex/CreateExpediteRequestHelper.QuoteSearch';
import managerSearch from '@salesforce/apex/CreateExpediteRequestHelper.ManagerSearch';
import retrieveManagerList from '@salesforce/apex/CreateExpediteRequestHelper.RetrieveManagerList';
import createNetSuiteExpedite from '@salesforce/apex/CreateExpediteRequestHelper.CreateNetSuiteExpediteRequest';
import UserRoleId from '@salesforce/schema/User.UserRoleId';
import userId from '@salesforce/user/Id';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class CreateExpediteRequest extends LightningElement {

    @track loaded = true;
    @track theRecord = {};
    @track customerNumber = '';
    @track orderNumber = '';
    @track quoteNumber = '';
    @track expediteReasonOptions = [];
    @track pleaseSelectOption = '';
    @track division = '';
    @track customerName = '';
    @track orderEntryDate;
    @track orderTotal = 0;
    @track currentMOT = '';
    @track mfgLoc = '';
    @track shipVia = '';
    @track expeditingEntireOrder = false;
    @track changingMOT = false;
    @track chargingExpediteFee = true;
    @track motList = [];
    @track expediteItemList = [];
    @track managerList = [];
    @track orderItems = [];
    @track displayError = false;
    @track orderNumber = '';
    @track quoteNumber = '';
    @track proposedDate;
    @track isProductCurrentlyInStock = false;
    @track areWeChangingMOT = false;
    @track newMOT = '';
    @track expediteFeeAmount = 0;
    @track expediteReason = '';
    @track expediteReasonNotes = '';
    @track expediteName = "Expedite Request: ";
    @track expediteApprovalStepId = '';
    @track createExpediteButtonVisible = true;
    @track retrievedExpediteFee = 250;
    @track displayFCError = false;
    @track approvingManagerId = 'Please Select';
    @track quoteId = '';
    @track selectedQuote = {};
    @track expeditePartNumber = '';

    connectedCallback() {
        // initialize component

        var pleaseSelectOption = {
            label: 'Please Select',
            value: 'Please Select'
        };

        var customerOption = {
            label: 'Customer',
            value: 'Customer'
        };

        var inproOption = {
            label: 'Inpro',
            value: 'Inpro'
        };

        var otherOption = {
            label: 'Other',
            value: 'Other'
        };

        this.managerList = [...this.managerList, pleaseSelectOption];
        
        this.expediteReasonOptions = [...this.expediteReasonOptions, pleaseSelectOption];
        this.expediteReasonOptions = [...this.expediteReasonOptions, customerOption];
        this.expediteReasonOptions = [...this.expediteReasonOptions, inproOption];
        this.expediteReasonOptions = [...this.expediteReasonOptions, otherOption];

        this.pleaseSelectOption = 'Please Select';
        this.expeditingEntireOrder = false;
        this.getManagerList();
    }

    getManagerList()
    {
        this.loaded = false;
        retrieveManagerList().then(data => {
            if (data) {
                try {  
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(Expedite_Approver__c => { 
                        var newManagerOption = {
                            label: Expedite_Approver__c.Name,
                            value: Expedite_Approver__c.Id
                        };
                        this.managerList = [...this.managerList, newManagerOption];                       
                    }); 
                    this.loaded = true;                                         
                } catch (error) {
                    this.handleError(error);
                }

            } else if (error) {
                this.handleError(error);
            }
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    getOrder()
    {
        this.orderNumber = this.theRecord["li_orderNumber"];
        this.loaded = false;
        retrievalByOrder({
            orderNumber: this.theRecord["li_orderNumber"]
        }).then(data => {
            if (data) {
                try {
                    data = JSON.parse(data);
                    if(data.Status)
                    { 
                        if(data.CustomerName != null)
                            this.customerName = data.CustomerName;
                        if(data.OrderEntryDate != null)
                            this.orderEntryDate = data.OrderEntryDate;
                        if(data.CurrentShipDate != null)
                            this.currentShipDate = data.CurrentShipDate;
                        if(data.OrderTotal != null)
                        {
                            this.orderTotal = data.OrderTotal;
                            if((this.orderTotal * 0.1) > 100 && this.expeditePartNumber.indexOf("Shipping") != -1)
                                this.retrievedExpediteFee = this.orderTotal * 0.1;
                            else if ((this.orderTotal * 0.1) <= 100 && this.expeditePartNumber.indexOf("Shipping") != -1)
                                this.retrievedExpediteFee = 100;
                            else if((this.orderTotal * 0.2) > 250)
                                this.retrievedExpediteFee = this.orderTotal * 0.2;
                            else
                                this.retrievedExpediteFee = 250;
                            if(this.chargingExpediteFee)
                                this.expediteFeeAmount = this.retrievedExpediteFee;
                            else
                                this.expediteFeeAmount = 0;
                            // if(this.orderTotal > 25000)
                            // {
                            //     this.loaded = true;
                            //     this.displayFCError = true;
                            //     this.fcerror = 'Error: You cannot submit an expedite request for an order valued over $25000.';                                
                            // }
                        }
                        if(data.CurrentMOT != null)
                            this.currentMOT = data.CurrentMOT;
                        if(data.MfgLoc != null)
                            this.mfgLoc = data.MfgLoc;
                        if(data.ShipVia != null)
                            this.shipVia = data.ShipVia;
                        if(data.Division != null)
                            this.division = data.Division;
                        if(data.CustomerNumber != null)
                            this.customerNumber = data.CustomerNumber;
                        if(data.quoteId != null && data.quoteName != null)
                        {
                            this.quoteId = data.quoteId;
                            this.quoteNumber = data.quoteName;
                            this.selectedQuote = {
                                id: this.quoteId,
                                sObjectType: 'quote',
                                icon: 'standard:account',
                                title: this.quoteNumber,
                                subtitle: ''
                            };
                            
                        }

                        if(data.MOTList != null)
                        {
                            this.motList = [];
                            var pleaseSelectOption = {
                                label: 'Please Select',
                                value: 'Please Select'
                            };
                            this.motList = [...this.motList, pleaseSelectOption];
                            for(var i = 0; i < data.MOTList.length; i++)
                            {
                                var motListItem = {
                                    label: data.MOTList[i],
                                    value: data.MOTList[i]
                                };
                                
                                this.motList = [...this.motList, motListItem];
                            }
                        }

                        if(data.ExpediteItemList != null)
                        {
                            this.expediteItemList = [];
                            var pleaseSelectOption = {
                                label: 'Please Select',
                                value: 'Please Select'
                            };
                            this.expediteItemList = [...this.expediteItemList, pleaseSelectOption];
                            for(var i = 0; i < data.ExpediteItemList.length; i++)
                            {
                                var expediteItem = {
                                    label: data.ExpediteItemList[i],
                                    value: data.ExpediteItemList[i]
                                };
                                
                                this.expediteItemList = [...this.expediteItemList, expediteItem];
                            }
                        }

                        if(data.OrderItems != null)
                        {
                            this.orderItems = [];                           
                            for(var i = 0; i < data.OrderItems.length; i++)
                            {
                                var orderItem = {
                                    ItemNumber: data.OrderItems[i].ItemNumber,
                                    Description: data.OrderItems[i].Description,
                                    Quantity: data.OrderItems[i].Quantity,
                                    QuantityOnHand: data.OrderItems[i].QuantityOnHand,
                                    BackorderQuantity: data.OrderItems[i].BackorderQuantity,
                                    QuantityAvailable: data.OrderItems[i].QuantityAvailable,
                                    LineUniqueKey: data.OrderItems[i].LineUniqueKey,
                                    Selected: false
                                };
                                
                                this.orderItems = [...this.orderItems, orderItem];
                            }
                        }
                    }
                    else
                    {
                        this.orderNumber = '';
                        this.handleError(data.Message);
                    }  
                    console.log("order search result!");             
                } catch (error) {
                    this.orderNumber = '';
                    this.handleError(error);
                }
            } else if (error) {
                this.orderNumber = '';
                this.handleError(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            this.orderNumber = '';
            this.handleError(error);
        });
    }

    getQuote()
    {
        this.loaded = false;
        retrievalByQuote({
            quoteId: this.quoteId
        }).then(data => {
            if (data) {
                try {
                    data = JSON.parse(data);
                    var spacer = ''; //fixing browser js rendering                        
                    if(data.Status == true)
                    { 
                        if(data.customerNumber != null)
                            this.customerNumber = data.customerNumber;
                        if(data.Division != null)                            
                            this.division = data.Division;
                        if(data.customerName != null)                            
                            this.customerName = data.customerName; 
                            
                        this.orderItems = [];  
                        if(data.quoteItems != null)
                        {                         
                            for(var i = 0; i < data.quoteItems.length; i++)
                            {
                                var quoteItem = {
                                    ItemNumber: data.quoteItems[i].ItemNumber,
                                    Description: data.quoteItems[i].Description,
                                    Quantity: data.quoteItems[i].Quantity,
                                    QuantityOnHand: data.quoteItems[i].QuantityOnHand,
                                    BackorderQuantity: data.quoteItems[i].BackorderQuantity,
                                    QuantityAvailable: data.quoteItems[i].QuantityAvailable,
                                    LineUniqueKey: data.quoteItems[i].LineUniqueKey,
                                    Selected: false
                                };
                                
                                this.orderItems = [...this.orderItems, quoteItem];
                            }
                        }

                        if(data.expediteItemList != null)
                        {
                            this.expediteItemList = [];
                            var pleaseSelectOption = {
                                label: 'Please Select',
                                value: 'Please Select'
                            };
                            this.expediteItemList = [...this.expediteItemList, pleaseSelectOption];
                            for(var i = 0; i < data.expediteItemList.length; i++)
                            {
                                var expediteItem = {
                                    label: data.expediteItemList[i],
                                    value: data.expediteItemList[i]
                                };
                                
                                this.expediteItemList = [...this.expediteItemList, expediteItem];
                            }
                        }
                    }
                    else
                    {
                        this.customerNumber = '';
                        this.customerName = '';
                        this.handleError(data.Message);
                    }           
                } catch (error) {
                    this.customerNumber = '';
                    this.customerName = '';
                    this.handleError(error);
                }
            } else if (error) {
                this.customerNumber = '';
                this.customerName = '';
                this.handleError(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            this.customerNumber = '';
            this.customerName = '';
            this.handleError(error);
        });
    }

    getAccount()
    {
        this.customerNumber = this.theRecord["li_customerNumber"];
        console.log("Account Start");
        this.loaded = false;
        retrievalByCustomerNumber({
            customerNumber: this.theRecord["li_customerNumber"]
        }).then(data => {
            if (data) {
                try {
                    data = JSON.parse(data);
                                            
                    if(data.Status)
                    {
                        if(data.CustomerName != null)
                            this.customerName = data.CustomerName;
                    }
                    else
                    {
                        this.customerNumber = '';
                        this.handleError(data.Message);
                    }                                                                                                     
                } catch (error) {
                    this.customerNumber = '';
                    this.handleError(error);
                }
            } else if (error) {
                this.customerNumber = '';
                this.handleError(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            this.customerNumber = '';
            this.handleError(error);
        });
    }

    handleManagerSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        managerSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleQuoteSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        quoteSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
        }
        console.log(event.target.name);
        console.log(name);
        console.log(id);
        this.theRecord[event.target.name] = id;
        this.theRecord['approvingManagerName'] = name;       
    }

    handleQuoteLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        this.selectedQuote = selection;
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
        }
        console.log(event.target.name);
        console.log(name);
        console.log(id);
        this.quoteId = id;
        this.quoteNumber = name;   
        //this.customerNumber = subTitle;    
    }

    handleInputOnChange(event) {
        if(event.target.name == "li_proposedDate")
            this.proposedDate = event.target.value;
        else if (event.target.name == "li_expediteEntireOrder")
        {
            this.expeditingEntireOrder = event.target.checked;
            if(event.target.checked == true)
            {
                this.orderItems.forEach(item => {
                    item.Selected = true;
                });
            }
        }
        else if (event.target.name == "li_selectItemsWONeededQty")
        {
            if(event.target.checked == true)
            {
                this.orderItems.forEach(item => {
                    if(item.QuantityAvailable < item.Quantity)
                        item.Selected = true;
                });
            }
        }
        else if (event.target.name == "lcb_expeditePartNumber")
        {
            this.expeditePartNumber = event.target.value;
            if((event.target.value).indexOf("Shipping") != -1)
            {
                if((this.orderTotal * 0.1) > 100)
                    this.retrievedExpediteFee = this.orderTotal * 0.1;
                else
                    this.retrievedExpediteFee = 100;                              
            }
            else
            {
                if((this.orderTotal * 0.2) > 250)
                    this.retrievedExpediteFee = this.orderTotal * 0.2;
                else
                    this.retrievedExpediteFee = 250;
            }
            if(this.chargingExpediteFee)
                this.expediteFeeAmount = this.retrievedExpediteFee;
            else
                this.expediteFeeAmount = 0;
        }
        else if (event.target.name == "li_isProductCurrentlyInStock")
            this.isProductCurrentlyInStock = event.target.checked;
        else if (event.target.name == "li_areWeChangingMOT")
            this.areWeChangingMOT = event.target.checked;
        else if (event.target.name == "li_chargingAnExpediteFee")
        {
            this.chargingExpediteFee = event.target.checked;
            if(event.target.checked)
                this.expediteFeeAmount = this.retrievedExpediteFee;
            else
                this.expediteFeeAmount = 0;
        }
        else if (event.target.name == "lcb_newMOT")
            this.newMOT = event.target.value;
        else if (event.target.name == "li_expediteFeeAmount")
            this.expediteFeeAmount = event.target.value;
        else if (event.target.name == "lcb_expediteReason")
            this.expediteReason = event.target.value;
        else if (event.target.name == "ta_expediteReasonNotes")
            this.expediteReasonNotes = event.target.value;
        else if (event.target.name == "approvingManager")
            this.approvingManagerId = event.target.value;       
        this.theRecord[event.target.name] = event.target.value;
    }

    closeErrorMessage()
    {
        this.displayError = false;
    }

    createRequest()
    {
        this.displayFCError = false;
        //6-17-2022 -- built new process for high value expedites
        // if(this.orderTotal != null && this.orderTotal > 25000)
        // {
        //     this.displayFCError = true;
        //     this.fcerror = 'Error: Orders over $25,000 cannot be Expedited.';
        // }
        var selectedItemCount = 0;
        this.orderItems.forEach(item => {
            if(item.Selected == true)
                selectedItemCount++;
        });
        
        if(this.proposedDate == null || this.proposedDate == '')
        {
            this.handleError('Error: You must enter a proposed date before submitting this request.');
        }
        else if(this.orderNumber == null || this.orderNumber == '')
        {
            this.handleError('Error: There is no order associated to this request. Please note, the expedite by quote functionality has been disabled as of 1/10/2023.');
        }
        else if(this.customerNumber == null || this.customerNumber == '')
        {
            this.handleError('Error: You must specify a customer number for this request.');
        }
        else if(this.approvingManagerId == null || this.approvingManagerId == '' || this.approvingManagerId == 'Please Select')
        {
            this.handleError('Error: You must specify a manager approver for this request.');
        }
        else if(this.expeditePartNumber == null || this.expeditePartNumber == '' || this.expeditePartNumber == 'Please Select')
        {
            this.handleError('Error: You must specify a expedite part number for this request.');
        }
        else if(this.expediteReason == null || this.expediteReason == '' || this.expediteReason == 'Please Select')
        {
            this.handleError('Error: You must specify a expedite reason for this request.');
        }
        else if(selectedItemCount == 0)
        {
            this.handleError('Error: You must specify at least one order/quote item before submitting this request.');
        }
        else if(this.expediteReason == 'Customer' && (this.expeditePartNumber.toLowerCase().indexOf('fabricate') != -1 || this.expeditePartNumber.toLowerCase().indexOf('fabrication') != -1) && !this.chargingExpediteFee)
        {
            this.handleError('Error: You must specify an expedite fee for a \'Customer\' fabrication expedite. Please check the \'Charging an Expedite Fee?\' box.');
        }
        else if (this.currentMOT != null && this.currentMOT == 'DS' && this.expeditePartNumber != null && this.expeditePartNumber.toLowerCase().indexOf('-3') == -1 && !this.changingMOT)
        {
            this.handleError('Error: The current MOT is DS.. therefore you must select a purchasing expedite part number (-3).');   
        }
        else
        {
            this.loaded = false;
            this.expediteName = "Expedite Request: ";
            if(this.orderNumber != null && this.orderNumber != '')
                this.expediteName = this.expediteName + "Order: " + this.orderNumber;
            else if(this.quoteNumber != null && this.quoteNumber != '')
                this.expediteName = this.expediteName + "Quote: " + this.quoteNumber;
            else
            {
                this.handleError('Error: There isn\'t a order or quote specified for this request.');   
            }

            createExpediteRequest({
                approvingManagerId: this.approvingManagerId,
                changingMOT: this.areWeChangingMOT,
                chargingExpediteFee: this.chargingExpediteFee,
                currentMOT: this.currentMOT,
                currentShipDate: new Date(this.currentShipDate),
                currentStep: 'Manager',
                customerNumber: this.customerNumber,
                division: this.division,
                expediteEntireOrder: this.expeditingEntireOrder,
                expediteFeeAmount: this.expediteFeeAmount,
                expeditePartNumber: this.expeditePartNumber,
                expediteReason: this.expediteReason,
                expediteReasonNotes: this.expediteReasonNotes,
                name: this.expediteName,
                newMOT: this.newMOT,
                orderEntryDate: new Date(this.orderEntryDate),
                orderNumber: this.orderNumber,
                productIsInStock: this.isProductCurrentlyInStock,
                proposedDate: new Date(this.proposedDate),
                quoteNumber: this.quoteNumber,
                status: "Submitted",
                orderItems: this.orderItems,
                manageName: '',
                quoteId: this.quoteId
            }).then(data => {
                if (data) {
                    try {
                        if(!data.Message.toLowerCase().includes("error"))
                        {
                            this.expediteId = data.ExpediteID;
                            this.expediteApprovalStepId = data.ApprovalStepID;
                            createNetSuiteExpedite({
                                expediteName: this.expediteName,
                                orderNumber: this.orderNumber,
                                division: this.division,
                                customerNumber: this.customerNumber,
                                location: this.location,
                                managerId: this.approvingManagerId,
                                expediteSalesforceId: this.expediteId,
                                expediteReason: this.expediteReasonNotes,
                                salesforceManagerApprovalStepId: this.expediteApprovalStepId,
                                requestorId: userId,
                                expediteProposedDate: this.proposedDate.toString(),
                                expediteFeeAmount: this.expediteFeeAmount.toString(),
                                newMOT: this.newMOT,
                                expediteReasonNotes: this.expediteReason,
                                quoteId: this.quoteId,
                                orderTotal: this.orderTotal
                            }).then(data => {
                                if (data) {
                                    try {
                                        if(!data.toLowerCase().includes("error"))
                                        {
                                            this.createExpediteButtonVisible = false;
                                            this.displayFCError = true;
                                            this.fcerror = data.Message;
                                            document.location = "https://" + location.hostname + "/lightning/r/Expedite_Request__c/" + this.expediteId + "/view";
                                            this.loaded = true;                                        
                                        }
                                        else
                                        {
                                            this.handleError(data); 
                                        }                   
                                    } catch (error) {
                                        this.handleError(error); 
                                    }
                    
                                } else if (error) {
                                    this.handleError(error); 
                                }
                            })
                            .catch(error => {
                                this.handleError(error); 
                            });
                            
                        }
                        else
                        {
                            this.handleError(data.Message); 
                        }                   
                    } catch (error) {
                        this.handleError(error); 
                    }

                } else if (error) {
                    this.handleError(error); 
                }
            })
            .catch(error => {
                this.handleError(error); 
            });
        }
    }

    handleItemChecked(event)
    {
        let Id = event.target.accessKey;
        var selectedItem = this.orderItems.filter(product => {
            return product.LineUniqueKey == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }

    handleQuantityChanged(event)
    {
        let Id = event.target.accessKey;
        var selectedItem = this.orderItems.filter(product => {
            return product.LineUniqueKey == Id;
        })[0];
        if(event.target.value != null && event.target.value != "")
            selectedItem.Quantity = parseFloat(event.target.value);
    }

    handleCheckAllChecked(event) {
        if (this.orderItems.length > 0) {           
            this.orderItems.forEach(item => {
                item.Selected = event.target.checked;
            });
        }
    }

    findAllocations(event){
        let Id = event.target.accessKey;
        var selectedItem = this.orderItems.filter(product => {
            return product.ItemNumber == Id;
        })[0];
        window.open("http://srvsrsapp/ReportServer/Pages/ReportViewer.aspx?%2fNetSuite%2fSales%2fAllocation+By+Item&rs:Command=Render&itemNo=" + selectedItem.ItemNumber, "_blank");
    }

    getOrderDetail(event){
        window.open("http://srvempportal/employeeportalEM10/Reports_NS.asp?DoReport=02&Tabid=0&mreportid=02&comp=1&ordno=" + this.orderNumber, "_blank");
    }

    closeFCErrorMessage(){
        this.displayFCError = false;
    }

    handleError(error) {
        alert(error);
        this.loaded = true;
    }
}