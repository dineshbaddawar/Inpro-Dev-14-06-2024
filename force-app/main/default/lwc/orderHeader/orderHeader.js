import {
    LightningElement,
    api,
    track
} from 'lwc';

import getTransactionInformation from '@salesforce/apex/OrderHelper.getOrderHeaderInformation';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class OrderHeader extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track loaded = false;
    @track fulfillmentColumns = [{
        label: 'Ship Date',
        fieldName: 'ShipDate',
        type: 'date',
        sortable: true
    },
    {
        label: 'Status',
        fieldName: 'Status',
        type: 'text',
        sortable: true
    },
    {
        label: 'Tracking Number',
        fieldName: 'TrackingNumber',
        type: 'text',
        sortable: true
    },
    {
        label: 'Tracking URL',
        fieldName: 'TrackingURL',
        type: 'url',
        typeAttributes: { tooltip: { fieldName: 'TrackingURLLabel' }, target: '_blank', label: { fieldName: 'TrackingURLLabel' } },
    },
    {
        label: 'Shipping Method',
        fieldName: 'ShippingMethod',
        type: 'text',
        sortable: true
    }   
    ];
    @track shipToContact = '';
    @track orderStatus = '';
    @track expectedShipDate;
    @track orderStartDate;
    @track actualShipDate;
    @track poNumber = '';
    @track nonCommissionable = false;
    @track subTotal;
    @track total;
    @track shippingAmount;
    @track tax;
    @track fulfillmentData = [];

    connectedCallback() {
        this.loaded = false;
        this.retrieveOrderHeader();
    }

    retrieveOrderHeader()
    {
        try {
            getTransactionInformation({
                recordId: this.recordId,
                recordType: this.objectApiName
            }).then(data => {
                console.log(data);
                var resultData = JSON.parse(data);
                if(resultData.status != null && resultData.status != 'Error: This order no longer exists in NetSuite.')
                {
                    this.shipToContact = resultData.shipToContact;
                    this.orderStatus = resultData.status;

                    if(resultData.expectedShippingDate != null)
                    {
                        var date = new Date(resultData.expectedShippingDate);
                        if(date != null && date.getFullYear() != 1)
                            this.expectedShipDate = ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + date.getFullYear();
                    }
                    
                    if(resultData.orderStartDate != null)
                    {
                        var date = new Date(resultData.orderStartDate);
                        if(date != null && date.getFullYear() != 1)
                            this.orderStartDate = ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + date.getFullYear();
                    }

                    if(resultData.actualShipDate != null)
                    {
                        var date = new Date(resultData.actualShipDate);
                        if(date != null && date.getFullYear() != 1)
                            this.actualShipDate = ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + date.getFullYear();
                    }
                    
                    this.poNumber = resultData.poNumber;
                    this.nonCommissionable = resultData.nonCommissionable;
                    if(resultData.total != null)
                    {
                        this.total = resultData.total.toLocaleString('en-US', { 
                            style: 'currency', 
                            currency: 'USD' 
                        });
                    }
                    if(resultData.shippingAmount != null)
                    {
                        this.shippingAmount = resultData.shippingAmount.toLocaleString('en-US', { 
                            style: 'currency', 
                            currency: 'USD' 
                        });
                    }
                    if(resultData.tax != null)
                    {
                        this.tax = resultData.tax.toLocaleString('en-US', { 
                            style: 'currency', 
                            currency: 'USD' 
                        });
                    }
                    if(resultData.subTotal != null)
                    {
                        this.subTotal = resultData.subTotal.toLocaleString('en-US', { 
                            style: 'currency', 
                            currency: 'USD' 
                        });
                    }
                    
                    (resultData.orderFulfillments).forEach(li => {
                        
                        if(li.Status != null)
                        {
                            if(li.Status == '_shipped')
                                li.Status = 'Shipped';
                        }
                        li.TrackingURLLabel = 'Click here to track..';
                        if(li.TrackingNumber != null && li.ShippingMethod != null)
                        {
                            if(li.ShippingMethod == 'FedEx')
                                li.TrackingURL = 'http://www.fedex.com/Tracking?ascend_header=1&clienttype=dotcom&cntry_code=us&language=english&tracknumbers=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'UPS 2ND DAY AIR')
                                li.TrackingURL = 'http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'UPS 3 DAY SLCT')
                                li.TrackingURL = 'http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'UPS Ground')
                                li.TrackingURL = 'http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'UPS NDA SAVER')
                                li.TrackingURL = 'http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'UPS NEXT DAY')
                                li.TrackingURL = 'http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=' + li.TrackingNumber + '&AgreeToTermsAndConditions=yes&ignore=&track.x=34&track.y=9';
                            else if (li.ShippingMethod == 'Old Dominion')
                                li.TrackingURL = 'https://www.odfl.com/Trace/standardResult.faces?pro=' + li.TrackingNumber;
                            else if (li.ShippingMethod == 'OLD DOMINION')
                                li.TrackingURL = 'https://www.odfl.com/Trace/standardResult.faces?pro=' + li.TrackingNumber;
                            else if (li.ShippingMethod == 'Dayton Freight')
                                li.TrackingURL = 'https://tools.daytonfreight.com/tracking/detail/' + li.TrackingNumber;
                            else if (li.ShippingMethod == 'DAYTON FREIGHT')
                                li.TrackingURL = 'https://tools.daytonfreight.com/tracking/detail/' + li.TrackingNumber;
                            else
                                li.TrackingURLLabel = 'Unable to Track Shipment..';
                        }
                        else
                        {
                            li.TrackingURLLabel = 'Unable to Track Shipment..';
                        }
                    });
                    this.fulfillmentData = resultData.orderFulfillments;
                }
                else
                    alert(resultData.status);
                this.loaded = true;
            });
        } catch (error) {
            console.log(error);
            this.loaded = true;
        }
    }
}