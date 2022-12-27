@isTest
public class TRS_MyCalendarTest {

	public static testMethod void test() {
        User u1=TestUtility.getUserDetail();
        
        System.runAs(u1){
        
        User objUser = RC_UtilityClass.returnCommunityUser();
        String strId = [Select contactId from User where id =: objUser.Id].contactId;
        
        system.runAs(objUser)
        {
            Test.setCurrentPage(Page.TRS_MyCalendar);
            TRS_MyCalendar testController = new TRS_MyCalendar();
        }
        
	}
    }

}