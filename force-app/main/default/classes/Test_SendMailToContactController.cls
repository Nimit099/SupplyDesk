@isTest
public class Test_SendMailToContactController {
    @isTest public static void testData(){
        Contact con = new Contact();
        con.LastName = 'Last';
        con.Email = 'test@test.com';
        insert con;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        SendMailToContactController sm = new SendMailToContactController(sc);        
        
        sm.sendEmail();
    }    
}