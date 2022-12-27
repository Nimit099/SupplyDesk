public class SendConfirmationLetter{
    public static Boolean sendConfirmationLetterFlag = False;
    @future(callout=true)
    public static void sendVF(set<Id> crIdSet){
        List<TR1__Closing_Report__c> crList = [Select Name, Id, Contact_Email__c,Hiring_Manager__r.Email,TR1__Person_Placed__c,TR1__Person_Placed__r.Name,TR1__Contact__c,TR1__Job__r.Owner.Email,TR1__Job__r.Owner.Name from TR1__Closing_Report__c where Id IN :crIdSet ];
        if(crList.size() > 0){
            for(TR1__Closing_Report__c cr : crList){
                if(cr.Hiring_Manager__r.Email != null){
                    PageReference PageRef = Page.ConfirmationLetterPDF_V2;
                    pageRef.getParameters().put('Id',cr.Id);
                    Blob b;
                    if(!Test.isRunningTest()){
                        b = PageRef.getContentAsPDF();
                    }
                    else{
                        b= blob.valueOf('Test Data');
                    }
                    
                    // Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    // attachment.setFileName('Confirmation Letter.pdf');
                    // attachment.setBody(b);
                    
                    List<string> sendTo = new List<string>{cr.Hiring_Manager__r.Email};
                    // List<string> sendTo = new List<string>{'sakina.s@mvclouds.com'};

                    
                        String vacancyOwnerEmail  = cr.TR1__Job__r.Owner.Email;
                    List<string> sendCC = new List<string>{vacancyOwnerEmail};
                        String vacancyOwnerName = cr.TR1__Job__r.Owner.Name;
                    
                    Id templateId = [SELECT Id,Name,HtmlValue,Body, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Client_Confirmation_of_Checks'].Id;
                    Id orgEmailID = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Payroll Team'].Id;
                    
                    String CandidateName = String.isNotBlank(cr.TR1__Person_Placed__r.Name) ? cr.TR1__Person_Placed__r.Name : 'Candidate';
                    //String Body = 'Hi, \n\nPlease find attched confirmation Letter of '+ CandidateName +'.\n\nThanks, \nSupply Desk..';
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email = Messaging.renderStoredEmailTemplate(templateId, cr.Hiring_Manager__c, cr.Id);                    
                    email.setToAddresses(sendTo); 

                    email.setCcAddresses(sendCC); 
                    // email.setOrgWideEmailAddressId(orgEmailID);
                    email.setReplyTo(vacancyOwnerEmail);
                    email.setSenderDisplayName(vacancyOwnerName);
                    
                    if(!Test.isRunningTest())
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 

                }
            }
        }
    }
}