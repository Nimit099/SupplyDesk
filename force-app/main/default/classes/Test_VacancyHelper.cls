@isTest
private class Test_VacancyHelper {
                     @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    
    @isTest static void test_method_one() {
         User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        // Create Test Data
        Account[] accList = TestUtility.accList; 
        Contact[] conList = TestUtility.con;
        List<Candidate_Availability__c> candidateAvailabilityList=new List<Candidate_Availability__c>();
      candidateAvailabilityList=[Select Id, Name, Start_Date_Time__c, End_Date_Time__c from Candidate_Availability__c where Start_Date_Time__c != null and End_Date_Time__c != null]; 
        Test.startTest();

        TR1__Job__c jobRec = TestUtility.job;

        TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = false;
        
       
     Candidate_Availability__c ca=    new Candidate_Availability__c(Start_Date__c=System.Today().addDays(-40),End_Date__c=System.Today().addDays(-40), Candidate__c = conList[0].Id, Applicable_Days__c = 'Monday', Type__c = 'Available');
     ca.Start_Date_Time__c=TestUtility.formatDateTimefromDate(ca.Start_Date__c,'15:45'); 
        ca.End_Date_Time__c=TestUtility.formatDateTimefromDate(ca.End_Date__c,'23:30');
        insert ca;
        /*
        RecordType consulting = [Select Id from RecordType where SObjectType = 'TR1__Closing_Report__c' and Name = 'Consulting'];
        
        TR1__Closing_Report__c closingRep = new TR1__Closing_Report__c();
        closingRep.RecordTypeId = consulting.id;
        closingRep.TR1__Start_Date__c = System.Today().addDays(-60);
        closingRep.TR1__End_Date__c = System.Today();
        closingRep.TR1__Person_Placed__c = conList[0].Id;
        closingRep.TR1__Job__c = jobRec.Id;
        closingRep.TR1__Pay_Rate__c = 100.0;
        closingRep.TR1__Bill_Rate__c = 100.0;
        closingRep.Booking_Type__c = 'LT';
        insert closingRep;
        */
         
        // Update Vacancy Dates
        jobRec.TR1__Estimated_Start_Date__c = System.today().addDays(15);
        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(30);
        update jobRec;

        TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = false;

        jobRec.TR1__Estimated_Start_Date__c = System.today().addDays(-10);
        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(40);
        update jobRec;

        TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = false;

        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(-5);
        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(5);
        update jobRec;

        TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = false;

        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(-50);
        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(-30);
        update jobRec;

        TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = false;

        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(10);
        jobRec.TR1__Estimated_End_Date__c = System.today().addDays(30);
        
        jobRec.Monday_s_Shift__c = 'AM';
        jobRec.Tuesday_s_Shift__c = 'AM';
        jobRec.Wednesday_s_Shift__c = 'AM';
        jobRec.Friday_s_Shift__c = 'AM';
        jobRec.Saturday_s_Shift__c = 'AM';
        jobRec.Sunday_s_Shift__c = 'AM';
        jobRec.Thursday_s_Shift__c = 'AM';
        

        update jobRec;

        Test.stopTest();
    }
    }
}