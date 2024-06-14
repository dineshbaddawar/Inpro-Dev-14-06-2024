/*************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ===========================================================
* Test Class:   ResendLunchAndLearn_Test
* ===========================================================
* Purpose:      This class acts at the page extension for the 
*				ResendLunchAndLearnContact page.  It will call
* 				the necessary method in the ResendLunchAndLearn 
*				class to check certificates, then resend emails
*				to a given Contact record.
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
************************************************************/
public class ResendLunchAndLearnContact {
	
	public String recordId {get;set;}
	public String outputMessage {get;set;}
	public String successFail {get;set;}

	public ResendLunchAndLearnContact(ApexPages.StandardController controller) {
		outputMessage = 'Please wait a moment while the lunch and learn validation completes.';
		successFail = 'more';
		recordId = controller.getId();
	}

	public void doResendLandL() {
		String result = ResendLunchAndLearn.ResendLunchAndLearnNoFlag(new List<String>{recordId}, new List<Event_Attendee__c>());

		if(result=='Success') {
			outputMessage = 'Certificates confirmed and emails resent successfully.';
			successFail = 'approval';
		} else {
			outputMessage = 'Oops, something went wrong. ' + 
							'Please contact your Salesforce Administrator and provide the following errors: ' + result;
			successFail = 'close';
		}

	}

	public PageReference getRecordPage() {
		PageReference returnPage = new PageReference('/' + recordId);
		returnPage.setRedirect(true);
		return returnPage;
	}

	@AuraEnabled
	public static LunchAndLearnEvent__c getLunchAndLearnEvent(String eventId) {
		LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();

		if(!String.isBlank(eventId)) {
			evt = [Select Id, Name,Course_Name__r.Name, Start_Formatted__c from LunchAndLearnEvent__c where Id =: eventId];
		}

		return evt;
	}

	@AuraEnabled
    //Public method that returns a string for the UI Theme to determine appropriate navigation within
    //the Lightning component (either classic or Lightning).
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }

	@AuraEnabled
	public static List<AttendeeWrapper> getAttendees(String eventId) {
		List<AttendeeWrapper> attendeeList = new List<AttendeeWrapper>();
        
        if(!String.isBlank(eventId)) {
            for(Event_Attendee__c member : [Select Id, FirstName__c, LastName__c, Email__c,
                                            LunchAndLearn_AIA_Number__c,
                                            contact__r.GBCI_Number__c,contact__r.IDCEC_Number__c
                                            from Event_Attendee__c
                                            where LunchAndLearnEvent__c =: eventId]) {
                                                attendeeList.add(new AttendeeWrapper(member));
                                            }
        }
        return attendeeList;
    }

	@AuraEnabled
	public static String doEventLevelResend(String attendeeListJSON) {
		String result = '';

		List<AttendeeWrapper> attendees = (List<AttendeeWrapper>)JSON.deserialize(attendeeListJSON, List<AttendeeWrapper>.class);

		Set<String> campaignMemberIds = new Set<String>();

		for(AttendeeWrapper wrap : attendees) {
			if(wrap.resend==true) {
				campaignMemberIds.add(wrap.camMemId);
			}
		}

		if(campaignMemberIds.size()>0) {
			/*List<Event_Attendee__c> members = [SELECT Id,Course__c,Course__r.Course_Id__c,Course__r.Id,Course__r.IDCEC_Course_ID__c,Course__r.USGBC_Course_ID__c,
												Course__r.LandLCourseCredit__c,Course__r.Name,LunchAndLearnEvent__r.Course_Name__r.Name, 
												LunchAndLearnEvent__r.Location1__c, Lead__c ,Lead__r.Company, contact__r.Accountid,
												contact__r.Account.name, contact__c,contact__r.AIA_Member_Number__c,contact__r.IDCEC_Number__c,
												contact__r.GBCI_Number__c,contact__r.Name,Lead__r.name,Lead__r.IDCEC_Number__c,Email__c,LastModifiedDate, Status__c, Name, 
												Email_Opt_In__c,Mail_Send__c, LunchAndLearn_AIA_Number__c,IDCEC_Number__c,
												GBCI_Number__c, LunchAndLearnEvent__c,LunchAndLearnEvent__r.OwnerId,
												LunchAndLearnEvent__r.Owner.Name,LunchAndLearnEvent__r.Location__c,
												LunchAndLearnEvent__r.Owner.Title,LunchAndLearnEvent__r.Owner.Phone,
												LunchAndLearnEvent__r.Owner.Email,createdDate,Course__r.Provider_Id__c,
												LunchAndLearnEvent__r.EndDateTime__c ,LunchAndLearnEvent__r.StartDateTime__c,LunchAndLearnEvent__r.Id 
												FROM Event_Attendee__c where Id in: campaignMemberIds 
                                                AND (Contact__r.IDCEC_Number__c = null and Lead__r.IDCEC_Number__c = null) 
                                                AND Status__c = 'Attended'];

			result = ResendLunchAndLearn.ResendLunchAndLearnNoFlag(new List<String>(), members);*/
            result = LandLResendCertificates.ResendCertificates(campaignMemberIds);
			system.debug('result'+result);
			if(result=='Success') {
				result = 'Certificates confirmed and emails resent successfully.';
			} else {
				result = 'Oops, something went wrong. ' + 
								'Please contact your Salesforce Administrator and provide the following errors: ' + result;
			}

		}

		return result;
	}

	public class AttendeeWrapper {
		@AuraEnabled
		public String camMemId {get;set;}
		@AuraEnabled
		public String firstName {get;set;}
		@AuraEnabled
		public String lastName {get;set;}
		@AuraEnabled
		public String fullName {get;set;}
		@AuraEnabled
		public String email {get;set;}
		@AuraEnabled
		public Boolean resend {get;set;}
        @AuraEnabled
		public String AIA {get;set;}
        @AuraEnabled
		public String GBCI {get;set;}
        @AuraEnabled
		public String IDCEC {get;set;}

		public AttendeeWrapper(Event_Attendee__c mem) {
			this.camMemId = mem.Id;
			this.firstName = mem.FirstName__c;
			this.lastName = mem.LastName__c;
			this.fullName = this.firstName + ' ' + this.lastName;
			this.email = mem.Email__c;
			this.resend = false;
            
            this.AIA=mem.LunchAndLearn_AIA_Number__c;
            this.GBCI=mem.contact__r.GBCI_Number__c;
            this.IDCEC=mem.contact__r.IDCEC_Number__c;
		}
	}
}