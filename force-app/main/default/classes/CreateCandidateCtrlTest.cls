@isTest
private class CreateCandidateCtrlTest {

    static testMethod void myUnitTest() {
        
        Account testAccount = new Account(Name='Test Account', BillingStreet  ='123', BillingCity ='test city', BillingState ='test county', BillingPostalCode  = '234345',
                                        BillingCountry  = 'test Country', ShippingStreet = '1233', ShippingCity='Test City', ShippingState='Test State', ShippingPostalCode='564533',
                                        ShippingCountry='Test Country');
        insert testAccount;
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppludesk.com');
        testContact.AccountId = testAccount.id;
        RecordType rt;
        for(RecordType r : [Select Id From RecordType Where Name = 'Candidate' AND SObjectType = 'Contact' limit 1]){
            rt = r;
        }
        testContact.RecordTypeId = rt.Id;
        CreateCandidateCtrl create = new CreateCandidateCtrl();
        create.con = testContact;
        create.doSubmit();
        create.createNewCandidate();
    }
    static testMethod void cacheCoverMethod() {
        
        CreateCandidateCtrl create = new CreateCandidateCtrl();
        create.doSubmit();
    }
}