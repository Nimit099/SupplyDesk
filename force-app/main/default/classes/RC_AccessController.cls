public without sharing class RC_AccessController {


    public static TR1.Candidate createUpdateContact(Attachment objAttachment, String orgId) {
     	return TR1.ResumeProcessor.createUpdateContact(objAttachment, orgId);   
    }

    public static void upsertContact(Contact contact2Upsert, Schema.SObjectField keyField) {
        Database.upsert(contact2Upsert, keyField, false);
    }


    public static List<sObject> query(String queryStr) {
        return Database.query(queryStr);
    }

    public static List<TR1__EducationHistory__c> getEducationHistoryRecordsByContactId(Id contactId) {
        return [Select Id,TR1__EducationHistoryExtID__c from TR1__EducationHistory__c Where TR1__Contact__c =: contactId];
    }
    
    public static List<Closing_Report_Schedule__c> getClosingReportScheduleRecordsByEventId(Id eventId) {
        return [Select Id from Closing_Report_Schedule__c where Id =:eventId];
    }
    
    public static List<Candidate_Availability__c> getCandidateAvailabilityRecordsByEventId(Id eventId) {
        return [Select Id from Candidate_Availability__c where id =:eventId];
    }


    public static List<TR1__EmploymentHistory__c> getEmploymentHistoryRecordsByContactId(Id contactId) {
        return [Select Id,TR1__EmployeeHistoryExtID__c from TR1__EmploymentHistory__c Where TR1__Contact__c =: contactId];
    }

    public static Contact getContactsByExternalCandidateId(String deleteCandidateId) {
        return [Select Id from Contact where TR1__External_Candidate_Id__c =: deleteCandidateId];
    }

    public static List<User> getUsersByContactId(String contactId) {
        return [Select Id from User where ContactId =: contactId];
    }

    public static TR1__ContactDocument__c getLastCreatedContactDocument(String contactId) {
        return [Select Name from TR1__ContactDocument__c where TR1__Contact__c =:contactId  Order BY CreatedDate Desc limit 1];
    }

    public static void insertRecord(sObject record2Insert) {
        Database.insert(record2Insert);
    }
    
    public static void insertRecords(List<sObject> records2Insert) {
        Database.insert(records2Insert);
    }

    public static void upsertRecords(List<sObject> sObjects2Upsert) {
        Database.upsert(sObjects2Upsert);
    }
    
    public static void upsertRecord(sObject sObjects2Upsert) {
        Database.upsert(sObjects2Upsert);
    }

    public static void updateRecord(sObject record2Update) {
        Database.update(record2Update);
    }

    public static void updateRecords(List<sObject> records2Update) {
        Database.update(records2Update);
    }

    public static void deleteRecord(sObject record2Delete) {
        Database.delete(record2Delete);
    }
    
    public static void deleteRecords(List<sObject> records2Delete) {
        Database.delete(records2Delete);
    }


    public static List<AggregateResult> getArticleCategories() {
        return [select count(id) numOfRecords, TR1__Category__c from TR1__RC_Article__c group by TR1__Category__c];
    }

    public static List<List<sObject>> searchQuery(String query) {
        return Search.query(query);
    }

    public static List<TR1__Application__c> getContactApplicationsForJob(String strJobId, String idContact) {
        return [Select Id from TR1__Application__c where TR1__Job__c =: strJobId and TR1__Applicant__c =: idContact];
    }

    public static TR1__Job__c getJobById(String jobId) {
        return [Select  Job_Title__c from TR1__Job__c where Id =: jobId];
    }

    public static List<TR1__ContactDocument__c> getContactsDefaultResumes(Set<Id> contactIds) {
       return [SELECT TR1__Contact__c,TR1__Internal_URL__c,TR1__Internal_View_URL__c,TR1__HTML_URL__c FROM TR1__ContactDocument__c WHERE TR1__Contact__c IN: contactIds AND TR1__isDefault__c = true AND TR1__Type__c = 'Resume'];
    }

    public static TR1__ContactDocument__c getContactDefaultResume(Id contactId, Boolean isUploadSuccess) {
        return [Select Id,TR1__FlashAttachmentId_Legacy__c from TR1__ContactDocument__c where TR1__Contact__c =: contactId AND TR1__isDefault__c =: isUploadSuccess  ORDER BY CreatedDate DESC limit 1];
    }
    
    public static List<TR1__RC_Article__c> getRCArticleById(Id articleId) {
        return [select TR1__Content__c from TR1__RC_Article__c where Id = :articleId];
    }

    public static List<TR1__Associated_Qualification__c> getAssociatedQualificationsById(Id qualificationId) {                                                                  
        return [Select Power_Form_URL__c, TR1__Qualification__r.Field_Set_ID_c__c, TR1__Qualification__c, TR1__Qualification__r.TR1__Field_Set_ID__c, TR1__Qualification__r.TR1__Collection_Methods__c, TR1__Qualification__r.Name, TR1__Qualification__r.TR1__Instructions_External__c, TR1__Completed_Collection_Methods__c, TR1__Status__c From TR1__Associated_Qualification__c Where Id =: qualificationId];
    }

    public static List<TR1__Associated_Qualification__c> getAssociatedQualificationsById(Id qualificationId, Id contactId) {
        return [Select Power_Form_URL__c, TR1__Qualification__c, TR1__Qualification__r.TR1__Field_Set_ID__c, TR1__Qualification__r.TR1__Collection_Methods__c, TR1__Qualification__r.Name, TR1__Qualification__r.TR1__Instructions_External__c, TR1__Completed_Collection_Methods__c, TR1__Status__c From TR1__Associated_Qualification__c Where Id =: qualificationId AND TR1__Contact__c =: contactId];
    }
    
    public static List<TR1__Associated_Qualification__c> getAssociatedQualificationsByContactIds(List<Id> contactIds) {
       return [SELECT ID,TR1__External_ID__c,Clear_DBS__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c IN : contactIds ];
    }

    public static void upsertContactAccrual(List<TR1__Contact_Accrual__c> contactAccruals2Upsert, Schema.SObjectField keyField) {
        Database.upsert(contactAccruals2Upsert, keyField, false);
    }

    public static List<TR1__Job_Reporting__c> getJobReportingsForContact(String jobId, String candidateId, String jobContactId) {
        //getting the allowed value for picklist from Custom-setting    
        List<String> lstStageToBeIncluded = Candidate_Community__c.getValues('RegistrationDetail').Include_Stages__c.split(':');
        return [Select TR1__Contact__c , TR1__Contact__r.Name, TR1__Stage__c, TR1__Contact__r.Rating__c ,TR1__Job__c From TR1__Job_Reporting__c where TR1__Job__c =:jobId AND TR1__Application__c != '' AND TR1__Contact__c =: candidateId AND TR1__Stage__c IN: lstStageToBeIncluded AND (TR1__Job__r.TR1__Hiring_Manager__c =: jobContactId OR TR1__Job__r.TR1__Contact__c =: jobContactId)];
    }
    
    public static List<TR1__Closing_Report__c> getClosingReportsForContact(Id contactId) {
        return [Select Id, TR1__Start_Date__c, TR1__Job__r.Name from TR1__Closing_Report__c where TR1__Person_Placed__c =: contactId];
    }

    public static List<TR1__Closing_Report__c> getClosingReportById(Id closingReportId) {
        return [Select TR1__Account__c, TR1__Timesheet_Approver__c from TR1__Closing_Report__c where Id =: closingReportId];
    }

    public static List<Attachment> getAttachmentsByParentId(Id parentId) {
        return [SELECT ContentType, Name, ParentId, Description FROM Attachment where parentId =: parentId];
    }
    
    public static Attachment getAttachmentsById(Id attachmentId) {
        return [SELECT Id, ContentType, Name, ParentId, Description FROM Attachment where Id =: attachmentId LIMIT 1];
    }

    public static void upsertExpenseLineItems(List<TR1__Expense_Report_Detail__c> items2Upsert, Schema.SObjectField keyField, Boolean allOrNothing) {
        Database.upsert(items2Upsert, keyField, allOrNothing);
    }

    public static List<TR1__Job_Reporting__c> getAllJobReportingsForContactsJobs(String contactId) {
        return [SELECT Id, TR1__Contact__c FROM TR1__Job_Reporting__c WHERE TR1__Job__r.TR1__Contact__c =: contactId OR TR1__Job__r.TR1__Hiring_Manager__c =: contactId];
    }

    public static List<TR1__ContactDocument__c> getContactDocumentByIdWithParticularContactAccess(Id docId, Set<Id> availableContactIds) {
        return [SELECT  Id, TR1__Contact__c, TR1__Contact__r.Name, Name, TR1__HTML_URL__c, TR1__Internal_View_URL__c, TR1__Internal_URL__c, TR1__File_Download__c,  TR1__External_View_URL__c, TR1__External_URL__c, TR1__Version__c, TR1__Type__c, TR1__ContentDocumentId__c, TR1__isDefault__c, TR1__ContentVersionId__c, TR1__ScrambledCV__c , TR1__ContentVersionFileExtension__c  FROM TR1__ContactDocument__c  WHERE id =: docId AND TR1__Contact__c IN: availableContactIds];
    }
    
    public static List<SocialPersona> getSocialPersonaByContactId(Id contactId){
        return [Select Id, ParentId, ExternalPictureURL from SocialPersona where ParentId =:contactId];
    }
    
    public static Contact getContactRecordById(Id contactId) {
        return [Select Name, Phone, Email, Title, TR1__Skills__c,Subjects_Job_Titles__c,MobilePhone,LastName,FirstName,OwnerId,
                                                MailingCity, Nearest_Station__c, Registered_Postal_Code__c,
                                                TR1__Candidate_Status__c, Account.LEA_Region__c, Compliance_Status__c
                                            from Contact
                                            where Id = : contactId];
    }
    
    public static List<TR1__Timesheet__c> getTimesheetsByIds(String[] timesheetIds) {
        User objUser = [Select Id, ContactId, smallPhotoUrl From User where Id=: UserInfo.getUserId()]; 
    	Id idContact = objUser.ContactId;
        String idcontactPartial = '%' + ((String)idContact).left(15) + '%';
        return [Select t.TR1__Consultant_Name__c, t.TR1__Consultants_Notes__c,  t.TR1__Status__c, t.TR1__Week_Ending__c, t.TR1__Assignment_Continuing__c,
                         t.TR1__Recruiter__c, TR1__Total_Hours__c, TR1__Total_Regular_Hours__c, TR1__Total_Overtime_Hours__c, TR1__Total_Double_Time_Hours__c,Total_Days__c,
                         TR1__Total_Sick_Time_Hours__c, TR1__Total_Vacation_Hours__c,TR1__Approver__c, t.TR1__Approvers_Notes__c, t.Id, t.TR1__Job_Order__c,Pay_Rate_1__c,Pay_Rate_2__c,Pay_Rate_3__c,Timesheet_Week__c,
                         Timesheet_Approved_Date_Time__c, Timesheet_Approved_By__c, Name, TR1__Total_Days_Worked__c,Total_Half_Days__c,Charge_Rate_1__c,Charge_Rate_2__c,Charge_Rate_3__c,
                         t.TR1__Client_Name__c,t.TR1__Client__r.BillingPostalCode ,
                         t.TR1__Job_Order__r.name,t.TR1__Job_Order__r.TR1__Job_Title__c,t.TR1__Job_Order__r.Sector1__c ,t.TR1__Closing_Report__r.TR1__Job__r.TR1__Account__r.RecordType.Name,
                         t.TR1__Closing_Report__c,t.TR1__Closing_Report__r.TR1__Job_Credit__c,t.TR1__Closing_Report__r.TR1__Job_Credit__r.name,t.TR1__Closing_Report__r.TR1__PO_Number__c,
                         TR1__Approver__r.name, Timesheet_Approved_By__r.Name,(Select TR1__Date__c, TR1__Day__c, TR1__Double_Time_Hours__c, Id,DayShift__c,Half_Day__c,
                                                                               TR1__Overtime_Hours__c, TR1__Regular_Hours__c, TR1__Sick_Time_Hours__c,TR1__Timesheet__c, TR1__Vacation_Hours__c, TR1__Expenses__c,
                                                                               Start_Time__c,End_Time__c
                                                                               From TR1__Timecards__r order by TR1__date__c asc) from TR1__Timesheet__c t where id in : timesheetIds AND (TR1__Consultant__c =: idContact OR  All_Approver__c like : idcontactPartial)]; 
        
        //where Closing_Report_Schedule__c != null order by TR1__date__c asc) from TR1__Timesheet__c t where id in : timesheetIds];

    }
    
     public static List<Candidate_Availability__c> getCandidateAvailabilityByContactId(Id contactId) {
       return [Select Id,Name,Start_Date_Time__c,End_Date_Time__c,Type__c,Candidate__r.Owner.Name from Candidate_Availability__c where Candidate__c = :contactId and Start_Date_Time__c != null and End_Date_Time__c != null];
    }
    
     public static List<Closing_Report_Schedule__c> getClosingReportScheduleByCandidateAvailability(Map<Id,Candidate_Availability__c> candidateAvailabilityMap) {
        return [Select Id,Candidate_Availability__c,Name,Closing_Report__r.Booking_Type__c, Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report__r.TR1__Job__r.Name from Closing_Report_Schedule__c WHERE Status__c = 'Booked' AND Candidate_Availability__c IN :candidateAvailabilityMap.keySet()];
    }
    
    public static TR1__Timesheet_Detail__c getTimesheetById(Id tsdId) {
        return [Select Id, Name,DayShift__c,Closing_Report_Schedule__c,Half_Day__c,TR1__Regular_Hours__c from TR1__Timesheet_Detail__c where Id =: tsdId limit 1 ];
    }

}