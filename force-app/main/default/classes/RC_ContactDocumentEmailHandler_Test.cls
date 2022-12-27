@isTest
public class RC_ContactDocumentEmailHandler_Test{

    static testMethod void myTestMethod() {
        
        Contact testContact = new Contact (LastName = 'Test contact Last Name1234');
        insert testContact;
        
        TR1__ContactDocument__c  testContactDocument= new TR1__ContactDocument__c (Name = 'Test Contact Document1234', TR1__Contact__c	 = testContact.Id); 
        insert testContactDocument ;

       // Create a new email, envelope object and Attachment
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
       email.subject = 'test : ' +testContact.Id;
       env.fromAddress = 'user@acme.com';
       
       system.assertEquals(email.subject,'test : ' +testContact.Id);
      
       // call the class and test it with the data in the testMethod
       Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
       RC_ContactDocumentEmailHandler emailServiceObj = new RC_ContactDocumentEmailHandler();
       result = emailServiceObj.handleInboundEmail(email,env);          
             
       system.assertEquals(True, result.Success);
       system.assertEquals(email.subject,'test : ' +testContact.Id);
       system.assertEquals(env.fromAddress,'user@acme.com');
       
     /*  TR1__ContactDocument__c conDocument = new TR1__ContactDocument__c();
       conDocument.Name= 'Test Contact Document';
       conDocument.TR1__isDefault__c = true;
       conDocument.TR1__Contact__c = email.subject;
       update conDocument;*/
       
                   
}    



}