@isTest
private class RC_ContactAssociatedQualifications_Test {

	private static testMethod void testCreateAssoicatedQualification() {
	    
	    Test.startTest();
	    
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
	    //objAssoQual.Inactive_Compliance_Result__c = 'Non Workable';
	    insert objAssoQual;
	    
	    TR1__Associated_Qualification__c objAssoQual1 = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual1.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        //objAssoQual1.Inactive_Compliance_Result__c = 'Non Payable';
        insert objAssoQual1;
      
        
        objContact = [select Name, Id,Pay_Type__c from Contact where id= : objContact.Id limit 1 ];
        objContact.Pay_Type__c = 'OTT';
        update objContact;
        
	    
	    List<TR1__Associated_Qualification__c> lstAQ = [Select TR1__Status__c from TR1__Associated_Qualification__c where TR1__Contact__c =:objContact.Id];
	    if(!lstAQ.isEmpty()){
    	    lstAQ[0].TR1__Status__c = 'Active';
    	    lstAQ[1].TR1__Status__c = 'Active';
    	    update lstAQ;
	    }
	       
        Contact objContact1 = new Contact(LastName = 'TestLastName_AssoQual - 1',email ='tes1414t@test32847294.com', phone  ='34234', Subject__c  = 'Art', Year_Key_Stage__c ='KS1');//, Pay_Type__c = 'Permanent');
	    insert objContact1;
        
        TR1__Associated_Qualification__c objAssoQual2 = new TR1__Associated_Qualification__c(TR1__Qualification__c =objQual.Id, TR1__Contact__c = objContact1.Id, TR1__Qualification_Package__c = objQualPkg.Id); 
        //objAssoQual2.Source_Associated_Qualification__c = objAssoQual1.Id;
        objAssoQual2.TR1__Status__c = 'Active';
        insert objAssoQual2;
      
        
	    
	    Test.stopTest();

	}

}