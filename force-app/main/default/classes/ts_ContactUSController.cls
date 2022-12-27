public with sharing class ts_ContactUSController {
    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String Name, String Email, String Subject, String Body) {
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            mail.setHtmlBody(Body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}