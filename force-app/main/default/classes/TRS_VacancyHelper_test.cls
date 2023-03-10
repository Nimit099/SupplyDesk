@isTest(SeeAlldata=False)
private class TRS_VacancyHelper_test {
    private static testMethod void insertD2DVacancyTest(){

		// For Gravity Form Error
		
		Profile sytemAdminProfileObj = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Account objAccUDND = new Account (
            Name = 'UNKNOWN DO NOT DELETE',
            Account_Code_S__c = '12342'
        );
        insert objAccUDND;

        User katherineUser = new User(
            FirstName='Katherine',
            LastName = 'Gibson',
            Alias = 'tete',
            Email = 'testTimesheet12@gmail.com',
            Username = 'testTimesheet12@gmail.com',
            ProfileId = sytemAdminProfileObj.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert katherineUser;

		// For Gravity Form Error

         Account acc = new Account(Name='CVP',BillingState='TEst');
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        	User u1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                                EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR', ProfileId = p.Id,
                                TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
        system.runAs(u1) { 
        	try{
	            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
	            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Clearance Pending', Compliance_Owner__c=u1.Id,
	            							Qualified_Schools_Candidate__c = 'YES' ,Subject__c='Art' ,Trained_As__c =' Early Years Trained', Sector__c='HMP Prison', Job_Titles__c='Primary Teacher',Assignment_Type__c='Long Term', Pay_Type__c = 'Teacher QTS/NQT Trainee Teacher');
	            insert con;
	            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
	            Date todayDate = system.today();
	            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
	                                                Subject2__c='Art', TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,TR1__Status__c='Open',Start_Time__c='04:00 AM',End_Time__c='10:00 AM',Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
	            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
	            insert joblist;
	            
	            job1.TR1__Estimated_Start_Date__c = job1.TR1__Estimated_Start_Date__c.addDays(5);
	            job1.TR1__Estimated_End_Date__c = job1.TR1__Estimated_End_Date__c.addDays(5);
	            job1.Start_Time__c='05:00 AM';
	            job1.End_Time__c='01:00 PM';
	            job1.Applicable_Days__c='Monday;Thursday;Friday;Saturday;Sunday';
	            TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY=false;
	            update job1; 
	            
	            Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
	            Contact[] candidatelist = new Contact[]{candidate1};  
	            insert candidatelist;
	            
	             
	            
	            DateTime dateTimeVar = system.today();
	            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
	            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
	            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
	            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
	            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id , Maximum_Day_Pay_Rate__c = 20, Maximum_Day_Charge_Rate__c = 50, Maximum_Hour_Charge_Rate__c = 18,
                                                                                    Maximum_Hour_Pay_Rate__c = 13); 
	            // insert cr1;
	
	            // Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
	            // insert csd1;
	            // Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
	            // insert jsd1;
	            //  Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
	            // insert crs1;
	            // job1.TR1__Status__c='Cancelled';
	            // update job1;
	            
	       }catch(DMLexception e ){
	            
				System.debug('Exception-->'+e);
            	System.debug('Exception-->'+e.getCause());
            	System.debug('Exception-->'+e.getLineNumber());

	            Boolean expectedExceptionThrown =  e.getMessage().contains('Candidate Availability cannot be deleted as there exist booking ') ? true : false;
	            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Overlapping Candidate Availability cannot be created.') ? true : false;
	            if(expectedExceptionThrown)
	                System.AssertEquals(expectedExceptionThrown, true);
	            else
	                System.AssertEquals(expectedExceptionThrown1, true);
	            
	        }
        }
    }
     private static testMethod void vacancyD2DTest(){

		// For Gravity Form Error
		
		Profile sytemAdminProfileObj = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Account objAccUDND = new Account (
            Name = 'UNKNOWN DO NOT DELETE',
            Account_Code_S__c = '12342'
        );
        insert objAccUDND;

        User katherineUser = new User(
            FirstName='Katherine',
            LastName = 'Gibson',
            Alias = 'tete',
            Email = 'testTimesheet12@gmail.com',
            Username = 'testTimesheet12@gmail.com',
            ProfileId = sytemAdminProfileObj.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert katherineUser;

		// For Gravity Form Error



     	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
    	User u1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                            EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                            LocaleSidKey='fr_FR', ProfileId = p.Id,
                            TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
        system.runAs(u1) { 
        	try{
	            Account acc = new Account(Name='CVP',BillingState='TEst');
	            insert acc;
	            Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
	            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,  Compliance_Status__c = 'Clearance Pending', Compliance_Owner__c=u1.Id,
	            							Qualified_Schools_Candidate__c = 'YES', Subject__c='Art', Trained_As__c =' Early Years Trained', Sector__c='HMP Prison', Job_Titles__c='Primary Teacher',Assignment_Type__c='Long Term', Pay_Type__c = 'Teacher QTS/NQT Trainee Teacher');
	            insert con;
	            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
	            Date todayDate = system.today();
	            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id,TR1__Estimated_Start_Date__c=todayDate,TR1__Estimated_End_Date__c=todayDate.addDays(7),
	                                              Subject2__c='Art', TR1__Minimum_Pay_Rate__c=100,TR1__Maximum_Bill_Rate__c=100,TR1__Status__c='Open',Start_Time__c='04:00 AM',End_Time__c='10:00 AM',Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
	            TR1__Job__c[] joblist = new TR1__Job__c[]{job1};        
	            insert joblist;
	            
	            job1.TR1__Estimated_Start_Date__c = job1.TR1__Estimated_Start_Date__c.addDays(5);
	            job1.TR1__Estimated_End_Date__c = job1.TR1__Estimated_End_Date__c.addDays(5);
	            job1.Start_Time__c='05:00 AM';
	            job1.End_Time__c='01:00 PM';
	            job1.Applicable_Days__c='Monday;Thursday;Friday;Saturday;Sunday';
	            TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY=false;
	            update job1; 
	            
	            Contact candidate1 = new Contact(LastName = 'Candidate 1'); 
	            Contact[] candidatelist = new Contact[]{candidate1};  
	            insert candidatelist;
	            
	            
	            DateTime dateTimeVar = system.today();
	            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
	            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(RecordTypeId = crconsultingId, TR1__Job__c = job1.Id, TR1__Person_Placed__c = con.Id, TR1__Salary__c = 125000.00, TR1__Job_Percentage__c = 20,
	            TR1__Candidate_Percentage__c = 20, TR1__Marketing_Percentage__c = 20, TR1__Other_Percentage__c = 20, TR1__Other2_Percentage__c = 20,
	            TR1__Job_Credit__c = u1.Id, TR1__Candidate_Credit__c = u1.Id, TR1__Marketing_Credit__c = u1.Id, TR1__Other_Credit__c = u1.Id, TR1__Other2_Credit__c = u1.Id,Timesheet_Frequency__c = 'Weekly',
	            TR1__Start_Date__c = todayDate.addDays(-15), TR1__End_Date__c = todayDate.addDays(10), TR1__Generate_Timesheet__c = true, TR1__Timesheet_Approver__c = candidatelist[0].Id, Maximum_Day_Pay_Rate__c = 20, Maximum_Day_Charge_Rate__c = 50, Maximum_Hour_Charge_Rate__c = 13,
                                                                                    Maximum_Hour_Pay_Rate__c = 18); 
	            // insert cr1;
	
	            // Candidate_Availability__c csd1 = new Candidate_Availability__c(Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date__c=todayDate, Start_Date__c=todayDate,End_Date_Time__c = dateTimeVar.addHours(6), Candidate__c = con.id,Applicable_Days__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday');
	            // insert csd1;
	            // Vacancy_D2D__c jsd1 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(-3), End_Date_Time__c = dateTimeVar.addHours(3),Status__c ='Open');
	            // insert jsd1;
	            //  Closing_Report_Schedule__c crs1 = new Closing_Report_Schedule__c(Candidate_Availability__c = csd1.id, Schedule_Date__c=todayDate,Vacancy_Schedule__c = jsd1.id, Closing_Report__c = cr1.id, Status__c = 'Booked');
	            // insert crs1;
	            
	            // Vacancy_D2D__c jsd3 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(4), End_Date_Time__c = dateTimeVar.addHours(5),Status__c ='Open');
	            // insert jsd3;
	            // Vacancy_D2D__c jsd4 = new Vacancy_D2D__c(Vacancy__c = job1.id,Vacancy_Date__c=todayDate, Start_Date_Time__c = dateTimeVar.addHours(6), End_Date_Time__c = dateTimeVar.addHours(8),Status__c ='Open');
	            // insert jsd4;
	            
	        }catch(DMLexception e ){
				
				System.debug('Exception-->'+e);
            	System.debug('Exception-->'+e.getCause());
            	System.debug('Exception-->'+e.getLineNumber());

	            Boolean expectedExceptionThrown =  e.getMessage().contains('Vacancy Schedule cannot be deleted as there exist booking') ? true : false;
	            Boolean expectedExceptionThrown1 =  e.getMessage().contains('Overlapping Vacancy Schedule cannot be created.') ? true : false;
	            if(expectedExceptionThrown)
	                System.AssertEquals(expectedExceptionThrown, true);
	            else
	                System.AssertEquals(expectedExceptionThrown1, true);
	            
	        }
        }     
    }
    
     public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or .. 
    }
        
}