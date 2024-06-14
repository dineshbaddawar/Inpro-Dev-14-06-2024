import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getProjects from '@salesforce/apex/ProjectManagementController.getProjects';
 
const DIVISION_FIELD = 'Project_Management__c.Division__c';
const columns = [
    { label: 'Division', fieldName: 'Division__c', editable: true },
    { label: 'Milestone', fieldName: 'Milestone__c', editable: true },
    { label: 'Date Created', fieldName: 'Date_Created__c', type: 'date', editable: true },
    { label: 'Date Completed', fieldName: 'Date_Completed__c', type: 'date', editable: true },
];
 
export default class PmFormMain extends LightningElement {
    @api recordId;
    @track showIPC = false;
    @track showSignScape = false;
    @track data = [];
    @track columns = columns;
    @track rowOffset = 0;
 
    @wire(getProjects, { projectId: '$recordId' })
    wiredProjects({ error, data }) {
        if (data) {
            this.data = data;
        } else if (error) {
            console.error('Error:', error);
        }
    }
 
    connectedCallback() {
        if (this.record && this.record.data) {
            this.setFieldVisibility(this.divisionValue);
        }
    }
 
    handleDivisionChange(event) {
        const division = event.target.value;
        this.setFieldVisibility(division);
    }
 
    setFieldVisibility(division) {
        this.showIPC = (division === 'IPC');
        this.showSignScape = (division === 'SignScape');
    }
}