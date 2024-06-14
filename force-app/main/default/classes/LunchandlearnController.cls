/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:   LunchandLeanControllerTest
* ==========================================================================
* Purpose:      This is the controller class for LandLSiteHomePage VF. 
*				
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/
public  class LunchandlearnController {
    
    public String courseId { get; set; }
    public string enroll { get; set; }
    public Boolean enrollMe { get; set; }
    public String courseName { get; set; }
    public String Provider_Number { get; set; }
    public string Provider_Name {get;set;}
    public String firstName { get; set; }
    public String lastName { get; set; }
    public string Is_AIA_Member { get; set; }
    public string AIA_Member_Number {get;set;}
    public string GBCI_Number {get;set;}
    public string contactEmail {get;set;}
    public boolean displayPopup {get; set;}    
    public string todayDate {get;set;}
    public id AccountIdx {get;set;}
    public string CompanyName {get;set;}
    public boolean statusbool {get;set;}
    public  string IDCEC_Number{get;set;} 
    public LunchAndLearnEvent__c correspondingEvents{get; set;}
    public string AIA {get;set;}
    public string IDCEC {get;set;}
    public string GBCI {get;set;}
    
    public String Provider_Number_AIA { get; set; }
    public String Provider_Number_IDCEC { get; set; }
    public String Provider_Number_GBCI { get; set; }
    
    public String checkMark { get; set; }
    public String educationLogo { get; set; }
    public String companyLogo { get; set; }
    
    public String instructor { get; set; }
    public String instructorEmail { get; set; }
    
    boolean isPopUpOPen=false;
    
    public String optIn{ get; set; }
    public boolean optInLandL{ get; set; }
    public string tooltipText {get;set;}
    
    public LunchandlearnController(){
    }
    public  void selectAction() {
        contactEmail = Apexpages.currentPage().getParameters().get('Email');
        firstName=Apexpages.currentPage().getParameters().get('firstname');
        lastName=Apexpages.currentPage().getParameters().get('lastname');
        AIA_Member_Number=Apexpages.currentPage().getParameters().get('NumName');
        GBCI_Number=Apexpages.currentPage().getParameters().get('GBCINumber');
        System.debug('GBCI_Number'+GBCI_Number);
        Is_AIA_Member=Apexpages.currentPage().getParameters().get('AIAName');
        CompanyName=Apexpages.currentPage().getParameters().get('companyName');
        enroll= Apexpages.currentPage().getParameters().get('Enrollme');
        System.debug('enroll'+enroll);
        
        CreateNewContact();
        
        
    }
    
