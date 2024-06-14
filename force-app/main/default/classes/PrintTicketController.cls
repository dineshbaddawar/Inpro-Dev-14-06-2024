/*************************************************************
* Created by:   The Hunley Group
* Created on:    10/07/2020
* ===========================================================
* Test Class:   PrintControllerTest
* ===========================================================
* Purpose:   Conttroller class of SampleRequestPrintTicket vfp
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 10/07/2020    THG - NK        Created
*
************************************************************/
public class PrintTicketController {
    public Sample_Request__c sampleRequest {get; set;}    
    public PrintTicketController() {
        sampleRequest = new Sample_Request__c();
        for (Sample_Request__c sampleItem :[SELECT Id, Name,OwnerId,Notes__c,Desired_Shipping_Method__c,Street_Address__c,City__c,State__c,Country__c,Postal_Code__c,Owner.Name,
                                            Account__c,Account__r.Name,Account__r.Customer_Number__c,Account__r.Owner.Name,
                                            Contact__c,Contact__r.Name,Project__c,Inside_Rep__c,Side_Mark__c,ISR__c,ISR__r.Name,
                                            Customer_Billing_Zip__c,Customer_Shipping_Account_Number__c, Lead__r.Company, Lead__r.Name,Has_Inactive_Product__c,
                                            (SELECT Id,Name,Quantity__c,Item_Cost__c,Total_Cost__c,Sample_Product__r.Name,Sample_Product__r.IsActive,Sample_Product__r.ProductCode FROM Sample_Request_Items__r order by Sample_Product__r.Name ASC)
                                            FROM Sample_Request__c WHERE Id =:Apexpages.currentPage().getParameters().get('Id') order by Name ASC])
        {
            
            sampleRequest =sampleItem;

            sampleRequest.Barcode_URL__c = 'https://barcode.tec-it.com/barcode.ashx?data=' + sampleRequest.Name + '&code=Code128&dpi=72&dataseparator=';
            if(sampleRequest.Sample_Request_Items__r != null)
            {
                for(Sample_Request_Item__c i: sampleRequest.Sample_Request_Items__r)
                {
                    if(i.Sample_Product__r != null)
                        i.Sample_Product__r.Barcode_URL__c = 'https://barcode.tec-it.com/barcode.ashx?data=' + i.Sample_Product__r.ProductCode + '&code=Code128&dpi=72&dataseparator=';
                }
            }
        }
    }
    public void updatePrintDate() {
        try {
            Datetime now = system.now();

            Boolean hasInactiveProduct = false;
            for(Sample_Request_Item__c sri : sampleRequest.Sample_Request_Items__r)
            {
                if (!sri.Sample_Product__r.IsActive)
                {
                    hasInactiveProduct = true;
                }
            }
            if (!hasInactiveProduct)
            {
                sampleRequest.Print_Date__c = now;
                update sampleRequest;
            }
            else
            {
                sampleRequest.Has_Inactive_Product__c = true;
            }
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
}