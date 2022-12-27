@isTest
public with sharing class ContentDocumentLinkTriggerHandler_Test {

    @TestSetup
    public static void testSetupData(){
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Durham;Durham",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        insert con;
    }

    @isTest 
    public static void contentDoclinkTrigMethod1() {
        Contact con = [SELECT Id, Name, References_Candidate__c, Right_to_work_Candidate__c, Cautions_Convictions_Candidate__c, Disciplinary_Candidate__c FROM Contact LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(Title = 'a picture', PathOnClient = 'Pic.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = con.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }   
}