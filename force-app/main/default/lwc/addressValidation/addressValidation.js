import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import GetObjectNameById from '@salesforce/apex/AddressValidationHelper.GetObjectNameById';
import ValidateAddressOne from '@salesforce/apex/AddressValidationHelper.ValidateAddressOne';
import ValidateAddressTwo from '@salesforce/apex/AddressValidationHelper.ValidateAddressTwo';
import GetCountries from '@salesforce/apex/AddressValidationHelper.GetCountries';
import UpdateAddress from '@salesforce/apex/AddressValidationHelper.UpdateAddress';

export default class AddressValidation extends LightningElement {
    @api recordId;
    @track objectName = '';
    @track isLoaded = false;
    @track isAccount = false;
    @track isAddressOne = true;
    @track isAddressTwo = false;
    @track isContact = false;
    @track isSampleRequest = false;

    @track enableProposed = true;

    @track addressValidationHeaderText = 'Address Validation';
    @track aLine1;
    @track bLine1;
    @track aLine2;
    @track bLine2;
    @track aCity;
    @track bCity;
    @track aState;
    @track bState;
    @track aZip;
    @track bZip;
    @track status = false;
    @track message = '';
    @track DPVValidated = false;
    @track DPVIndicator;
    @track DPVDetail;
    @track runAgain = false;
    /*@track countryList = [];
    @track aCountry = '';
    @track bCountry = '';*/

    connectedCallback()
    {
        /*GetCountries().then(results =>{
            var data = JSON.parse(results);
            for(var i = 0; i < data.length; i++)
            {
                this.countryList.push({value: data.value, label: data.label});
            }
            
        })*/
        GetObjectNameById({recordId: this.recordId}).then(results =>{
            console.log(results);
            this.objectName = results;
            if (results == 'Account') this.addressValidationHeaderText = 'Shipping Address Validation';
            else if (results == 'Contact') this.addressValidationHeaderText = 'Mailing Address Validation';
            
            this.validateAddressOne(false);
        });
    }

    handleRerun(){
        this.isLoaded = false;
        if (this.isAddressOne)
        {
            this.validateAddressOne(true);
        }
        else{
            this.validateAddressTwo(true);
        }
        this.runAgain = false;
    }

    handleInput(event){
        console.log(event.target.name);
        if (event.target.name == 'aLine1')
        {
            this.aLine1 = event.target.value;
        }
        else if (event.target.name == 'aLine2')
        {
            this.aLine2 = event.target.value;
        }
        else if (event.target.name == 'aCity')
        {
            this.aCity = event.target.value;
        }
        else if (event.target.name == 'aState')
        {
            this.aState = event.target.value;
        }
        else if (event.target.name == 'aZip')
        {
            this.aZip = event.target.value;
        }
        this.runAgain = true;
    }

    handleOriginal(){
        console.log("handleOriginal start...");
        this.isLoaded = false;
        this.updateAddress(false);
    }

    handleProposed(){
        console.log("handleProposed start...");
        this.isLoaded = false;
        this.updateAddress(true);
    }

    validateAddressOne(updateAddress){
        ValidateAddressOne({recordId: this.recordId, objectName: this.objectName, updateAddress: updateAddress,
            Line1: this.aLine1, Line2: this.aLine2, City: this.aCity, State: this.aState, Zip: this.aZip}).then(data => 
        {      
            data = JSON.parse(data);
            console.log(data);
            this.isLoaded = true;
            this.aLine1 = data.OriginalStreet1;
            this.bLine1 = data.Street1;
            this.aLine2 = data.OriginalStreet2;
            this.bLine2 = data.Street2;
            this.aCity = data.OriginalCity;
            this.bCity = data.City;
            this.aState = data.OriginalState;
            this.bState = data.State;
            this.aZip = data.OriginalZipCode;
            this.bZip = data.ZipCode;
            this.status = data.Status;
            this.message = data.Message;
            this.DPVValidated = data.DPVValidated;
            this.DPVIndicator = data.DPVIndicator;
            this.DPVDetail = data.DPVDetail;

            if (data.ZipCode == '' || data.ZipCode == null)
            {
                this.enableProposed = false;
            }
            else{
                this.enableProposed = true;
            }

            if (data.ResultCode == 0) //valid
            {
                this.updateAddress(true);
            }
        });
    }

