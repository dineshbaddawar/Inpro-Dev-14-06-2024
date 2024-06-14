import { LightningElement, api, track } from 'lwc';

import IsRCAApprovalInProcess from '@salesforce/apex/RCAHelper.IsRCAApprovalInProcess';

export default class RcaExternalApprovalBanner extends LightningElement {
    
    @track loaded = false;
    @track externalApprovalLink = '';
    @api recordId;
    @track baseURL = 'https://devdyn2011app.inprocorp.com:444/RCA/Signin.aspx?id=';

    connectedCallback()
    {
        console.log(window.location.origin);
        if(window.location.origin == "https://inprocorporation2019.lightning.force.com/" || window.location.origin == "https://inprocorporation2019.lightning.force.com")
            this.baseURL = 'https://internalcrm.inprocorp.com:444/RCA/Signin.aspx?id=';
        IsRCAApprovalInProcess({
            rcaId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    console.log(data);
                    if(!data.toLowerCase().includes("error"))
                    {
                        if(data == "true")
                            this.externalApprovalLink = this.baseURL + this.recordId;
                        else
                            this.externalApprovalLink = "This RCA is not currently going through an approval.";
                    }
                    else
                        this.externalApprovalLink = data;
                    this.loaded = true;                      
                } catch (error) {
                    console.log("Error Loading RCA: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error getting RCA: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }
}