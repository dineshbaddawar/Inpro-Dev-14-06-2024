public with sharing class GlobalHelper {
    public static string GetTaxEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/SalesforceTax/service.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/SalesforceTax/service.asmx';
        }
    }

    public static string GetDataWareHouseEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/datawarehouse/datawarehouse.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/datawarehouse/datawarehouse.asmx';
        }
    }

    public static string GetSfDataEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/sfDataWebService.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/sfDataWebService.asmx';
        }
    }

    public static string GetInproRCAEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/SalesforceRCA/RCAService.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/SalesforceRCA/RCAService.asmx';
        }
    }

    public static string GetExpediteEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/SalesforceExpedite/ExpediteService.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/SalesforceExpedite/ExpediteService.asmx';
        }
    }

    public static string GetSharepointDocumentMangementEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/SharePoint/SharePointDocumentService.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/SharePoint/SharePointDocumentService.asmx';
        }
    }

    public static string GetAllocationServiceEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34910/AllocationCalculator/AllocationService.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34772/AllocationCalculator/AllocationService.asmx';
        }
    }

    public static string GetEDIServiceEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34950/edisvc.asmx';
        }
        else
        {
            return 'https://cloudproxy.inprocorp.com:34850/edisvc.asmx';
        }
    }

    public static string GetTDMServiceEndpoint()
    {
        if(IsProductionOrg())
        {            
            return 'https://cloudproxy.inprocorp.com:34830/TDMService.asmx';
        }
        else
        {            
            return 'https://cloudproxy.inprocorp.com:34840/TDMService.asmx';
        }
    }

    public static Boolean IsProductionOrg() { // Method to check of environement is Production ORG or not
        Organization org = [select IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        return (org.IsSandbox == true) ? false : true;
    }
}