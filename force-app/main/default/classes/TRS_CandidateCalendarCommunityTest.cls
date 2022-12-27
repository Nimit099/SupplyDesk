@isTest(SeeAlldata=False)
private class TRS_CandidateCalendarCommunityTest {
    private static testMethod void Test1(){
      //  try{           
      		User u = RC_UtilityClass.getStandartUser('test'); 
        	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
            User u1 = [SELECT Id FROM User WHERE ProfileId = :p.Id limit 1];
        Account acc;
        Contact con;
        TR1__Job__c job1;
        Contact[] candidatelist;
        System.runAs(u) {
           
        	acc = new Account(Name='CVP',BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                         shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
            RC_AccessController.insertRecord(acc);
            con = new Contact(LastName='CVP Contact',Email='test@test1.com',AccountId = acc.Id, Compliance_Status__c = 'Cleared', Compliance_Owner__c=u1.Id,
            							Subject__c='Art', Trained_As__c =' Early Years Trained', Sector__c='HMP Prison',TR1__Candidate_Status__c='Assigned',Qualified_Schools_Candidate__c='Yes',Job_Titles__c='Acting Assistant Principal',Assignment_Type__c='Long Term');
            RC_AccessController.insertRecord(con);
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,Subject__c = 'Art');
            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
            RC_AccessController.insertRecords(joblist);
            Contact candidate1 = new Contact(LastName = 'Candidate 1', email='test@test.com');
            candidatelist = new Contact[]{candidate1};  
            RC_AccessController.insertRecords(candidatelist);
           
        }
           
            
            Date todayDate = Date.newInstance(2090,5,7);
            DateTime dateTimeVar = datetime.newInstance(2090,5,7, 10, 30, 0);
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 25,
                                                                    TR1__Candidate_Percentage__c = 25, TR1__Marketing_Percentage__c = 25, TR1__Other_Percentage__c = 15, TR1__Other2_Percentage__c = 10,
                                                                    TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,
                                                                    TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id, TR1__Job_Credit__c = u.Id); 
            RC_AccessController.insertRecord(cr1);
            
            Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(3), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
            RC_AccessController.insertRecord(csd1);
            Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
            RC_AccessController.insertRecord(jsd1);
            Vacancy_D2D__c jsd2 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(9),Status__c ='Open');
            RC_AccessController.insertRecord(jsd2);
            Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
            RC_AccessController.insertRecord(crs1);
            PageReference pref=page.TRS_CandidateCalendarCommunity;
            pref.getParameters().put('contactid', con.id);
            String strDate = String.valueOf(Date.newInstance(5, 7,2090));
            strDate = strDate.replace('-' , '/');
            system.debug('Dates format is ->'+strDate);
            pref.getParameters().put('dateStr', strDate);
            Test.setCurrentPage(pref);
            TRS_CandidateCalendarCommunity candid = new TRS_CandidateCalendarCommunity();
            candid.selectedDate = Date.newInstance(5, 7,2090);
            candid.getSelectedDateStr();
            candid.getSelectedDateStartOfWeekStr();
            candid.getSelectedDateEndOfWeekStr();
            candid.isWeekSelected = True;
            candid.showCreateAvailRecord = True;
            candid.tempCandidateAvailability.Type__c ='Available';
            candid.tempVacancy.Start_Time__c = '04:00 PM';
            candid.tempVacancy.End_Time__c = '07:00 PM';
            candid.tempVacancy.TR1__Estimated_Start_Date__c = Date.today().addDays(2);
            candid.tempVacancy.TR1__Estimated_End_Date__c = Date.today().addDays(3);
            candid.selectedDateStartOfWeek = Date.newInstance(5, 7,2090);
            candid.selectedDateEndOfWeek = Date.newInstance(5, 8,2090);
            TRS_CandidateCalendar.timeslotWrapper timewrap = new TRS_CandidateCalendar.timeslotWrapper();
            candid.tsw.isMon  =True ; 
            candid.tsw.isTue  =True ; 
            candid.tsw.isWed  =True; 
            candid.tsw.isThu  =True; 
            candid.tsw.isFri  =True; 
            candid.tsw.isSat  =True; 
            candid.tsw.isSun  =True;
            candid.saveCreateAvailRecord();
            candid.tempVacancy.Start_Time__c = '07:00 PM';
            candid.tempVacancy.End_Time__c = '';
            candid.saveCreateAvailRecord();
            candid.tempVacancy.Start_Time__c = '';
            candid.tempVacancy.End_Time__c = '';
            candid.saveCreateAvailRecord();
            candid.tempVacancy.Start_Time__c = '';
            candid.tempVacancy.End_Time__c = '07:00 PM';
            candid.saveCreateAvailRecord();
            candid.isWeekSelected = false;
            candid.tempVacancy.Start_Time__c = '06:00 PM';
            candid.tempVacancy.End_Time__c = '06:00 PM';
            candid.saveCreateAvailRecord();
            candid.tempVacancy.Start_Time__c = '07:00 PM';
            candid.tempVacancy.End_Time__c = '06:00 PM';
            candid.saveCreateAvailRecord();
            candid.tempCandidateAvailability.Type__c ='Available';
            candid.tempVacancy.Start_Time__c = '06:00 PM';
            candid.tempVacancy.End_Time__c = '07:00 PM';
            candid.saveCreateAvailRecord();
            candid.calenderSchedule();
            candid.eventId = crs1.Id;
            candid.deleteCalEvent();
            candid.eventId = csd1.Id;
            candid.deleteCalEvent();
            candid.openCreateAvailRecordDialog();
     /**   }catch (exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please populate Start Time') ? true : false;
            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Please populate End Time.') ? true : false;
            Boolean expectedExceptionThrown2 =  e.getMessage().contains('Start Time & End Time cannot be same.') ? true : false;
            Boolean expectedExceptionThrown3 =  e.getMessage().contains('Shift cannot be empty.') ? true : false;
            Boolean expectedExceptionThrown4 =  e.getMessage().contains('Start Date & End Date both should be populated.') ? true : false;
            Boolean expectedExceptionThrown5 =  e.getMessage().contains('Start Date should be before End Date.') ? true : false;
            Boolean expectedExceptionThrown6 =  e.getMessage().contains('Start Time should be less than  End Time.') ? true : false;
            Boolean expectedExceptionThrown7 =  e.getMessage().contains('Please select start date Today or greater than Today.') ? true : false;
        }**/
    }
    
    
}