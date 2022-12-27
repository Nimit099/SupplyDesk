public class ConvertToApplicationController{
    public final TR1__Job_Board_Application__c jobBoardApplication {get;set;}
    String templateApiName = 'Rejection Email to Candidate';
    Id EmailTemplateId = [select id, name from EmailTemplate where Name =: templateApiName].id;    

    public ConvertToApplicationController(ApexPages.StandardController stdController){
        Id JobBoardApplicationId = Id.valueof(stdController.getId());
        this.jobBoardApplication = [select Id,TR1__Job__c,TR1__Applicant__c,TR1__Job__r.OwnerId,Rejection_Reason__c,Rejection_Comment__c from TR1__Job_Board_Application__c where Id =: JobBoardApplicationId limit 1];
    }
    
    public PageReference convertToApplication(){
        PageReference newocp;
        TR1__Application__c application = new TR1__Application__c();
        try{
            application.TR1__Applicant__c = jobBoardApplication.TR1__Applicant__c;
            application.TR1__Job__c = jobBoardApplication.TR1__Job__c;
            insert application;
            newocp = new PageReference('/'+jobBoardApplication.TR1__Job__c);
            newocp.setRedirect(true);
            jobBoardApplication.TR1__Status__c = 'Current';
            update jobBoardApplication;
            return newocp;
        }catch(System.DMLException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(e));
            ApexPages.addMessage(myMsg);          
            return null;
        }
    }
    
    public PageReference sendback(){
        PageReference newocp = new PageReference('/'+jobBoardApplication.Id);
        newocp.setRedirect(true);       
        return newocp;
    }
    
    public PageReference rejectAndDelete(){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        PageReference newocp = new PageReference('/'+jobBoardApplication.TR1__Job__c);
        newocp.setRedirect(true);
        email.setTargetObjectId(jobBoardApplication.TR1__Applicant__c);
        email.setTemplateId(EmailTemplateId);        
        try {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            delete jobBoardApplication;
            delete new Contact(Id=jobBoardApplication.TR1__Applicant__c);
            return newocp;
        }
        catch (EmailException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(e));
            ApexPages.addMessage(myMsg);
        }
        return newocp;
    }
    
    public PageReference rejectAndKeep(){
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        PageReference newocp = new PageReference('/'+jobBoardApplication.Id);
        newocp.setRedirect(true);

        //email.setTargetObjectId(jobBoardApplication.Applicant__c);
        //system.debug('Email Template Id >>> ' +EmailTemplateId);
        //email.setTemplateId(EmailTemplateId);
        
        try {
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            jobBoardApplication.TR1__Status__c = 'Rejected';
            update jobBoardApplication;    
            return newocp;
    
        }
        catch (EmailException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(e));
            ApexPages.addMessage(myMsg);
        }
        return newocp;
    }
    
    public PageReference rejectAndRefer(){
        PageReference newocp = new PageReference('/'+jobBoardApplication.Id);
        newocp.setRedirect(true);
        

        /*******************************************  Email to candidate      *******************************************/
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //email.setTargetObjectId(jobBoardApplication.Applicant__c);
        //email.setTemplateId(EmailTemplateId);
            //email.setSaveAsActivity(false);
        
        /*******************************************  Email to users      *******************************************/
    
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
        String templateApiName1 = 'Refer candidate to user';
        Id templateId = [select id, name from EmailTemplate where Name =: templateApiName1].id;

        Id UserId = jobBoardApplication.TR1__Job__r.OwnerId;
        User user = [select email, firstName, lastName from User where id = :userId];
        Contact tempContact = new Contact(email = user.email, firstName = user.firstName, lastName = user.lastName);
        insert tempContact;

        email1.setTargetObjectId(tempContact.id); 
        email1.setTemplateId(templateId);
        email1.setWhatId(jobBoardApplication.Id);         
        email1.setSaveAsActivity(false);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});//email,
            delete tempContact;
            jobBoardApplication.TR1__Status__c = 'Rejected';
            update jobBoardApplication;    
            return newocp;
        }
        catch (EmailException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(e));
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    private static void sendMyTemplate(Id userId, Id mergedObjectId, Id templateId) {
        User user = [select email, firstName, lastName from User where id = :userId];
        Contact tempContact = new Contact(email = user.email, firstName = user.firstName, lastName = user.lastName);
        insert tempContact;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(tempContact.id); 
        mail.setTemplateId(templateId);
        mail.setWhatId(mergedObjectId); 
        Messaging.sendEmail(new Messaging.singleemailMessage[] {mail});
        delete tempContact;
    }        
}