@isTest(seealldata=false)
private class VacancyD2DTriggerHandler_test {
 @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}

    private static testMethod void vacancyD2DTest(){
       User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        try{
            Account acc = TestUtility.getAccountDetail();
           Contact con = TestUtility.getContactDetail(u1, acc);
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                                TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,TR1__Status__c='Open',Start_Time__c='04:00 AM',End_Time__c='10:00 AM');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
            insert joblist;
            
            job1.TR1__Estimated_Start_Date__c = job1.TR1__Estimated_Start_Date__c.addDays(5);
            job1.TR1__Estimated_End_Date__c = job1.TR1__Estimated_End_Date__c.addDays(5);
            job1.Start_Time__c='05:00 AM';
            job1.End_Time__c='01:00 PM';
            TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY=false;
            update job1; 
            
            Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
            Contact[] candidatelist = new Contact[]{candidate1};  
            insert candidatelist;
         //   Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
         //   User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];
             
            
            DateTime dateTimeVar = system.today();
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            insert cr1;

            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd1;
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            insert jsd1;
             Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            insert crs1;
            Delete jsd1;
            
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(6),Status__c ='Open');
            insert jsd3;
            Vacancy_D2D__c jsd4 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-1), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            insert jsd4;
            
        }catch(DMLexception e ){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Vacancy Schedule cannot be deleted as there exist booking') ? true : false;
            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Overlapping Vacancy Schedule cannot be created.') ? true : false;
          //  if(expectedExceptionThrown)
          //      System.AssertEquals(expectedExceptionThrown, true);
         //   else
          //      System.AssertEquals(expectedExceptionThrown1, true);
            
        }   
       } 
    }

}