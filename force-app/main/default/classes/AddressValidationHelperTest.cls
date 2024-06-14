@isTest
public with sharing class AddressValidationHelperTest {
    @isTest static void runTests() {
        Test.setMock(WebServiceMock.class, new sfdataTest());		
        string updateResultAccount = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Account', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', true);
        string updateResultContact = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Contact', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', true);
        string updateResultSampleRequest = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Sample Request', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', true);
        string updateResultAccount2 = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Account', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', false);
        string updateResultContact2 = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Contact', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', false);
        string updateResultSampleRequest2 = AddressValidationHelper.UpdateAddress('0016g000009eq6yAAA', 'Sample Request', 'Shipping', 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150', false);
        string objectNameById = AddressValidationHelper.GetObjectNameById('0016g000009eq6yAAA');
        string validateAddress1Account = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Account', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');
        string validateAddress1SampleRequest = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Sample Request', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');
        string validateAddress1Contact = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Contact', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');        
        string validateAddress2Account = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Account', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');
        string validateAddress2SampleRequest = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Sample Request', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');
        string validateAddress2Contact = AddressValidationHelper.ValidateAddressOne('0016g000009eq6yAAA', 'Contact', true, 'S80W18766 Apollo Dr', '', 'Muskego', 'Wisconsin', '53150');        
        string countryResult = AddressValidationHelper.GetCountries();        
    }
}