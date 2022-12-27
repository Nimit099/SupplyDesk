@isTest
private class RC_ContactHandler_Test {

    @testSetup 
    static void createCustomSetting() {
      
        User u1=TestUtility.getUserDetail();
        
     

    }
    
  private static testMethod void testContactEnableCommunity() {
       Candidate_Community__c objCustomSett = new Candidate_Community__c (Name='RegistrationDetail', Profile__c ='Recruitment Community User', Username_suffix__c='@test.com');
        insert objCustomSett;
          
        User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
        System.runAs(u1){
      Account objNewAcc = new Account(Name='testAccount');
      insert objNewAcc;
        Contact objCon = new Contact(LastName = 'Test1', Email ='test11@mailinator.com',AccountId=objNewAcc.Id,Compliance_Status__c='Vet Complete',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Vetted',Year_Key_Stage__c='KS1',Subject__c='Accountancy');
        
        Contact objConEnableComm = new Contact(LastName = 'Test1', Email ='test13@mailinator.com', AccountId=objNewAcc.Id,Compliance_Status__c='Vet Complete',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Vetted',Year_Key_Stage__c='KS1',Subject__c='Accountancy');
        
        Contact objConNoComm = new Contact(LastName = 'Test1', Email ='test11@mailinator.com', Enable_Community_User__c = true,AccountId=objNewAcc.Id,Compliance_Status__c='Vet Complete',Trained_As__c = 'Instructor',Pay_Type__c = 'Perm',Sector__c = 'Junior', Job_Titles__c = 'Admin Assistant',Assignment_Type__c = 'Perm',TR1__Candidate_Status__c='Vetted',Year_Key_Stage__c='KS1',Subject__c='Accountancy');
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objCon);
        lstContact.add(objConEnableComm);
        lstContact.add(objConNoComm);
        insert lstContact;
        
        
        objCon.Enable_Community_User__c = true;
        objCon.FirstName = 'PNBest';
        
        objConEnableComm.Enable_Community_User__c = true;
        objConNoComm.Enable_Community_User__c = false;
        
        lstContact = new List<Contact>{objCon,objConEnableComm,objConNoComm};
        try{
            update lstContact;
        }
        catch(DmlException ex){
            system.assert(true, ex.getMessage().contains('User already available with this email'));
        }
        
        //duplicate email id
        system.debug('::: user::'+[Select Id, Email, UserName from User where Email ='test13@mailinator.com']);
        Contact objConDupEmail = new Contact(LastName = 'Test123', Email ='test13@mailinator.com',Enable_Community_User__c = true,AccountId=objNewAcc.Id);
        try{
            insert objConDupEmail;
        }
        catch(DmlException ex){
            system.assert(true, ex.getMessage().contains('User already available with this email'));
        }
        
        Test.startTest();
        objConNoComm.Email ='';
        objConNoComm.Enable_Community_User__c = true;
        try{
            update objConNoComm;
        }
        catch(DmlException ex){
            system.assert(true, ex.getMessage().contains('Email Id should not be blank'));
        }
        
        objCon.FirstName = 'newFirstName';
        objCon.LastName = 'lastNameNew';
        try{
            update objCon;
        }
        catch(DmlException ex){
            system.assert(true, ex.getMessage().contains('User already available with this email'));
        }
        Test.stopTest();
        
        objConEnableComm.Enable_Community_User__c = false;
        objConEnableComm.LastName='asdasd';
        update objConEnableComm;

  }
  }

}