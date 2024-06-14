import {
    LightningElement,
    api
} from 'lwc';
import registerUser from '@salesforce/apex/EcomRegisterUserHelper.registerUser';
import userId from '@salesforce/user/Id';

export default class EcomRegisterUser extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';

    handleRegisterUserClick() {
        this.callRegisterUser();
    }

    callRegisterUser() {

        try {

            this.loaded = false;
            console.log("contactId: " + this.recordId);
            console.log("userId: " + userId);
            registerUser({
                    recordId: this.recordId,
                    userId: userId
                }).then(data => {
                    if (data) {

                        this.Response = data;
                        this.loaded = true;
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error registering user: " + errorJSON);
                    this.loaded = true;
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error calling register user: " + erJSON);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}