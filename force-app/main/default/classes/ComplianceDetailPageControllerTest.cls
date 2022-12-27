@isTest
public class ComplianceDetailPageControllerTest {
    
    public static testMethod void maintest(){
        
        test.startTest();
            Contact newcon = new Contact(lastname = 'test', email = 'test@test522525.com', phone = '34234234');
            insert newcon;        
            List< TR1__Qualification__c > listqlfns = new List< TR1__Qualification__c >();
            for(Integer i=0;i<5;i++){
                TR1__Qualification__c qualfn = new TR1__Qualification__c(Name='testqual'+i,Description__c='testdesc'+i);
                listqlfns.add(qualfn);
            }
            insert listqlfns;
            List< TR1__Associated_Qualification__c > listasqlfns = new List< TR1__Associated_Qualification__c >();
            for(Integer i=0;i<4;i++){
                TR1__Associated_Qualification__c qualfn = new TR1__Associated_Qualification__c(TR1__Qualification__c=listqlfns[i].Id,TR1__Contact__c=newcon.Id);
                listasqlfns.add(qualfn);
            }
            insert listasqlfns;
            pageReference pr = new pageReference('/apex/ComplianceDetailPage');
            test.setCurrentPageReference(pr);
            ApexPages.currentPage().getParameters().put('id',newcon.Id);
            ApexPages.StandardController str = new ApexPages.StandardController(newcon);
            ComplianceDetailPageController compdetobj = new ComplianceDetailPageController(str);
            compdetobj.redirectToCompliance();
        test.stopTest();
    }
}