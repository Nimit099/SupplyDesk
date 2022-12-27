@isTest
private class autoSubmitTimesheetsBatchTest {

    private static testMethod void autoSubmitTimesheetsTest() {
        // Create Test data
       Test.StartTest();
      
      User u1=TestUtility.getUserDetail();
          
        
        System.runAs(u1){
            Account acc=TestUtility.getAccountDetail();
        Contact con =TestUtility.getContactDetail(u1,acc);
            insert con;
            
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        Date todayDate = system.today();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='Y4(KS2)');
        TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
        insert joblist;
        Contact candidate1 = new Contact(LastName = 'Candidate 1');
        Contact[] candidatelist = new Contact[]{candidate1};  
        insert candidatelist;
       
        
        DateTime dateTimeVar = system.today();
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id,TR1__Account__c=acc.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
                                    TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
                                    TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id,Booking_Confirmed__c = true); 
        insert cr1;
        
        autoSubmitTimesheetsBatch batchClass = new autoSubmitTimesheetsBatch();
        ID batchprocessid = Database.executeBatch(batchClass);
        
        autoSubmitTimesheetsBatchSchedulable sch = New autoSubmitTimesheetsBatchSchedulable();
        String constr = '0 0 23 * * ?';
        system.schedule('Auto Submit Timesheet Batch',constr,sch);
        Test.StopTest();
        }
        
    }
    

}