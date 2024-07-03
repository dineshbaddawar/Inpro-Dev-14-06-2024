import { LightningElement,
    api,
    track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import GetContract from '@salesforce/apex/ContractHelper.getContract';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class AccountSummaryLetter extends LightningElement {
    
    @api recordId;
    @track division = '';
    @track loaded = true;
    @track divisionList = [];
    @track customerNumber = '';
    @track poNumber = '';

    
    connectedCallback() {
        try
        {
            console.log('entered');
            this.loaded = false;
            this.divisionList = [
                {
                    label: 'ALL',
                    value: 'ALL'
                },
                {
                    label: 'Ascend',
                    value: 'ASCEND - 1008'
                },
                {
                    label: 'Clickeze',
                    value: 'CLICKEZE - 1001'
                },
                {
                    label: 'Endurant',
                    value: 'EN - 1005'
                },
                {
                    label: 'Hinkel',
                    value: 'HL - 1010'
                },
                {
                    label: 'IPC',
                    value: 'IPC - 1000'
                },
                {
                    label: 'JointMaster',
                    value: 'JM - 1002'
                },
                {
                    label: 'SignScape',
                    value: 'SS - 1004'
                }           
            ];


            GetContract({recordId: this.recordId}).then(contractData =>{
                contractData.forEach(x =>{
                    if(x.Original_PO_Contract_No__c != null)
                        this.poNumber = x.Original_PO_Contract_No__c;
                    if(x.Customer_Number__c != null)
                        this.customerNumber = x.Customer_Number__c;
                });           
            }); 
            this.division = 'ALL';
            this.loaded = true;
        }
        catch(ex)
        {
            this.handleError(ex);
        }
    }

    handleInput(event)
    {
        if (event.target.name == 'division') 
            this.division = event.target.value;
    }

    generateAccountSummaryLetter()
    {
        try{
            if(this.poNumber != '' && this.division != '' && this.customerNumber != '')
                window.open("/apex/accountSummaryLetterVF?division=" + this.division + "&customerNumber=" + this.customerNumber + "&contractId=" + this.recordId,"_blank");                                
        }
        catch(ex)
        {
            this.handleError(ex);
        }
    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }
}