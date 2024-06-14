import {
    LightningElement,
    api, 
    track
} from 'lwc';

import ApproveRCARequest from '@salesforce/apex/RCAHelper.ApproveRCARequest';
import RejectRCARequest from '@salesforce/apex/RCAHelper.RejectRCARequest';
import SendRCAToNetSuite from '@salesforce/apex/RCAHelper.SendRCAToNetSuite';
import GetCurrentRCA from '@salesforce/apex/RCAHelper.GetCurrentRCA';

import userId from '@salesforce/user/Id';

export default class RcaProcess extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';
    @track notes = '';
    @track totalInproImpact = 0;
    @track rcaType = '';
    @track noChargeOver99 = false;
    @track over2500 = false;
    @track over70DaysOld = false;

    connectedCallback() {
        // initialize component
        this.loaded = false;
        this.getCurrentRCA();
    }

    getCurrentRCA() {
        GetCurrentRCA({
                rcaId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(RCA__c => { 
                            this.totalInproImpact = RCA__c.Total_Inpro_Impact__c;
                            this.rcaType = RCA__c.RCA_Type__c;
                            this.daysSinceInvoice = RCA__c.Days_Since_Invoice__c;    
                            if(this.rcaType == "No Charge" && this.totalInproImpact > 99)
                                this.noChargeOver99 = true;    
                            if (this.totalInproImpact > 2499)
                                this.over2500 = true;
                            if (this.daysSinceInvoice > 70)
                                this.over70DaysOld = true;               
                        }); 
                        this.loaded = true;                      
                    } catch (error) {
                        console.log("Error Loading Bidders: " + error);
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

    handleApproveRCAClick() {
        this.loaded = false;
        this.callApproveRCA();
    }

    handleRejectRCAClick() {
        this.loaded = false;
        this.callRejectRCA();
    }

    handleSendRCAToNetSuiteClick() {
        this.loaded = false;
        this.callSendRCAToNetSuite();
    }

    handleNotesOnChange(event){
        this.notes = event.target.value;
    }

    callApproveRCA() {
        try {
            console.log(this.recordId);
            ApproveRCARequest({
                    rcaId: this.recordId,
                    notes: this.notes,
                    userId: userId
                }).then(data => {
                    this.Response = data;
                    console.log(data);
                    if(!data.toLowerCase().includes("error"))
                        document.location = location.href;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error approving RCA: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error approving RCA: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    callRejectRCA() {
        try {
            console.log(this.recordId);
            RejectRCARequest({
                    rcaId: this.recordId,
                    notes: this.notes,
                    userId: userId
                }).then(data => {
                    this.Response = data;
                    console.log(data);
                    if(data != 'Success!')
                        document.location = location.href;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error rejecting RCA: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error rejecting RCA: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    callSendRCAToNetSuite() {
        try {
            console.log(this.recordId);
            if(location.hostname == 'inprocorporation2019.lightning.force.com')
            {               
                SendRCAToNetSuite({
                        rcaId: this.recordId
                    }).then(data => {
                        this.Response = data;
                        console.log(data);
                        if(!data.toLowerCase().includes("error"))
                            document.location = location.href;
                        this.loaded = true;
                    })
                    .catch(error => {
                        // TODO: handle error
                        var errorJson = JSON.stringify(error);
                        console.log("Error moving RCA to NetSuite: " + errorJson);
                        this.Response = errorJson;
                        this.loaded = true;
                    });
            }
            else
            {
                var errorJson = "Push to NetSuite functionality currently disabled outside of production.";
                console.log("Error moving RCA to NetSuite: " + errorJson);
                this.Response = errorJson;
                this.loaded = true;
            }

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error moving RCA to NetSuite: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}