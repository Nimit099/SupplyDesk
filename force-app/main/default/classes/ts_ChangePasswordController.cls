public with sharing class ts_ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public String sss {get;set;}
    
    public ts_ChangePasswordController() {
        
    }
    public PageReference changePassword() {

        Pagereference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        // sss = pr.getURL();
        sss = 'Test!!';
        System.debug('sss->'+sss);
        return null;
    }     
}