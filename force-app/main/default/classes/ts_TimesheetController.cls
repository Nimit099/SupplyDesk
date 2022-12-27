/* ****************************************************************************************************************************
Class Name       : ts_TimesheetController
Author           : Nitin, Mihir Ramoliya, Krunal
Created Date     : 29/06/2022
Description      : This Class Used In ts_Timesheet (LWC component ) and  ts_TimesheetDetails (LWC component)
TestClass        : test_ts_TimesheetController
Code Coverage    : 81%

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Krunal                      28/07/2022          Create getAllTimesheet method, Change in approveRejectTimeSheet method

******************************************************************************************************************************/

public without sharing class ts_TimesheetController {
    
    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_Timesheet Component
    * Description        : get timesheet data for display timesheet records in ts_Timesheet Component.
    ***************************************************/
    @AuraEnabled
    public static List<TR1__Timesheet__c> getTimesheet(list<String> timesheetStatus) {
        User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId()];
        List<Schema.FieldSetMember> lstFieldsTimesheetDetail = new List<Schema.FieldSetMember>();
        List<TR1__Timesheet__c> lstTimesheet = new List<TR1__Timesheet__c>();

        List<TR1__Timesheet__c> lstTsCandidate = new List<TR1__Timesheet__c>();
        List<TR1__Timesheet__c> lstTsClient = new List<TR1__Timesheet__c>();
        
        try {
            Contact objContactPage = [Select Community_Contact_Type__c, Holiday_Accrued__c,Name from Contact where Id =:loggedInUser.ContactId];
            
            String strQuery = 'SELECT Id';
            lstFieldsTimesheetDetail = SObjectType.TR1__Timesheet__c.FieldSets.RC_TimesheetList.getFields();

            for(Schema.FieldSetMember objFSM: lstFieldsTimesheetDetail) {
                strQuery += ', ' + objFSM.getFieldPath() ;
            }

            if(!strQuery.contains('All_Approver__c')) {
                strQuery += ',All_Approver__c ';
            }
            if(!strQuery.contains('TR1__Consultant__c')) {
                strQuery += ',TR1__Consultant__c ';
            }
            strQuery += ', Client_Status__c, Candidate_Status__c ';

            strQuery += ' FROM TR1__Timesheet__c Where  ';

            String whereClause = objContactPage.Community_Contact_Type__c == 'C and C' ?  '( All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\' OR  TR1__Consultant__c =\''+ loggedInUser.ContactId+'\') AND TR1__Status__c  In ' + timesheetStatus + '':
                               (objContactPage.Community_Contact_Type__c == 'Client' ? 'All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\'AND TR1__Status__c In '+ timesheetStatus  :
                               (objContactPage.Community_Contact_Type__c == 'Candidate' ? 'TR1__Consultant__c =\''+ loggedInUser.ContactId+'\'AND TR1__Status__c  In '+ timesheetStatus+'' : ' '  ) ) ;   

            if(String.isNotBlank(whereClause)) {  
                lstTimesheet = Database.query(strQuery + whereClause + ' ORDER By CreatedDate DESC');
                for(TR1__Timesheet__c objTS : lstTimesheet) {
                    if(objTS.All_Approver__c.contains(((String)loggedInUser.ContactId).left(15))) {
                        lstTsClient.add(objTS);
                    } else if(objTS.TR1__Consultant__c == (((String)loggedInUser.ContactId).left(15))){
                        lstTsClient.add(objTS);
                    }
                }
            }
            return lstTsClient;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'getTimesheet');
            return null;
        }
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 28/07/2022
    * Last Modified Date : 28/07/2022
    * UsedBy             : ts_Timesheet Component
    * Description        : Use for get all time sheet data
    ***************************************************/
    @AuraEnabled
    public static List<TR1__Timesheet__c> getAllTimesheet() {
        try {
            User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId()];
            List<TR1__Timesheet__c> lstTimesheet = new List<TR1__Timesheet__c>();
            List<TR1__Timesheet__c> lstTsClient = new List<TR1__Timesheet__c>();
            Contact objContactPage = [Select Community_Contact_Type__c, Holiday_Accrued__c,Name from Contact where Id =:loggedInUser.ContactId];
            String strQuery = 'SELECT Id, Feedback_Modal_Open__c, Feedback_Modal_Open_Candidate__c';
            if(!strQuery.contains('All_Approver__c')) {
                strQuery += ',All_Approver__c ';
            }
            if(!strQuery.contains('TR1__Consultant__c')) {
                strQuery += ',TR1__Consultant__c ';
            }
            strQuery += ' FROM TR1__Timesheet__c Where  ';
            String whereClause = objContactPage.Community_Contact_Type__c == 'C and C' ?  'All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\' OR  TR1__Consultant__c =\''+ loggedInUser.ContactId+'\'' :
                               (objContactPage.Community_Contact_Type__c == 'Client' ? 'All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\'AND TR1__Status__c NOT In (\'Unsubmitted\',\'Not Submitted\')'  : 
                               (objContactPage.Community_Contact_Type__c == 'Candidate' ? 'TR1__Consultant__c =\''+ loggedInUser.ContactId+'\'' : ' ') ) ;
            if(String.isNotBlank(whereClause)) {  
                lstTimesheet = Database.query(strQuery + whereClause + ' ORDER By CreatedDate DESC');
                for(TR1__Timesheet__c objTS : lstTimesheet) {
                    if(objTS.All_Approver__c.contains(((String)loggedInUser.ContactId).left(15))) {
                        lstTsClient.add(objTS);
                    } else if(objTS.TR1__Consultant__c == (((String)loggedInUser.ContactId).left(15))){
                        lstTsClient.add(objTS);
                    }
                }
            }
            return lstTsClient;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'getAllTimesheet');
            return null;
        }
    }

    /***************************************************
    * Author             : Krunal
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_Timesheet Component and ts_TimesheetDetails Component
    * Description        : Used for approving and rejecting timesheet.
    ***************************************************/
    @AuraEnabled
    public static String approveRejectTimeSheet(String timesheetId, String operation, String notes, String ratingValue, Boolean rqc, Boolean openModal) {
        String message;
        try {
            User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId()];
            String logedInUserCommunityContactType = [Select Community_Contact_Type__c, Holiday_Accrued__c,Name from Contact where Id =:loggedInUser.ContactId].Community_Contact_Type__c;

            TR1__Timesheet__c timesheetForUpdate = [SELECT Id, Name, TR1__Status__c, Request_Quality_Call__c, Client_Status__c, Candidate_Status__c, Feedback_Modal_Open__c, Feedback_Modal_Open_Candidate__c FROM TR1__Timesheet__c WHERE Id =: timesheetId];
            if (operation == 'Approve') {
                if (logedInUserCommunityContactType == 'Candidate') {
                    timesheetForUpdate.Candidate_Status__c = 'Approved';
                } else {
                    timesheetForUpdate.Client_Status__c	 = 'Approved';
                }
                if (openModal == true) {
                    if (logedInUserCommunityContactType == 'Candidate') {
                        timesheetForUpdate.Feedback_Modal_Open_Candidate__c = System.today();
                    } else {
                        timesheetForUpdate.Feedback_Modal_Open__c = System.today();
                    }

                    Id idContact = [SELECT Id, ContactId FROM User where Id=: UserInfo.getUserId()].ContactId;
                    CommunityFeedback__c feedback = new CommunityFeedback__c();
                    feedback.Timesheet__c = timesheetId;
                    feedback.Person__c = idContact;
                    if (ratingValue != null || ratingValue != '') {
                        feedback.Status__c = ratingValue;
                    }
                    if (rqc != null) {
                        feedback.Request_Quality_Call__c = rqc;
                        timesheetForUpdate.Request_Quality_Call__c = rqc;
                    }
                    if (notes != null || notes !='') {
                        feedback.StatusMessage__c = notes;
                    }
                    if (logedInUserCommunityContactType == 'Candidate') {
                        feedback.Feedback_Type__c = 'Candidate Feedback';
                    } else {
                        feedback.Feedback_Type__c	 = 'Client Feedback	';
                    }
                    if (feedback != null) {
                        insert feedback;
                    }
                }
                message = 'Approved';
            } else if(operation == 'Reject') {
                if (logedInUserCommunityContactType == 'Candidate') {
                    timesheetForUpdate.Candidate_Status__c = 'Rejected';
                } else {
                    timesheetForUpdate.Client_Status__c	 = 'Rejected';
                }
                if (notes != null || notes !='') {
                    timesheetForUpdate.TR1__Approvers_Notes__c = notes;
                }
                message = 'Rejected';
            }
            if (timesheetForUpdate.Client_Status__c	 == 'Approved' &&  timesheetForUpdate.Candidate_Status__c == 'Approved') {
                timesheetForUpdate.TR1__Status__c = 'Approved';
            }
            if (timesheetForUpdate.Client_Status__c	 == 'Rejected' &&  timesheetForUpdate.Candidate_Status__c == 'Rejected') {
                timesheetForUpdate.TR1__Status__c = 'Rejected';
            }

            update timesheetForUpdate;
            return message;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'approveRejectTimeSheet');
            return null;
        } 
    }


    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_TimesheetDetails Component
    * Description        : used for sending message to jobowner its store message in Message_to_Job_Owner__c field .
    ***************************************************/
    @AuraEnabled
    public static String sendMessageToJobOwner(String timesheetId, String message) {
        try {
            TR1__Timesheet__c timesheetForUpdate = [SELECT Id, Name, TR1__Status__c, Message_to_Job_Owner__c FROM TR1__Timesheet__c WHERE Id =: timesheetId];
            if (message != null || message !='') {
                timesheetForUpdate.Message_to_Job_Owner__c = message;
            }
            update timesheetForUpdate;
            return 'sent';
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'sendMessageToJobOwner');
            return null;
        }
    }


    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_TimesheetDetails Component
    * Description        : used for getting timesheet details .
    ***************************************************/
    @AuraEnabled
    public static timesheetDetail getTimesheetDetails(String timesheetId) {
        
        timesheetDetail timesheetDetailWrapper = new timesheetDetail();
        Id userId = UserInfo.getUserId();
        
        List<Schema.FieldSetMember> lstFieldSet;
        String strContactId = [Select ContactId from User where Id =: userId].ContactId;
        Contact objContact = [SELECT Id, Name, Community_Contact_Type__c, Email FROM Contact WHERE id =: strContactId];
        Boolean isClient;

        try {
            String strQueryTS = 'SELECT Id, Name, TR1__Week_Ending__c, Timesheet_Week__c, TR1__Status__c,TR1__Consultant_Name__c , TR1__Job_Order__r.TR1__Job_Title__c, ';
            strQueryTS += 'Charge_Rate_1__c, Charge_Rate_2__c, Charge_Rate_3__c, Total_Reported_Pay__c, Total_Reported_Charge__c, ';
            strQueryTS += 'TR1__Total_Regular_Hours__c, Total_Days__c, Total_Half_Days__c, ';
            strQueryTS += 'Teacher_Rating__c, Request_Quality_Call__c, TR1__Approvers_Notes__c, ';
            strQueryTS += 'All_Approver__c, TR1__Consultant__c ';
            strQueryTS += ' from TR1__Timesheet__c where Id = \'' + timesheetId  + '\'';

            String whereClauseTSD = ' AND (All_Approver__c like \'%'+ ((String)objContact.Id).left(15) +'%\' OR TR1__Consultant__c = \'' + strContactId + '\') ';
            
            TR1__Timesheet__c ts = Database.query(strQueryTS+whereClauseTSD);
            
            String strQueryTSD = 'SELECT TR1__Date__c, TR1__Day__c, TR1__Regular_Hours__c, DayShift__c, Half_Day__c ';
            strQueryTSD += ' from TR1__Timesheet_Detail__c where TR1__Timesheet__c = \'' + timesheetId  + '\'';
            strQueryTSD += ' ORDER BY TR1__Date__c ASC';

            List<TR1__Timesheet_Detail__c> lstTimesheetDetailRecords = Database.query(strQueryTSD);

            if( (objContact.Community_Contact_Type__c == 'Candidate' || objContact.Community_Contact_Type__c == 'C and C') && strContactId == ts.TR1__Consultant__c) {
                isClient = false;
            }
            else if( (objContact.Community_Contact_Type__c == 'Client' || objContact.Community_Contact_Type__c == 'C and C') && ts.All_Approver__c.contains(((String)objContact.Id).left(15))) {
                isClient = true;
            }

            timesheetDetailWrapper.timesheet = ts;         
            timesheetDetailWrapper.timesheetDetailsList = lstTimesheetDetailRecords;         
            timesheetDetailWrapper.isClient = isClient;
         
            return timesheetDetailWrapper;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'getTimesheetDetails');
            return null;
        }
    }


    /***************************************************
    * Author             : Mihir
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_TimesheetDetails Component
    * Description        : used for downloading timesheet details as pdf .
    ***************************************************/
    @AuraEnabled
    public static string downloadPdf(String recordid){
        try {
            String pdf_url = '/apex/ts_TimesheetPrintPdf?id='+recordid;
    
            PageReference pdfPage = new PageReference(pdf_url);
            Blob pdfBlob = pdfPage.getContent();
            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
            return base64Pdf;
            
        } catch (Exception e) {
            System.debug(e);
            GenericException Exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'downloadPdf');
            return null;
        }
    }


    /***************************************************
    * Author             : Krunal
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_TimesheetDetails Component and ts_Timesheet Component
    * Description        : used for getting contact type of login user .
    ***************************************************/
    @AuraEnabled
    public static Contact fetchContact(){
        try {
            Id idContact = [SELECT Id, ContactId FROM User where Id=: UserInfo.getUserId()].ContactId;
            if(idContact != null){
                Contact con = [SELECT Id,Community_Contact_Type__c, Consol_URL__c FROM Contact WHERE Id = :idContact];
                return con;
            }
            return null; 
        } catch (Exception e) {
            System.debug(e);
            GenericException Exp = ExceptionHandler.logException(e, 'ts_TimesheetController', 'fetchContact');
            return null; 
        }   
    }


    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * UsedBy             : ts_TimesheetDetails Component and getTimesheetDetails method as wrapper class.
    * Description        : used in getTimesheetDetails method as wrapper class. .
    ***************************************************/
    public class timesheetDetail{
        @AuraEnabled public List<TR1__Timesheet_Detail__c> timesheetDetailsList;
        @AuraEnabled public TR1__Timesheet__c timesheet;
        @AuraEnabled public Boolean isClient;
    }

}