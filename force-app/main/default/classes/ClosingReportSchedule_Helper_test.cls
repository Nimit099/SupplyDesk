@isTest(SeeAlldata=False)
public class ClosingReportSchedule_Helper_test {
    private static testMethod void ClosingReportSchedule_Helpertest(){
        try{
            test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
            User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];
            system.runAs(u1){
                Account acc = new Account(Name='CVP',BillingState='TEst');
                insert acc;
                Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,Compliance_Status__c = 'Cleared',Subject__c ='Art',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Prospect',Year_Key_Stage__c='KS1',Payroll_Number__c='32323',Compliance_Owner__c=Userinfo.getUserId(),Barred_List_AQ_Hidden__c ='Active',Perm_Qualification_AQ_Hidden__c ='Active',ID_AQ_Hidden__c='Active',References_AQ_Hidden__c ='Active',Right_to_Work_AQ_Hidden__c ='Active',OwnerId=u1.Id);
                insert con;
                Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                Date todayDate = system.today();
                TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                                   TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS1');
                TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
                    insert joblist;
                Contact candidate1 = new Contact(LastName = 'Candidate 1', Email='test25434w56@test.com',OwnerId=u1.Id);
                Contact[] candidatelist = new Contact[]{candidate1};  
                    insert candidatelist;
                
                
                DateTime dateTimeVar = system.today();
                Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
                                                                        TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
                                                                        TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',Maximum_Day_Charge_Rate__c =23,Maximum_Day_Pay_Rate__c =23,
                                                                        TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
                insert cr1;			         
                TR1__Timesheet__c ts = new TR1__Timesheet__c();
                //ts.CurrencyIsoCode = cr.CurrencyIsoCode;
                ts.TR1__Status__c = 'Unsubmitted';
                ts.TR1__Closing_Report__c = cr1.Id;
                ts.TR1__Consultant__c = cr1.TR1__Person_Placed__c;
                ts.TR1__Job_Order__c = cr1.TR1__Job__c;
                ts.TR1__Approver__c = cr1.TR1__Timesheet_Approver__c;
                ts.TR1__Timesheet_Second_Approver__c = cr1.TR1__Timesheet_Second_Approver__c;
                ts.TR1__Client__c = cr1.TR1__Account__c;
                ts.TR1__Week_Ending__c = todayDate.addDays(6);
                ts.TR1__Pay_Week_Ending__c = todayDate.addDays(6);
                Insert ts;
                test.stopTest();   
                Integer numberDaysDue = todayDate.daysBetween(todayDate.addDays(6));
                List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>();
                for (Integer i = 0 ; i <= numberDaysDue; i++) {
                    TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.Id, TR1__Date__c = todayDate.addDays(i), TR1__Day__c = dayOfDate(todayDate.addDays(i)));
                    timesheetdetails.add(td);
                }
                insert timesheetdetails;
                Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
                insert csd1;
                Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open',Shift__c='Hourly');
                insert jsd1;
                Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
                insert csd2;
                Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(7), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open',Shift__c='Daily');
                insert jsd2;
                Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(7).addHours(6), End_Date__c=todayDate.addDays(7), Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.adddays(7).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
                insert csd3;
                Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(7), Start_Date_Time__c = dateTimeVar.adddays(7).addHours(7), End_Date_Time__c = dateTimeVar.adddays(7).addHours(8),Status__c ='Open',Shift__c='Half Day');
                insert jsd3;
                Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
                insert crs1;
                crs1.LastTimeTriggerExecuted__c = 'Started';
                update crs1;
                crs1.LastTimeTriggerExecuted__c = 'Ended';
                update crs1;
                
                delete crs1;
                Closing_Report_Schedule__c crs3 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
                insert crs3;
                
                Closing_Report_Schedule__c crs2 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
                insert crs2;
                
                Closing_Report_Schedule__c crs5 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd3.id, Schedule_Date__c=jsd3.Vacancy_Date__c,Vacancy_Schedule__c = jsd3.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
                insert crs5;
                Closing_Report_Schedule__c crs4 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd2.id, Schedule_Date__c=jsd2.Vacancy_Date__c,Vacancy_Schedule__c = jsd2.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
                insert crs4;
                Candidate_Availability__c csd4 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(7).addHours(6), End_Date__c=todayDate.addDays(7), Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.adddays(7).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
                insert csd4;
                
