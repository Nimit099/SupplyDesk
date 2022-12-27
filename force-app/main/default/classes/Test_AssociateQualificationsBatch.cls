@isTest
private class Test_AssociateQualificationsBatch {

	private static testMethod void batchQualification() {
        Contact con = new Contact();
        con.LastName = 'Demo';
        con.Compliance_Owner__c = UserInfo.getUserId();
        insert con;
        
        List<TR1__Qualification__c> quaList = new List<TR1__Qualification__c>();
        
        for(Integer i=0; i<10; i++){
            quaList.add(new TR1__Qualification__c(Name = 'Barred List'+i));
        }
        
    
        insert quaList;
    
        List<TR1__Associated_Qualification__c> assQuaList = new List<TR1__Associated_Qualification__c>();
        
        for(Integer i=0; i<10; i++){
           assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[i].Id));
        }
        
        insert assQuaList;
        
        Test.startTest();
            AssociateQualificationsBatch bq = new AssociateQualificationsBatch('SELECT Id, isBatch_updated__c FROM TR1__Associated_Qualification__c');
            Database.executeBatch(bq,200);
            AssociateQualificationsBatch bq1 = new AssociateQualificationsBatch('SELECT Id FROM TR1__Qualification__c');
            Database.executeBatch(bq1,200);
        Test.stopTest();
	}

}