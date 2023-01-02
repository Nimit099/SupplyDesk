// public with sharing class TRS_VacancyHelperTestV2 {
//     public TRS_VacancyHelperTestV2() {

//     }
// }

@isTest(SeeAlldata=False)
private class TRS_VacancyHelperTestV2 {
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