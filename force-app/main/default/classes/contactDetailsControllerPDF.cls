/*************************************************************
* Created by:   The Hunley Group
* Created on:    4/21/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:   Controller class for the Certificate visualforce 
*			 pages.
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
*
************************************************************/
public  class contactDetailsControllerPDF {
    
    public String StandardBodyName { get; set; }
    public String AttendeeName { get; set; }
    public String StandardBodyRegistrationNumber { get; set; }
    public String Coursecredit { get; set; }
    public String DateCompleted { get; set; }
    public String CourseName { get; set; }
    public String CourseNumber { get; set; }
    public String ProviderName { get; set; }
    public String ProviderNumber { get; set; }
    public String ContactInfo { get; set; }
    public String OwnerName { get; set; }
    public String StandardBodyLogo { get; set; }
    public String ProviderLogo { get; set; }
    public String isHSW {get;set;}
    public string City{get;set;}
    public string State{get;set;}
    public string CourseCreditLabel{get;set;}
    public string PresenterName{get;set;}
    public string ContactInfoProductRepresentative{get;set;}
    public string ProductRepresentative{get;set;}
    public string ProductRepresentativeTitle{get;set;}
    public string ProductRepresentativeAddress1{get;set;}
    public string ProductRepresentativeAddress2{get;set;}
    public string ProductRepresentativePhone{get;set;}
    
    public contactDetailsControllerPDF() {
        StandardBodyName = ApexPages.currentPage().getParameters().get('StandardBodyName');
        AttendeeName = ApexPages.currentPage().getParameters().get('AttendeeName');
        StandardBodyRegistrationNumber =ApexPages.currentPage().getParameters().get('StandardBodyRegistrationNumber');
        Coursecredit =ApexPages.currentPage().getParameters().get('Coursecredit');
        DateCompleted=ApexPages.currentPage().getParameters().get('DateCompleted');
        CourseName=ApexPages.currentPage().getParameters().get('CourseName');
        CourseNumber=ApexPages.currentPage().getParameters().get('CourseNumber');
        ProviderName=ApexPages.currentPage().getParameters().get('ProviderName');
        ProviderNumber=ApexPages.currentPage().getParameters().get('ProviderNumber');
        ContactInfo=ApexPages.currentPage().getParameters().get('ContactInfo');
        OwnerName=ApexPages.currentPage().getParameters().get('OwnerName');
        StandardBodyLogo = ApexPages.currentPage().getParameters().get('StandardBodyLogo');
        ProviderLogo = ApexPages.currentPage().getParameters().get('ProviderLogo');
        
        if(isHSW == 'true')
            CourseCreditLabel='HSW LEARNING UNIT';
        else
            CourseCreditLabel='LEARNING UNIT';
        
        string landlRecordId = ApexPages.currentPage().getParameters().get('l&lRecordId');
        LunchAndLearnEvent__c landlRecord = [Select Id,Presenter_User__c,Presenter_User__r.Name,
                                             Session_Number__c,City__c,State__c
                                             from LunchAndLearnEvent__c where
                                             Id=:landlRecordId];
        City = landlRecord.City__c;
        State = landlRecord.State__c;
        PresenterName = landlRecord.Presenter_User__r.Name;
        if(PresenterName == null){
            PresenterName = '-';
        }
        if(City == null){
            City = '-';
        }
        if(State == null){
            State = '-';
        }
        
        ContactInfoProductRepresentative=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative_Email__c');
        ProductRepresentative=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative__c');
        ProductRepresentativeTitle=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative_Title__c');
        ProductRepresentativeAddress1=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative_Address_L1__c');
        ProductRepresentativeAddress2=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative_Address_L2__c');
        ProductRepresentativePhone=LunchandLearnUtils.GetMetadataValue('AIA_Products_Representative_Phone__c');
        
        if(StandardBodyRegistrationNumber == null)
            StandardBodyRegistrationNumber = '-';
        
    }
  
}