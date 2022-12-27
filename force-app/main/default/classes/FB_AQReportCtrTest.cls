@isTest
public class FB_AQReportCtrTest {
    static testMethod void unitTes(){
        List<TR1__Qualification__c> qualificationList = New List<TR1__Qualification__c>();
        List<String> qualiLIst = New List<String> {'DBS','Perm Qualification','ID','Teacher Qualification','Medical','References', 
            'Disqualification by Association','TOE','Right to Work', 'Overseas Police Check','Overseas Teacher Qualifications','Early Years Qualifications',
            'Support Qualifications','Post 16 Qualifications','Overseas DBS Check','CV' ,'Safeguarding'   };
                
                for(String s : qualiLIst) {
                    TR1__Qualification__c objQual = new TR1__Qualification__c(Name = s, TR1__Field_Set_ID__c = '321534', Abbreviation__c = s);
                    qualificationList.add(objQual);
                }   
        
        insert qualificationList;
        
        List<TR1__Qualification__c> objQualification = [SELECT Id, Name, Abbreviation__c FROM TR1__Qualification__c WHERE Name IN : qualiLIst ];
        
        Id contactRecordType = schema.SObjectType.contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(RecordTypeId = contactRecordType,LastName='test Contact123',Email='test@test32525.com',Phone='2343423',MobilePhone='1223343433',Subject__c ='Business Studies',Preferred_LEA__c='Blackpool',Tax_Method__c = 'PAYE');
        insert con;
        Id conId = con.Id; 
        
        ID qualiId = objQualification[0].Id;
        
        TR1__Qualification_Package__c objQualPkg  = new TR1__Qualification_Package__c(TR1__Name__c = 'OTT');
        insert objQualPkg;
        
        TR1__Associated_Qualification__c objAssoQual = new TR1__Associated_Qualification__c(TR1__Qualification__c =qualiId, TR1__Contact__c = conId, TR1__Qualification_Package__c = objQualPkg.Id,Clear_DBS__c=true,TR1__Status__c='Submitted',DBS_Disclosure_Notes__c='test',Qualification_Type2__c='Teacher Qualification',Qualification_Type__c='Bachelor of Arts/ Education');
        insert objAssoQual;
        
        Integer index = 200;
        PageReference pageRef = Page.FB_AQReport;
        pageRef.getParameters().put('iStart', String.valueOf(index));
        Test.setCurrentPage(pageRef);

        FB_AQReportCtr oFBAQReportCtr = new FB_AQReportCtr();
        FB_AQReportCtr.AQWrapper at = new FB_AQReportCtr.AQWrapper(con, objQualification);
        oFBAQReportCtr.doGenerate();
    }
}