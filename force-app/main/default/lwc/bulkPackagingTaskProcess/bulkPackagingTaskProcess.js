import { LightningElement,
    api,
    wire,
    track } from 'lwc';

    import updateBulkPackagingTask from '@salesforce/apex/RequestOrderHelper.updateBulkPackagingTask';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import userId from '@salesforce/user/Id';

export default class BulkPackagingTaskProcess extends LightningElement {
    @api recordId;
    @track comments = '';
    @track status = '';
    @track statuses = [];
    @track Response = '';
    @track loaded = true;

    connectedCallback()
    {
        var acceptedOption = {
            label: 'Bulk Packaging Accepted',
            value: 'Bulk Packaging Accepted'
        };

        var declinedOption = {
            label: 'Bulk Packaging Declined',
            value: 'Bulk Packaging Declined'
        };

        this.statuses = [...this.statuses, acceptedOption];
        this.statuses = [...this.statuses, declinedOption];
    }

    handleSave()
    {
        this.loaded = false;
        if(this.status != null && this.status != '')
        {
            console.log('save started');
            updateBulkPackagingTask({
                recordId: this.recordId,
                userId: userId,
                status: this.status,
                comments: this.comments
            }).then(data => {
                if(!data.toLowerCase().includes("error"))
                    document.location = location.href; 
                else
                    this.handleError(data); 
            })
            .catch(error => {
                this.handleError("Error: There was an error updating the bulk packaging task." + error);
            });
        }
        else
            this.handleError('Error: There was an error updating the bulk packaging task.');
    }

    handlestatusOptionChange(event){
        if (event.target.name == 'lcb_status')
            this.status = event.target.value;
        if (event.target.name == 'ta_comments')
            this.comments = event.target.value;
    }

    handleCommentsOnChange(event)
    {
        this.comments = event.target.value;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
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