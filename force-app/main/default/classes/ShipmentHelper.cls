public with sharing class ShipmentHelper{

    @invocablemethod(label='Update Rates' description='Update UPS Ground and USPS Priority Rates at time of delivery.')
    public static void UpdateRatesFlow(List<string> recordIds)
    {
        for(string recordId : recordIds)
        {
            SampleRequestHelper.UpdateRateService(recordId);
        }
    }
}