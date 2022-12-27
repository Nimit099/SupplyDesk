@isTest
public class Test_SchoolRequiredPreparationController {
	
    @isTest public static void testData(){
        Contact ct = new Contact();
        ct.LastName = 'test';
        insert ct;
        
        PageReference pageRef = Page.SchoolRequiredPreparation;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',ct.id);
        
        Test.startTest();
        	SchoolRequiredPreparationController sc = new SchoolRequiredPreparationController();
        	sc.isCovRiskAssesmet = 'Yes';
        	sc.isNotifyToSupplyDeskoCovidCase = 'Yes';
        	sc.isSupplyCandidateWorking = 'Yes';
        	sc.Submit();
        Test.stopTest();
    }
}