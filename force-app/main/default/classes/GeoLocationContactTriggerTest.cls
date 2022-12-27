@isTest
private class GeoLocationContactTriggerTest {
    
    public static testmethod void unitTest(){
        Google_Map_API__c gApi = Google_Map_API__c.getInstance();
        gApi.isExecuteAccount__c = true;
        gApi.isExecuteContact__c = true;
        gApi.API_Key__c = 'TestClassOnly';
        upsert gApi;
        
        Test.startTest();
        Account acc = new Account(Name='CVP', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345', BillingCountry  = 'test Country',
                                  shippingStreet = '1233',shippingCity='Test City',ShippingState='Test State',shippingPostalCode='564533',shippingCountry='Test Country');
        
        insert acc;
        
        Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(LastName='CVP Contact',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId,  Subject__c ='Art',
                                  Year_Key_Stage__c = 'KS1',TR1__Candidate_Status__c = 'DNU',Compliance_Status__c = 'Cleared',Pay_Type__c = 'Perm', Trained_As__c = 'Instructor',
                                  Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm', References_AQ_Hidden__c='Active',ID_AQ_Hidden__c='Active',Barred_List_AQ_Hidden__c='Active',
                                  Perm_Qualification_AQ_Hidden__c='Active',Right_to_Work_AQ_Hidden__c='Active',
                                  OtherStreet='Test',OtherCity='Test',OtherState='London',OtherCountry='United Kingdom',OtherPostalCode='EC2R 8DN',
                                  Compliance_Owner__c = UserInfo.getUserId()); 
        insert con;
        
        con.OtherStreet='Test1';
        con.OtherCity='Test1';
        con.OtherState='London';
        con.OtherCountry='United Kingdom';
        con.OtherPostalCode='EC2R 8DM';
        update con;
        
        Test.stopTest();
        
    }
}