public without sharing class ts_MyQualificationDetailController {


    @AuraEnabled
    public static String getContactId(){

        System.debug('In getContactId');

        User u  = [SELECT Id,ContactId from User where Id=:UserInfo.getUserId()];
        if(String.isNotBlank(u.contactId)){
            return u.ContactId;
        }
        else{
            return 'Id null';
        }
        
    }

    @AuraEnabled(cacheable=false)
    public static void editQuali(Id conId,String qfname,TR1__Associated_Qualification__c qual){
        System.debug('qual>>'+qual);
        TR1__Associated_Qualification__c qualList = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:conId AND qualificationName__c =: qfname LIMIT 1];
        if(qual.qualificationName__c == 'CV'){
            qualList.Gaps_Explanation__c = qual.Gaps_Explanation__c;
            qualList.CV_Submitted__c = qual.CV_Submitted__c;
            qualList.CV_Received__c = qual.CV_Received__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        
        else if(qual.qualificationName__c == 'Right to Work'){
            qualList.Permanent_Right_to_Work_in_UK__c = qual.Permanent_Right_to_Work_in_UK__c;
            qualList.Documents__c = qual.Documents__c;
            qualList.Work_Permit_OR_Visa_Expiry_Date__c = qual.Work_Permit_OR_Visa_Expiry_Date__c;            
        }
        else if(qual.qualificationName__c == 'Teacher Qualification'){
            qualList.NCTL_Number__c = qual.NCTL_Number__c;
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.Qualification_Type__c = qual.Qualification_Type__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'Overseas Police Check'){
            qualList.Overseas_Police_Check__c = qual.Overseas_Police_Check__c;
            qualList.Live_Worked_Overseas_Start_Date__c = qual.Live_Worked_Overseas_Start_Date__c;
            qualList.Live_Worked_Overseas_End_Date__c = qual.Live_Worked_Overseas_End_Date__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'Overseas Teacher Qualifications'){
            qualList.NCTL_Number__c = qual.NCTL_Number__c;
            qualList.NARIC_Approved__c = qual.NARIC_Approved__c;
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.Qualification_Type__c = qual.Qualification_Type__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'ID'){
            qualList.Group_1_ID_Type__c = qual.Group_1_ID_Type__c;
            qualList.Name_Change_Document__c = qual.Name_Change_Document__c;
            qualList.Group_2a_ID_Type__c = qual.Group_2a_ID_Type__c;
            qualList.Group_2b_ID_Type__c = qual.Group_2b_ID_Type__c;            
            System.debug('qual.Group_2a_ID_Type__c>>>'+qual.Group_2a_ID_Type__c);
            System.debug('qual.Group_2b_ID_Type__c>>>'+qual.Group_2b_ID_Type__c);
        }
        else if(qual.qualificationName__c == 'Safeguarding'){
            qualList.Safeguarding_Date_Completed__c = qual.Safeguarding_Date_Completed__c;
        }
        else if(qual.qualificationName__c == 'Emergency Contact'){
            qualList.Relationship_to_You__c = qual.Relationship_to_You__c;
            qualList.Emergency_Contact_Address__c = qual.Emergency_Contact_Address__c;
            qualList.Emergency_Contact_Home_Phone__c = qual.Emergency_Contact_Home_Phone__c;
            qualList.Emergency_Contact_Mobile_Phone__c = qual.Emergency_Contact_Mobile_Phone__c;
            qualList.Emergency_Contact_Work_Phone__c = qual.Emergency_Contact_Work_Phone__c;
            qualList.Emergency_Contact_Name__c = qual.Emergency_Contact_Name__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'DBS'){
            System.debug('Perm');
            qualList.DBS_Form_Number__c = qual.DBS_Form_Number__c;
            qualList.Update_Service_Status_Check__c = qual.Update_Service_Status_Check__c;
        }
        else if(qual.qualificationName__c == 'Post 16 Qualifications'){
            System.debug('Perm');
            qualList.SET_Registration_Number__c = qual.SET_Registration_Number__c;
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.SET_Expiry_Date__c = qual.SET_Expiry_Date__c;
            qualList.QTLS__c = qual.QTLS__c;
            qualList.Qualification_Type__c = qual.Qualification_Type__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'Early Years Qualifications'){
            System.debug('Perm');
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.Qualification_Type__c = qual.Qualification_Type__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'Support Qualifications'){
            System.debug('Perm');
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.Qualification_Type__c = qual.Qualification_Type__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'International'){
            System.debug('Perm');
            qualList.Seeking_International_Position__c = qual.Seeking_International_Position__c;
            qualList.Choice_of_Country__c = qual.Choice_of_Country__c;
        }
        else if(qual.qualificationName__c == 'Barred List'){
            System.debug('Perm');
            qualList.Barred_Check_URL__c = qual.Barred_Check_URL__c;
            qualList.Barred_List_Results__c = qual.Barred_List_Results__c;
            qualList.EWC_Registration_Checked_Date__c = qual.EWC_Registration_Checked_Date__c;
            qualList.EWC__c = qual.EWC__c;
            qualList.Barred_List_Date_Checked__c = qual.Barred_List_Date_Checked__c;
            qualList.Barred_List_Expiry_Date_New__c = qual.Barred_List_Expiry_Date_New__c;
        }
        else if(qual.qualificationName__c == 'References'){
            System.debug('Perm');
            qualList.Reference_Sent_Date__c = qual.Reference_Sent_Date__c;
            qualList.Reference_1_Text_Name__c = qual.Reference_1_Text_Name__c;
            qualList.Reference_Received_Date__c = qual.Reference_Received_Date__c;
            qualList.Reference_1_Contact_Details__c = qual.Reference_1_Contact_Details__c;
            qualList.Reference_1_Email__c = qual.Reference_1_Email__c;
            qualList.Reference_1_Date_Range_End__c = qual.Reference_1_Date_Range_End__c;
            qualList.Reference_1_Type__c = qual.Reference_1_Type__c;
            qualList.Reference_1_Received__c = qual.Reference_1_Received__c;
            qualList.Reference_1_Rating__c = qual.Reference_1_Rating__c;
            qualList.Reference_2_Sent_Date__c = qual.Reference_2_Sent_Date__c;
            qualList.Reference_2_Name__c = qual.Reference_2_Name__c;
            qualList.Reference_2_Received_Date__c = qual.Reference_2_Received_Date__c;
            qualList.Reference_2_Contact_Details__c = qual.Reference_2_Contact_Details__c;
            qualList.Reference_2_Date_Rage__c = qual.Reference_2_Date_Rage__c;
            qualList.Reference_2_Email__c = qual.Reference_2_Email__c;
            qualList.Reference_2_Date_Range_End__c = qual.Reference_2_Date_Range_End__c;
            qualList.Reference_2_Type__c = qual.Reference_2_Type__c;
            qualList.Reference_2_Received__c = qual.Reference_2_Received__c;
            qualList.Reference_2_Rating__c = qual.Reference_2_Rating__c;
            qualList.Reference_3_Sent_Date__c = qual.Reference_3_Sent_Date__c;
            qualList.Reference_3_Text_Name__c = qual.Reference_3_Text_Name__c;
            qualList.Reference_3_Received_Date__c = qual.Reference_3_Received_Date__c;
            qualList.Reference_3_Contact_Details__c = qual.Reference_3_Contact_Details__c;
            qualList.Reference_3_Date_Range__c = qual.Reference_3_Date_Range__c;
            qualList.Reference_3_Email__c = qual.Reference_3_Email__c;
            qualList.Reference_3_Date_Range_End__c = qual.Reference_3_Date_Range_End__c;
            qualList.Reference_3_Type__c = qual.Reference_3_Type__c;
            qualList.Reference_3_Received__c = qual.Reference_3_Received__c;
            qualList.Reference_3_Rating__c = qual.Reference_3_Rating__c;
            qualList.TR1__Status__c = 'Submitted';
        }
        else if(qual.qualificationName__c == 'Upload Photo'){
            qualList.TR1__Status__c = 'Submitted';
        }
        System.debug('qualList>>>'+qualList);
        update qualList;
        System.debug('In editQualification');
    }

    @AuraEnabled
    public static List<String> saveCV(String parentId,String description, String fileName, String base64Data) { 
        try{


            System.debug('parentId>>>'+parentId);
            System.debug('description>>>'+description);
            TR1__Associated_Qualification__c qual = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:parentId AND qualificationName__c=:description LIMIT 1];
            System.debug('qual>>'+qual);

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            contentVersion.PathOnClient = fileName;//File name with extention            
            contentVersion.Title = fileName;//Name of the file
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
            contentVersion.Description = description;
            insert contentVersion;

            System.debug('contentVersion>>'+contentVersion);

            //After saved the Content Verison, get the ContentDocumentId
            ContentVersion contentData = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id];

            //Insert ContentDocumentLink
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentData.contentDocumentId;//Add ContentDocumentId
            contentDocumentLink.LinkedEntityId = qual.Id;//Add attachment parentId
            contentDocumentLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            contentDocumentLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert contentDocumentLink;

            System.debug('contentDocumentLink>>'+contentDocumentLink);

            List<String> lst = new List<String> {contentData.contentDocumentId, contentData.Title};
            return lst;

        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_ProfilePageController', 'saveCV');
            String data = 'getMessagelogin+   '+e.getMessage() + 'line no => '+e.getLineNumber();
            System.debug('data>>>'+data);
            List<String> lst = new List<String> {data};
            return lst;
        }

    }

    @AuraEnabled
    public static List<ContentDocument> getDocsData(String parentId, String description){
        try{

            TR1__Associated_Qualification__c qual = [SELECT Id,Gaps_Explanation__c,CV_Submitted__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:parentId AND qualificationName__c =: description];

            List<Id> contIds = new List<Id>();
            List<ContentDocumentLink> contentLinklst = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility FROM ContentDocumentLink where LinkedEntityId =: qual.Id];
            for(ContentDocumentLink cont : contentLinklst){
                contIds.add(cont.ContentDocumentId);
            }
            List<ContentDocument> contentData = [SELECT Id, Title FROM ContentDocument WHERE Id IN: contIds];
            return contentData;
        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_ProfilePageController', 'getDocsData');
            return null;
        }
    }

    @AuraEnabled
    public static List<TR1__Associated_Qualification__c> getData(){
        try {
            User u  = [SELECT Id,ContactId from User where Id=:UserInfo.getUserId()];

            List<TR1__Associated_Qualification__c> qualLst = [SELECT Id,qualificationName__c,Gaps_Explanation__c,CV_Submitted__c,CV_Received__c,
                                                            SET_Registration_Number__c,Permanent_Right_to_Work_in_UK__c,Documents__c,Work_Permit_OR_Visa_Expiry_Date__c,
                                                            NCTL_Number__c,Qualification_Type2__c,Qualification_Type__c,NARIC_Approved__c,Overseas_Police_Check__c,Live_Worked_Overseas_Start_Date__c,
                                                            Live_Worked_Overseas_End_Date__c,Relationship_to_You__c,Emergency_Contact_Address__c,Emergency_Contact_Home_Phone__c,
                                                            Emergency_Contact_Mobile_Phone__c,Emergency_Contact_Work_Phone__c,Emergency_Contact_Name__c,
                                                            SET_Expiry_Date__c,QTLS__c,Reference_Sent_Date__c,Reference_1_Text_Name__c,Reference_Received_Date__c,
                                                            Reference_1_Date_Range_End__c,Reference_1_Rating__c,Reference_2_Name__c,
                                                            Reference_2_Received_Date__c,Reference_2_Date_Rage__c,Reference_2_Date_Range_End__c,
                                                            Reference_2_Rating__c,Reference_3_Sent_Date__c,Reference_3_Text_Name__c,
                                                            Reference_3_Received_Date__c,Reference_3_Date_Range__c,Reference_3_Date_Range_End__c,
                                                            Reference_3_Rating__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c =: u.ContactId];
            return qualLst;                                                


        } catch (Exception e) {
            System.debug('exception>>>'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
}