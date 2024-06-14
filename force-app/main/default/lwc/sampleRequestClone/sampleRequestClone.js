import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import GetSampleRequest from '@salesforce/apex/NewSampleItemHelper.GetSampleRequest';
import GetSampleRequestItems from '@salesforce/apex/NewSampleItemHelper.GetSampleRequestItems';
import CloneSampleRequest from '@salesforce/apex/SampleRequestCloneHelper.CloneSampleRequest';

export default class SampleRequestClone extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track sampleItems;
    @track hasInactiveItems = false;

    @track sampleItemColumns = [
        {
            label: '',
            fieldName: '',
            type: 'action',
            sortable: false
        },
        {
            label: 'Name', 
            fieldName: 'SRLink', 
            type: 'url', 
            initialWidth: 100, 
            sortable: true, 
            typeAttributes: 
            {
                label: 
                { 
                    fieldName: 'Name' 
                },
                target: '_blank'
            }
        },
        {
            label: 'Product Name', 
            fieldName: 'PrLink', 
            type: 'url', 
            initialWidth: 100, 
            sortable: true, 
            typeAttributes: 
            {
                label: 
                { 
                    fieldName: 'ProductName' 
                },
                target: '_blank'
            }
        },
        {label: 'Quantity', initialWidth: 100, fieldName: 'Quantity__c'},
        {label: 'Available Inventory',initialWidth: 110, fieldName: 'Available_Inventory__c'},
        {label: 'Division', initialWidth: 100, fieldName: 'Div_Abbreviation__c'},
        {label: 'Is Active', initialWidth: 100, fieldName: 'Product_Is_Active__c'},
    ];

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleChange(e)
    {
        console.log(e);
    }

    connectedCallback(){
        GetSampleRequestItems({recordId : this.recordId}).then(data => {
            this.sampleItems = data;
            let index = 1;
            this.sampleItems.forEach(x => {
                x.Actions = [
                    { 
                      isCheckbox: true,
                      checked: true,
                      style: 'margin-right:10px;padding-top:5px;padding-bottom:10px;border-radius:5px;',
                      variant: 'border-inverse',
                      onclick: (function(event){
                        this.handleSelect(event);
                      }).bind(this)
                    }
                ];
                //x.Sample_Product__r_Name = Sample_Product.Name;
                x.Selected = true;
                if (x.Sample_Product__r != undefined)
                {
                    x.ProductName = x.Sample_Product__r.Name;
                    x.PrLink = '/' + x.Sample_Product__c;
                }
                x.SRLink = '/' + x.Id;
                x.RowId = index++;
                if (x.Product_Is_Active__c == "false" || x.Product_Is_Active__c == false)
                {
                    this.hasInactiveItems = true;
                    x.Actions[0].checked = false;
                    x.Selected = false;
                }
            })
            this.loaded = true;
        });
    }

    handleClone(e){
        e.preventDefault();
        let fields = e.detail.fields;

        //Test

        let data = JSON.stringify(fields);
        console.log(data);
        let idList = '';
        this.sampleItems.forEach(x => {
            if (x.Selected)
            {
                idList += idList == '' ? x.Id : ',' + x.Id;
            }
        });
        this.loaded = false;
        CloneSampleRequest({recordJson: data, sampleRequestItemIds: idList}).then(message=>{
            console.log(message);
            if (message.indexOf('Error') == -1)
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Sample Request was cloned! {1}.',
                    variant: 'success',
                    mode: 'sticky',
                    "messageData": [
                        'Salesforce',
                        {
                            url: window.location.protocol + '//' + window.location.host + '/lightning/r/Sample_Request__c/' + message + '/view',
                            label: 'Click here to navigate to the cloned sample request'
                        }
                    ]
                }));
                this.loaded = true;
                this.closeQuickAction();
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                  }));
            }
            this.loaded = true;
        });
    }
    handleSelect(event){
        const rowId = event.target.value;
        let selected = this.sampleItems.filter(function (x) {
            return x.RowId.toString() === rowId;
        })[0];
        if (selected.Product_Is_Active__c == "false" || selected.Product_Is_Active__c == false)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Inactive products cannot be added to a cloned sample request.',
                variant: 'error'
              }));
              event.preventDefault();
        }
        else
        {
            selected.Selected = event.target.checked;
        }
        
    }
}