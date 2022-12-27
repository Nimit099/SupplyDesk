@isTest
private class GeoLocationAccountTriggerTest {
    
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
        
        acc.BillingStreet='Test1';
        acc.BillingCity='Test1';
        acc.BillingState='London';
        acc.BillingCountry='United Kingdom';
        acc.BillingPostalCode='EC2R 8DM';
        update acc;
        
        Test.stopTest();
        
    }
}