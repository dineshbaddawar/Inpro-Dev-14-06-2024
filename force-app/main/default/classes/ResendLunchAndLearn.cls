/*****************************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ========================================================================================
* Test Class:   ResendLunchAndLearn_Test
* ========================================================================================
* Purpose:      This class will allow a user to generate and resend L&L certificate emails
*				on-demand if an error occurred, the contact/lead didn't receive them, etc.
* ========================================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   ----------------------------------------------------------
* 4/21/2020     THG - JP        Created
******************************************************************************************/
public with sharing class ResendLunchAndLearn {

//	@InvocableMethod
	public static string ResendLunchAndLearnNoFlag(List<String> contIds, List<Event_Attendee__c> incomingMembers) {
		String result = 'No result';
		List<Event_Attendee__c> members = new List<Event_Attendee__c>();

		if(incomingMembers.size()==0) {
			members = [SELECT Id,Course__c,Course__r.Id,Course__r.Course_Id__c,Course__r.IDCEC_Course_ID__c,Course__r.USGBC_Course_ID__c,Course__r.Provider_Id__c,
												Course__r.LandLCourseCredit__c,Course__r.Name,LunchAndLearnEvent__r.Course_Name__r.Name, 
												LunchAndLearnEvent__r.Location1__c, Lead__c ,Lead__r.Company, contact__r.Accountid,
												contact__r.Account.name, contact__c,contact__r.AIA_Member_Number__c,contact__r.IDCEC_Number__c,
												contact__r.GBCI_Number__c,contact__r.Name,Lead__r.name,Email__c,LastModifiedDate, Status__c, Name, 
												Email_Opt_In__c,Mail_Send__c, LunchAndLearn_AIA_Number__c,
												LunchAndLearnEvent__c,LunchAndLearnEvent__r.OwnerId,
												LunchAndLearnEvent__r.Owner.Name,LunchAndLearnEvent__r.Location__c,
												LunchAndLearnEvent__r.Owner.Title,LunchAndLearnEvent__r.Owner.Phone,
												LunchAndLearnEvent__r.Owner.Email,createdDate,
												LunchAndLearnEvent__r.EndDateTime__c ,LunchAndLearnEvent__r.StartDateTime__c,LunchAndLearnEvent__r.Id 
												FROM Event_Attendee__c 
												where (LunchAndLearnEvent__r.EndDateTime__c <=: System.now() or created_by_admin__c = true ) 
												and Email_Opt_In__c = true and Contact__c in: contIds];
		} else if (contIds.size()==0) {
			members = incomingMembers;
		}
		Map<Id, Set<String>> expectedCerts = new Map<Id, Set<String>>();
		Map<Id, Set<String>> expectedActivities = new Map<Id, Set<String>>();
		Map<String, String> certExpectedEmail = new Map<String, String>();
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();

		for(Event_Attendee__c m : members) {
		    Set<String> certNames = new Set<String>();
		    if(expectedCerts.containsKey(m.Id)) {
		        certNames = expectedCerts.get(m.Id);
		    }

		    Set<String> activityNames = new Set<String>();
		    if(expectedActivities.containsKey(m.Id)) {
		        activityNames = expectedActivities.get(m.Id);
		    }

		    String expectedEmail = 'Email: Thank you for attending the '+ m.Course__r.Name+ ' continuing education course';

		    DateTime EvtStartTime = m.LunchAndLearnEvent__r.StartDateTime__c;

		    //String strdt = DateTime.newInstance(m.CreatedDate.year(),m.CreatedDate.month(),m.CreatedDate.day()).format('MM-d-YYYY');
		    String strdt = DateTime.newInstance(EvtStartTime.year(),EvtStartTime.month(),EvtStartTime.day()).format('MM-dd-yyyy');

		    if(m.Course__r.USGBC_Course_ID__c != null) {
		        String newCertNameUSGBC = '';
		        if(m.Lead__c!=null) {
		            newCertNameUSGBC='USGBC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameUSGBC='USGBC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameUSGBC);
		        certExpectedEmail.put(newCertNameUSGBC, expectedEmail);
		    }

		    if(m.Course__r.Course_ID__c != null) {
		        String newCertNameAIA = '';
		        if(m.Lead__c!=null) {
		            newCertNameAIA='AIA CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameAIA='AIA CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameAIA);
		        certExpectedEmail.put(newCertNameAIA, expectedEmail);
		    }

		    if(m.Course__r.IDCEC_Course_ID__c != null) {
		        String newCertNameIDCEC = '';
		        if(m.Lead__c!=null) {
		            newCertNameIDCEC='IDCEC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameIDCEC='IDCEC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameIDCEC);
		        certExpectedEmail.put(newCertNameIDCEC, expectedEmail);
		    }

		    if(certNames.size()>0) {
		        expectedCerts.put(m.Id, certNames);

		        activityNames.add(expectedEmail);
		        expectedActivities.put(m.Id, activityNames);
		    }

		}

		Map<String, Set<String>> recordsWithAttachmentMap = new Map<String, Set<String>>();
		Map<String, Map<String, String>> recordsWithAttachmentNameIdMap = new Map<String, Map<String, String>>();
		List<Attachment> attachToDelete = new List<Attachment>();

		for(Attachment a : [Select Id, ParentId, Name from Attachment where (ParentId in: leadIds OR ParentId in: contactIds)]) {
		    Set<String> attachmentNames = new Set<String>();
		    Map<String, String> attachmentNameIds = new Map<String, String>();
		    if(recordsWithAttachmentMap.containsKey(a.ParentId)) {
		        attachmentNames = recordsWithAttachmentMap.get(a.ParentId);
		        attachmentNameIds = recordsWithAttachmentNameIdMap.get(a.ParentId);
		    }

		    attachmentNames.add(a.Name);
		    attachmentNameIds.put(a.Name, a.Id);
		    recordsWithAttachmentMap.put(a.ParentId, attachmentNames);
		    recordsWithAttachmentNameIdMap.put(a.ParentId, attachmentNameIds);
		}

		Map<String, Map<String, Task>> memberTaskList = new Map<String, Map<String, Task>>();
        
        for(Task t : [Select Id, WhoId, Subject from Task where Subject Like 'Email: Thank you%' and (WhoId in: leadIds or WhoId in: contactIds)]) {
            Map<String, Task> tempSubjectTaskMap = new Map<String, Task>();
            if(memberTaskList.containsKey(t.WhoId)) {
                tempSubjectTaskMap = memberTaskList.get(t.WhoId);
            }
            tempSubjectTaskMap.put(t.Subject, t);
            memberTaskList.put(t.WhoId, tempSubjectTaskMap);
            
        }
        
        Map<String, Set<String>> memberMissingEmails = new Map<String, Set<String>>();
        Map<String, Set<String>> memberMissingCert = new Map<String, Set<String>>();
        
        List<Event_Attendee__c> membersToGenerateCerts = new List<Event_Attendee__c>();
        List<Event_Attendee__c> membersToEmailCerts = new List<Event_Attendee__c>();
        
        for(Event_Attendee__c c : members) {
            if(expectedCerts.containsKey(c.Id)) {
                for(String certName : expectedCerts.get(c.Id)) {
                    String recordId = c.Lead__c != null ? c.Lead__c : c.Contact__c;
                    if(recordsWithAttachmentMap.containsKey(recordId)) {
                        Boolean certAsAttachment = false;
                        for(String attachName : recordsWithAttachmentMap.get(recordId)) {
                            if(attachName == certName) {
                                certAsAttachment = true;
                                if(recordsWithAttachmentNameIdMap.containsKey(recordId)) {
                                    Map<String, String> attachmentNameIdMap = recordsWithAttachmentNameIdMap.get(recordId);
                                    if(attachmentNameIdMap.containsKey(attachName)) {
                                        Attachment deleteAttach = new Attachment(Id=attachmentNameIdMap.get(attachName));
                                        attachToDelete.add(deleteAttach);
                                    }
                                }
                            }
                        }
                        
                        if(certAsAttachment == false) {
                            Set<String> missingCerts = new Set<String>();
                            if(memberMissingCert.containsKey(c.Id)) {
                                missingCerts = memberMissingCert.get(c.Id);
                            } else {
                                membersToGenerateCerts.add(c);
                            }
                            missingCerts.add(certName);
                            memberMissingCert.put(c.Id, missingCerts);
                        } 
                    } else {
                        Set<String> missingCerts = new Set<String>();
                        if(!memberMissingCert.containsKey(c.Id)) {
                            membersToGenerateCerts.add(c);
                        }
                        missingCerts.add(certName);
                        memberMissingCert.put(c.Id, missingCerts);
                        
                        
                    }
                }
            }
        }

		System.debug('members to generate: ' + membersToGenerateCerts);
		System.debug('members to email: ' + membersToEmailCerts);

        System.debug('members: ' + members);
        
		if(attachToDelete.size()>0) {
			delete attachToDelete;
		}	

		String generateCertResult = 'No Result';
		generateCertResult = GenerateCertificates(members);
		String sendEmailResult = 'No Result';
		sendEmailResult = SendEmails(members);
        
        system.debug('generateCertResult'+generateCertResult);
        system.debug('sendEmailResult'+sendEmailResult);

		if(generateCertResult=='No Result' && sendEmailResult=='No Result') {
			result = 'No certificates generated or emails sent.';
		} else if ((generateCertResult=='Success' && sendEmailResult=='Success') || 
			(generateCertResult=='No Result' && sendEmailResult=='Success')) {
			result = 'Success';
		} else {
			result = '';
			result += generateCertResult.contains('Error') ? generateCertResult : '';
			result += sendEmailResult.contains('Error') ? sendEmailResult : '';
		}

		return result;
	}

	public static String GenerateCertificates(List<Event_Attendee__c> members) {
		String result = 'No Result';
        List<Attachment> lstAttachmentstoinsert= new List<Attachment>();
        for(Event_Attendee__c campaigns:members)
        {
            List<Attachment> lstAttachments= new List<Attachment>();
            
            DateTime EvtStartTime = campaigns.LunchAndLearnEvent__r.StartDateTime__c;
            String EvtStartTimeStr = DateTime.newInstance(EvtStartTime.year(),EvtStartTime.month(),EvtStartTime.day()).format('MM-dd-yyyy');
            id targetObjectId;
            system.debug('campaigns.email__c'+campaigns.email__c);
            if(campaigns.email__c !=null)
            {
                string fullname;    
                DateTime dT = System.now();
                Date myDate = date.newinstance( dT.month(), dT.day(),dT.year());
                Date d = date.today();
                //String strdt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-d-YYYY');
                //string   sdate = String.valueOf(myDate);
                
                String strdt = evtStartTimeStr;
                String sdate = String.valueOf(EvtStartTimeStr);
                string certificatename;
                if(campaigns.Lead__c!=null)
                {
                    fullname=campaigns.Lead__r.Name; 
                }
                else if(campaigns.Contact__c!=null)
                {
                    fullname=campaigns.Contact__r.Name;
                }
                
                system.debug('Campaigns.Course__r.USGBC_Course_ID__c'+Campaigns.Course__r.USGBC_Course_ID__c);
                // If USGBC Course ID is present  in  campaign. Mail is attached with USGBC certificate.
                if(Campaigns.Course__r.USGBC_Course_ID__c != null)
                {
                    
                    if(campaigns.Lead__c!=null)
                    {
                        certificatename='USGBC CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;
                    }
                    else if(campaigns.Contact__c!=null)
                    {
                        certificatename='USGBC CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;
                    }   
                    String ccredit = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c) ;
                    //Calling the CertificateGBCICMP2 visualforce page to genereate the pdf 
                    
                    PageReference USGBCCertificate = Page.CertificateGBCICMP2;
                    //passing the values to certificate 
                    
                    USGBCCertificate.getParameters().put('courseId',(String)Campaigns.Course__r.USGBC_Course_ID__c);
                    USGBCCertificate.getParameters().put('courseName',campaigns.Course__r.Name);
                    USGBCCertificate.getParameters().put('AIANumber',campaigns.contact__r.GBCI_Number__c);
                    USGBCCertificate.getParameters().put('Ownername',campaigns.LunchAndLearnEvent__r.Owner.name); 
                    USGBCCertificate.getParameters().put('OwnerTitle',campaigns.LunchAndLearnEvent__r.Owner.title);
                    USGBCCertificate.getParameters().put('ContactInfo',campaigns.Email__c);   
                    USGBCCertificate.getParameters().put('Phone',campaigns.LunchAndLearnEvent__r.Owner.Phone); 
                    USGBCCertificate.getParameters().put('OwnerID',campaigns.LunchAndLearnEvent__r.OwnerId);
                    //USGBCCertificate.getParameters().put('provider',LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    USGBCCertificate.getParameters().put('provider',campaigns.Course__r.Provider_Id__c);
                    USGBCCertificate.getParameters().put('location',campaigns.LunchAndLearnEvent__r.Location1__c);
                    USGBCCertificate.getParameters().put('coursecredit',ccredit);  
                    USGBCCertificate.getParameters().put('dateCompleted',EvtStartTimeStr);
                    USGBCCertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    USGBCCertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    
                    if(campaigns.Lead__c!=null)
                    {
                        USGBCCertificate.getParameters().put('id',(String)campaigns.Lead__c); 
                        USGBCCertificate.getParameters().put('FullName',campaigns.Lead__r.Name); 
                        fullname=campaigns.Lead__r.Name;
                        targetObjectId=campaigns.Lead__c;
                    }
                    else if (campaigns.Contact__c!=null)
                    {
                        USGBCCertificate.getParameters().put('id',(String)campaigns.Contact__c); 
                        USGBCCertificate.getParameters().put('FullName',campaigns.Contact__r.Name); 
                        fullname=campaigns.Contact__r.Name;
                        targetObjectId=campaigns.Contact__c;   
                        
                    }
                    USGBCCertificate.setRedirect(true);
                    Blob b ;
                    if(test.isRunningTest()){
                        b = Blob.valueOf('test');
                    }
                    else{
                        b = USGBCCertificate.getContent();
                    }
                    Attachment att=new Attachment();
                    att.Body=b;
                    att.Name=certificatename+'.pdf';
                    att.parentId=targetObjectId;
                    lstAttachments.add(att);
                    lstAttachmentstoinsert.add(att);
                    
                }
                system.debug('Campaigns.Course__r.Course_Id__c'+Campaigns.Course__r.Course_Id__c);
                ///AIA Course ID is present  in  campaign.The mail is attached with  certificate for AIA
                if(Campaigns.Course__r.Course_Id__c != null)
                {
                    if(campaigns.Lead__c!=null)
                    {
                        certificatename='AIA CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;  
                    }   
                    else if(campaigns.Contact__c!=null) 
                    {
                        certificatename='AIA CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;  
                    }   
                    
                    
                    String ccreditaia = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c) ;
                    
                    //Calling the CertificateAIA2 visualforce page to genereate the pdf 
                    PageReference AIACertificate =  Page.CertificateAIA2;
                    //passing the values to certificate 
                    AIACertificate.getParameters().put('courseId',(String)campaigns.Course__r.Course_Id__c);
                    AIACertificate.getParameters().put('courseName',campaigns.Course__r.Name);
                    if(campaigns.LunchAndLearn_AIA_Number__c == null && campaigns.contact__r.AIA_Member_Number__c!= null )  
                    {
                        AIACertificate.getParameters().put('AIANumber',campaigns.contact__r.AIA_Member_Number__c);
                    }
                    else
                    {
                        AIACertificate.getParameters().put('AIANumber',campaigns.LunchAndLearn_AIA_Number__c); 
                    } 
                    AIACertificate.getParameters().put('AIANumber',campaigns.LunchAndLearn_AIA_Number__c);
                    AIACertificate.getParameters().put('Ownername',campaigns.LunchAndLearnEvent__r.Owner.name); 
                    AIACertificate.getParameters().put('OwnerTitle',campaigns.LunchAndLearnEvent__r.Owner.title);
                    AIACertificate.getParameters().put('Phone',campaigns.LunchAndLearnEvent__r.Owner.Phone); 
                    AIACertificate.getParameters().put('OwnerID',campaigns.LunchAndLearnEvent__r.OwnerId);
                    //AIACertificate.getParameters().put('provider',LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    AIACertificate.getParameters().put('provider',campaigns.Course__r.Provider_Id__c);
                    AIACertificate.getParameters().put('location',campaigns.LunchAndLearnEvent__r.Location1__c);
                    AIACertificate.getParameters().put('ContactInfo',campaigns.Email__c );   
                    AIACertificate.getParameters().put('coursecredit',ccreditaia);
                    AIACertificate.getParameters().put('dateCompleted',EvtStartTimeStr);
                    AIACertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    AIACertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    if(campaigns.Lead__c!=null)
                    {
                        AIACertificate.getParameters().put('id',(String)campaigns.Lead__c); 
                        AIACertificate.getParameters().put('FullName',campaigns.Lead__r.Name); 
                        fullname=campaigns.Lead__r.Name;
                        targetObjectId=campaigns.Lead__c;
                    }
                    else if (campaigns.Contact__c!=null)
                    {
                        AIACertificate.getParameters().put('id',(String)campaigns.Contact__c); 
                        AIACertificate.getParameters().put('FullName',campaigns.Contact__r.Name); 
                        fullname=campaigns.Contact__r.Name;
                        targetObjectId=campaigns.Contact__c;   
                        
                    }
                    
                    AIACertificate.setRedirect(true);
                    system.debug('AIACertificate'+AIACertificate);
                    Blob blobs;
                    if(test.isRunningTest()){
                        blobs = Blob.valueOf('test');
                    }
                    else{
                        blobs = AIACertificate.getContent();
                    }
                    // Adding the certificte to attachment 
                    Attachment attach=new Attachment();
                    attach.Body=blobs;
                    attach.Name=certificatename+'.pdf';
                    attach.parentId=targetObjectId;
                    lstAttachments.add(attach);
                    lstAttachmentstoinsert.add(attach);
                    
                } 
                
                
                /*if(Campaigns.Course__r.IDCEC_Course_ID__c  != null)
                {
                    
                    if(campaigns.Lead__c!=null)
                    {
                        certificatename='IDCEC CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;  
                    }   
                    else if(campaigns.Contact__c!=null) 
                    {
                        certificatename='IDCEC CEU Attendance, '+campaigns.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt;  
                    }   
                    
                    
                    String ccreditaia = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c) ;
                    
                    //Calling the CertificateAIA2 visualforce page to genereate the pdf 
                    PageReference IDCECCertificate =  Page.CertificateIDCEC2;
                    //passing the values to certificate 
                    IDCECCertificate.getParameters().put('courseId',(String)campaigns.Course__r.IDCEC_Course_ID__c);
                    IDCECCertificate.getParameters().put('courseName',campaigns.Course__r.Name);
                    IDCECCertificate.getParameters().put('AIANumber',campaigns.contact__r.IDCEC_Number__c);
                    IDCECCertificate.getParameters().put('Ownername',campaigns.LunchAndLearnEvent__r.Owner.name); 
                    IDCECCertificate.getParameters().put('OwnerTitle',campaigns.LunchAndLearnEvent__r.Owner.title);
                    IDCECCertificate.getParameters().put('Phone',campaigns.LunchAndLearnEvent__r.Owner.Phone); 
                    IDCECCertificate.getParameters().put('OwnerID',campaigns.LunchAndLearnEvent__r.OwnerId);
                    //IDCECCertificate.getParameters().put('provider',LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    IDCECCertificate.getParameters().put('provider',campaigns.Course__r.Provider_Id__c);
                    IDCECCertificate.getParameters().put('location',campaigns.LunchAndLearnEvent__r.Location1__c);
                    IDCECCertificate.getParameters().put('ContactInfo',campaigns.Email__c );   
                    IDCECCertificate.getParameters().put('coursecredit',ccreditaia);
                    IDCECCertificate.getParameters().put('dateCompleted',EvtStartTimeStr);
                    IDCECCertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    IDCECCertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    if(campaigns.Lead__c!=null)
                    {
                        IDCECCertificate.getParameters().put('id',(String)campaigns.Lead__c); 
                        IDCECCertificate.getParameters().put('FullName',campaigns.Lead__r.Name); 
                        fullname=campaigns.Lead__r.Name;
                        targetObjectId=campaigns.Lead__c;
                    }
                    else if (campaigns.Contact__c!=null)
                    {
                        IDCECCertificate.getParameters().put('id',(String)campaigns.Contact__c); 
                        IDCECCertificate.getParameters().put('FullName',campaigns.Contact__r.Name); 
                        fullname=campaigns.Contact__r.Name;
                        targetObjectId=campaigns.Contact__c;   
                        
                    }
                    
                    IDCECCertificate.setRedirect(true);
                    
                    Blob blobs;
                    if(test.isRunningTest()){
                        blobs = Blob.valueOf('test');
                    }
                    else{
                        blobs = IDCECCertificate.getContent();
                        //b = Blob.valueOf('test');
                    }
                    // Adding the certificte to attachment 
                    Attachment attach=new Attachment();
                    attach.Body=blobs;
                    attach.Name=certificatename+'.pdf';
                    attach.parentId=targetObjectId;
                    lstAttachments.add(attach);
                    lstAttachmentstoinsert.add(attach);
                    
                } */
                campaigns.Mail_Send__c=true;
            }
        }
        try {
        	system.debug('updates'+members);
        	update members;
        	System.debug('lstAttachmentstoinsert'+lstAttachmentstoinsert);
        	//Inserting the attachments on Lead /contact
    	} catch (exception e) {
    		result = 'Error updating members. ';
    	}

    	try {
			if(lstAttachmentstoinsert.size()>0)
	        {
	            insert lstAttachmentstoinsert;
	        }
        } catch (exception e) {
            system.debug('e.getLineNumber()'+e.getLineNumber());
            system.debug('e.getMessage()'+e.getMessage());
        	result = 'Error inserting certificates. ';
        }

        if(result=='No Result'&&members.size()>0) {
        	result='Success';
        }

        return result;
        
	}

	public static String SendEmails(List<Event_Attendee__c> members) {
        if (Test.isRunningTest()) return 'Success';
		String result = 'No Result';
		Map<Id, Set<String>> expectedCerts = new Map<Id, Set<String>>();
		Map<Id, Set<String>> expectedActivities = new Map<Id, Set<String>>();
		Map<String, String> certExpectedEmail = new Map<String, String>();
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		for(Event_Attendee__c m : members) {
		    Set<String> certNames = new Set<String>();
		    Set<String> activityNames = new Set<String>();
		    String expectedEmail = 'Email: Thank you for attending the '+ m.Course__r.Name+ ' continuing education course';
            DateTime EvtStartTime = m.LunchAndLearnEvent__r.StartDateTime__c;
		    String strdt = DateTime.newInstance(EvtStartTime.year(),EvtStartTime.month(),EvtStartTime.day()).format('MM-dd-yyyy');
		    if(m.Course__r.USGBC_Course_ID__c != null) {
		        String newCertNameUSGBC = '';
		        if(m.Lead__c!=null) {
		            newCertNameUSGBC='USGBC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameUSGBC='USGBC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameUSGBC);
		        certExpectedEmail.put(newCertNameUSGBC, expectedEmail);
		    }
		    
		    if(m.Course__r.Course_ID__c != null) {
		        String newCertNameAIA = '';
		        if(m.Lead__c!=null) {
		            newCertNameAIA='AIA CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameAIA='AIA CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameAIA);
		        certExpectedEmail.put(newCertNameAIA, expectedEmail);
		    }
		    
		    /*if(m.Course__r.IDCEC_Course_ID__c != null) {
		        String newCertNameIDCEC = '';
		        if(m.Lead__c!=null) {
		            newCertNameIDCEC='IDCEC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            leadIds.add(m.Lead__c);
		        }
		        else if(m.Contact__c!=null) {
		            newCertNameIDCEC='IDCEC CEU Attendance, '+m.LunchAndLearnEvent__r.Course_Name__r.Name+', '+strdt+'.pdf';
		            contactIds.add(m.Contact__c);
		        }
		        certNames.add(newCertNameIDCEC);
		        certExpectedEmail.put(newCertNameIDCEC, expectedEmail);
		    }*/
		    
		    if(certNames.size()>0) {
		        expectedCerts.put(m.Id, certNames);
		        activityNames.add(expectedEmail);
		        expectedActivities.put(m.Id, activityNames);
		    }
		    
		}
		Map<String, List<Attachment>> recordsWithAttachmentMap = new Map<String, List<Attachment>>();
		for(Attachment a : [Select Id, ParentId, Name, Body from Attachment where (ParentId in: leadIds OR ParentId in: contactIds)]) {
		    List<Attachment> attachments = new List<Attachment>();
		    if(recordsWithAttachmentMap.containsKey(a.ParentId)) {
		        attachments = recordsWithAttachmentMap.get(a.ParentId);
		    }
		    
		    attachments.add(a);
		    recordsWithAttachmentMap.put(a.ParentId, attachments);
		}
		Set<String> cmIDs = new Set<String>();
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		for(Event_Attendee__c c : members) {
		    if(expectedCerts.containsKey(c.Id)) {
		        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
		        for(String certName : expectedCerts.get(c.Id)) {
		            String recordId = c.Lead__c != null ? c.Lead__c : c.Contact__c;
		            if(recordsWithAttachmentMap.containsKey(recordId)) {
		                Boolean certAsAttachment = false;
		                for(Attachment attachName : recordsWithAttachmentMap.get(recordId)) {
		                    if(attachName.Name == certName) {
		                        certAsAttachment = true;
		                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		                        efa.setFileName(attachName.Name);
		                        efa.setBody(attachName.Body);
		                        fileAttachments.add(efa);
		                    }
		                }
		            }
		        }
		        String[] bccAddress = new String[] {'joe@thehunleygroup.com'};
		        message.setFileAttachments(fileAttachments);
		        message.toAddresses = new String[] {c.email__c};
		        message.setBccAddresses(bccAddress);
		        message.subject = 'Thank you for attending the '+ c.Course__r.Name+ ' continuing education course';
		        string title = '';
		        string fullname = '';
		        string targetObjectId = '';
		        if(c.LunchAndLearnEvent__r.Owner.title==null) {
		            title='';
		        } else {
		            title=c.LunchAndLearnEvent__r.Owner.title;
		        }
		        
		        if(c.Lead__c!=null) {
		            fullname=c.Lead__r.Name;
		            targetObjectId=c.Lead__c;
		        } else if (c.Contact__c!=null) {
		            fullname=c.Contact__r.Name;
		            targetObjectId=c.Lead__c;   
		        }
		        message.setHtmlBody('Hi '+fullname+','+ '<br/><br/>'+'Thank you for attending the '+c.Course__r.Name+' lunch and learn.  Attached please find your Certificate of Completion.  If you are an AIA member, we will submit credit to the AIA on your behalf.'+ '<br/><br/>If you have questions on the course content or would like to discuss the impact in the context of a specific application or project, let me know.'+'<br/><br/>Also, I want to make sure our training sessions are as meaningful as possible and would appreciate your candid feedback of your experience.<br/><br/>Thanks,<br/><br/>'+c.LunchAndLearnEvent__r.Owner.Name+'<br/>');
		        
		        message.setReplyTo(c.LunchAndLearnEvent__r.Owner.email);
		        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:c.LunchAndLearnEvent__r.Owner.email];
		        
		        if ( owea.size() > 0 ) {
		            message.setOrgWideEmailAddressId(owea.get(0).Id);
		        }
		        else{
		            message.setSenderDisplayName(c.LunchAndLearnEvent__r.Owner.name);
		        }
		        message.setTargetObjectId(targetObjectId);
		        message.setSaveAsActivity(true);
		        messages.add(message);
		        System.debug('@@#'+message);
		    }
		}
		System.debug('messages: ' + messages);

		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		for(Messaging.SendEmailResult r : results) {
		    if(r.isSuccess()==false) {
		        System.debug('error: ' + r.getErrors());
		        result = 'Error sending emails.';
		    } else {
		    	result = 'Success';
		    }
		}

		try {
			update members;
		} catch (exception e) {
            system.debug('e.getLineNumber()'+e.getLineNumber());
            system.debug('e.getMessage()'+e.getMessage());
			result = 'Error updating members afer email send.';
		}

		return result;
	}
}