@isTest
public class ConfirmationLetterPDFControllerTest {
    
    @istest
    public static void main(){
        
          
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
        
        User ownerUsr = new User(
            LastName = 'test',
            FirstName='Timesheet',
            Alias = 'tete',
            Email = 'testTimesheet@gmail.com',
            Username = 'testTimesheet@gmail.com',
            ProfileId = sytemAdminProfileObj.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert ownerUsr;


        System.runAs(katherineUser){
        Test.startTest();

        Account acc = new Account(Name='CVP',BillingState='TEst',Account_Code_S__c='32323');
        insert acc;

        Contact con = new Contact(Pay_Type__c = 'FE Qualified', LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Cleared', Compliance_Owner__c=ownerUsr.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Assignment_Type__c='', Qualified_Schools_Candidate__c = 'YES');
        insert con;
        
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        TR1__Job__c job = new TR1__Job__c(TR1__Account__c = acc.id,
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
                                          TR1__Estimated_Start_Date__c = System.today().addDays(-30),
                                          TR1__Estimated_End_Date__c = System.today().addDays(90), 
                                          RecordTypeId = consultingid,
                                          Friday_s_Shift__c = 'Full Day',
                                          Monday_s_Shift__c = 'Full Day',
                                          Saturday_s_Shift__c = 'Full Day',
                                          Sunday_s_Shift__c = 'Full Day',
                                          Thursday_s_Shift__c = 'Full Day',
                                          Tuesday_s_Shift__c = 'Full Day',
                                          Subject2__c='Accountancy',
                                          Year_Key_Stage__c='KS2',
                                          Wednesday_s_Shift__c = 'Full Day');
        insert job;
        
        
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c(TR1__Account__c = acc.id, Maximum_Day_Pay_Rate__c = 40 , Maximum_Half_Day_Pay_Rate__c = 20, Maximum_Hour_Charge_Rate__c = 10, TR1__Job__c = job.id ,TR1__Person_Placed__c = con.id , RecordTypeId = Utility.CONSULTING_RTID ,TR1__Start_Date__c = System.today() , TR1__End_Date__c = System.today().addDays(6),TR1__Candidate_Percentage__c=100,
        Trial_Day__c = TRUE,
        TR1__Job_Credit__c = katherineUser.Id);
        insert cr;
        
        pageReference pageRef = page.confirmationLetterPDF_V2;
        pageRef.getParameters().put('Id',cr.Id);
        
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cr);
        ConfirmationLetterPDFController controller = new ConfirmationLetterPDFController(sc);
        
        Test.stopTest();
        }  
    }
    
    
}