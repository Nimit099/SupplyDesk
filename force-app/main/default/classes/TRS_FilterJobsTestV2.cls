/***************************************************************************************
 * DESCRIPTION          : Test Class For TRS_FilterJobs
 * CLASS                : TRS_FilterJobs
 * DATE                 : 12 DECEMBER 2022 (CREATED)
 * AUTHOR               : MIHIR RAMOLIYA (MV CLOUDS)
 * LAST MODIFIED        : MIHIR RAMOLIYA (MV CLOUDS)
 ***************************************************************************************/
@isTest
public class TRS_FilterJobsTestV2 {

    public static testMethod void test_method1() {

        Test.startTest();

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

        Account acc = new Account(
            Name='UNKNOWN DO NOT DELETE', 
            BillingStreet  ='123', 
            BillingCity ='test city', 
            BillingState ='test county', 
            BillingPostalCode  = '234345', 
            BillingCountry  = 'test Country',
            shippingStreet = '1233',
            shippingCity='Test City',
            ShippingState='Test State',
            shippingPostalCode='564533',
            shippingCountry='Test Country'
        );
        
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
        
        TR1__Job__c job1 = new TR1__Job__c(
            RecordTypeId=consultingid,
            TR1__Account__c=acc.Id,
            Name='Job 2',
            TR1__Contact__c=con.Id,
            TR1__Estimated_Start_Date__c=todayDate,
            TR1__Estimated_End_Date__c=todayDate.addDays(7),
            TR1__Minimum_Pay_Rate__c=100,
            TR1__Maximum_Bill_Rate__c=100, 
            Year_Key_Stage__c ='KS1', 
            SEN_Experience__c='ADHD',
            TR1__State_Area__c = 'UK',
            TR1__Regional_Area__c='Barnet',
            Sector1__c='Junior'
        );
        insert job1;       
            
            
        Contact candidate1 = new Contact(
            LastName = 'Candidate 1', 
            Email='test@test.com', 
            Subject__c ='Art'
        );
        Contact candidate2 = new Contact(
            LastName = 'Candidate 2',
            Email='test@test.com', 
            Subject__c ='Art'
        );
        Contact[] candidatelist = new Contact[]{candidate1,candidate2};  
        insert candidatelist;
            
        Blacklisted__c bl = new Blacklisted__c(Candidate__c = candidate2.Id);
            
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
            RecordTypeId = crconsultingId, 
            TR1__Job__c = job1.Id, 
            TR1__Person_Placed__c = con.Id, 
            TR1__Salary__c = 1250200.00, 
            TR1__Job_Percentage__c = 10,
            TR1__Candidate_Percentage__c = 10, 
            TR1__Marketing_Percentage__c = 10, 
            TR1__Other_Percentage__c = 10, 
            TR1__Other2_Percentage__c = 60,
            Maximum_Day_Pay_Rate__c = 1200,
            Maximum_Day_Charge_Rate__c = 500,
            Maximum_Hour_Charge_Rate__c = 100,
            Maximum_Hour_Pay_Rate__c=15, 
            TR1__Job_Credit__c = u1.Id,
            TR1__Start_Date__c = todayDate.addDays(-15), 
            TR1__End_Date__c = todayDate.addDays(10), 
            TR1__Generate_Timesheet__c = true, 
            TR1__Timesheet_Approver__c = candidatelist[0].Id
        ); 
        insert cr1;
            
        TR1__Closing_Report__c cr2 = new TR1__Closing_Report__c(
            RecordTypeId = crconsultingId, 
            TR1__Job__c = job1.Id, 
            TR1__Person_Placed__c = con.Id, 
            TR1__Salary__c = 125000.00, 
            TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, 
            TR1__Marketing_Percentage__c = 20, 
            TR1__Other_Percentage__c = 20, 
            TR1__Other2_Percentage__c = 20,
            Maximum_Day_Pay_Rate__c = 30,
            Maximum_Day_Charge_Rate__c = 100,
            Maximum_Hour_Charge_Rate__c = 10,
            Maximum_Hour_Pay_Rate__c=1.5, 
            TR1__Job_Credit__c = u1.Id,
            TR1__Start_Date__c = todayDate.addDays(-15), 
            TR1__End_Date__c = todayDate.addDays(10), 
            TR1__Generate_Timesheet__c = true, 
            TR1__Timesheet_Approver__c = candidatelist[0].Id
        ); 
        Candidate_Availability__c csd1 = new Candidate_Availability__c(
            Start_Date_Time__c = dateTimeVar.addHours(-3), 
            End_Date__c=todayDate, 
            Start_Date__c=todayDate,
            End_Date_Time__c = dateTimeVar.addHours(3), 
            Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday'
        );
        Candidate_Availability__c[] candidateAvailabilitylist = new Candidate_Availability__c[]{csd1};  

