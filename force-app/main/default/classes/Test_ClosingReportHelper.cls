@isTest
private class Test_ClosingReportHelper {
                 @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    
    @isTest static void test_method_one() {
         User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
       System.runAs(u1){
        
        // Create Test data

        Account acc = new Account(Name = 'Test');
        insert acc;

        //List<Contact> conList = TestUtility.con;
        
        Contact testCandidate = new Contact(LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,Compliance_Status__c = 'Clearance Pending',Compliance_Owner__c=u1.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day');
        insert testCandidate; 
           
           
        Contact testHiringManager = new Contact(LastName='Test The Hiring Manager',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,Compliance_Status__c = 'Clearance Pending',Compliance_Owner__c=u1.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day');
        insert testHiringManager;

        TR1__Job__c job = TestUtility.job;

         //Create Candidate Availablities
        Candidate_Availability__c ca= new Candidate_Availability__c(Start_Date__c=System.Today().addDays(5),End_Date__c=System.Today().addDays(5), Candidate__c = testCandidate.Id, Applicable_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday', Type__c = 'Full Day');
        
                //Candidate_Availability__c ca=    new Candidate_Availability__c(Start_Date__c=System.Today().addDays(-40),End_Date__c=System.Today().addDays(-40), Candidate__c = conList[0].Id, Applicable_Days__c = 'Monday', Type__c = 'Available');
        ca.Start_Date_Time__c=TestUtility.formatDateTimefromDate(ca.Start_Date__c,'15:45'); 
        ca.End_Date_Time__c=TestUtility.formatDateTimefromDate(ca.End_Date__c,'23:30');
        insert ca;
           
           
    //    insert new Candidate_Availability__c(Start_Date__c=System.Today().addDays(6),End_Date__c=System.Today().addDays(6), Candidate__c = conList[1].Id, Applicable_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday', Type__c = 'AM');
        
     // insert new Candidate_Availability__c(Start_Date__c=System.Today().addDays(7),End_Date__c=System.Today().addDays(7), Candidate__c = conList[0].Id, Applicable_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday', Type__c = 'PM');
   		Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
        Contact[] candidatelist = new Contact[]{candidate1};  
        insert candidatelist;
                          
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        Date todayDate = system.today();

        TR1__Job__c testJob = new TR1__Job__c(TR1__Account__c = acc.id, TR1__Hiring_Manager__c = testHiringManager.Id,Subject2__c='Accountancy',Year_Key_Stage__c='KS2',TR1__Contact__c=testCandidate.Id);
        insert testJob;
           Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr = new TR1__Closing_Report__c(TR1__Account__c = acc.id,RecordTypeId = crconsultingId, TR1__Job__c = testJob.Id, TR1__Person_Placed__c = testCandidate.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            //insert testClosingReport;
       
           
           
           
           
           
        //TR1__Closing_Report__c cr = new TR1__Closing_Report__c(TR1__Account__c = acc.id ,TR1__Job__c = job.id , TR1__Person_Placed__c = conList[0].id , RecordTypeId = Utility.CONSULTING_RTID ,TR1__Start_Date__c = System.today() , TR1__End_Date__c = System.today().addDays(6), TR1__Candidate_Percentage__c=100);

        TR1__Closing_Report__c closingRep = new TR1__Closing_Report__c(TR1__Account__c = acc.id ,TR1__Job__c = job.id , 
                                                                       TR1__Person_Placed__c = testCandidate.id , 
                                                                       RecordTypeId = Utility.CONSULTING_RTID ,
                                                                       TR1__Start_Date__c = System.today() , 
                                                                       TR1__End_Date__c = System.today().addDays(6),
                                                                       TR1__Candidate_Percentage__c=100,
                                                                        TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id,
                                                                       Booking_Confirmed__c =false );
        insert closingRep;
        
        Test.startTest();

        List<Vacancy_D2D__c> vacancyschedule = [Select Candidate_Assigned__c,Shift__c,Status__c,Vacancy__c from Vacancy_D2D__c where Vacancy__c =:job.id];
        System.assertEquals(false , vacancyschedule.size() > 0);
        //System.assertEquals(true , vacancyschedule.size() > 0);

        //System.assertEquals( 51 ,candidschedule.size());

        insert cr;
        
        System.debug('job value '+ cr.TR1__Job__c);
        System.debug('candidate value '+ cr.TR1__Person_Placed__c);
        System.debug('RecordType '+ cr.RecordTypeId);
        System.debug('CL start Date '+cr.TR1__Start_Date__c);
        System.debug('CL end Date '+ cr.TR1__End_Date__c);
        
        cr.TR1__Rate_Change_Effective_Date__c = System.today().addDays(-5);
        cr.TR1__End_Date__c = System.today().addDays(40);
        
        //ClosingReport_Helper.Execute_OnInsert_ClosingReport = true;
        update cr;

        
        closingRep.TR1__End_Date__c = System.today().addDays(5);
        
        //ClosingReport_Helper.Execute_OnInsert_ClosingReport = true;
        update closingRep;
        
        closingRep.TR1__Start_Date__c = System.today().addDays(-5);
        closingRep.TR1__End_Date__c = System.today().addDays(1);

        //ClosingReport_Helper.Execute_OnInsert_ClosingReport = true;
        update closingRep;
        
        
        closingRep.TR1__Start_Date__c = System.today().addDays(-20);
        closingRep.TR1__End_Date__c = System.today().addDays(30);
        closingRep.Booking_Confirmed__c  = True;
        //ClosingReport_Helper.Execute_OnInsert_ClosingReport = true;
        update closingRep;
        
        TR1__Timesheet__c ts = [SELECT ID,Teacher_Score__c FROM TR1__Timesheet__c WHERE TR1__Closing_Report__c =: closingRep.Id ];
        ts.Teacher_Score__c = 2;    
        update ts;

        Test.stopTest() ;
    }
    }
}