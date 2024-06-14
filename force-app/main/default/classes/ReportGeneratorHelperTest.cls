@isTest
private class ReportGeneratorHelperTest {
    @isTest static void testSavedSearchExecution() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
		String results = ReportGeneratorHelper.runSavedSearch(new List<ReportGeneratorHelper.ReportFilter>(),'1234','0056g000005OkrhAAC');
		//System.assertEquals('Success', results);
	}

    @isTest static void testRetrieveNetSuiteFilterValues() {
        Test.setMock(WebServiceMock.class, new sfdataTest());
		String results = ReportGeneratorHelper.retrieveNetSuiteFilterValues();
		//System.assertEquals('Success', results);
	}
}