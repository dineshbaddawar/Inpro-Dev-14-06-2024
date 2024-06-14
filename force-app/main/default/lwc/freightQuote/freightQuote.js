import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import validateAddress from '@salesforce/apex/FreightQuoteHelper.validateShippingAddress';
import updateQuoteCityState from '@salesforce/apex/FreightQuoteHelper.updateQuoteShippingAddress';
import getAlternates from '@salesforce/apex/FreightQuoteHelper.getAlternates';
import getFreightQuoteByAlternate from '@salesforce/apexContinuation/FreightQuoteHelper.getFreightQuoteByAlternate';
import saveFreightQuote from '@salesforce/apex/FreightQuoteHelper.saveFreightQuote';
import saveAlternateGroupName from '@salesforce/apex/FreightQuoteHelper.saveAlternateGroupName';
import getFreightCarriers from '@salesforce/apex/FreightQuoteHelper.getFreightCarriers';
import requestManualFreightQuote from '@salesforce/apex/FreightQuoteHelper.RequestManualFreightQuote';
import removeAlternateFreight from '@salesforce/apex/FreightQuoteHelper.removeAlternateFreight';
import userId from '@salesforce/user/Id';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import getTerrZipWarning from '@salesforce/apex/FreightQuoteHelper.getTerrZipWarning';

export default class FreightQuote extends LightningElement {

    @api recordId;
    @track loadMessage = 'Loading...';
    loaded = false;
    groupAlternates = false;
    @track fQuoteList = [];
    @track alternateGroupList = [];
    //TODO: get these from service
    @track negotiatedFreightOptions = [];
    @track currentNegotiatedFreightOption;
    @track groupName = '';
    @track errorMessage = '';
    @track showError = false;
    @track altNames = [];
    @track removeCount = 0;
    @track reset = false;
    @track addressConfirmationScreenOpen = false;
    @track retrievedCity = '';
    @track retrievedState = '';
    @track originalCity = '';
    @track originalState = '';
    
    connectedCallback() {
        // initialize component
        this.validateShippingAddress();
        
    }

    @wire(getFreightQuoteByAlternate)
    wiredContinuation;

