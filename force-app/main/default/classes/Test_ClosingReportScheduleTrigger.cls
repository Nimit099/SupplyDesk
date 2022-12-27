@isTest
public with sharing class Test_ClosingReportScheduleTrigger {
       @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    static testmethod void test_method_one() {
         User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        
        // Create Test data
        // 
        
        List<Account> acc = TestUtility.accList;
         

        //System.debug('Execute_OnInsert_ClosingReport 1: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);
        List<Contact> conList = TestUtility.con;
System.debug('::::conlIst'+conList);
        TR1__Job__c job =  new TR1__Job__c(TR1__Account__c = acc[0].id,
                                        TR1__Status__c = 'Open',
                                        TR1__Client_Description__c ='test',
                                        TR1__Education_Requirements__c='aaa',
                                        TR1__Experience_Requirements__c='bbb',
                                        TR1__Responsibilities__c='ccc',
                                        TR1__State_Area__c='test',
                                        TR1__Regional_Area__c='test',
                                        Booking_Type__c='test',
                                        TR1__Division__c='test',
                                        TR1__Primary_Background__c='test',
                                        TR1__Estimated_Start_Date__c = System.today().addDays(15),
                                        TR1__Estimated_End_Date__c = System.today().addDays(17), 
                                        Applicable_Days__c = 'Monday' , RecordtypeId = TRS_vacancyhelper.CONSULTING_RTID,
                                        Friday_s_Shift__c = 'Full Day',
                                        Monday_s_Shift__c = 'Full Day',
                                        Saturday_s_Shift__c = 'Full Day',
                                        Sunday_s_Shift__c = 'Full Day',
                                        Thursday_s_Shift__c = 'Full Day',
                                        Tuesday_s_Shift__c = 'Full Day',
                                        Wednesday_s_Shift__c = 'Full Day');
        insert job;     

        List<Vacancy_D2D__c> vacd2dList = [select Vacancy__c , Closing_Report_Schedule__c from Vacancy_D2D__c where Vacancy__c = : job.id ];
        //System.assertEquals(3 ,vacd2dList.size());
        
        //System.debug('Execute_OnInsert_ClosingReport 2: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);
        Candidate_Availability__c avail = new Candidate_Availability__c (Candidate__c = conList[0].id , Shift__c = 'AM' , Type__c = 'AM',Start_Date__c = System.today().addDays(-10) , 
                                                                                End_Date__c = System.today().addDays(-2), Applicable_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        avail.Start_Date_Time__c=TestUtility.formatDateTimefromDate(avail.Start_Date__c,'15:45'); 
        avail.End_Date_Time__c=TestUtility.formatDateTimefromDate(avail.End_Date__c,'23:30');
       // insert ca;
        insert avail;
        //System.debug('Execute_OnInsert_ClosingReport 3: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);

        TR1__Closing_Report__c cr = new TR1__Closing_Report__c(TR1__Account__c = acc[0].id, TR1__Job__c = job.id, TR1__Person_Placed__c = conList[0].id, TR1__Job_Credit__c = u1.Id,
                                                                    RecordTypeId = Utility.CONSULTING_RTID, TR1__Start_Date__c = System.today().addDays(0), TR1__Candidate_Percentage__c=100,
                                                                    TR1__End_Date__c = System.today().addDays(2), Contract_End_Date__c =  System.today().addDays(2));

        //Start Test
        Test.startTest();
        
        //System.debug('Execute_OnInsert_ClosingReport 4: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);
        
        insert cr;
        
        System.debug('CR val:'+cr);
        
        List<Closing_Report_Schedule__c> crsList = [Select Closing_Report__c , Schedule_Date__c from Closing_Report_Schedule__c where Closing_Report__c = :cr.id];
        //System.assertEquals(3 ,crsList.size());
        System.debug('CRS :' + crsList);
        
        delete crsList;
        
        //Stop Test
        Test.stopTest();
       }
    }
    
    static testmethod void test_method_two() {
        
        // Create Test data
          User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        
        List<Account> acc = TestUtility.accList;
         

        //System.debug('Execute_OnInsert_ClosingReport 1: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);
        List<Contact> conList = TestUtility.con;

        TR1__Job__c job =  new TR1__Job__c(TR1__Account__c = acc[0].id,
                                        TR1__Status__c = 'Open',
                                        TR1__Client_Description__c ='test',
                                        TR1__Education_Requirements__c='aaa',
                                        TR1__Experience_Requirements__c='bbb',
                                        TR1__Responsibilities__c='ccc',
                                        TR1__State_Area__c='test',
                                        TR1__Regional_Area__c='test',
                                        Booking_Type__c='test',
                                        TR1__Division__c='test',
                                        TR1__Primary_Background__c='test',
                                        TR1__Estimated_Start_Date__c = System.today().addDays(0),
                                        TR1__Estimated_End_Date__c = System.today().addDays(2), 
                                        Applicable_Days__c = 'Monday' , RecordtypeId = TRS_vacancyhelper.CONSULTING_RTID,
                                        Friday_s_Shift__c = 'Full Day',
                                        Monday_s_Shift__c = 'Full Day',
                                        Saturday_s_Shift__c = 'Full Day',
                                        Sunday_s_Shift__c = 'Full Day',
                                        Thursday_s_Shift__c = 'Full Day',
                                        Tuesday_s_Shift__c = 'Full Day',
                                        Wednesday_s_Shift__c = 'Full Day');
        insert job;                             
        
        //System.debug('Execute_OnInsert_ClosingReport 2: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);
        Candidate_Availability__c avail = new Candidate_Availability__c (Candidate__c = conList[0].id , Shift__c = 'AM' , Type__c = 'AM',Start_Date__c = System.today().addDays(-30) , 
                                                                                End_Date__c = System.today().addDays(-20), Applicable_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        avail.Start_Date_Time__c=TestUtility.formatDateTimefromDate(avail.Start_Date__c,'15:45'); 
        avail.End_Date_Time__c=TestUtility.formatDateTimefromDate(avail.End_Date__c,'23:30');
       // insert ca;
        insert avail;
        //System.debug('Execute_OnInsert_ClosingReport 3: ' + ClosingReport_Helper.Execute_OnInsert_ClosingReport);

        TR1__Closing_Report__c cr = new TR1__Closing_Report__c(TR1__Account__c = acc[0].id, TR1__Job__c = job.id, TR1__Person_Placed__c = conList[0].id, TR1__Job_Credit__c = u1.Id,
                                                                    RecordTypeId = Utility.CONSULTING_RTID, TR1__Start_Date__c = System.today().addDays(0), TR1__Candidate_Percentage__c=100,
                                                                    TR1__End_Date__c = System.today().addDays(2), Contract_End_Date__c =  System.today().addDays(2));

        
        
        
        insert cr;
        
        
        List<Closing_Report_Schedule__c> crsList = [Select Closing_Report__c , Schedule_Date__c from Closing_Report_Schedule__c where Closing_Report__c = :cr.id];
        //System.assertEquals(3 ,crsList.size());
        
        List<Vacancy_D2D__c> vacd2dList = [select Vacancy__c , Closing_Report_Schedule__c from Vacancy_D2D__c where Vacancy__c = : job.id ];
        //System.assertEquals(3 ,vacd2dList.size());
        //Start Test
        Test.startTest();
        
        //for(Closing_Report_Schedule__c crs :crsList){
            delete crsList;
        //}
        
        
        //Stop Test
        Test.stopTest();
       }
    }
}