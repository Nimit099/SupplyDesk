/**
 * An apex page controller that exposes the change password functionality
 */
public without sharing class TestChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        // return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
        // return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
        String userId = UserInfo.getUserId();
        System.debug('Current User Id : ' +userId);
        System.setPassword(userId, newPassword);
        return new Pagereference('/Signin'); 
    }     
    
   	public TestChangePasswordController() {

        System.debug('log');
        id userId = UserInfo.getUserId();
        System.debug('userId-->'+userId);

    }
}