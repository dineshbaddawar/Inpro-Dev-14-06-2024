/*************************************************************
* Created by:   The Hunley Group
* Created on:   5/21/2019
* ===========================================================
* Test Class:   SubstitutionLineItemTriggerHandlerTest
* ===========================================================
* Purpose:      Sets status fields on sub-line-item and construction
*               project records. See ConstructionProjectStatusMaps.cls
*               for field value mapping.
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 5/21/2019     THG - JP        Created
* 4/17/2020     THG - ATS       Add more robust status field mapping.
*                               Removed email to rep (see EOF).
*                               Removed 'with sharing' to allow project referral email
*                               links to work.
* 
************************************************************/
public class SubstitutionLineItemTriggerHandler {
  private Map<Id, Substitution_Line_Item__c> newMap;
  private Map<Id, Substitution_Line_Item__c> oldMap;
  private List<Substitution_Line_Item__c> trigNew;
  private List<Substitution_Line_Item__c> trigOld;
  private ConstructionProjectStatusMaps cpStatusMaps;

  // Constructor usedd for Before/After Update handler
  public SubstitutionLineItemTriggerHandler(
    Map<Id, Substitution_Line_Item__c> triggerOldMap,
    Map<Id, Substitution_Line_Item__c> triggerNewMap,
    List<Substitution_Line_Item__c> triggerOld,
    List<Substitution_Line_Item__c> triggerNew
  ) {
    this.oldMap = triggerOldMap;
    this.newMap = triggerNewMap;
    this.trigOld = triggerOld;
    this.trigNew = triggerNew;
    this.cpStatusMaps = new ConstructionProjectStatusMaps();
  }

  //Public method called from the trigger in Before Insert context
  public void beforeInsert() {
    setSalesTeamOnSubLineItem();
    //setSubmittedStatusOnSubLineItem();
  }

  public void beforeUpdate() {
    setSalesTeamOnSubLineItem();
    updateConstructionProjectIfNecessary();
    //setSubmittedStatusOnSubLineItem();
  }

  public void afterUpdate(
    List<Substitution_Line_Item__c> newSLIList,
    Map<Id, Substitution_Line_Item__c> oldMap
  ) {
    updateProjectStatus(newSLIList, oldMap);
  }

  // Update internal status on construction project
  public void updateProjectStatus(
    List<Substitution_Line_Item__c> newSLIList,
    Map<Id, Substitution_Line_Item__c> oldMap
  ) {
      List<Construction_Project__c> projectsToUpdate = new List<Construction_Project__c>();
      List<Construction_Project__c> projects = getRelatedConstructionProjects(newSLIList);
      List<String> teamFieldNames = getCPSalesTeamStatusFieldNames();

      for(Construction_Project__c proj : projects) {
        // Determine highest ranked cp internal status value based on the current cp sales team status values
        Integer highestRank = -10;
        String newInternalStatus;
        // Loop all team status fields in the construction project object
        for(String teamField : teamFieldNames) {
          String teamStatus = (String)proj.get(teamField);
          if (!internalStatusIsValid(teamStatus)) {
            continue;
          }
          String internalStatusCandidate = cpStatusMaps.cpTeamStatusToCPInternalStatus.get(teamStatus);
          String candidateRankStr = cpStatusMaps.cpInternalStatusRanking.get(internalStatusCandidate);
          Integer candidateRank = Integer.valueOf(candidateRankStr);
          if (candidateRank > highestRank) {
            highestRank = candidateRank;
            newInternalStatus = internalStatusCandidate;
          }
        }
        if(    proj.Internal_Status__c != newInternalStatus
            && newInternalStatus != null
        ){
          proj.Internal_Status__c = newInternalStatus;
          projectsToUpdate.add(proj);
        }
      }
      updateProjects(projectsToUpdate);
    }