                Delete csd2;
            }
            
        }catch(DMLexception e ){
            // system.debug('Following exception occured'+ex.getmessage() );
            // system.assertEquals('System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You can not add same closing report schedule. There is already a similar Closing Report schedule.', ex.getmessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('You can not add same closing report schedule. There is already a similar Closing Report schedule.') ? true : false;
            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Overlapping Candidate Availability cannot be created.') ? true : false;
            if(expectedExceptionThrown)
                System.AssertEquals(expectedExceptionThrown, true);
            else
                System.AssertEquals(expectedExceptionThrown, false);
            // Boolean expectedExceptionThrown1 =  e.getMessage().contains('Candidate Availability cannot be deleted as there exist booking ') ? true : false;
            // System.AssertEquals(expectedExceptionThrown1, true);
            
        }   
        
    }
    private static testMethod void closingreportTriggerTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = [SELECT Id FROM User WHERE Name != 'Talent Rover Administrator' limit 1]; 
        system.runAs(u1){
            Account acc = new Account(Name='CVP',BillingState='TEst');
            insert acc;
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con = new Contact(OwnerId=u1.Id,LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Cleared',Subject__c ='Art',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Prospect',Year_Key_Stage__c='KS1',Payroll_Number__c='32323',Compliance_Owner__c=Userinfo.getUserId(),Barred_List_AQ_Hidden__c ='Active',Perm_Qualification_AQ_Hidden__c ='Active',ID_AQ_Hidden__c='Active',References_AQ_Hidden__c ='Active',Right_to_Work_AQ_Hidden__c ='Active',Qualified_Schools_Candidate__c='YES');
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                               TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS1');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
                insert joblist;
            Contact candidate1 = new Contact(LastName = 'Candidate 1',Email='test4534535@test.com',OwnerId=u1.Id);
            Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
            
            DateTime dateTimeVar = system.today();
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd1;
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open',Shift__c='Hourly');
            insert jsd1;
            Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(8), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            //insert csd2;
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(7), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open',Shift__c='Daily');
            insert jsd2;
            Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(17).addHours(6), End_Date__c=todayDate.addDays(7), Start_Date__c=todayDate.addDays(12),End_Date_Time__c = dateTimeVar.adddays(7).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd3;
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(12), Start_Date_Time__c = dateTimeVar.adddays(7).addHours(7), End_Date_Time__c = dateTimeVar.adddays(7).addHours(8),Status__c ='Open',Shift__c='Half Day');
            insert jsd3;
            
            test.startTest();
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
                                                                    TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
                                                                    TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',Maximum_Day_Charge_Rate__c =23,Maximum_Day_Pay_Rate__c =23,Maximum_Half_Day_Charge_Rate__c =23,Maximum_Half_Day_Pay_Rate__c =23,Maximum_Hour_Charge_Rate__c=23,Maximum_Hour_Pay_Rate__c =23,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            ClosingReportTriggerHelper.FromJobboard=false;
            insert cr1;
            
            Test.stopTest();
        }
    } 
    public static testMethod void TRS_CreateCRSctrlTest(){      
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = [SELECT Id FROM User WHERE Name != 'Talent Rover Administrator' limit 1];
        system.runAs(u1){
            Account acc = new Account(Name='CVP',BillingState='TEst');
            insert acc;
            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con = new Contact(OwnerId=u1.Id,LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Cleared',Subject__c ='Art',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Prospect',Year_Key_Stage__c='KS1',Payroll_Number__c='32323',Compliance_Owner__c=Userinfo.getUserId(),Barred_List_AQ_Hidden__c ='Active',Perm_Qualification_AQ_Hidden__c ='Active',ID_AQ_Hidden__c='Active',References_AQ_Hidden__c ='Active',Right_to_Work_AQ_Hidden__c ='Active',Qualified_Schools_Candidate__c='YES');
            insert con;
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Date todayDate = system.today();
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                               TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS1');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
                insert joblist;
            Contact candidate1 = new Contact(LastName = 'Candidate 1', Email='test436346345@test.com',OwnerId=u1.Id);
            Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
            
            DateTime dateTimeVar = system.today();
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd1;
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open',Shift__c='Hourly');
            insert jsd1;
            Candidate_Availability__c csd2 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(7), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            //insert csd2;
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(7), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open',Shift__c='Daily');
            insert jsd2;
            Candidate_Availability__c csd3 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(17).addHours(6), End_Date__c=todayDate.addDays(7), Start_Date__c=todayDate.addDays(12),End_Date_Time__c = dateTimeVar.adddays(7).addHours(9), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd3;
            Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate.adddays(7), Start_Date_Time__c = dateTimeVar.adddays(7).addHours(7), End_Date_Time__c = dateTimeVar.adddays(7).addHours(8),Status__c ='Open',Shift__c='Half Day');
            insert jsd3;
            
            
            TR1__Job__c job2 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
                                               TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,Subject2__c='Accountancy',Year_Key_Stage__c='KS1');
            TR1__Job__c[] joblist1 = new TR1__Job__c[]{job2};        
                insert joblist1;
            Contact candidate2 = new Contact(LastName = 'Candidate 1', Email='test36346@test.com',OwnerId=u1.Id);
            Contact[] candidatelis1t = new Contact[]{candidate2};  
                insert candidatelis1t;
            
            Candidate_Availability__c csd11 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = candidate2.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd11; 
            Vacancy_D2D__c jsd11 = new Vacancy_D2D__c(Vacancy__c = job2.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open',Shift__c='Hourly');
            insert jsd11;
            Candidate_Availability__c csd21 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(6), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(9), Candidate__c = candidate2.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd21;
            Vacancy_D2D__c jsd21 = new Vacancy_D2D__c(Vacancy__c = job2.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(7), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open',Shift__c='Daily');
            insert jsd21;
            Candidate_Availability__c csd31 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.adddays(7).addHours(6), End_Date__c=todayDate.addDays(7), Start_Date__c=todayDate.addDays(2),End_Date_Time__c = dateTimeVar.adddays(7).addHours(9), Candidate__c = candidate2.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            insert csd31;
            Vacancy_D2D__c jsd31 = new Vacancy_D2D__c(Vacancy__c = job2.id,Vacancy_Date__c=todayDate.adddays(7), Start_Date_Time__c = dateTimeVar.adddays(7).addHours(7), End_Date_Time__c = dateTimeVar.adddays(7).addHours(8),Status__c ='Open',Shift__c='Half Day');
            insert jsd31;                    
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
                                                                    TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
                                                                    TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',Maximum_Day_Charge_Rate__c =23,Maximum_Day_Pay_Rate__c =23,Maximum_Half_Day_Charge_Rate__c =23,Maximum_Half_Day_Pay_Rate__c =23,Maximum_Hour_Charge_Rate__c=23,Maximum_Hour_Pay_Rate__c =23,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id); 
            ClosingReportTriggerHelper.FromJobboard=True;
            insert cr1;
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(job1); 
            PageReference pref=page.TRS_CreateCRS; 
            pref.getParameters().put('id', job1.id);
            pref.getParameters().put('contact1', con.id);
            TRS_CreateCRSctrl fCandt = new TRS_CreateCRSctrl(stdController);
            test.startTest();
            
            fCandt.saveClosingReportSch();
            fCandt.objCRTemp.add(cr1);
            fCandt.canAvail.add(csd3);
            fCandt.vacAvail.add(jsd3);
            fCandt.objCR.TR1__Person_Placed__c = con.Id;
            fCandt.objCR = cr1;
            fCandt.objCRS.Schedule_Date__c=todayDate;
            fCandt.objCR.Maximum_Day_Pay_Rate__c=20;
            fCandt.objCR.Maximum_Day_Charge_Rate__c=20;
            fCandt.objCR.Maximum_Half_Day_Pay_Rate__c=20;
            fCandt.objCR.Maximum_Half_Day_Charge_Rate__c=20;
            fCandt.objCR.Maximum_Hour_Pay_Rate__c=20;
            fCandt.objCR.Maximum_Hour_Charge_Rate__c=20;
            fCandt.saveClosingReportSch();
            
            delete [select Id,name from Closing_Report_Schedule__c ];
            //delete cr1;
            fCandt.saveClosingReportSch();
            fCandt.FetchCandidateId();
            fCandt.RedirectTocalendar();
            fCandt.Cancel();
            test.stopTest();
        }
        
    } 
    
    public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or .. 
    }
    
}