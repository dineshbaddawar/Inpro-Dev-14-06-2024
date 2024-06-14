/* Created by:   The Hunley Group
 * Created on:   4/24/2018
 * ===========================================================
 * Test Class:   ConProjRefController_Test
 * ===========================================================
 * Purpose:      This class acts as the controller for the custom Lightning Component, ReferConstructionProject.
 *
 * ===========================================================
 * Change History
 * Date          Author          Purpose
 * ----------    -------------   -----------------------------
 * 4/26/2018     THG - PS        Created
 * 7/21/2018     THG - PS        Restrict accounts by record type
 * 7/24/2018     THG - PS        Correct errors in record type usage
 * 7/26/2018     THG - PS        Added support for search without geolocation
 * 8/13/2018     THG - PS        Remove Contractor Type filter
 * 8/20/2018     THG - PS        Added support for setting StageName on successful referral
 * 3/21/2019     THG - DS        Included Opportunity Attachments in Referral email
 * 3/24/2020     THG - ATS       Edit rectype SOQL query to filter by DeveloperName, notId
 ************************************************************/
global with sharing class ConstructionProjectReferralController {
  @AuraEnabled
  //Public method that returns an Construction Project record back to the Lightning component.
  public static Construction_Project__c getConProjRecord(String conProjId) {
    Construction_Project__c conProjRecord = new Construction_Project__c();
    if (!String.isBlank(conProjId)) {
      conProjRecord = [
        SELECT
          Id,
          Name,
          Architect_Firm__r.Name,
          Street_Address__c,
          City__c,
          State__c,
          ZIP_or_Postal_Code__c,
          Country__c,
          County__c,
          Total_Constructed_Value__c,
          Architect_Firm__r.BillingStreet,
          Architect_Firm__r.BillingCity,
          Architect_Firm__r.BillingState,
          Architect_Firm__r.BillingCountry,
          Architect_Firm__r.BillingPostalCode,
          Architect_Firm__r.BillingLatitude,
          Architect_Firm__r.BillingLongitude,
          Queue_Geolocation__c,
          Project_Location__Latitude__s,
          Project_Location__Longitude__s
        FROM Construction_Project__c
        WHERE Id = :conProjId
      ];
    }

    return conProjRecord;
  }

  @AuraEnabled
  public static List<Substitution_Line_Item__c> getSubstitutionRequests(
    String conProjId
  ) {
    List<Substitution_Line_Item__c> subLineItemList = [
      SELECT
        Name,
        Project_Specification_Article_Paragraph__c,
        Specification_Status__c,
        Competing_Product_Basis_of_Design__c,
        Project_Specification_Page_Number__c,
        Project_Specification_Title__c,
        Project_Specification_Description__c,
        Substitution_Status__c,
        Status__c,
        ANSI_Category__c,
        Competors_Product_to_be_Substituted__c,
        Competitors_Listed_All__c,
        Substitute_Product_1__c,
        Substitute_Product_1__r.Name,
        Substitute_Product_2__c,
        Substitute_Product_2__r.Name,
        Project_Specification_Section_Number__c,
        Our_Specified_Product__c,
        Product_FamilyG__c
      FROM Substitution_Line_Item__c
      WHERE ConstructionProject__c = :conProjId
      ORDER BY Product_FamilyG__c
    ];
    return subLineItemList;
  }

  @AuraEnabled
  public static List<RecordType> getAccountRecordTypes() {
    List<Subreq_Setting__mdt> meta = [
      SELECT
        Construction_Project_Status_Transition__c,
        Customer_Image_Logo__c,
        Referral_Accept_Page_URL__c,
        Contractor_Record_Types__c
      FROM Subreq_Setting__mdt
    ];
    List<String> recTypeNames = meta[0].Contractor_Record_Types__c.split(',');

    Map<Id, String> recTypeMap = new Map<Id, String>();
    List<RecordType> recTypeList = [
      SELECT Id, Name, DeveloperName, SobjectType, IsActive
      FROM RecordType
      WHERE
        SobjectType = 'Account'
        AND IsActive = true
        AND DeveloperName IN :(recTypeNames)
    ];
    for (RecordType rt : recTypeList)
      recTypeMap.put(rt.Id, rt.Name);
    return recTypeList;
  }

  @AuraEnabled
  public static List<AccountTypeWrapper> getAccountTypePLValues(
    List<RecordType> recTypes
  ) {
    system.debug('recTypes' + recTypes);
    List<Id> recTypeIds = new List<Id>();
    if (recTypes.size() > 0) {
      for (RecordType rt : recTypes)
        recTypeIds.add(rt.Id);
    }
    List<Account_Record_Type_PL_Values__mdt> meta = [
      SELECT Contractor_Id__c, PL_Values__c
      FROM Account_Record_Type_PL_Values__mdt
      WHERE Contractor_Id__c IN :recTypeIds
    ];
    List<String> PLValuesList = meta[0].PL_Values__c.split(',');
    List<AccountTypeWrapper> wrapList = new List<AccountTypeWrapper>();
    for (string s : PLValuesList) {
      AccountTypeWrapper wrap = new AccountTypeWrapper();
      wrap.acctType = s;
      wrapList.add(wrap);
    }
    return wrapList;
  }

  @AuraEnabled
  //Public method that returns a list of AccountWrappers (defined below) to the Lightning Component.
  //The query for account records handles finding the nearest 20 by latitude/longitude
  //and other methods from the GeoLocationUtilities class handle calculating distance in miles.
  public static List<AccountWrapper> getAccounts(
    String conProjId,
    String acctName,
    List<RecordType> recTypes,
    List<AccountTypeWrapper> accTypes
    ) {
    List<AccountWrapper> acctList = new List<AccountWrapper>();
    List<Id> recTypeIds = new List<Id>();
    String accTypesList = '';
    if (recTypes.size() > 0) {
      for (RecordType rt : recTypes)
        recTypeIds.add(rt.Id);
    }

    if (accTypes != null) {
      for (AccountTypeWrapper aw : accTypes) {
        if (accTypesList.length() > 0)
          accTypesList += ',';
        accTypesList += '\'' + aw.acctType + '\'';
      }
    }

    if (!String.isBlank(conProjId)) {
      Construction_Project__c conProj = [
        SELECT
          Id,
          Project_Location__Latitude__s,
          Project_Location__Longitude__s,
          Architect_Firm__r.BillingLatitude,
          Architect_Firm__r.BillingLongitude,
          Architect_Firm__r.ShippingLatitude,
          Architect_Firm__r.ShippingLongitude
        FROM Construction_Project__c
        WHERE Id = :conProjId
      ];

      Decimal lat = conProj.Project_Location__Latitude__s;
      Decimal lon = conProj.Project_Location__Longitude__s;
      SYSTEM.debug('lat' + lat);

      // Build list of list of accounts that previously received a referral for this opportunity
      Map<Id, Opportunity_Referral__c> assignedAccounts = new Map<Id, Opportunity_Referral__c>();
      for (Opportunity_Referral__c oppRef : [
        SELECT Id, Account__c, ConstructionProject__c
        FROM Opportunity_Referral__c
        WHERE ConstructionProject__c = :conProjId
      ]) {
        assignedAccounts.put(oppRef.Account__c, oppRef);
      }

      // Build account query string
      String soqlQuery = 'Select Id,RecordTypeId, Name, Type, BillingStreet, BillingCity, BillingPostalCode, BillingState,';
      soqlQuery += 'BillingCountry, BillingLatitude, BillingLongitude,ShippingAddress,';
      soqlQuery += 'ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry,';
      soqlQuery += 'ShippingLatitude, ShippingLongitude, Billing_Street_Address__c, Billing_City__c, Billing_State__c,';
      soqlQuery += 'Billing_Country__c, Billing_Postal_Code__c, Contractor_Location__latitude__s,';
      soqlQuery += 'Contractor_Location__longitude__s, Contractor_Locator_Address_Choice__c,';
      soqlQuery += '(SELECT Contact.Name,Roles,Contact.Email FROM AccountContactRelations where Contact.Email != null AND Roles INCLUDES (\'Lead Recipient\'))';
      soqlQuery += ' from Account ';

      // Build 'where' string for account query
      String rtIds = '';
      if (recTypeIds.size() > 0) {
        for (Id rId : recTypeIds) {
          if (rtIds.length() > 0)
            rtIds += ',';
          rtIds += '\'' + rId + '\'';
        }
      }

      if (recTypeIds.size() > 0) {
        system.debug('query------>' + ' where RecordTypeId in (' + rtIds + ')');
        soqlQuery += 'where RecordTypeId in (' + rtIds + ')';
      }

      if (accTypesList.length() > 0) {
        system.debug('query------>' + ' and Type in (' + accTypesList + ')');
        soqlQuery += 'and Type in (' + accTypesList + ')';
      }

      system.debug('recTypeIds' + recTypeIds);
      if (!String.isBlank(acctName)) {
        acctName = String.escapeSingleQuotes(acctName);
        system.debug('acctName' + acctName);
        acctName += '%';
        system.debug('query------>' + ' and Name Like \'' + acctName + '\'');
        soqlQuery += ' and Name Like \'' + acctName + '\'';
      }

      String existingReferralQuery = soqlQuery;
      System.debug('query: ' + soqlQuery);
      if (
          !String.isBlank(String.valueOf(lat)) &&
          !String.isBlank(String.valueOf(lon)) &&
          (lat != 0 || lon != 0)
      ) {
        system.debug(
          'query------>' +
          ' ORDER BY DISTANCE(ShippingAddress, GEOLOCATION(' +
          lat +
          ',' +
          lon +
          '),\'mi\') ASC NULLS LAST'
        );
        soqlQuery +=
          ' ORDER BY DISTANCE(ShippingAddress, GEOLOCATION(' +
          lat +
          ',' +
          lon +
          '),\'mi\') ASC NULLS LAST';
      }

      soqlQuery += ' Limit 20';

      System.debug('query: ' + soqlQuery);

      // Commented out to ensure the following code always fires
      // may cause unwanted side effects - ATS 03/24/2020
      // if (
      //   (
      //     !String.isBlank(String.valueOf(lat)) &&
      //     !String.isBlank(String.valueOf(lon)) &&
      //     (lat != 0 || lon != 0)
      //   ) || !String.isBlank(acctName)
      // ) {
        for (Account a : database.query(soqlQuery)) {
          Boolean assigned = false;

          if (assignedAccounts.containsKey(a.Id)) {
            assigned = true;
            assignedAccounts.remove(a.Id);
          }
          System.debug('a.ID: ' + a.Id);
          System.debug('lat: ' + lat);
          System.debug('lon: ' + lon);
          System.debug(
            'a.Contractor_Location__latitude__s: ' +
            a.Contractor_Location__latitude__s
          );
          System.debug(
            'a.Contractor_Location__longitude__s: ' +
            a.Contractor_Location__longitude__s
          );
          System.debug('a.ShippingLatitude: ' + a.BillingLatitude);
          System.debug('a.ShippingLongitude: ' + a.BillingLongitude);
          System.debug('a.ShippingLatitude: ' + a.ShippingLatitude);
          System.debug('a.ShippingLongitude: ' + a.ShippingLongitude);

          Decimal accountLat = getAccountLatitude(a);
          Decimal accountLon = getAccountLongitude(a);

          //Decimal distance = (lat==null||lon==null||lat==0||lon==0|| a.Contractor_Location__latitude__s==null || a.Contractor_Location__longitude__s == null) ? null : GeoLocationUtilities.calculateDistance(lat, lon, a.Contractor_Location__latitude__s, a.Contractor_Location__longitude__s).setScale(0);
          Decimal distance = (lat == null ||
            lon == null ||
            lat == 0 ||
            lon == 0 ||
            accountLat == 0 ||
            accountLon == 0)
            ? null
            : GeoLocationUtilities.calculateDistance(
                  lat,
                  lon,
                  accountLat,
                  accountLon
                )
                .setScale(0);
          acctList.add(new AccountWrapper(a, assigned, distance));
        }
      // }
      
      // If any other previously referred accounts remain, query them and add them
      // to the return list
      if (assignedAccounts.keySet().size() > 0) {
        String assignedIds = '';

        for (String acctId : assignedAccounts.keySet()) {
          if (assignedIds.length() > 0)
            assignedIds += ',';
          assignedIds += '\'' + acctId + '\'';
        }
        system.debug('assignedIds' + assignedIds);
        if (!test.isRunningTest()) {
          if (existingReferralQuery.contains('where RecordTypeId')) {
            existingReferralQuery =
              existingReferralQuery +
              ' and Id in (' +
              assignedIds +
              ')';
            system.debug('inside where');
          } else {
            existingReferralQuery =
              existingReferralQuery +
              ' where Id in (' +
              assignedIds +
              ')';
            system.debug('inside else');
          }
          system.debug('query------>' + ' and Id in (' + assignedIds + ')');
          //existingReferralQuery = existingReferralQuery + ' and Id in (' + assignedIds + ')';
        }

        if (
          !String.isBlank(String.valueOf(lat)) &&
          !String.isBlank(String.valueOf(lon)) &&
          (lat != 0 ||
          lon != 0)
        ) {
          existingReferralQuery +=
            ' order by DISTANCE(ShippingAddress, GEOLOCATION(' +
            lat +
            ',' +
            lon +
            '),\'mi\') DESC';
        }

        System.debug('existing: ' + existingReferralQuery);

        for (Account alreadyAssigned : database.query(existingReferralQuery)) {

          Decimal assignedAccountLat = getAccountLatitude(alreadyAssigned);
          Decimal assignedAccountLon = getAccountLongitude(alreadyAssigned);

          //Decimal distance = (lat==null||lon==null||lat==0||lon==0 || alreadyAssigned.Contractor_Location__longitude__s == null) ? null : GeoLocationUtilities.calculateDistance(lat, lon, alreadyAssigned.Contractor_Location__latitude__s, alreadyAssigned.Contractor_Location__longitude__s).setScale(0);
          Decimal distance = (lat == null ||
            lon == null ||
            lat == 0 ||
            lon == 0 ||
            assignedAccountLat == 0 ||
            assignedAccountLon == 0)
            ? null
            : GeoLocationUtilities.calculateDistance(
                  lat,
                  lon,
                  assignedAccountLat,
                  assignedAccountLon
                )
                .setScale(0);
          if (acctList.size() > 0) {
            acctList.add(
              0,
              new AccountWrapper(alreadyAssigned, true, distance)
            );
          } else {
            acctList.add(new AccountWrapper(alreadyAssigned, true, distance));
          }
        }
      }
    }
    system.debug('acctList' + acctList);
    for (AccountWrapper aw : acctList)
      system.debug('aw.distance' + aw.distance);
    return acctList;
  }

  private static Decimal getAccountLatitude(Account a) {
    Decimal result = 0;
    if (isValidDecimal(a.BillingLatitude)) { 
      result = a.BillingLatitude;
    } else if (isValidDecimal(a.ShippingLatitude)) {
      result = a.ShippingLatitude;
    }
    return result;
  }

  private static Decimal getAccountLongitude(Account a) {
    Decimal result = 0;
    if (isValidDecimal(a.BillingLongitude)) { 
      result = a.BillingLongitude;
    } else if (isValidDecimal(a.ShippingLongitude)) {
      result = a.ShippingLongitude;
    }
    return result;
  }

  private static Boolean isValidDecimal(Decimal val) {
    Boolean result = false;
    if ( val != 0 && val != null) {
      result = true;
    }
    return result;
  }

  @AuraEnabled
  //Public method that returns a string for the UI Theme to determine appropriate navigation within
  //the Lightning component (either classic or Lightning).
  public static String getUIThemeDescription() {
    String theme = UserInfo.getUiThemeDisplayed();
    return theme;
  }

  @AuraEnabled
  //Public method that returns a string after attempting to create new Opportunity_Referral__c
  //records after accounts are chosen.
  public static String doAssignOpp(
    String conProjId,
    String[] acctWrapList,
    List<Substitution_Line_Item__c> subLineItems
  ) {
    String result = '';
    system.debug('subLineItems' + subLineItems);
    system.debug('acctWrapList' + acctWrapList);
    system.debug('conProjId' + acctWrapList);

    string subLineItemIds = '';
    List<Id> subReqIDs = new List<Id>();
    list<String> prodFamilyList = new List<String>();
    for (Substitution_Line_Item__c sli : subLineItems) {
      subLineItemIds += sli.Id + '_';
      prodFamilyList.add(sli.Product_FamilyG__c);
      subReqIDs.add(sli.Id);
    }
    subLineItemIds = subLineItemIds.removeEnd('_');

    User loggedinUser = [
      SELECT
        Id,
        ContactId,
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
      WHERE Id = :Userinfo.getUserId()
      LIMIT 1
    ];
    Construction_Project__c objConstruction = [
      SELECT
        Id,
        Product_Links__c,
        Construction_Stage__c,
        Bid_Date__c,
        Building_Type__c,
        Building_Sub_Type__c,
        Street_Address__c,
        City__c,
        State__c,
        Country__c,
        General_Contractor__r.Name,
        OwnerId,
        Owner.Email,
        Name,
        Public_Links__c,
        (SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments)
      FROM Construction_Project__c
      WHERE id = :conProjId
    ];
    list<AttachedContentDocument> attContentDocList = new List<AttachedContentDocument>();
    list<AttachedContentDocument> attContentDocConProjList = new List<AttachedContentDocument>();
    Set<Id> contDocIDs = new Set<Id>();
    list<ContentVersion> contentVersionList = new List<ContentVersion>();
    Set<Id> contentVersionIds = new Set<Id>();
    list<Substitution_Line_Item__c> slItemList = [
      SELECT
        ID,
        Name,
        Our_Specified_Product__c,
        (SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments)
      FROM Substitution_Line_Item__c
      WHERE id IN :subReqIDs
    ];
    Map<Id, Id> contDocContVersMap = new Map<Id, Id>();
    Map<String, List<ContentDistribution>> prodCdMap = new Map<String, List<ContentDistribution>>();
    for (Substitution_Line_Item__c sli : slItemList) {
      attContentDocList.addAll(sli.AttachedContentDocuments);
      for (AttachedContentDocument attdoc : attContentDocList) {
        contDocIDs.add(attdoc.ContentDocumentId);
      }
    }

    attContentDocConProjList.addAll(objConstruction.AttachedContentDocuments);
    for (AttachedContentDocument attdoc : attContentDocConProjList) {
      contDocIDs.add(attdoc.ContentDocumentId);
    }

    system.debug('contDocIDs' + contDocIDs);
    for (ContentVersion contVer : [
      SELECT
        id,
        VersionData,
        FileType,
        ContentSize,
        ContentDocumentId,
        ContentDocument.title
      FROM ContentVersion
      WHERE IsLatest = true AND ContentDocumentId IN :contDocIDs
    ]) {
      contentVersionList.add(contVer);
      contentVersionIds.add(contVer.Id);
      contDocContVersMap.put(contVer.ContentDocumentId, contVer.Id);
    }
    system.debug('contDocContVersMap' + contDocContVersMap);
    List<ContentDistribution> conDistrToInsertList = new List<ContentDistribution>();
    List<ContentDistribution> conDistrExistList = new List<ContentDistribution>();
    List<ContentDistribution> conDistrToInsertConProjList = new List<ContentDistribution>();
    List<ContentDistribution> conDistrExistConProjList = new List<ContentDistribution>();

    for (AttachedContentDocument attdoc : attContentDocConProjList) {
      List<ContentDistribution> cdExistLink = [
        SELECT
          Id,
          ContentDocumentId,
          Name,
          RelatedRecordId,
          DistributionPublicUrl,
          ContentDownloadUrl
        FROM ContentDistribution
        WHERE ContentDocumentId = :attdoc.ContentDocumentId
      ];
      system.debug('cdExistLink' + cdExistLink);
      if (cdExistLink.size() != 0) {
        conDistrExistConProjList.add(cdExistLink[0]);
      } else {
        ContentDistribution cd = new ContentDistribution();
        if (attdoc.Title.length() > 99)
          cd.Name = (attdoc.Title).substring(0, 99);
        else
          cd.Name = attdoc.Title;
        cd.ContentVersionId = contDocContVersMap.get(attdoc.ContentDocumentId);
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        conDistrToInsertConProjList.add(cd);
        system.debug('cd' + cd);
      }
    }
    insert conDistrToInsertConProjList;

    List<Id> conDistributionIds = new List<Id>();

    Map<Id, ContentDistribution> conDistributionMap = new Map<Id, ContentDistribution>();
    for (ContentDistribution conDist : conDistrExistConProjList) {
      //conDistributionMap.put(conDist.id, conDist);
      conDistributionIds.add(conDist.id);
    }
    for (ContentDistribution conDist : conDistrToInsertConProjList) {
      //conDistributionMap.put(conDist.id, conDist);
      conDistributionIds.add(conDist.id);
    }

    for (ContentDistribution conDist : [
      SELECT Id, Name, DistributionPublicURL
      FROM ContentDistribution
      WHERE Id IN :conDistributionIds
    ]) {
      conDistributionMap.put(conDist.Id, conDist);
    }

    string htmllinks = '<ul>';
    if (conDistrExistConProjList.size() != 0) {
      for (ContentDistribution cdlinks : conDistrExistConProjList) {
        ContentDistribution conDistributionobj = conDistributionMap.get(
          cdlinks.id
        );
        htmllinks +=
          '<li><a href="' +
          conDistributionobj.DistributionPublicURL +
          '">' +
          conDistributionobj.Name +
          '</a></li>';
        htmllinks +=
          '<ul style="list-style-type:square;font-size: 10pt;"><li">(Link not working? Use this instead: ' +
          '<a style="font-family: inherit; color: inherit;" target="_blank" href="' +
          conDistributionobj.DistributionPublicUrl +
          '" rel="noopener">' +
          conDistributionobj.DistributionPublicUrl +
          '</a>' +
          ') </li></ul>';
      }
    }
    if (conDistrToInsertConProjList.size() != 0) {
      for (ContentDistribution cdlinks : conDistrToInsertConProjList) {
        ContentDistribution conDistributionobj = conDistributionMap.get(
          cdlinks.id
        );
        htmllinks +=
          '<li><a href="' +
          conDistributionobj.DistributionPublicURL +
          '">' +
          conDistributionobj.Name +
          '</a></li>';
        htmllinks +=
          '<ul style="list-style-type:square;font-size: 10pt;"><li">(Link not working? Use this instead: ' +
          '<a style="font-family: inherit; color: inherit;" target="_blank" href="' +
          conDistributionobj.DistributionPublicUrl +
          '" rel="noopener">' +
          conDistributionobj.DistributionPublicUrl +
          '</a>' +
          ') </li></ul>';
      }
    }
    htmllinks += '</ul>';
    for (Substitution_Line_Item__c sli : slItemList) {
      list<AttachedContentDocument> attContentDocumentList = new List<AttachedContentDocument>();
      attContentDocumentList.addAll(sli.AttachedContentDocuments);
      system.debug('attContentDocumentList' + attContentDocumentList);
      for (AttachedContentDocument attdoc : attContentDocumentList) {
        List<ContentDistribution> cdExistLink = [
          SELECT
            Id,
            ContentDocumentId,
            Name,
            RelatedRecordId,
            DistributionPublicUrl,
            ContentDownloadUrl
            FROM ContentDistribution
            WHERE ContentDocumentId = :attdoc.ContentDocumentId
        ];
          system.debug('cdExistLink.size()' + cdExistLink.size());
          system.debug('cdExistLink' + cdExistLink);
          if (cdExistLink.size() != 0) {
              conDistrExistList.add(cdExistLink[0]);
          if (prodCdMap.containsKey(sli.Our_Specified_Product__c)) {
            List<ContentDistribution> rwList = prodCdMap.get(
              sli.Our_Specified_Product__c
            );
            rwList.add(cdExistLink[0]);
            prodCdMap.put(sli.Our_Specified_Product__c, rwList);
          } else {
            List<ContentDistribution> rwListNew = new List<ContentDistribution>();
            rwListNew.add(cdExistLink[0]);
            prodCdMap.put(sli.Our_Specified_Product__c, rwListNew);
          }
        } else {
          ContentDistribution cd = new ContentDistribution();

          // validate name is 100 chars or lower:
          String docName = attdoc.Title;
          if (docName.length() > 100) {
            docName = docName.substring(0, 97) + '...';
          }

          cd.Name = docName;
          cd.ContentVersionId = contDocContVersMap.get(
            attdoc.ContentDocumentId
          );
          cd.PreferencesAllowViewInBrowser = true;
          cd.PreferencesLinkLatestVersion = true;
          cd.PreferencesNotifyOnVisit = false;
          cd.PreferencesPasswordRequired = false;
          cd.PreferencesAllowOriginalDownload = true;
          conDistrToInsertList.add(cd);
          system.debug('cd' + cd);

          if (prodCdMap.containsKey(sli.Our_Specified_Product__c)) {
            List<ContentDistribution> rwList = prodCdMap.get(
              sli.Our_Specified_Product__c
            );
            rwList.add(cd);
            prodCdMap.put(sli.Our_Specified_Product__c, rwList);
          } else {
            List<ContentDistribution> rwListNew = new List<ContentDistribution>();
            rwListNew.add(cd);
            prodCdMap.put(sli.Our_Specified_Product__c, rwListNew);
          }
        }
      }
    }
    system.debug('conDistrToInsertList' + conDistrToInsertList);
    insert conDistrToInsertList;
    system.debug('conDistrToInsertList' + conDistrToInsertList);
    system.debug('conDistrExistList' + conDistrExistList);
    system.debug('prodCdMap' + prodCdMap);

    for (ContentDistribution conDist : conDistrToInsertList) {
      //conDistributionMap.put(conDist.id, conDist);
      conDistributionIds.add(conDist.id);
    }
    for (ContentDistribution conDist : conDistrExistList) {
      //conDistributionMap.put(conDist.id, conDist);
      conDistributionIds.add(conDist.id);
    }

    for (ContentDistribution conDist : [
      SELECT Id, Name, DistributionPublicURL
      FROM ContentDistribution
      WHERE Id IN :conDistributionIds
    ]) {
      conDistributionMap.put(conDist.Id, conDist);
    }

    for (string product : prodCdMap.keySet()) {
      htmllinks += '<br></br>';
      htmllinks +=
        '<ul style="list-style-type:circle;">Specified Product: ' + product;
      htmllinks += '<br></br>';
      system.debug('product' + product);
      for (ContentDistribution cdlinks : prodCdMap.get(product)) {
        ContentDistribution conDistributionobj = conDistributionMap.get(
          cdlinks.id
        );
        htmllinks +=
          '<li><a href="' +
          conDistributionobj.DistributionPublicURL +
          '">' +
          conDistributionobj.Name +
          '</a></li>';
        system.debug(
          'conDistributionobj.DistributionPublicUrl' +
          conDistributionobj.DistributionPublicUrl
        );

        htmllinks +=
          '<ul style="list-style-type:square;font-size: 10pt;"><li">(Link not working? Use this instead: ' +
          '<a style="font-family: inherit; color: inherit;" target="_blank" href="' +
          conDistributionobj.DistributionPublicUrl +
          '" rel="noopener">' +
          conDistributionobj.DistributionPublicUrl +
          '</a>' +
          ') </li></ul>';
      }
      htmllinks += '</ul>';
    }
    if (!String.isBlank(htmllinks)) {
      htmllinks += '</ul>';
    }
    system.debug('htmllinks' + htmllinks);
    //objConstruction.Product_Links__c=htmllinks;
    //update objConstruction;

    map<String, string> contatRole = new Map<String, string>();
    Map<String, Opportunity_Referral__c> emailOppRefMap = new Map<String, Opportunity_Referral__c>();
    list<AccountContactRelation> accRelList = [
      SELECT
        Id,
        AccountId,
        Account.Name,
        Contact.Email,
        Contact.Id,
        Contact.Name,
        Roles
      FROM AccountContactRelation
      WHERE Roles INCLUDES ('Lead Recipient') AND AccountId IN :acctWrapList
    ];

    system.debug('accRelList' + accRelList);
    List<Opportunity_Referral__c> oppRefs = new List<Opportunity_Referral__c>();
    List<Lead_Recipients__c> leadRecepientList = new List<Lead_Recipients__c>();
    Construction_Project__c currentConProj = [
      SELECT Id, Name, First_Referral_Date__c
      FROM Construction_Project__c
      WHERE Id = :conProjId
    ];
    if (acctWrapList.size() != 0) {
      for (Account a : [
        SELECT
          Id,
          (
            SELECT
              Id,
              AccountId,
              Account.Name,
              Contact.Email,
              Contact.Name,
              Roles
            FROM AccountContactRelations
            WHERE Roles INCLUDES ('Lead Recipient')
          )
        FROM Account
        WHERE Id IN :acctWrapList
      ]) {
        Opportunity_Referral__c oppRef = new Opportunity_Referral__c(
          ConstructionProject__c = conProjId,
          Account__c = a.Id,
          Product_Links__c = htmllinks,
          LineItemIds__c = subLineItemIds
        );
        oppRefs.add(oppRef);
        system.debug('oppRefs' + oppRefs);
        List<AccountContactRelation> accConRelList = a.AccountContactRelations;
        //accConRelList.addAll(a.AccountContactRelations);
        system.debug('accConRelList' + accConRelList);
        for (AccountContactRelation ac : accConRelList) {
          emailOppRefMap.put(ac.Contact.Email, oppRef);
          system.debug('emailOppRefMap' + emailOppRefMap);
          contatRole.put(ac.AccountId, ac.ContactId);
        }
      }
    }
    if (oppRefs.size() > 0) {
      insert oppRefs;
      for (Opportunity_Referral__c oppref : oppRefs) {
        Lead_Recipients__c lrObj = new Lead_Recipients__c();
        lrObj.Refer_Lead__c = oppref.Id;
        lrObj.Contact__c = contatRole.get(oppref.Account__c);
        leadRecepientList.add(lrObj);
      }
      insert leadRecepientList;
      Map<Id, Id> oppRefLeadRecMap = new Map<Id, Id>();
      for (Lead_Recipients__c lr : leadRecepientList) {
        oppRefLeadRecMap.put(lr.Refer_Lead__c, lr.Id);
      }
      LIST<EmailTemplate> lstAcceptRejectTemplate = [
        SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body
        FROM EmailTemplate
        WHERE DeveloperName = 'Lead_Accept_Reject_Template'
      ];
      LIST<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
      EmailTemplate AcceptRejectTemplate = lstAcceptRejectTemplate[0];
      //String siteURL= 'https://subreqsprojects-dev-ed--c.ap5.visual.force.com/apex/AcceptOrRejectLeadPage';
      //String siteURL='https://full-californiaproducts.cs30.force.com/closingloop/AcceptOrRejectLeadPage';

      List<Subreq_Setting__mdt> meta = [
        SELECT
          Construction_Project_Status_Transition__c,
          Customer_Image_Logo__c,
          Referral_Accept_Page_URL__c
        FROM Subreq_Setting__mdt
      ];

      String siteURL = meta.get(0).Referral_Accept_Page_URL__c;

      for (AccountContactRelation acr : accRelList) {
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        List<String> toEmails = new List<String>{ acr.Contact.Email };
        //singleEmail.setToAddresses(toEmails);
        singleEmail.setTargetObjectId(acr.Contact.Id);
        singleEmail.setWhatId(objConstruction.Id);
        singleEmail.setSubject(AcceptRejectTemplate.Subject);
        String emailBody = AcceptRejectTemplate.HtmlValue;
        emailBody = emailBody.replace('###DISPLAY_NAME###', acr.Contact.Name);
        String parameters = '?';
        system.debug('acr' + acr);
        parameters +=
          '&oppReferralId=' + emailOppRefMap.get(acr.Contact.Email).Id;
        parameters +=
          '&leadRecId=' +
          oppRefLeadRecMap.get(emailOppRefMap.get(acr.Contact.Email).Id);
        parameters += '&subLineItems=' + subLineItemIds;
        parameters += '&userId=' + loggedinUser.Id;
        String tableData = '';
        tableData += '<ul>';
        for (string prod : prodFamilyList) {
          tableData += '<li>' + prod + '</li>';
        }
        string buttondata = '';
        string senderData = '';
        senderData +=
          '<p>' +
          loggedinUser.FirstName +
          ' ' +
          loggedinUser.LastName +
          '</p>';
        senderData +=
          '<p>' +
          loggedinUser.CompanyName +
          ' | ' +
          loggedinUser.Street +
          '  ' +
          loggedinUser.City +
          ' | ' +
          loggedinUser.State +
          ' | Zip: ' +
          loggedinUser.PostalCode +
          '</p>';
        senderData +=
          '<p>Phone:' +
          loggedinUser.Phone +
          '| Email: ' +
          loggedinUser.Email +
          '</p>';

        buttondata +=
          '<br/><table style="border:0; text-align:center;" cellpadding="0" cellspacing="0"><td style="padding-right:1px;color: #fff"><a class="button" style="background-color:green" href="' +
          siteURL +
          parameters +
          '&statusResponse=accept">ACCEPT</a></td>';
        buttondata +=
          ' <td style="width:200px;color: #fff"><a class="button" style="background-color:red" href="' +
          siteURL +
          parameters +
          '&statusResponse=reject">REJECT</a></td></table><br/><br/>';

        //buttondata += '<br/><a class="button" href="' + siteURL + parameters + '&statusResponse=accept">ACCEPT</a>';
        //buttondata += '<a class="button" href="' + siteURL + parameters + '&statusResponse=reject">REJECT</a><br/><br/>';
        //tableData += '<td class="action"><a href="' + siteURL + parameters + '&statusResponse=accept">ACCEPT</a></td>';
        //tableData += '<td class="action"><a href="' + siteURL + parameters + '&statusResponse=reject">REJECT</a></td>';
        tableData += '</ul>';
        emailBody = emailBody.replace('###RECORD_DATA###', tableData);
        emailBody = emailBody.replace('###BUTTONS###', buttondata);
        emailBody = emailBody.replace('###SENDER_NAME###', senderData);
        system.debug('emailBody' + emailBody);
        singleEmail.setHtmlBody(emailBody);
        List<String> ccAddresses = ConstructionProjectReferralController.getEmailCCAddresses(subLineItemIds);
        if (ccAddresses.size() > 0) {
          //singleEmail.setCCAddresses(ccAddresses);
        }
        singleEmail.setSaveAsActivity(true);
        lstEmailsToSend.add(singleEmail);
        system.debug('parameters' + parameters);
        print('mail', singleEmail);
        print('mail list', lstEmailsToSend);
      }
      List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(lstEmailsToSend);
      Boolean sendSuccessful = true;
      for(Messaging.SendEmailResult res : sendResults) {
        if(res.isSuccess()) {
            continue; 
        } else {
            System.debug('Email send error: ' + res.getErrors());
            sendSuccessful = false;
        }
      }
      if (sendSuccessful) {
          result = 'Success';
      }
      for (Substitution_Line_Item__c sli : subLineItems) {
        sli.Status__c = 'Sent to Contractors';
      }
      update subLineItems;
    } else {
      system.debug('No Assignments');
      result = 'No Assignments';
    }
    return result;
  }

  private static List<String> getEmailCCAddresses(String subLineItemIdsStr) {
    List<Substitution_Line_Item__c> subLineItems = ConstructionProjectReferralController.getSubLineItemsWithReps(subLineItemIdsStr);
    List<String> ccAddresses = new List<String>();
    String newEmail = '';
    for (Substitution_Line_Item__c subLine : subLineItems) {
      if (subLine.Sales_Rep__c != null) {
        User salesRep = ConstructionProjectReferralController.getUserRecord(subLine.Sales_Rep__c);
        if (  salesRep != null && 
              salesRep.Email != null &&
              salesRep.Email != newEmail
        ) {
          newEmail = salesRep.Email;
          ccAddresses.add(newEmail);
        }
      }
    }
    return ccAddresses;
  }

  private static List<Substitution_Line_Item__c> getSubLineItemsWithReps(String subLineItemIdsStr) {
    List<String> subLineItemIds = subLineItemIdsStr.split('_');
    List<Substitution_Line_Item__c> subLineItems = [
      SELECT Id, Sales_Rep__c
      FROM Substitution_Line_Item__c
      WHERE Id IN :subLineItemIds
    ];
    return subLineItems;
  }

  private static User getUserRecord(String userId) {
    User userRec = [
      SELECT Id, Email
      FROM User
      WHERE Id = :userId
    ];
    return userRec;
  }

  @AuraEnabled
  public static Construction_Project__c confirmGeolocation(String conProjId) {
    //public static Opportunity confirmGeolocation(String conProjId) {
    Set<Id> conProjIds = new Set<Id>{ conProjId };

    GeoLocationUtilities.getLatLongConstructionProject(conProjIds);

    Construction_Project__c o = ConstructionProjectReferralController.getConProjRecord(
      conProjId
    );
    //Opportunity o = OpportunityReferralController.getOppRecord(conProjId);

    return o;
  }

  public class AccountTypeWrapper {
    @AuraEnabled
    public string acctType { get; set; }
  }
  //Public wrapper class that is used to flag which accounts already have a Opportunity_Referral__c record
  //with the given lead, and alter the display on the Lightning component accordingly.
  public class AccountWrapper {
    @AuraEnabled
    public Account acct { get; set; }

    @AuraEnabled
    public String street { get; set; }

    @AuraEnabled
    public String city { get; set; }

    @AuraEnabled
    public String stateName { get; set; }

    @AuraEnabled
    public String country { get; set; }

    @AuraEnabled
    public String postalCode { get; set; }

    @AuraEnabled
    public Boolean assigned { get; set; }

    @AuraEnabled
    public Decimal distance { get; set; }

    @AuraEnabled
    public Boolean toAssign { get; set; }

    public AccountWrapper(Account a, Boolean isAssigned, Decimal dist) {
      this.acct = a;
      SYSTEM.debug(
        'a.Contractor_Locator_Address_Choice__c' +
        a.Contractor_Locator_Address_Choice__c
      );
      switch on a.Contractor_Locator_Address_Choice__c {
        when 'Mailing Address' {
          this.street = a.BillingStreet;
          this.city = a.BillingCity;
          this.stateName = a.BillingState;
          this.country = a.BillingCountry;
          this.postalCode = a.BillingPostalCode;
        }
        when 'Shipping Address' {
          this.street = a.ShippingStreet;
          this.city = a.ShippingCity;
          this.stateName = a.ShippingState;
          this.country = a.ShippingCountry;
          this.postalCode = a.ShippingPostalCode;
        }
        when 'Billing Address' {
          this.street = a.BillingStreet;
          this.city = a.BillingCity;
          this.stateName = a.BillingState;
          this.country = a.BillingCountry;
          this.postalCode = a.BillingPostalCode;
          system.debug('a' + a);
        }
        when null {
          this.street = a.ShippingStreet;
          this.city = a.ShippingCity;
          this.stateName = a.ShippingState;
          this.country = a.ShippingCountry;
          this.postalCode = a.ShippingPostalCode;
        }
      }
      this.assigned = isAssigned;
      this.distance = dist;
      this.toAssign = false;
    }
  }

  private static void print(String str, Object obj) {
    if(str == 'mail') {
        Messaging.SingleEmailMessage o = (Messaging.SingleEmailMessage)obj;
        System.debug('-------------------------------------------');
        print('mail.getBccAddresses()', o.getBccAddresses());
        print('mail.getCcAddresses()', o.getCcAddresses());
        print('mail.getCharset()', o.getCharset());
        // print('mail.getDocumentAttachments()', o.getDocumentAttachments());
        print('mail.getEntityAttachments()', o.getEntityAttachments());
        print('mail.getFileAttachments()', o.getFileAttachments());
        print('mail.getHtmlBody()', o.getHtmlBody());
        print('mail.getInReplyTo()', o.getInReplyTo());
        print('mail.getOptOutPolicy()', o.getOptOutPolicy());
        print('mail.getPlainTextBody()', o.getPlainTextBody());
        print('mail.getOrgWideEmailAddressId()', o.getOrgWideEmailAddressId());
        print('mail.getReferences()', o.getReferences());
        print('mail.getSubject()', o.getSubject());
        print('mail.getTargetObjectId()', o.getTargetObjectId());
        print('mail.getTemplateId()', o.getTemplateId());
        print('mail.getToAddresses()', o.getToAddresses());
        print('mail.getWhatId()', o.getWhatId());
        System.debug('-------------------------------------------');
    } else {
        System.debug(str + ': ' + obj);
    }
}
}