        insert candidateAvailabilitylist;
        
        Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
        Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
        Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(200), Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date_Time__c = dateTimeVar.adddays(200).addHours(9),Status__c ='Open');
        Vacancy_D2D__c[] vacancyAvailabilitylist = new Vacancy_D2D__c[]{jsd1,jsd2,jsd3};  
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
        Test.setCurrentPage(page.TRS_FilterJobs);

        TRS_FilterJobs fCandt = new TRS_FilterJobs(stdController);
            fCandt.openCreateVacancyRecordDialog();
            fCandt.saveCreateVacancyRecord();
            fCandt.cancelVacancyCreation();
            fCandt.vacRecord = new TR1__Job__c ();
       
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
            fCandt.selectedSpecialism =new List<String>{fCandt.specialisms[0].getValue(),'Test2'};
            fCandt.vacRecord.Sub_Sector__c =  'Test';
            fCandt.getSectors();
            fCandt.getSortDirection();
            fCandt.startDate = Date.Today();
            fCandt.grossProfit.TR1__Job__c = job1.id;
            Double stddate1 = 2 + fCandt.offset;
            String strDate = Date.Today().toStartofWeek().day()+'-'+Date.Today().toStartofWeek().Month()+'-'+Date.Today().toStartofWeek().Year();
            String endDate = Date.Today().toStartofWeek().addDays(6).day()+'-'+Date.Today().addDays(6).Month()+'-'+Date.Today().addDays(6).Year();
            String endDatenew = todayDate.addDays(9).day()+'-'+todayDate.addDays(9).Month()+'-'+todayDate.addDays(9).Year();
            System.debug(strDate);
            System.debug(endDate);
            System.debug(endDatenew);
            strDate = strDate.replace('-' , '/');
            endDate = endDate.replace('-' , '/');
            endDatenew = endDatenew.replace('-' , '/');
            
            fCandt.startDateStr = endDatenew;
            fCandt.endDateStr =strDate;
            
            fCandt.getSectors();
           
            fCandt.resetFilters();
            fCandt.whichVacancy='All Vacancies';
        
            //Positive Case
            system.currentPageReference().getParameters().put('Job1', job1.id);
            fCandt.endDate = date.Today().addDays(-9);
            fCandt.startDateStr = strDate;
            fCandt.endDateStr = endDatenew; 
            fCandt.openDialogForClosingReport();
            fCandt.endDateEnterred = endDatenew;
            fCandt.startDateEnterred = endDatenew;//strDate; Nimit
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
            
            // Nimit================================
           
// For updateweek method --
            strDate = endDatenew;
            fCandt.startDateStr = strDate;
            fCandt.updateWeek();
// updateweek method --
// weekdayFunction --
            fCandt.vacRecord.Applicable_Days__c='Monday';
            fCandt.weekdayFunction();
            
            fCandt.vacRecord.Applicable_Days__c= null;
            fCandt.weekdayFunction();
