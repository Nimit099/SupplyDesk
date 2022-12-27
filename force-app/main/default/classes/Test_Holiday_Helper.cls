@isTest(SeeAllData = false)
public with sharing class Test_Holiday_Helper {

    static testmethod void test_method_one() {
        
        // Create Test Data
        
        List<Account> acc = TestUtility.accList;
        List<Contact> conList = TestUtility.con;

        TR1__Job__c job =  new TR1__Job__c(TR1__Account__c = acc[0].id,
                                        TR1__Status__c = 'Open',
                                        TR1__Client_Description__c ='test',
                                        TR1__Education_Requirements__c='aaa',
                                        TR1__Experience_Requirements__c='bbb',
                                        TR1__Responsibilities__c='ccc',
                                        TR1__State_Area__c='test',
                                        TR1__Regional_Area__c='test',
                                        Booking_Type__c='test',
                                        TR1__Division__c='test',
                                        TR1__Primary_Background__c='test',
                                        TR1__Estimated_Start_Date__c = System.today().addDays(-10),
                                        TR1__Estimated_End_Date__c = System.today().addDays(10),  
                                        Applicable_Days__c = 'Monday' , RecordtypeId = TRS_vacancyhelper.CONSULTING_RTID,
                                        Friday_s_Shift__c = 'Full Day',
                                        Monday_s_Shift__c = 'Full Day',
                                        Saturday_s_Shift__c = 'Full Day',
                                        Sunday_s_Shift__c = 'Full Day',
                                        Thursday_s_Shift__c = 'Full Day',
                                        Tuesday_s_Shift__c = 'Full Day',
                                        Wednesday_s_Shift__c = 'Full Day');
        insert job;
        
        Vacancy_D2D__c testVacD2D = new Vacancy_D2D__c(Vacancy__c = job.Id, Vacancy_Date__c  = date.today() );
                     
        Holiday__c holiday = new Holiday__c(Account__c = acc[0].id , Start_Date__c = System.today() , End_Date__c = System.today().addDays(1));
        Holiday__c holid = new Holiday__c(Vacancy__c = job.id , Start_Date__c = System.today().addDays(5) , End_Date__c = System.today().addDays(6));
        // Start Test
        Test.startTest();        
        insert holiday;
        
        insert testVacD2d;               
        holiday.Start_Date__c = System.today().addDays(2);
        holiday.End_Date__c = System.today().addDays(2);        
        update holiday;
        
        
        insert holid; 
        
        Holiday__c holidayrec = [Select id from Holiday__c where id = :holiday.id];
        delete holidayrec;
        
         
        // Stop Test
        Test.stopTest();                                
                
    }
}