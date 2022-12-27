@isTest
public class TRS_FilterJobsTest {
    public static testMethod void test() {
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                           EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                           LocaleSidKey='fr_FR', ProfileId = p.Id,
                           TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
            system.runAs(u1) { 
            Date todayDate = system.today();
            DateTime dateTimeVar = system.today();
            Datetime dt1 = System.now();
            Account acc = new Account(Name='CVP', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                      shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
            
            insert acc;
            // User testUser = TestDataUtility.createUser(true);
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            
            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,  Subject__c ='Art',
                                      Compliance_Owner__c = u1.Id, Year_Key_Stage__c = 'KS1',TR1__Candidate_Status__c = 'DNU',Compliance_Status__c = 'Cleared',Pay_Type__c = 'Perm', Trained_As__c = 'Instructor',
                                      Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm', References_AQ_Hidden__c='Active',ID_AQ_Hidden__c='Active',Barred_List_AQ_Hidden__c='Active',
                                      Perm_Qualification_AQ_Hidden__c='Active',Right_to_Work_AQ_Hidden__c='Active'); 
            con.Trained_As__c = 'Cover Supervisor';
            con.Sector__c = 'Junior';
            con.Job_Titles__c = 'Acting Principal';
            con.Assignment_Type__c = 'Full Time';
            insert con;
            
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100, Year_Key_Stage__c ='KS1', SEN_Experience__c='ADHD',
                                               TR1__State_Area__c = 'UK',TR1__Regional_Area__c='Barnet',Sector1__c='Junior');
            insert job1;       
            
            
            Contact candidate1 = new Contact(LastName = 'Candidate 1', Qualificaitons__c = 'Bachelor of Primary Education',Email='test@test.com', Subject__c ='Art');
            Contact candidate2 = new Contact(LastName = 'Candidate 2',Email='test@test.com', Subject__c ='Art');
            Contact[] candidatelist = new Contact[]{candidate1,candidate2};  
            insert candidatelist;
            
            Blacklisted__c bl = new Blacklisted__c(Candidate__c = candidate2.Id);
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 1250200.00, 
                                                                    TR1__Job_Percentage__c = 10,TR1__Candidate_Percentage__c = 10, TR1__Marketing_Percentage__c = 10, TR1__Other_Percentage__c = 10, TR1__Other2_Percentage__c = 60,
                                                                    Maximum_Day_Pay_Rate__c = 1200,Maximum_Day_Charge_Rate__c = 500,Maximum_Hour_Charge_Rate__c = 100,Maximum_Hour_Pay_Rate__c=15, 
                                                                    TR1__Job_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            //ClosingReportTriggerHelper.FromJobboard = True;
            insert cr1;
            
            TR1__Closing_Report__c cr2 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, 
                                                                    TR1__Job_Percentage__c = 20,TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
                                                                    Maximum_Day_Pay_Rate__c = 30,Maximum_Day_Charge_Rate__c = 100,Maximum_Hour_Charge_Rate__c = 10,Maximum_Hour_Pay_Rate__c=1.5, 
                                                                    TR1__Job_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            //ClosingReportTriggerHelper.FromJobboard = True;
            // insert cr2;
            
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            //  Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            //  Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date__c=todayDate.addDays(200), Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.adddays(200).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            Candidate_Availability__c[] candidateAvailabilitylist = new Candidate_Availability__c[]{csd1};  
            insert candidateAvailabilitylist;
            
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(200), Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date_Time__c = dateTimeVar.adddays(200).addHours(9),Status__c ='Open');
            Vacancy_D2D__c[] vacancyAvailabilitylist = new Vacancy_D2D__c[]{jsd1,jsd2,jsd3};  
            insert vacancyAvailabilitylist;
            
            // Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            // insert crs1;
            
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
            Test.setCurrentPage(page.TRS_FilterJobs);
            TRS_FilterJobs fCandt = new TRS_FilterJobs(stdController);
            fCandt.openCreateVacancyRecordDialog();
            fCandt.saveCreateVacancyRecord();
            fCandt.cancelVacancyCreation();
            fCandt.vacRecord = new TR1__Job__c ();
            
            fCandt.getResourceAvailability();
            fCandt.getCandidateDetails();
            //Filter Results
            fCandt.VacRec.TR1__Regional_Area__c = 'Barnet';
            fCandt.VacRec.TR1__Contact__c = con.id;
            fCandt.conTemp.LEA__c = 'Test';
            fCandt.VacRec.Qualifications__c = 'Test';
            fCandt.VacRec.SEN_Experience__c = 'Test';
            fCandt.VacRec.Skills_Training_Experience__c = 'Test';
            fCandt.VacRec.SEN_Additional_Experience__c = 'Test';
            fCandt.VacRec.Year_Key_Stage__c = 'KS1';
            fCandt.closingReport = new TR1__Closing_Report__c();
            fCandt.vacRecord.Sector1__c = 'Junior';
            // fCandt.selectedJobTitle=  new List<String>{fCandt.jobTitles[0].getValue(),'Test2'};
            fCandt.selectedSpecialism =new List<String>{fCandt.specialisms[0].getValue(),'Test2'};
            // fCandt.selectedSector =new List<String>{'Test2'};
            fCandt.vacRecord.Sub_Sector__c =  'Test';
            fCandt.getSectors();
            fCandt.getSortDirection();
            fCandt.startDate = Date.Today();
            fCandt.grossProfit.TR1__Job__c = job1.id;
            Double stddate1 = 2 + fCandt.offset;
            String strDate = Date.Today().toStartofWeek().day()+'-'+Date.Today().toStartofWeek().Month()+'-'+Date.Today().toStartofWeek().Year();
            String endDate = Date.Today().toStartofWeek().addDays(6).day()+'-'+Date.Today().addDays(6).Month()+'-'+Date.Today().addDays(6).Year();
            String endDatenew = todayDate.addDays(9).day()+'-'+todayDate.addDays(9).Month()+'-'+todayDate.addDays(9).Year();
            strDate = strDate.replace('-' , '/');
            endDate = endDate.replace('-' , '/');
            endDatenew = endDatenew.replace('-' , '/');
            
            fCandt.startDateStr = strDate;
            fCandt.endDateStr =endDate;
           
            fCandt.getSectors();
            fCandt.updateWeek();
            fCandt.resetFilters();
            fCandt.whichVacancy='All Vacancies';
            
            //Positive Case
            system.currentPageReference().getParameters().put('Job1', job1.id);
            fCandt.endDate = date.Today().addDays(-9);
            fCandt.startDateStr = strDate;
            fCandt.endDateStr =endDatenew;
            fCandt.openDialogForClosingReport();
            
            fCandt.endDateEnterred = strDate;
            fCandt.startDateEnterred = endDatenew;
            fCandt.closingReport.Comparator_Full_Time_Annual_Salary__c = 0.00;
            fCandt.closingReport.TR1__Person_Placed__c=con.id;
            fCandt.closingReport.School_Working_Days__c = 0.00;
            fCandt.closingReport.Annual_Leave_Entitlement__c = '0';
            
            system.currentPageReference().getParameters().put('partialsave', 'True');
            fCandt.saveClosingReport();
            fCandt.refresh();
           
            fCandt.getSortDirection();
            
            //Negative Case : End Date is null
            fCandt.endDateEnterred = null;
            fCandt.saveClosingReport();

            //Negative Case : Start Date & End Date are null
            fCandt.startDateEnterred = null;
            fCandt.saveClosingReport();

            //Negative Case : Start Date is null
            fCandt.endDateEnterred = endDatenew;
            fCandt.saveClosingReport();

            fCandt.vacRecord.Year_Key_Stage__c='';
            fCandt.saveCreateVacancyRecord();

