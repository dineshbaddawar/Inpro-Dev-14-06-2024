import {
    LightningElement,
    api,
    track
} from 'lwc';
import getExistingProductDiscounts from '@salesforce/apex/QuoteDiscountingHelper.getExistingProductDiscounts';
import saveDiscounts from '@salesforce/apex/QuoteDiscountingHelper.saveDiscounts';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import userId from '@salesforce/user/Id';

export default class QuoteDiscounting extends LightningElement {


    @api recordId;
    loaded = false;
    discountSimilar = false;
    @track error;
    //per alternate list
    @track existingProductList = [];
    //current config list
    @track filteredProductList = [];
    @track removedProductList = [];
    @track alternateList = [];
    @track selectedItem;
    @track theRecord = {};
    alternateTotal = 0;
    alternateTotalYield = 0;
    toastMessage = 'Save Complete';
    showError = false;
    errorMessage = '';
    alternateCM = 0;

    connectedCallback() {
        // initialize component
        this.loadExistingProducts();
    }

    loadExistingProducts() {
        var date = Date().toLocaleString();
        console.log(date);
        console.log(this.recordId);
        getExistingProductDiscounts({
                recordId: this.recordId,
                cache: date
            }).then(data => {
                if (data) {
                    try {
                        console.log("start wire");
                        data.forEach(item => {
                            console.log(item.Id);
                            var newItem = {
                                Id: item.Id,
                                rId: item.rId,
                                Name: item.Name,
                                Color: item.Color,
                                Quantity: item.Quantity,
                                Description: item.Description,
                                AlternateName: item.AlternateName,
                                AlternateId: item.AlternateId,
                                rAlternateId: item.rAlternateId,
                                ColorPalette: item.ColorPalette,
                                PickSequence: item.PickSequence,
                                Description2: item.Description2,
                                UnitCost: item.UnitCost,
                                Yield: this.roundToTwo(item.Yield * 100),
                                CM: this.roundToTwo(item.CM * 100),
                                Discount: item.Discount,
                                DiscountType: item.DiscountType,
                                HasContractPricing: item.HasContractPricing,
                                DiscountPercent: 0,
                                Selected: false,
                                BasePrice: this.roundToTwo(item.BasePrice),
                                Price: this.roundToTwo(item.Price),
                                DiscountPrice: 0,
                                DiscountCM: 0,
                                BackGround: '',
                                QuoteDiscountMinimumCM: item.QuoteDiscountMinimumCM
                            };

                            if (newItem.Price < newItem.UnitCost)
                                newItem.BackGround = 'salmon';
                            else if (newItem.CM < newItem.QuoteDiscountMinimumCM || newItem.DiscountPercent > 10)
                                newItem.BackGround = 'tan'
                            else if (newItem.HasContractPricing === true)
                                newItem.BackGround = 'skyblue'
                            else
                                newItem.BackGround = '';


                            console.log("adding: " + item.Name + item.Id);

                            this.existingProductList.push(newItem);

                            var newAlternate = {
                                AlternateName: newItem.AlternateName,
                                AlternateId: newItem.AlternateId,
                                rAlternateId: newItem.rAlternateId
                            }

                            var duplicate = false;
                            if (this.alternateList.length > 0) {
                                this.alternateList.forEach(element => {
                                    if (element.AlternateId == newAlternate.AlternateId)
                                        duplicate = true;
                                });
                            }

                            if (!duplicate) {
                                this.alternateList.push(newAlternate);
                                console.log("adding new alternate: " + newAlternate.AlternateName + " " + newAlternate.AlternateId);
                            }
                        });
                        var myJSON = JSON.stringify(this.existingProductList);
                        console.log(myJSON);
                        this.filteredProductList = this.existingProductList;
                        this.selectedItem = this.alternateList[0].AlternateId;
                        this.filterListByAlternate();
                        console.log("end wire");
                    } catch (error) {
                        console.log("Error Binding Existing Products: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }

                this.loaded = true;

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting products: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    filterListByAlternate() {
        try {
            let num = parseInt(this.selectedItem);
            if (this.filteredProductList.length > 0) {
                this.existingProductList = this.filteredProductList.filter(function (product) {

                    return parseInt(product.AlternateId) === parseInt(num);
                }).sort((a, b) => (a.PickSequence < b.PickSequence) ? 1 : -1);
            }

            this.calculateCurrentAlternate();

        } catch (error) {
            console.log(error);
        }
    }

    handleSelected(event) {
        try {
            //console.log(event.detail.name);
            if (event.detail.name || event.detail.name === 0) {
                this.selectedItem = event.detail.name;
                console.log(event.detail.name);
                this.filterListByAlternate();
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    createAsyncTask() {
        console.log(this.recordId);
        console.log(userId);
        console.log("create async task");
        createAsyncProcess({
                recordId: this.recordId,
                UserId: userId
            }).then(data => {
                if (data) {
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);

                    if (data.includes("Save in progress")) {
                        this.showError = true;
                        this.errorMessage = data;
                        this.loaded = true;
                    } else
                        this.finishSave();
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error creating async process: " + errorJson);
                this.loaded = true;
            });
    }


    saveConfig() {
        this.loaded = false;
        if (this.alternateList.length >= 2) {
            this.createAsyncTask();
            this.toastMessage = 'Save in progress, you will be notified when it finishes (Bell icon in the upper right corner).';
        } else
            this.finishSave();
    }

    finishSave() {
        this.loaded = false;
        console.log(this.filteredProductList);
        saveDiscounts({
                recordId: this.recordId,
                products: this.filteredProductList
            }).then(results => {
                console.log("save results: " + results);
                // this.filteredProductList = [];
                // this.existingProductList = [];
                // //this.cacheCounter++;
                // this.loadExistingProducts();

                if (results.includes("error")) {
                    this.showError = true;
                    this.errorMessage = results;
                    this.loaded = true;
                } else if (results.includes("Unable to save")) {
                    this.showError = true;
                    this.errorMessage = "It looks like the configuration was unable to save back to Salesforce, please open Experlogix and review any misconfigurations.";
                    this.loaded = true;
                } else {

                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: this.toastMessage,
                        variant: 'success',
                        mode: 'sticky'
                    }));
                    this.loaded = true;
                }


            })
            .catch(error => {
                // TODO: handle error
                console.log("Error saving: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: "Error saving: " + error.status + " " + error.body.message + " " + error.body.stackTrace,
                    variant: 'warning',
                    mode: 'sticky'
                }));
            });
        var myJSON = JSON.stringify(this.filteredProductList);
        console.log(this.recordId + " " + myJSON);
    }

    handleApplyToSelectedOnClick(event) {
        let num = parseInt(this.selectedItem);
        var toUpdate = this.filteredProductList.filter(function (product) {
            return product.Selected == true && product.AlternateId == num
        });

        toUpdate.forEach(option => {
            option.DiscountPercent = this.theRecord['discountPercent'];
            option.DiscountType = 'Percent';
            option.Discount = this.theRecord['discountPercent'];
            option.DiscountPrice = 0;
            option.DiscountCM = 0;
            option.Price = this.roundToTwo(option.BasePrice - ((this.theRecord['discountPercent'] / 100) * option.BasePrice));
            option.Yield = this.roundToTwo((option.Price / option.BasePrice) * 100);
            option.CM = this.roundToTwo(((option.Price - option.UnitCost) / option.Price) * 100);
            if (option.Price < option.UnitCost)
                option.BackGround = 'salmon';
            else if (option.CM < option.QuoteDiscountMinimumCM || option.DiscountPercent > 10)
                option.BackGround = 'tan'
            else if (option.HasContractPricing === true)
                option.BackGround = 'skyblue'
            else
                option.BackGround = '';
        });
    }

    handleApplyToSelectedCMOnClick(event) {
        let num = parseInt(this.selectedItem);
        var toUpdate = this.filteredProductList.filter(function (product) {
            return product.Selected == true && product.AlternateId == num
        });

        toUpdate.forEach(option => {
            option.DiscountPercent = this.theRecord['discountCM'];
            option.DiscountType = 'CM';
            option.DiscountCM = this.theRecord['discountCM'];
            option.DiscountPrice = 0;
            option.DiscountPercent = 0;
            option.CM = this.theRecord['discountCM'];
            option.Price = this.roundToTwo((option.UnitCost * -1) / ((this.theRecord['discountCM'] / 100) - 1));
            option.Yield = this.roundToTwo((option.Price / option.BasePrice) * 100);
            if (option.Price < option.UnitCost)
                option.BackGround = 'salmon';
            else if (option.CM < option.QuoteDiscountMinimumCM || option.DiscountPercent > 10)
                option.BackGround = 'tan'
            else if (option.HasContractPricing === true)
                option.BackGround = 'skyblue'
            else
                option.BackGround = '';
        });
    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.filteredProductList.filter(product => {
            return product.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }

    handleGridInputChange(event) {

        //here
        let selectedItem = this.filteredProductList.filter(function (product) {
            return product.Id === event.target.accessKey;
        })[0];

        if (event.target.name == 'OptionDiscountPrice') {
            selectedItem.DiscountPrice = event.target.value;
            selectedItem.Price = event.target.value;
            selectedItem.DiscountPercent = 0;
            selectedItem.DiscountCM = 0
            selectedItem.DiscountType = 'Price';
            if (event.target.value == 0) {
                selectedItem.DiscountPrice = 0;
                selectedItem.Price = selectedItem.BasePrice;
                selectedItem.DiscountType = '';
            }

        } else if (event.target.name == 'OptionDiscountPercent') {
            selectedItem.DiscountPrice = 0
            selectedItem.DiscountCM = 0
            selectedItem.DiscountPercent = event.target.value;
            selectedItem.Price = this.roundToTwo(selectedItem.BasePrice - ((event.target.value / 100) * selectedItem.BasePrice));
            selectedItem.DiscountType = 'Percent';
        } else if (event.target.name == 'OptionDiscountCM') {
            selectedItem.DiscountPrice = 0
            selectedItem.DiscountPercent = 0;
            selectedItem.DiscountCM = event.target.value;
            selectedItem.Price = this.roundToTwo((selectedItem.UnitCost * -1) / ((event.target.value / 100) - 1));
            selectedItem.DiscountType = 'Percent';

        }

        if (selectedItem.Price == 0)
            selectedItem.CM = 0;
        else if (event.target.name == 'OptionDiscountCM')
            selectedItem.CM = event.target.value;
        else
            selectedItem.CM = this.roundToTwo(((selectedItem.Price - selectedItem.UnitCost) / selectedItem.Price) * 100);


        selectedItem.Yield = this.roundToTwo((selectedItem.Price / selectedItem.BasePrice) * 100);
        if (selectedItem.Price < selectedItem.UnitCost)
            selectedItem.BackGround = 'salmon';
        else if (selectedItem.CM < selectedItem.QuoteDiscountMinimumCM || selectedItem.DiscountPercent > 10)
            selectedItem.BackGround = 'tan'
        else if (selectedItem.HasContractPricing === true)
            selectedItem.BackGround = 'skyblue'
        else
            selectedItem.BackGround = '';
        if (event.target.name == 'OptionDiscountCM')
            selectedItem.Discount = 100 - ((((selectedItem.UnitCost * -1) / ((selectedItem.DiscountCM / 100) - 1)) / selectedItem.BasePrice) * 100);
        else
            selectedItem.Discount = event.target.value;
        console.log(selectedItem.BackGround);
        this.calculateCurrentAlternate();
    }

    roundToTwo(num) {
        return +(Math.round(num + "e+2") + "e-2");
    }

    handleCheckAllChecked(event) {
        let num = parseInt(this.selectedItem);
        if (this.filteredProductList.length > 0) {
            var toUpdateSelected = this.filteredProductList.filter(function (product) {
                return parseInt(product.AlternateId) === parseInt(num);
            });

            toUpdateSelected.forEach(option => {
                option.Selected = event.target.checked;
            });
        }
    }

    handleFormInputChange(event) {
        // In 1 line, assign the value to the property
        this.theRecord[event.target.name] = event.target.value;
        //console.log(event.target.name + ' now is set to ' + event.target.value);
    }

    handleCheckAllDiscountSimilar(event) {
        console.log(this.existingProductList);
        this.existingProductList.forEach(option => {
                option.Selected = event.target.checked;
            });
        }
    

    handleDiscountSimilarItemsOnClick(event) {
        var uniq = this.filteredProductList.map((value) => {
                return {
                    count: 1,
                    Id: value.Name
                }
            })
            .reduce((a, b) => {
                a[b.Id] = (a[b.Id] || 0) + b.count
                return a
            }, {});
        var duplicates = Object.keys(uniq).filter((a) => uniq[a] > 1);
        this.existingProductList = this.removeDuplicates(this.filteredProductList.filter(({
            Name
        }) => duplicates.includes(Name)), "Name");
        this.discountSimilar = true;

    }

    removeDuplicates(myArr, prop) {
        return myArr.filter((obj, pos, arr) => {
            return arr.map(mapObj =>
                mapObj[prop]).indexOf(obj[prop]) === pos;
        });
    }

    handleApplyDiscountClick(event) {
        this.loaded = false;
        this.existingProductList.filter(x => {
            return x.Selected == true;
        }).forEach(product => {
            //console.log('first Loop: ' + product.Name);
            this.filteredProductList.filter(parent => {
                return parent.Name == product.Name;
            }).forEach(p => {
                //console.log('second loop: ' + p.Name + ' dp: ' + product.DiscountPercent + ' dprice: ' + product.DiscountPrice);
                p.DiscountPercent = product.DiscountPercent;
                p.DiscountPrice = product.DiscountPrice;
                p.DiscountCM = product.DiscountCM;
                if (product.DiscountPercent != 0) {
                    p.DiscountType = 'Percent';
                    p.Discount = product.DiscountPercent;
                    p.Price = this.roundToTwo(p.BasePrice - ((product.DiscountPercent / 100) * p.BasePrice));
                    p.Yield = this.roundToTwo((p.Price / p.BasePrice) * 100);
                    p.CM = this.roundToTwo(((p.Price - p.UnitCost) / p.Price) * 100);
                    if (p.Price < p.UnitCost)
                        p.BackGround = 'salmon';
                    else if (p.CM < p.QuoteDiscountMinimumCM || p.DiscountPercent > 10)
                        p.BackGround = 'tan'
                    else if (p.HasContractPricing === true)
                        p.BackGround = 'skyblue'
                    else
                        p.BackGround = '';
                } else if (product.DiscountPrice != 0) {
                    p.DiscountType = 'Price';
                    p.Discount = product.DiscountPrice;
                    p.Price = product.DiscountPrice;
                    p.CM = this.roundToTwo(((p.Price - p.UnitCost) / p.Price) * 100);
                    p.Yield = this.roundToTwo((p.Price / p.BasePrice) * 100);
                    if (p.Price < p.UnitCost)
                        p.BackGround = 'salmon';
                    else if (p.CM < p.QuoteDiscountMinimumCM || p.DiscountPercent > 10)
                        p.BackGround = 'tan'
                    else if (p.HasContractPricing === true)
                        p.BackGround = 'skyblue'
                    else
                        p.BackGround = '';
                } else if (product.DiscountCM != 0) {
                    p.DiscountType = 'Percent';
                    p.Price = this.roundToTwo((p.UnitCost * -1) / ((product.DiscountCM / 100) - 1));
                    p.CM = product.DiscountCM;
                    p.Yield = this.roundToTwo((p.Price / p.BasePrice) * 100);
                    p.Discount = 100 - ((((p.UnitCost * -1) / ((product.DiscountCM / 100) - 1)) / p.BasePrice) * 100);
                    if (p.Price < p.UnitCost)
                        p.BackGround = 'salmon';
                    else if (p.CM < p.QuoteDiscountMinimumCM || p.DiscountPercent > 10)
                        p.BackGround = 'tan'
                    else if (p.HasContractPricing === true)
                        p.BackGround = 'skyblue'
                    else
                        p.BackGround = '';
                } else {
                    p.DiscountType = '';
                    p.Discount = 0;
                }
            });
        });

        this.loaded = true;
    }

    handleReturnToMainScreenOnClick(event) {
        this.filterListByAlternate();
        this.discountSimilar = false;
    }

    calculateCurrentAlternate() {
        this.alternateTotal = 0;
        var alternateBasePrice = 0;
        this.alternateTotalYield = 0;
        var unitCost = 0;

        this.existingProductList.forEach(product => {
            this.alternateTotal += (product.Price * product.Quantity);
            alternateBasePrice += (product.BasePrice * product.Quantity);
            unitCost += (product.UnitCost * product.Quantity);
        });
        this.alternateTotal = this.roundToTwo(this.alternateTotal);
        this.alternateTotalYield = this.roundToTwo((this.alternateTotal / alternateBasePrice) * 100);
        this.alternateCM = this.roundToTwo(((this.roundToTwo(this.alternateTotal) - this.roundToTwo(unitCost)) /
                                              this.roundToTwo(this.alternateTotal)) * 100)                                                      

    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}