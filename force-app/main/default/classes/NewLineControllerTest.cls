@isTest
public class NewLineControllerTest {

    @isTest
    public static void test(){
        NewLineController controller = new NewLineController();
        controller.NewLine = 'Test';
        string newLinestring = controller.NewLine;
        
        controller.Space = 'Test';
        newLinestring = controller.Space;
    }
}