@isTest(SeeAllData=true)
public class TestTimeSheets_v1{
    public static testMethod void Test1(){

        User testUser = TestDataUtility.createUser(false);
        system.runAs(testUser){
            Account testAccount = TestDataUtility.createAccount(true);

            Contact testContact = TestDataUtility.createContact(testAccount.id,false);
            testContact.Compliance_Owner__c = testUser.Id;
            testContact.Year_Key_Stage__c = 'KS1';
            testContact.Compliance_Status__c = 'Perm';
            testContact.Pay_Type__c = 'Perm';
            testContact.Trained_As__c = 'Instructor';
            testContact.TR1__Candidate_Status__c = 'Prospect';
            testContact.Qualified_Schools_Candidate__c ='YES';
            insert testContact;

            TR1__Job__c testConsutlingJob = TestDataUtility.createJob(TestDataUtility.CONSULTING_RECORDTYPE_JOB,testAccount.id,true);

            TR1__Closing_Report__c testClosingReport = TestDataUtility.createClosingReport(TestDataUtility.CONSULTING_RECORDTYPE_CLOSINGREPORT,testAccount.Id,testConsutlingJob.Id,testContact.Id,testuser.Id,true);

            Date sow = Date.today().toStartOfWeek().addDays(7);
            Date eow = Date.today().toStartOfWeek().addDays(13);
            String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
            String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');
            Test.startTest();
            String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c, TR1__Payroll_Type__c, Timesheet_Frequency__c FROM TR1__Closing_Report__c WHERE Id = \''+testClosingReport.id+'\' AND TR1__Assignment_Ended__c=\'No\' and Timesheet_Frequency__c =\'weekly\' and  (RecordTypeId = \'';
            query += TestDataUtility.CONSULTING_RECORDTYPE_CLOSINGREPORT + '\') AND TR1__Generate_Timesheet__c = true AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';

            ID batchprocessid = Database.executeBatch(new CreateTimesheetsCustomWeekly(query,sow),50);
            Test.stopTest();
        }
    }

    public static testMethod void Test2(){

        User testUser = TestDataUtility.createUser(true);
        system.runAs(testUser){

            Account testAccount = TestDataUtility.createAccount(true);

            Contact testContact = TestDataUtility.createContact(testAccount.id,false);
            testContact.Compliance_Owner__c = testUser.Id;
            testContact.Year_Key_Stage__c = 'KS1';
            testContact.Compliance_Status__c = 'Perm';
            testContact.Pay_Type__c = 'Perm';
            testContact.Trained_As__c = 'Instructor';
            testContact.TR1__Candidate_Status__c = 'Prospect';
            testContact.Qualified_Schools_Candidate__c ='YES';
            insert testContact;

            TR1__Job__c testConsutlingJob = TestDataUtility.createJob(TestDataUtility.CONSULTING_RECORDTYPE_JOB,testAccount.id,true);
            

            TR1__Closing_Report__c testClosingReport = TestDataUtility.createClosingReport(TestDataUtility.CONSULTING_RECORDTYPE_CLOSINGREPORT,testAccount.Id,testConsutlingJob.Id,testContact.Id,testuser.Id,true);

            Date sow = Date.today().toStartOfWeek().addDays(7);
            Date eow = Date.today().toStartOfWeek().addDays(13);
            String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
            String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');

            Test.startTest();

            String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c, TR1__Payroll_Type__c, Timesheet_Frequency__c FROM TR1__Closing_Report__c WHERE Id = \''+testClosingReport.id+'\' AND TR1__Assignment_Ended__c=\'No\' and Timesheet_Frequency__c =\'weekly\' and  (RecordTypeId = \'';
            query += TestDataUtility.CONSULTING_RECORDTYPE_CLOSINGREPORT + '\') AND TR1__Generate_Timesheet__c = true AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';

            ScheduleCreateTimesheetsCustomWeekly sch = New ScheduleCreateTimesheetsCustomWeekly();
            String constr = '0 0 0 3 9 ? 2022';
            system.schedule('CreateTimesheetsCustomWeekly',constr,sch);
            
            // For test coverage for TimesheetUtility class 
            Set<Id> jobIds = New Set<Id> {testConsutlingJob.Id};
            TimesheetUtility.GetHolidaysAgaintsVacancy(jobIds);
            TimesheetUtility.GetHolidaysAgaintsVacancy(jobIds);
            Map<Id, Set<Date>> mapJobAgainstSetOfWeekEndDate = new Map<Id, Set<Date>>();
            Set<Date> dateSet =  new Set<Date>();
            dateSet.add(Date.Today().toStartOfWeek());
            mapJobAgainstSetOfWeekEndDate.put(testClosingReport.TR1__Job__c, dateSet);
            TimesheetUtility.CheckIfCompleteWeekIsHoliday(testClosingReport, Date.Today().toStartOfWeek(), mapJobAgainstSetOfWeekEndDate);


        }
    }
}