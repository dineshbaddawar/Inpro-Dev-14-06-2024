/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/17/2020
* ===========================================================
* Test Class:   SubstitutionLineItemTriggerHandlerTest
* ===========================================================
* Purpose:      This class maps subline status values to construction
                project status values. It also ranks the cp status
                values for easier prioritization.
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/17/2020     THG - ATS       Created
************************************************************/
public with sharing class ConstructionProjectStatusMaps {

  public Map<String,String> spStatusToCPTeamStatus = new Map<String,String> {
    'Substitution Submitted, Pending' =>  'Qualifying',
    'Substitution Accepted' =>            'Ready for Rep',
    'Qualified' =>                        'Ready for Rep',
    'Sent to Contractors' =>              'Rep Has Referred',
    'Referral Accepted' =>                'Contractor Accepted',
    'Closed Won' =>                       'Won',
    'Closed Lost' =>                      'Closed Lost',
    'Pre-Qualified' =>                    'Unqualified/TBD'
  };

  public Map<String,String> cpTeamStatusToCPInternalStatus = new Map<String,String> {
    'Qualifying' =>                       'Working',
    'Ready for Rep' =>                    'Working',
    'Rep Has Referred' =>                 'Working',
    'Contractor Accepted' =>              'Working',
    'Won' =>                              'Closed',
    'Closed Lost' =>                      'Closed',
    'Unqualified/TBD' =>                  'New',
    'N/A - Nothing Relevant' =>           'Disqualified'
  };

  public Map<String,String> spStatusToSPSubstitutionStatus = new Map<String,String> {
    'Substitution Submitted, Pending' =>  'Submitted',
    'Substitution Accepted' =>            'Accepted',
    'Qualified' =>                        'N/A',
    'Sent to Contractors' =>              'Accepted',
    'Referral Accepted' =>                'Accepted',
    'Closed Won' =>                       'Accepted',
    'Closed Lost' =>                      'Accepted',
    'Pre-Qualified' =>                    'N/A'
  };

  public Map<String,String> cpSalesTeamStatusRanking = new Map<String,String> {
    'Closed Lost' =>	              '-2',
    'Won' =>	                      '-1',
    'N/A - Nothing Relevant' =>      '0',
    'Qualifying' =>	                 '1',
    'Rep Has Referred' =>	           '2',
    'Contractor Accepted' =>	       '3',
    'Ready for Rep' =>	             '4'
  };

  public Map<String,String> cpInternalStatusRanking = new Map<String,String> {
    'New' =>                        '-2',
    'Disqualified' =>               '-1',
    'Closed' =>                      '0',
    'Working' =>                     '1'
  };

}