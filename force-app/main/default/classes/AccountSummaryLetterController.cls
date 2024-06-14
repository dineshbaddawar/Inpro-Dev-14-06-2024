public class AccountSummaryLetterController {

    public AccountSummaryWrapper accountSummaryWrapper {get;set;}
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    public AccountSummaryLetterController() {
        try
        {
            accountSummaryWrapper = new accountSummaryWrapper();
            String division = Apexpages.currentPage().getParameters().get('division');
            String customerNumber = Apexpages.currentPage().getParameters().get('customerNumber');
            String poNumber = '';//Apexpages.currentPage().getParameters().get('poNumber');
            String contractId = Apexpages.currentPage().getParameters().get('contractId');

            string results = 'Error';             
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;        
            
            results = service.retrieveAccountSummaryLetter(customerNumber, poNumber, contractId, division, 'dsj8U73_3nv3Dhba'); 
            accountSummaryWrapper = (AccountSummaryWrapper)JSON.deserialize(results, AccountSummaryWrapper.class);
        }
        catch(Exception ex)
        {
            throw new OtherException(ex.getMessage() + ex.getStackTraceString());
        }
    }

    public class AccountSummaryWrapper{
        public decimal totalContractAmount { get; set; }
        public decimal totalBilled { get; set; }
        public decimal contractBalance { get; set; }
        public decimal totalTransactionAmount { get; set; }
        public decimal totalPaidAmount { get; set; }
        public decimal totalDueAmount { get; set; }
        public string customerNumber { get; set; }
        public string customerName { get; set; }
        public string poNumber { get; set; }
        public string currentDate { get; set; }
        public string contractName { get; set; }
        public List<AccountSummaryCV> contractVersions { get; set; }
        public List<ContractInvoice> contractInvoices { get; set; }
    }

    public class AccountSummaryCV{
        public string name { get; set; }
        public decimal total { get; set; }
    }

    public class ContractInvoice{
        public DateTime invoiceDate { get; set; }
        public string invoiceDateString { get; set; }
        public string invoiceNumber { get; set; }
        public string orderNumber { get; set; }
        public string division { get; set; }
        public decimal amount { get; set; }
        public decimal paid { get; set; }
        public decimal balanceDue { get; set; }
    }
}