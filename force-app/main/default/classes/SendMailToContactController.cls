public class SendMailToContactController {
    public Contact ct;
        
    public SendMailToContactController(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) { 
        	controller.addFields(new List<String>{'Name', 'Email'});
        }
        ct = (Contact) controller.getRecord();
    }
    
    public PageReference sendEmail(){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(ct.id); 
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true); 
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName = 'Covid19_Assesment'];
        message.toAddresses = new String[] { ct.email};
        message.setTemplateID(emailTemplate.Id); 
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        PageReference pgRef = new PageReference('/' + ct.id);
    	return pgRef;
    }
}