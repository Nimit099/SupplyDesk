@isTest
public with sharing class SendRejectContactStatusBatch_Test {
    
    @TestSetup
    public static void testSetupData(){
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
        Contact con = new Contact(RecordTypeId = rcId, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Eastern England', Preferred_LEA__c = 'Essex', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK');
        insert con;
    }

    @isTest
    public static void rejectedContactStatusTest_1() {
        Contact con = [SELECT Id, Name, References_Candidate__c, Right_to_work_Candidate__c, Cautions_Convictions_Candidate__c, Disciplinary_Candidate__c FROM Contact LIMIT 1];
        con.Right_to_work__c = 'No';
        con.Right_to_work_Candidate__c = 'No';
        update con;
        //Calling Batch class || Because of the less data records in test class giving size as 10.
        Database.executeBatch(new SendRejectContactStatusBatch(), 10);
    }
}