            fCandt.vacRecord.Subject2__c='';
            fCandt.saveCreateVacancyRecord();

            fCandt.nextWeek();
            fCandt.previousWeek();
            // fCandt.openCloneVacancyrecordDialog();
            // List<String> strweek= fCandt.weekHeader;
            // strweek[0] = fCandt.getWeek();
            
            List<SelectOption> so = fCandt.whichVacancyOptions;
            // TR1__Job__c job = fCandt.job;
            fCandt.vacRecord.Shift__c='';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='AM';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='PM';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='Hourly';
            fCandt.dummyFunction();
            
            fCandt.setsortdirection('ASC');
            fCandt.getSortDirection();
            fCandt.setSortDirection('');
            fCandt.getSortDirection();
            fCandt.sortExpression= null;
            fCandt.startDateStr = String.valueOf( system.today());
            fCandt.endDateStr = String.valueOf( system.today().addDays(5));
            /*fCandt.vacancyStartDate = String.valueOf(system.today());
            system.debug('@@@@@@fCandt.vacancyStartDate : ' + fCandt.vacancyStartDate);*/
            fCandt.getWeek();
            fCandt.previouspaginaton();
            fCandt.nextpaginaton();
            fCandt.changeListsize();
            fCandt.getResourceAvailability();
            fCandt.matchCSDJSDslots();
            fCandt.vacRecord.TR1__Account__c = acc.Id;
            fCandt.doSchoolNamePopulate();
            
            
            List<Closing_Report_Schedule__c> templist= [Select Id from Closing_Report_Schedule__c];
            delete templist;
            List<TR1__Closing_Report__c> templist1= [Select Id from TR1__Closing_Report__c];
            delete templist1;
            
            fCandt.closingReport = null;
            fCandt.openDialogForClosingReport();
            fCandt.endDateEnterred = strDate;
            fCandt.startDateEnterred = endDatenew;
            fCandt.closingReport.Comparator_Full_Time_Annual_Salary__c = 0.00;
            fCandt.closingReport.TR1__Person_Placed__c=con.id;
            fCandt.closingReport.School_Working_Days__c = 0.00;
            fCandt.closingReport.Annual_Leave_Entitlement__c = '0';
            system.currentPageReference().getParameters().put('partialsave', 'True');
            fCandt.saveClosingReport();
            fCandt.refresh();
            
            
            fCandt.closingReport.Pay_Type__c= 'Hour';
            fCandt.closingReport.Maximum_Hour_Pay_Rate__c=null;
            fCandt.saveClosingReport();
            
            
            fCandt.closingReport.Pay_Type__c= 'Day';
            fCandt.closingReport.Maximum_Day_Pay_Rate__c=null;
            fCandt.saveClosingReport();
            
            fCandt.closingReport.Pay_Type__c= 'Half-Day';
            fCandt.closingReport.Maximum_Half_Day_Pay_Rate__c=null;
            fCandt.saveClosingReport();
            
            
            // TRS_FilterJobs fCandt2 = new TRS_FilterJobs(stdController);
            // system.currentPageReference().getParameters().put('Job1', job1.id);
            
            // fCandt2.vacRecord = new TR1__Job__c ();
            // fCandt2.closingReport = new TR1__Closing_Report__c();
            // fCandt2.vacRecord.Sector1__c = 'Junior';
            // //fCandt2.selectedJobTitle=  new List<String>{fCandt2.jobTitles[0].getValue(),'Test2'};
            // fCandt2.selectedSpecialism =new List<String>{fCandt2.specialisms[0].getValue(),'Test2'};
            //     //fCandt2.selectedSector =new List<String>{'Test2'};
            //     //fCandt2.vacRecord.Sub_Sector__c =  'Test';
            // //     fCandt2.getSectors();
            // // fCandt2.getSortDirection();
            // fCandt2.startDate = Date.Today();
            // fCandt2.grossProfit.TR1__Job__c = job1.id;
            // system.debug('Dates format is ->'+strDate);
            // fCandt2.startDateStr = strDate;
            // fCandt2.endDateStr =endDate;
            // fCandt2.getSectors();
            // fCandt2.updateWeek();
            // fCandt2.previouspaginaton();
            // fCandt2.nextpaginaton();
            // fCandt2.changeListsize();
            
