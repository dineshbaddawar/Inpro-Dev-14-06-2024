public class AcceptOrRejectLeadPageController {
  public boolean showAcceptedPnl { get; set; }
  public Construction_Project__c objConstruction { get; set; }
  public String CompanyLogo { get; set; }
  public Boolean leadAccepted { get; set; }
  private String acceptOrReject; 


  public AcceptOrRejectLeadPageController() {
    showAcceptedPnl = true;
    acceptOrReject = apexpages.currentpage().getparameters().get('statusResponse');
    leadAccepted = (acceptOrReject == 'accept');
    // leadAccepted = false;
    // 
  }
  public void acceptOrReject() {
    // load the URL of our company logo to put in the header:
    CompanyLogo = HunleyUtils.GetMetadataValue('Customer_Image_Logo__c');

    string oppRefId = apexpages.currentpage().getparameters().get('oppReferralId');
    string leadRecId = apexpages.currentpage().getparameters().get('leadRecId');
    string userId = apexpages.currentpage().getparameters().get('userId');
    User loggedinUser = [
      SELECT
        Id,
        ContactId,
        Name,
        LastName,
        FirstName,
        CompanyName,
        Title,
        Street,
        State,
        City,
        PostalCode,
        Country,
        Email,
        Phone
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
    Lead_Recipients__c leadRecObj = [
      SELECT
        Id,
        Name,
        Refer_Lead__c,
        Account_of_Lead_Recipient__c,
        Referral_Status_Response__c
      FROM Lead_Recipients__c
      WHERE Id = :leadRecId
    ];
    Opportunity_Referral__c oppRefObj = [
      SELECT
        Id,
        ConstructionProject__r.Name,
        ConstructionProject__r.City__c,
        Account__r.Owner.Email,
        Opportunity__c,
        Account__c,
        Account__r.Name,
        Opportunity__r.Owner.Name,
        Opportunity__r.Owner.Email,
        Contractor_Status__c,
        Product_Links__c
      FROM Opportunity_Referral__c
      WHERE Id = :oppRefId
    ];
    objConstruction = [
      SELECT
        Id,
        Product_Links__c,
        Construction_Stage__c,
        Bid_Date__c,
        ConstructConnect_Building_Type__c,
        ConstructConnect_Building_SubType__c,
        Street__c,
        City__c,
        State__c,
        Country__c,
        General_Contractor__r.Name,
        OwnerId,
        Name,
        Public_Links__c,
        Substitution_Message_To_Arch__c,
        Owner.Name,
        OwnerCompanyName__c,
        OwnerStreet__c,
        Owner_City__c,
        OwnerState__c,
        OwnerPostalCode__c,
        Owner.Phone,
        Owner.Email,
        (SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments)
      FROM Construction_Project__c
      WHERE id = :oppRefObj.ConstructionProject__c
    ];
      system.debug('objConstruction.Name'+objConstruction.Name);
    string subLine = apexpages.currentpage().getparameters().get('subLineItems');
    List<String> subReqIDs = subLine.split('_');

    List<Substitution_Line_Item__c> slItemList = [
      SELECT Name, Specification_Status__c, Substitution_Status__c, Status__c
      FROM Substitution_Line_Item__c
      WHERE id IN :subReqIDs
    ];

    if (acceptOrReject == 'accept') {
      oppRefObj.Contractor_Status__c = 'Accepted Lead';
      leadRecObj.Referral_Status_Response__c = 'Closed Won';
      for (Substitution_Line_Item__c sli : slItemList) {
        sli.Status__c = 'Referral Accepted';
      }
      update slItemList;
      showAcceptedPnl = true;
    } else {
      oppRefObj.Contractor_Status__c = 'Declined to Bid';
      leadRecObj.Referral_Status_Response__c = 'Closed Lost';
      showAcceptedPnl = false;
    }
    update oppRefObj;
    update leadRecObj;

    if (oppRefObj.Contractor_Status__c == 'Accepted Lead') {
      String templateId = Label.ReferalToContractor;
      string textforemail = '<p>Thank you for accepting this project lead; please follow up and quote it as soon as possible.</p>';
      textforemail += '<p><b>Project details:</b></p>';
      textforemail += '<ul>';
      textforemail +=
      '<li>Project Name: ' +
        objConstruction.Name +
        '</li>';
        textforemail +=
        '<li>Stage of Construction: ' +
        objConstruction.Construction_Stage__c +
        '</li>';
        textforemail +=
        '<li>Bid Date: ' +
        objConstruction.Bid_Date__c +
        '</li>';
      textforemail +=
      '<li>Type of Building: ' +
      objConstruction.ConstructConnect_Building_Type__c +
      ',' +
      objConstruction.ConstructConnect_Building_SubType__c +
        '</li>';
        textforemail +=
        '<li>Address: ' +
        objConstruction.Street__c +
        ',' +
        objConstruction.City__c +
        ',' +
        objConstruction.State__c +
        ',' +
        objConstruction.Country__c +
        '</li>';
        textforemail +=
        '<li>General Contractor: ' +
        objConstruction.General_Contractor__r.Name +
        '</li>';
        textforemail += '</ul>';

      if( oppRefObj.Product_Links__c != null &&
          oppRefObj.Product_Links__c != ''){
        textforemail += '<p>' + oppRefObj.Product_Links__c + '</p>';
      }

      textforemail += '<p>Thank you!</p>';
      
      // if (
      //   objConstruction.Substitution_Message_To_Arch__c != null ||
      //   objConstruction.Substitution_Message_To_Arch__c != ''
      // ) {
      //   textforemail +=
      //     '<p>' +
      //     objConstruction.Substitution_Message_To_Arch__c +
      //     '</p>';
      // }
      textforemail += '<p>Best Regards,</p>';
      textforemail +=
        '<p>' +
        loggedinUser.FirstName +
        ' ' +
        loggedinUser.LastName +
        '</p>';
      textforemail +=
        '<p>' +
        loggedinUser.CompanyName +
        ' | ' +
        loggedinUser.Street +
        '  ' +
        loggedinUser.City +
        ' | ' +
        loggedinUser.State +
        ' | ' +
        loggedinUser.PostalCode +
        '<br></br>';
      textforemail +=
        ' Phone:' +
        loggedinUser.Phone +
        '| Email: ' +
        loggedinUser.Email +
        '</p>';

      LIST<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
      for (AccountContactRelation a : [
        SELECT
          Id,
          AccountId,
          Account.Name,
          Contact.Email,
          ContactId,
          Contact.Name,
          Roles
        FROM AccountContactRelation
        WHERE
          Roles INCLUDES ('Lead Recipient')
          AND AccountId = :oppRefObj.Account__c
          AND Contact.Email != null
      ]) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new List<String>{ a.Contact.Email };
        message.subject = 'Full Project Details : ' + objConstruction.Name;
        message.setHtmlBody(textforemail);

        message.setReplyTo(loggedinUser.Email);
        message.setSenderDisplayName(loggedinUser.Name);

        lstEmailsToSend.add(message);
      }
      Messaging.sendEmail(lstEmailsToSend);
    }
  }
}