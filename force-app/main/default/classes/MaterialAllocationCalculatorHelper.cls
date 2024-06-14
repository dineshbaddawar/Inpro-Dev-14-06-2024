public with sharing class MaterialAllocationCalculatorHelper {
    @AuraEnabled()
    public static string calcAllocations(String quoteId, string quoteProductId) {                      
        inproAllocationService.AllocationServiceSoap service = new inproAllocationService.AllocationServiceSoap();
        service.timeout_x = 120000;
        inproAllocationService.CalculateAllocationsResult results = service.calculateAllocations(quoteId,quoteProductId, 'dsj8U73_3nv3Dhba');
        if(results.Status == true)
        {
            return JSON.serialize(results.QuoteProducts.QuoteProduct);
        }
        else {
            return JSON.serialize(results.Message);
        }
    }  
}