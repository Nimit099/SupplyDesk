/*******************************************************
* Name          : ForgotPasswordNewPageControllerTest
* Author        : Krunal
* Create Date   : 01/08/2022
* UsedBy        : ForgotPasswordNewPageController
* Description   : Test Class
*******************************************************/
@isTest 
public with sharing class ForgotPasswordNewPageControllerTest {

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


        System.RunAs(newUser){

            Test.startTest();
            ForgotPasswordNewPageController controller = new ForgotPasswordNewPageController();

            controller.strUsername = 'newUser@gmail.com';
            controller.blnSuccess = true; 
            controller.returnmsg = 'test';                
            controller.returnValue = 'Success';                
            controller.tost_message = 'done';                

        
            controller.redirectAuthenticatedUser();
            controller.forgotPassword();
            controller.redirectToLogin();
           
            controller.strUsername = 'User@gmail.com';
            controller.forgotPassword();

            Test.stopTest();
        }

    }
}