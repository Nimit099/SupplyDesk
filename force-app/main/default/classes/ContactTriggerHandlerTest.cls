@isTest
private class ContactTriggerHandlerTest {        

    @TestSetup
    public static void testSetupData(){
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
    }

    @isTest 
    public static void contactTriggerTest_1() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        List<Contact> conList = new List<Contact>();
        // Contact Record #1
        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Durham;Durham",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con);

        // Contact Record #2
        Contact con2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#2', Email = 'testingdata#2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Yorkshire & Humberside', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Bradford;Bradford",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con2);

        // Contact Record #3
        Contact con3 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#3', Email = 'testingdata#3@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North West', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Blackpool;Blackpool",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con3);

        // Contact Record #4
        Contact con4 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#4', Email = 'testingdata#4@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Derbyshire;Derbyshire",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con4);

        // Contact Record #4_1
        Contact con4_1 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#4_1', Email = 'testingdata#4_1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Northhamptonshire;Northhamptonshire",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con4_1);

        // Contact Record #4_2
        Contact con4_2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#4_2', Email = 'testingdata#4_2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Rutland;Rutland",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con4_2);

        insert conList;
    }

    @isTest 
    public static void contactTriggerTest_1_1() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        List<Contact> conList = new List<Contact>();
        // Contact Record #5
        Contact con5 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#5', Email = 'testingdata#5@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Eastern England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Essex;Essex",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con5);

        // Contact Record #6
        Contact con6 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#6', Email = 'testingdata#6@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Greater London', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Bexley;Bexley",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con6);

        // Contact Record #6_1
        Contact con6_1 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#6_1', Email = 'testingdata#6_1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Greater London', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Sutton;Sutton",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con6_1);

        // Contact Record #6_2
        Contact con6_2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#6_2', Email = 'testingdata#6_2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Greater London', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Croydon;Croydon",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con6_2);

        // Contact Record #7
        Contact con7 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7', Email = 'testingdata#7@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South East England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Buckinghamshire;Buckinghamshire",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con7);

        // Contact Record #7_1
        Contact con7_1 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7_1', Email = 'testingdata#7_1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South East England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Brighton and Hove;Brighton and Hove",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con7_1);

        // Contact Record #7_2
        Contact con7_2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7_2', Email = 'testingdata#7_2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South East England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Hampshire;Hampshire",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con7_2);

        // Contact Record #7_3
        Contact con7_3 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7_3', Email = 'testingdata#7_3@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South East England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Kent;Kent",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con7_3);

        // Contact Record #8
        Contact con8 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#8', Email = 'testingdata#8@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South West England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Bournemouth;Bournemouth",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con8);

        // Contact Record #8_1
        Contact con8_1 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#8_1', Email = 'testingdata#8_1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South West England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Gloustershire;Gloustershire",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con8_1);

        // Contact Record #8_2
        Contact con8_2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#8_2', Email = 'testingdata#8_2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'South West England', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Swindon;Swindon",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con8_2);

        // Contact Record #9
        Contact con9 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#9', Email = 'testingdata#9@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Wales', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Newport;Newport",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con9);

        insert conList;
    }

    @isTest 
    public static void contactTriggerTest_2() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        List<Contact> conList = new List<Contact>();
        // Contact Record #1
        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","EYFS;EYFS"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Social Media;Social Media"],"Source":[";","Instagram;Instagram",";",";"]}');
        conList.add(con);

        // Contact Record #2
        Contact con2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#2', Email = 'testingdata#2@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Primary Teacher;Secondary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Yorkshire & Humberside', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":["ACT;ACT",";",";"],"Qualification":[";","Primary & Secondary;Primary & Secondary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Email;Email"],"Source":[";",";",";",";"]}');
        conList.add(con2);

        // Contact Record #3
        Contact con3 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#3', Email = 'testingdata#3@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Primary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North West', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","Primary;Primary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Event;Event"],"Source":[";",";",";",";"]}');
        conList.add(con3);

        // Contact Record #4
        Contact con4 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#4', Email = 'testingdata#4@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Secondary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","Secondary;Secondary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Queensland University of Technology;Queensland University of Technology",";",";"]}');
        conList.add(con4);

        // Contact Record #5
        Contact con5 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#5', Email = 'testingdata#5@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Special Needs Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;;;Testing Only', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","Special Needs;Special Needs"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Auckland University;Auckland University",";",";"]}');
        conList.add(con5);

        // Contact Record #6 || Test data for throwing Exception
        Contact con6 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#6', Email = 'testingdata#6@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'FE Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","FE;FE"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Auckland University;Auckland University",";",";"]}');
        conList.add(con6);

        // Contact Record #7 || Test data for throwing Exception
        Contact con7 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7', Email = 'testingdata#7@test.com', Candidate_Type__c = 'Support Staff', Job_Titles__c = 'TA General', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","TA General;TA General"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Auckland University;Auckland University",";",";"]}');
        conList.add(con7);

        // Contact Record #8 || Test data for throwing Exception
        Contact con8 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#8', Email = 'testingdata#8@test.com', Candidate_Type__c = 'Support Staff', Job_Titles__c = 'Other', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["AUS_site"],"Regional Area":[";",";",";"],"Qualification":[";","TA General;TA General"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Auckland University;Auckland University",";",";"]}');
        conList.add(con8);

        insert conList;

    }

    @isTest 
    public static void contactTriggerTest_3() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        List<Contact> conList = new List<Contact>();
        // Contact Record #1
        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","EYFS;EYFS"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Social Media;Social Media"],"Source":[";","Instagram;Instagram",";",";"]}');
        conList.add(con);

        // Contact Record #2
        Contact con2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#2', Email = 'testingdata#2@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Primary Teacher;Secondary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Yorkshire & Humberside', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","Primary & Secondary;Primary & Secondary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Email;Email"],"Source":[";",";",";",";"]}');
        conList.add(con2);

        // Contact Record #3
        Contact con3 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#3', Email = 'testingdata#3@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Primary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North West', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","Primary;Primary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["Event;Event"],"Source":[";",";",";",";"]}');
        conList.add(con3);

        // Contact Record #4
        Contact con4 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#4', Email = 'testingdata#4@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Secondary Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;;;Testing Only', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","Secondary;Secondary"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Niagara University;Niagara University",";",";"]}');
        conList.add(con4);

        // Contact Record #5
        Contact con5 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#5', Email = 'testingdata#5@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'Special Needs Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","Special Needs;Special Needs"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Niagara University;Niagara University",";",";"]}');
        conList.add(con5);

        // Contact Record #6
        Contact con6 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#6', Email = 'testingdata#6@test.com', Candidate_Type__c = 'Qualified Teacher', Job_Titles__c = 'FE Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","FE;FE"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Niagara University;Niagara University",";",";"]}');
        conList.add(con6);

        // Contact Record #7
        Contact con7 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#7', Email = 'testingdata#7@test.com', Candidate_Type__c = 'Support Staff', Job_Titles__c = 'TA General', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","TA General;TA General"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Niagara University;Niagara University",";",";"]}');
        conList.add(con7);

        // Contact Record #8
        Contact con8 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#8', Email = 'testingdata#8@test.com', Candidate_Type__c = 'Support Staff', Job_Titles__c = 'Other', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'East Midlands', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Alert__c = 'within 24 months;Testing Only', Form_Map_Data__c = '{"GFormContact":["CAN_site"],"Qualification":[";","TA General;TA General"],"Years of Experience":["> 10 years;> 10 years"],"Source Category":["University;University"],"Source":[";","Niagara University;Niagara University",";",";"]}');
        conList.add(con8);

        insert conList;

    }

    @isTest 
    public static void contactTriggerTest_4() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        List<Contact> conList = new List<Contact>();
        // Contact Record #1
        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Durham;Durham",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con);

        // Contact Record #2
        Contact con2 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#2', Email = 'testingdata#2@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'Yorkshire & Humberside', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Bradford;Bradford",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con2);

        // Contact Record #3
        Contact con3 = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#3', Email = 'testingdata#3@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North West', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Form_Map_Data__c = '{"GFormContact":["UK_site"],"Qualification":["EYFS;EYFS",";"],"Years of Experience":["< 2 years;< 2 years"],"Preferred LEA":[";",";",";",";",";","Blackpool;Blackpool",";",";",";",";"],"Source":["Indeed;Indeed",";",";",";",";",";",";"],"Time will Travel":["10 minutes;10 minutes"]}');
        conList.add(con3);

        insert conList;

        conList[0].Right_to_work__c = 'No';
        conList[1].References_not_agreed__c = 'Yes';
        conList[1].Right_to_work__c = 'Yes';
        conList[1].Cautions_Convictions__c = 'No';
        conList[1].Disciplinary__c = 'No';
        conList[2].References_not_agreed__c = 'No';
        conList[2].Right_to_work__c = 'Yes';
        conList[2].Cautions_Convictions__c = 'Yes';
        conList[2].Disciplinary__c = 'Yes';
        update conList;

    }

    @isTest 
    public static void contactTriggerTest_5() {
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];

        Contact con = new Contact(RecordTypeId = rcId, AccountId = acc.Id, FirstName = 'Testing', LastName = 'Data#1', Email = 'testingdata#1@test.com', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c  = 'EYFS', Job_Titles__c = 'EYFS Teacher', Year_Key_Stage__c = 'EYFS', Assignment_Type__c = 'Day to Day', LEA__c = 'North East', Preferred_LEA__c = 'Durham', Source_Category__c = 'Social Media', TR1__Source__c = 'Facebook', References_Candidate__c = 'Yes', Right_to_work_Candidate__c = 'Yes', DBS_Tick_Box__c = 'Yes', Cautions_Convictions_Candidate__c = 'No', Disciplinary_Candidate__c = 'No', TR1__State_Area__c = 'UK', Safeguarding_Training_Hidden__c = 'No');
        insert con;

        TR1__Qualification__c qual = new TR1__Qualification__c(Name = 'Safeguarding', Abbreviation__c = 'SAFE', Field_Set_ID_c__c = 'Safeguarding_c', Require_Documents__c = FALSE, Sort_Order__c = 18, TR1__Collection_Methods__c = 'Field Update;Upload File', TR1__Field_Set_ID__c = 'Safeguarding');
        insert qual;

        TR1__Associated_Qualification__c objAssoQual = new TR1__Associated_Qualification__c(TR1__Qualification__c = qual.Id, TR1__Contact__c = con.Id, Clear_DBS__c = true, TR1__Status__c = 'Requested', DBS_Disclosure_Notes__c = 'test'); 
        insert objAssoQual;

        TR1__Qualification__c qual1 = new TR1__Qualification__c(Name = 'Terms and Registration Forms', Abbreviation__c = 'TOE', Field_Set_ID_c__c = 'TOE_c', Require_Documents__c = FALSE, Sort_Order__c = 24, TR1__Collection_Methods__c = 'Field Update;Upload File', TR1__Field_Set_ID__c = 'TOE');
        insert qual1;

        TR1__Associated_Qualification__c objAssoQual1 = new TR1__Associated_Qualification__c(TR1__Qualification__c = qual1.Id, TR1__Contact__c = con.Id, Clear_DBS__c = true, TR1__Status__c = 'Requested', DBS_Disclosure_Notes__c = 'test');
        insert objAssoQual1;

        Test.startTest();
            con.Safeguarding_Training_Hidden__c = 'GForm_Safeguarding;;;Yes';
            update con;
        Test.stopTest();

    }

    @isTest
    public static void createContact() { 
        test.startTest();
        User u1=TestUtility.getUserDetail();
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        System.runAs(u1){
            TR1__TalentRoverProperties__c props = TR1__TalentRoverProperties__c.getOrgDefaults();
            if(props!=null){
                props.TR1__Disable_Zipcode_Mapping__c = true; 
                Upsert props;
            }
            List<TR1__Zip_Code_Mapping__c> zipList = new List<TR1__Zip_Code_Mapping__c>();
            TR1__Zip_Code_Mapping__c zipcode = new TR1__Zip_Code_Mapping__c(TR1__Regional_Area__c='test',Name='AC5ee',TR1__State_Area__c='testing');
            zipList.add(zipcode);
            TR1__Zip_Code_Mapping__c zipcode1 = new TR1__Zip_Code_Mapping__c(TR1__Regional_Area__c='test',Name='GT56',TR1__State_Area__c='testing');
            zipList.add(zipcode1);
            TR1__Zip_Code_Mapping__c zipcode2 = new TR1__Zip_Code_Mapping__c(TR1__Regional_Area__c='test',Name='UT6',TR1__State_Area__c='testing');
            zipList.add(zipcode2);
            TR1__Zip_Code_Mapping__c zipcode3 = new TR1__Zip_Code_Mapping__c(TR1__Regional_Area__c='test',Name='RT',TR1__State_Area__c='testing');
            zipList.add(zipcode3);
            insert zipList;

            List<Contact> conList = new List<Contact>();
            Contact con = new Contact(Salutation = 'Mr', RecordTypeId = rcId, Pay_Type__c='OTT',Qualified_Schools_Candidate__c='Yes', LastName='test Contact Last',Email='test@test32525.com', Compliance_Status__c ='Cleared',
                                    Employee_Status__c='0',National_Insurance__c='352352',Pay_Method__c='Cheque', Year_Key_Stage__c ='Foundation Stage 3-5yrs',Compliance_Owner__c=u1.Id, Subject__c ='Classics',OtherPostalCode='AC5ee', Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='EYFS Teacher',Assignment_Type__c='Day to Day');
            conList.add(con);
            Contact con1 = new Contact(Salutation = 'Mr', RecordTypeId = rcId,Pay_Type__c='OTT',Qualified_Schools_Candidate__c='Yes', LastName='test Contact Last1',Email='test1@test32525.com', Compliance_Status__c ='Cleared',
                                    Employee_Status__c='0',National_Insurance__c='352352',Pay_Method__c='Cheque', Year_Key_Stage__c ='Foundation Stage 3-5yrs',Compliance_Owner__c=u1.Id, Subject__c ='Classics',OtherPostalCode='GT56H', Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='EYFS Teacher',Assignment_Type__c='Day to Day');
            conList.add(con1);
            Contact con2 = new Contact(Salutation = 'Mr', RecordTypeId = rcId,Pay_Type__c='OTT',Qualified_Schools_Candidate__c='Yes', LastName='test Contact Last2',Email='test2@test32525.com', Compliance_Status__c ='Cleared',
                                    Employee_Status__c='0',National_Insurance__c='352352',Pay_Method__c='Cheque', Year_Key_Stage__c ='Foundation Stage 3-5yrs',Compliance_Owner__c=u1.Id, Subject__c ='Classics',OtherPostalCode='UT6HJ', Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='EYFS Teacher',Assignment_Type__c='Day to Day');
            conList.add(con2);
            Contact con3 = new Contact(Salutation = 'Mr', RecordTypeId = rcId,Pay_Type__c='OTT',Qualified_Schools_Candidate__c='Yes', LastName='test Contact Last3',Email='test3@test32525.com', Compliance_Status__c ='Cleared',
                                    Employee_Status__c='0',National_Insurance__c='352352',Pay_Method__c='Cheque', Year_Key_Stage__c ='Foundation Stage 3-5yrs',Compliance_Owner__c=u1.Id, Subject__c ='Classics',OtherPostalCode='RT65H', Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='EYFS Teacher',Assignment_Type__c='Day to Day');
            conList.add(con3);   
            insert conList;

            List<Candidate_Availability__c> caList = [select Name,Candidate__c,Start_Date__c, Id from Candidate_Availability__c where Candidate__c =:conList[0].Id AND Start_Date__c > = :date.Today().addDays(1)];
            System.assertEquals(10, caList.size(), 'Candidate Availability count 10.'); 
            delete caList[0];
            
            List<contact> contactList = [select Name, Id from contact where Id = :conList[0].Id];
            contactList[0].Compliance_Status__c = 'Clearance Pending';
            update contactList; 
            
            caList = [select Name,Candidate__c,Start_Date__c, Id from Candidate_Availability__c where Candidate__c =:conList[0].Id AND Start_Date__c > = :date.Today().addDays(1)];
        
        }
        test.stopTest();
    }
}