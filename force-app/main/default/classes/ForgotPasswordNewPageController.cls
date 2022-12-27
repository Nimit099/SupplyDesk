public without sharing class ForgotPasswordNewPageController {
    
    public String strUsername           {get; set;}      //To get the user name from forgot password page.
    public boolean blnSuccess           {get; set;}     //To check the username is get success or not
    public String returnmsg           {get; set;}      //To check the username is get success or not
    public String returnValue {get; set;}
    public String tost_message {get; set;}

       
    //Contstrutor
    public ForgotPasswordNewPageController () {
        returnmsg = 'Controller';
    }
    
    //Securtiy redirecting 
    public Pagereference redirectAuthenticatedUser()
    {
        if(Userinfo.getUserType() == 'CspLitePortal' || Userinfo.getUserType() == 'PowerCustomerSuccess')
        {
            return new Pagereference('/s/');
        }
        return null;
    }

    public void forgotPassword() {
        
        List<User> lstUser = RC_AccessController.query('Select Username, ContactId, LastPasswordChangeDate From User where Username = \'' + strUsername + '\' And ContactId != null');
        blnSuccess =  false;

        if(!lstUser.isEmpty()) {
            if (lstUser[0].LastPasswordChangeDate < System.now()-1) {
                blnSuccess = Site.forgotPassword(strUsername);
                returnmsg = 'Success';
                tost_message = 'success';
            } else {
                tost_message = 'error';
                returnmsg = 'We recently received a request to reset the Salesforce password for the username ' +strUsername+ ' We can not reset your password because it was changed within the last 24 hours.';
            }     
        }else {
            tost_message = 'error';
            returnmsg = 'Username doesnot match any records in our System. Please Enter a valid Username!';
        }
    }

    public PageReference redirectToLogin() {
        PageReference pgnew = new PageReference('/s/login');
        return pgnew.setRedirect(true);
    }
}