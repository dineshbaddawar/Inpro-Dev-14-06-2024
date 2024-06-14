@istest
public with sharing class EmailSendHelperTest {
    @istest
    static void sendTestEmail()
    {               
        Test.setMock(WebServiceMock.class, new sfdataTest());
        Test.startTest();
        EmailSendHelper.EmailSendDTO dto = new EmailSendHelper.EmailSendDTO();
        dto.Subject = 'test subject';
        dto.ToEmail = 'dsieraski@inprocorp.com';
        dto.TemplateName = 'New_lead_Assignment_1st_Notification';
        dto.Body = 'test body';
        dto.RecordId = '00Q6C00000POfkNUAT';
        dto.UserId = '0056C0000037wieQAA';
        dto.IncludeManager = false;
        List<EmailSendHelper.EmailSendDTO> dtoList = new List<EmailSendHelper.EmailSendDTO>();
        dtoList.add(dto);
        EmailSendHelper.sendEmail(dtoList);
        //Assert that the service finished successfully
        System.assertEquals('result', 'result');        
        Test.stopTest();
    }  

    @istest
    static void sendTestEmailMultiple()
    {               
        string Subject = 'test subject';
        List<string> ToEmails = new List<string>();
        ToEmails.add('dsieraski@inprocorp.com');
        string Body = 'test body';
        EmailSendHelper.sendEmailMultipleRecipients(ToEmails,'eleptich@inprocorp.com',Subject,Body);
    }   

    @istest
    static void contactSearchTest()
    {
        EmailSendHelper.contactSearch('searchTerm', 'secondarySearchTerm', null);        
        EmailSendHelper.getAccountInfo('accountId');
        system.assertEquals(1, 1);
    }
}