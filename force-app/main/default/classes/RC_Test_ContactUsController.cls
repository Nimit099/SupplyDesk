@isTest()
public class RC_Test_ContactUsController 
{
    private static testMethod void TestContactUs()
    {
        RC_ContactUsController objContactUs = new RC_ContactUsController();
        System.assertEquals('Portal Help', objContactUs.strSubject);
        objContactUs.redirectUnAuthenticatedUser();
        objContactUs.sendEmail();
        System.assertEquals(objContactUs.strName, UserInfo.getFirstName()+' '+UserInfo.getLastName());
    }
}