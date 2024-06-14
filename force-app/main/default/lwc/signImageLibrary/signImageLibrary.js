import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getSignImages from '@salesforce/apex/SignImageLibraryHelper.getSignImages';
import getFullSignImage from '@salesforce/apex/SignImageLibraryHelper.getFullSignImage';
import deleteSignImage from '@salesforce/apex/SignImageLibraryHelper.deleteSignImage';
import getQuoteLineItems from '@salesforce/apex/SignImageLibraryHelper.getQuoteLineItems';
import copySignImage from '@salesforce/apex/SignImageLibraryHelper.copySignImage';


export default class SignImageLibrary extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track showError = false;
    @track errorMessage = '';
    @track imageSourceOptionList = [];
    @track SignImages = [];
    @track AllSignImages = [];
    @track selectedImageSourceOption = 'From Current Quote';
    @track quoteProducts = [];
    @track copyImage = false;

    connectedCallback() {

        this.loaded = false;
        var oCurrent = {
            label: 'From Current Quote',
            value: 'From Current Quote'
        };
        var oRelated = {
            label: 'From all related Quotes',
            value: 'From all related Quotes'
        };
        var oOrphaned = {
            label: 'Orphaned Images',
            value: 'Orphaned Images'
        };

        this.imageSourceOptionList = [...this.imageSourceOptionList, oCurrent];
        this.imageSourceOptionList = [...this.imageSourceOptionList, oRelated];
        this.imageSourceOptionList = [...this.imageSourceOptionList, oOrphaned];
        this.loadExistingImages();
        //TODO: get externalID on load
    }

    loadExistingImages() {
        console.log(this.recordId);
        getSignImages({
                recordId: this.recordId
            }).then(data => {
                if (data !== '') 
                {
                    console.log(data);
                    this.AllSignImages = JSON.parse(data);
                    this.AllSignImages.forEach(x => {
                        x.ImageLoaded = false;
                        getFullSignImage({recordId: this.recordId,imageId: x.ImageId}).then(results => {
                            var imageResults = JSON.parse(results);
                            console.log(imageResults[0].FileData);
                            x.ImageLoaded = true;
                            x.FileData = imageResults[0].FileData;
                        });
                    });
                    //TODO: or quoteid = externalid
                    this.SignImages = this.AllSignImages.filter(x => {
                        return x.QuoteId == this.recordId
                    });
                } 
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error getting images: " + errorJson);
                this.errorMessage = errorJson;
                this.showError = true;
                this.loaded = true;
            });
    }

    handleCopyToCurrent(event) {
        try {
            //todo: check if the image is custom
            console.log(this.recordId);
            getQuoteLineItems({
                    quoteId: this.recordId
                }).then(data => {
                    if (data) {
                        console.log(data);
                        this.quoteProducts = data;
                        this.copyImage = true;

                    } else if (error) {
                        var errorJson = JSON.stringify(error);
                        console.log("Error getting quote products: " + errorJson);
                        this.errorMessage = errorJson;
                        this.showError = true;
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error getting quote products : " + errorJson);
                    this.errorMessage = errorJson;
                    this.showError = true;
                });
        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error getting quote products1: " + errorJson);
        }
    }

    handleDeletemage(event) {
        this.loaded = false;
        let selectedImage = this.SignImages.filter(function (prod) {
            return prod.Selected === true;
        })[0];
        console.log(selectedImage.ImageId);

        deleteSignImage({
                imageId: selectedImage.ImageId
            }).then(data => {
                if (data) {
                    console.log(data);

                    this.SignImages = this.SignImages.filter(function (prod) {
                        return prod.Selected != true;
                    });

                } else if (error) {
                    var errorJson = JSON.stringify(error);
                    console.log("Error deleting images : " + errorJson);
                    this.errorMessage = errorJson;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error deleting images: " + errorJson);
                this.errorMessage = errorJson;
                this.showError = true;
            });


    }

    handleImageSourceComboBoxOnchange(event) {
        console.log(event.target.value);
        this.selectedImageSourceOption = event.target.value;

        if (this.selectedImageSourceOption == 'From Current Quote') {
            this.SignImages = this.AllSignImages.filter(x => {
                return x.QuoteId == this.recordId
            });
        } else if (this.selectedImageSourceOption == 'From all related Quotes') {
            this.SignImages = this.AllSignImages;
        } else if (this.selectedImageSourceOption == 'Orphaned Images') {
            this.SignImages = this.AllSignImages.filter(x => {
                return x.IsOrphaned == true
            });
        }

    }

    handleOptionChecked(event) {
        var prodId = event.target.accessKey;
        console.log(prodId);
        let selectedImage = this.SignImages.filter(function (prod) {
            return prod.ImageId === prodId;
        })[0];

        selectedImage.Selected = event.target.checked;
        console.log(selectedImage.Selected);
    }

    handleProductChecked(event) {
        var prodId = event.target.accessKey;
        console.log(prodId);
        let selectedProduct = this.quoteProducts.filter(function (prod) {
            return prod.Id === prodId;
        })[0];

        selectedProduct.Selected = event.target.checked;
        console.log(selectedProduct.Selected);
    }

    handleCopyCancel(event) {
        this.copyImage = false;
    }

    handleCopyFinish(event) {
        //String imageId, String quoteId, String quoteDetailId, Boolean useUpdate
        try {


            this.loaded = false;
            let selectedImage = this.SignImages.filter(function (prod) {
                return prod.Selected === true;
            })[0];
            if (selectedImage === undefined)
            {
                this.errorMessage = 'Selected Image not found!';
                this.showError = true;
                this.loaded = true;
                return;
            }
            console.log("ImageID: " + selectedImage.ImageId);

            let selectedProduct = this.quoteProducts.filter(function (prod) {
                return prod.Selected === true;
            })[0];
            console.log("quote productID: " + selectedProduct.Id);

            var useUpdate = false;

            if (this.selectedImageSourceOption == "Orphaned Images") {
                useUpdate = true;
            }

            console.log(useUpdate);

            copySignImage({
                    imageId: selectedImage.ImageId,
                    quoteId: this.recordId,
                    quoteDetailId: selectedProduct.Id,
                    useUpdate: useUpdate
                }).then(data => {
                    if (data) {
                        console.log(data);
                        this.loadExistingImages();
                    } else if (error) {
                        var errorJson = JSON.stringify(error);
                        console.log("Error copying images1: " + errorJson);
                        this.errorMessage = errorJson;
                        this.showError = true;
                    }                    
                    this.copyImage = false;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error copying2: " + errorJson);
                    this.errorMessage = errorJson;
                    this.showError = true;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error copying images3: " + error);
            this.errorMessage = errorJson;
            this.showError = true;
            this.loaded = true;
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}