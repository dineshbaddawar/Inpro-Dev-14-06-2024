@isTest
public with sharing class USPSAddressServicesTest {
    @IsTest
    static void testService() {
        String zip = '35811';
        Set<String> zips = new Set<String>();
        zips.add(zip);
        USPSAddressServices usps = new USPSAddressServices();
        List<USPSAddressServices.ResolvedZip> rzips = usps.resolveZipcodes(zips);
        system.assert(rzips.size() > 0);
    }
}