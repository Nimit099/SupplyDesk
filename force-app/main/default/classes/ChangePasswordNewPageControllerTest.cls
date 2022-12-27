/*******************************************************
* Name          : ChangePasswordNewPageControllerTest
* Author        : 
* Create Date   : 01/08/2022
* UsedBy        : ChangePasswordNewPageController
* Description   : Test Class
*******************************************************/
@IsTest 
public with sharing class ChangePasswordNewPageControllerTest {
    
   	@IsTest
    public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordNewPageController controller = new ChangePasswordNewPageController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}