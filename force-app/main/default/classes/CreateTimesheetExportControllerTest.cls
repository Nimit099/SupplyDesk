@isTest
public class CreateTimesheetExportControllerTest {

    public static testmethod void test(){
 User u1=TestUtility.getUserDetail();
          
        
        System.runAs(u1){
            Account testAccount=TestUtility.getAccountDetail();
        Contact testContact =TestUtility.getContactDetail(u1,testAccount);
            insert testContact;
        CreateTimesheetExportController c = new CreateTimesheetExportController();
        c.doTimesheetExport();

       

        Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();

        

        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

        TR1__Job__c testJob = new TR1__Job__c(RecordTypeId=consultingid, TR1__Account__c=testAccount.Id, Name='Job 2',TR1__Estimated_Start_Date__c=Date.today(),TR1__Estimated_End_Date__c=Date.today().addDays(7),TR1__Contact__c=testContact.Id,Sector1__c='Nursery', Year_Key_Stage__c ='KS1',Maximum_Hour_Charge_Rate__c=23,TR1__Maximum_Pay_Rate__c=54,TR1__Maximum_Bill_Rate__c=45,SEN_Experience__c='ADHD',SEN_Additional_Experience__c ='ADHD Awareness');
        insert testJob;

        TR1__Timesheet__c testTimesheet = new TR1__Timesheet__c(TR1__Status__c = 'Unsubmitted', TR1__Job_Order__c = testJob.Id ,TR1__Client__c=testAccount.Id,TR1__Consultant__c=testContact.Id);
        insert testTimesheet;

        Date todayDate = system.today();
        Integer numberDaysDue = todayDate.daysBetween(todayDate.addDays(6));
        List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>();
        for (Integer i = 0 ; i <= numberDaysDue; i++) {
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = testTimesheet.Id, TR1__Date__c = todayDate.addDays(i),DayShift__c=true, TR1__Day__c = dayOfDate(todayDate.addDays(i)));
            timesheetdetails.add(td);
        }
        insert timesheetdetails;
        Test.startTest();
        testTimesheet.TR1__Status__c = 'Approved';
        update testTimesheet;
        c.checkAsyncJobStatus();
        c.doTimesheetExport();
        c.checkAsyncJobStatus();
        Test.stopTest();
        }
    }

    public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or ..
    }
}