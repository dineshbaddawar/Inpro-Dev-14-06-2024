import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getOpportunityContracts from '@salesforce/apex/ContractHelper.getOpportunityContracts';

export default class ContractRelatedList extends LightningElement {
    @api recordId;
    @track RecordCount = 0;
    @track data = [];
    @track columns = [ 
        {label: '', fieldName: 'RecordNumber', type: 'text', sortable: false, initialWidth: 30 },
        {label: 'Contract', fieldName: 'ContractLink', type: 'url',sortable: true, initialWidth: 150, typeAttributes: {label: { fieldName: 'ContractName' }}},       
        {label: 'Contract Name', fieldName: 'InproContractName', type: 'text', sortable: true, initialWidth: 130 },
        {label: 'Account', fieldName: 'AccountLink', type: 'url',sortable: true, initialWidth: 150, typeAttributes: {label: { fieldName: 'AccountName' }}},
        {label: 'Original PO/Contract No', fieldName: 'OriginalPO', type: 'text', sortable: true, initialWidth: 250 },
        {label: 'Status', fieldName: 'Status', type: 'text', sortable: true, initialWidth: 100 },
        {label: 'Pending Contract Amount', fieldName: 'PendingContractAmount', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Executed Contract Amount', fieldName: 'ExecutedContractAmount', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true}
    ];
    
    @track sortedBy = 'CreatedDate';
    @track sortDirection = 'desc';

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log(this.sortBy);
        console.log(this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        if (fieldname == 'ContractLink') fieldname = 'ContractName';
        else if (fieldname == 'AccountLink') fieldname = 'AccountName';
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        var index = 1;
        parseData.forEach(item =>{
            item.RecordNumber = index++;
        });
        this.data = parseData;
    }   

    handleOpen(event){
        window.location.href = window.location.origin + '/lightning/r/Contract__c/' + this.recordId + '/view';
    }

    connectedCallback(){
        this.populateRecordList();
    }

    populateRecordList()
    {
        var tempData = [];
        var contractIds = [];
        getOpportunityContracts({opportunityId: this.recordId}).then(data =>{
            console.log("retrieving contracts..");
            var index = 1;
            data.forEach(item =>{
                item.ContractLink = window.location.origin + '/' + item.Inpro_Contract__r.Id;
                item.ContractName = item.Inpro_Contract__r.Name;
                item.InproContractName = item.Inpro_Contract__r.Contract_Name__c;
                item.AccountLink = window.location.origin + '/' + item.Inpro_Contract__r.Account__c;
                item.AccountName = item.Inpro_Contract__r.Account__r.Name;
                item.OriginalPO = item.Inpro_Contract__r.Original_PO_Contract_No__c;
                item.Status = item.Inpro_Contract__r.Status__c;
                item.PendingContractAmount = item.Inpro_Contract__r.Pending_Contract_Amount__c;
                item.ExecutedContractAmount = item.Inpro_Contract__r.Executed_Contract_Amount__c;
                item.CreatedDate = item.Inpro_Contract__r.CreatedDate;
                item.RecordNumber = index++;
                if(contractIds.length == 0)
                {
                    contractIds.push(item.Inpro_Contract__r.Id);
                    tempData.push(item);
                }
                else if (contractIds.length > 0 && !contractIds.includes(item.Inpro_Contract__r.Id))
                {
                    contractIds.push(item.Inpro_Contract__r.Id);
                    tempData.push(item);
                }
            });

            if (tempData.length > 0) this.hasData = true;
            this.data = tempData;
            this.RecordCount = tempData.length;
        });
        
    }
}