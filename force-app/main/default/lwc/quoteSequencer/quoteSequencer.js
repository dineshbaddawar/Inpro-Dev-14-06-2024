import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAlternates from '@salesforce/apex/QuoteSequencerHelper.getAlternates';
import getQuoteProductsByAlternate from '@salesforce/apex/QuoteSequencerHelper.getQuoteProductsByAlternate';
import updateAlternates from '@salesforce/apex/QuoteSequencerHelper.updateAlternates';
import updateQuoteLineItems from '@salesforce/apex/QuoteSequencerHelper.updateQuoteLineItems';

export default class QuoteSequencer extends LightningElement {
    @api recordId;

    @track loaded = false;
    @track isAltView = false;
    @track hasGroups = false;
    @track isQuoteProductView = false;
    @track hasUnsavedChanges = false;
    @track Alternates = [];
    @track Groups = [];
    @track QuoteProducts = [];
    @track LoadedQuoteProducts = [];
    @track LoadedAlternateIds = [];

    handleMoveDown(event)
    {
        var Id =  event.target.accessKey;
        if (this.isAltView)
        {
            var index = this.Alternates.findIndex(x => x.Id == Id);
            if (index < this.Alternates.length - 1)
            {
                this.Alternates = this.arrayMove(this.Alternates, index, index + 1);
            }
        }
        else if (this.isGroupView)
        {
            var index = this.Groups.findIndex(x => x.Name == Id);
            if (index < this.Groups.length - 1)
            {
                this.Groups = this.arrayMove(this.Groups, index, index + 1);
            }
        }
        else
        {
            var index = this.QuoteProducts.findIndex(x => x.Id == Id);
            if (index < this.QuoteProducts.length - 1)
            {
                this.QuoteProducts = this.arrayMove(this.QuoteProducts, index, index + 1);
            }
        }
        
    }

    handleMoveUp(event)
    {
        var Id =  event.target.accessKey;
        if (this.isAltView)
        {
            var index = this.Alternates.findIndex(x => x.Id == Id);
            if (index > 0)
            {
                this.Alternates = this.arrayMove(this.Alternates, index, index - 1);
            }
        }
        else if (this.isGroupView)
        {
            var index = this.Groups.findIndex(x => x.Name == Id);
            if (index > 0)
            {
                this.Groups = this.arrayMove(this.Groups, index, index - 1);
            }
        }
        else
        {
            var index = this.QuoteProducts.findIndex(x => x.Id == Id);
            if (index > 0)
            {
                this.QuoteProducts = this.arrayMove(this.QuoteProducts, index, index - 1);
            }
        }
    }

    handleViewGroups(event)
    {
        this.isGroupView = true;
        this.isAltView = false;
    }

    handleExitGroups(event)
    {
        this.isGroupView = false;
        this.isAltView = true;
    }