  // Update the sales team status field on construction project
  private void updateConstructionProjectIfNecessary() {
    Set<Id> cpIDs = new Set<Id>();
    Set<Id> lineIds = new Set<Id>();
    Map<Id,Construction_Project__c> projectsToUpdateMap = new Map<Id,Construction_Project__c>();
    Map<String, Sales_Team_Field_Automation_Mapping__c> autoMap = new Map<String, Sales_Team_Field_Automation_Mapping__c>();

    // create our datastructure map for the automations:
    List<Sales_Team_Field_Automation_Mapping__c> stMappings = getSTMappings();
    for (Sales_Team_Field_Automation_Mapping__c amap : stMappings) {
      autoMap.put(amap.Sales_Team__c, amap);
    }

    for (Id lid : this.newMap.keySet()) {
      Substitution_Line_Item__c newLine = this.newMap.get(lid);
      cpIDs.add(newLine.ConstructionProject__c);
      lineIds.add(lid);
    }

    List<Construction_Project__c> projects = LoadConstructionProjectsIncludingDynamicMappingFields(
      cpIDs
    );

    // load ALL lines associated with the construction project EXCEPT ones in this trigger:
    List<Substitution_Line_Item__c> allOtherLines = [
      SELECT Id, Sales_Team__c, ConstructionProject__c, Status__c
      FROM Substitution_Line_Item__c
      WHERE id NOT IN :lineIds AND ConstructionProject__c IN :cpIDs
    ];

    // build maps of construction project id to lines, and construction project id to const. project
    Map<Id, List<Substitution_Line_Item__c>> projectToLineMap = new Map<Id, List<Substitution_Line_Item__c>>();
    Map<Id, Construction_Project__c> projectMap = new Map<Id, Construction_Project__c>();
    for (Construction_Project__c proj : projects) {
      projectMap.put(proj.Id, proj);
      List<Substitution_Line_Item__c> lines = new List<Substitution_Line_Item__c>();
      projectToLineMap.put(proj.Id, lines);

      for (Substitution_Line_Item__c line : allOtherLines) {
        if (line.ConstructionProject__c == proj.Id) {
          lines.add(line);
        }
      }
      for (Substitution_Line_Item__c line : this.trigNew) {
        if (line.ConstructionProject__c == proj.Id) {
          lines.add(line);
        }
      }
    }

    // Update team status fields on construction project
    for(Id projId : projectToLineMap.keyset()) {
      Construction_Project__c proj = projectMap.get(projId);
      List<Substitution_Line_Item__c> allLinesInProj = projectToLineMap.get(projId);
      Map<String,String> highestRankedStatusByTeam = new Map<String,String>();

      // Create map of team name => highest ranked cp team field status
      // for the given list of spec lines
      for(Substitution_Line_Item__c line : allLinesInProj) {
        if (!teamStatusIsValid(line.Sales_Team__c, line.Status__c)) {
          continue;
        }
        String teamName = line.Sales_Team__c;
        String lineStatus = line.Status__c;
        String teamStatusCandidate = cpStatusMaps.spStatusToCPTeamStatus.get(lineStatus);
        if (!highestRankedStatusByTeam.containsKey(teamName)) {
          highestRankedStatusByTeam.put(teamName, teamStatusCandidate);
          continue;
        }
        String currentStatus = highestRankedStatusByTeam.get(teamName);
        String currentRankStr = cpStatusMaps.cpSalesTeamStatusRanking.get(currentStatus);
        String candidateRankStr = cpStatusMaps.cpSalesTeamStatusRanking.get(teamStatusCandidate);
        Integer currentRank = Integer.valueOf(currentRankStr);
        Integer candidateRank = Integer.valueOf(candidateRankStr);
        if (candidateRank > currentRank) {
          highestRankedStatusByTeam.put(teamName, teamStatusCandidate);
        }
      }
      // Set new values for sales team status fields
      for (String team : highestRankedStatusByTeam.keySet()) {
        if (!autoMap.containsKey(team)) {
          continue;
        }
        Sales_Team_Field_Automation_Mapping__c fieldMap = autoMap.get(team);
        String teamStatusField = fieldMap.Construction_Project_Team_Field__c;
        String teamStatusValueNew = highestRankedStatusByTeam.get(team);
        String teamStatusValueOld = (String)proj.get(teamStatusField);
        if (teamStatusValueNew != teamStatusValueOld) {
          if (projectsToUpdateMap.containsKey(proj.Id)) {
            Construction_Project__c mappedProj = projectsToUpdateMap.get(proj.Id);
            mappedProj.put(teamStatusField, teamStatusValueNew);
            projectsToUpdateMap.put(mappedProj.Id, mappedProj);
          } else {
            proj.put(teamStatusField, teamStatusValueNew);
            projectsToUpdateMap.put(projId, proj);
          }
        }
      }
    }
    if (projectsToUpdateMap.keyset().size() > 0) {
      List<Construction_Project__c> projectsToUpdate = projectsToUpdateMap.values();
      update projectsToUpdate;
    }
}

private Boolean internalStatusIsValid(String teamStatus) {
  Boolean allValid = true;
  allValid = (teamStatus != '' && teamStatus != null);
  allValid = cpStatusMaps.cpTeamStatusToCPInternalStatus.containsKey(teamStatus);
  if (allValid) {
    String internalStatus = cpStatusMaps.cpTeamStatusToCPInternalStatus.get(teamStatus);
    allValid = cpStatusMaps.cpInternalStatusRanking.containsKey(internalStatus);
  }
  return allValid;
}

private Boolean teamStatusIsValid(String teamName, String lineStatus) {
  Boolean allValid = true;
  allValid = (teamName != null && lineStatus != null);
  allValid = cpStatusMaps.spStatusToCPTeamStatus.containsKey(lineStatus);
  if (allValid) {
    String cpTeamStatus = cpStatusMaps.spStatusToCPTeamStatus.get(lineStatus);
    allValid = cpStatusMaps.cpSalesTeamStatusRanking.containsKey(cpTeamStatus);
  }
  return allValid;
}

