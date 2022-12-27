@isTest(SeeAlldata=False)
private class TimesheetDetailTriggerHandler_test {
    private static testMethod void updateTimesheetDetailWithCRStest(){
        //try{
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u1 = [SELECT Id FROM User WHERE Name != 'Talent Rover Administrator' limit 1];
            system.runAs(u1){
            Account acc = new Account(Name='CVP',BillingState='TEst');
            insert acc;
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,Compliance_Status__c = 'Cleared', Subject__c ='Art',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Vetted',Year_Key_Stage__c='KS1',Payroll_Number__c='32323',Compliance_Owner__c=Userinfo.getUserId(),Barred_List_AQ_Hidden__c ='Active',Perm_Qualification_AQ_Hidden__c ='Active',ID_AQ_Hidden__c='Active',References_AQ_Hidden__c ='Active',Right_to_Work_AQ_Hidden__c ='Active');
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                                TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS1');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};
            insert joblist;
            Contact candidate1 = new Contact(LastName = 'Candidate 1');
            Contact[] candidatelist = new Contact[]{candidate1};
            insert candidatelist;

            Test.startTest();

            DateTime dateTimeVar = system.today();
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',Maximum_Day_Pay_Rate__c=23,Maximum_Day_Charge_Rate__c =23,Maximum_Half_Day_Charge_Rate__c=23,Maximum_Half_Day_Pay_Rate__c=23,Maximum_Hour_Charge_Rate__c=23,Maximum_Hour_Pay_Rate__c=23,
            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id);
            insert cr1;

            List<Candidate_Availability__c> candidateAvailabilityList = new List<Candidate_Availability__c>();

            candidateAvailabilityList.add(new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(2), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(4), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday'));
            candidateAvailabilityList.add(new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(8), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(12), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday'));
            insert candidateAvailabilityList;

            List<Vacancy_D2D__c> vacancyAvailabilityList = new List<Vacancy_D2D__c>();
            vacancyAvailabilityList.add(new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(2), End_Date_Time__c = dateTimeVar.addHours(4),Status__c ='Open',Shift__c='Half Day'));
            vacancyAvailabilityList.add(new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(8), End_Date_Time__c = dateTimeVar.addHours(12),Status__c ='Open',Shift__c='Half Day'));
            insert vacancyAvailabilityList;

            List<Closing_Report_Schedule__c> crsList = new List<Closing_Report_Schedule__c>();

            crsList.add(new Closing_Report_Schedule__c(Candidate_Availability__c = candidateAvailabilityList[0].id,Vacancy_Schedule__c = vacancyAvailabilityList[0].id, Closing_Report__c = cr1.id, Status__c = 'Booked', Schedule_Date__c=todayDate));
            crsList.add(new Closing_Report_Schedule__c(Candidate_Availability__c = candidateAvailabilityList[1].id,Vacancy_Schedule__c = vacancyAvailabilityList[1].id, Closing_Report__c = cr1.id, Status__c = 'Booked', Schedule_Date__c=todayDate));
            insert crsList;
            system.debug('===crsList=='+crsList);
            TR1__Timesheet__c ts = new TR1__Timesheet__c(TR1__Status__c = 'Unsubmitted',Teacher_Score__c=4,TR1__Closing_Report__c = cr1.Id,TR1__Consultant__c = cr1.TR1__Person_Placed__c,TR1__Job_Order__c = cr1.TR1__Job__c,
                                                        TR1__Approver__c = cr1.TR1__Timesheet_Approver__c, TR1__Timesheet_Second_Approver__c = cr1.TR1__Timesheet_Second_Approver__c,TR1__Client__c = cr1.TR1__Account__c,
                                                        TR1__Week_Ending__c = todayDate.addDays(7),TR1__Pay_Week_Ending__c = todayDate.addDays(7));
            Insert ts;

            Test.stopTest();

            Integer numberDaysDue = todayDate.daysBetween(todayDate.addDays(7));
            List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>();
            for (Integer i = 0 ; i <= numberDaysDue; i++) {
                TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.Id, TR1__Date__c = todayDate.addDays(i), TR1__Day__c = dayOfDate(todayDate.addDays(i)));
                timesheetdetails.add(td);
            }
            insert timesheetdetails;
            update timesheetdetails;


        /*}catch(DMLexception e ){
            // system.debug('Following exception occured'+ex.getmessage() );
            // system.assertEquals('System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You can not add same closing report schedule. There is already a similar Closing Report schedule.', ex.getmessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Start time and End time are not present on candidate availablitily record') ? true : false;
            Boolean expectedExceptionThrown1 =  e.getMessage().contains('You can not add same closing report schedule. There is already a similar Closing Report schedule') ? true : false;
            // if(expectedExceptionThrown)
            //     System.AssertEquals(expectedExceptionThrown, true);
            // else
            //     System.AssertEquals(expectedExceptionThrown1, false);
            // Boolean expectedExceptionThrown1 =  e.getMessage().contains('Candidate Availability cannot be deleted as there exist booking ') ? true : false;
            // System.AssertEquals(expectedExceptionThrown1, true);

        }
        */
        }
    }

     public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or ..
    }

}