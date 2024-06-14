public with sharing class ReportGeneratorHelper {
    // @AuraEnabled
    // public static string runReportPDF(List<ReportFilter> filters, string reportId, string reportPath) {                        
    //     sfExpedite.ExpediteServiceSoap service = new sfExpedite.ExpediteServiceSoap();
    //     service.timeout_x = 120000;
    //     string results = service.RetrievalByOrder('dsj8U73_3nv3Dhba', orderNumber);     
    //     return results;  
    // }

    @AuraEnabled
    public static string runSavedSearch(List<ReportFilter> filters, string reportId, string reportPath) {                        
        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;      
        sfdata.ArrayOfReportFilter sfdataReportFilters = new sfdata.ArrayOfReportFilter();
        sfdataReportFilters.ReportFilter = new List<sfdata.ReportFilter>();
        for(ReportFilter f : filters)
        {
            sfdata.ReportFilter newFilter = new sfdata.ReportFilter();
            newFilter.filterName = f.filterName;
            newFilter.filterValue = f.filterValue;
            sfdataReportFilters.ReportFilter.add(newFilter);
        } 
        return service.runNetSuiteSavedSearch(sfdataReportFilters, reportId, '', 'dsj8U73_3nv3Dhba'); 
    }

    @AuraEnabled
    public static string retrieveNetSuiteFilterValues() {                        
        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;             
        return service.retrieveNetSuiteFilterValues('dsj8U73_3nv3Dhba'); 
    }

    public class ReportFilter
    {
        @AuraEnabled
        public string filterName {get;set;}
        @AuraEnabled
        public string filterValue {get;set;}
    }
}