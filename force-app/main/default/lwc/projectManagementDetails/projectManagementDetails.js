import { LightningElement, api, wire, track } from 'lwc';
import getProjectManagementDetails from '@salesforce/apex/ProjectManagementController.getProjectManagementDetails';
 
export default class ProjectManagementDetails extends LightningElement {
    @api recordId;
    @track detailsLoaded = false;
    @track poNumber;
    @track constructionProject;
    @track poUpdatedTimestamp;
    @track taxExemptCertRequired;
    @track sOpMeetingRequired;
    @track colorsSelected;
    @track phasingRequirement;
    @track colors;
    @track phasingRequirementDetail;
    @track awardDecisionDate;
    @track leadTimeDays;
    @track bidDueDate;
    @track materialsNeededDate;
    @track customPriceNeeded;
    @track customPartNumbers;
    @track customProductNeeded;
    @track shippingInstructions;
    @track projectManagementNumber;
 
    connectedCallback()
    {
        this.fetchProjectDetails();
    }
 
    fetchProjectDetails() {
        getProjectManagementDetails({ recordId: this.recordId })
            .then(data => {
                this.detailsLoaded = true;
                this.poNumber = data.Project_Management__r.PO_Number__c;
                this.constructionProject = data.Project_Management__r.Construction_Project__c;
                this.poUpdatedTimestamp = data.Project_Management__r.PO_Updated_Timestamp__c;
            })
            .catch(error => {
                console.error('Error fetching Project Management details:', error);
                this.detailsLoaded = false;
            });
    }
 
}