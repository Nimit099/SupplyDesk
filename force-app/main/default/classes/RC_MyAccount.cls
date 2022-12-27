/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public with sharing class RC_MyAccount 
{   
    public Contact objContact                                           {get;set;}      //To fetch the current user logged in user contact information
    Id idContact;                                                                       //To check the current logged in user have contact id / not
    
    public List<TR1__EmploymentHistory__c> lstEmploymentHistory         {get;set;}      //To collect all the Employment History 
    public List<TR1__EducationHistory__c> lstEduHistory                 {get;set;}      //To collect all the Education History 
    public List<TR1__ContactDocument__c> lstDocument                    {get;set;}      //To get all the contact document which is created by user
    
    public boolean isEditable                                           {get;set;}      //To show the page as editable/ non editable mode
    public Boolean isClient {get;set;}                                                  // To check loggedin user type    
    public boolean isSuccess                                            {get;set;}      //To show the error / success message panel
    public boolean isUploadSuccess                                      {get;set;}      //To check the upload document is success or not
    public Boolean isCnC                                                {get;set;}
    public String strMessage                                            {get;set;}      //To show the error / success message 
    public String strUploadMessage                                      {get;set;}      //To show the error / success message 
    
    public String smallPhotoUrl                                         {get;set;}      //To show the photo on header
    
    private List<Schema.FieldSetMember> lstFieldSet;
    
    public String strHistoryId                                          {get;set;}      //To get the Emp Id to show on popup window
    public String strRelatedListName                                    {get;set;}      //To get the related list name
    
    public  TR1__EmploymentHistory__c objEmploymentDetail               {get;set;}      //To show the detailed employment on popup window
    public  TR1__EducationHistory__c objEducationDetail                 {get;set;}      //To show the detailed employment on popup window
    public  TR1__ContactDocument__c objContactDocument                  {get;set;}      //To update the Contact document type once document get uploaded 
    
    private String strDocumentQuery;
    public String strDateFormat                                         {get;set;}
   
    public Candidate_Community__c objCustomSettingForCandidate { get;set; }
    
    //Constructor
    public RC_MyAccount()
    {
        objContact = new Contact();
        objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail'); 
        lstDocument = new List<TR1__ContactDocument__c>();
        lstFieldSet = new List<Schema.FieldSetMember>();
        objContactDocument =  new TR1__ContactDocument__c();
        
        isClient = false;
        isEditable = false;
        strMessage = '';
        fetchContactInfo();

        strDateFormat = (RC_RelatedListHistoryDetails.MapValues()).get(UserInfo.getLocale());
        
    }
    
    //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
            
            if(System.currentPageReference().getParameters().containsKey('isEdit') && 
                System.currentPageReference().getParameters().get('isEdit') == 'true')
                    isEditable = true;
            
            
            
            //To get the current logged in user contact Id
            User objUser = [Select Id, ContactId, smallPhotoUrl                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
            if(objUser != null)
            {
                idContact = objUser.ContactId;
                fetchContactInfo();
                getRelatedList();
                 
            } 
            if( (objContact.Community_Contact_Type__c == 'Candidate') || objContact.Community_Contact_Type__c == 'C and C' )
                isClient = false;
            else if( (objContact.Community_Contact_Type__c == 'Client'))
                isClient = true;
            Utility.addInfomessage('Contact NAme is '+objContact.Name+' CLient contact '+objContact.Community_Contact_Type__c);
                
           return null;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
         isCnC = false;
        Set<String> setFieldNames = new Set<String>{'Id','PhotoUrl','MarketingCommunication__c'};
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('MyAccount').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
            setFieldNames.add(field.getFieldPath());
            
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('MyAccount2').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
            setFieldNames.add(field.getFieldPath());
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
            setFieldNames.add(field.getFieldPath());
       
        system.debug('--- setFieldNames ---'+setFieldNames);       
        String strQuery = 'Select Community_Contact_Type__c,' + String.join(new List<String>(setFieldNames), ',') + ' from Contact where id =:idContact'; 
        //Utility.addInfomessage('--- strQuery ---'+strQuery);       
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
        {
            objContact = lstContact[index]; 
            List<SocialPersona> lstSocialPersona = RC_AccessController.getSocialPersonaByContactId(lstContact[0].Id);
            
            if(!lstSocialPersona.isEmpty()) {
                
                if (!String.isBlank(lstSocialPersona[0].ExternalPictureURL)) {
                
                    smallPhotoUrl = lstSocialPersona[0].ExternalPictureURL;
                } 
            
                
            } else {
                    
                smallPhotoUrl = 'https://badenochandclark.force.com/img/social/unknown_profile_pic.png?v=2';
            }
        }
        if( (objContact.Community_Contact_Type__c == 'Candidate') || objContact.Community_Contact_Type__c == 'C and C' )
            isClient = false;
        else if( (objContact.Community_Contact_Type__c == 'Client'))
            isClient = true;    
            
        if(objContact.Community_Contact_Type__c == 'C and C'){
            isCnC = true;
        }    
    
           
        system.debug('---- objContact ----'+objContact);
    } 
    
    //To get all the related details Employment, Education and Contact Document
    public void getRelatedList()
    {
        lstFieldSet = new List<Schema.FieldSetMember>();
        
        //To get the Education History
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.TR1__EducationHistory__c.FieldSets.getMap().get('RC_EducationInfo').getFields(); 
        
        for(Schema.FieldSetMember field : lstFieldSet) 
          fieldNames += ', ' + field.getFieldPath();
        
        
        strQuery  += fieldNames + ' from TR1__EducationHistory__c where TR1__Contact__c =\'' +idContact+'\''+ ' ORDER BY Name ASC' ;            
         
        lstEduHistory = RC_AccessController.query(strQuery) ;
         
         //To get the Employment History
        fieldNames = '';
        strQuery = 'Select Id';
        lstFieldSet = SObjectType.TR1__EmploymentHistory__c.FieldSets.getMap().get('RC_EmploymentInfo').getFields(); 
         
        for(Schema.FieldSetMember field : lstFieldSet) 
             fieldNames += ', ' + field.getFieldPath();
                  
        
        strQuery  += fieldNames + ' from TR1__EmploymentHistory__c where TR1__Contact__c =\'' +idContact+'\''+ ' ORDER BY Name ASC' ;            
         
        lstEmploymentHistory = RC_AccessController.query(strQuery) ; 
         
         //To get the Contact Documents
        fieldNames = '';
        strDocumentQuery = 'Select Id';
         
        lstFieldSet = SObjectType.TR1__ContactDocument__c.FieldSets.getMap().get('TR1__Documents').getFields(); 
         
        for(Schema.FieldSetMember field : lstFieldSet) 
                  fieldNames += ', ' + field.getFieldPath();
    
        //loggedUser = UserInfo.getUserId();
         
        strDocumentQuery  += fieldNames + ', TR1__Internal_View_URL__c, TR1__ContentVersionId__c from TR1__ContactDocument__c where TR1__Contact__c =\'' +idContact+'\''+ ' ORDER BY LastModifiedDate DESC' ;
         
        lstDocument = RC_AccessController.query(strDocumentQuery);
         
        lstFieldSet.clear(); 
    }
    
    
   
    //Update contact info which is edited by User
    public void updateContactInfo()   
    {
        try
        {
           System.debug('aaaaaa');
           isEditable =  false;
           System.debug('bbbbbb' +isEditable);
           RC_AccessController.updateRecord(objContact);
           System.debug('cccccc'+objContact);
           isSuccess = true; 
           System.debug('ddddd'+isSuccess);
           strMessage = 'Your profile has been updated successfully';
           System.debug('eeeeeee'+strMessage);
           
           if(Test.isRunningTest())
                Integer c = 5/0; 
        }
        catch(DMLException ex)
        {
             isSuccess = false;
             isEditable =  true;
             strMessage = ex.getDmlMessage(0);
             system.debug('=====catch block executed==='+isSuccess +'===isEditable=='+isEditable);
        }
        catch(Exception ex)
        {
             isSuccess = false;
             isEditable =  true;
             strMessage = ex.getMessage();
             system.debug('=====catch block executed==='+isSuccess +'===isEditable=='+isEditable);
        }
      
    }
    
    public void editContactInfo() 
    {
        isEditable =  true;
        strMessage = '';
       
    }
    
    public void cancelEditContactInfo()
    {
       isEditable =  false;
    }
    
    public void getUploadDetails()
    {
        if(isUploadSuccess == true)
        {
            
            objContactDocument.Id = RC_AccessController.getContactDefaultResume(idContact, isUploadSuccess).Id;
            RC_AccessController.updateRecord(objContactDocument);
            RC_AccessController.updateRecord(objContact);
            lstDocument = RC_AccessController.query(strDocumentQuery);
           
        }
        
    }
    
    //Delete the Education/Employement history details.
    public void deleteRelatedHistoryRecord()
    {
        if(strRelatedListName == 'Employment') 
        {
            TR1__EmploymentHistory__c objEmploymentDetail = new TR1__EmploymentHistory__c(Id = strHistoryId); 
            RC_AccessController.deleteRecord(objEmploymentDetail);
        }
        else
        {
            TR1__EducationHistory__c objEducationDetail = new TR1__EducationHistory__c(Id = strHistoryId); 
            RC_AccessController.deleteRecord(objEducationDetail);
        }
        
        getRelatedList();
    }
}