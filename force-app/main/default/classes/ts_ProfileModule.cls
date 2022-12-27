/*******************************************************
* Name          : ts_ProfileModule
* Author        : Krunal
* Create Date   : 26/07/2022
* UsedBy        : Used in community site components
* Description   : ts_ChangePassword, ts_Compilance, ts_ContactUs, ts_MyQualificationDetail, ts_MyQualifications, ts_ProfilePage, ts_Register, ts_ResetPassword, ts_SignIn
* Test Class    : ts_ProfileModuleTest
* Code Coverage : 84% 

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Krunal                      27/07/2022          Change in getcrdata method
2.                  Sakina                      27/07/2022          Change in createuser method :- add if condition ,if email is alredy exist
3.                  Krunal                      08/08/2022          Create forgotSitePassword method for forgot password in community site
4.                  Nitin                       24/08/2022          Method (getcrdata) ==> Changed Query of crList, Added Filter in Query that return if Hiring Manger or Vacany(Job) Owner is Loggedin in Community Site.
5.                  Nitin                       26/08/2022          Method (createuser) ==> rewritted method as per requirments.

*******************************************************/

public without sharing class ts_ProfileModule {

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : Save user data from profile page.
    ***************************************************/
    @AuraEnabled
    public static void saveData(Contact con){
        try {
            User usr = [SELECT Id , ContactId FROM User WHERE Id=:UserInfo.getUserId()];
            if(con.Id == usr.ContactId){
                update con;
            }
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'saveData');
        }
    }

    /***************************************************
    * Author             : Karan            Sakina
    * Created Date       : 26/07/2022     
    * Last Modified Date : 17/08/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : Get user data and show on profile page when profile page is load.
    ***************************************************/
    @AuraEnabled
    public static User getData(){
        try{
            User usr=[ SELECT Id , ContactId , AccountId  , FullPhotoUrl , Name  , Account.Name , Contact.Firstname , Contact.Lastname , Contact.HomePhone , Contact.MobilePhone ,  Contact.Email , Contact.Phone FROM User where Id=:UserInfo.getUserId()];
            return usr;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getData');
            return null;
        }
    }
    
    /***************************************************
    * Author             : Krunal
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : Get CV list for user and show it in profile page.
    ***************************************************/
    @AuraEnabled
    public static List<ContentDocument> getDocsData(){
        try{
            User usr = [SELECT Id,ContactId FROM User WHERE Id=:UserInfo.getUserId()];
            List<ContentDocumentLink> contentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: usr.ContactId];
            Set<Id> conId = new Set<Id>();
            for(ContentDocumentLink con : contentLink){
                conId.add(con.ContentDocumentId);
            }
            List<ContentDocument> contentData = [SELECT Id, Title FROM ContentDocument WHERE Id IN: conId];
            return contentData;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getDocsData');
            return null;
        }
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : Change profile photo of user from profile page.
    ***************************************************/
    @AuraEnabled
    public static String saveFile(String userId, String base64Data) { 
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(EncodingUtil.base64Decode(base64Data), 'image/png', 'userImage.png');
            ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(null, userId,  fileUpload);
            return 'Success';
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'saveFile');
            return null;
        }
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : Delete profile photo of user from profile page.
    ***************************************************/
    @AuraEnabled
    public static void deleteFile(String userId) { 
        try{
            ConnectApi.UserProfiles.deletePhoto(null,userId);
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'deleteFile');
        }
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : For save CV which uplaod by user in profile page.
    ***************************************************/
    @AuraEnabled
    public static void saveCV(String parentId, String fileName, String base64Data) { 
        try{

            User usr = [SELECT Id,ContactId FROM User WHERE Id=:UserInfo.getUserId()];

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            contentVersion.PathOnClient = fileName;//File name with extention
            contentVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
            contentVersion.OwnerId = UserInfo.getUserId();//Owner of the file
            contentVersion.Title = fileName;//Name of the file
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
            contentVersion.Description = 'CV Upload From My Account';
            insert contentVersion;

            //After saved the Content Verison, get the ContentDocumentId
            ContentVersion contentData = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id];

            //Insert ContentDocumentLink
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentData.contentDocumentId;//Add ContentDocumentId
            contentDocumentLink.LinkedEntityId = usr.ContactId;//Add attachment parentId
            contentDocumentLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            contentDocumentLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert contentDocumentLink;

        } catch (Exception e) {
            System.debug(e);
            String data = 'getMessagelogin => '+e.getMessage() + 'line no => '+e.getLineNumber();
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'saveCV');
        }

    }

    /***************************************************
    * Author             : 
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_SignIn Component
    * Description        : Use for user login in site
    ***************************************************/
    @AuraEnabled
    public static string doLogin(String username, String password){
        try {


            // List<Site> st = [SELECT Id, Name, Subdomain, UrlPathPrefix, GuestUserId, Status, AdminId, MasterLabel, SiteType, CreatedDate, CreatedById FROM Site WHERE Name = 'Supply_Desk'];
            // SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :st[0].Id];
            // system.debug('site url'+ mySiteDetail.SecureUrl);
            // String startUrl  = mySiteDetail.SecureUrl+'s/';
            // ApexPages.PageReference pageRef = Site.login('180770107588@supplydesk.com', 'Mvclouds@5', startUrl);
            //     if(pageRef != null){
            //         system.debug('pageref'+ pageRef.getUrl());
            //     } 


            String starturl = 'mvcdev-supplydesk.cs110.force.com/s/';
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            if(pageRef != null){
                return pageRef.getUrl();
            } 
            return null;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'doLogin');
            return e.getMessage();
        }
    }


    /***************************************************
    * Author             : Nitin
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/08/2022
    * UsedBy             : ts_Register Component
    * Description        : For Creating Community User 
    ***************************************************/

    @AuraEnabled
    public static string createuser(String contwrapdata , String email){
        try {

            contwrap cont = (contwrap)JSON.deserialize(contwrapdata,contwrap.class);
            LIST<Account> acclst = [SELECT Id, Name, Post_Code__c, URN__c, OwnerId, TR1__Status__c, Client_Status__c, Division__c FROM Account WHERE URN__c =: cont.URNCode LIMIT 1];

            if (acclst.size() == 0) {
                
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { email});  //add other emails here.
                mail.setReplyTo('clare.othman@supplydesk.co.uk');
                mail.setUseSignature(false);
                mail.setSubject('Invalid URN');
                String body =  '<div>'+ 'Hi Client, ';
                body+='<br/>';
                body+='<br/>';
                body+='Thank you for your attempt to register on our portal.  Unfortunately we were unable to identify your school by the URN (Unique Reference Number)  provided.';
                body+='<br/>';
                body+='Please check on this Government website <a href="https://www.get-information-schools.service.gov.uk/">www.get-information-schools.service.gov.uk/</a>';
                body+='<br/>';
                body+='If you can not find URN on this website Please reply to <a href="mailto:clare.othman@supplydesk.co.uk">clare.othman@supplydesk.co.uk</a> with the following:';
                body+='<br/>';
                body+='<br/>';
                body+='<b>Your Name:</b>';
                body+='<br/>';
                body+='<b>School name:</b>';
                body+='<br/>';
                body+='<b>School postcode:</b>';
                body+='<br/>';
                body+='<b>Direct contact number:</b>';
                body+='<br/>';
                body+='<br/>';
                body+='We will be in touch to check details and get you set up as soon as possible.';
                body+='<br/>';
                body+='<br/>';
                body+='Best Regards,';
                body+='<br/>';
                body+='Supply Desk Team';
                body+='</div>';
                
                mail.setHtmlBody(body);
                emails.add(mail);
                Messaging.sendEmail(emails);

                return 'Invalid PostCode';

            } else {
                
                List<Contact> contlst = [SELECT Id, Name, Email FROM Contact WHERE Email =: email];
                List<User> usrlst = [SELECT Id, Name, Email FROM User WHERE Email =: email];
                if (contlst.size() > 0 || usrlst.size() > 0) {
                    return 'Email already Exist';
                } 

                Contact con = new Contact();
                con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client').getRecordTypeId();
                con.LastName = cont.LastName;
                con.FirstName = cont.FirstName;
                con.Email = cont.Email;
                con.Roles__c = cont.Job;
                con.MobilePhone = cont.Mobile;
                con.Phone = cont.Phone;
                con.Job_Title__c=cont.Team;
                con.TR1__Client_Status__c = 'Active';
                con.Division__c = acclst[0].Division__c;
                con.OwnerId = acclst[0].OwnerId;
                con.Enable_Community_User__c = true;
                con.AccountId = acclst[0].Id;
                insert con;
                return 'User Created';
            }
                 
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'createuser');
            return e.getMessage();
        }
    }




    /***************************************************
    * Author             : Ravi Modi
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_Register Component
    * Description        : Dependent Field value
    ***************************************************/
    @AuraEnabled
    public static Map<String, List<String>> getDependentPicklistValues() {

        try {
            Schema.DescribeFieldResult depend = Contact.Roles__c.getDescribe();
            Schema.sObjectField controlToken = depend.getController();
            if (controlToken == null) {
                return new Map<String, List<String>>();
            }
        
            Schema.DescribeFieldResult control = controlToken.getDescribe();
            List<Schema.PicklistEntry> controlEntries;
            if(control.getType() != Schema.DisplayType.Boolean) {
                controlEntries = control.getPicklistValues();
            }
        
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
            for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
                if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                    List<String> base64chars = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                    for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                        Object controlValue  =  (controlEntries == null
                                                        ?   (Object) (index == 1)
                                                        :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                                                );
                        Integer bitIndex = index / 6;
                        if (bitIndex > base64chars.size() - 1) {
                            break;
                        }
                        Integer bitShift = 5 - Math.mod(index, 6);
                        if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                            continue;
                        if (!dependentPicklistValues.containsKey((String) controlValue)) {
                            dependentPicklistValues.put((String) controlValue, new List<String>());
                        }
                        dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                    }
                }
            }
            return dependentPicklistValues;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getDependentPicklistValues');
            return null;
        }
    }

    /***************************************************
    * Author             :
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : In createuser Method
    * Description        :
    ***************************************************/
    public class contwrap {
        @AuraEnabled
        public String FirstName {get;set;}
        @AuraEnabled
        public String LastName {get;set;}
        @AuraEnabled
        public String Email{get;set;}
        @AuraEnabled
        public String Job{get;set;}
        @AuraEnabled
        public String Postcode{get;set;}
        @AuraEnabled
        public String URNCode{get;set;}
        @AuraEnabled
        public String Mobile{get;set;}
        @AuraEnabled
        public String Phone{get;set;}
        @AuraEnabled
        public String Team{get;set;}
    }

 /***************************************************
    * Author             : Sakina
    * Created Date       : 17/08/2022    
    * Last Modified Date : 17/08/2022
    * UsedBy             : ts_ProfilePage Component
    * Description        : 
    ***************************************************/
    public class profilePageWrap {
        @AuraEnabled
        public String photoUrl {get;set;}
        @AuraEnabled
        public Contact con{get;set;}
        @AuraEnabled
        public String schoolPostal{get;set;}
       
    }

    /***************************************************
    * Author             :
    * Created Date       : 26/07/2022
    * Last Modified Date : 27/07/2022
    * UsedBy             : ts_Compilance Component
    * Description        : Compliance Class
    ***************************************************/
    @AuraEnabled 
    public static List<TR1__Closing_Report__c> getcrdata(String userid){
        try {           
            Id loggedInUserId = [SELECT Id, ContactId FROM User where Id =: userid].ContactId;

            List<TR1__Closing_Report__c> crlist = [SELECT id, TR1__Account__c, Hiring_Manager__c, TR1__Job__r.OwnerId, TR1__Person_Placed__r.FirstName, TR1__Person_Placed__r.Group_1_ID_Type_Hidden__c, TR1__Person_Placed__r.Group_2A_ID_Type_Hidden__c,TR1__Person_Placed__r.Group_2B_ID_Type_Hidden__c, 
                                                    TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c, TR1__Person_Placed__r.SET_Checked_Date_Hidden__c , TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c , TR1__Person_Placed__r.Qualification_Verified_Hidden__c FROM TR1__Closing_Report__c 
                                                    WHERE (Hiring_Manager__c =:loggedInUserId OR TR1__Job__r.OwnerId =: userid)];
            return crlist;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getcrdata');
            return null;
        }
    }

    /***************************************************
    * Author             : Mihir Ramoliya
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_Compilance Component
    * Description        : Compliance Download PDF
    ***************************************************/
    @AuraEnabled
    public static string downloadpdf(String recordid){
        try {
            String pdf_url = '/apex/ConfirmationLetterPDF_v2?recordid='+recordid;
            PageReference pdfPage = new PageReference(pdf_url);
            Blob pdfBlob = pdfPage.getContent();
            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
            return base64Pdf;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'downloadpdf');
            return null;
        }
    }

    /***************************************************
    * Author             :
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ChangePassword Component
    * Description        : Change Password Page
    ***************************************************/
    @AuraEnabled
    public static string changepass(String newPassword, String verifyNewPassword, String oldpassword){
        try {
            String strRetURL;
            // Check if user is changing password from email link or from My Profile page
            strRetURL = Site.isPasswordExpired() ? '/s/login' : '/MyAccount';
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
            if(pr == null) {
                String ss = pr.getURL();
                return ss;
            }
            return strRetURL;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'changepass');
            return e.getMessage();
        }
    }

    /***************************************************
    * Author             :
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ResetPassword Component
    * Description        : Reset Password Page
    ***************************************************/
    @AuraEnabled
    public static string resetpass(String newPassword, String usrid){
        try {
            System.setPassword(usrid, newPassword);
            return 'Changed?';
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'resetpass');
            return e.getMessage();
        }
    }

    /***************************************************
    * Author             :
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_ContactUs Component
    * Description        : For ContactUs Page
    ***************************************************/
    @AuraEnabled(cacheable=true)
    public static String sendEmailToController(String Name, String Email, String Subject, String Body) {
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            mail.setSenderDisplayName(Name);
            mail.setHtmlBody(Body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            return 'Success';
        }catch(Exception e){
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'sendEmailToController');
            return e.getMessage();
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualifications Component
    * Description        : Use for get qualification list in qualification component
    ***************************************************/
    @AuraEnabled
    public static List<TR1__Associated_Qualification__c> getQualification(){
        try {
            User usr = [SELECT Id,ContactId FROM User Where Id=:UserInfo.getUserId()];
            List<Schema.FieldSetMember> lstFieldSet = new List<Schema.FieldSetMember>(); 
            Contact con = [SELECT Id FROM Contact WHERE Id =: usr.ContactId]; //Added for test
            List<TR1__Associated_Qualification__c> qualiList = new List<TR1__Associated_Qualification__c>();
            String fieldNames ='';
            String strQuery = 'Select Id'; 
            lstFieldSet = SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get('RC_QualificationInfo').getFields(); 
            for(Schema.FieldSetMember field : lstFieldSet){
                fieldNames += ', ' + field.getFieldPath();
            }
            strQuery  += fieldNames + ' from TR1__Associated_Qualification__c where TR1__Contact__c = \'' + con.Id + '\' ORDER BY Name ASC' ;      
            qualiList = Database.query(strQuery);
            return qualiList;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getQualification');
            return null;
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualificationDetail Component
    * Description        : get user contact id
    ***************************************************/
    @AuraEnabled
    public static String getContactId(){
        try{
            User u  = [SELECT Id,ContactId from User where Id=:UserInfo.getUserId()];
            if(String.isNotBlank(u.contactId)){
                return u.ContactId;
            }
            else{
                return 'Id null';
            }
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getContactId');
            return null;
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualificationDetail Component
    * Description        : save qualification data
    ***************************************************/
    @AuraEnabled(cacheable=false)
    public static void editQuali(Id conId,String qfname,TR1__Associated_Qualification__c qual){
        try {
            TR1__Associated_Qualification__c qualList = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:conId AND qualificationName__c =: qfname LIMIT 1];
            if(qual.qualificationName__c == 'CV'){
                qualList.Gaps_Explanation__c = qual.Gaps_Explanation__c;
                qualList.CV_Submitted__c = qual.CV_Submitted__c;
                qualList.CV_Received__c = qual.CV_Received__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Right to Work'){
                qualList.Permanent_Right_to_Work_in_UK__c = qual.Permanent_Right_to_Work_in_UK__c;
                qualList.Documents__c = qual.Documents__c;
                qualList.Work_Permit_OR_Visa_Expiry_Date__c = qual.Work_Permit_OR_Visa_Expiry_Date__c;            
            }
            else if(qual.qualificationName__c == 'Teacher Qualification'){
                qualList.NCTL_Number__c = qual.NCTL_Number__c;
                qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
                qualList.Qualification_Type__c = qual.Qualification_Type__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Overseas Police Check'){
                qualList.Overseas_Police_Check__c = qual.Overseas_Police_Check__c;
                qualList.Live_Worked_Overseas_Start_Date__c = qual.Live_Worked_Overseas_Start_Date__c;
                qualList.Live_Worked_Overseas_End_Date__c = qual.Live_Worked_Overseas_End_Date__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Overseas Teacher Qualifications'){
                qualList.NCTL_Number__c = qual.NCTL_Number__c;
                qualList.NARIC_Approved__c = qual.NARIC_Approved__c;
                qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
                qualList.Qualification_Type__c = qual.Qualification_Type__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'ID'){
                qualList.Group_1_ID_Type__c = qual.Group_1_ID_Type__c;
                qualList.Name_Change_Document__c = qual.Name_Change_Document__c;
                qualList.Group_2a_ID_Type__c = qual.Group_2a_ID_Type__c;
                qualList.Group_2b_ID_Type__c = qual.Group_2b_ID_Type__c;            
            }
            else if(qual.qualificationName__c == 'Safeguarding'){
                qualList.Safeguarding_Date_Completed__c = qual.Safeguarding_Date_Completed__c;
            }
            else if(qual.qualificationName__c == 'Emergency Contact'){
                qualList.Relationship_to_You__c = qual.Relationship_to_You__c;
                qualList.Emergency_Contact_Address__c = qual.Emergency_Contact_Address__c;
                qualList.Emergency_Contact_Home_Phone__c = qual.Emergency_Contact_Home_Phone__c;
                qualList.Emergency_Contact_Mobile_Phone__c = qual.Emergency_Contact_Mobile_Phone__c;
                qualList.Emergency_Contact_Work_Phone__c = qual.Emergency_Contact_Work_Phone__c;
                qualList.Emergency_Contact_Name__c = qual.Emergency_Contact_Name__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'DBS'){
                qualList.DBS_Form_Number__c = qual.DBS_Form_Number__c;
                qualList.Update_Service_Status_Check__c = qual.Update_Service_Status_Check__c;
            }
            else if(qual.qualificationName__c == 'Post 16 Qualifications'){
                qualList.SET_Registration_Number__c = qual.SET_Registration_Number__c;
                qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
                qualList.SET_Expiry_Date__c = qual.SET_Expiry_Date__c;
                qualList.QTLS__c = qual.QTLS__c;
                qualList.Qualification_Type__c = qual.Qualification_Type__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Early Years Qualifications'){
                qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
                qualList.Qualification_Type__c = qual.Qualification_Type__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Support Qualifications'){
                qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
                qualList.Qualification_Type__c = qual.Qualification_Type__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'International'){
                qualList.Seeking_International_Position__c = qual.Seeking_International_Position__c;
                qualList.Choice_of_Country__c = qual.Choice_of_Country__c;
            }
            else if(qual.qualificationName__c == 'Barred List'){
                qualList.Barred_Check_URL__c = qual.Barred_Check_URL__c;
                qualList.Barred_List_Results__c = qual.Barred_List_Results__c;
                qualList.EWC_Registration_Checked_Date__c = qual.EWC_Registration_Checked_Date__c;
                qualList.EWC__c = qual.EWC__c;
                qualList.Barred_List_Date_Checked__c = qual.Barred_List_Date_Checked__c;
                qualList.Barred_List_Expiry_Date_New__c = qual.Barred_List_Expiry_Date_New__c;
            }
            else if(qual.qualificationName__c == 'References'){
                qualList.Reference_Sent_Date__c = qual.Reference_Sent_Date__c;
                qualList.Reference_1_Text_Name__c = qual.Reference_1_Text_Name__c;
                qualList.Reference_Received_Date__c = qual.Reference_Received_Date__c;
                qualList.Reference_1_Contact_Details__c = qual.Reference_1_Contact_Details__c;
                qualList.Reference_1_Email__c = qual.Reference_1_Email__c;
                qualList.Reference_1_Date_Range_End__c = qual.Reference_1_Date_Range_End__c;
                qualList.Reference_1_Type__c = qual.Reference_1_Type__c;
                qualList.Reference_1_Date_Range__c = qual.Reference_1_Date_Range__c;
                qualList.Reference_1_Received__c = qual.Reference_1_Received__c;
                qualList.Reference_1_Rating__c = qual.Reference_1_Rating__c;
                qualList.Reference_Sent_Date__c = qual.Reference_Sent_Date__c;
                qualList.Reference_2_Name__c = qual.Reference_2_Name__c;
                qualList.Reference_2_Received_Date__c = qual.Reference_2_Received_Date__c;
                qualList.Reference_2_Contact_Details__c = qual.Reference_2_Contact_Details__c;
                qualList.Reference_2_Date_Rage__c = qual.Reference_2_Date_Rage__c;
                qualList.Reference_2_Text_Name__c = qual.Reference_2_Text_Name__c;
                qualList.Reference_2_Email__c = qual.Reference_2_Email__c;
                qualList.Reference_2_Sent_Date__c = qual.Reference_2_Sent_Date__c;
                qualList.Reference_2_Date_Range_End__c = qual.Reference_2_Date_Range_End__c;
                qualList.Reference_2_Type__c = qual.Reference_2_Type__c;
                qualList.Reference_2_Received__c = qual.Reference_2_Received__c;
                qualList.Reference_2_Rating__c = qual.Reference_2_Rating__c;
                qualList.Reference_3_Sent_Date__c = qual.Reference_3_Sent_Date__c;
                qualList.Reference_3_Text_Name__c = qual.Reference_3_Text_Name__c;
                qualList.Reference_3_Received_Date__c = qual.Reference_3_Received_Date__c;
                qualList.Reference_3_Contact_Details__c = qual.Reference_3_Contact_Details__c;
                qualList.Reference_3_Date_Range__c = qual.Reference_3_Date_Range__c;
                qualList.Reference_3_Email__c = qual.Reference_3_Email__c;
                qualList.Reference_3_Date_Range_End__c = qual.Reference_3_Date_Range_End__c;
                qualList.Reference_3_Type__c = qual.Reference_3_Type__c;
                qualList.Reference_3_Received__c = qual.Reference_3_Received__c;
                qualList.Reference_3_Rating__c = qual.Reference_3_Rating__c;
                qualList.TR1__Status__c = 'Submitted';
            }
            else if(qual.qualificationName__c == 'Upload Photo'){
                qualList.TR1__Status__c = 'Submitted';
            }
            update qualList;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'editQuali');
        }

    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualificationDetail Component
    * Description        : For save file which uplaod by user in qualification page.
    ***************************************************/
    @AuraEnabled
    public static List<String> saveQualifiFile(String parentId,String description, String fileName, String base64Data) { 
        try{
            TR1__Associated_Qualification__c qual = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:parentId AND qualificationName__c=:description LIMIT 1];

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            contentVersion.PathOnClient = fileName;//File name with extention            
            contentVersion.Title = fileName;//Name of the file
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
            contentVersion.Description = description;
            insert contentVersion;

            //After saved the Content Verison, get the ContentDocumentId
            ContentVersion contentData = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id];

            //Insert ContentDocumentLink
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentData.contentDocumentId;//Add ContentDocumentId
            contentDocumentLink.LinkedEntityId = qual.Id;//Add attachment parentId
            contentDocumentLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            contentDocumentLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert contentDocumentLink;

            List<String> lst = new List<String> {contentData.contentDocumentId, contentData.Title};
            return lst;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'saveQualifiFile');
            return null;
        }

    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualificationDetail Component
    * Description        : for get all qualification uploaded file data
    ***************************************************/
    @AuraEnabled
    public static List<ContentDocument> getqualifiFileData(String parentId, String description){
        try{
            TR1__Associated_Qualification__c qual = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:parentId AND qualificationName__c =: description];
            List<Id> contIds = new List<Id>();
            List<ContentDocumentLink> contentLinklst = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility FROM ContentDocumentLink where LinkedEntityId =: qual.Id];
            for(ContentDocumentLink cont : contentLinklst){
                contIds.add(cont.ContentDocumentId);
            }
            List<ContentDocument> contentData = [SELECT Id, Title FROM ContentDocument WHERE Id IN: contIds];
            return contentData;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getqualifiFileData');
            return null;
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 26/07/2022
    * Last Modified Date : 26/07/2022
    * UsedBy             : ts_MyQualificationDetail Component
    * Description        : for get qualification data
    ***************************************************/
    @AuraEnabled
    public static List<TR1__Associated_Qualification__c> getQualifiData(){
        try {
            User u  = [SELECT Id,ContactId from User where Id=:UserInfo.getUserId()];

            List<TR1__Associated_Qualification__c> qualLst = [SELECT Id,qualificationName__c,Gaps_Explanation__c,CV_Submitted__c,CV_Received__c,
                                                            SET_Registration_Number__c,Permanent_Right_to_Work_in_UK__c,Documents__c,Work_Permit_OR_Visa_Expiry_Date__c,
                                                            NCTL_Number__c,Qualification_Type2__c,Qualification_Type__c,NARIC_Approved__c,Overseas_Police_Check__c,Live_Worked_Overseas_Start_Date__c,
                                                            Live_Worked_Overseas_End_Date__c,Relationship_to_You__c,Emergency_Contact_Address__c,Emergency_Contact_Home_Phone__c,
                                                            Emergency_Contact_Mobile_Phone__c,Emergency_Contact_Work_Phone__c,Emergency_Contact_Name__c,Reference_1_Received__c,
                                                            SET_Expiry_Date__c,QTLS__c,Reference_Sent_Date__c,Reference_1_Text_Name__c,Reference_Received_Date__c,Reference_1_Date_Range__c,
                                                            Reference_1_Date_Range_End__c,Reference_1_Rating__c,Reference_2_Name__c,Reference_1_Contact_Details__c,Reference_1_Type__c,
                                                            Reference_2_Received_Date__c,Reference_2_Date_Rage__c,Reference_2_Date_Range_End__c,Reference_2_Sent_Date__c,Reference_2_Received__c,
                                                            Reference_2_Rating__c,Reference_3_Sent_Date__c,Reference_3_Text_Name__c,Reference_1_Email__c,Reference_2_Contact_Details__c,
                                                            Reference_3_Received_Date__c,Reference_3_Date_Range__c,Reference_3_Date_Range_End__c,Reference_2_Email__c,Reference_2_Type__c,
                                                            Reference_3_Rating__c,Reference_3_Email__c,Reference_3_Type__c,Reference_3_Received__c,
                                                            Reference_3_Contact_Details__c, TR1__Status__c, TR1__Expiration_Date__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c =: u.ContactId];
            return qualLst;                                                
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_ProfileModule', 'getQualifiData');
            return null;
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_HomePage,ts_Navigation,ts_Qualification,ts_Scheduler,ts_Compliance Component
    * Description        :
    ***************************************************/

    @AuraEnabled
    public static Contact fetchContact(){
        try {
            Id idContact = [SELECT Id, ContactId FROM User where Id=: UserInfo.getUserId()].ContactId;

            if(idContact != null){
                Contact con = [SELECT Id,Community_Contact_Type__c, Consol_URL__c FROM Contact WHERE Id = :idContact];
                return con;
            }
            return null;  
        } catch (Exception e) {
            System.debug(e);
            return null; 
        }  
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 08/08/2022
    * Last Modified Date : 08/08/2022
    * UsedBy             : ts_ForgotPasswordPage Component
    * Description        : Use for forgot user password
    ***************************************************/
    @AuraEnabled
    public static List<String> forgotSitePassword(String UsrId){
        try {
            List<User> lstUser = RC_AccessController.query('Select Username, ContactId, LastPasswordChangeDate From User where Username = \'' + UsrId + '\' And ContactId != null');

            if(!lstUser.isEmpty()) {
                if (lstUser[0].LastPasswordChangeDate < System.now().addDays(-1)) {
                    boolean blnSuccess = Site.forgotPassword(UsrId);
                    List<string> str = new List<string>{'Success', 'Success'};
                    return str;
                } else {
                    List<string> str = new List<string>{'Error', 'We recently received a request to reset the Salesforce password for the username ' +UsrId+ ' We can not reset your password because it was changed within the last 24 hours.'};
                    return str;
                }     
            }else {
                List<string> str = new List<string>{'Error', 'Username doesnot match any records in our System. Please Enter a valid Username!'};
                return str;
            }
        } catch (Exception e) {
            System.debug(e);
            List<string> str = new List<string>{'Error', 'Something Went Wrong', 'getMessagelogin => '+e.getMessage() + 'line no => '+e.getLineNumber()};
            return str;
        }
    }
}