// weekdayFunction --

            fCandt.vacRecord.Applicable_Days__c='Monday';
            fCandt.vacRecord.Selected_Week_Days__c = true;
            fCandt.saveCreateVacancyRecord();

           

            // Nimit=======================


            List<String> strweek= fCandt.weekHeader;
            
            List<SelectOption> so = fCandt.whichVacancyOptions;
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
            fCandt.setsortdirection('ASC');
            fCandt.startDateStr = String.valueOf( system.today());
            fCandt.endDateStr = String.valueOf( system.today().addDays(5));
            fCandt.getWeek();
            fCandt.previouspaginaton();
            fCandt.nextpaginaton();
            fCandt.changeListsize();
            fCandt.getResourceAvailability();
            fCandt.matchCSDJSDslots();
            fCandt.vacRecord.TR1__Account__c = acc.Id;
            fCandt.doSchoolNamePopulate();
            fCandt.saveClosingReport();
            
            List<Closing_Report_Schedule__c> templist= [Select Id from Closing_Report_Schedule__c];
            delete templist;
            List<TR1__Closing_Report__c> templist1= [Select Id from TR1__Closing_Report__c];
            delete templist1;
            
            fCandt.endDateEnterred = endDate;
            fCandt.startDateEnterred = strDate;
            fCandt.closingReport.School_Working_Days__c = 0.00;
            fCandt.closingReport.Annual_Leave_Entitlement__c = null; 
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
            fCandt.openEditVacancyRecordDialog();
            fCandt.saveEditVacancyRecord();
            fCandt.cancelEditVacancyCreation();
            fCandt.deleteEditVacancyCreation();
           
           
        Test.stopTest();
        }
    }
    public static testMethod void test_method002() {

        Test.startTest();

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

        Account acc = new Account(
            Name='UNKNOWN DO NOT DELETE', 
            BillingStreet  ='123', 
            BillingCity ='test city', 
            BillingState ='test county', 
            BillingPostalCode  = '234345', 
            BillingCountry  = 'test Country',
            shippingStreet = '1233',
            shippingCity='Test City',
            ShippingState='Test State',
            shippingPostalCode='564533',
            shippingCountry='Test Country'
        );
        
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
        
        TR1__Job__c job1 = new TR1__Job__c(
            RecordTypeId=consultingid,
            TR1__Account__c=acc.Id,
            Name='Job 2',
            TR1__Contact__c=con.Id,
            TR1__Estimated_Start_Date__c=todayDate,
            TR1__Estimated_End_Date__c=todayDate.addDays(7),
            TR1__Minimum_Pay_Rate__c=100,
            TR1__Maximum_Bill_Rate__c=100, 
            Year_Key_Stage__c ='KS1', 
            SEN_Experience__c='ADHD',
            TR1__State_Area__c = 'UK',
            TR1__Regional_Area__c='Barnet',
            Sector1__c='Junior'
        );
        insert job1;       
            
            
        Contact candidate1 = new Contact(
            LastName = 'Candidate 1', 
            Email='test@test.com', 
            Subject__c ='Art'
        );
        Contact candidate2 = new Contact(
            LastName = 'Candidate 2',
            Email='test@test.com', 
            Subject__c ='Art'
        );
        Contact[] candidatelist = new Contact[]{candidate1,candidate2};  
        insert candidatelist;
            
        Blacklisted__c bl = new Blacklisted__c(Candidate__c = candidate2.Id);
            
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
            RecordTypeId = crconsultingId, 
            TR1__Job__c = job1.Id, 
            TR1__Person_Placed__c = con.Id, 
            TR1__Salary__c = 1250200.00, 
            TR1__Job_Percentage__c = 10,
            TR1__Candidate_Percentage__c = 10, 
            TR1__Marketing_Percentage__c = 10, 
            TR1__Other_Percentage__c = 10, 
            TR1__Other2_Percentage__c = 60,
            Maximum_Day_Pay_Rate__c = 1200,
            Maximum_Day_Charge_Rate__c = 500,
            Maximum_Hour_Charge_Rate__c = 100,
            Maximum_Hour_Pay_Rate__c=15, 
            TR1__Job_Credit__c = u1.Id,
            TR1__Start_Date__c = todayDate.addDays(-15), 
            TR1__End_Date__c = todayDate.addDays(10), 
            TR1__Generate_Timesheet__c = true, 
            TR1__Timesheet_Approver__c = candidatelist[0].Id
        ); 
        insert cr1;
            
        TR1__Closing_Report__c cr2 = new TR1__Closing_Report__c(
            RecordTypeId = crconsultingId, 
            TR1__Job__c = job1.Id, 
            TR1__Person_Placed__c = con.Id, 
            TR1__Salary__c = 125000.00, 
            TR1__Job_Percentage__c = 20,
            TR1__Candidate_Percentage__c = 20, 
            TR1__Marketing_Percentage__c = 20, 
            TR1__Other_Percentage__c = 20, 
            TR1__Other2_Percentage__c = 20,
            Maximum_Day_Pay_Rate__c = 30,
            Maximum_Day_Charge_Rate__c = 100,
            Maximum_Hour_Charge_Rate__c = 10,
            Maximum_Hour_Pay_Rate__c=1.5, 
            TR1__Job_Credit__c = u1.Id,
            TR1__Start_Date__c = todayDate.addDays(-15), 
            TR1__End_Date__c = todayDate.addDays(10), 
            TR1__Generate_Timesheet__c = true, 
            TR1__Timesheet_Approver__c = candidatelist[0].Id
        ); 
        
        Candidate_Availability__c csd1 = new Candidate_Availability__c(
            Start_Date_Time__c = dateTimeVar.addHours(-3), 
            End_Date__c=todayDate, 
            Start_Date__c=todayDate,
            End_Date_Time__c = dateTimeVar.addHours(3), 
            Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday'
        );
        Candidate_Availability__c[] candidateAvailabilitylist = new Candidate_Availability__c[]{csd1};  

        insert candidateAvailabilitylist;
        
        Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
        Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
        Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(200), Start_Date_Time__c = dateTimeVar.adddays(200).addHours(6), End_Date_Time__c = dateTimeVar.adddays(200).addHours(9),Status__c ='Open');
        Vacancy_D2D__c[] vacancyAvailabilitylist = new Vacancy_D2D__c[]{jsd1,jsd2,jsd3};  

        insert vacancyAvailabilitylist;

       
        ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
        Test.setCurrentPage(page.TRS_FilterJobs);

        TRS_FilterJobs fCandt = new TRS_FilterJobs(stdController);
            fCandt.vacRecord = new TR1__Job__c ();
            // Nimit --
            fCandt.vD2D = vacancyAvailabilitylist[0];
            fCandt.deleteEditVacancyCreation();
            // Nimit --
            

            fCandt.getResourceAvailability();
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
            fCandt.selectedSpecialism =new List<String>{fCandt.specialisms[0].getValue(),'Test2'};
            fCandt.vacRecord.Sub_Sector__c =  'Test';
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
            
            fCandt.whichVacancy='All Vacancies';
        
            //Positive Case
            system.currentPageReference().getParameters().put('Job1', job1.id);
            fCandt.endDate = date.Today().addDays(-9);
            fCandt.startDateStr = strDate;
            fCandt.endDateStr =endDatenew;
            
            fCandt.endDateEnterred = strDate;
            fCandt.startDateEnterred = endDatenew;
            fCandt.closingReport.Comparator_Full_Time_Annual_Salary__c = 0.00;
            fCandt.closingReport.TR1__Person_Placed__c=con.id;
            fCandt.closingReport.School_Working_Days__c = 0.00;
            fCandt.closingReport.Annual_Leave_Entitlement__c = '0';
            
            //Negative Case : End Date is null
            fCandt.endDateEnterred = null;

            //Negative Case : Start Date & End Date are null
            fCandt.startDateEnterred = null;

            //Negative Case : Start Date is null
            fCandt.endDateEnterred = endDatenew;

            fCandt.vacRecord.Year_Key_Stage__c='';

            fCandt.vacRecord.Subject2__c='';
            List<String> strweek= fCandt.weekHeader;
            
            List<SelectOption> so = fCandt.whichVacancyOptions;
            fCandt.vacRecord.Shift__c='';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='AM';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='PM';
            fCandt.dummyFunction();
            
            fCandt.vacRecord.Shift__c='Hourly';
            fCandt.dummyFunction();
            fCandt.sortExpression= null;
            fCandt.setsortdirection('ASC');
            fCandt.startDateStr = String.valueOf( system.today());
            fCandt.endDateStr = String.valueOf( system.today().addDays(5));
            fCandt.vacRecord.TR1__Account__c = acc.Id;
            List<Closing_Report_Schedule__c> templist= [Select Id from Closing_Report_Schedule__c];
            delete templist;
            List<TR1__Closing_Report__c> templist1= [Select Id from TR1__Closing_Report__c];
            delete templist1;
            
            fCandt.closingReport = null;
            fCandt.endDateEnterred = strDate;
            fCandt.startDateEnterred = endDatenew;
            system.currentPageReference().getParameters().put('partialsave', 'True');
        Test.stopTest();
        }
    }
    public static testMethod void test_method003() {

        Test.startTest();

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

        Account acc = new Account(
            Name='UNKNOWN DO NOT DELETE', 
            BillingStreet  ='123', 
            BillingCity ='test city', 
            BillingState ='test county', 
            BillingPostalCode  = '234345', 
            BillingCountry  = 'test Country',
            shippingStreet = '1233',
            shippingCity='Test City',
            ShippingState='Test State',
            shippingPostalCode='564533',
            shippingCountry='Test Country'
        );
        
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
        
        TR1__Job__c job1 = new TR1__Job__c(
            RecordTypeId=consultingid,
            TR1__Account__c=acc.Id,
            Name='Job 2',
            TR1__Contact__c=con.Id,
            TR1__Estimated_Start_Date__c=todayDate,
            TR1__Estimated_End_Date__c=todayDate.addDays(7),
            TR1__Minimum_Pay_Rate__c=100,
            TR1__Maximum_Bill_Rate__c=100, 
            Year_Key_Stage__c ='KS1', 
            SEN_Experience__c='ADHD',
            TR1__State_Area__c = 'UK',
            TR1__Regional_Area__c='Barnet',
            Sector1__c='Junior'
        );
        insert job1;       
            
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(con); 
        Test.setCurrentPage(page.TRS_FilterJobs);
        ApexPages.currentPage().getParameters().put('Job1',job1.Id);
        TRS_FilterJobs fCandt = new TRS_FilterJobs(stdController);
        
        TRS_FilterJobs f = new TRS_FilterJobs(stdController);
        f.saveClosingReport();
        f.vacancyStartDate = String.valueOf(System.today());
        f.matchCSDJSDslots();
        f.test();
        
        Test.stopTest();
        }
    }
}