  // Read Product Mapping Relationships and set any relevant sales team (i.e. 'region') on the speclines
  private void setSalesTeamOnSubLineItem() {

    List<Product_Brand__c> productBrands = [
      SELECT Id, Business_UnitG__c, Product_Sub_FamilyG__c, Product_FamilyG__c
      FROM Product_Brand__c
    ];

    for (Substitution_Line_Item__c newLine : this.trigNew) {
      // Get a list of business-unit names (i.e. 'regions') that are valid
      // for the specline's product-families
      List<String> validBusinessUnits = new List<String>();
      for (Product_Brand__c pb : productBrands) {
        if (
          newLine.Product_FamilyG__c == pb.Product_FamilyG__c &&
          newLine.Product_Sub_FamilyG__c == pb.Product_Sub_FamilyG__c
        ) {
          validBusinessUnits.add(pb.Business_UnitG__c);
        }
      }
      // If the specline's sales team (i.e. 'region') is not set to a valid business-unit name
      // then change it to a valid one
      if (
        !validBusinessUnits.contains(newLine.Sales_Team__c) &&
        validBusinessUnits.size() > 0
      ) {
        newLine.Sales_Team__c = validBusinessUnits[0];
      }
    }
  }

  private void setSubmittedStatusOnSubLineItem(){
    for(Substitution_Line_Item__c newLine : this.trigNew){
      String lineStatus = newLine.Status__c;
      if (cpStatusMaps.spStatusToSPSubstitutionStatus.containsKey(lineStatus)) {
        String lineSubstitutionStatus = cpStatusMaps.spStatusToSPSubstitutionStatus.get(lineStatus);
        newLine.Substitution_Status__c = lineSubstitutionStatus;
      }
    }
  }

  public static List<Construction_Project__c> LoadConstructionProjectsIncludingDynamicMappingFields(
    Set<Id> ids
  ) {
    Set<String> dynFields = new Set<String>();

    List<Sales_Team_Field_Automation_Mapping__c> stMappings = getSTMappings();

    // add our dynamic fields
    for (Sales_Team_Field_Automation_Mapping__c stam : stMappings) {
      dynFields.add(stam.Construction_Project_Rep_Field__c);
      dynFields.add(stam.Construction_Project_Team_Field__c);
    }

    // build soql query based on automation mapping fields.
    String soql = 'SELECT Id, Name, Internal_Status__c';

    if (dynFields.size() > 0) {
      soql += ',' + +String.join(new List<String>(dynFields), ', ');
    }

    soql += ' FROM Construction_Project__c where id ';
    soql += ' in (\'' + String.join(new List<Id>(ids), '\',\'') + '\')';
    System.debug('SubLITriggerHandler.LoadConProjs soql: ' + soql);

    // run query and return objects
    List<Construction_Project__c> projs = Database.query(soql);
    return projs;
  }
    
