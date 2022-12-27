public without sharing class ts_RegisterController {
    public ts_RegisterController() {

    }

    @AuraEnabled
    public static string checkuser(String email){
        try {

            System.debug('email-->'+email);
            
            List<Contact> contlst = [SELECT Id, Name, Email FROM Contact WHERE Email =: email];
            if (contlst.size() > 0) {
                return 'Email already Exist!!!';
            } else {
                return null;
            }
            
        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'checkuser');
            return null;
        }
    }
    
    @AuraEnabled
    public static string createuser(String contwrapdata){
        try {
            
            System.debug('contwrapdata==>'+contwrapdata);
            contwrap cont = (contwrap)JSON.deserialize(contwrapdata,contwrap.class);
            System.debug('cont-->'+cont);
            System.debug('cont Name-->'+cont.FirstName);
            System.debug('cont Name-->'+cont.LastName);
            System.debug('cont Name-->'+cont.Email);
            
            Account acc = [SELECT Id, Name, Post_Code__c, OwnerId, TR1__Status__c, Client_Status__c, Division__c FROM Account WHERE Post_Code__c =: cont.Postcode LIMIT 1];
            
            Contact con = new Contact();
            con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client').getRecordTypeId();
            con.LastName = cont.LastName;
            con.FirstName = cont.FirstName;
            con.Email = cont.Email;
            con.Roles__c = cont.Job;
            con.MobilePhone = cont.Mobile;
            con.Phone = cont.Phone;
            // con.Postcode__c = cont.Postcode;
            // con.Owner_Alias__c = acc.Owner_Alias__c;
            // con.Contact_Type__c = acc.TR1__Status__c;
            con.TR1__Client_Status__c = acc.Client_Status__c;
            con.Division__c = acc.Division__c;
            con.OwnerId = acc.OwnerId;
            con.Enable_Community_User__c = true;
            con.AccountId = acc.Id;

            insert con;


            System.debug('con-->'+cont);
            
            return null;
            
        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            system.debug('e.getMessagelogin+   '+e.getLineNumber());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'createuser');
            return null;
        }
    }

    // Forgot Password
    @AuraEnabled
    public static string forgotpassword(String usernameval){
        try {
            System.debug('username==>'+usernameval);
            List<User> usrlst = [Select Username, ContactId From User where Username =: usernameval  And ContactId != null LIMIT 1];
            System.debug('usrlst==>'+usrlst);

            if(usrlst.size() == 1){
                System.debug('usrlst.get(0)==>'+usrlst.get(0));
                Boolean boo = Site.forgotPassword(usernameval);
                return String.valueOf(boo);
            } else {
                return 'Please Enter valid UserName';
            }

        } catch (Exception e) {
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'forgotpassword');
            return null;
        }
    }

    // Compliance Class
    @AuraEnabled
    public static List<TR1__Closing_Report__c> getcrdata(String userid){
        try {
            System.debug('getcrdata');
           
            Id loggedInUserId = [SELECT Id, ContactId FROM User where Id =: userid].ContactId;
            List<TR1__Closing_Report__c> crlist = [select id, TR1__Person_Placed__r.FirstName, TR1__Person_Placed__r.Group_1_ID_Type_Hidden__c, TR1__Person_Placed__r.Group_2A_ID_Type_Hidden__c,TR1__Person_Placed__r.Group_2B_ID_Type_Hidden__c from TR1__Closing_Report__c where TR1__Person_Placed__c =:loggedInUserId];
            System.debug('crlist-->'+crlist);
            return crlist;
        } catch (Exception e) {
            System.debug(e);
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'getcrdata');
            return null;
        }
    }

    // Compliance Download PDF Created by Mihir Ramoliya
    @AuraEnabled
    public static string downloadpdf(String recordid){
        try {

            String pdf_url = '/apex/ConfirmationLetterPDF_v2?recordid='+recordid;
    
            PageReference pdfPage = new PageReference(pdf_url);
            Blob pdfBlob = pdfPage.getContent();
            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
            System.debug(base64Pdf);
            return base64Pdf;
            
        } catch (Exception e) {
            System.debug(e);
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'downloadpdf');
            return null;
        }
    }

    // Change Password Page
    @AuraEnabled
    public static string changepass(String newPassword, String verifyNewPassword, String oldpassword){
        try {
            System.debug('changepass');
            System.debug('oldpass->'+oldpassword);
            System.debug('newpass->'+newPassword);
            System.debug('verifynewpass-->'+verifyNewPassword);
            // System.debug('Site.changePassword(newPassword, verifyNewPassword, oldpassword);    ==>'+Site.changePassword(newPassword, verifyNewPassword, oldpassword));
            // PageReference pr = Site.changePassword(newpass, verifynewpass, oldpass);
            String strRetURL;
            // Check if user is changing password from email link or from My Profile page
            strRetURL = Site.isPasswordExpired() ? '/s/login' : '/MyAccount';

            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
            System.debug('pr-->'+pr);
            if(pr == null) {
                String ss = pr.getURL();
                return ss;
            }
            return strRetURL;
            
        } catch (Exception e) {
            System.debug('Exception->'+e.getLineNumber());
            System.debug('Exception->'+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'changepass');
            return e.getMessage();
        }
    }

    // Reset Password Page
    @AuraEnabled
    public static string resetpass(String newPassword, String usrid){
        try {
            System.debug('changepass');
            // System.debug('Site.changePassword(newPassword, verifyNewPassword, oldpassword);    ==>'+Site.changePassword(newPassword, verifyNewPassword, oldpassword));
            // PageReference pr = Site.changePassword(newpass, verifynewpass, oldpass);
            // PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
            // System.debug('pr-->'+pr);
            // String ss = pr.getURL();
                // System.resetPassword(usrid, true);
             System.setPassword(usrid, newPassword);
            return 'Changed?';
            // if (pr != null) {
            //     return 'Success';
            // } else {
            //     return null;
            // }
            
        } catch (Exception e) {
            System.debug('Exception->'+e.getLineNumber());
            System.debug('Exception->'+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_RegisterController', 'resetpass');
            return e.getMessage();
        }
    }

    // For ContactUs Page
    @AuraEnabled(cacheable=true)
    public static String sendEmailToController(String Name, String Email, String Subject, String Body) {
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            mail.setHtmlBody(Body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            return 'Success';
        }catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            return ex.getMessage();
        }
    }


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
        public String Mobile{get;set;}
        @AuraEnabled
        public String Phone{get;set;}
    }
}