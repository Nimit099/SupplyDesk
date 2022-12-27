@isTest
public class SendConfirmationLetterTest {

  
    
    @isTest
    public static void method(){


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
       System.runAs(katherineUser){
           
        Set<Id> mySet = new Set<Id>();
        
        Account testAccount = new Account(Name = 'Test Account',BillingState='TEst',Account_Code_S__c='32323', Email__c='test@test.com');
        insert testAccount;

        Contact testCandidate = new Contact(Pay_Type__c = 'FE Qualified', LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = testAccount.Id, TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Cleared', Compliance_Owner__c=ownerUsr.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Assignment_Type__c='', Qualified_Schools_Candidate__c = 'YES');
        insert testCandidate;

        Contact testHiringManager = new Contact(Pay_Type__c = 'FE Qualified', LastName='Test The Hiring Manager',Subject__c='Art',Email='test@test.com',AccountId = testAccount.Id, TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Cleared', Compliance_Owner__c=ownerUsr.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Assignment_Type__c='', Qualified_Schools_Candidate__c = 'YES');
        insert testHiringManager;


           Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
            Contact[] candidatelist = new Contact[]{candidate1};  
            insert candidatelist;
                          
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
         Date todayDate = system.today();

        TR1__Job__c testJob = new TR1__Job__c(TR1__Account__c = testAccount.id, TR1__Hiring_Manager__c = testHiringManager.Id,Subject2__c='Accountancy',Year_Key_Stage__c='KS2',TR1__Contact__c=testCandidate.Id);
        insert testJob;
           Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
       
           
            TR1__Closing_Report__c testClosingReport = new TR1__Closing_Report__c(TR1__Account__c = testAccount.id, Maximum_Day_Pay_Rate__c = 40 , Maximum_Half_Day_Pay_Rate__c = 20, Maximum_Hour_Charge_Rate__c = 10, RecordTypeId = crconsultingId ,TR1__Start_Date__c = System.today() , TR1__End_Date__c = System.today().addDays(6),TR1__Candidate_Percentage__c=100,
            Trial_Day__c = TRUE,
            TR1__Job_Credit__c = katherineUser.Id,
            TR1__Job__c = testJob.Id,
            Hiring_Manager__c = testHiringManager.Id,
            TR1__Person_Placed__c = testCandidate.Id);
            insert testClosingReport;
           
                   
        testClosingReport.Booking_Confirmed__c = true;
        Update testClosingReport;

    }
    }
    
}