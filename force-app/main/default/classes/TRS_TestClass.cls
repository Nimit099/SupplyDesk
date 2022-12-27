@isTest(SeeAlldata=False)
private class TRS_TestClass {
    private static testMethod void TRS_FilterCandidates_test() {
    	
    	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                                EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR', ProfileId = p.Id,
                                TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
        system.runAs(u1) { 
        Account acc = new Account(Name='CVP',BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                         shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
        insert acc;
        Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
       // Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Workable Pending', Subject__c ='Art');
        //insert con;
        
        Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,  Subject__c ='Art',
	                                Compliance_Owner__c = u1.Id, Year_Key_Stage__c = 'KS1',TR1__Candidate_Status__c = 'DNU',Compliance_Status__c = 'Cleared',Pay_Type__c = 'Perm', Trained_As__c = 'Instructor',
	                                Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm', References_AQ_Hidden__c='Active',ID_AQ_Hidden__c='Active',Barred_List_AQ_Hidden__c='Active',
	                                Perm_Qualification_AQ_Hidden__c='Active',Right_to_Work_AQ_Hidden__c='Active'); 
        insert con;
        
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Estimated_Start_Date__c=Date.today(),TR1__Estimated_End_Date__c=Date.today().addDays(7),TR1__Contact__c=con.Id,Sector1__c='Nursery', Year_Key_Stage__c ='KS1',SEN_Experience__c='ADHD');
        TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
        insert joblist;
        Contact candidate1 = new Contact(LastName = 'Candidate 1',Email='test@test.com', Subject__c ='Art');
        Contact[] candidatelist = new Contact[]{candidate1};  
        insert candidatelist;
        
       // Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        //User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];
         
        Date todayDate = system.today();
        DateTime dateTimeVar = system.today();
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 25,
        TR1__Candidate_Percentage__c = 25, TR1__Marketing_Percentage__c = 25, TR1__Other_Percentage__c = 15, TR1__Other2_Percentage__c = 10,
        TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,
        TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
        ClosingReportTriggerHelper.FromJobboard = True;
        insert cr1;
        
        Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        insert csd1;
        Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
        insert jsd1;
        Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        insert csd2;
        Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
        insert jsd2;
       // Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(10).addHours(6), End_Date__c=todayDate.addDays(10), Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.adddays(10).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
        //insert csd3;
        //Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(10), Start_Date_Time__c = dateTimeVar.adddays(10).addHours(6), End_Date_Time__c = dateTimeVar.adddays(10).addHours(9),Status__c ='Open');
        //insert jsd3;
        Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
        insert crs1;
        ApexPages.StandardController stdController = new ApexPages.StandardController(job1); 
        PageReference pref=page.TRS_FilterCandidates;
        pref.getParameters().put('id', job1.id);
        Test.startTest();
        TRS_FilterCandidates fCandt = new TRS_FilterCandidates(stdController);
        fCandt.vacRecord = new TR1__Job__c ();
        fCandt.vacRecord.Sector1__c = 'Nursery';
        fCandt.vacRecord.Shift__c = 'Daily';
        //fCandt.selectedJobTitle=  'Test';
        fCandt.selectedSpecialism =  'Test';
        fCandt.vacRecord.Sub_Sector__c =  'Test';
        fCandt.getVacancyDetails();
        fCandt.gettimeSelectList();
        fCandt.getSortDirection();
        fCandt.isweekDayMapPopulated = false;
        fCandt.dummyFunction();
        fCandt.startDate = Date.Today();
        fCandt.grossProfit.TR1__Job__c = job1.id;
        Double stddate1 = 2 + fCandt.offset;
        String strDate = Date.Today().addDays(1).toStartofWeek().day()+'-'+Date.Today().addDays(1).toStartofWeek().Month()+'-'+Date.Today().addDays(1).toStartofWeek().Year();
        String endDate = Date.Today().toStartofWeek().addDays(6).day()+'-'+Date.Today().addDays(6).Month()+'-'+Date.Today().addDays(6).Year();
        String endDatenew = todayDate.addDays(7).day()+'-'+todayDate.addDays(7).Month()+'-'+todayDate.addDays(7).Year();
        strDate = strDate.replace('-' , '/');
        endDate = endDate.replace('-' , '/');
        system.debug('Dates format is ->'+strDate);
        fCandt.startDateStr = strDate;
        fCandt.endDateStr =endDate;
        String str =fCandt.jobTitles[0].getValue();        
        fCandt.getLEAOption();
        fCandt.getsubLEAs();
        fCandt.getSectors();
        //fCandt.getSubSectors();
        fCandt.getWeek();
        fCandt.complianceStatusValue = fCandt.complianceStatus[0].getValue();
        //fCandt.selectedSubSector = fCandt.subsectors[0].getValue();
        fCandt.candidateStatus = fCandt.candidatestautsList[0].getValue();
        //fCandt.selectedSpecialism = fCandt.specialisms[0].getValue();
        fCandt.updateWeek();
        fCandt.resetFilters();
        fCandt.whichContacts='My Candidates';
        system.currentPageReference().getParameters().put('contact1', con.id);
        fCandt.startDateEnterred = strDate;
        fCandt.endDateEnterred = endDate;
        fCandt.openDialogForClosingReport();

        fCandt.matchCSDJSDslots();
        
        system.currentPageReference().getParameters().put('partialsave', 'True');
        fCandt.saveClosingReport();
        system.currentPageReference().getParameters().put('partialsave', 'False');
        fCandt.saveClosingReport();
        fCandt.nextWeek();
        fCandt.previousWeek();
        fCandt.openCloneVacancyrecordDialog();
        fCandt.vacRecord.Shift__c = 'Hourly';
        fCandt.vacRecord.Maximum_Hour_Charge_Rate__c = null;
        fCandt.vacRecord.Maximum_Hour_Pay_Rate__c = null;
        fCandt.dummyFunction();
        fCandt.saveCreateVacancyRecord();
        fCandt.vacRecord.Shift__c = 'Daily';
        fCandt.vacRecord.TR1__Maximum_Pay_Rate__c = null;
        fCandt.vacRecord.TR1__Maximum_Bill_Rate__c = null;
        fCandt.saveCreateVacancyRecord();
        fCandt.vacRecord.Shift__c = 'Half Day';
        fCandt.vacRecord.TR1__Minimum_Bill_Rate__c = null;
        fCandt.vacRecord.TR1__Minimum_Pay_Rate__c = null;
        fCandt.vacRecord.Shift__c = 'Daily';
        fCandt.vacRecord.TR1__Maximum_Pay_Rate__c = 120;
        fCandt.vacRecord.TR1__Maximum_Bill_Rate__c = 120;
        
        fCandt.saveCreateVacancyRecord();
        fCandt.openCreateVacancyRecordDialog();
        fCandt.cancelVacancyCreation();
        fCandt.startDateStr = strDate;
        fCandt.endDateStr =endDatenew;
        List<String> strweek= fCandt.weekHeader;
        system.currentPageReference().getParameters().put('partialsave', 'True');
        fCandt.saveClosingReport();
        fCandt.setSortDirection('ASC');
        Test.stopTest();
    }
        }
}