import { LightningElement, track, api } from 'lwc';

import GetQuoteProducts from '@salesforce/apex/CalculateAlternateYardageHelper.GetQuoteProducts';

export default class CalculateAlternateYardage extends LightningElement {

    @api recordId;
    @track quoteProductList = [];
    totalYards = 0;
    loaded = true;

    connectedCallback() {
        // initialize component
        this.loaded = false;
        this.getQuoteProducts();
    }

    getQuoteProducts() {    
        GetQuoteProducts({
            recordId: this.recordId
        }).then(data => {
                if (data) {
                    try {
                        data.forEach(item => {
                        if(item.Yards_Per_Line__c != null)
                        {
                            var retrievedItem =  {
                                Id: item.Id,
                                Color: item.Color__c,
                                Alternate: item.Alternate__r.Name,
                                ItemNumber: item.Item_Number__c,
                                TotalYards: item.Total_Yards__c,
                                YardsPerLine: item.Yards_Per_Line__c,
                                Selected: true
                            };
                            this.quoteProductList.push(retrievedItem);
                            if(item.Yards_Per_Line__c != null)
                                this.totalYards += item.Yards_Per_Line__c;
                        }
                        });
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading The Product Information: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error Loading The Product Information: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    handleOptionChecked(event) {
        try {
            
            var isChecked = event.target.checked;
            var selectedAlternate = event.target.accessKey;
            var totalSelectedYards = 0;
            console.log(selectedAlternate);
            for(var i = 0; i < this.quoteProductList.length; i++)
            {
                if(this.quoteProductList[i].Id == selectedAlternate)
                    this.quoteProductList[i].Selected = isChecked;
            }

            for(var i = 0; i < this.quoteProductList.length; i++)
            {
                if(this.quoteProductList[i].Selected == true)
                    if(this.quoteProductList[i].YardsPerLine != null)
                        totalSelectedYards += this.quoteProductList[i].YardsPerLine;
            }

            this.totalYards = totalSelectedYards;

        } catch (error) {
            console.log(error);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}