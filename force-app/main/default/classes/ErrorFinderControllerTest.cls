@isTest
public class ErrorFinderControllerTest {

    @isTest
    public static void test(){
        
        ErrorFinderController efc = new ErrorFinderController();
        efc.failingPageResponse = 'Test Failing page response';
        efc.fetchFailingPage();
        
    }
}