public with sharing class OrderConfirmationController {

    public OrderConfirmationWrapper orderConfirmationWrapper {get;set;}
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    public OrderConfirmationController() {
        try
        {
            string results = 'Error';             
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            String internalId = Apexpages.currentPage().getParameters().get('internalId');        
            
            results = service.retrieveOrderConfirmation(internalId, 'dsj8U73_3nv3Dhba'); 
            orderConfirmationWrapper = (OrderConfirmationWrapper)JSON.deserialize(results, OrderConfirmationWrapper.class);
        }
        catch(Exception ex)
        {
            throw new OtherException(ex.getMessage() + ex.getStackTraceString());
        }
    }

    public class OrderConfirmationWrapper
    {
        public string orderNumber { get; set; }
        public string customerNumber { get; set; }
        public string reference { get; set; }
        public string shippingContact { get; set; }
        public string quoteName { get; set; }
        public DateTime shipDate { get; set; }
        public string companyName { get; set; }
        public string companyAddress1 { get; set; }
        public string shipToAddress1 { get; set; }
        public string companyAddress2 { get; set; }
        public string shipToAddress2 { get; set; }
        public string companyAddress3 { get; set; }
        public string shipToAddress3 { get; set; }
        public string companyAddress4 { get; set; }
        public string shipToAddress4 { get; set; }
        public string poNumber { get; set; }
        public string shipVia { get; set; }
        public DateTime orderDate { get; set; }
        public string salesRep { get; set; }
        public string terms { get; set; }
        public decimal subTotal { get; set; }
        public decimal shippingCost { get; set; }
        public string liftGate { get; set; }
        public string driverWait { get; set; }
        public string loadingDock { get; set; }
        public string residential { get; set; }
        public string constructionSite { get; set; }
        public string serviceCall { get; set; }
        public Boolean isLumpSum { get; set; }
        public List<OrderConfirmationItem> orderItems { get; set; }
    }

    public class OrderConfirmationItem
    {
        public decimal quantity { get; set; }
        public string itemNumber { get; set; }
        public string description { get; set; }
        public decimal unitPrice { get; set; }
        public decimal amount { get; set; }
    }
}