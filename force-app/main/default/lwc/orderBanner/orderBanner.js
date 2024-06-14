import { LightningElement, api, track } from 'lwc';

import GetOrderInformation from '@salesforce/apex/OrderConfirmationSendHelper.GetOrderInformation';

export default class orderBanner extends LightningElement {
    
    @track loaded = false;
    @track netSuiteOrderLink = '';
    @api recordId;
    @track baseURL = 'https://4814214-sb3.app.netsuite.com/app/accounting/transactions/salesord.nl?id=';

    connectedCallback()
    {
        console.log(window.location.origin);
        if(window.location.origin == "https://inprocorporation2019.lightning.force.com/" || window.location.origin == "https://inprocorporation2019.lightning.force.com")
            this.baseURL = 'https://4814214.app.netsuite.com/app/accounting/transactions/salesord.nl?id=';
        GetOrderInformation({
            recordId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    console.log(data);
                    if(data.NetSuite_Id__c != null)
                        this.netSuiteOrderLink = this.baseURL + data.NetSuite_Id__c;
                    else
                        this.handleError('Error: The order number could not be found.');
                    this.loaded = true;                      
                } catch (error) {
                    console.log("Error Retrieving Order: " + error);
                }

            } 
            else
                this.handleError('Error: There was an error retrieving the NetSuite order link.'); 
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error retrieving order: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    handleError(error) {
        //console.log(error);
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
}