  private static List<Sales_Team_Field_Automation_Mapping__c> getSTMappings() {
    List<Sales_Team_Field_Automation_Mapping__c> stMappings = [
      SELECT
        Id,
        Sales_Team__c,
        Construction_Project_Rep_Field__c,
        Construction_Project_Team_Field__c
      FROM Sales_Team_Field_Automation_Mapping__c
    ];
    return stMappings;
  }

  private List<Construction_Project__c> getRelatedConstructionProjects(List<Substitution_Line_Item__c> lines) {
    Set<Id> cpIDs = extractConstructionProjectIDs(lines);
    List<Construction_Project__c> projects = LoadConstructionProjectsIncludingDynamicMappingFields(
      cpIDs
    );
    return projects;
  }

  private Set<Id> extractConstructionProjectIDs(List<Substitution_Line_Item__c> lines) {
    Set<Id> cpIDs = new Set<Id>();
    for(Substitution_Line_Item__c line : lines){
      cpIDs.add(line.ConstructionProject__c);
    }
    return cpIDs;
  }

  private List<String> getCPSalesTeamStatusFieldNames() {
    List<String> fieldNames = new List<String>();
    List<Sales_Team_Field_Automation_Mapping__c> stMappings = getSTMappings();
    for(Sales_Team_Field_Automation_Mapping__c fieldMap : stMappings) {
      String field = fieldMap.Construction_Project_Team_Field__c;
      fieldNames.add(field);
    }
    return fieldNames;
  }

  private void updateProjects(List<Construction_Project__c> projects) {
    if (projects.size() > 0) {
      update projects;
    }
  }

}


// SEND EMAIL TO REP
        // 'Ready for Rep' emails are sent via workflow rules in this org
        // Previously, they were sent from this class 
        // i.e. If team statusValue == 'Ready for Rep', then send rep email.

// create a map object to track emails so we don't send multiple to anyone:
// Map<Id, List<String>> projectsEmailed = new Map<Id, List<String>>();
// 
//   if (proj.get(repField) != null) {
//   String repId = (String) proj.get(repField);
//   // check that we haven't already emailed this team:
//   if (
//     !projectsEmailed.get(proj.Id).contains(newLine.Sales_Team__c)
//   ) {
//     projectsEmailed.get(proj.Id).add(newLine.Sales_Team__c); // add current team to email tracker
//
//     NOTE: wausau does not have a template of the name below (code is from ICP)
//     String templateDevName = 'Construction_Project_Ready_for_Sales';
//     if (!Test.isRunningTest()) {
//       // send emails unless unittest
//       sendEmail(repId, proj.Id, templateDevName);
//     }
//   }
// }

  // private static Contact dummyContact = null;

  // public static void sendEmail(
  //   Id recipient,
  //   Id targetObject,
  //   String templateDeveloperName
  // ) {
  //   // verify we have at least 1 dummy contact available:
  //   if (dummyContact == null) {
  //     dummyContact = [SELECT Id FROM Contact LIMIT 1];
  //   }

  //   //New instance of a single email message
  //   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

  //   // Who you are sending the email to BCC'd
  //   List<String> emails = new List<String>();
  //   emails.add('tschacht@thehunleygroup.com');
  //   mail.setBccAddresses(emails);

  //   User u = [SELECT Id, Email FROM User WHERE Id = :recipient];

  //   List<String> emailsTo = new List<String>();
  //   emails.add(u.Email);
  //   mail.setToAddresses(emailsTo);

  //   // The email template ID used for the email
  //   EmailTemplate temp = [
  //     SELECT Id, DeveloperName
  //     FROM EmailTemplate
  //     WHERE DeveloperName = :templateDeveloperName
  //   ];
  //   mail.setTemplateId(temp.Id);

  //   // bind our object
  //   mail.setTargetObjectId(dummyContact.Id);
  //   mail.setTreatTargetObjectAsRecipient(false);

  //   mail.setWhatId(targetObject);

  //   mail.setBccSender(false);

  //   mail.setUseSignature(false);

  //   mail.setReplyTo('noreply@icpgroup.com');

  //   mail.setSenderDisplayName('ICP Salesforce');

  //   mail.setSaveAsActivity(false);

  //   Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  // }