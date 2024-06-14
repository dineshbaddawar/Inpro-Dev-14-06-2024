/*************************************************************
* Created by:   The Hunley Group
* Created on:    4/21/2020
* ===========================================================
* Test Class:   LunchandLeanControllerTest
* ===========================================================
* Purpose:   To Send the mail with certificate to attendees. 
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
*
************************************************************/
global class BatchEmailSendForCampaigns implements Database.Batchable < sObject > {
    
    global Database.querylocator start(Database.BatchableContext BC) {
        String certificateTimeWindow = label.L_L_Certificate_Time_Window;
        datetime dateTimeNow = system.now().addHours(- Integer.valueOf(certificateTimeWindow) );
        // Query the AsyncApexJob object to retrieve the current job's information    
        return Database.getQueryLocator([SELECT Id, Course__c,Course__r.Id, Course__r.Course_Id__c,Course__r.Provider_Id__c, Course__r.IDCEC_Course_ID__c, Course__r.USGBC_Course_ID__c, Course__r.LandLCourseCredit__c, Course__r.Name, LunchAndLearnEvent__r.Course_Name__r.Name, LunchAndLearnEvent__r.Location1__c, Lead__c, Lead__r.Company,Lead__r.IDCEC_Number__c, Contact__r.Accountid, Contact__r.Account.name, Contact__c, Contact__r.AIA_Member_Number__c, Contact__r.IDCEC_Number__c, Contact__r.GBCI_Number__c, Contact__r.Name, Lead__r.name, Email__c, LastModifiedDate, Status__c, Name, Mail_Send__c, LunchAndLearn_AIA_Number__c, LunchAndLearnEvent__c, LunchAndLearnEvent__r.OwnerId, LunchAndLearnEvent__r.Owner.Name, LunchAndLearnEvent__r.Location__c, LunchAndLearnEvent__r.Owner.Title, LunchAndLearnEvent__r.Owner.Phone, LunchAndLearnEvent__r.Owner.Email, createdDate, LunchAndLearnEvent__r.EndDateTime__c, LunchAndLearnEvent__r.StartDateTime__c,LunchAndLearnEvent__r.Id FROM Event_Attendee__c where(LunchAndLearnEvent__r.EndDateTime__c <=: dateTimeNow or created_by_admin__c = true) and Mail_Send__c != true AND Status__c = 'Attended'  AND (Contact__r.IDCEC_Number__c = null and Lead__r.IDCEC_Number__c = null)]);
    }
    global void execute(Database.BatchableContext BC, List < Event_Attendee__c > llist) {
        Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage > ();
        List < Attachment > lstAttachmentstoinsert = new List < Attachment > ();
        for (Event_Attendee__c campaigns: llist) {
            List < Attachment > lstAttachments = new List < Attachment > ();
            
            DateTime EvtStartTime = campaigns.LunchAndLearnEvent__r.StartDateTime__c;
            String EvtStartTimeStr = DateTime.newInstance(EvtStartTime.year(), EvtStartTime.month(), EvtStartTime.day()).format('MM-dd-yyyy');
            id targetObjectId;
            
            
            if (campaigns.Email__c != null) {
                string fullname;
                DateTime dT = System.now();
                Date myDate = date.newinstance(dT.month(), dT.day(), dT.year());
                Date d = date.today();
                String strdt = DateTime.newInstance(d.year(), d.month(), d.day()).format('MM-d-YYYY');
                string sdate = String.valueOf(myDate);
                string certificatename;
                if (campaigns.Lead__c != null) {
                    fullname = campaigns.Lead__r.Name;
                } else if (campaigns.Contact__c != null) {
                    fullname = campaigns.Contact__r.Name;
                }
                
                
                // If USGBC Course ID is present  in  campaign. Mail is attached with USGBC certificate.
                if (Campaigns.Course__r.USGBC_Course_ID__c != null) {
                    
                    if (campaigns.Lead__r != null) {
                        certificatename = 'USGBC CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    } else if (campaigns.Contact__r != null) {
                        certificatename = 'USGBC CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    }
                    String ccredit = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c);
                    //Calling the CertificateGBCICMP2 visualforce page to genereate the pdf 
                    
                    PageReference USGBCCertificate = Page.CertificateGBCICMP2;
                    //passing the values to certificate 
                    
                    USGBCCertificate.getParameters().put('courseId', (String) Campaigns.Course__r.USGBC_Course_ID__c);
                    USGBCCertificate.getParameters().put('courseName', campaigns.Course__r.Name);
                    USGBCCertificate.getParameters().put('AIANumber', campaigns.contact__r.GBCI_Number__c);
                    USGBCCertificate.getParameters().put('Ownername', campaigns.LunchAndLearnEvent__r.Owner.name);
                    USGBCCertificate.getParameters().put('OwnerTitle', campaigns.LunchAndLearnEvent__r.Owner.title);
                    USGBCCertificate.getParameters().put('ContactInfo', campaigns.Email__c);
                    USGBCCertificate.getParameters().put('Phone', campaigns.LunchAndLearnEvent__r.Owner.Phone);
                    USGBCCertificate.getParameters().put('OwnerID', campaigns.LunchAndLearnEvent__r.OwnerId);
                    //USGBCCertificate.getParameters().put('provider', LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    USGBCCertificate.getParameters().put('provider', campaigns.Course__r.Provider_Id__c);
                    USGBCCertificate.getParameters().put('location', campaigns.LunchAndLearnEvent__r.Location1__c);
                    USGBCCertificate.getParameters().put('coursecredit', ccredit);
                    USGBCCertificate.getParameters().put('dateCompleted', EvtStartTimeStr);
                    USGBCCertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    USGBCCertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    
                    if (campaigns.Lead__c != null) {
                        USGBCCertificate.getParameters().put('id', (String) campaigns.Lead__c);
                        USGBCCertificate.getParameters().put('FullName', campaigns.Lead__r.Name);
                        fullname = campaigns.Lead__r.Name;
                        targetObjectId = campaigns.Lead__c;
                    } else if (campaigns.Contact__c != null) {
                        USGBCCertificate.getParameters().put('id', (String) campaigns.Contact__c);
                        USGBCCertificate.getParameters().put('FullName', campaigns.Contact__r.Name);
                        fullname = campaigns.Contact__r.Name;
                        targetObjectId = campaigns.Contact__c;
                        
                    }
                    USGBCCertificate.setRedirect(true);
                    Blob b;
                    if (test.isRunningTest()) {
                        b = Blob.valueOf('test');
                    } else {
                        b = USGBCCertificate.getContent();
                    }
                    
                    // Adding the certificte to attachment 
                    Attachment att = new Attachment();
                    att.Body = b;
                    att.Name = certificatename + '.pdf';
                    att.parentId = targetObjectId;
                    lstAttachments.add(att);
                    lstAttachmentstoinsert.add(att);
                    
                }
                system.debug(Campaigns.Course__r.Course_Id__c);
                ///AIA Course ID is present  in  campaign.The mail is attached with  certificate for AIA
                if (Campaigns.Course__r.Course_Id__c != null) {
                    
                    if (campaigns.Lead__c != null) {
                        certificatename = 'AIA CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    } else if (campaigns.Contact__c != null) {
                        certificatename = 'AIA CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    }
                    
                    
                    String ccreditaia = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c);
                    
                    //Calling the CertificateAIA2 visualforce page to genereate the pdf 
                    PageReference AIACertificate = Page.CertificateAIA2;
                    //passing the values to certificate 
                    AIACertificate.getParameters().put('courseId', (String) campaigns.Course__r.Course_Id__c);
                    AIACertificate.getParameters().put('courseName', campaigns.Course__r.Name);
                    
                    if (campaigns.LunchAndLearn_AIA_Number__c == null && campaigns.contact__r.AIA_Member_Number__c != null) {
                        AIACertificate.getParameters().put('AIANumber', campaigns.contact__r.AIA_Member_Number__c);
                    } else {
                        AIACertificate.getParameters().put('AIANumber', campaigns.LunchAndLearn_AIA_Number__c);
                    }
                    AIACertificate.getParameters().put('AIANumber', campaigns.LunchAndLearn_AIA_Number__c);
                    AIACertificate.getParameters().put('Ownername', campaigns.LunchAndLearnEvent__r.Owner.name);
                    AIACertificate.getParameters().put('OwnerTitle', campaigns.LunchAndLearnEvent__r.Owner.title);
                    AIACertificate.getParameters().put('Phone', campaigns.LunchAndLearnEvent__r.Owner.Phone);
                    AIACertificate.getParameters().put('OwnerID', campaigns.LunchAndLearnEvent__r.OwnerId);
                    //AIACertificate.getParameters().put('provider', LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    AIACertificate.getParameters().put('provider', campaigns.Course__r.Provider_Id__c);
                    AIACertificate.getParameters().put('location', campaigns.LunchAndLearnEvent__r.Location1__c);
                    AIACertificate.getParameters().put('ContactInfo', campaigns.Email__c);
                    AIACertificate.getParameters().put('coursecredit', ccreditaia);
                    AIACertificate.getParameters().put('dateCompleted', EvtStartTimeStr);
                    AIACertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    AIACertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    if (campaigns.Lead__c != null) {
                        AIACertificate.getParameters().put('id', (String) campaigns.Lead__c);
                        AIACertificate.getParameters().put('FullName', campaigns.Lead__r.Name);
                        fullname = campaigns.Lead__r.Name;
                        targetObjectId = campaigns.Lead__c;
                    } else if (campaigns.Contact__c != null) {
                        AIACertificate.getParameters().put('id', (String) campaigns.Contact__c);
                        AIACertificate.getParameters().put('FullName', campaigns.Contact__r.Name);
                        fullname = campaigns.Contact__r.Name;
                        targetObjectId = campaigns.Contact__c;
                        
                    }
                    
                    AIACertificate.setRedirect(true);
                    
                    Blob blobs;
                    if (test.isRunningTest()) {
                        blobs = Blob.valueOf('test');
                    } else {
                        blobs = AIACertificate.getContent();
                        //b = Blob.valueOf('test');
                    }
                    // Adding the certificte to attachment 
                    Attachment attach = new Attachment();
                    attach.Body = blobs;
                    attach.Name = certificatename + '.pdf';
                    attach.parentId = targetObjectId;
                    lstAttachments.add(attach);
                    lstAttachmentstoinsert.add(attach);
                    
                }
                
                
                /*if (Campaigns.Course__r.IDCEC_Course_ID__c != null) {
                    
                    if (campaigns.Lead__c != null) {
                        certificatename = 'IDCEC CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    } else if (campaigns.Contact__c != null) {
                        certificatename = 'IDCEC CEU Attendance, ' + campaigns.LunchAndLearnEvent__r.Course_Name__r.Name + ', ' + strdt;
                    }
                    
                    
                    String ccreditaia = String.valueOf(Campaigns.Course__r.LandLCourseCredit__c);
                    
                    //Calling the CertificateAIA2 visualforce page to genereate the pdf 
                    PageReference IDCECCertificate = Page.CertificateIDCEC2;
                    //passing the values to certificate 
                    IDCECCertificate.getParameters().put('courseId', (String) campaigns.Course__r.IDCEC_Course_ID__c);
                    IDCECCertificate.getParameters().put('courseName', campaigns.Course__r.Name);
                    IDCECCertificate.getParameters().put('AIANumber', campaigns.contact__r.IDCEC_Number__c);
                    IDCECCertificate.getParameters().put('Ownername', campaigns.LunchAndLearnEvent__r.Owner.name);
                    IDCECCertificate.getParameters().put('OwnerTitle', campaigns.LunchAndLearnEvent__r.Owner.title);
                    IDCECCertificate.getParameters().put('Phone', campaigns.LunchAndLearnEvent__r.Owner.Phone);
                    IDCECCertificate.getParameters().put('OwnerID', campaigns.LunchAndLearnEvent__r.OwnerId);
                    //IDCECCertificate.getParameters().put('provider', LunchandLearnUtils.GetMetadataValue('Provider_Number__c'));
                    IDCECCertificate.getParameters().put('provider', campaigns.Course__r.Provider_Id__c);
                    IDCECCertificate.getParameters().put('location', campaigns.LunchAndLearnEvent__r.Location1__c);
                    IDCECCertificate.getParameters().put('ContactInfo', campaigns.Email__c);
                    IDCECCertificate.getParameters().put('coursecredit', ccreditaia);
                    IDCECCertificate.getParameters().put('dateCompleted', EvtStartTimeStr);
                    IDCECCertificate.getParameters().put('courseRecordId',campaigns.Course__r.Id);
                    IDCECCertificate.getParameters().put('l&lRecordId',campaigns.LunchAndLearnEvent__r.Id);
                    if (campaigns.Lead__c != null) {
                        IDCECCertificate.getParameters().put('id', (String) campaigns.Lead__c);
                        IDCECCertificate.getParameters().put('FullName', campaigns.Lead__r.Name);
                        fullname = campaigns.Lead__r.Name;
                        targetObjectId = campaigns.Lead__c;
                    } else if (campaigns.Contact__c != null) {
                        IDCECCertificate.getParameters().put('id', (String) campaigns.Contact__c);
                        IDCECCertificate.getParameters().put('FullName', campaigns.Contact__r.Name);
                        fullname = campaigns.Contact__r.Name;
                        targetObjectId = campaigns.Contact__c;
                        
                    }
                    
                    IDCECCertificate.setRedirect(true);
                    
                    Blob blobs;
                    if (test.isRunningTest()) {
                        blobs = Blob.valueOf('test');
                    } else {
                        blobs = IDCECCertificate.getContent();
                        //b = Blob.valueOf('test');
                    }
                    // Adding the certificte to attachment 
                    Attachment attach = new Attachment();
                    attach.Body = blobs;
                    attach.Name = certificatename + '.pdf';
                    attach.parentId = targetObjectId;
                    lstAttachments.add(attach);
                    lstAttachmentstoinsert.add(attach);
                    
                }*/
                
                // Send an email to the Lunch and learn Owner  notifying the Lunch and learn event registration completion.
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                // Attaching the certificate to emails
                List < Messaging.Emailfileattachment > fileAttachments = new List < Messaging.Emailfileattachment > (); //
                string title;
                // Set recipients to  contact.
                message.toAddresses = new String[] {
                    campaigns.email__c
                        };
                            message.subject = 'Thank you for attending the ' + campaigns.Course__r.Name + ' continuing education course';
                if (campaigns.LunchAndLearnEvent__r.Owner.title == null) {
                    title = '';
                } else {
                    title = campaigns.LunchAndLearnEvent__r.Owner.title;
                }
                
                //Setting the HTML Body
                message.setHtmlBody('Hi ' + fullname + ',' + '<br/><br/>' + 'Thank you for attending the ' + campaigns.Course__r.Name + ' lunch and learn.  Attached please find your Certificate of Completion.  If you are an AIA member, we will submit credit to the AIA on your behalf.' + '<br/><br/>If you have questions on the course content or would like to discuss the impact in the context of a specific application or project, let me know.<br/><br/>Thanks,<br/><br/>' + campaigns.LunchAndLearnEvent__r.Owner.Name + '<br/>');
                
                
                message.setReplyTo(campaigns.LunchAndLearnEvent__r.Owner.email);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: campaigns.LunchAndLearnEvent__r.Owner.email];
                
                if (owea.size() > 0) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                } else {
                    message.setSenderDisplayName(campaigns.LunchAndLearnEvent__r.Owner.name);
                }
                
                
                message.setTargetObjectId(targetObjectId);
                message.setSaveAsActivity(true);
                messages.add(message);
                System.debug('@@#' + message);
                campaigns.Mail_Send__c = true;
                
                
            }
        }
        System.debug('lstAttachmentstoinsert' + lstAttachmentstoinsert);
        //Inserting the attachments on Lead /contact
        if (lstAttachmentstoinsert.size() > 0) {
            insert lstAttachmentstoinsert;
        }
        // for mapping the attachment to contact
        map < id, list < id >> ContactAttachmentMap = new map < id, list < id >> ();
        for (attachment attachedItem: lstAttachmentstoinsert) {
            if (ContactAttachmentMap.containsKey(attachedItem.ParentId)) {
                list < id > attachedItems = ContactAttachmentMap.get(attachedItem.ParentId);
                attachedItems.add(attachedItem.id);
                ContactAttachmentMap.put(attachedItem.ParentId, attachedItems);
            } else {
                ContactAttachmentMap.put(attachedItem.ParentId, new List < Id > {
                    attachedItem.id
                        });
            }
        }
        //
        for (Messaging.SingleEmailMessage SEM: messages) {
            SEM.setEntityAttachments(ContactAttachmentMap.get(SEM.targetobjectid));
        }
        
        
        try {
            //throw new LunchandLearnException('Test  L&L Email Batch Exception');
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            for(Messaging.SendEmailResult r : results) {
                if(r.isSuccess()==false) {
                    String[] adminMailIds = LunchandLearnUtils.GetMetadataValue('Admin_Notification__c').split(',');
                    Messaging.SingleEmailMessage messageToAdmin = new Messaging.SingleEmailMessage();
                    messageToAdmin.toAddresses = adminMailIds;
                    messageToAdmin.subject = 'Dev Org- L&L Email Resend Exception';
                    List<Messaging.SendEmailError> errorList = r.getErrors();
                    String errorEmailHtmlBody = '';
                    for(Messaging.SendEmailError err:errorList){
                        errorEmailHtmlBody += err.getMessage() + ', Status Code: '+err.getStatusCode() + ', TargetObjectId: '+  err.getTargetObjectId();
                        errorEmailHtmlBody += '</br>';
                    }
                    messageToAdmin.htmlbody = errorEmailHtmlBody;
                    
                    Messaging.SingleEmailMessage[] adminMessages = new List < Messaging.SingleEmailMessage > {
                        messageToAdmin
                            };
                                Messaging.SendEmailResult[] adminEmailResults = Messaging.sendEmail(adminMessages);
                }
            }
        } catch (exception e) {
            system.debug('error--' + e.getMessage());
            set < id > eventIDs = new set < id > ();
            for (Event_Attendee__c campMember: llist) {
                if (campMember.email__c != null)
                    eventIDs.add(campMember.LunchAndLearnEvent__c);
            }
            String[] adminMailIds = LunchandLearnUtils.GetMetadataValue('Admin_Notification__c').split(',');
            Messaging.SingleEmailMessage messageToAdmin = new Messaging.SingleEmailMessage();
            messageToAdmin.toAddresses = adminMailIds; //'joe@thehunleygroup.com' , 'nkallingal@thehunleygroup.com';
            messageToAdmin.subject = 'Inpro Org- L&L Email Batch Exception';
            messageToAdmin.htmlbody = e.getMessage() + '<br/><br/>L&L Event affected' + eventIDs;
            
            Messaging.SingleEmailMessage[] adminMessages = new List < Messaging.SingleEmailMessage > {
                messageToAdmin
                    };
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(adminMessages);
        }
        system.debug('updates' + llist);
        update llist;
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}