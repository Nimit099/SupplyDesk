@isTest
private class ClosingReportButtonsCtrlTest {

    private static testMethod void endAssignmentTest() {
        
             User u1=TestUtility.getUserDetail();
          
        
        System.runAs(u1){
            Account acc=TestUtility.getAccountDetail();
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con =TestUtility.getContactDetail(u1,acc); 
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                                TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS2');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
            insert joblist;
            Contact candidate1 = new Contact(LastName = 'Candidate 1', Email='test25434w56@test.com');
            Contact[] candidatelist = new Contact[]{candidate1};  
            insert candidatelist;
            DateTime dateTimeVar = system.today();
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id,Maximum_Hour_Pay_Rate__c =23,Maximum_Hour_Charge_Rate__c =23,Maximum_Day_Charge_Rate__c = 23, Maximum_Day_Pay_Rate__c =23); 
            insert cr1;        
            
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd1;
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open',Shift__c='Hourly');
            insert jsd1;
            Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd2;
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(7), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open',Shift__c='Daily');
            insert jsd2;
            
            Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            insert crs1;
            Closing_Report_Schedule__c crs2 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd2.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd2.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            insert crs2;
            
            Test.startTest();
            PageReference pageRef = Page.ClosingReportEndAssignment;
            pageRef.getParameters().put('id', String.valueOf(cr1.Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(cr1);
            ClosingReportButtonsCtrl clBtnCtrl = new ClosingReportButtonsCtrl(sc);
            
            clBtnCtrl.SaveEndAssignment();
            
            Test.stopTest();
        }

    }

}