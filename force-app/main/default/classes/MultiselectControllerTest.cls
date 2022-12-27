@isTest
public class MultiselectControllerTest {

    @isTest
    public static void test(){
        
        MultiselectController controller = new MultiselectController();
    	
        List<selectOption> leftSOlist  = new List<selectOption>();        
        leftSOList.add(new selectOption('Test','UTF-8'));
        controller.leftOption = leftSOlist;
        leftSOlist = controller.leftOption;
        
        List<selectOption> rightSOlist = new List<selectOption>(); 
        rightSOlist.add(new selectOption('Test','UTF-8'));
        controller.rightOption = rightSOlist;
        rightSOlist = controller.rightOption;
        
        string leftOptionhiddenstring =  controller.leftOptionsHidden;
        string rightOptionhiddenstring = controller.rightOptionsHidden;
        controller.leftOptionsHidden = 'test1&test2&test3&test4&test5&test6';
        controller.rightOptionsHidden = 'test1&test2&test3&test4&test5&test6';
    }
}