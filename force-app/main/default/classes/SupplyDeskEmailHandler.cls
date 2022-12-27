global class SupplyDeskEmailHandler implements Messaging.InboundEmailHandler{
    Boolean isSuccess;
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
        
        system.debug(LoggingLevel.Info, 'Your info');
        TR1.Candidate candt;
        String[] emailSubjecttext = email.Subject.split('/');
        
        if(emailSubjecttext.size() == 14){
            emailSubjecttext[3] = emailSubjecttext[3] + '/' + emailSubjecttext[4];
            emailSubjecttext[4] = emailSubjecttext[5];
            emailSubjecttext[5] = emailSubjecttext[6];
            emailSubjecttext[6] = emailSubjecttext[7];
            emailSubjecttext[7] = emailSubjecttext[8];
            emailSubjecttext[8] = emailSubjecttext[9];
            emailSubjecttext[9] = emailSubjecttext[10];
            emailSubjecttext[10] = emailSubjecttext[11];
            emailSubjecttext[11] = emailSubjecttext[12];
            emailSubjecttext[12] = emailSubjecttext[13];
        }
        
        if(emailSubjecttext.size() > 0 && emailSubjecttext.size() >= 12){
            isSuccess = false;
            
            system.debug('EmailID is' + env.fromaddress);
            
            system.debug('EmailID is' + email.fromaddress);
            
            system.debug('Plain Body is' + email.PlainTextBody);
            
            system.debug('HTML Body is' + email.HtmlBody);
            
            system.debug('subject is' + email.subject);
            
            Set<String> setCandidateStatus = new Set<String>();
            Schema.DescribeFieldResult fieldResult = Contact.Candidate_Source__c.getDescribe();
            List<Schema.PicklistEntry> f = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry p : f){
                setCandidateStatus.add(p.getValue());
            }
            
            Set<String> setLogicMelonType = new Set<String>();
            Schema.DescribeFieldResult fieldResultt = Contact.Logic_Melon_Type__c.getDescribe();
            List<Schema.PicklistEntry> ff = fieldResultt.getPicklistValues();
            for(Schema.PicklistEntry p : ff){
                setLogicMelonType.add(p.getValue());
            }
            
            Contact con = new Contact();
            for(Contact cont : [Select Id From Contact Where FirstName =:emailSubjecttext[7] AND LastName =:emailSubjecttext[8] AND Email=:emailSubjecttext[9]]){
                con = new Contact(Id = cont.id);    
            }
            
            if(setCandidateStatus.contains(emailSubjecttext[3])){
                con.Candidate_Source__c = emailSubjecttext[3];
            }
            
            //Production Account Id
            String accId = Label.UnknownAccountId;
            Account acc = new Account();
            
            for(Account acco : [Select Id From Account Where Id =: accId limit 1]){
                acc = new Account(Id = acco.id);
            }
            
            if(acc.id == null){
                for(Account acco : [Select Id From Account Where Name LIKE '%UNKNOWN%' limit 1]){
                    acc = new Account(Id = acco.id);
                }
            }
            
            
            if(acc.id == null){
                Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
                acc.Name = 'UNKNOWN';
                acc.RecordTypeId = rt;
                insert acc;
            }
            
            String userName = emailSubjecttext[5];
            for(User u : [Select Id,Branch__c From User Where Name =: userName limit 1]){
                con.OwnerId = u.Id;
                con.Division__c = u.Branch__c;
            }
            
            con.FirstName = emailSubjecttext[7];
            con.LastName = emailSubjecttext[8];
            con.Email = emailSubjecttext[9];
            con.MobilePhone = emailSubjecttext[10];
            con.HomePhone = emailSubjecttext[11];
            if(setLogicMelonType.contains(emailSubjecttext[12])){
                con.Logic_Melon_Type__c = emailSubjecttext[12];    
            }
            
            con.TR1__Candidate_Status__c = 'Prospect';
            con.Compliance_Status__c = 'Not Registered';
            con.MailingCountry = 'UK';
            con.AccountId = acc.id;
            upsert con; 
            
            //TR1.ResumeProcessor.mapToContact(candt,con);
            List < Attachment > ResumeList = new List < Attachment > ();
            if (email.binaryAttachments != null) {
                
                for (Messaging.InboundEmail.BinaryAttachment bAttachment: email.binaryAttachments) {

                        Attachment CV = new Attachment();
                        
                        CV.Body = bAttachment.Body;
                        
                        CV.Name = bAttachment.fileName;
                        
                        CV.ParentId = con.id;
                        
                        ResumeList.add(CV);
                }
                
            }   
            if(email.textAttachments != null){
                for (Messaging.InboundEmail.TextAttachment tAttachment: email.textAttachments) {

                    Attachment CV = new Attachment();
                    
                    CV.Body = Blob.valueOf(tAttachment.Body);
                    
                    CV.Name = tAttachment.fileName;
                    
                    CV.ParentId = con.id;
                    
                    ResumeList.add(CV);

                    
                }
            }                
            if (ResumeList.size() > 0) {
                insert ResumeList;
                
                List<TR1__ContactDocument__c> lstContactDocument = new List<TR1__ContactDocument__c>();
                for(integer i=0 ; i< ResumeList.size() ; i++){
                    TR1__ContactDocument__c cd = new TR1__ContactDocument__c();
                    cd.Name = ResumeList[i].Name;
                    cd.TR1__Contact__c =con.id;
                    cd.TR1__isDefault__c = true;
                    cd.TR1__Type__c = 'Resume';
                    lstContactDocument.add(cd);
                }
                
                if(lstContactDocument.size() > 0){
                    insert lstContactDocument;
                }
                
                if(string.isBlank(emailSubjecttext[10]) || string.isBlank(emailSubjecttext[11])){
                    Attachment Resume = ResumeList[0];
                    candt = TR1.ResumeProcessor.createUpdateContact(Resume, UserInfo.getSessionId());
                    
                    candt = TR1.ResumeProcessor.performDML(candt);
                    system.debug('candt-->' + candt);
                }
            }
            if (con.id != null) {
                parseEmailSubject(emailSubjecttext[1], emailSubjecttext[2], con.id);
            }
        }
        return null;
    }
    
    void parseEmailSubject(String JobReference, String JobTitle, String contactId) {
        
        // [AdvertType]/[JobTitle]/[JobReference]/
        List < TR1__Job__c > jobList = [Select Id,TR1__Job_Number__c from TR1__Job__c where TR1__Job_Number__c =: JobTitle limit 1];
        if (jobList.size() == 1) {
            
            Set<String> setSource = new Set<String>();
            Schema.DescribeFieldResult fieldResult = TR1__Job_Board_Application__c.TR1__Source__c.getDescribe();
            List<Schema.PicklistEntry> f = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry p : f){
                setSource.add(p.getValue());
            }
            
            TR1__Job_Board_Application__c app = new TR1__Job_Board_Application__c(TR1__Job__c = jobList[0].id, TR1__Applicant__c = contactId);
            if(setSource.contains(JobReference)){
                app.TR1__Source__c = JobReference;
            }
            insert app;
        } 
    }
    
}