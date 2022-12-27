public without sharing class ts_earlyyearqualification {
    
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
        TR1__Associated_Qualification__c qualList = [SELECT Id,Update_Service_Status_Check__c,QTLS__c,SET_Expiry_Date__c,Qualification_Type2__c,SET_Registration_Number__c,Relationship_to_You__c,Emergency_Contact_Address__c,Emergency_Contact_Home_Phone__c,Emergency_Contact_Work_Phone__c,Emergency_Contact_Mobile_Phone__c,Emergency_Contact_Name__c,DBS_Form_Number__c,On_Update_Service__c,Qualification_Type__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c=:conId AND qualificationName__c =: qfname LIMIT 1];
        

        if(qual.qualificationName__c == 'Perm DBS'){
            System.debug('Inside Perm DBS');
            qualList.DBS_Form_Number__c = qual.DBS_Form_Number__c;  //Early Years Qualifications
            qualList.On_Update_Service__c = qual.On_Update_Service__c;
        }else if(qual.qualificationName__c == 'Safeguarding'){
            System.debug('Inside safeguarding');
            qualList.Safeguarding_Date_Completed__c = qual.Safeguarding_Date_Completed__c; //this is the date field
        }else if(qual.qualificationName__c == 'Emergency Contact'){
            System.debug('inside emergency contact');
            qualList.Relationship_to_You__c = qual.Relationship_to_You__c;
            qualList.Emergency_Contact_Address__c = qual.Emergency_Contact_Address__c;
            qualList.Emergency_Contact_Home_Phone__c = qual.Emergency_Contact_Home_Phone__c;
            qualList.Emergency_Contact_Mobile_Phone__c = qual.Emergency_Contact_Mobile_Phone__c;
            qualList.Emergency_Contact_Work_Phone__c = qual.Emergency_Contact_Work_Phone__c;
            qualList.Emergency_Contact_Name__c = qual.Emergency_Contact_Name__c;
        }else if(qual.qualificationName__c == 'DBS'){
            System.debug('Inside DBS');
            qualList.DBS_Form_Number__c = qual.DBS_Form_Number__c;          //this is dbs number
            qualList.Update_Service_Status_Check__c = qual.Update_Service_Status_Check__c;      //this is picklist for four options
        }else if(qual.qualificationName__c == 'Post 16 Qualifications'){
            System.debug('inside post 16 qualifications');
            qualList.SET_Registration_Number__c = qual.SET_Registration_Number__c;          //this is type string
            qualList.Qualification_Type2__c = qual.Qualification_Type2__c;
            qualList.SET_Expiry_Date__c = qual.SET_Expiry_Date__c;
            qualList.QTLS__c = qual.QTLS__c;
            qualList.Qualification_Type__c =  qual.Qualification_Type__c;           //this is restricted multi picklist 
        }

        System.debug('qualList>>>'+qualList);
        update qualList;
        System.debug('In editQualification');
    }
}