    public   void CreateNewContact () {
        
        
        contactEmail = Apexpages.currentPage().getParameters().get('Email');
        system.debug('contactEmail-----'+contactEmail);
        firstName=Apexpages.currentPage().getParameters().get('firstname');
        lastName=Apexpages.currentPage().getParameters().get('lastname');
        AIA_Member_Number=Apexpages.currentPage().getParameters().get('NumName');
        GBCI_Number=Apexpages.currentPage().getParameters().get('GBCINumber');
        IDCEC_Number=Apexpages.currentPage().getParameters().get('IDCECNumber');
        system.debug('GBCI_Number---->'+GBCI_Number);
        Is_AIA_Member=Apexpages.currentPage().getParameters().get('AIAName');
        CompanyName=Apexpages.currentPage().getParameters().get('companyName');
        system.debug('CompanyName---->'+CompanyName);
        string  ZIPPostal=Apexpages.currentPage().getParameters().get('ZIPPostal');
        System.debug('Is_AIA_Member'+Is_AIA_Member);
        enroll= Apexpages.currentPage().getParameters().get('Enrollme');
        System.debug('enroll'+enroll);
        if(enroll=='true')
            enrollMe =true;
        else
            enrollMe=false;
        optIn=Apexpages.currentPage().getParameters().get('lOptin');
        System.debug('enroll'+enroll);
        if(optIn=='true')
            optInLandL =true;
        else
            optInLandL=false;
        string fullname=firstName+' '+lastName;
        contact newContact = new contact();
        Lead newLead= new Lead();
        List<contact> existingContacts = new List <contact>();
        List<Lead> existngLeads = new List <Lead>();
        List<Event_Attendee__c> existingMembers = new List<Event_Attendee__c>();
        List<Event_Attendee__c> existingLeadMembers = new  List<Event_Attendee__c>();
        string recId =ApexPages.currentPage().getParameters().get('Id');
        boolean isMember = false;
        boolean isExistingContact = false;
        LunchAndLearnEvent__c correspondingEvent= new LunchAndLearnEvent__c() ;
        Course__c correspondingCampaign= new Course__c() ;
        correspondingEvent=[SELECT Id, Owner.name,Owner.email,Course_Name__c	,EndDateTime__c,  Location__c,Owner.title,Owner.Phone,OwnerId  FROM LunchAndLearnEvent__c where id= :recId];
        system.debug('correspondingEvent.Course_Name__c	'+correspondingEvent.Course_Name__c	);
        correspondingCampaign=[SELECT id FROM Course__c where id = :correspondingEvent.Course_Name__c	];
        
        
        
        
        if(AIA_Member_Number!=null && AIA_Member_Number!='')
        {
            existingContacts=[SELECT id,email,AIA_Member_Number__c FROM Contact where  (AIA_Member_Number__c =:AIA_Member_Number  and AIA_Member_Number__c!=null) ];
            
        }
        if(existingContacts.size()==0 || existingContacts==null)
        {
            existingContacts=[SELECT id,email FROM Contact where (email=: contactEmail and email!=null)];
            
        }
        if(existingContacts.size()==0 || existingContacts==null)
        {
            if(GBCI_Number!=null && GBCI_Number!='')
                existingContacts=[SELECT id,email,GBCI_Number__c    FROM Contact where  (GBCI_Number__c =:GBCI_Number  and GBCI_Number__c!=null) ];
            
        }
        if(existingContacts.size()==0 || existingContacts==null)
        {
            if(IDCEC_Number!=null && IDCEC_Number!='')
                existingContacts=[SELECT id,email,IDCEC_Number__c    FROM Contact where  (IDCEC_Number__c =:IDCEC_Number  and IDCEC_Number__c!=null) ];
        }
        
        
        
        if(AIA_Member_Number!=null && AIA_Member_Number!='')
        {
            existngLeads=[SELECT id,email,Company FROM Lead where (AIA_Member_Number__c =:AIA_Member_Number  and AIA_Member_Number__c!=null)];
        }
        
        if((existngLeads.size()==0 || existngLeads==null) )
        {
            existngLeads=[SELECT id,email,Company FROM Lead where (email=: contactEmail and email!=null) ];
            
        }
        
        
        system.debug('existngLeads'+existngLeads);
        system.debug('@@@CompanyName : '+CompanyName+' existingContacts : '+existingContacts);
        if((CompanyName == null || CompanyName == '' ) && (existingContacts==null || existingContacts.size()==0 )&& (AccountIdx!=null || AccountIdx!='')&& (existngLeads.size()==0 || existngLeads==null))
        {
            system.debug('enters newContactObj');
            system.debug('AccountIdx'+AccountIdx);
            
            newContact.FirstName = firstName ;
            newContact.LastName = lastName ;
            newContact.Is_AIA_Member__c= Is_AIA_Member;
            newContact.GBCI_Number__c = GBCI_Number;
            newContact.IDCEC_Number__c=IDCEC_Number;
            newContact.AIA_Member_Number__c= AIA_Member_Number;
            newContact.Email= contactEmail;
            newContact.AccountId=AccountIdx;
            newContact.Email_Opt_In__c=optInLandL;
            insert newContact;
            system.debug('ddd'+newContact);
            system.debug('ContactEmail'+contactEmail);
            if(contactEmail!=null && contactEmail!='')
            {
                existingMembers=[SELECT Id, Contact__c, LunchAndLearnEvent__c,Course__c FROM Event_Attendee__c	 where (Email__c=:contactEmail or Contact__c = : newContact.Id )AND Course__c= :correspondingCampaign.Id  ];
                
            }
            else{
                existingMembers=[SELECT Id, Contact__c,LunchAndLearnEvent__c, Course__c FROM Event_Attendee__c where Contact__c = : newContact.Id AND Course__c= :correspondingCampaign.Id  ];
            }  
            
            if(existingMembers!=null && existingMembers.size()>0)
            {  
                isMember = true;
                existingMembers[0].LunchAndLearnEvent__c=correspondingEvent.Id; 
                existingMembers[0].Created_from_Site__c =true;
                
            }
            
            if(!isMember)//if not a member add it 
            {
                createCampaignMember(newContact.Id,correspondingCampaign.Id,correspondingEvent.Id);
                
            }
        }
        
        system.debug('GBCI_Number'+GBCI_Number);
        system.debug('IDCEC_Number'+IDCEC_Number);
        // if there is no Lead and no contact - insert Lead And if contact exist update existing contact
        
        if((existngLeads.size()==0 ||existngLeads==null ) )
        { 
            if(existingContacts!=null && existingContacts.size()>0) 
            {  system.debug('existingContact found@@@@@@');
             //There is existing contact So update the contact
             //Creating New contact or updating The contact
             if(contactEmail!=null && contactEmail!='')
             {
                 newContact.Id= existingContacts[0].id;
                 newContact.FirstName = firstName ;
                 newContact.LastName = lastName ;
                 newContact.Is_AIA_Member__c= Is_AIA_Member;
                 if(AIA_Member_Number != ''  || String.isNotEmpty(AIA_Member_Number) || String.isNotBlank(AIA_Member_Number) )
                     newContact.AIA_Member_Number__c= AIA_Member_Number;
                 if(GBCI_Number != '' ||  String.isNotEmpty(GBCI_Number) || String.isNotBlank(GBCI_Number) )
                     newContact.GBCI_Number__c = GBCI_Number;
                 if(IDCEC_Number != ''  || String.isNotEmpty(IDCEC_Number) || String.isNotBlank(IDCEC_Number) )
                     newContact.IDCEC_Number__c=IDCEC_Number;
                 newContact.Email= contactEmail;
                 newContact.Email_Opt_In__c=optInLandL;
                 newContact.AccountId=AccountIdx;
                 isExistingContact=true;
                 //contact exists in campaignMember
                 if(contactEmail!=null && contactEmail!='')
                 {
                     existingMembers=[SELECT Id, Contact__c, LunchAndLearnEvent__c,Course__c FROM Event_Attendee__c where (Email__c=:contactEmail or Contact__c = : newContact.Id) AND Course__c= :correspondingCampaign.Id  ];
                     
                 }
                 else{
                     existingMembers=[SELECT Id, Contact__c,LunchAndLearnEvent__c, Course__c FROM Event_Attendee__c where Contact__c = : newContact.Id AND Course__c= :correspondingCampaign.Id  ];
                 }  
                 
                 if(existingMembers!=null && existingMembers.size()>0)
                 {  
                     isMember = true;
                     existingMembers[0].LunchAndLearnEvent__c=correspondingEvent.Id;
                     existingMembers[0].Created_from_Site__c =true;
                 }
                 
                 if(!isMember)//if not a member add it 
                 {
                     createCampaignMember(newContact.Id,correspondingCampaign.Id,correspondingEvent.Id);
                 }
                 
                 system.debug('Existing Contact--'+newContact);
                 update newContact; 
             } 
             
             
             
            }
            else
            {
                //there is no existing contact  and existing Lead so create a Lead
                system.debug('newLead inserted1');
                newLead.FirstName = firstName ;
                newLead.LastName = lastName ;
                newLead.Country='United States';
                newLead.Is_AIA_Member__c= Is_AIA_Member;
                newLead.AIA_Member_Number__c= AIA_Member_Number;
                
                newLead.Email= contactEmail;
                newLead.PostalCode  =ZIPPostal;
                newLead.Email_Opt_In__c=optInLandL;
                if(CompanyName==null||CompanyName=='')
                {
                   
                }
                else
                {
                    
                    newLead.Company=CompanyName;
                    insert newLead;
                    system.debug('newLead inserted'+newLead);
                    if(contactEmail!=null && contactEmail!='')
                    {
                        existingLeadMembers=[SELECT Id, Lead__c, Course__c ,LunchAndLearnEvent__c FROM Event_Attendee__c where  (Email__c = : contactEmail or Lead__c = : newLead.Id) AND Course__c= :correspondingCampaign.Id  ];
                    }
                    else{  existingLeadMembers=[SELECT Id, Lead__c, Course__c,LunchAndLearnEvent__c FROM Event_Attendee__c where  Lead__c = : newLead.Id AND Course__c= :correspondingCampaign.Id  ];
                        }
                    
                    if(existingLeadMembers!=null && existingLeadMembers.size()>0)
                    {  
                        isMember = true;
                        existingLeadMembers[0].LunchAndLearnEvent__c=correspondingEvent.Id;
                        existingLeadMembers[0].Created_from_Site__c =true;
                        
                    }
                    if(!isMember)//if not a member add it 
                    {
                        createCampaignLeadMember(newLead.Id,correspondingCampaign.Id,correspondingEvent.Id);// creating Campaign Member
                    }
                    
                    
                }
                
                
            }
        }
        //
        // if the lead already exist - checking if contact is present or not. If present update contact , if not present update lead 
        else if((existngLeads.size()>0 || existngLeads!=null))
        {
            if(existingContacts!=null && existingContacts.size()>0) 
            {
                existingMembers=[SELECT Id, Contact__c,Lead__c, LunchAndLearnEvent__c,Course__c FROM Event_Attendee__c where Email__c=:contactEmail];
                if(existingMembers.size()>0 && existingMembers[0].Contact__c!=null && existingMembers[0].Lead__c==null )
                {
                    if(contactEmail!=null && contactEmail!='')
                    {
                        newContact.Id= existingContacts[0].id;
                        newContact.FirstName = firstName ;
                        newContact.LastName = lastName ;
                        
                        newContact.Is_AIA_Member__c= Is_AIA_Member;
                        if(AIA_Member_Number != ''  || String.isNotEmpty(IDCEC_Number) || String.isNotBlank(AIA_Member_Number) )
                            newContact.AIA_Member_Number__c= AIA_Member_Number;
                        if(GBCI_Number != ''  || String.isNotEmpty(GBCI_Number) || String.isNotBlank(GBCI_Number) )
                            newContact.GBCI_Number__c = GBCI_Number;
                        if(IDCEC_Number != ''  || String.isNotEmpty(IDCEC_Number) || String.isNotBlank(IDCEC_Number) )
                            newContact.IDCEC_Number__c=IDCEC_Number;
                        
                        newContact.Email= contactEmail;
                        newContact.AccountId=AccountIdx;
                        newContact.Email_Opt_In__c=optInLandL;
                        if(contactEmail!=null && contactEmail!='')
                        {
                            system.debug('contactEmail'+contactEmail);
                            existingMembers=[SELECT Id, Contact__c, LunchAndLearnEvent__c,Course__c FROM Event_Attendee__c where (Email__c=:contactEmail or Contact__c = : newContact.Id) AND Course__c= :correspondingCampaign.Id  ];
                            system.debug('correspondingCampaign.Id'+correspondingCampaign.Id);
                        }
                        else{
                            existingMembers=[SELECT Id, Contact__c,LunchAndLearnEvent__c, Course__c FROM Event_Attendee__c where Contact__c = : newContact.Id AND Course__c= :correspondingCampaign.Id  ];
                        } 
                        system.debug('existingMembers'+existingMembers);
                        
                        if(existingMembers!=null && existingMembers.size()>0)
                        {  
                            isMember = true;
                            existingMembers[0]. LunchAndLearnEvent__c=correspondingEvent.Id;
                            existingMembers[0].Created_from_Site__c =true;
                            system.debug('netered');
                        }
                        if(!isMember)//if not a member add it 
                        {
                            createCampaignMember(newContact.Id,correspondingCampaign.Id,correspondingEvent.Id);
                            system.debug('neteredvvv');
                        }
                        
                        system.debug('Existing Contact--'+newContact);
                        update newContact; 
                    }
                }
                
                else if(existingMembers.size()>0 && existingMembers[0].Lead__c!=null )
                {
                    if(contactEmail!=null && contactEmail!='')
                    {
                        newLead.FirstName = firstName ;
                        newLead.LastName = lastName ;
                        newLead.Is_AIA_Member__c= Is_AIA_Member;
                        newLead.AIA_Member_Number__c= AIA_Member_Number;
                        newLead.Email= contactEmail;
                        newLead.id=existngLeads[0].id;
                        newLead.PostalCode  =ZIPPostal;
                        newLead.Email_Opt_In__c=optInLandL;
                        update newLead;
                        system.debug('newLead'+newLead);
                        if(contactEmail!=null && contactEmail!='')
                        {
                            existingLeadMembers=[SELECT Id, Lead__c, Course__c,LunchAndLearnEvent__c FROM Event_Attendee__c where  (Email__c = : contactEmail or Lead__c = : newLead.Id )AND Course__c= :correspondingCampaign.Id  ];
                            
                        }
                        else{
                            existingLeadMembers=[SELECT Id, Lead__c,LunchAndLearnEvent__c ,Course__c FROM Event_Attendee__c where  Lead__c = : newLead.Id AND Course__c= :correspondingCampaign.Id  ];
                        }
                        
                        
                        if(existingLeadMembers!=null && existingLeadMembers.size()>0)
                        {  
                            isMember = true;
                            existingLeadMembers[0].LunchAndLearnEvent__c=correspondingEvent.Id;
                            existingLeadMembers[0].Created_from_Site__c =true;
                            // existingLeadMembers[0].Email_Opt_In__c=false;
                        }
                        if(!isMember)//if not a member add it 
                        {
                            createCampaignLeadMember(newLead.Id,correspondingCampaign.Id,correspondingEvent.Id);
                        }
                        
                    }
                }
                
                else if(existingMembers.size()==0 ||existingMembers!=null)
                {
                    if(contactEmail!=null && contactEmail!='')
                    {
                        newContact.Id= existingContacts[0].id;
                        newContact.FirstName = firstName ;
                        newContact.LastName = lastName ;
                        newContact.Is_AIA_Member__c= Is_AIA_Member;
                        if(AIA_Member_Number != ''  || String.isNotEmpty(AIA_Member_Number) || String.isNotBlank(AIA_Member_Number) )
                            newContact.AIA_Member_Number__c= AIA_Member_Number;
                        if(GBCI_Number != ''  || String.isNotEmpty(GBCI_Number) || String.isNotBlank(GBCI_Number) )
                            newContact.GBCI_Number__c = GBCI_Number;
                        if(IDCEC_Number != ''  || String.isNotEmpty(IDCEC_Number) || String.isNotBlank(IDCEC_Number) )
                            newContact.IDCEC_Number__c=IDCEC_Number;
                        newContact.Email= contactEmail;
                        newContact.AccountId=AccountIdx;
                        newContact.Email_Opt_In__c=optInLandL;
                        if(contactEmail!=null && contactEmail!='')
                        {
                            system.debug('contactEmail'+contactEmail);
                            existingMembers=[SELECT Id, Contact__c, LunchAndLearnEvent__c,Course__c FROM Event_Attendee__c where (Email__c=:contactEmail or Contact__c = : newContact.Id) AND Course__c= :correspondingCampaign.Id  ];
                            system.debug('correspondingCampaign.Id'+correspondingCampaign.Id);
                        }
                        else{
                            existingMembers=[SELECT Id, Contact__c,LunchAndLearnEvent__c, Course__c FROM Event_Attendee__c where Contact__c = : newContact.Id AND Course__c= :correspondingCampaign.Id  ];
                        } 
                        system.debug('existingMembers'+existingMembers);
                        
                        if(existingMembers!=null && existingMembers.size()>0)
                        {  
                            isMember = true;
                            existingMembers[0]. LunchAndLearnEvent__c=correspondingEvent.Id;
                            existingMembers[0].Created_from_Site__c =true;
                            
                        }
                        if(!isMember)//if not a member add it 
                        {
                            createCampaignMember(newContact.Id,correspondingCampaign.Id,correspondingEvent.Id);
                            
                        }
                        
                        update newContact; 
                    }
                }
            }
            else{
                if(contactEmail!=null && contactEmail!='')
                {
                    newLead.FirstName = firstName ;
                    newLead.LastName = lastName ;
                    newLead.Is_AIA_Member__c= Is_AIA_Member;
                    newLead.AIA_Member_Number__c= AIA_Member_Number;
                    newLead.Email= contactEmail;
                    newLead.id=existngLeads[0].id;
                    newLead.PostalCode=ZIPPostal;
                    newLead.Email_Opt_In__c=optInLandL;
                    system.debug('@@newLead'+newLead);
                    update newLead;
                    system.debug('@@newLead'+newLead);
                    if(contactEmail!=null && contactEmail!='')
                    {
                        existingLeadMembers=[SELECT Id, Lead__c, Course__c,LunchAndLearnEvent__c FROM Event_Attendee__c where  (Email__c = : contactEmail or Lead__c = : newLead.Id )AND Course__c= :correspondingCampaign.Id  ];
                    }
                    else{
                        existingLeadMembers=[SELECT Id, Lead__c,LunchAndLearnEvent__c ,Course__c FROM Event_Attendee__c where  Lead__c = : newLead.Id AND Course__c= :correspondingCampaign.Id  ];
                    }
                    if(existingLeadMembers!=null && existingLeadMembers.size()>0)
                    {  
                        isMember = true;
                        existingLeadMembers[0].LunchAndLearnEvent__c=correspondingEvent.Id;
                        existingLeadMembers[0].Created_from_Site__c =true;
                    }
                    if(!isMember)//if not a member add it 
                    {
                        createCampaignLeadMember(newLead.Id,correspondingCampaign.Id,correspondingEvent.Id);
                    }
                    
                }
            }
        }
        id recordId;
        system.debug('maildd outside');  
        if(newLead.id!=null)
        {
            system.debug('maildd lead');
            system.debug('test112'+recordId);
        }
        else 
        {
            system.debug('maildd');
            if(newContact.id!=null)               
                recordId=  newContact.Id; 
            system.debug(recordId);
        }
        if(existingLeadMembers.size()>0 && existingLeadMembers!=null)
        {
            update existingLeadMembers;
        }
        if(existingMembers.size()>0 && existingMembers!=null)
        {
            update existingMembers;
        }
        
    }
    public  void createCampaignMember(Id contactId , Id campaignId, id eventid) {
        system.debug('Enters create campaign member');
        Event_Attendee__c newMember= new Event_Attendee__c();
        newMember.Contact__c = contactId;
        newMember.Course__c =campaignId;
        newMember.LunchAndLearnEvent__c=eventid;
        newMember.Status__c='Attended';
        newMember.Created_from_Site__c =true;
        newMember.Email_Opt_In__c=false;
        upsert newMember;
        List<AggregateResult> ListCampaign= new   List<AggregateResult>();
        ListCampaign=[SELECT COUNT(Id) FROM Event_Attendee__c where LunchAndLearnEvent__c = : eventid];
        integer count=(Integer) ListCampaign[0].get('expr0');
        system.debug('count'+ListCampaign);
        LunchAndLearnEvent__c correspondingEvent= [select id, Number_Attending__c from LunchAndLearnEvent__c where id = : eventid];
        correspondingEvent.Number_Attending__c=count;
        update correspondingEvent;
        return;
    }
    public  void createCampaignLeadMember(Id LeadID , Id campaignId,Id eventid) {
        system.debug('Enters createCampaignLeadMember');
        Event_Attendee__c newMember= new Event_Attendee__c();
        newMember.Lead__c = LeadID;
        newMember.Course__c =campaignId;
        newMember.LunchAndLearnEvent__c=eventid;
        newMember.Status__C='Attended';
        newMember.Created_from_Site__c =true; 
        newMember.Email_Opt_In__c=false;
        
        upsert newMember;
        List<AggregateResult> ListCampaign= new   List<AggregateResult>();
        ListCampaign=[SELECT COUNT(Id) FROM Event_Attendee__c where LunchAndLearnEvent__c = : eventid];
        system.debug('count'+ListCampaign);
        system.debug('count'+ListCampaign[0].get('expr0'));
        integer count=(Integer) ListCampaign[0].get('expr0');
        LunchAndLearnEvent__c correspondingEvent= [select id, Number_Attending__c from LunchAndLearnEvent__c where id = : eventid];
        correspondingEvent.Number_Attending__c=count;
        update correspondingEvent;
        system.debug('newMember-createCampaignLeadMember '+newMember);
        return;
    }
    public void   pageLoadFunction() {  
        string recId=ApexPages.currentPage().getParameters().get('Id');
        system.debug('recId'+ApexPages.CurrentPage().getparameters().get('id'));
        correspondingEvents= new LunchAndLearnEvent__c() ;
        Course__c correspondingCampaign= new Course__c() ;
        correspondingEvents=[SELECT Id,Course_Name__c,EndDateTime__c,StartDateTime__c,Course_Name__r.Name,
                             Course_Name__r.IDCEC_Course_ID__c,Course_Name__r.USGBC_Course_ID__c,Course_Name__r.Course_Id__c,
                             Related_To__c,Location__c,Presenter_User__c,Presenter_User__r.Name,Presenter_User__r.Email,Is_Ongoing__c	 
                             FROM LunchAndLearnEvent__c where id= :recId];
        correspondingCampaign=[SELECT id,Name,Course_Id__c,Provider_Id__c FROM Course__c where id = :correspondingEvents.Course_Name__c];
        
        instructor=correspondingEvents.Presenter_User__r.Name;
        instructorEmail=correspondingEvents.Presenter_User__r.Email;
        System.debug('correspondingEvents'+correspondingEvents);
        AIA  =correspondingEvents.Course_Name__r.Course_Id__c;
        IDCEC = correspondingEvents.Course_Name__r.IDCEC_Course_ID__c;
        GBCI =  correspondingEvents.Course_Name__r.USGBC_Course_ID__c;
        map<string,string> campaignMap = new map<string,string>();
        
        AccountIdx =correspondingEvents.Related_To__c;
        system.debug(AccountIdx );
        courseId =correspondingCampaign.Course_Id__c;
        courseName =correspondingCampaign.Name;
        //Provider_Number=LunchandLearnUtils.GetMetadataValue('Provider_Number__c');
        Provider_Number=correspondingCampaign.Provider_Id__c;
        
        Provider_Number_AIA=LunchandLearnUtils.GetMetadataValue('Provider_Number_AIA__c');
        Provider_Number_IDCEC=LunchandLearnUtils.GetMetadataValue('Provider_Number_IDCEC__c');
        Provider_Number_GBCI=LunchandLearnUtils.GetMetadataValue('Provider_Number_GBCI__c');
        
        checkMark=LunchandLearnUtils.GetMetadataValue('Checkmark__c');
        educationLogo=LunchandLearnUtils.GetMetadataValue('Education_Logo__c');
        companyLogo=LunchandLearnUtils.GetMetadataValue('Customer_Image_Logo__c');
        
        Provider_Name=LunchandLearnUtils.GetMetadataValue('Provider_Name__c');
        todayDate =system.today().format();
        todayDate=correspondingEvents.StartDateTime__c.month()+'/'+correspondingEvents.StartDateTime__c.day()+'/'+correspondingEvents.StartDateTime__c.year();
        tooltipText=LunchandLearnUtils.GetMetadataValue('L_L_Registration_Page_Tooltip_Text__c');
        //if(correspondingEvents.EndDateTime__c.addhours(1)>system.now())
        if(correspondingEvents.Is_Ongoing__c)
        {
            statusbool=false;
        }
        else
        {
            statusbool=true;
        }
        
        
    }
    public  void closePopup() {       
        displayPopup = false; 
        
    }    
    public  void showPopup() {   
        displayPopup = true; 
        
    }  
    public class DuplicationWrapper {
        boolean isDuplicated = false;
        boolean GBCINumber = false;
        boolean IDCECNumber =false;
    }
    
}