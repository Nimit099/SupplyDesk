/***************************************************************************************
 * DESCRIPTION        : Test Class For TRS_FilterCandidates
 * CLASS              : TRS_FilterCandidates
 * DATE               : 12 DECEMBER 2022 (LAST CHANGES)
 * AUTHOR             : 
 * LAST MODIFIED      : MIHIR RAMOLIYA (MV CLOUDS)
 ***************************************************************************************/
@istest
private class TRS_FilterCandidatesTest {
    
    @TestSetup
    public static void testSetupData(){
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
    }
    
    public static testmethod void method_1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];   
        User u1 = new User(
            Alias = 'tete', 
            Email='testUser@suppludesk.com',
            EmailEncodingKey='UTF-8', 
            LastName='Gibson', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='GMT', 
            UserName='testTimesheet12@gmail.com',
            FirstName='Katherine'
        );
        
        system.runAs(u1) { 

            Date todayDate = system.today();
            DateTime dateTimeVar = system.today();
            Datetime dt1 = System.now();
            Account acc = new Account(Name='CVP', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                      shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country',Set_Account_GeoLocation__Latitude__s = 51.30,Set_Account_GeoLocation__Longitude__s = 51.30 );
            
            insert acc;

            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();

            Contact con = new Contact(
                AccountId = acc.id,
                LastName = 'portalTestUser',
                TR1__Candidate_Status__c = 'Placed',
                TR1__Client_Status__c = 'Active',
                OwnerId = u1.Id,
                Subject__c = 'Art',
                Year_Key_Stage__c = 'Y5(KS2)',
                Trained_As__c = 'Cover Supervisor',
                Sector__c = 'Junior',
                Assignment_Type__c = 'Long Term',
                Compliance_Status__c = 'Cleared',
                Pay_Type__c = '',
                Qualified_Schools_Candidate__c = 'YES',
                Phone = '5343434',
                MobilePhone = '3232323',
                Email = 'testEmail@gmail.com',
                Payroll_Number__c = '43434'
            ); 

            insert con;
            
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2', 
                                               Booking_Type__c = 'Daily', TR1__Estimated_Start_Date__c=todayDate,
                                               TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,
                                               TR1__Maximum_Bill_Rate__c=100, Year_Key_Stage__c ='KS1', SEN_Experience__c='ADHD',
                                               TR1__State_Area__c = 'UK', End_Time__c = '07:00 PM',
                                               School_Type__c = 'College (6th)', TR1__Contact__c = acc.Payroll_Primary_Contact__c,
                                               TR1__Hiring_Manager__c = acc.Payroll_Primary_Hiring_Manager__c,  TR1__Regional_Area__c='Barnet',
                                               Sector1__c='Junior', Selected_Week_Days__c = true, Applicable_Days__c = 'Monday;Tuesday;');

            insert job1;       
            
            Contact candidate1 = new Contact(RecordTypeId = conCandidId, LastName = 'Candidate 1', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c = 'EYFS',Email='test@test.com', Subject__c ='Art');
            Contact candidate2 = new Contact(RecordTypeId = conCandidId, LastName = 'Candidate 2',Email='test@test.com', Subject__c ='Art',Job_Titles__c = 'Senior Leader');
            Contact[] candidatelist = new Contact[]{candidate1,candidate2}; 

            insert candidatelist;
        
            Blacklisted__c bl = new Blacklisted__c(Candidate__c = candidate2.Id);
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 1250200.00, 
                                                                    TR1__Job_Percentage__c = 10,TR1__Candidate_Percentage__c = 10, TR1__Marketing_Percentage__c = 10, TR1__Other_Percentage__c = 10, TR1__Other2_Percentage__c = 60,
                                                                    Maximum_Day_Pay_Rate__c = 1200,Maximum_Day_Charge_Rate__c = 500,Maximum_Hour_Charge_Rate__c = 100,Maximum_Hour_Pay_Rate__c=15, 
                                                                    TR1__Job_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id);
            
            ClosingReportTriggerHelper.FromJobboard = True;
            cr1.Pay_Type__c='Hour';

            insert cr1;
            
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            Candidate_Availability__c[] candidateAvailabilitylist = new Candidate_Availability__c[]{csd1};  

            insert candidateAvailabilitylist; 
            
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(200), Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date_Time__c = dateTimeVar.adddays(200).addHours(9),Status__c ='Open');
            Vacancy_D2D__c[] vacancyAvailabilitylist = new Vacancy_D2D__c[]{jsd1,jsd2,jsd3};  

            insert vacancyAvailabilitylist;
            
            Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            
            insert crs1;
            
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(job1);
            PageReference pref=page.TRS_FilterCandidates;
            //Added By Accenture - NK
            test.setCurrentPage(pref);
            //
            pref.getParameters().put('id', con.id);
            pref.getParameters().put('save', 'True');
            
            TRS_FilterCandidates obj = new TRS_FilterCandidates (stdController);
            double offvar =  obj.offset;
            boolean isweekDayMapPopulate =  obj.isweekDayMapPopulated;
            obj.startDate = System.today();
            obj.endDate = system.today().addDays(+10);
            obj.isSortingByDistances = true;
            obj.dummyFunction();
            obj.getVacancyDetails();
            obj.resetFilters();
            obj.getWeek();
            obj.nextWeek();
            obj.previousWeek();
            obj.getvacancyStartDate();
            obj.setvacancyStartDate('27/05/2019');
            system.debug('obj.setvacancyStartDate() @@@@@ : '+ obj.startDateEnterred);
            System.debug(obj.isMidNight);
            
            obj.startDateStr = '27/05/2019';
            try{
                obj.updateWeek();
            }
            catch(exception e){
                
            }
            
            obj.sortDirection ='DSEC';
            obj.contact1 = con.Id;
            obj.MassSMSmethod();
            obj.AllSelectcandidate();
            string sExp = obj.sortExpression;
            obj.gettimeSelectList();
            obj.getSortDirection();
            obj.sortExpression = null;
            obj.getSortDirection();
            obj.setSortDirection('5');

            obj.openEditVacancyRecordDialog();
            obj.cancelEditVacancyCreation();
            
            List<SelectOption> listSelectoption = new List<SelectOption>();
            
            List<SelectOption> listSelectoption1 = new List<SelectOption>();

            // listSelectoption1 = obj.getDeselectedValues;
            
            List<string> weekHeaderlst = new List<string>();
            weekHeaderlst = obj.weekHeader;
            Try{
                obj.matchCSDJSDslots();
            }Catch(exception e){
                system.debug('Exception is --->'+e);
            }

            Set<String> test = new Set<String>();
            test = obj.leftValues;
            test = obj.picklistValues;
            
            obj.vacRecord.Shift__c = 'Hourly';
            obj.dummyFunction();
            
            obj.vacRecord.Shift__c = 'AM';
            obj.dummyFunction();
            
            obj.vacRecord.Shift__c = 'PM';
            obj.dummyFunction();
            obj.saveEditVacancyRecord();
            
            TRS_FilterCandidates.CSDJSDwrap obt = new TRS_FilterCandidates.CSDJSDwrap(null,null,null);
            TRS_FilterCandidates.dayDetail obD = new TRS_FilterCandidates.dayDetail(System.today(), '');
            TRS_FilterCandidates.ShiftClass sc = new TRS_FilterCandidates.ShiftClass();
            obj.previouspaginaton();
            obj.nextpaginaton();
            obj.changeListsize();
            
            obj.saveCreateVacancyRecord();
            obj.refresh();
            obj.openCreateVacancyRecordDialog();
            obj.openCloneVacancyrecordDialog();
            obj.cancelVacancyCreation();
            obj.saveClosingReport();
            obj.deleteEditVacancyCreation();
            // obj.weekdayFunction();
            
            cr1.Maximum_Day_Pay_Rate__c = null;
            obj.saveCreateVacancyRecord();

            TRS_FilterCandidates.DayDetailWrapper obddw = new TRS_FilterCandidates.DayDetailWrapper();
        }       
    }
    
    public Static testMethod void method_2(){
        Account acc = new Account(Name='CVP',BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                  shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country', 
                                  Set_Account_GeoLocation__Latitude__s=53.47, Set_Account_GeoLocation__Longitude__s=-1.46);
        insert acc;
        Id CANDIDATE_RECORDTYPE_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        
        Contact testContact = new Contact(
            AccountId = acc.id,
            LastName = 'portalTestUser',
            TR1__Candidate_Status__c = 'Placed',
            TR1__Client_Status__c = 'Active',
            Subject__c = 'Art',
            Year_Key_Stage__c = 'Y5(KS2)',
            Trained_As__c = 'Cover Supervisor',
            Sector__c = 'Junior',
            Assignment_Type__c = 'Long Term',
            Compliance_Status__c = 'Cleared',
            Pay_Type__c = '',
            Qualified_Schools_Candidate__c = 'YES',
            Phone = '5343434',
            MobilePhone = '3232323',
            Email = 'testEmail@gmail.com',
            Payroll_Number__c = '43434'
        ); 

        insert testContact;

        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId(),TR1__Account__c=acc.Id,Name='Job 2',TR1__Estimated_Start_Date__c=Date.today().addDays(8),TR1__Estimated_End_Date__c=Date.today().addDays(7),TR1__Contact__c=testContact.Id,Sector1__c='Nursery', Year_Key_Stage__c ='KS1',Applicable_Days__c = 'Monday;Tuesday;', Selected_Week_Days__c = true);
        job1.Shift__c = 'Hourly';
        TR1__Job__c[] joblist = new TR1__Job__c[]{job1};
            insert joblist;
        
        Contact candidate1 = new Contact(LastName = 'Candidate 1',Email='test@test.com', Subject__c ='Art');
        insert candidate1;
        
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = testContact.Id, TR1__Salary__c = 1250200.00, 
                                                                    TR1__Job_Percentage__c = 10,TR1__Candidate_Percentage__c = 10, TR1__Marketing_Percentage__c = 10, TR1__Other_Percentage__c = 10, TR1__Other2_Percentage__c = 60,
                                                                    Maximum_Day_Pay_Rate__c = 1200,Maximum_Day_Charge_Rate__c = 500,Maximum_Hour_Charge_Rate__c = 100,Maximum_Hour_Pay_Rate__c=15, 
                                                                    TR1__Job_Credit__c = UserInfo.getUserId(),
                                                                    TR1__Start_Date__c = system.today().addDays(-15), TR1__End_Date__c = system.today().addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidate1.Id);
        
        ClosingReportTriggerHelper.FromJobboard = True;
        cr1.TR1__Person_Placed__c = testContact.id;
        cr1.TR1__Account__c = acc.id;
        insert cr1;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(job1);
        PageReference pref=page.TRS_FilterCandidates;
        //Added By Accenture - NK
        test.setCurrentPage(pref);
        pref.getParameters().put('id', job1.id);
        pref.getParameters().put('save', 'True');
        
        TRS_FilterCandidates obj = new TRS_FilterCandidates (stdController);
        obj.saveClosingReport();
    }
    
    public static testmethod void method_3(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];   
        User u1 = new User(
            Alias = 'tete', 
            Email='testUser@suppludesk.com',
            EmailEncodingKey='UTF-8', 
            LastName='Gibson', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='GMT', 
            UserName='testTimesheet12@gmail.com',
            FirstName='Katherine'
        );

        system.runAs(u1) { 
            
            DateTime dateTimeVar = system.today();
            Date todayDate = system.today();
            
            Account acc = new Account(Name='CVP',BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                      shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country', 
                                      Set_Account_GeoLocation__Latitude__s=53.47, Set_Account_GeoLocation__Longitude__s=-1.46);
            insert acc;
            Id CANDIDATE_RECORDTYPE_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact testContact = new Contact(
            AccountId = acc.id,
            LastName = 'portalTestUser',
            TR1__Candidate_Status__c = 'Placed',
            TR1__Client_Status__c = 'Active',
            OwnerId = u1.Id,
            Subject__c = 'Art',
            Year_Key_Stage__c = 'Y5(KS2)',
            Trained_As__c = 'Cover Supervisor',
            Sector__c = 'Junior',
            Assignment_Type__c = 'Long Term',
            Compliance_Status__c = 'Cleared',
            Pay_Type__c = '',
            Qualified_Schools_Candidate__c = 'YES',
            Phone = '5343434',
            MobilePhone = '3232323',
            Email = 'testEmail@gmail.com',
            Payroll_Number__c = '43434'
        ); 

            insert testContact;
            
            //Id consultingid =
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId(),TR1__Account__c=acc.Id,Name='Job 2',TR1__Estimated_Start_Date__c=Date.today().addDays(8),TR1__Estimated_End_Date__c=Date.today().addDays(7),TR1__Contact__c=testContact.Id,Sector1__c='Nursery', Year_Key_Stage__c ='KS1', Selected_Week_Days__c = true,Applicable_Days__c = 'Monday;Tuesday;');
            job1.Shift__c = 'Hourly';
            TR1__Job__c job2 = new TR1__Job__c(RecordTypeId=Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId(),TR1__Account__c=acc.Id,Name='Job 2',TR1__Estimated_Start_Date__c=Date.today().addDays(8),TR1__Estimated_End_Date__c=Date.today().addDays(7),TR1__Contact__c=testContact.Id,Sector1__c='Nursery', Year_Key_Stage__c ='KS1',Selected_Week_Days__c = true,Applicable_Days__c = 'Monday;Tuesday;');
            job1.Shift__c = 'Hourly';
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1, job2};
                insert joblist;
            
            Contact candidate1 = new Contact(LastName = 'Candidate 1',Email='test@test.com', Subject__c ='Art');
            Contact[] candidatelist = new Contact[]{candidate1};
                insert candidatelist;
            
            Blacklisted__c bl = new Blacklisted__c();
            bl.Candidate__c = candidatelist[0].id;
            bl.Company__c = job1.TR1__Account__c;
            insert bl;
            
            Id rt = Schema.SObjectType.TR1__Screening__c.getRecordTypeInfosByName().get('Disclaimer').getRecordTypeId();
            TR1__Screening__c scr = new TR1__Screening__c();
            scr.Company__c = job1.TR1__Account__c;
            scr.RecordTypeId = rt;
            insert scr;
            
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(1), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            insert jsd1;
            
            Candidate_Availability__c cAvail = new Candidate_Availability__c();
            cAvail.Start_Date__c = system.today().addDays(20);
            cAvail.End_Date__c = system.today().addDays(-20);
            cAvail.Start_Date_Time__c=system.today().addDays(20);
            cAvail.End_Date_Time__c = system.today().addDays(-20);
            cAvail.Candidate__c = testContact.id;
            System.debug('cAvail@@@@@@  :  '+ cAvail);
            insert cAvail;
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = testContact.Id, TR1__Salary__c = 1250200.00, 
                                                                    TR1__Job_Percentage__c = 10,TR1__Candidate_Percentage__c = 10, TR1__Marketing_Percentage__c = 10, TR1__Other_Percentage__c = 10, TR1__Other2_Percentage__c = 60,
                                                                    Maximum_Day_Pay_Rate__c = 1200,Maximum_Day_Charge_Rate__c = 500,Maximum_Hour_Charge_Rate__c = 100,Maximum_Hour_Pay_Rate__c=15, 
                                                                    TR1__Job_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id);
            
            ClosingReportTriggerHelper.FromJobboard = True;
            cr1.TR1__Person_Placed__c = testContact.id;
            cr1.TR1__Account__c = acc.id;
            insert cr1;
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(job1);
            PageReference pref=page.TRS_FilterCandidates;
            //Added By Accenture - NK
            test.setCurrentPage(pref);
            //
            pref.getParameters().put('id', job1.id);
            pref.getParameters().put('save', 'True');

            Test.startTest();
                TRS_FilterCandidates obj = new TRS_FilterCandidates (stdController);
                double offvar =  obj.offset;
                boolean isweekDayMapPopulate =  obj.isweekDayMapPopulated;
                obj.isSortingByDistances = true;
                obj.dummyFunction();
                obj.getVacancyDetails();
                obj.resetFilters();
                obj.getWeek();
                obj.nextWeek();
                obj.previousWeek();
                obj.previouspaginaton();
                obj.changeListsize();
                obj.getResourceAvailability();
                obj.openDialogForClosingReport();
                System.debug(obj.isMidNight);
                
                // obj.startDateStr = '03-09-2018';
                try{
                    obj.updateWeek();
                }
                catch(exception e){
                    
                }
                
                string sExp = obj.sortExpression;
                obj.gettimeSelectList();
                obj.getSortDirection();
                obj.sortExpression = null;
                obj.getSortDirection();
                obj.setSortDirection('5');
                List<SelectOption> listSelectoption = new List<SelectOption>();
                List<SelectOption> listSelectoption1 = new List<SelectOption>();
                
                List<string> weekHeaderlst = new List<string>();
                weekHeaderlst = obj.weekHeader;
                
                obj.vacRecord.Shift__c = 'Hourly';
                obj.dummyFunction();
                
                obj.vacRecord.Shift__c = 'AM';
                obj.dummyFunction();
                
                obj.vacRecord.Shift__c = 'PM';
                obj.dummyFunction();
                
                TRS_FilterCandidates.CSDJSDwrap obt = new TRS_FilterCandidates.CSDJSDwrap(null,null,null);
                system.debug(obt.vaccAvail);
                system.debug(obt.canAvail);
                system.debug(obt.Colour);
                system.debug(obt.vaccAvail);
                
                TRS_FilterCandidates.dayDetail obD = new TRS_FilterCandidates.dayDetail(System.today(), '');
                system.debug(obj.showSection);
                system.debug(obD.assignedJobId);
                system.debug(obD.personPlacedName);
                system.debug(obD.closingReportSchedule);
                system.debug(obD.assignedJobName);
                system.debug(obD.personPlacedId);
                system.debug(obD.shift);
                system.debug(obD.VacAvailshift);
                system.debug(obD.CandidAvailshift);
                system.debug(obD.showAssignButton);
                system.debug(obD.cancelAssignButton);
                system.debug(obj.candidateRecord);
                system.debug(obj.showAssignmentDialogBox);
                system.debug(obj.showCreateVacancyRecord);
                
                TRS_FilterCandidates.ShiftClass sc = new TRS_FilterCandidates.ShiftClass();
                system.debug(sc.isActive);
                system.debug(sc.selectedType);
                system.debug(sc.optionList);
                system.debug(sc.shiftDate);
                system.debug(sc.bookingType);
                obj.saveClosingReport();
                obj.saveCreateVacancyRecord();
                obj.createStringForMultiSelectFields('test;test');
                obj.con.OtherPostalCode = '20002';
                obj.vacRecord.Sub_Sector__c = 'test';
                obj.con.Job_Titles__c = 'sfdc';
                obj.VacancyRecord.TR1__Contact__c = testContact.id;
                obj.candidateStatus = 'Vetted';
                
                obj.con.Division__c = 'Brighton Primary';
                
                obj.con.SEN_Additional_Experience__c = 'Art Therapy';
                obj.con.SEN_Experience__c = 'ADHD';
                obj.con.Subject__c = 'Art and Design';
                obj.con.TR1__Regional_Area__c ='Alabama';
                obj.con.AccountId = acc.Id;
                obj.whichContacts = 'My Candidates';
                obj.con.Hidden_Scheduler_Filter__c = USerInfo.getUserId();
                obj.con.Trained_As__c = 'Cover Supervisor';
                
                obj.con.Preferred_LEA__c = 'Darlington';
                obj.con.LEA__c = 'North East';
                obj.con.Qualificaitons__c = 'Postgraduate Diploma of Education (secondary)';
                obj.con.Skills_Training_Experience__c = 'Careers Advisor';
                obj.con.Year_Key_Stage__c = 'Nursery 0-5yrs';
                
                obj.vacRecord.TR1__Account__c = acc.id;
                obj.sortDirection = 'desc';
                obj.doSchoolNamePopulate();
                obj.refresh();
                obj.openCreateVacancyRecordDialog();
                obj.openCloneVacancyrecordDialog();
                obj.cancelVacancyCreation();
                system.debug(obj.selectedSector);
                system.debug(obj.selectedSubSector);
                system.debug(obj.isJobTitleDisplay);
                system.debug(obj.selectedLEA);
                system.debug(obj.selectedSubLEA);
                system.debug(obj.getLEAOption());
                system.debug(obj.LEAOption);
                system.debug(obj.getsubLEAs());
                system.debug(obj.getSectors());
                system.debug(obj.jobTitles);
                system.debug(obj.formatDateTimefromDate(System.Today(), '12:21 AM'));
                system.debug(obj.formatDateTimefromDate(System.Today(), '10:21 AM'));
                system.debug(obj.closeRep);
                system.debug(obj.closeRepSchedule);
                
                system.debug(obj.endDateStr);
                system.debug(obj.closeRepSchedule);
                system.debug(obj.closeRepSchedule);
                
                TRS_FilterCandidates.DayDetailWrapper obddw = new TRS_FilterCandidates.DayDetailWrapper();
                system.debug(obddw.Startdate);
                system.debug(obddw.dayDetail2);
                system.debug(obddw.showDayDetail2);
                system.debug(obddw.showDayDetail2);
                system.debug(obddw.candidD2DList1);
            Test.stopTest();
        }       
    }

    public static testmethod void method_4(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];   
        User u1 = new User(
            Alias = 'tete', 
            Email='testUser@suppludesk.com',
            EmailEncodingKey='UTF-8', 
            LastName='Gibson', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='GMT', 
            UserName='testTimesheet12@gmail.com',
            FirstName='Katherine'
        );
        
        system.runAs(u1) { 

            Date todayDate = system.today();
            DateTime dateTimeVar = system.today();
            Datetime dt1 = System.now();
            Account acc = new Account(Name='CVP', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                      shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country',Set_Account_GeoLocation__Latitude__s = 51.30,Set_Account_GeoLocation__Longitude__s = 51.30 );
            
            insert acc;

            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();

            Contact con = new Contact(
                AccountId = acc.id,
                LastName = 'portalTestUser',
                TR1__Candidate_Status__c = 'Placed',
                TR1__Client_Status__c = 'Active',
                OwnerId = u1.Id,
                Subject__c = 'Art',
                Year_Key_Stage__c = 'Y5(KS2)',
                Trained_As__c = 'Cover Supervisor',
                Sector__c = 'Junior',
                Assignment_Type__c = 'Long Term',
                Compliance_Status__c = 'Cleared',
                Pay_Type__c = '',
                Qualified_Schools_Candidate__c = 'YES',
                Phone = '5343434',
                MobilePhone = '3232323',
                Email = 'testEmail@gmail.com',
                Payroll_Number__c = '43434'
            ); 

            insert con;
            
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2', 
                                               Booking_Type__c = 'Daily', TR1__Estimated_Start_Date__c=todayDate,
                                               TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,
                                               TR1__Maximum_Bill_Rate__c=100, Year_Key_Stage__c ='KS1', SEN_Experience__c='ADHD',
                                               TR1__State_Area__c = 'UK', End_Time__c = '07:00 PM',
                                               School_Type__c = 'College (6th)', TR1__Contact__c = acc.Payroll_Primary_Contact__c,
                                               TR1__Hiring_Manager__c = acc.Payroll_Primary_Hiring_Manager__c,  TR1__Regional_Area__c='Barnet',
                                               Sector1__c='Junior', Selected_Week_Days__c = true, Applicable_Days__c = 'Monday;Tuesday;');

            insert job1;     
            
            TR1__Job__c job11 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2', 
                                               Booking_Type__c = 'Daily', TR1__Estimated_Start_Date__c=todayDate,
                                               TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,
                                               TR1__Maximum_Bill_Rate__c=100, Year_Key_Stage__c ='KS1', SEN_Experience__c='ADHD',
                                               TR1__State_Area__c = 'UK', End_Time__c = '07:00 PM', Shift__c = 'Hourly',Job_Title__c = 'cdce',
                                               School_Type__c = 'College (6th)', TR1__Contact__c = con.Id,
                                               TR1__Hiring_Manager__c = con.Id,  TR1__Regional_Area__c='Barnet',
                                               Sector1__c='Junior', Selected_Week_Days__c = true, Applicable_Days__c = 'Monday;Tuesday;');
            
            Contact candidate1 = new Contact(RecordTypeId = conCandidId, LastName = 'Candidate 1', Candidate_Type__c = 'Qualified Teacher', Qualificaitons__c = 'EYFS',Email='test@test.com', Subject__c ='Art');
            Contact candidate2 = new Contact(RecordTypeId = conCandidId, LastName = 'Candidate 2',Email='test@test.com', Subject__c ='Art',Job_Titles__c = 'Senior Leader');
            Contact[] candidatelist = new Contact[]{candidate1,candidate2}; 

            insert candidatelist;
        
            Blacklisted__c bl = new Blacklisted__c(Candidate__c = candidate2.Id);
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 1250200.00, 
                                                                    TR1__Job_Percentage__c = 10,TR1__Candidate_Percentage__c = 10, TR1__Marketing_Percentage__c = 10, TR1__Other_Percentage__c = 10, TR1__Other2_Percentage__c = 60,
                                                                    Maximum_Day_Pay_Rate__c = 1200,Maximum_Day_Charge_Rate__c = 500,Maximum_Hour_Charge_Rate__c = 100,Maximum_Hour_Pay_Rate__c=15, 
                                                                    TR1__Job_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id);
            
            ClosingReportTriggerHelper.FromJobboard = True;
            cr1.Pay_Type__c='Hour';

            insert cr1;
            
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            Candidate_Availability__c[] candidateAvailabilitylist = new Candidate_Availability__c[]{csd1};  

            insert candidateAvailabilitylist; 
            
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(200), Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date_Time__c = dateTimeVar.adddays(200).addHours(9),Status__c ='Open');
            Vacancy_D2D__c[] vacancyAvailabilitylist = new Vacancy_D2D__c[]{jsd1,jsd2,jsd3};  

            insert vacancyAvailabilitylist;
            
            Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            
            insert crs1;
            
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(job1);
            PageReference pref=page.TRS_FilterCandidates;
            //Added By Accenture - NK
            test.setCurrentPage(pref);
            //
            pref.getParameters().put('id', con.id);
            pref.getParameters().put('save', 'True');
            
            TRS_FilterCandidates obj = new TRS_FilterCandidates (stdController);
            double offvar =  obj.offset;
            boolean isweekDayMapPopulate =  obj.isweekDayMapPopulated;
            
            Map<String,  Map<String, String>> temp_t = new Map<String, Map<String, String>>();
            Map<String, String> temp_map = new Map<String, String>();
            temp_map.put('ST', '12:00 AM');
            temp_map.put('ET', '01:00 AM');

            temp_t.put('Monday', temp_map);
            temp_t.put('Tuesday', temp_map);

            obj.weekData = temp_t;

            obj.vacRecord = job11;
            obj.clonevacancy = false; 
            // obj.saveEditVacancyRecord(); 
            obj.saveCreateVacancyRecord(); 


            TRS_FilterCandidates.DayDetailWrapper obddw = new TRS_FilterCandidates.DayDetailWrapper();
        }       
    }
}