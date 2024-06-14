@isTest
private class TerritoryHelperTest {
    @isTest static void testGetTerritory_success() {

		Test.setMock(WebServiceMock.class, new sfdataTest());
        
        TerritoryHelper.ZipDTO zipDTO = new TerritoryHelper.ZipDTO();
        zipDTO.StateCode = 'WI';
        zipDTO.ZipCode = '53105';     

        List<TerritoryHelper.ZipDTO> dtoList = new List<TerritoryHelper.ZipDTO>();
        dtoList.add(zipDTO);
           
		List<string> results = TerritoryHelper.getTerritory(dtoList);
		System.assertEquals(results[0],'');
	}
}