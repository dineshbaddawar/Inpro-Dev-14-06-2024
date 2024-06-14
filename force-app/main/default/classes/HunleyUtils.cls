public with sharing class HunleyUtils {

    // used to avoid *magic string* fields passed around --  strongly typed properties are used instead:
    //
    // usage:  HunleyUtils.GetMetadataValue(HunleyUtils.COMPANYNAME)
    public static String COMPANY_NAME = 'Company_Name__c';
    public static String COMPANY_ADDRESS = 'Company_Street__c';
    public static String COMPANY_PHONE = 'Company_Phone__c';
    public static String COMPANY_CITYSTATEZIP = 'Company_CityStateZip__c';
    public static String CONPROJ_STATUS_TRANSITION = 'Construction_Project_Status_Transition__c';
    public static String CUSTOMER_IMAGE_LOGO_URL = 'Customer_Image_Logo__c';
    public static String REFERRAL_ACCEPT_PAGE_SITES_URL = 'Referral_Accept_Page_URL__c';
    

    private static Subreq_Setting__mdt myRow = null;

    // Utility method to allow easy access to our SubReq metadata settings:
    public static string GetMetadataValue(String name) {

        
        // cache the result:
        if (myRow == null) {

            List<Subreq_Setting__mdt> rows = [
                    select Construction_Project_Status_Transition__c,
                            Customer_Image_Logo__c,
                            Referral_Accept_Page_URL__c,
                            Company_Name__c,
                            Company_Street__c,
                            Company_Phone__c,
                            Company_CityStateZip__c
                    from  Subreq_Setting__mdt
            ];

            myRow = rows.get(0);

        }


        return (String) myRow.get(name);

    }



}