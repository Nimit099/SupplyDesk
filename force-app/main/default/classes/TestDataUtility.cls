/**
 * This class willl provide data for test classes
 * This class is used by following classes
 * 1. TestTimeSheets_v1
 * 
**/


@isTest
public class TestDataUtility {
    
    public static Id CONSULTING_RECORDTYPE_JOB = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    public static Id CONSULTING_RECORDTYPE_CLOSINGREPORT = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    
    public static User createUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@suppludesk.com',
                                EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR', ProfileId = sysAdminProfile.Id,
                                TimeZoneSidKey='Europe/London', UserName='testUser'+String.valueOf(Math.random())+'@supplydesk.com',FirstName='Test');
        if(isInsert){
            insert testUser;
        }
        return testUser;
    }
    
    public static Account createAccount(Boolean isInsert){
        Account testAccount = new Account(Name='Test Account', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345',
                                        BillingCountry  = 'test Country', ShippingStreet = '1233', ShippingCity='Test City', ShippingState='Test State', ShippingPostalCode='564533',
                                        ShippingCountry='Test Country');
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
  
    public static Contact createContact(Id accountId,Boolean isInsert){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppludesk.com');
        if(isInsert){
            insert testContact;
        }
        return testContact;
    }
    
    public static TR1__Job__c createJob(Id recordTypeId,Id accountId,Boolean isInsert){
        TR1__Job__c testJob = new TR1__Job__c(RecordTypeId = recordTypeId, TR1__Account__c = accountId, Name = 'Test Job',TR1__Status__c='Open', Subject__c ='Art', Year_Key_Stage__c ='KS1');
        if(isInsert){
            insert testJob;
        }
        return testJob;
    }
    
    public static TR1__Closing_Report__c createClosingReport(Id recordTypeId,Id accountId,Id jobId,Id personPlacedId,Id jobCreditId,Boolean isInsert){
        
        TR1__Closing_Report__c testClosingReport = new TR1__Closing_Report__c(
                                                                                    TR1__Account__c= accountId,
                                                                                    RecordTypeId = recordTypeId,
                                                                                    TR1__Job__c=jobId,
                                                                                    TR1__Person_Placed__c=personPlacedId,
                                                                                    TR1__Job_Percentage__c = 100,
                                                                                    TR1__Job_Credit__c = jobCreditId,
                                                                                    TR1__Start_Date__c = Date.today().addDays(-15),
                                                                                    TR1__End_Date__c = Date.today().addDays(30),
                                                                                    TR1__Generate_Timesheet__c = true,
                                                                                    Maximum_Day_Pay_Rate__c = 23,
                                                                                    Maximum_Day_Charge_Rate__c = 23,
                                                                                    Maximum_Hour_Charge_Rate__c = 23,
                                                                                    Maximum_Hour_Pay_Rate__c = 23
                                                                                );
        if(isInsert){
            insert testClosingReport;
        }
        return testClosingReport;
    }
    
    public static TR1__Qualification__c createQualification(String qualificationName,Boolean isInsert){
        TR1__Qualification__c testQualification = new TR1__Qualification__c(Name = qualificationName);
        if(isInsert){
            insert testQualification;
        }
        return testQualification;
    }
    
    public static TR1__Associated_Qualification__c createAssociatedQualification(Id qualificationId,Id contactId,String status, Boolean isInsert){
        TR1__Associated_Qualification__c testAssociatedQualification = new TR1__Associated_Qualification__c	(TR1__Qualification__c = qualificationId,TR1__Status__c = status,TR1__Contact__c = contactId);
        if(isInsert){
            insert testAssociatedQualification;
        }
        return testAssociatedQualification;
    }
}