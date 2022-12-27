public with sharing class tS_SignInController {
    public tS_SignInController() {

    }

    @AuraEnabled
    public static string doLogin(String username, String password){
        try {
            
            System.debug('username-->'+username);
            System.debug('password-->'+password);
            // String startUrl = System.Label.Community_Url;
            String starturl = 'mvcdev-supplydesk.cs110.force.com/s/';
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);

            System.debug('pageRef.getUrl()-->'+pageRef.getUrl());

            if(pageRef != null) return pageRef.getUrl();

            // throw new CalloutException();

            return null;


        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_SignInController', 'doLogin');
            return e.getMessage();
        }
    }

}