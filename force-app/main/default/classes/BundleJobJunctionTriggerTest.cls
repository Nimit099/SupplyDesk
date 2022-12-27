@isTest(seeAlldata= false)
public class BundleJobJunctionTriggerTest {
    
    @isTest
    public static void test(){
        
        Account testAccount = new Account(Name = 'Test Account34687');
        insert testAccount;           
        
        TR1__Job__c testJob = RC_UtilityClass.insertJob();
        testJob.TR1__Account__c  = testAccount.Id;
        update testJob;                
        
        Bundle__c testBundle = new Bundle__c(Name = 'Test Bundle4521734',Account__c =testAccount.Id, Type__c  = 'Teacher',Total_Allocated_Days__c = 1,Invoice_Amount__c =60000);
        insert testBundle;                
        
        Bundle_Job_Junction__c testBundleJobJunction = new Bundle_Job_Junction__c(Bundle__c =testBundle.Id, Job__c = testJob.Id) ;
        insert testBundleJobJunction;
        
        testBundleJobJunction.Active__c  = true;
        update testBundleJobJunction;
        
    }
    
}