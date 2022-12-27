@isTest
private class RC_HolidayAccrualTest {

    private static testMethod void testing() {
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
      
        User objUserCommunityContactType2 = RC_UtilityClass.returnCommunityContactTypeUser('c&c', 'testcc');
        system.assertEquals(1, [Select id from User where Id =: objUserCommunityContactType2.Id].size());

        User objUserCommunityContactType = RC_UtilityClass.returnCommunityContactTypeUser('candidate', 'testcand');
    	system.assertEquals(1, [Select id from User where Id =: objUserCommunityContactType.Id].size());

        TR1__Closing_Report__c objClosingReport = RC_UtilityClass.returnClosingReportWithApprover(objUserCommunityContactType2, objUserCommunityContactType);
        objClosingReport.Maximum_Half_Day_Charge_Rate__c = 9;
        objClosingReport.Maximum_Hour_Charge_Rate__c = 8;
        objClosingReport.Maximum_Hour_Pay_Rate__c = 7;
        update objClosingReport;
        Account acc=TestUtility.getAccountDetail();
        Contact objContact = new Contact(Firstname = 'Test', Lastname = 'Conatct1',Payroll_Number__c='12345');
        insert objContact;
            
        Test.startTest();
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
        objTimesheet.TR1__Client__c = acc.Id;
        objTimesheet.TR1__Consultant__c = objContact.Id;
        objTimesheet.TR1__Closing_Report__c = objClosingReport.Id;
        update objTimesheet;
        
        TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.Id);
        objTimesheetDetail.TR1__Vacation_Hours__c = 4;
        objTimesheetDetail.TR1__Regular_Hours__c = 4;
        objTimesheetDetail.TR1__Timesheet__c = objTimesheet.Id;
        update objTimesheetDetail;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
          
        objTimesheet.TR1__Status__c = 'Unsubmitted';
        update objTimesheet;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
        
        delete objTimesheetDetail;
            Test.stopTest();
        } 

}