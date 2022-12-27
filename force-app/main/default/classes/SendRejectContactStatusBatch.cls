/******************************************************************************
 * Name: SendRejectContactStatusBatch
 * CreatedDate: 27 May 2022
 * Author: Prakash Mewada (MV Clouds)
 * Description: This is a Batch class on SendRejectContactStatusBatch for sending Email
 *              with list of Contact records that have Candidate Status as 'Reject'.
 * Test class: SendRejectContactStatusBatch_Test
 ******************************************************************************/

 /********************************************************************
  *     Modified Date   |   Changed By  |   Description              *
  ********************************************************************
  *     31 May 2022         Prakash         Created Batch class.             
  *
  ********************************************************************/
global class SendRejectContactStatusBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    global String generateCSVfile = '';
    public List<Contact> contactRecList = new List<Contact>();
    String toEmailException = System.label.Exception_To_Email;
    String toEmail = System.label.Rejected_Contact_To_Email;
    List<String> toEmailAddress = new List<String>();

    public SendRejectContactStatusBatch() {
        generateCSVfile = 'Name,Email,Mobile,Person Owner,Candidate Status,Source Category,Source,Cautions/Convictions,Disciplinary,References(not agreed),Right To Work'+'\n';
        if(toEmail.contains(',')){  toEmailAddress.addAll(toEmail.split(','));  }
        else{   toEmailAddress.add(toEmail);    }
    }
    
    global List<Contact> start(Database.BatchableContext BC) {   
        contactRecList = [SELECT Id, Name, MobilePhone, Email, OwnerId, Owner.Name, CreatedDate, TR1__Candidate_Status__c, Compliance_Status__c, Source_Category__c, TR1__Source__c, Cautions_Convictions_Candidate__c, Disciplinary_Candidate__c, References_Candidate__c, Right_to_work_Candidate__c FROM Contact WHERE TR1__Candidate_Status__c = 'Reject' AND CreatedDate = THIS_MONTH];
        return contactRecList;
    }

    global void execute(Database.BatchableContext BC, List<Contact> contactList) {
        for(Contact con : contactList) {
            generateCSVfile += con.Name+','+con.Email+','+con.MobilePhone+','+con.Owner.Name+','+con.TR1__Candidate_Status__c+','+con.Source_Category__c+','+con.TR1__Source__c+','+con.Cautions_Convictions_Candidate__c+','+con.Disciplinary_Candidate__c+','+con.References_Candidate__c+','+con.Right_to_work_Candidate__c+'\n';
        }
        System.debug('generateCSVfile --> '+generateCSVfile);
    }

    global void finish(Database.BatchableContext BC) {
        try{
            // Below code to send Email with csv data of all Reject status contacts
            DateTime dt = DateTime.now();
            if(contactRecList.size() > 0) {
                System.debug('generateCSVfile --> '+generateCSVfile);
                Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
                Blob csvBlob = blob.valueOf(generateCSVfile);
                String csvName = 'Rejected_Contacts('+ dt.format('MMMM') + dt.format('YYYY') +').csv';
                csvAttachment.setFileName(csvName);
                csvAttachment.setBody(csvBlob);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> toEmailAddress1 = new List<String>();
                if(toEmail.contains(',')){  toEmailAddress1.addAll(toEmail.split(','));
                }else{  toEmailAddress1.add(toEmail);    }
                email.setToAddresses(toEmailAddress1);
                
                String subject = 'Rejected Candidates from '+ dt.format('MMMM') +' '+ dt.format('YYYY');
                email.setSubject(subject);
                String bodyText = 'Hi All, <br/><br/>Below attached a list of candidates that were rejected in ' +dt.format('MMMM') +' '+ dt.format('YYYY')+ ' and deleted from the Salesforce database. <br/><br/>Thanks, <br/>'+'<h5>This email was sent as part of an automated procedure. Please do not reply to this message.</h5>';
                email.setHtmlBody(bodyText);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvAttachment });
                List<Messaging.SendEmailResult> r = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
                
                if (r[0].success) {
                    System.debug('The email was sent successfully.');
                    System.debug('Records deleted Successfully.');
                    delete contactRecList;
                }else {
                    System.debug('The email failed to send: ' + r[0].errors[0].message);
                }
            }

            // To schedule the batch class again for next month.
            DateTime ddate = (System.today() == System.today().addMonths(1).toStartofMonth().addDays(-1)) ? System.today().addMonths(2).toStartofMonth().addDays(-1) : System.today().addMonths(1).toStartofMonth().addDays(-1);
            
            String strSchedule = '0 ' + String.valueOf(ddate.minute()) + ' ' + String.valueOf(ddate.hour()) + ' ' + String.valueOf(ddate.day()) + ' ' + String.valueOf(ddate.month()) + ' ?' + ' ' + String.valueOf(ddate.year());
            System.schedule('Send Reject Contact Batch ('+ dt.addMonths(1).format('MMMM') +'-'+ dt.addMonths(1).format('YYYY')+ ')', strSchedule, new SendRejectContactStatusBatch());

        }catch(Exception e) {
            System.debug('Error --- '+e.getMessage()+' --- '+e.getStackTraceString());
            Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
            email1.setToAddresses(toEmailAddress);
            email1.setSubject('Exception while SendRejectContactStatusBatch batch class | Supply Desk Project');
            email1.setHtmlBody('Hi All, <br/><br/>This Email is due to Exception occured on SendRejectContactStatusBatch batch class. <br/>Below is the Exception details,<br/><br/>'+'Exception Cause   ::: '+e.getCause()+'<br/>'+'Line Number       ::: '+e.getLineNumber()+'<br/>'+'Exception Message ::: '+e.getMessage()+'<br/>'+'Stack Trace       ::: '+e.getStackTraceString()+'<br/>'+'Exception Type    ::: '+e.getTypeName()+'<br/>');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email1 });
        }
    }

    global void execute(SchedulableContext sc) {
        //Database.executeBatch takes in the class, and then the size of batches.
        ID BatchId = Database.executeBatch(new SendRejectContactStatusBatch(), 200);
    }
}