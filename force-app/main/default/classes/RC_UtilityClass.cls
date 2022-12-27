/*
Developer Name : 
Description : 
*/
public with sharing class RC_UtilityClass 
{
    static TR1__Expense_Report__c objExpense;
    // for Custom setting object, have necessary value for candidate registration
    static Candidate_Community__c objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail'); 
    
    /* 
    Name : insertJob
    Parameter : None
    Purpose : Inserts a TR1__Job__c record and returns it accordingly.
    */
    
    public static User getStandartUser(String nameVariation) {
        
        User u = [select id from user LIMIT 1];
        
        if(u == null) {
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
    		User usr = new User(LastName = 'LIVESTON',
                             FirstName='JASON',
                             Alias = 'jliv',
                             Email = 'jason'+nameVariation+'@af.com',
                             Username = nameVariation+'@af.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US'
                             );
       		insert usr;
            u = usr;
		}
        
       return u;
    }
    public static TR1__Job__c insertJob()
    {
        TR1__Job__c objJob = new TR1__Job__c(); 
        objJob.OwnerId = getStandartUser('ghjhh').Id;
        insert objJob;
        return objJob;
    }
    
    /*
    Name : insertJob
    Parameter : String
    Purpose : Inserts a TR1__Timesheet__c record and returns it accordingly.
    */
    public static TR1__Timesheet__c insertTimeSheet(String strJobId)
    {
        TR1__Timesheet__c objTimeSheet = new TR1__Timesheet__c(TR1__Job_Order__c = strJobId);
        insert objTimeSheet;
        return objTimeSheet;
    }
    
    /*
    Name : insertTimeSheetDetail
    Parameter : String
    Purpose : Inserts a TR1__Timesheet_Detail__c record and returns it accordingly.
    */
    public static TR1__Timesheet_Detail__c insertTimeSheetDetail(String strTimeSheetId)
    {
        TR1__Timesheet_Detail__c objTimeSheetDetail = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = strTimeSheetId);
        insert objTimeSheetDetail;
        return objTimeSheetDetail;
    }
    
    /*
    Name : returnCommunityUser
    Parameter : None
    Purpose : inserts and returns community User
    */ 
    public static User returnCommunityUser()
    {
        User standUser = getStandartUser('fdsfsfes');

        RC_UtilityClass objUtility = new RC_UtilityClass();
        
        Account objAcc = new Account (Name = 'newAcc1', Account_Code_S__c = '12345');
        insert objAcc;
        
        Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser', TR1__Candidate_Status__c = 'Placed', TR1__Client_Status__c = 'Active', OwnerId = standUser.Id, Subject__c = 'Art', Year_Key_Stage__c = 'Y5(KS2)');
        objContact.Trained_As__c = 'Cover Supervisor';
        objContact.Sector__c = 'Junior';
        objContact.Job_Titles__c = 'Acting Assistant Principal';
        objContact.Assignment_Type__c = 'Long Term';
        objContact.Compliance_Status__c = 'Not Registered';
        objContact.Pay_Type__c = '';
        objContact.TR1__Candidate_Status__c = 'Placed';
        objContact.Qualified_Schools_Candidate__c = 'YES';
        objContact.Phone = '5343434';
        objContact.MobilePhone = '3232323';
        objContact.Email = 'testEmail@gmail.com';
        objContact.Payroll_Number__c = '43434';
        insert objContact;
         
        
        Profile objProfile = [select Id,name from Profile where name ='Recruitment Community User' limit 1];
        
        User newUser = new User(
            profileId = objProfile.id, 
            username = 'newUser@yahoo.com', 
            email = 'pb@ff.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname', 
            contactId = objContact.id
        );
        
        insert newUser;
        
        return newUser; 
    }
    
    /*
    Name : returnExpenseReport
    Parameter : None
    Purpose : inserts and returns TR1__Expense_Report__c object.
    */ 
    public static TR1__Expense_Report__c returnExpenseReport()
    {
        Contact objContact = new Contact(Firstname = 'Test', Lastname = 'Conatct1', Subject__c = 'Art', Year_Key_Stage__c = 'Y5(KS2)');
        insert objContact;
        //Submitted
        //objExpense = new TR1__Expense_Report__c(TR1__Consultant__c = objContact.Id, TR1__Status__c = 'Approved');
        objExpense = new TR1__Expense_Report__c(TR1__Consultant__c = objContact.Id, TR1__Status__c = 'Submitted');
        insert objExpense; 
        
        return objExpense;
    }
    
    /*
    Name : returnExpenseReportDetail
    Parameter : None
    Purpose : inserts and returns TR1__Expense_Report_Detail__c object.
    */ 
    public static TR1__Expense_Report_Detail__c returnExpenseReportDetail() 
    {
        TR1__Expense_Report_Detail__c objExpReport = new TR1__Expense_Report_Detail__c();
        objExpReport.TR1__Expense_Report__c = objExpense.id;
        insert objExpReport; 
        return objExpReport; 
    }
    
    public static User returnCommunityContactTypeUser(String contactType) {
        return returnCommunityContactTypeUser(contactType, '');
        
    }
    
    public static User returnCommunityContactTypeUser(String contactType, String nameVariation) 
    {
        User standUser = getStandartUser('tfawdwaaw');
        Account objAcc = new Account (Name = 'newAcc1'+ nameVariation);   
        insert objAcc;
        
        //Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser', TR1__Candidate_Status__c = 'Consult Hot', TR1__Client_Status__c = 'Active');
        Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser'+ nameVariation, OwnerId = standUser.Id, Subject__c = 'Art', Year_Key_Stage__c = 'Y5(KS2)');
        objContact.Trained_As__c = 'Cover Supervisor';
        objContact.Sector__c = 'Junior';
        objContact.Job_Titles__c = 'Acting Assistant Principal';
        objContact.Assignment_Type__c = 'Long Term';
        objContact.Compliance_Status__c = 'Not Registered';
        objContact.Pay_Type__c = '';
        objContact.TR1__Candidate_Status__c = 'Placed';
        objContact.Qualified_Schools_Candidate__c = 'YES';
        objContact.Phone = '5343434';
        objContact.MobilePhone = '3232323';
        objContact.Email = nameVariation + '@gmail.com';
        if(contactType == 'c&c')
        {
            objContact.TR1__Candidate_Status__c = 'Consult Hot';
            objContact.TR1__Client_Status__c = 'Active';
        }   
        else if(contactType == 'client')
        {
            objContact.TR1__Candidate_Status__c = 'Prospect';
            objContact.TR1__Client_Status__c = 'Active';
        }
        else if(contactType == 'candidate')
        {
            objContact.TR1__Candidate_Status__c = 'Placed';
            objContact.TR1__Client_Status__c = 'Not Applicable';
        }
        insert objContact;
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        //System.runAs ( thisUser ) 
        //{
            Profile objProfile = [select Id,name from Profile where name ='Recruitment Community User' limit 1]; 
            
            User newUser = new User(
                profileId = objProfile.id, 
                username = 'newUser1'+ nameVariation +'@yahoo.com', 
                email = 'pb'+ nameVariation +'@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias = nameVariation, 
                lastname='lastname'+ nameVariation, 
                contactId = objContact.id
            );
            insert newUser;
            //thisUser =  [ select Id,contactId,accountId from User where Id = :newUser.Id ] ;   
            //System.debug('--- thisUser.accountId : '+thisUser.accountId);
        //}
        return newUser; 
        
    }
    //TR1__Closing_Report__c objClosingReport = RC_UtilityClass.returnClosingReport();
    public static TR1__Closing_Report__c returnClosingReport()
    {
        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c();
        objClosingReport.TR1__Job_Percentage__c = 20;
        objClosingReport.TR1__Candidate_Percentage__c  = 20;
        objClosingReport.TR1__Marketing_Percentage__c  = 20; 
        objClosingReport.TR1__Other_Percentage__c  = 20;
        objClosingReport.TR1__Other2_Percentage__c = 20; 
        objClosingReport.TR1__Job__c = insertJob().id; 
        insert objClosingReport; 
        return objClosingReport;
    }
    
        public static TR1__Closing_Report__c returnClosingReportWithApprover(User client, User candidate)
    {
        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c();
        objClosingReport.TR1__Job_Percentage__c = 20;
        objClosingReport.TR1__Candidate_Percentage__c  = 20;
        objClosingReport.TR1__Marketing_Percentage__c  = 20; 
        objClosingReport.TR1__Other_Percentage__c  = 20;
        objClosingReport.TR1__Other2_Percentage__c = 20; 
        objClosingReport.TR1__Job__c = insertJob().id;
        objClosingReport.TR1__Timesheet_Approver__c = client.ContactId;
        objClosingReport.TR1__Candidate_Credit__c = insertJob().OwnerId;
        objClosingReport.TR1__Person_Placed__c = candidate.contactId;
        objClosingReport.TR1__Job_Credit__c = insertJob().OwnerId; 
        insert objClosingReport; 
        return objClosingReport;
    }
    
    public static Id createAndGetContactId(String contactName)
    {
       Account acc = new Account(Name = 'Test Account', Account_Code_S__c = '12345');
       acc.Account_Code_S__c = '6886';
       insert acc;
        
       Contact con = new Contact (LastName = contactName, AccountId = acc.Id);
       con.Payroll_Number__c = '43434';
       insert con;
       return con.Id; 
    }
}