@isTest
public with sharing class ChangeRequestProcessHelperTest {
    @isTest
    static void processTest() {
        string details =  ChangeRequestProcessHelper.FinishProcessingChangeRequest('1', 'Approve', 'Test', new List<String>(), new List<String>(), '' );
    }   
}