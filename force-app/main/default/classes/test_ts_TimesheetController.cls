/*******************************************************
* Name          : test_ts_TimesheetController
* Author        : Nitin
* Create Date   : 01/08/2022
* UsedBy        : ts_TimesheetController, ts_TimesheetPrintPdfController
* Description   : Test Class
*******************************************************/
@isTest
public without sharing class test_ts_TimesheetController {

    @isTest
    public static void testMethod1(){

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
            username = 'newUser@gmail.com', 
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

        TR1__Job__c vac = new TR1__Job__c(
            OwnerId = ownerUsr.Id,
            Applicable_Days__c = 'Monday;Friday'
        );
        insert vac;

        TR1__Timesheet__c ts = new TR1__Timesheet__c(
            TR1__Job_Order__c = vac.Id,
            TR1__Consultant__c = newUser.ContactId
        );
        insert ts;

        TR1__Timesheet__c ts2 = new TR1__Timesheet__c(
            TR1__Job_Order__c = vac.Id,
            TR1__Consultant__c = newUser.ContactId
        );
        insert ts2;

        ts.TR1__Client__c = objAcc.Id;
        ts.TR1__Consultant__c = objContact.Id;
        update ts;
       
        List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>();
        for (Integer i = 0 ; i <= 5; i++) {
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.Id, TR1__Date__c = System.today() ,TR1__Double_Time_Hours__c = 12.40, TR1__Expenses__c = 32, TR1__Overtime_Hours__c=43);
            timesheetdetails.add(td);
        }
        for (Integer i = 0 ; i <= 5; i++) {
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts2.Id, TR1__Date__c = System.today() ,TR1__Double_Time_Hours__c = 12.4, TR1__Expenses__c = 32, TR1__Overtime_Hours__c=43);
            timesheetdetails.add(td);
        }
        insert timesheetdetails;

        List<String> timesheetStatus = new list<String> { 'Submitted'};

        System.RunAs(newUser){

            Test.startTest();
           
            ts_TimesheetController.getTimesheet(timesheetStatus);
            ts_TimesheetController.fetchContact();
            ts_TimesheetController.downloadPdf(ts.id);
            ts_TimesheetController.getTimesheetDetails(ts.id);
            ts_TimesheetController.sendMessageToJobOwner(ts.id, 'message for timesheet');
            ts_TimesheetController.approveRejectTimeSheet(ts.id, 'Approve', 'test note', 'Good', false, false);
            ts_TimesheetController.approveRejectTimeSheet(ts.id, 'Reject', 'test note', 'Good', false, false);
            ts_TimesheetController.approveRejectTimeSheet(ts.id, 'Approve', 'test note', 'Good', false, true);
            ts_TimesheetController.approveRejectTimeSheet(ts.id, 'Reject', 'test note', 'Good', false, true);
            ts_TimesheetController.getAllTimesheet();
            
            Test.setCurrentPageReference(new PageReference('Page.ts_TimesheetPrintPdf')); 
            System.currentPageReference().getParameters().put('Id', ts2.Id);

            ts_TimesheetPrintPdfController tst = new ts_TimesheetPrintPdfController();
            tst.calculatehours();
            Test.stopTest();
        }


    }
}