@isTest
public class AssociatedQualificationDetailCtrlTest {
    
    public static testmethod void testMethod1(){
        
        TR1__Qualification__c objQual = new TR1__Qualification__c(Name = 'Passport', TR1__Field_Set_ID__c = '321534');
        insert objQual;
        TR1__Qualification__c objQual1 =  new TR1__Qualification__c(Name = 'Resume', TR1__Field_Set_ID__c = '321534');
        insert objQual1;
        
        TR1__Qualification_Package__c objQualPkg  = new TR1__Qualification_Package__c(TR1__Name__c = 'OTT');
        insert objQualPkg;
        
        Id contactRecordType = schema.SObjectType.contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact objContact = new Contact(recordTypeId = contactRecordType, LastName = 'TestLastName_AssoQual', Tax_Method__c = 'PAYE', email ='test@test328435634567294.com', phone  ='342336364', Subject__c  = 'Art', Year_Key_Stage__c ='KS1');
        insert objContact;
        
        TR1__Associated_Qualification__c objAssoQual = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        insert objAssoQual;
        
        TR1__Associated_Qualification__c objAssoQual1 = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual1.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        insert objAssoQual1;
        
        PageReference pageRef = Page.AssociatedQualificationDetailPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(objAssoQual.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(objAssoQual);
        AssociatedQualificationDetailCtrl testAccPlan = new AssociatedQualificationDetailCtrl(sc);
        testAccPlan.goToStandardPage();
        testAccPlan.backToContact();
        testAccPlan.clickAddNote();
        testAccPlan.createNote();
        testAccPlan.backToCurrentRecord();
        
    }
    
    public static testmethod void testMethod2(){
        
        TR1__Qualification__c objQual = new TR1__Qualification__c(Name = 'Passport',TR1__Field_Set_ID__c = 'CV');
        insert objQual;
        TR1__Qualification__c objQual1 =  new TR1__Qualification__c(Name = 'Resume', TR1__Field_Set_ID__c = '321534');
        insert objQual1;
        
        TR1__Qualification_Package__c objQualPkg  = new TR1__Qualification_Package__c(TR1__Name__c = 'OTT');
        insert objQualPkg;
        
        Id contactRecordType = schema.SObjectType.contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact objContact = new Contact(recordTypeId = contactRecordType, LastName = 'TestLastName_AssoQual', Tax_Method__c = 'PAYE', email ='test@test328435634567294.com', phone  ='342336364', Subject__c  = 'Art', Year_Key_Stage__c ='KS1');
        insert objContact;
        
        TR1__Associated_Qualification__c objAssoQual = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        insert objAssoQual;
        
        TR1__Associated_Qualification__c objAssoQual1 = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual1.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        insert objAssoQual1;
        
        Note n = new Note();
        n.Title ='test';
        n.Body ='test';
        n.IsPrivate = true;
        n.ParentId =objAssoQual.id;
        insert n;
        
        PageReference pageRef = Page.AssociatedQualificationDetailPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(objAssoQual.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(objAssoQual);
        AssociatedQualificationDetailCtrl testAccPlan = new AssociatedQualificationDetailCtrl(sc);
        testAccPlan.goToStandardPage();
        testAccPlan.backToContact();
        testAccPlan.clickAddNote();
        testAccPlan.createNote();
        testAccPlan.backToCurrentRecord();
        
    }
}