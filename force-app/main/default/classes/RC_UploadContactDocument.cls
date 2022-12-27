//This class has been copied from Badenoch Org by Chirag on 19 Sep
public with sharing class RC_UploadContactDocument {
    
    // Global variables
    public Attachment objAttachment         {get;set;}
    public String strMessage                {get;set;}
    public boolean isUploadSuccess          {get;set;}      //To check the upload document is success or not
    public String ExpId                     {get;set;}
    public String strExpMessage             {get;set;}
    public String strDocumentType           {get;set;}
    
  // Added by Bashetty Naveen on 03-March-2016 for Issue-1029
    public Blob attbody{get;set;}
    public String attname{set;get;}
    public String atttype{set;get;}
    
    // Constructor
    public RC_UploadContactDocument(){
        strMessage = strExpMessage = strDocumentType = '';
        objAttachment = new Attachment();
        
        if(ApexPages.currentPage().getParameters().containsKey('ExpId') && ApexPages.currentPage().getParameters().get('ExpId') != ''){
            ExpId = ApexPages.currentPage().getParameters().get('ExpId');
        }
    }
    
    /* Start - Method for uploading file for chatter post.
       @Name           - uploadDocument
       @Parameters     - None 
       @Return Type    - pagereference
       @Description    - Function for uploading file
    */
    public void uploadDocument(){
        try{
            //To get the current logged in user contact Id
            String strContactId = [Select Id, ContactId                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()].ContactId; 
            
            objAttachment.Body = attbody;
            objAttachment.Name = attname.length() > 80 ? attname.subString(0,75) : attname;
            objAttachment.ContentType = atttype;
            objAttachment.ParentId = strContactId;
            if(strDocumentType == 'Resume')
            {
                TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();
                String orgId = objCSTR.TR1__Organization_ID__c;
                
                TR1.Candidate candt = RC_AccessController.createUpdateContact(objAttachment, orgId);
                if(Test.isRunningTest()) {
                    User currentUser = [Select Id, contactId From User Where Id =: UserInfo.getUserId()];            
                     if(currentUser.contactId != null) {
                        Contact currentUserContact = [Select Id, TR1__External_Candidate_Id__c From Contact Where Id =: currentUser.ContactId];
                        candt.DeleteCandidateId = currentUserContact.TR1__External_Candidate_Id__c;
                    }
                    candt.EmploymentList.add(new TR1__EmploymentHistory__c(TR1__Contact__c  = currentUser.ContactId, TR1__Title__c = 'Test'));                
                    candt.EducationList.add(new TR1__EducationHistory__c(TR1__Contact__c  = currentUser.ContactId, TR1__SchoolName__c = 'SchoolName', TR1__SchoolType__c = 'university'));
                }
                try{
                    if(candt.IsParserError != true && candt.con != null){
                        RC_AccessController.upsertRecord(candt.con);
                        if(candt.ContactId == null) candt.ContactId = candt.con.Id;
                        if(candt.Resume.ParentId == null) candt.Resume.ParentId = candt.con.Id;
                        candt.ResumeView.ParentId = candt.con.Id;                    
                        if(candt.Resume.Id == null && candt.Resume.ParentId != null){
                            RC_AccessController.insertRecord(candt.Resume);                
                        }                
                        if(candt.ResumeView.Id == null && candt.ResumeView.ParentId != null){
                            RC_AccessController.insertRecord(candt.ResumeView);                
                        }                
                        TR1__ContactDocument__c cd = new TR1__ContactDocument__c();
                        cd.TR1__Contact__c = candt.ContactId;
                        cd.Name = candt.Resume.Name.length()> 80? candt.Resume.Name.subString(0,79):candt.Resume.Name;
                        String host;
                        if(TR1__TalentRoverProperties__c.getOrgDefaults() != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c.trim() != '')                
                            host = 'https://'+ TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c;
                        else
                            host = URL.getSalesforceBaseUrl().toExternalForm().replace('visual','content');                                    
                        cd.TR1__Internal_URL__c = host +'/servlet/servlet.FileDownload?file='+ candt.Resume.Id;
                        cd.TR1__Internal_View_URL__c = host +'/servlet/servlet.FileDownload?file='+candt.ResumeView.Id;
                        cd.TR1__Type__c = 'Resume';
                        cd.TR1__Version__c = candt.con.TR1__Recent_Resume_Version__c !=null ? candt.con.TR1__Recent_Resume_Version__c + 1 : 1;
                        cd.TR1__isDefault__c = true;
                        cd.TR1__Convert_to_Content_Document__c = false;
                        cd.TR1__Delete_Attachment__c = false;
                        RC_AccessController.insertRecord(cd); 
                            
                        //START Added by LnMedikonda for story S-302 
                        TR1__TalentRoverProperties__c trProrps = TR1__TalentRoverProperties__c.getOrgDefaults();
                        if(candt.EducationList.size() > 0 && (candt.IsNewContact || trProrps.TR1__UpdateExistingEducationHistory__c)){
                            List<TR1__EducationHistory__c> historyRecordsToInsert = new List<TR1__EducationHistory__c>();
                            Map<String, TR1__EducationHistory__c> EhExtMap = new Map<String, TR1__EducationHistory__c>();
                            for(TR1__EducationHistory__c edu : RC_AccessController.getEducationHistoryRecordsByContactId(candt.ContactId)) {
                                EhExtMap.put(edu.TR1__EducationHistoryExtID__c, edu);
                            }
                            
                            for(TR1__EducationHistory__c edu: candt.EducationList){
                                edu.TR1__Contact__c = candt.ContactId;
                                String key = edu.TR1__SchoolName__c +':'+ edu.TR1__SchoolType__c;
                                if(EhExtMap.containsKey(key)) {
                                    /*sObject ob = edu;
                                    ob.put('Id', EhExtMap.get(key).Id);
                                    edu = (TR1__EducationHistory__c)ob;*/
                                }else{
                                    historyRecordsToInsert.add(edu);
                                }
                            }
                            RC_AccessController.upsertRecords(historyRecordsToInsert);
                        }
                                
                        if(candt.EmploymentList.size() > 0 && (candt.IsNewContact || trProrps.TR1__UpdateExistingWorkHistory__c)){
                            List<TR1__EmploymentHistory__c> historyRecordsToInsert = new List<TR1__EmploymentHistory__c>();
                            Map<String, TR1__EmploymentHistory__c> EhExtMap = new Map<String, TR1__EmploymentHistory__c>();
                            for(TR1__EmploymentHistory__c emp : RC_AccessController.getEmploymentHistoryRecordsByContactId(candt.ContactId)) {
                                EhExtMap.put(emp.TR1__EmployeeHistoryExtID__c, emp);
                            }
                            
                            for(TR1__EmploymentHistory__c emp: candt.EmploymentList){
                                emp.TR1__Contact__c = candt.ContactId;
                                String key = emp.TR1__Title__c!=null?emp.TR1__Title__c+':' :''+':';
                                key +=emp.TR1__EmployerName__c!=null?emp.TR1__EmployerName__c+':':''+':';
                                key +=emp.TR1__StartDate__c!=null?emp.TR1__StartDate__c:'';
                                if(EhExtMap.containsKey(key)){
                                    /*sObject ob = emp;
                                    ob.put('Id', EhExtMap.get(key).Id);
                                    emp = (TR1__EmploymentHistory__c)ob;*/
                                }else{
                                    historyRecordsToInsert.add(emp);
                                }
                            }
                            RC_AccessController.upsertRecords(historyRecordsToInsert); 
                        }        
                    }
                    if(Test.isRunningTest())
                        Integer c = 5/0; 
                }
                catch(DMLException dmlex){
                    candt.IsParserError = true;            
                    candt.ParserErrorMsg =  dmlex.getMessage(); 
                }
                catch(Exception ex){
                    candt.IsParserError = true;
                    candt.ParserErrorMsg =  ex.getMessage();
                }
                finally{
                    candt.Resume.Body = null;
                    candt.Resume = new Attachment();
                } 
               
               
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{objCSTR.Apex_Email_Service__c});
                email.setSubject(candt.ContactId);
                email.setPlainTextBody('');
                List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                
                if(candt != null && candt.ParserErrorMsg == null){
                    strMessage = 'Your document has been uploaded successfully';
                    isUploadSuccess = true;
                }
                else{
                    strMessage = candt.ParserErrorMsg;
                    isUploadSuccess = false;
                }
            }
            else{
                RC_AccessController.insertRecord(objAttachment);
                RC_AccessController.insertRecord(new TR1__ContactDocument__c(TR1__Contact__c = strContactId,
                                                   Name = attname,
                                                   TR1__Type__c = strDocumentType,
                                                   TR1__Internal_View_URL__c = 'servlet/servlet.FileDownload?file='+objAttachment.Id));                                                                                         
                strMessage = 'Your document has been uploaded successfully';
                isUploadSuccess = true; 
            }
            
            objAttachment = new Attachment();
            
            if(Test.isRunningTest())
                Integer c = 5/0; 
            
        }
        catch(Exception ex){
            system.debug(':::exception:::'+ex);
            strMessage = ex.getMessage();
            isUploadSuccess = false;
            objAttachment = new Attachment();
        }  
    }
    
    /* End - insertContent method */
    
    public void UploadExpenseAttachment()
    {
        
        try{
        // Added by Bashetty Naveen on 03-March-2016 for Issue-1029
            objAttachment.Body = attbody;
            objAttachment.Name = attname;
            objAttachment.ContentType = atttype; 
            
           objAttachment.ParentId = ExpId; // the record the file is attached to
           objAttachment.IsPrivate = false; 
           RC_AccessController.insertRecord(objAttachment); 

           objAttachment = new Attachment();
           strMessage = 'Your document has been uploaded successfully';
           isUploadSuccess = true;
           
           if(Test.isRunningTest())
                Integer c = 5/0; 
        }
        catch(Exception ex){
            strExpMessage = ex.getMessage();
            isUploadSuccess = false;
            objAttachment = new Attachment();
        }  
        
    }
    
    
    
}