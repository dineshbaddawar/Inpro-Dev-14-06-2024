@isTest
private class QuoteDiscountingHelperTest{

	@testSetup static void setup(){
		
	}

	@isTest static void testGetExistingProductDiscounts() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<QuoteDiscountingHelper.qProduct> results = QuoteDiscountingHelper.getExistingProductDiscounts('', '');	
		results[0].ColorPalette = '';
		results[0].DisplayName = '';
		System.assertEquals(1, results.size());
	}

	@isTest static void testSaveDiscounts() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<QuoteDiscountingHelper.qProduct> products = QuoteDiscountingHelper.getExistingProductDiscounts('', '');	
		String results = QuoteDiscountingHelper.saveDiscounts('', products);
		System.assertEquals('', results);
	}
}