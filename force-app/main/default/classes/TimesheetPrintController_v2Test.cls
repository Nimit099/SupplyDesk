@isTest(SeeAllData=false)
public class TimesheetPrintController_v2Test {
@TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}


    /**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
*
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
    static testMethod void testUtility() {
        System.assert(TestUtility.formatDateTimefromDate(Date.today(),'15:45') != null);
        System.assert(TestUtility.accList != null);
        System.assert(TestUtility.job != null);
    }
    
    static testMethod void testTimesheetPrintController() {
        
        User communityPlacedUser  = RC_UtilityClass.returnCommunityContactTypeUser('candidate', '1');
        User communityApproverUser  = RC_UtilityClass.returnCommunityContactTypeUser('c&c', '2');
        
                 User u1=[Select Id,Name,Email,ContactId from User where email='pb@ff1.com' Limit 1];
       
        Account acc =TestUtility.getAccountDetail();
        Contact con = TestUtility.getContactDetailWithoutRT(u1, acc);
        insert con;

        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id, Subject__c ='Art', Year_Key_Stage__c ='KS1');

        TR1__Job__c[] joblist = new TR1__Job__c[]{job1};
            insert joblist;
 		
       // Contact candidate1 = new Contact(Pay_Type__c = 'FE Qualified', LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Vet Complete', Compliance_Owner__c=u1.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day', Qualified_Schools_Candidate__c = 'YES');
      
        Contact candidate1 = new Contact(Pay_Type__c = 'FE Qualified', Firstname = 'Test1', Lastname = 'Conatct1',
        TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Cleared',Subject__c='Accountancy; Art; Art and Design; Basic Skills Tutor',
        Year_Key_Stage__c='Foundation Stage 3-5yrs; Y1(KS1)',
        Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='Acting Assistant Principal',
        Assignment_Type__c='Day to Day; Long Term; Perm',Compliance_Owner__c=UserInfo.getUserId(),
        TR1__Client_Status__c = 'Not Applicable', Qualified_Schools_Candidate__c = 'YES');

        Contact[] candidatelist = new Contact[]{candidate1};
        insert candidatelist;

       // Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       // User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];

        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        

        TR1__Closing_Report__c cr1 = RC_UtilityClass.returnClosingReportWithApprover(communityApproverUser, communityPlacedUser);
           
            cr1.RecordTypeId = crconsultingId;
            cr1.TR1__Person_Placed__c=candidate1.Id;
            cr1.TR1__Candidate_Credit__c = u1.Id;
            cr1.TR1__Marketing_Credit__c = u1.Id;
            cr1.TR1__Other_Credit__c = u1.Id;
            cr1.TR1__Other2_Credit__c = u1.Id;
            cr1.TR1__Start_Date__c = Date.today().addDays(-15);
            cr1.TR1__Generate_Timesheet__c = true;
            cr1.TR1__Timesheet_Approver__c = con.Id;
           	cr1.Trial_Day__c = true;
            update cr1;
    
        Closing_Report_Schedule__c crs  = new Closing_Report_Schedule__c(Closing_Report__c = cr1.Id,Schedule_Date__c = Date.today().toStartOfWeek().addDays(1), Shift__c = 'PM');
        insert crs;

        Date sow = Date.today().toStartOfWeek();
        Date eow = Date.today().toStartOfWeek().addDays(7);
        String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
        String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');
        String query = 'SELECT Id,TR1__Payroll_Type__c,Name,Start_Date__c,End_Date__c,Job__c,Person_Placed__c,Account__c,Timesheet_Approver__c,Bill_Rate__c,Pay_Rate__c FROM Closing_Report__c WHERE Id IN (\'';
        query += cr1.Id + '\')';
        Test.StartTest();

        //Change

        Date weekenddate = Date.today().toStartOfWeek().addDays(7);
        TR1__Timesheet__c ts = new TR1__Timesheet__c();
        ts.TR1__Status__c='Unsubmitted';
        ts.TR1__Closing_Report__c =cr1.Id;
        ts.TR1__Consultant__c= communityPlacedUser.contactId;
        ts.TR1__Job_Order__c = cr1.TR1__Job__c;
        ts.TR1__Approver__c=cr1.TR1__Timesheet_Approver__c;
        ts.TR1__Client__c=cr1.TR1__Account__c;
        ts.TR1__Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
        ts.TR1__Pay_Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
        insert ts;
        List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>();
        TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c();

        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(1),TR1__Day__c='Monday',Start_Time__c='08:00 AM',End_Time__c='09:00 AM',Closing_Report_Schedule__c = crs.Id,
                                          TR1__Double_Time_Hours__c = 2, TR1__Expenses__c =2, TR1__Overtime_Hours__c = 2, TR1__Regular_Hours__c = 2, TR1__Sick_Time_Hours__c = 2, TR1__Vacation_Hours__c = 4);
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(2),TR1__Day__c='Tuesday',Start_Time__c='08:00 PM',End_Time__c='09:00 PM');
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(3),TR1__Day__c='Wednesday',Start_Time__c='09:00 AM',End_Time__c=null);
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(4),TR1__Day__c='Thursday',Start_Time__c=null,End_Time__c='09:00 PM');
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(5),TR1__Day__c='Friday',TR1__Regular_Hours__c = 41);
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(6),TR1__Day__c='Saturday');
        timesheetdetails.add(td);
        td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(7),TR1__Day__c='Sunday');
        timesheetdetails.add(td);

        insert timesheetdetails;
           
          
        /*
Test.setCurrentPage(Page.TR1__CreateTimesheet);
ApexPages.currentPage().getParameters().put('crid',cr1.Id);
//change Finish
*/

        /* ID batchprocessid = Database.executeBatch(new TR1.CreateTimeSheets(query));
Test.setCurrentPage(Page.TR1__CreateTimesheet);
ApexPages.currentPage().getParameters().put('crid',cr1.Id);
TR1__Timesheet__c ts = new TR1__Timesheet__c();
TR1.CreateTimesheetCtrl ctsc = new TR1.CreateTimesheetCtrl(new ApexPages.StandardController(ts));
ctsc.createts();
ctsc.goBack();
*/

        /*
List<TR1__Timesheet__c> timesheets = new List<TR1__Timesheet__c>([SELECT Id,
(select id from TR1__Timecards__r limit 1)
TR1__Status__c
FROM TR1__Timesheet__c
WHERE TR1__Closing_Report__c = :cr1.Id]);

if(timesheets.size() > 0 )
{
timesheets.get(0).TR1__Status__c = 'Submitted';
TR1__Timesheet_Detail__c trdetails = timesheets.get(0).TR1__Timecards__r.get(0);
trdetails.TR1__Double_Time_Hours__c = 0;
trdetails.TR1__Expenses__c =0;
trdetails.TR1__Overtime_Hours__c =0;
trdetails.TR1__Regular_Hours__c =10;
trdetails.TR1__Sick_Time_Hours__c =1;
trdetails.TR1__Vacation_Hours__c =0;
update trdetails;
update timesheets.get(0);
}*/
        
        System.runAs(communityPlacedUser){
        Test.setCurrentPage(Page.TimesheetPrintPdf_v1);
        ApexPages.currentPage().getParameters().put('timesheetids',ts.Id);
        TimesheetPrintController_v2 tpc = new TimesheetPrintController_v2();
        tpc.getPageCount();
        Test.StopTest();

       }
    }



    public User createTestUser(String a, Id conId, Id accId) {

        if(a == 'ApprC'){
            Profile p = [Select Id, Name from Profile where Name = 'Talent Rover Approver'];
            return createTestUser(p,a,conId,accId);
        }
        else{
            Profile p = [Select Id, Name from Profile where Name = 'Talent Rover Consultant'];
            return createTestUser(p,a,conId,accId);
        }

        //return new User();
    }
    public String createRandomWord() {

        String ret = 'word' + math.rint(math.random() * 100000);

        return ret;
    }
    public User createTestUser( Profile p,String a,Id conId, Id accId ) {

        String namePrefix = createRandomWord();

        User testUser = new User();
        testUser.Email              = 'admin@satrangtech.com';
        testUser.Username           = a+'_' + namePrefix + '@testuser.com';
        testUser.LastName           = 'test'+a;
        testUser.Alias              = a;
        testUser.ProfileId          = p.Id;
        testUser.LanguageLocaleKey  = 'en_US';
        testUser.LocaleSidKey       = 'en_US';
        testUser.TimeZoneSidKey     = 'America/Chicago';
        testUser.EmailEncodingKey   = 'UTF-8';
        testUser.ContactId          = conId;
        //testUser.CompanyName      = '';
        //testUser.AccountId            = accId;
        //testUser.IsPortalEnabled = true;

        insert testUser;

        return testUser;
    }

}