    validateAddressTwo(updateAddress){
        this.isLoaded = false;
        console.log("validateAddressTwo start...");
        if (this.objectName == 'Account') this.addressValidationHeaderText = 'Billing Address Validation';
        else if (this.objectName == 'Contact') this.addressValidationHeaderText = 'Contact Address Validation';

        ValidateAddressTwo({recordId: this.recordId, objectName: this.objectName, updateAddress: updateAddress,
            Line1: this.aLine1, Line2: this.aLine2, City: this.aCity, State: this.aState, Zip: this.aZip}).then(data =>
        {
            this.isLoaded = true;
            console.log(data);
            data = JSON.parse(data);
            this.isLoaded = true;
            this.aLine1 = data.OriginalStreet1;
            this.bLine1 = data.Street1;
            this.aLine2 = data.OriginalStreet2;
            this.bLine2 = data.Street2;
            this.aCity = data.OriginalCity;
            this.bCity = data.City;
            this.aState = data.OriginalState;
            this.bState = data.State;
            this.aZip = data.OriginalZipCode;
            this.bZip = data.ZipCode;
            this.status = data.Status;
            this.message = data.Message;
            this.DPVValidated = data.DPVValidated;
            this.DPVIndicator = data.DPVIndicator;
            this.DPVDetail = data.DPVDetail;

            if (data.ResultCode == 0) //valid
            {
                if (this.objectName == 'Account' || this.objectName == 'Contact')
                {
                    this.updateAddress(true);
                }

            }
            else{
                //Give user option to override or use proposed value
            }
        });
    }

    updateAddress(isValid){
        console.log("updateAddress start...");
        this.isLoaded = false;
        console.log('aState is "' + this.aState +'"');
        console.log('bState is "' + this.bState +'"');
        if (isValid)
        {
            UpdateAddress({
                recordId: this.recordId,
                objectName: this.objectName,
                ValidationType: 'Validated',
                Street1: this.bLine1,
                Street2: this.bLine2,
                City: this.bCity,
                State: this.bState,
                ZipCode: this.bZip,
                isFirstAddress: this.isAddressOne
            }).then(message =>{
                this.isLoaded = true;

                if(message != '') {//error message
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'There was a problem updating this address: ' + message,
                        variant: 'warning'
                    }));
                    return;
                }

                var moveToAddressTwo = false;
                var message = 'Address marked as validated.';

                if (this.isAddressOne && this.objectName == 'Account'){
                    moveToAddressTwo = true;
                    message = 'Shipping Address marked as validated.';
                }
                else if (!this.isAddressOne && this.objectName == 'Account') {
                    message = 'Billing Address marked as validated.';
                } 
                else if (this.isAddressOne && this.objectName == 'Contact') {
                    moveToAddressTwo = true;
                    message = 'Mailing Address marked as validated.';
                }
                else if (!this.isAddressOne && this.objectName == 'Contact') {
                    message = 'Contact Address marked as validated.';
                }
                

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation',
                    message: message,
                    variant: 'success'
                }));

                if (moveToAddressTwo)
                {
                    this.isAddressOne = false;
                    this.isAddressTwo = true;
                    this.validateAddressTwo(false);
                }
                else{
                    console.log('Close application');
                    if (this.objectName == 'Sample_Request__c') window.location.reload();
                    this.closeQuickAction();
                }
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'There was a problem updating this address: ' + error.statusText(),
                    variant: 'warning'
                }));
            });
        }
        else{
            UpdateAddress({
                recordId: this.recordId,
                objectName: this.objectName,
                ValidationType: 'Overwritten',
                Street1: this.aLine1,
                Street2: this.aLine2,
                City: this.aCity,
                State: this.aState,
                ZipCode: this.aZip,
                isFirstAddress: this.isAddressOne
            }).then(message =>{
                this.isLoaded = true;

                if(message != '') {//error message
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'There was a problem updating this address: ' + message,
                        variant: 'warning'
                    }));
                    return;
                }
                
                var moveToAddressTwo = false;
                var message = 'Address validation marked as overwritten by user.';

                if (this.isAddressOne && this.objectName == 'Account'){
                    moveToAddressTwo = true;
                    message = 'Shipping Address validation marked as overwritten by user.';
                }
                else if (!this.isAddressOne && this.objectName == 'Account') {
                    message = 'Billing Address validation marked as overwritten by user.';
                } 
                else if (this.isAddressOne && this.objectName == 'Contact') {
                    moveToAddressTwo = true;
                    message = 'Mailing Address validation marked as overwritten by user.';
                }
                else if (!this.isAddressOne && this.objectName == 'Contact') {
                    message = 'Contact Address validation marked as overwritten by user.';
                }
                
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation',
                    message: message,
                    variant: 'success'
                }));

                if (moveToAddressTwo)
                {
                    this.isAddressOne = false;
                    this.isAddressTwo = true;
                    this.validateAddressTwo(false);
                }
                else{
                    this.closeQuickAction();
                    window.location.reload();
                }
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'There was a problem updating this address: ' + error.statusText(),
                    variant: 'warning'
                }));
            });
        }
    }

    closeQuickAction() {
        console.log("begin closeQuickAction...");
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}