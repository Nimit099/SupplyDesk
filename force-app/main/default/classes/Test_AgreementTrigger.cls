@isTest
public class Test_AgreementTrigger {

    @TestSetup
    public static void testSetupData(){
        Account acc = new Account(Name = 'UNKNOWN DO NOT DELETE');
        insert acc;
    }

    @isTest
    public static void adobeSignAgreementTest1(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion cv = new Contentversion();
        cv.title='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';
        cv.PathOnClient ='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Supply Desk Terms of Engagement Supply Teacher';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Out for Signature';
            update agSign;
        Test.stopTest();
    }
    
    @isTest
    public static void adobeSignAgreementTest1_1(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com', Registration_Agreement_Names__c = 'Supply Desk Terms of Engagement');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion cv = new Contentversion();
        cv.title='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';
        cv.PathOnClient ='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Supply Desk Terms of Engagement Supply Teacher';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Out for Signature';
            update agSign;
        Test.stopTest();
    }

    @isTest
    public static void adobeSignAgreementTest2(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the functionality.');
        ContentVersion cv = new Contentversion();
        cv.title='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';
        cv.PathOnClient ='Supply Desk Terms of Engagement Supply Teacher - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Supply Desk Terms of Engagement Supply Teacher';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        TR1__Qualification__c qual = new TR1__Qualification__c();
        qual.Name = 'Terms and Registration Forms';
        insert qual;
        TR1__Associated_Qualification__c associatQual = new TR1__Associated_Qualification__c();
        associatQual.TR1__Contact__c = testContact.Id;
        associatQual.TR1__Qualification__c = qual.Id;
        insert associatQual;

        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Signed';
            update agSign;
        Test.stopTest();
    }

    @isTest
    public static void adobeSignAgreementTest3(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the functionality.');
        ContentVersion cv = new Contentversion();
        cv.title='Referee Consent Form - signed.pdf';
        cv.PathOnClient ='Referee Consent Form - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Referee Consent Form';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        TR1__Qualification__c qual1 = new TR1__Qualification__c();
        qual1.Name = 'References';
        insert qual1;
        TR1__Associated_Qualification__c associatQual1 = new TR1__Associated_Qualification__c();
        associatQual1.TR1__Contact__c = testContact.Id;
        associatQual1.TR1__Qualification__c = qual1.Id;
        insert associatQual1;

        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Signed';
            update agSign;
        Test.stopTest();
    }

    @isTest
    public static void adobeSignAgreementTest4(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the functionality.');
        ContentVersion cv = new Contentversion();
        cv.title='Supply Desk DBS Terms of Service - signed.pdf';
        cv.PathOnClient ='Supply Desk DBS Terms of Service - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Supply Desk DBS Terms of Service';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        TR1__Qualification__c qual2 = new TR1__Qualification__c();
        qual2.Name = 'DBS';
        insert qual2;
        TR1__Associated_Qualification__c associatQual2 = new TR1__Associated_Qualification__c();
        associatQual2.TR1__Contact__c = testContact.Id;
        associatQual2.TR1__Qualification__c = qual2.Id;
        insert associatQual2;
        
        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Signed';
            update agSign;
        Test.stopTest();
    }

    @isTest
    public static void adobeSignAgreementTest5(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the functionality.');
        ContentVersion cv = new Contentversion();
        cv.title='Supply Desk DBS Terms of Service - signed.pdf';
        cv.PathOnClient ='Supply Desk DBS Terms of Service - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'Supply Desk DBS Terms of Service';
        agTemplate.echosign_dev1__Name__c = 'Testing Agreement';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'Testing Agreement';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        TR1__Qualification__c qual2 = new TR1__Qualification__c();
        qual2.Name = 'DBS';
        insert qual2;
        TR1__Associated_Qualification__c associatQual2 = new TR1__Associated_Qualification__c();
        associatQual2.TR1__Contact__c = testContact.Id;
        associatQual2.TR1__Qualification__c = qual2.Id;
        insert associatQual2;
        
        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Draft';
            agSign.echosign_dev1__Message__c = null;
            update agSign;
        Test.stopTest();
    }

    @isTest
    public static void adobeSignAgreementTest6(){
        Contact testContact = new Contact(FirstName = 'Test', LastName='Candidate', Email='testcandidate@suppldesk.com');
        insert testContact;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the functionality.');
        ContentVersion cv = new Contentversion();
        cv.title='SD/Teach in Teacher Registration Pack Overseas - signed.pdf';
        cv.PathOnClient ='SD/Teach in Teacher Registration Pack Overseas - signed.pdf';	
        cv.VersionData = bodyBlob;
        insert cv;

        echosign_dev1__Agreement_Template__c agTemplate = new echosign_dev1__Agreement_Template__c();
        agTemplate.Name = 'SD/Teach in Teacher Registration Pack';
        agTemplate.echosign_dev1__Name__c = 'SD/Teach in Teacher Registration Pack';
        insert agTemplate;

        echosign_dev1__SIGN_Agreement__c agSign = new echosign_dev1__SIGN_Agreement__c();
        agSign.Name = 'SD/Teach in Teacher Registration Pack';
        agSign.echosign_dev1__Recipient__c = testContact.Id;
        insert agSign;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = agSign.Id;
        contentlink.contentdocumentid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        TR1__Qualification__c qual2 = new TR1__Qualification__c();
        qual2.Name = 'DBS';
        insert qual2;
        TR1__Associated_Qualification__c associatQual2 = new TR1__Associated_Qualification__c();
        associatQual2.TR1__Contact__c = testContact.Id;
        associatQual2.TR1__Qualification__c = qual2.Id;
        insert associatQual2;
        
        Test.startTest();
            agSign.echosign_dev1__Status__c = 'Draft';
            agSign.echosign_dev1__Message__c = null;
            update agSign;
        Test.stopTest();
    }
}