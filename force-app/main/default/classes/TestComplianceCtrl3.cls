@isTest
public class TestComplianceCtrl3 {
    public static testMethod void maintest(){
        test.startTest();
        	Contact newcon = new Contact(lastname = 'test');
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
        	pageReference pr = new pageReference('/apex/CompliancePage3');
        	test.setCurrentPageReference(pr);
        	ApexPages.currentPage().getParameters().put('id',newcon.Id);
        	ComplianceCtrl3 compctr3obj = new ComplianceCtrl3();
            for(Integer i=0;i<compctr3obj.listqualifications.size();i++){
                compctr3obj.listqualifications[i].ischeck=true;
                compctr3obj.listqualifications[0].asscqualfcn.TR1__Status__c='Submitted';
            }
        	compctr3obj.updateAsscQualfns();
        	
        	ComplianceCtrl3 compctr3obj1 = new ComplianceCtrl3();
            compctr3obj1.updateAsscQualfns();
            
            /*ComplianceCtrl2 compctr3obj2 = new ComplianceCtrl2();
            ApexPages.currentPage().getParameters().put('id',newcon.Id);
            compctr3obj2.actsel();
            compctr3obj2.SaveAss();
            compctr3obj2.getQualnames();*/
            
        test.stopTest();
    }
}