public class SampleRequestBulkTicketPrintController {
    public List<Sample_Request__c> sampleRequestList {get; set;}    
    public SampleRequestBulkTicketPrintController(){
        List<string> urlParam = new List<string>();
        System.debug('###'+Apexpages.currentPage().getParameters().get('Ids'));
        string urlStr = Apexpages.currentPage().getParameters().get('Ids');
        urlParam = urlStr.split(',');
        sampleRequestList =[SELECT Id, Name,OwnerId,Notes__c,Desired_Shipping_Method__c,Street_Address__c,City__c,State__c,Country__c,Postal_Code__c,Owner.Name,
                                            Account__c,Account__r.Name,Account__r.Customer_Number__c,Account__r.Owner.Name,
                                            Contact__c,Contact__r.Name, Lead__r.Name, Lead__r.Company,
                                            (SELECT Id,Name,Quantity__c,Item_Cost__c,Total_Cost__c,Sample_Product__r.Name,Sample_Product__r.ProductCode FROM Sample_Request_Items__r order by CreatedDate desc)
                                            FROM Sample_Request__c WHERE Name IN:urlParam order by CreatedDate desc];
        
    }
   

}