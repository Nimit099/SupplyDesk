/*******************************************************
* Name          : test_ts_schedulercontroller
* Author        : Mihir
* Create Date   : 29/07/2022 
* UsedBy        : ts_schedulercontroller
* Description   : Test Class
*******************************************************/
@isTest
public with sharing class test_ts_schedulercontroller {
    
    @testSetup static void testSetup() {

        Profile sytemAdminProfileObj = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Account objAccUDND = new Account (
            Name = 'UNKNOWN DO NOT DELETE',
            Account_Code_S__c = '12342'
        );
        insert objAccUDND;

        User katherineUser = new User(
            FirstName='Katherine',
            LastName = 'Gibson',
            Alias = 'tete',
            Email = 'testTimesheet12@gmail.com',
            Username = 'testTimesheet12@gmail.com',
            ProfileId = sytemAdminProfileObj.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert katherineUser;


        User ownerUsr = new User(
            LastName = 'test',
            FirstName='Timesheet',
            Alias = 'tete',
            Email = 'testTimesheet@gmail.com',
            Username = 'testTimesheet@gmail.com',
            ProfileId = sytemAdminProfileObj.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert ownerUsr;

        Account objAcc = new Account (
            Name = 'newAcc1',
            Account_Code_S__c = '12345'
        );
        insert objAcc;

        Contact objContact = new Contact (
            AccountId = objAcc.id,
            LastName = 'portalTestUser',
            TR1__Candidate_Status__c = 'Placed',
            TR1__Client_Status__c = 'Active',
            OwnerId = ownerUsr.Id,
            Subject__c = 'Art',
            Year_Key_Stage__c = 'Y5(KS2)',
            Trained_As__c = 'Cover Supervisor',
            Sector__c = 'Junior',
            Assignment_Type__c = 'Long Term',
            Compliance_Status__c = 'Not Registered',
            Pay_Type__c = '',
            Qualified_Schools_Candidate__c = 'YES',
            Phone = '5343434',
            MobilePhone = '3232323',
            Email = 'testEmail@gmail.com',
            Payroll_Number__c = '43434'
        );
        insert objContact;

        Profile objProfile = [select Id,name from Profile where name ='Recruitment Community User' limit 1];

        User newUser = new User(
            profileId = objProfile.id, 
            username = 'newUser456@gmail.com', 
            email = 'newUser@gmail.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser',
            lastname='lastname', 
            contactId = objContact.id
        );
        insert newUser;


            Date date1 = Date.valueOf('2022-07-18T23:00:00.000+0000');
            Date date11 = Date.valueOf('2022-07-19T23:00:00.000+0000');
            Date date2 = Date.valueOf('2022-07-20');

            Candidate_Availability__c candidate_ava = new Candidate_Availability__c();
            candidate_ava.Candidate__c = objContact.id;
            candidate_ava.Type__c = 'Available';
            candidate_ava.End_Date__c = date2;
            candidate_ava.Start_Date__c = date2;
            candidate_ava.End_Date_Time__c = date1;
            candidate_ava.Start_Date_Time__c = date11;
            insert candidate_ava;

            Candidate_Availability__c candidate_ava2 = new Candidate_Availability__c();
            candidate_ava2.Candidate__c = objContact.id;
            candidate_ava2.Type__c = 'Unavailable';
            candidate_ava2.End_Date__c = date2;
            candidate_ava2.Start_Date__c = date2;
            candidate_ava2.End_Date_Time__c = date1;
            candidate_ava2.Start_Date_Time__c = date11;
            insert candidate_ava2;
            
            Candidate_Availability__c candidate_ava3 = new Candidate_Availability__c();
            candidate_ava3.Candidate__c = objContact.id;
            candidate_ava3.Type__c = 'Working for Another Agency';
            candidate_ava3.End_Date__c = date2;
            candidate_ava3.Start_Date__c = date2;
            candidate_ava3.End_Date_Time__c = date1;
            candidate_ava3.Start_Date_Time__c = date11;
            insert candidate_ava3;



    }

    

    @isTest
    public static void testMethod1(){
        User newUser = [SELECT Id, Name, ContactId FROM User WHERE username = 'newUser456@gmail.com' LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact];
        List<Candidate_Availability__c> cavail = [SELECT Id, Type__c, End_Date__c, Start_Date__c, Start_Date_Time__c, End_Date_Time__c,Candidate__c FROM Candidate_Availability__c];
        System.RunAs(newUser){

            Test.startTest();
    
            String st = '{"startDate":"2022-07-30T12:30:00.000Z","EndDate":"2022-07-30T13:30:00.000Z","TypeValue":"Available","typeValue":"Available"}';
            String stnull = 'test';
            String sts = null;
            Date datee = Date.today();
            Date dateenull  ;

            String monthStartDtStr = DateTime.newInstance(2022,01,01, 00, 00, 00).format('yyyy-MM-dd HH:mm:ss');
            Datetime startDateAvailDT = DateTime.valueOf(monthStartDtStr);

            String monthEndDtStr = DateTime.newInstance(2022,09,30, 23, 59, 59).format('yyyy-MM-dd HH:mm:ss');
            Datetime endDateAvailDT = DateTime.valueOf(monthEndDtStr);

            ts_schedulercontroller.fetchData();
            ts_schedulercontroller.saveCreateAvailRecord(st);
            ts_schedulercontroller.saveCreateAvailRecord(sts);
            ts_schedulercontroller.saveCreateAvailRecord(stnull);
            ts_schedulercontroller.displaySelectedDateAvailability(datee);

            ts_schedulercontroller.displayMonthWeekAvailability(startDateAvailDT,endDateAvailDT);
            
            String st1 = '{"startDate":"2022-11-19T12:30:00.000Z","EndDate":"2022-11-23T13:30:00.000Z","TypeValue":"Available","typeValue":"Available","sd_dr":"2022-11-19","ed_dr":"2022-11-23","st_dr":"12:30","et_dr":"13:30"}';
            ts_schedulercontroller.saveDateRange(st1);
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testMethod2(){
        Test.startTest();

        Contact con = [SELECT Id, AccountId FROM Contact];
        User newUser = [SELECT Id, Name, ContactId FROM User WHERE username = 'newUser456@gmail.com' LIMIT 1];

        Date date1 = Date.valueOf('2022-07-18T23:00:00.000+0000');
        Date date11 = Date.valueOf('2022-07-19T23:00:00.000+0000');
        Date date2 = Date.valueOf('2022-07-20');
        Candidate_Availability__c candidate_ava = new Candidate_Availability__c();
            candidate_ava.Candidate__c = con.id;
            candidate_ava.Type__c = 'Available';
            candidate_ava.End_Date__c = date2;
            candidate_ava.Start_Date__c = date2;
            candidate_ava.End_Date_Time__c = date1;
            candidate_ava.Start_Date_Time__c = date11;
        insert candidate_ava;

        Candidate_Availability__c candidate_ava2 = new Candidate_Availability__c();
            candidate_ava2.Candidate__c = con.id;
            candidate_ava2.Type__c = 'Unavailable';
            candidate_ava2.End_Date__c = date2;
            candidate_ava2.Start_Date__c = date2;
            candidate_ava2.End_Date_Time__c = date1;
            candidate_ava2.Start_Date_Time__c = date11;
        insert candidate_ava2;

        Candidate_Availability__c candidate_ava3 = new Candidate_Availability__c();
            candidate_ava3.Candidate__c = newUser.ContactId;
            candidate_ava3.Type__c = 'Working for Another Agency';
            candidate_ava3.End_Date__c = date2;
            candidate_ava3.Start_Date__c = date2;
            candidate_ava3.End_Date_Time__c = date1;
            candidate_ava3.Start_Date_Time__c = date11;
        insert candidate_ava3;

        String eventidnull ;
        ts_schedulercontroller.deleteCalEvent(eventidnull);
        ts_schedulercontroller.deleteCalEvent(candidate_ava.id);

        String monthStartDtStr = DateTime.newInstance(2022,08,01, 00, 00, 00).format('yyyy-MM-dd HH:mm:ss');
        Datetime startDateAvailDT = DateTime.valueOf(monthStartDtStr);

        String monthEndDtStr = DateTime.newInstance(2022,09,30, 23, 59, 59).format('yyyy-MM-dd HH:mm:ss');
        Datetime endDateAvailDT = DateTime.valueOf(monthEndDtStr);
        ts_schedulercontroller.displayMonthWeekAvailability(startDateAvailDT,endDateAvailDT);
        Test.stopTest();
    }

    @isTest
    public static void testMethod3(){
        String eventidnull ;
        ts_schedulercontroller.deleteCalEvent(eventidnull);
        Date dateenull  ;
    }

}