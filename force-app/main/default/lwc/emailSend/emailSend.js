import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import {
    getRecord
} from 'lightning/uiRecordApi';

import contactSearch from '@salesforce/apex/EmailSendHelper.contactSearch';
import getAccountInfo from '@salesforce/apex/EmailSendHelper.getAccountInfo';
import sendEmail from '@salesforce/apex/EmailSendHelper.sendEmail';


export default class EmailSend extends LightningElement {

    @api recordId;
    @track secondarySearchTerm = '';
    @track selectedFrom = {};
    @track Body = '';
    @track Subject = 'Credit Application Link';
    @track error;
    @track email;
    @track name;
    @track accountNumber;
    @track emailTo = '';
    @track emailCC = '';
    @track results = '';


    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.email = data.fields.Email.value;
            this.name = data.fields.Name.value;
            var newLookup = {
                id: USER_ID,
                sObjectType: 'user',
                icon: 'standard:account',
                title: this.name,
                subtitle: this.email
            };
            this.selectedFrom = newLookup;
        }
    }


    connectedCallback() {
        console.log(this.recordId);
        try {
            getAccountInfo({
                    accountId: this.recordId
                }).then(data => {
                    if (data) {
                        this.accountNumber = data[0].Customer_Number__c;


                        this.Body = "Thank you for your interest in Inpro. Please follow the steps in the link below to submit your credit application. <BR><BR>" +
                            "<a href='https://inprocorp.com/credit-application?systemuser=" + USER_ID + "&account=" + this.accountNumber + "'>LINK HERE</a> <BR><BR>" +
                            "This information and credit results will be held in strict confidence. You will be notified once a line of credit has been established for your account. Feel free to contact Danielle Connolly in our Finance Department with any questions or concerns you might have at 262.682.5525 or dconnolly@inprocorp.com. <BR><BR><BR>" +
                            "Thank you, <BR>" +
                            "Inpro  //  Inprocorp.com <BR>" +
                            "---------------------------------------- <BR>" +
                            "Office: 262.679.9010 / 800.222.5556 <BR>" +
                            "Fax: 262.682.5198";
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error: " + errorJson);
                    this.loaded = true;
                });
        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error: " + errorJson);
            this.loaded = true;
        }


    }

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        contactSearch(event.detail)
            .then(results => {
                console.log("contact results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting contacts: " + error);
            });
    }




    handleToSearch(event) {

    }

    handleCCSearch(event) {

    }

    handleLookupSelectionChange(event) {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);

            if (event.target.name == "To") {
                this.emailTo = subTitle;
            }

            if (event.target.name == "Cc") {
                this.emailCC = subTitle;
            }

        }

    }

    handleInputChange(event) {     

        if (event.target.name == "Subject")
            this.Subject = event.target.value;      
        if(event.target.name ==  "Body")
            this.Body = event.target.value;
    }

    handleSendEmail(event) {
        this.loaded = false;
        sendEmail({
                EmailTo: this.emailTo,
                EmailCC: this.emailCC,
                Subject: this.Subject,
                Body: this.Body
            }).then(data => {
                if (data) {
                    this.results = data;
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                this.results ="Error: " + errorJson;
                console.log("Error: " + errorJson);
                this.loaded = true;
            });
    }



}