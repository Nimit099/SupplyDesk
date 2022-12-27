@isTest
public class ViewAssociatedQualification_Test {
    static testMethod void testViewAssociateQualification() {
        Test.startTest();
        Contact objContact = new Contact(LastName = 'TestContact', phone = '231233', mobilePhone = '3432423', email = 'test@test.com', Subject__c = 'Art', Year_Key_Stage__c = 'KS1');
        insert objContact;
        TR1__Qualification__c objQualifiation = H_Utility_Test.createQualification('Graduation');
        TR1__Associated_Qualification__c objSourceAQ = H_Utility_Test.createAssociateQualification(objQualifiation.Id, null, null);

        TR1__Associated_Qualification__c objAQ = H_Utility_Test.createAssociateQualification(objQualifiation.Id, objContact.Id, null);
        objAQ.Source_Associated_Qualification__c = objSourceAQ.Id;
        update objAQ;

        PageReference pref;
        pref = Page.ViewAssociatedQualification;
        pref.getParameters().put('id', objAQ.id);
        pref.getParameters().put('retURL', objContact.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(objAQ);
        ViewAssociatedQualification objViewAQ = new ViewAssociatedQualification(sc);
        objViewAQ.goToStandardPage();
        objViewAQ.doCancelAQ();

        TR1__Associated_Qualification__c objAQ1 = H_Utility_Test.createAssociateQualification(objQualifiation.Id, null, null);
        sc = new ApexPages.StandardController(objAQ1);
        objViewAQ = new ViewAssociatedQualification(sc);
        objViewAQ.goToStandardPage();
        objQualifiation.Require_Documents__c = true;
        update objQualifiation;
        objViewAQ.saveAQ();
        objAQ1.TR1__Status__c = 'Active';
        sc = new ApexPages.StandardController(objAQ1);
        objViewAQ = new ViewAssociatedQualification(sc);
        objViewAQ.goToStandardPage();
        objQualifiation.Require_Documents__c = false;
        update objQualifiation;
        delete objAQ1;
        objViewAQ.saveAQ();
        Test.stopTest();
    }

    static testMethod void testAssociateQualificationDetail() {
        Test.startTest();
        Contact objContact = new Contact(LastName = 'TestContact', phone = '231233', mobilePhone = '3432423', email = 'test@test.com', Subject__c = 'Art', Year_Key_Stage__c = 'KS1');
        insert objContact;
        TR1__Qualification__c objQualifiation = H_Utility_Test.createQualification('Graduation');
        ViewAssociatedQualification.AddInfoMessage('Test value');
        ViewAssociatedQualification.AddWarningMessage('Test value');
        ViewAssociatedQualification.AddConfirmMessage('Test value');
        ViewAssociatedQualification.AddErrorMessage('Test value');
        ViewAssociatedQualification.AddFatalMessage('Test value');
        Test.stopTest();
    }
}