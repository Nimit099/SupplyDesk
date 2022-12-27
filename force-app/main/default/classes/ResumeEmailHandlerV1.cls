global class ResumeEmailHandlerV1 implements Messaging.InboundEmailHandler {
    //Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        //result.success = false;
        system.debug('EmailID is' + env.fromaddress);
        system.debug('EmailID is' + email.fromaddress);
        system.debug('Plain Body is' + email.PlainTextBody);
        system.debug('HTML Body is' + email.HtmlBody);
        system.debug('subject is' + email.subject);
        try {
            TR1.Candidate candt;
            //Parse Attachments
            if (email.binaryAttachments != null) {
                List < Attachment > ResumeList = new List < Attachment > ();
                for (Messaging.InboundEmail.BinaryAttachment bAttachment: email.binaryAttachments) {
                    if (TR1.Constants.ContentTypesMap.get(bAttachment.mimeTypeSubType) != null) {
                        Attachment Resume = new Attachment();
                        Resume.Body = bAttachment.Body;
                        Resume.Name = bAttachment.fileName;
                        if (bAttachment.mimeTypeSubType != null)
                            Resume.ContentType = bAttachment.mimeTypeSubType;
                        ResumeList.add(Resume);

                    }
                }
                if (ResumeList.size() > 0) {
                    Attachment Resume = ResumeList[0];
                    candt = TR1.ResumeProcessor.createUpdateContact(Resume, UserInfo.getSessionId());
                    candt = TR1.ResumeProcessor.performDML(candt);
                    system.debug('candt-->' + candt);
                    if (candt.IsParserError != true) {
                        Id uploadedContactId = candt.ContactId;
                        PageReference pref = new PageReference('/' + uploadedContactId + '/e');
                        pref.getParameters().clear();
                        pref.getParameters().put('retURL', '/' + uploadedContactId);
                        //result.message = System.Label.Email_Success_Message;
                        //result.message += '\n\n' + 'https://' + URL.getCurrentRequestUrl().getHost().remove('-api') + pref.getURL();
                        //result.success = true;
                        //Added below code to handle 2nd attachment
                        if (ResumeList.size() == 2 && candt.ContactId != null) {
                            Attachment Resume2 = ResumeList[1];
                            Resume2.ParentId = candt.ContactId;
                            insert Resume2;
                        }
                    } else {
                        //result.message = candt.ParserErrorMsg;
                    }
                } else {
                    //result.message = System.Label.No_File_Attached;
                }
            }else {
                    //result.message = System.Label.No_File_Attached;
                }
            //Parse Body
            String emailSubject = email.Subject;
            String contactId = candt != null ? candt.ContactId : null;
            if (emailSubject != null && contactId != null) {
                parseEmailSubject(emailSubject, contactId);
            }
        } catch (Exception e) {
            //result.message = System.Label.Unknown_Error + '\n' + e.getMessage();
        }
        return null;
    }

    void parseEmailSubject(String emailSubject, String contactId) {
        // [AdvertType]/[JobTitle]/[JobReference]/[FeedName]/[FeedIdentifier]/[UserFullName]/[RankingColour]
        String[] emailSubjecttext = emailSubject.split('/');
        if (emailSubjecttext.size() >= 4) {
            List < TR1__Job__c > jobList = [Select Id,TR1__Job_Number__c from TR1__Job__c where TR1__Job_Number__c = : emailSubjecttext[2] limit 1];
            if (jobList.size() == 1) {
                TR1__Job_Board_Application__c app = new TR1__Job_Board_Application__c(TR1__Job__c = jobList[0].id, TR1__Applicant__c = contactId, TR1__Source__c = emailSubjecttext[3] );
                insert app;
            } else {
                //result.message = system.label.EmailParser_Job_Id_Empty + emailSubjecttext[2];
            }
        } else {
            //result.message = system.label.EmailParser_IncorrectNoOfParameters + emailSubjecttext;
        }
    }
}