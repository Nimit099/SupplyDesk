@isTest
private class associatedQualificationTriggerTest {

    @TestSetup
    public static void testSetupData(){
        Id rcId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
    }

	private static testMethod void UpdateContactWhenAQSavedTest() {
	    
	    
	    List<TR1__Qualification__c> qualificationList = New List<TR1__Qualification__c>();
	    
	    List<String> qualiLIst = New List<String> {'DBS','Perm Qualification','ID','Teacher Qualification','Medical','References', 
                                                    'Disqualification by Association','TOE','Right to Work', 'Overseas Police Check','Overseas Teacher Qualifications','Early Years Qualifications',
	                                                'Support Qualifications','Post 16 Qualifications','Overseas DBS Check','CV' ,'Safeguarding'   };
         
        for(String s : qualiLIst) {
            TR1__Qualification__c objQual = new TR1__Qualification__c(Name = s, TR1__Field_Set_ID__c = '321534');
            qualificationList.add(objQual);
        }   
        
        insert qualificationList;
        
        List<TR1__Qualification__c> objQualification = [SELECT Id,Name FROM TR1__Qualification__c WHERE Name IN : qualiLIst ];
        
         TR1__Qualification_Package__c objQualPkg  = new TR1__Qualification_Package__c(TR1__Name__c = 'OTT');
        insert objQualPkg;
        
        Id contactRecordType = schema.SObjectType.contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(RecordTypeId = contactRecordType,LastName='test Contact123',Email='test@test32525.com',Phone='2343423',MobilePhone='1223343433', Year_Key_Stage__c ='Foundation Stage 3-5yrs', LEA__c = 'North West', Preferred_LEA__c='Blackpool',Tax_Method__c = 'PAYE');
        insert con;
        Id conId = con.Id;  
        
        ID qualiId = objQualification[0].Id;

        
        TR1__Associated_Qualification__c objAssoQual = new TR1__Associated_Qualification__c(TR1__Qualification__c =qualiId, TR1__Contact__c = conId, TR1__Qualification_Package__c = objQualPkg.Id,Clear_DBS__c=true,TR1__Status__c='Submitted',DBS_Disclosure_Notes__c='test',Qualification_Type2__c='Teacher Qualification',Qualification_Type__c='Bachelor of Arts/ Education'); 
        //objAssoQual.Inactive_Compliance_Result__c = 'Non Workable';
        insert objAssoQual;
        
        List<TR1__Associated_Qualification__c> aqListToBeinserted = New List<TR1__Associated_Qualification__c>();
        
        TR1__Associated_Qualification__c aqObj = [SELECT ID,TR1__Qualification__c FROM TR1__Associated_Qualification__c WHERE TR1__Qualification__c  =: qualiId];
        
        for(Integer i=1;i<=11;i++){
            TR1__Associated_Qualification__c ob = New TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification[i].Id,TR1__Contact__c = conId, TR1__Qualification_Package__c = objQualPkg.Id,Clear_DBS__c=true,TR1__Status__c='Requested',DBS_Disclosure_Notes__c='test');
            aqListToBeinserted.add(ob);
        }
        Test.startTest();
        
            if(aqListToBeinserted.size() > 0)
            insert aqListToBeinserted;
        
            aqObj.TR1__Qualification__c = objQualification[13].Id;
            update aqObj;
        
        Test.stopTest();
	}


}