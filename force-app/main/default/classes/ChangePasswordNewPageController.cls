/*******************************************************
* Name          : ChangePasswordNewPageController
* Author        : 
* Create Date   : 01/08/2022
* UsedBy        : Used in ChangePasswordNewPage VF Page
* Description   : User for change password of user from visual force page
* Test Class    : ChangePasswordNewPageControllerTest
*******************************************************/
public with sharing class ChangePasswordNewPageController {
    public String oldPassword                   {get; set;}
    public String newPassword                   {get; set;}
    public String verifyNewPassword             {get; set;}   
    public Boolean isErrorPresent               {get; set;}
    
    public ChangePasswordNewPageController() {}
    
    public Pagereference redirectUnAuthenticatedUser() {
        return (Userinfo.getUserType() != 'CspLitePortal' && Userinfo.getUserType() != 'PowerCustomerSuccess') ? new Pagereference('/s/login') : null;
    }
    
    public PageReference changePassword() {
        String strRetURL;
        
        // Check if user is changing password from email link or from My Profile page
        strRetURL = Site.isPasswordExpired() ? '/s/' : '/s/profile';
            
        Pagereference prResultURL = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
        
        // Check if any errors found in changing the password
        if(prResultURL == null)
        {
            isErrorPresent = true;
            return prResultURL;
        }
        return new Pagereference(strRetURL);
    }
}