    validateShippingAddress()
    {
        validateAddress({recordId: this.recordId}).then(data => 
        {
            if (data) 
            {
                try 
                {
                    var results = JSON.parse(data);
                    console.log(results);
                    if(results.Status != null && results.Status == false)
                    {
                        if(results.Message == 'City and state mismatch')
                        {
                            this.originalCity = results.OriginalCity;
                            this.originalState = results.OriginalState;
                            this.retrievedCity = results.RetrievedCity;
                            this.retrievedState = results.RetrievedState;
                            this.addressConfirmationScreenOpen = true;
                            this.loaded = true;
                        }
                        else
                        {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error!',
                                message: 'Details: ' + results.Message,
                                variant: 'warning'
                            }));
                            this.loaded = true;
                        }
                    }
                    else
                    {
                        this.loadFreightQuotes();
                        this.loadFreightOptions();
                        this.loadZipWarning();
                    }                   
                } catch (error) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: 'Error validating shipping address...',
                        variant: 'warning'
                    }));
                    this.loaded = true;
                }
            } else if (error) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error validating shipping address...',
                    variant: 'warning'
                }));
                this.loaded = true;
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Error validating shipping address...',
                variant: 'warning'
            }));
            this.loaded = false;
        });
    }   

    runFreightOriginalAddress()
    {
        this.addressConfirmationScreenOpen = false;
        this.loaded = false;
        this.loadFreightQuotes();
        this.loadFreightOptions();
        this.loadZipWarning();
    }

    runFreightRetrievedAddress()
    {
        this.addressConfirmationScreenOpen = false;
        this.loaded = false;
        updateQuoteCityState({quoteId: this.recordId, city: this.retrievedCity, state: this.retrievedState}).then(result =>{
            if (result == true)
            {              
                this.loadFreightQuotes();
                this.loadFreightOptions();
                this.loadZipWarning();
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error updating quote city/state...',
                    variant: 'warning'
                }));
                this.loaded = false;
            }
        });
        
    }

    loadZipWarning(){
        getTerrZipWarning({recordId: this.recordId}).then(message =>{
            //console.log('Warning? ' + message);
            if (message != '')
            {
                this.hasTerrZipWarning = true;
                this.terrZipMessage = message;
            }
        });
    }

    loadFreightOptions() {
        getFreightCarriers().then(data => 
        {
            if (data) 
            {
                try 
                {
                    var pleaseSelectOption = {
                        value: '',
                        label: 'Please Select',
                        description: ''
                    };

                    var myJSON = JSON.stringify(data);
                    //console.log(myJSON);

                    this.negotiatedFreightOptions.push(pleaseSelectOption);

                    data.forEach(carrier => {
                        var carrierOption = {
                            value: carrier.Carrier_Code__c,
                            label: carrier.Name,
                            description: ''
                        };
                        this.negotiatedFreightOptions.push(carrierOption);
                    });

                } catch (error) {
                    console.log("Error Loading Freight Carriers: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }

        })
        .catch(error => {
            // TODO: handle error
            console.log(error);
        });
    }

    refreshGroup(event){
        var key = event.target.accessKey;
        var date = Date().toLocaleString();
        console.log(event);
        console.log('Alternate Id is ' + key);
        this.loaded = false;
        getFreightQuoteByAlternate({
            alternateId: key,
            cache: date
        }).then(data =>{
            var quote = data[0];

            //clear existing options
            let selectedGroup = this.fQuoteList.filter(function (group) {
                return group.GroupName === quote.GroupName;
            });
            let selectedAlternate = selectedGroup[0].Alternates.filter(function (alt) {
                return alt.AlternateId === quote.AlternateId;
            });

            selectedAlternate[0].FreightOptions = [];

            //rebuild options
            data.forEach(quote2 => {
                this.createNewFreightOption(selectedAlternate[0], quote2);
                this.loaded = true;
            });
        });
    }

    handleOpenMFQ(event)
    {
        let url = event.target.name;
        window.open(url, '_blank');
    }
    
    loadFreightQuotes() {
        var date = Date().toLocaleString();
        //console.log(date);
        //console.log(this.recordId);

        //Get all alternates under quote
        getAlternates({recordId: this.recordId}).then(alts => {
            console.log(alts);
            if (alts != null && alts.length > 0)
            {
                var altCount = alts.length;
                console.log('Total alternates: ' + altCount);
                var currentCount = 0;
                //Call freight one alternate at a time (this helps to avoid the 2 min timeout)

                alts.forEach(alt => 
                {
                    if (this.altNames.indexOf(alt.Name__c) == -1 || alt.Freight_Amount__c > 0)
                    {
                        this.altNames.push(alt.Name__c);
                        
                        getFreightQuoteByAlternate({alternateId: alt.Id}).then(data =>{
                            this.loadMessage = 'Loading freight for Alternate #' + (currentCount + 1) + ': ' + alt.Name__c;
                            console.log(this.loadMessage);
                            console.log(data);
                            //console.log(data);
                            
                            data.forEach(quote => {
                                console.log('MFQ? ' + alt.Manual_Freight_Quote_Request_Link__c);
                                quote.HasManualFreightQuote = alt.Manual_Freight_Quote_Request_Link__c != undefined;
                                quote.ManualFreightQuoteURL = alt.Manual_Freight_Quote_Request_Link__c;
                                quote.ManualFreightQuoteNumber = alt.Manual_Freight_Quote_Request_Link__c != undefined ?
                                    alt.Manual_Freight_Quote_Request_Link__c.substring(alt.Manual_Freight_Quote_Request_Link__c.indexOf('mQuote=') + 7) :
                                    '';
                                if (this.fQuoteList.length > 0) {
                                    let selectedGroup = this.fQuoteList.filter(function (group) {
                                        return group.GroupName === quote.GroupName;
                                    });
                                    
                                    if (selectedGroup.length > 0) //--Group Exists
                                    {
                                        
                                        //if the group exists
                                        //check to see if the alternate already exists                                    
                                        let selectedAlternate = selectedGroup[0].Alternates.filter(function (alt) {
                                            return alt.AlternateId === quote.AlternateId;
                                        });
        
                                        if (selectedAlternate.length > 0) {
                                            //the alternate exists, only create the option
                                            
                                            this.createNewFreightOption(selectedAlternate[0], quote);
                                        } else {
                                            //the alternate doesn't exist, create both the alternate and the option
                                            
                                            this.createNewAlternate(selectedGroup[0], quote);
                                        }
                                    } else //--Group Doesn't exist      
                                    {
                                        //the group doesn't exist
                                        //create the group, alternate, and option 
                                        
                                        this.createNewAlternateGroup(quote);
                                    }
                                } 
                                else
                                {
                                    console.log('Create new alternate group (outside)');
                                    this.createNewAlternateGroup(quote); //--first one
                                }
                                
                            });

                            currentCount++;
                            console.log('Alternates finished: ' + currentCount);
                            //Stop spinner once all alts finish
                            if (currentCount == altCount)
                            {
                                this.loaded = true;
                                this.loadMessage = 'Loading...';
                                this.buildSameNameWarnings();
                            }
                        }).catch(error => {
                            var errorMEssage = "Error getting freight for alternate " + alt.Name__c + ": " + error;
                            this.loaded = true;
                            this.loadMessage = 'Loading...';
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Error!',
                                    message: errorMEssage,
                                    variant: 'warning',
                                }));
                            console.log(errorMEssage);
                        });
                    }
                    else //Skip alternate and decrement total count
                    {
                        altCount--;
                        if (currentCount == altCount) //Done loading if at end of new count
                        {
                            this.loaded = true;
                            this.loadMessage = 'Loading...';
                        }
                    }
                });
            }
            else{
                this.loaded = true;
                this.loadMessage = 'Loading...';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Warning!',
                    message: 'No alternates were found for this quote.',
                    variant: 'warning',
                }));

            }
        }).catch(error => {
            console.log(error);
            var errorMEssage = "Error getting freight carriers: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
            this.loaded = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMEssage,
                    variant: 'warning',
                }));
            console.log(errorMEssage);
        });
    }

    buildSameNameWarnings()
    {
        let nameArray = [];
        this.fQuoteList.forEach(group => {
            group.Alternates.forEach(Alt => {
                nameArray.push(Alt.Alternate);
            });
        });

        this.fQuoteList.forEach(group => {
            group.Alternates.forEach(Alt => {
                console.log('Alternates # of name ' + Alt.Alternate + ' is ' + nameArray.filter(x => x == Alt.Alternate).length);
                if (nameArray.filter(x => x == Alt.Alternate).length > 1)
                {
                    Alt.IsSameNameSplit = true;
                }
            });
        });
    }

    removeFreight(event){
        var key = event.target.accessKey;
        this.loaded = false;
        this.recursiveRemoveFreight(key,true);
    }

    
    recursiveRemoveFreight(altId, firstCall)
    {
        this.removeCount++;
        console.log('Remove Count: ' + this.removeCount);
        removeAlternateFreight({alternateId: altId}).then(data =>{
            if (data == '')
            {
                this.fQuoteList.forEach(group => {
                    let selectedAlt = group.Alternates.filter(function (alt) {
                        return alt.AlternateId === altId;
                    })[0];
                    let tempArray = selectedAlt.FreightOptions;
                    selectedAlt.FreightOptions = [];
                    tempArray.forEach(option => {
                        option.Selected = false
                        option.ShowFreightOptions = false;
                    })
                    selectedAlt.FreightOptions = tempArray;
                    console.log('Removed freight for alt Id ' + altId);

                    if (firstCall)
                    {
                        this.fQuoteList.forEach(gr =>{
                            let sameNameAlts = gr.Alternates.filter(x => x.Alternate == selectedAlt.Alternate && x.AlternateId !== altId);
                            sameNameAlts.forEach(x => {
                                this.reset = true;
                                this.recursiveRemoveFreight(x.AlternateId, false);
                            });
                        });
                    }
                });
                if (--this.removeCount == 0)
                {
                    if (this.reset)
                    {
                        this.loaded = false;
                        this.fQuoteList = [];
                        this.altNames = [];
                        this.loadFreightQuotes();
                        this.groupAlternates = false;
                    }
                    else
                    {
                        this.loaded = true;
                    }
                } 
                console.log('Remove Count: ' + this.removeCount);
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error!',
                    message: data,
                    variant: 'warning'
                }));
                this.loaded = true;
            }
            
        });
    }

    
    saveFreight() {

        this.loaded = false;


        //Convert the UI object so it can be updated
        var fQuotes = [];
        console.log("start save");
        //get the list of selected options foreach alternate
        this.fQuoteList.forEach(group => {
            group.Alternates.forEach(Alt => {
                console.log(Alt.FreightOptions.length);
                try {
                    let currentOption = Alt.FreightOptions.filter(function (option) {
                        return option.Selected === true;
                    })[0];

                    console.log(currentOption.AlternateId);
                    console.log(currentOption.TotalCharge);


                    //create the fQuote object
                    var fQuote = {
                        AlternateId: Alt.AlternateId,
                        TotalCharge: currentOption.TotalCharge,
                        DriverWaitChrg: currentOption.DriverWaitChrg,
                        DriverWait: currentOption.DriverWait,
                        InsideDeliveryChrg: currentOption.InsideDeliveryChrg,
                        InsideDelivery: currentOption.InsideDelivery,
                        LiftGateChrg: currentOption.LiftGateChrg,
                        LiftGate: currentOption.LiftGate,
                        LoadingDockChrg: currentOption.LoadingDockChrg,
                        LoadingDock: currentOption.LoadingDock,
                        ServiceCall: currentOption.ServiceCall,
                        ServiceCallChrg: currentOption.ServiceCallChrg,
                        ServiceCallNote: currentOption.ServiceCallNote,
                        QuotedFromLocation: currentOption.QuotedFromLocation,
                        //get carrier code
                        FreightCarrierId: currentOption.FreightCarrierId,
                        CarrierCode: currentOption.CarrierCode,
                        ManualFreightQuoteID: currentOption.ManualFreightQuoteID,
                        ShippingDescription: currentOption.ShippingDescription

                    };
                    fQuotes.push(fQuote);
                } catch (error) {
                    console.log(error);
                }
            });
        });

        console.log("end loop")
        var myJSON = JSON.stringify(fQuotes);
        console.log(myJSON);

        saveFreightQuote({
                FreightQuotes: fQuotes
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        var json = JSON.stringify(data);
                        console.log(json);

                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: this.toastMessage,
                            variant: 'success',
                            mode: 'sticky'
                        }));

                        this.closeQuickAction();

                    } catch (error) {
                        console.log("Error Saving Freight Quotes: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;


            })
            .catch(error => {
                // TODO: handle error
                var jsonError = JSON.stringify(error);
                console.log("Error saving freight quote: " + error.status + " " + jsonError);
                this.loaded = true;
            });
    }

    handleRequestManualQuoteOnClick(event) {
        try {


            this.loaded = false;
            var OptionId = event.target.accessKey;
            var AlternateId = event.target.name;

            //TODO: Uncomment this once we have a working dev backend        
            var selectedOption = this.getSelectedOption(OptionId, AlternateId);
            var notes = selectedOption.TrafficNotes;            
            var isRush = selectedOption.RushRequested;
            var shippingDescription = selectedOption.ShippingDescription;
            console.log("requesting " + OptionId + " " + AlternateId);
            requestManualFreightQuote({
                    alternateId: AlternateId,
                    quoteId: this.recordId,
                    userId: userId,
                    notes: notes,                    
                    isRush: isRush,
                    shippingDescription: shippingDescription
                }).then(data => {
                    if (data) {
                        try {
                            console.log(data);
                            this.errorMessage = "Manual Quote Request Sent. Your request ID is: " + data;
                            this.showError = true;
                            console.log("Manual Quote Request Sent. Your request ID is: " + data);
                            var json = JSON.stringify(data);
                            console.log(json);
                        } catch (error) {
                            console.log("Error Requesting Manual Freight Quote: " + error);
                        }
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;

                })
                .catch(error => {
                    // TODO: handle error
                    var jsonError = JSON.stringify(error);
                    console.log("Error Requesting Manual Freight Quote: " + jsonError);
                    this.loaded = true;
                });

        } catch (error) {
            var jsonError = JSON.stringify(error);
            console.log("Error Requesting Manual Freight: " + jsonError);
            this.loaded = true;
        }

    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }
    handleCancelManualQuoteOnClick(event) {
        var QuoteID = event.target.accessKey;
        var OptionID = event.target.name;
        console.log("cancelling" + QuoteID + " " + OptionID);
    }

    handleInternationalNotesOnchange(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.value;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.ShippingDescription = value;
    }

    handleRushRequestChecked(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.checked;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.RushRequested = value;
    }

    handleLiftGateChecked(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.checked;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        if (selectedOption != null)
            selectedOption.LiftGate = value;
    }

    handleNegotiatedCostOnchange(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.value;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.TotalCharge = value;
    }

    handleNegotiatedComboBoxOnchange(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.value;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.CarrierCode = value;
    }

    handleNotesToTrafficOnchange(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.value;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.TrafficNotes = value;
    }

    handleManualQuoteIDOnchange(event) {
        var OptionId = event.target.accessKey;
        var AlternateId = event.target.name;
        var value = event.target.value;
        var selectedOption = this.getSelectedOption(OptionId, AlternateId);
        selectedOption.ManualFreightQuoteID = value;
        console.log(value);
    }

    handleOptionSelected(event) {

        var OptionId = event.target.accessKey;
        var AlternateId = event.target.getAttribute('name');
        console.log(OptionId);
        console.log(AlternateId);

        this.fQuoteList.forEach(group => {
            let selectedAlt = group.Alternates.filter(function (alt) {
                return alt.AlternateId === AlternateId;
            })[0];
            if (selectedAlt != null) {
                console.log("alt: " + selectedAlt.AlternateId);

                let selectedOption = selectedAlt.FreightOptions.filter(function (option) {
                    return option.OptionId === OptionId;
                })[0];

                console.log("option: " + selectedOption.OptionId);

                let currentOption = selectedAlt.FreightOptions.filter(function (option) {
                    return option.Selected === true;
                });

                console.log("currentOptionLength: " + currentOption.length);

                currentOption.forEach(option => {
                    option.Selected = false
                    option.ShowFreightOptions = false;
                });

                if (selectedOption.IsFreight == true) {
                    selectedOption.ShowFreightOptions = true;
                }
                selectedOption.Selected = true;
                console.log("OptionID: " + selectedOption.OptionId);
                console.log(selectedOption.Selected);
            }
        });
    }

    getSelectedOption(OptionId, AlternateId) {
        var Option;
        this.fQuoteList.forEach(group => {
            let selectedAlt = group.Alternates.filter(function (alt) {
                return alt.AlternateId === AlternateId;
            })[0];
            if (selectedAlt != null) {
                let selectedOption = selectedAlt.FreightOptions.filter(function (option) {
                    return option.OptionId === OptionId;
                })[0];
                Option = selectedOption;
            }
        });
        return Option;
    }

    handleSaveGroupOnClick(event) {
        this.loaded = false;
        this.updateAlternateGroupNames(false)
    }

    handleDeleteGroupOnClick(event) {
        this.loaded = false;
        this.updateAlternateGroupNames(true)
    }

    handleGroupCheckBoxOnChange(event) {
        var altId = event.target.accessKey;
        let selectedAlt = this.alternateGroupList.filter(function (alt) {
            return alt.AlternateId === altId;
        })[0];

        selectedAlt.Selected = event.target.checked;
    }

    updateAlternateGroupNames(deleteName) {

        var groupName = this.groupName;
        if (deleteName == true)
            groupName = ''

        let selectedAlts = this.alternateGroupList.filter(function (alt) {
            return alt.Selected === true;
        })

        selectedAlts.forEach(alt => {
            alt.GroupName = groupName;
        });

        saveAlternateGroupName({
                FreightQuotes: selectedAlts
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        var json = JSON.stringify(data);
                        console.log(json);
                    } catch (error) {
                        console.log("Error Saving Freight Group Names: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;

            })
            .catch(error => {
                // TODO: handle error
                var jsonError = JSON.stringify(error);
                console.log("Error saving freight Group Names: " + error.status + " " + jsonError);
                this.loaded = true;
            });
    }

    handleBackOnClick(event) {
        this.loaded = false;
        this.fQuoteList = [];
        this.altNames = [];
        this.loadFreightQuotes();
        this.groupAlternates = false;
    }

    handleGroupAlternatesClick(event) {
        this.loaded = false;
        this.alternateGroupList = [];
        this.fQuoteList.forEach(group => {
            group.Alternates.forEach(Alt => {
                try {
                    //Create the grouping objects                
                    var newAlt = {
                        AlternateId: Alt.AlternateId,
                        GroupName: group.GroupName,
                        AlternateLabel: Alt.AlternateLabel,
                        IsSameNameSplit: Alt.IsSameNameSplit,
                        HasManualFreightQuote: Alt.HasManualFreightQuote,
                        ManualFreightQuoteURL: Alt.Manual_Freight_Quote_Request_Link__c,
                        ManualFreightQuoteNumber: Alt.ManualFreightQuoteNumber
                    };
                    this.alternateGroupList.push(newAlt);
                } catch (error) {
                    console.log(error);
                }
            });
        });
        this.groupAlternates = true;
        this.loaded = true;
    }

    handleGroupAlternatesOnChange(event) {
        this.groupName = event.target.value;
    }

    //--Methods to build UI Object
    createNewAlternateGroup(quote) {

        var newAlternateGroup = {
            GroupLabel: quote.GroupLabel,
            GroupName: quote.GroupName,
            Alternates: []
        };

        var newAlternate = this.createAlternate(quote);
        var newOption = this.createOption(quote);

        console.log("adding new group, alternate, and option: " + newAlternate.Alternate + " " + newAlternate.AlternateId);
        newAlternateGroup.Alternates.push(newAlternate);
        newAlternate.FreightOptions.push(newOption);
        this.fQuoteList.push(newAlternateGroup);


    }

    createNewAlternate(group, quote) {

        var newAlternate = this.createAlternate(quote);
        var newOption = this.createOption(quote);
        //console.log("adding new alternate and option: " + newAlternate.Alternate + " " + newAlternate.AlternateId);
        newAlternate.FreightOptions.push(newOption);
        group.Alternates.push(newAlternate);
    }

    createNewFreightOption(Alternate, quote) {
        var newOption = this.createOption(quote);
        //console.log("adding just a new option: " + quote.Alternate + " " + quote.AlternateId);
        Alternate.FreightOptions.push(newOption);
    }

    createOption(quote) {
        var newOption = {
            OptionId: quote.OptionId,
            Selected: quote.Selected,
            AlternateId: quote.AlternateId,
            CarrierCode: quote.CarrierCode,
            CarrierDetail: quote.CarrierDetail,
            Alternate: quote.Alternate,
            Charge: Math.round(quote.Charge * 100) / 100.0,
            TotalCharge: Math.round(quote.TotalCharge * 100) / 100.0,
            TimeInTransit: quote.TimeInTransit,
            TimeInTransitDesc: quote.TimeInTransitDesc,
            IsFreight: quote.IsFreight,
            LiftGate: quote.LiftGate,
            LiftGateChrg: quote.LiftGateChrg,
            HasLiftGate: quote.HasLiftGate,
            FreightCarrierId: quote.FreightCarrierId,
            IsNegotiatedFreight: quote.IsNegotiatedFreight,
            IsMFQ: quote.IsMFQ,
            TrafficNotes: quote.TrafficNotes,
            ManualFreightQuoteID: quote.ManualFreightQuoteID,
            RushRequested: quote.RushRequested,
            ShippingDescription: quote.ShippingDescription,
            ShowFreightOptions: quote.ShowFreightOptions,
            DriverWait: quote.DriverWait,
            DriverWaitChrg: quote.DriverWaitChrg,
            InsideDeliveryChrg: quote.InsideDeliveryChrg,
            InsideDelivery: quote.InsideDelivery,
            LoadingDock: quote.LoadingDock,
            LoadingDockChrg: quote.LoadingDockChrg,
            ServiceCall: quote.ServiceCall,
            ServiceCallChrg: quote.ServiceCallChrg,
            ServiceCallNote: quote.ServiceCallNote,
            QuotedFromLocation: quote.QuotedFromLocation,
            ManualFreightQuotes: []
        };

        if (quote.ManualFreightQuotes != null) {
            quote.ManualFreightQuotes.forEach(mfq => {
                var newMFQ = {
                    ID: mfq.ID,
                    Carrier: mfq.Carrier,
                    Amount: mfq.Amount,
                    UpdatedBy: mfq.UpdatedBy,
                    UpdatedOn: mfq.UpdatedOn,
                    AltNo: mfq.AltNo,
                    Rev: mfq.Rev
                }

                newOption.ManualFreightQuotes.push(newMFQ);
            });

        }

        return newOption;
    }

    createAlternate(quote) {
        console.log('Quote is ');
        console.log(quote);
        var newAlternate = {
            OptionId: quote.OptionId,
            AlternateId: quote.AlternateId,
            CarrierCode: quote.CarrierCode,
            CarrierDetail: quote.CarrierDetail,
            Alternate: quote.Alternate,
            AlternateLabel: quote.AlternateLabel,
            ManualFreightQuoteNumber: quote.ManualFreightQuoteNumber,
            HasManualFreightQuote: quote.HasManualFreightQuote,
            ManualFreightQuoteURL: quote.ManualFreightQuoteURL,
            FreightOptions: []
        };

        return newAlternate;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}