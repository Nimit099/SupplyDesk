@isTest
private class RC_ResumeUploadTest 
{
    @TestSetup
static void initData()
{
   User u1=TestUtility.getUserDetail();
}
    
    private static testMethod void test1() 
    {               
        User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
        System.runAs(u1){
        //to generate exception  
        User u = RC_UtilityClass.returnCommunityUser();        
        System.runAs(u)
        {
            ApexPages.currentPage().getParameters().put('success', 'false');
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            RC_ResumeUpload objResumeUpload = new RC_ResumeUpload();
            objResumeUpload.objAttachment.Name = 'TestAttachment';
            objResumeUpload.objAttachment.body = bodyBlob;
            System.assertEquals(objResumeUpload.success,'false');
            PageReference pg = objResumeUpload.insertContent();  
            System.assertEquals('/ResumeUpload?Success=false&UserExist=false',pg.getURL());  
        }    
        }
    }
    
    private static testMethod void test2() 
    {
         User u1=[Select Id,Name,Email from User where email='pb@ff1.com' Limit 1];
          
        
        System.runAs(u1){
        
        Profile testProfile = [select Id,name from Profile where Name ='System Administrator' limit 1 ]; 
        Account testAcc =TestUtility.getAccountDetail();
          Contact testContact=TestUtility.getContactDetail(u1,testAcc);  
        
        User testUser = new User(
            profileId = testProfile.id, 
            username = 'testUser146212471547@174868476test.com', 
            email = 'testemail145235@testemail53235.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname12334124', 
            contactId = testContact.id
        );
        insert testUser;
        
        TR1__TalentRoverProperties__c testCustomSetting = new TR1__TalentRoverProperties__c(Apex_Email_Service__c = 'testemail@test37498274.com');
        insert testCustomSetting;
        
        System.runAs(testUser)
        {
            ApexPages.currentPage().getParameters().put('success', 'false');
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            RC_ResumeUpload objResumeUpload = new RC_ResumeUpload();
            objResumeUpload.objAttachment.Name = 'TestAttachment';
            objResumeUpload.objAttachment.body = bodyBlob;
            System.assertEquals(objResumeUpload.success,'false');
            PageReference pg = objResumeUpload.insertContent();  
            System.assertEquals('/ResumeUpload?Success=false&UserExist=false',pg.getURL());
        }
    }
    
    }
}