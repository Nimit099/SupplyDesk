@isTest(SeeAlldata=False)
private class CandidateAvailabilityTriggerHandlertest {
         @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    private static testMethod void OverlapingOnCandidateAvailabilitytest(){
          User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        try{
            Account acc = new Account(Name='CVP',BillingState='TEst');
            insert acc;
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Workable Pending');
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100);
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
            insert joblist;
            Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
            Contact[] candidatelist = new Contact[]{candidate1};  
            insert candidatelist;
            //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
            //User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];
             
            
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
            
            delete csd1;
            
            Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd2;
            
            Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(0), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd3;
            Candidate_Availability__c csd4 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(2), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd4;
            Candidate_Availability__c csd5 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(1), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd5;
            
           
            
            
        
            
            
        }catch(DMLexception e ){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Candidate Availability cannot be deleted as there exist booking ') ? true : false;
            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Overlapping Candidate Availability cannot be created.') ? true : false;
           /* if(expectedExceptionThrown)
                System.AssertEquals(expectedExceptionThrown, true);
            else
                System.AssertEquals(expectedExceptionThrown1, true); */
            
        }   
        
       }
    }
    
     public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or .. 
    }
        
}