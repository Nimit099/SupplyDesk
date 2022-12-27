@isTest
public with sharing class RateChangeButtonClosingReportCtrlTest{
@TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    public static testMethod void RateChangeTest1(){
        
        //Positive Case
          User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
          
        
        System.runAs(u1){
            Account testAccount=TestUtility.getAccountDetail();
        Contact testContact =TestUtility.getContactDetail(u1,testAccount);
            insert testContact;
        
        //Create Candidate Availablities
        Date startDate = System.today().toStartOfWeek().addDays(28);
        List<Candidate_Availability__c> testCandidateAvailabilityList = new List<Candidate_Availability__c>();
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate,End_Date__c=startDate, Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(1),End_Date__c=startDate.addDays(1), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(2),End_Date__c=startDate.addDays(2), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(3),End_Date__c=startDate.addDays(3), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(4),End_Date__c=startDate.addDays(4), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(5),End_Date__c=startDate.addDays(5), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        testCandidateAvailabilityList.add(new Candidate_Availability__c(Start_Date__c=startDate.addDays(6),End_Date__c=startDate.addDays(6), Candidate__c = testContact.Id,Type__c = 'Full Day'));
        for(Candidate_Availability__c ca:testCandidateAvailabilityList){
                  ca.Start_Date_Time__c=TestUtility.formatDateTimefromDate(ca.Start_Date__c,'15:45'); 
        		  ca.End_Date_Time__c=TestUtility.formatDateTimefromDate(ca.End_Date__c,'23:30');
            }
            
            
            
            insert testCandidateAvailabilityList;
        
        String CONSULTING_RECORD_TYPE_JOB = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c testConsultingJob =  new TR1__Job__c(TR1__Account__c = testAccount.id,
                                                         TR1__Status__c = 'Open',
                                                         TR1__Estimated_Start_Date__c = startDate.addDays(-7),
                                                         TR1__Estimated_End_Date__c = startDate.addDays(13),
                                                         RecordtypeId = CONSULTING_RECORD_TYPE_JOB
                                                        );
        insert testConsultingJob;
        
        List<Vacancy_D2D__c> testVacancyScheduleList = new List<Vacancy_D2D__c>();
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate, Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(1), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(2), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(3), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(4), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(5), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        testVacancyScheduleList.add(new Vacancy_D2D__c(Vacancy_Date__c=startDate.addDays(6), Vacancy__c = testConsultingJob.Id,Status__c = 'Open', Shift__c = 'Half Day'));
        insert testVacancyScheduleList;
        
        //Create Closing Report
        String CONSULTING_RECORD_TYPE_CLOSING_REPORT = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c testClosingReport = new TR1__Closing_Report__c(
                                                                                TR1__Rate_Change_Effective_Date__c=Date.today(),
                                                                                TR1__Start_Date__c = startDate.addDays(-7),
                                                                                TR1__End_Date__c = startDate.addDays(13),
                                                                                TR1__Person_Placed__c = testContact.Id,
                                                                                TR1__Job__c = testConsultingJob.Id,
                                                                                TR1__Pay_Rate__c = 100.0,
                                                                                TR1__Bill_Rate__c = 100.0,
            																	TR1__Job_Percentage__c =100.0,
                                                                                TR1__Job_Credit__c = u1.Id,
            																	Maximum_Day_Pay_Rate__c=100,Maximum_Day_Charge_Rate__c =100,
            																	Maximum_Hour_Charge_Rate__c=10,Maximum_Hour_Pay_Rate__c=10,
            																	Maximum_Half_Day_Pay_Rate__c=50,Maximum_Half_Day_Charge_Rate__c=50,
                                                                                RecordtypeId = CONSULTING_RECORD_TYPE_CLOSING_REPORT
                                                                             );
        insert testClosingReport;
        
        
        List<Closing_Report_Schedule__c> testClosingReportScheduleList = new List<Closing_Report_Schedule__c>();
        for(integer i=0;i<testVacancyScheduleList.size();i++){
            testClosingReportScheduleList.add(new Closing_Report_Schedule__c(Candidate_Availability__c = testCandidateAvailabilityList[i].id, Vacancy_Schedule__c = testVacancyScheduleList[i].id, Schedule_Date__c=startDate.addDays(i),Status__c = 'Booked', Shift__c = 'Full Day', Closing_Report__c = testClosingReport.id));
        }
        insert testClosingReportScheduleList;
        
        List<TR1__Timesheet__c> testTimesheetList = new List<TR1__Timesheet__c>();
        testTimesheetList.add(new TR1__Timesheet__c(TR1__Closing_Report__c = testClosingReport.Id,TR1__Consultant__c=testContact.Id,TR1__Week_Ending__c = startDate.addDays(6), TR1__Job_Order__c = testConsultingJob.Id, TR1__Client__c = testAccount.id ,TR1__Status__c = 'Open'));
        testTimesheetList.add(new TR1__Timesheet__c(TR1__Closing_Report__c = testClosingReport.Id,TR1__Consultant__c=testContact.Id,TR1__Week_Ending__c = startDate.addDays(13), TR1__Job_Order__c = testConsultingJob.Id, TR1__Client__c = testAccount.id ,TR1__Status__c = 'Open'));
        testTimesheetList.add(new TR1__Timesheet__c(TR1__Closing_Report__c = testClosingReport.Id,TR1__Consultant__c=testContact.Id, TR1__Week_Ending__c = startDate.addDays(-1), TR1__Job_Order__c = testConsultingJob.Id, TR1__Client__c = testAccount.id ,TR1__Status__c = 'Open'));
        insert testTimesheetList;
        
        List<TR1__Timesheet_Detail__c> testTimesheetDetailList = new List<TR1__Timesheet_Detail__c>();
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate,TR1__Regular_Hours__c = 8));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(1),TR1__Regular_Hours__c = 8));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(2),TR1__Regular_Hours__c = 8));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(3),TR1__Regular_Hours__c = 8));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(4),TR1__Regular_Hours__c = 8));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(5),TR1__Regular_Hours__c = 0));
        testTimesheetDetailList.add(new TR1__Timesheet_Detail__c(TR1__Timesheet__c=testTimesheetList[0].id, TR1__Date__c=startDate.addDays(6),TR1__Regular_Hours__c = 0));
        insert testTimesheetDetailList;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.RateChangeButtonClosingReport);
        ApexPages.currentPage().getParameters().put('Id',testClosingReport.Id);
        RateChangeButtonClosingReportController testController = new RateChangeButtonClosingReportController(new ApexPages.StandardController(testClosingReport));
        testController.newcr.TR1__Rate_Change_Effective_Date__c = startDate.addDays(3);
        testController.SaveRateChange();
        
        Test.stopTest();
        }
    }
    
    public static testMethod void RateChangeTest2(){
        
        //Negative Cases
        User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];

   
        
        System.runAs(u1){
            Account testAccount=TestUtility.getAccountDetail();
        Contact testContact =TestUtility.getContactDetail(u1,testAccount);
            insert testContact;
        
        Date startDate = System.today().toStartOfWeek();
        
        String CONSULTING_RECORD_TYPE_JOB = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c testConsultingJob =  new TR1__Job__c(TR1__Account__c = testAccount.id,
                                                         TR1__Status__c = 'Open',
                                                         TR1__Estimated_Start_Date__c = startDate.addDays(-7),
                                                         TR1__Estimated_End_Date__c = startDate.addDays(13),
                                                         RecordtypeId = CONSULTING_RECORD_TYPE_JOB
                                                        );
        insert testConsultingJob;
        
        //Create Closing Report
        String CONSULTING_RECORD_TYPE_CLOSING_REPORT = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c testClosingReport = new TR1__Closing_Report__c(
                                                                                TR1__Rate_Change_Effective_Date__c=Date.today(),
                                                                                TR1__Start_Date__c = startDate.addDays(-7),
                                                                                TR1__End_Date__c = startDate.addDays(13),
                                                                                TR1__Person_Placed__c = testContact.Id,
                                                                                TR1__Job__c = testConsultingJob.Id,
                                                                                TR1__Pay_Rate__c = 100.0,
                                                                                TR1__Bill_Rate__c = 100.0,
                                                                                TR1__Job_Percentage__c =100.0,
                                                                                TR1__Job_Credit__c = u1.Id,
                                                                                RecordtypeId = CONSULTING_RECORD_TYPE_CLOSING_REPORT
                                                                             );
        insert testClosingReport;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.RateChangeButtonClosingReport);
        ApexPages.currentPage().getParameters().put('Id',testClosingReport.Id);
        RateChangeButtonClosingReportController testController = new RateChangeButtonClosingReportController(new ApexPages.StandardController(testClosingReport));
        
        //Hour : Pay Rate greater than charge date
        testController.newcr.Maximum_Hour_Charge_Rate__c = 100;
        testController.newcr.Maximum_Hour_Pay_Rate__c = 120;
        testController.SaveRateChange();
        
        //Half Day : Pay Rate greater than charge date
        testController.newcr.Maximum_Half_Day_Charge_Rate__c = 100;
        testController.newcr.Maximum_Half_Day_Pay_Rate__c = 120;
        testController.SaveRateChange();
        
        //Day : Pay Rate greater than charge date
        testController.newcr.Maximum_Day_Charge_Rate__c = 100;
        testController.newcr.Maximum_Day_Pay_Rate__c = 120;
        testController.SaveRateChange();
        
        //Rate Change date greater than end date
        testController.newcr.TR1__Rate_Change_Effective_Date__c = startDate.addDays(14);
        testController.SaveRateChange();
        
        //Rate Change date greater than end date
        testController.newcr.TR1__Rate_Change_Effective_Date__c = startDate.addDays(-8);
        testController.SaveRateChange();
        
        Test.stopTest();
        }
    }
}