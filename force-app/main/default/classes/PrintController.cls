/*************************************************************
* Created by:   The Hunley Group
* Created on:    11/01/2020
* ===========================================================
* Test Class:   PrintControllerTest
* ===========================================================
* Purpose:   Conttroller class of printTickets vfp
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 11/01/2020    THG - NK        Created
*
************************************************************/
public class PrintController {
    public List<Sample_Request__c> getIDs{get;set;}
    public List<Sample_Request__c> sampleRequestList {get; set;}   
    
    public PrintController(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
        //System.debug('##getIDs'+ controller.getSelected());
        
        sampleRequestList =[SELECT Id, Name,OwnerId,Notes__c,Desired_Shipping_Method__c,Street_Address__c,City__c,State__c,Country__c,Postal_Code__c,Owner.Name,
                            Account__c,Account__r.Name,Account__r.Customer_Number__c,Account__r.Owner.Name,
                            Contact__c,Contact__r.Name,Project__c,Inside_Rep__c,Side_Mark__c,ISR__c,ISR__r.Name,
                             Customer_Billing_Zip__c,Customer_Shipping_Account_Number__c, Has_Inactive_Product__c,
                            (SELECT Id,Name,Quantity__c,Item_Cost__c,Total_Cost__c,Sample_Product__r.Name,Sample_Product__r.ProductCode,Sample_Product__r.IsActive FROM Sample_Request_Items__r order by Sample_Product__r.Name ASC)
                            FROM Sample_Request__c WHERE Id IN: getIDs AND Status__c = 'Approved' order by Name ASC];
        
        for(Sample_Request__c sr: sampleRequestList)
        {
            sr.Barcode_URL__c = 'https://barcode.tec-it.com/barcode.ashx?data=' + sr.Name + '&code=Code128&dpi=72&dataseparator=';
            if(sr.Sample_Request_Items__r != null)
            {
                for(Sample_Request_Item__c i: sr.Sample_Request_Items__r)
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

            List<Sample_Request__c> validSampleRequets = new List<Sample_Request__c>();

            //Iterate through sample items
            for (Sample_Request__c sr :sampleRequestList){
                Boolean hasInactiveProduct = false;
                for(Sample_Request_Item__c sri : sr.Sample_Request_Items__r)
                {
                    //Flag inactive products
                    if (!sri.Sample_Product__r.IsActive)
                    {
                        hasInactiveProduct = true;
                    }
                }
                //Only update sample requests with active-only products
                if (!hasInactiveProduct)
                {
                    sr.Print_Date__c = now;
                    validSampleRequets.add(sr);
                }
                else{
                    sr.Has_Inactive_Product__c = true;
                }
            }
            if(validSampleRequets.size()>0){
                update validSampleRequets; 
            }
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}