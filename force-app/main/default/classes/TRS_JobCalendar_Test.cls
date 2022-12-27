@isTest(SeeAlldata=False)
private class TRS_JobCalendar_Test {
    private static testMethod void jobCalendar_test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = [SELECT Id FROM User WHERE Name != 'Talent Rover Administrator' limit 1];
        system.runAs(u1) { 
        Account acc = new Account(Name='CVP',BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                         shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
        insert acc;
        Datetime dt1 = System.now();
        
        Contact con = new Contact(OwnerId = u1.Id,LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,Compliance_Not_Registered_Date__c=dt1,Candidate_Vetted_Date__c =dt1.addDays(3), Compliance_Status__c = 'Cleared', Compliance_Owner__c=u1.Id,
            							Subject__c='Art', Trained_As__c =' Early Years Trained', Sector__c='HMP Prison', Job_Titles__c='Acting Assistant Principal',Assignment_Type__c='Long Term',TR1__Candidate_Status__c='Prospect');
        insert con;
        
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,Subject__c = 'Art',Subject2__c='Accountancy',Year_Key_Stage__c='KS2');
        TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
        insert joblist;
        Contact candidate1 = new Contact(LastName = 'Candidate 1', email='test@test.com');
        Contact[] candidatelist = new Contact[]{candidate1};  
        insert candidatelist;

        Date todayDate = Date.newInstance(2090,5,7);
        DateTime dateTimeVar = datetime.newInstance(2090,5,7, 10, 30, 0);
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 25,
        TR1__Candidate_Percentage__c = 25, TR1__Marketing_Percentage__c = 25, TR1__Other_Percentage__c = 15, TR1__Other2_Percentage__c = 10,Maximum_Day_Charge_Rate__c =23,Maximum_Day_Pay_Rate__c =23,Maximum_Hour_Charge_Rate__c=23,Maximum_Hour_Pay_Rate__c =23,
        TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,
        TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
        insert cr1;
        
        Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        insert csd1;
        Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
        insert jsd1;
        Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
        insert jsd2;
        Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
        insert crs1;
        PageReference pref=page.TRS_JobCalendar;
        pref.getParameters().put('vacancyId', job1.id);
        String strDate = String.valueOf(Date.newInstance(5, 7,2090));
        strDate = strDate.replace('-' , '/');
        system.debug('Dates format is ->'+strDate);
        pref.getParameters().put('dateStr', strDate);
        Test.setCurrentPage(pref);
        TRS_JobCalendar candid = new TRS_JobCalendar();
        candid.selectedDate = Date.newInstance(5, 7,2090);
       
        candid.getSelectedDateStr();
        candid.getSelectedDateStartOfWeekStr();
        candid.getSelectedDateEndOfWeekStr();
        candid.isWeekSelected = true;
        candid.showCreateAvailRecord = True;
        candid.vacancy.TR1__Estimated_Start_Date__c = Date.Today().addDays(1);
        candid.vacancy.TR1__Estimated_End_Date__c = Date.Today().addDays(8);
        candid.vacancy.Shift__c = 'AM';
        candid.selectedDateStartOfWeek = Date.newInstance(5, 7,2090);
        candid.selectedDateEndOfWeek = Date.newInstance(5, 8,2090);
        candid.tsw.isMon  =True ; 
        candid.tsw.isTue  =True ; 
        candid.tsw.isWed  =True; 
        candid.tsw.isThu  =True; 
        candid.tsw.isFri  =True; 
        candid.tsw.isSat  =True; 
        candid.tsw.isSun  =True;
        
        candid.openCreateAvailRecordDialog();
        candid.isMidNight = false;
        candid.isWeekSelected = true;
        candid.vacancy.Start_Time__c = '04:00 PM';
        candid.vacancy.End_Time__c = '07:00 PM';
        candid.saveCreateAvailRecord();
        candid.vacancy.Start_Time__c = '07:00 PM';
        candid.vacancy.End_Time__c = '';
        candid.saveCreateAvailRecord();
        candid.vacancy.Start_Time__c = '';
        candid.vacancy.End_Time__c = '';
        candid.saveCreateAvailRecord();
        candid.vacancy.Start_Time__c = '';
        candid.vacancy.End_Time__c = '07:00 PM';
        candid.saveCreateAvailRecord();
        candid.vacancy.Start_Time__c = '07:00 PM';
        candid.vacancy.End_Time__c = '07:00 PM';
        candid.saveCreateAvailRecord();
        candid.isWeekSelected = false;
        candid.vacancy.Start_Time__c = '06:00 PM';
        candid.vacancy.End_Time__c = '07:00 PM';
        //candid.tsw.statusType = null;
        candid.saveCreateAvailRecord();
        
        candid.openCreateAvailRecordDialog();
        candid.isWeekSelected = false;
        candid.isMidNight = true;
        candid.vacancy.Start_Time__c = '11:00 PM';
        candid.vacancy.End_Time__c = '12:30:00 AM';
        candid.saveCreateAvailRecord();
        
        candid.openCreateAvailRecordDialog();
        candid.isWeekSelected = true;
        candid.isMidNight = true;
        candid.vacancy.Start_Time__c = '11:00 PM';
        candid.vacancy.End_Time__c = '12:30:00 AM';
        candid.saveCreateAvailRecord();
 
        
        candid.calenderSchedule();
        candid.eventId = jsd2.Id;
        candid.deleteCalEvent();
        candid.eventId = crs1.Id;
        candid.deleteCalEvent();
        cr1.Status__c ='Cancelled';
        update cr1;
        
        candid.vacancy.Shift__c='Hourly';
        candid.dummyFunction();
        candid.vacancy.Shift__c='AM';
        candid.dummyFunction();
        candid.vacancy.Shift__c='PM';
        candid.dummyFunction();
        candid.resetDaySelection();
        }
	}

}