    handleUpdateView(event)
    {
        if(this.isAltView)
        {
            if (this.Alternates.findIndex(x => x.Sequence_Number__c == undefined) != -1)
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in all alternates with a sequence number.',
                    variant: 'warning'
                }));
                return;
            }

            var array = this.Alternates.sort((a, b) => (a.Sequence_Number__c > b.Sequence_Number__c) ? 1 : -1);
            var counter = 0;
            array.forEach(x => {
                counter++;
                x.Sequence_Number__c = counter;
            });
            this.Alternates = array;         
        }
        else if (this.isGroupView)
        {
            var array = this.Groups.sort((a,b) => (a.Group_Sequence_Number__c > b.Group_Sequence_Number__c) ? 1 : -1);
            var counter = 0;
            array.forEach(x => {
                counter++;
                x.Group_Sequence_Number__c = counter;
            });
            this.Groups = array; 
        }
        else{
            if (this.QuoteProducts.findIndex(x => x.Sequence_Number__c == undefined) != -1)
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in all quote line items with a sequence number.',
                    variant: 'warning'
                }));
                return;
            }
            var array = this.QuoteProducts.sort((a, b) => (a.Sequence_Number__c > b.Sequence_Number__c) ? 1 : -1);
            var counter = 0;
            array.forEach(x => {
                counter++;
                x.Sequence_Number__c = counter;
            });
            this.QuoteProducts = array;
           
        }        
    }

    handleInput(event){
        var Id =  event.target.accessKey;

        if (this.isAltView)
        {
            let selectedAlt = this.Alternates.filter(function (Alt) {
                return Alt.Id === Id;
            })[0];
    
            selectedAlt.Sequence_Number__c = event.target.value;
            selectedAlt.HasChange = true;
            selectedAlt.BackGround = 'yellow';
            this.hasUnsavedChanges = true;
        }
        else if (this.isGroupView)
        {
            let selectedGroup = this.Groups.filter(function (Group) {
                return Group.Name === Id;
            })[0];
    
            selectedGroup.Group_Sequence_Number__c = event.target.value;
            selectedGroup.HasChange = true;
            selectedGroup.BackGround = 'yellow';
            this.hasUnsavedChanges = true;
        }
        else
        {
            let selectedQuoteLineItem = this.QuoteProducts.filter(function (Alt) {
                return Alt.Id === Id;
            })[0];
    
            selectedQuoteLineItem.Sequence_Number__c = event.target.value;
            selectedQuoteLineItem.HasChange = true;
            selectedQuoteLineItem.BackGround = 'yellow';
            this.hasUnsavedChanges = true;
        }
        
    }

    handleViewAlternates(event){
        this.isQuoteProductView = false;
        this.isAltView = true;
    }

    handleViewProducts(event){
        var Id =  event.target.accessKey;
        this.loaded = false;
        console.log(Id);
        console.log(this.LoadedQuoteProducts);
        if (this.LoadedAlternateIds.indexOf(Id) != -1)
        {
            this.QuoteProducts = this.LoadedQuoteProducts.filter(function(qli){
                return qli.Alternate__c == Id;
            });
            this.isQuoteProductView = true;
            this.isAltView = false;
            this.loaded = true;
        }
        else{
            getQuoteProductsByAlternate({alternateId: Id}).then(data =>{
                this.isQuoteProductView = true;
                this.isAltView = false;
                this.QuoteProducts = data;
    
                var index = 1;
                this.QuoteProducts.forEach(item => item.Sequence_Number__c = index++);

                if (this.LoadedAlternateIds.indexOf(Id) == -1) //only load quote products once into catchall
                {
                    this.LoadedAlternateIds.push(Id);
                    this.LoadedQuoteProducts.push(...data);
                }
                console.log('All loaded ' + this.LoadedQuoteProducts.length);
                this.loaded = true;
            });
        }
    }
    
    handleSave(event){
        this.loaded = false;
        this.Groups.forEach(x => {
            this.Alternates.forEach(y => {
                if (x.AlternateIds.indexOf(y.Id) != -1)
                {
                    y.Group_Sequence_Number__c = x.Group_Sequence_Number__c;
                }
            })
        });

        console.log(this.Groups);
        console.log(this.Alternates);

        updateQuoteLineItems({quoteLineItemJson: JSON.stringify(this.LoadedQuoteProducts)}).then(data =>{
            updateAlternates({quoteId: this.recordId, altJson: JSON.stringify(this.Alternates)}).then(data2 => {
                for(var i = 0; i < this.Alternates.length; i++)
                {
                    this.Alternates[i].HasChange = false;
                }
                for(var i = 0; i < this.QuoteProducts.length; i++)
                {
                    this.QuoteProducts[i].HasChange = false;
                }
                this.hasUnsavedChanges = false;
                this.loaded = true;
                this.handleUpdateView(null);
                
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Sequencing has been saved',
                    variant: 'success'
                  }));
            });
        });
    }

    arrayMove(arr, fromIndex, toIndex) {
        var element = arr[fromIndex];
        var otherElement = arr[toIndex];

        arr.splice(fromIndex, 1);
        arr.splice(toIndex, 0, element);
        
        var tempInt = element.Sequence_Number__c;
        if (this.isGroupView)
        {
            tempInt = element.Group_Sequence_Number__c;
            element.Group_Sequence_Number__c = otherElement.Group_Sequence_Number__c;
            otherElement.Group_Sequence_Number__c = tempInt;
        }
        else
        {
            element.Sequence_Number__c = otherElement.Sequence_Number__c;
            otherElement.Sequence_Number__c = tempInt;
        }
        element.HasChange = true;
        otherElement.HasChange = true;

        this.hasUnsavedChanges = true;

        return arr;
    }

    @track isFirstSequencing = false;
    connectedCallback(){
        getAlternates({recordId: this.recordId}).then(data => {
            var alts = data;
            var index = 1;
            var tempGroupArray = {};
            alts.forEach(item =>
            {
                if (item.Sequence_Number__c == '' || item.Sequence_Number__c == undefined)
                {
                    this.isFirstSequencing = true;
                    this.hasUnsavedChanges = true;
                }
                
                item.Sequence_Number__c = index++

                if (tempGroupArray[item.Freight_Group_Name__c] == undefined)
                {
                    tempGroupArray[item.Freight_Group_Name__c] = {
                        Group_Sequence_Number__c: item.Group_Sequence_Number__c,
                        Alternates: [item.Name__c],
                        AlternateIds: [item.Id]
                    };
                }
                else
                {
                    var tempObj = tempGroupArray[item.Freight_Group_Name__c];
                    var tempList = tempObj.Alternates;
                    tempList.push(item.Name__c);
                    var tempIds = tempObj.AlternateIds;
                    tempIds.push(item.Id);
                    tempGroupArray[item.Freight_Group_Name__c] = {
                        Group_Sequence_Number__c: item.Group_Sequence_Number__c,
                        Alternates: tempList,
                        AlternateIds: tempIds
                    };
                }
            });

            for(const key in tempGroupArray)
            {
                if (key != 'undefined' && key != 'N/A')
                {
                    this.hasGroups = true;
                }

                let altStr = '';
                tempGroupArray[key].Alternates.forEach(x => {
                    if (altStr == '') altStr += x;
                    else altStr += ', ' + x;
                });

                this.Groups.push({
                    Name: key == 'undefined' ? 'N/A' : key,
                    Group_Sequence_Number__c: tempGroupArray[key].Group_Sequence_Number__c,
                    Alternates: altStr,
                    AlternateIds: tempGroupArray[key].AlternateIds
                });

                this.Groups = this.Groups.sort((a,b) => (a.Group_Sequence_Number__c > b.Group_Sequence_Number__c) ? 1 : -1);
            }
            console.log(this.Groups);
            this.Alternates = alts;
            this.isAltView = true;
            this.loaded = true;

            
            /* SAME NAME COMBINE
            var tempArray = [];
            alts.forEach(x => {
                let altsWithSameName = alts.filter(y => y.Name__c == x.Name__c);
                let sameNameAltsWithFreight = altsWithSameName.filter(y => y.Freight_Amount__c > 0);
                let existingAlts = tempArray.filter(y => y.Name__c == x.Name__c);

                //Same name alt with combined freight or no freight
                if (existingAlts.length == 0 && altsWithSameName.length > 0 && sameNameAltsWithFreight.length <= 1)
                {
                    //Combine totals and get correct values. Push same name alt once
                    altsWithSameName.forEach(y => {
                        if (x.Id != y.Id)
                        {
                            x.Total_List_Price__c += y.Total_List_Price__c;
                            x.Freight_Group_Name__c = y.Freight_Group_Name__c != undefined && y.Freight_Group_Name__c != '' ? 
                                y.Freight_Group_Name__c : x.Freight_Group_Name__c;
                            x.Freight_Amount__c = y.Freight_Amount__c != undefined && y.Freight_Amount__c != '' ? 
                                y.Freight_Amount__c : x.Freight_Amount__c;
                            x.Sequence_Number__c = y.Sequence_Number__c != undefined && y.Sequence_Number__c != '' ? 
                                y.Sequence_Number__c : x.Sequence_Number__c;
                        }
                    });
                    const format = (num, decimals) => num.toLocaleString('en-US', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                    });
                    x.Total_List_Price__c = format(x.Total_List_Price__c).replace(',','');
                    tempArray.push(x);
                }
                //Unique name alt OR Same name alt with multiple freight
                else if (existingAlts.length == 0 || sameNameAltsWithFreight.length > 0)
                {
                    tempArray.push(x);
                }
            });
            this.Alternates = tempArray;
            this.isAltView = true;
            this.loaded = true;*/
            
        });
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}