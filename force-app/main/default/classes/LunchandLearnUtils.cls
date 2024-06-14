/*************************************************************
 * Created by:   The Hunley Group
 * Created on:    4/28/2020
 * ===========================================================
 * Test Class:
 * ===========================================================
 * Purpose:   Utility class to allow easy access to our Lunch
 *			 and Learn metadata settings.
 *
 * ===========================================================
 * Change History
 * Date          Author          Purpose
 * ----------    -------------   -----------------------------
 * 4/28/2020     THG - JP        Created
 *
 ************************************************************/
public with sharing class LunchandLearnUtils {
  private static Lunch_and_Learn_Settings__mdt myRow = null;

  // Utility method to allow easy access to our Lunch and Learn metadata settings:
  public static string GetMetadataValue(String name) {
    // cache the result:
    if (myRow == null) {
      List<Lunch_and_Learn_Settings__mdt> rows = [
        SELECT
          Id,
          AIA_Logo__c,
          Attendance_Link__c,
          Certificate_Background__c,
          Checkmark__c,
          Client_Id__c,
          Client_Secret__c,
          Customer_Image_Logo__c,
          Education_Logo__c,
          GBCICMP_Logo__c,
          IDCEC_Logo__c,
          Provider_Name__c,
          Provider_Number__c,
          Provider_Number_AIA__c,
          Provider_Number_GBCI__c,
          Provider_Number_IDCEC__c,
          Redirect_URI__c,
          L_L_Registration_Page_Tooltip_Text__c,
          Admin_Notification__c,
          AIA_Products_Representative__c,
          AIA_Products_Representative_Address_L1__c,
          AIA_Products_Representative_Address_L2__c,
          AIA_Products_Representative_Email__c,
          AIA_Products_Representative_Phone__c,
          AIA_Products_Representative_Title__c
          FROM Lunch_and_Learn_Settings__mdt
      ];
      myRow = rows.get(0);
    }
    return (String) myRow.get(name);
  }
}