            // fCandt2.resetFilters();
            // fCandt.whichVacancy='All Candidates';
            // system.currentPageReference().getParameters().put('Job1', job1.id);
            // fCandt.endDate = date.Today();
            // fCandt2.startDateStr = strDate;
            // fCandt2.endDateStr =endDate;
            // // fCandt2.openDialogForClosingReport();
            // fCandt2.vacancyStartDate = String.valueOf(system.today());
            // system.debug('@@@@@@fCandt.vacancyStartDate : ' + fCandt2.vacancyStartDate);
            // // fCandt2.matchCSDJSDslots();
            // fCandt2.vacRecord = new TR1__Job__c ();
            // system.currentPageReference().getParameters().put('partialsave', 'false');
            // fCandt2.vacRecord.Shift__c = 'Daily';
            // fCandt2.vacRecord.TR1__Maximum_Pay_Rate__c = 120;
            // fCandt2.vacRecord.TR1__Maximum_Bill_Rate__c = 120;
            // fCandt2.saveClosingReport();
            
            Test.stopTest();
        }
    }
    
        
    public static testMethod void test2(){
        Test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
            User u1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                               LocaleSidKey='fr_FR', ProfileId = p.Id,
                               TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
            system.runAs(u1) { 
                Date todayDate = system.today();
                DateTime dateTimeVar = system.today();
                Datetime dt1 = System.now();
                Account acc = new Account(Name='CVP', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                          shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
                
                insert acc;
                // User testUser = TestDataUtility.createUser(true);
                Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                
                Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,  Subject__c ='Art',
                                          Compliance_Owner__c = u1.Id, Year_Key_Stage__c = 'KS1',TR1__Candidate_Status__c = 'DNU',Compliance_Status__c = 'Cleared',Pay_Type__c = 'Perm', Trained_As__c = 'Instructor',
                                          Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm', References_AQ_Hidden__c='Active',ID_AQ_Hidden__c='Active',Barred_List_AQ_Hidden__c='Active',
                                          Perm_Qualification_AQ_Hidden__c='Active',Right_to_Work_AQ_Hidden__c='Active'); 
                con.Trained_As__c = 'Cover Supervisor';
                con.Sector__c = 'Junior';
                con.Job_Titles__c = 'Acting Principal';
                con.Assignment_Type__c = 'Full Time';
                insert con;
                
                Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
                TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100, Year_Key_Stage__c ='KS1', SEN_Experience__c='ADHD',
                                                   TR1__State_Area__c = 'UK',TR1__Regional_Area__c='Barnet',Sector1__c='Junior');
                insert job1;      
                
                ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
                Test.setCurrentPage(page.TRS_FilterJobs);
                ApexPages.currentPage().getParameters().put('Job1',job1.Id);
                TRS_FilterJobs fCandt = new TRS_FilterJobs(stdController);
                
                // ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
                
                TRS_FilterJobs f = new TRS_FilterJobs(stdController);
                // ApexPages.currentPage().getParameters().put('Id',emp.id);
                // f.closingReport.School_Working_Days__c = null;
                f.saveClosingReport();
                
                f.vacancyStartDate = String.valueOf(System.today());
                // f.vacancyD2DMap = new Map<Id, List<Vacancy_D2D__c>>();
                // fCandt.vacancyD2DMap = .put(Job1.Id, new List<Vacancy_D2D__c>());
                f.matchCSDJSDslots();
                f.test();
            Test.stopTest();
        }
    }
    
}