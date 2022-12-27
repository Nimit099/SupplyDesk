/*******************************************************
* Name          : ts_ProfileModuleTest
* Author        : Krunal
* Create Date   : 01/08/2022
* UsedBy        : ts_ProfileModule, ExceptionHandler, ExceptionInfo, GenericException
* Description   : Test Class
*******************************************************/
@isTest
public with sharing class ts_ProfileModuleTest {

    @TestSetup
    static void testData(){
        
        Id profileId = [Select Id From Profile Where Name ='System Administrator'].Id;
        
        User usr = new User();
        usr.FirstName = 'Wilson';
        usr.LastName = 'Client';
        usr.Email = 'wilsonClient@gmail.com';
        usr.Phone = '9163298798';
        usr.MobilePhone = '9163298790';
        usr.Username = 'wilson@sfdcWilson.org'; 
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.Alias = 'Wilson';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = profileId;
        insert usr;
        
        Account acc = new Account();
        acc.Name = 'UNKNOWN DO NOT DELETE';
        acc.TR1__Status__c = 'Client';
        insert acc;

        Contact con = new Contact();
        con.LastName = usr.LastName;
        con.FirstName = usr.FirstName;
        con.Email = usr.Email;
        con.MobilePhone = usr.MobilePhone;
        con.Phone = usr.Phone;
        con.AccountId = acc.Id;
        con.OwnerId = usr.Id;
        insert con;

        List<TR1__Qualification__c> quaList = new List<TR1__Qualification__c>();
        quaList.add(new TR1__Qualification__c(Name = 'CV'));
        quaList.add(new TR1__Qualification__c(Name = 'Right to Work'));
        quaList.add(new TR1__Qualification__c(Name = 'Teacher Qualification'));
        quaList.add(new TR1__Qualification__c(Name = 'Overseas Police Check'));
        quaList.add(new TR1__Qualification__c(Name = 'Overseas Teacher Qualifications'));
        quaList.add(new TR1__Qualification__c(Name = 'Id'));
        quaList.add(new TR1__Qualification__c(Name = 'Safeguarding'));
        quaList.add(new TR1__Qualification__c(Name = 'Emergency Contact'));
        quaList.add(new TR1__Qualification__c(Name = 'DBS'));
        quaList.add(new TR1__Qualification__c(Name = 'Post 16 Qualifications'));
        quaList.add(new TR1__Qualification__c(Name = 'Early Years Qualifications'));
        quaList.add(new TR1__Qualification__c(Name = 'Support Qualifications'));
        quaList.add(new TR1__Qualification__c(Name = 'International'));
        quaList.add(new TR1__Qualification__c(Name = 'Barred List'));
        quaList.add(new TR1__Qualification__c(Name = 'References'));
        quaList.add(new TR1__Qualification__c(Name = 'Upload Photo'));
        insert quaList;

        List<TR1__Associated_Qualification__c> assQuaList = new List<TR1__Associated_Qualification__c>();
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[0].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[1].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[2].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[3].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[4].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[5].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[6].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[7].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[8].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[9].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[10].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[11].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[12].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[13].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[14].Id));
        assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[15].Id));
        insert assQuaList;

        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=con.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

    }

    @isTest
    static void testMethod1(){
        Test.startTest();

        user usr = [SELECT Id, FirstName, LastName, Username, Email, Phone, MobilePhone FROM User WHERE LastName =: 'Client'];
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];

        System.runAs(usr) {
            ts_ProfileModule.saveData(con);
            ts_ProfileModule.getData();
            ts_ProfileModule.getDocsData();
            ts_ProfileModule.getContactId();
            ts_ProfileModule.getQualifiData();
            ts_ProfileModule.deleteFile(usr.Id);
            ts_ProfileModule.doLogin(usr.Username, 'Password');
            String jsonstring = Json.serialize(usr); 
            ts_ProfileModule.createuser(jsonstring, 'test@gmail.com');
            ts_ProfileModule.getcrdata(usr.Id);
            ts_ProfileModule.getcrdata('  ');
            ts_ProfileModule.changepass('oldPass', 'newPass', 'newPass');
            ts_ProfileModule.resetpass('newPass', usr.Username);
            ts_ProfileModule.sendEmailToController('Wilson', 'WilsonClient@gmail.com', 'User Mail', 'Feedback of User');
            ts_ProfileModule.sendEmailToController('Wilson', '', 'User Mail', 'Feedback of User');
            ts_ProfileModule.getQualification();
            ts_ProfileModule.saveFile(usr.Id, 'Unit Test ContentVersion Body');
            ts_ProfileModule.saveCV(usr.Id, 'User CV', 'Unit Test ContentVersion Body');
            ts_ProfileModule.saveQualifiFile(con.Id, 'References', 'CV', 'Unit Test ContentVersion Body');
            ts_ProfileModule.downloadpdf('Record Id');
            ts_ProfileModule.getqualifiFileData(con.Id, 'References');

            TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'CV'];
            ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        }
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){
        Test.startTest();
        user usr = [SELECT Id, FirstName, LastName, Username, Email, Phone, MobilePhone FROM User WHERE LastName =: 'Client'];
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];

        Account acc = [SELECT Id, Name, ShippingPostalCode FROM Account LIMIT 1];
        acc.ShippingPostalCode = '000';
        update acc;

        String jsonstring = Json.serialize(usr); 
        ts_ProfileModule.createuser(jsonstring, 'test@gmail.com');
        
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Gaps_Explanation__c, CV_Submitted__c, CV_Received__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'CV'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        ts_ProfileModule.getDependentPicklistValues();
        ts_ProfileModule.fetchContact();
        ts_ProfileModule.forgotSitePassword(usr.Username);

        ExceptionHandler.futureLogException('test', 'test', 'test');
        ExceptionHandler.logInformation('test', 'test', 'test', 'test');


        GenericException exc = new GenericException();
        exc.getErrorMsg();
        exc.getReasonCode();
        
        Test.stopTest();
    }

    @isTest
    static void testMethod3(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Permanent_Right_to_Work_in_UK__c, Documents__c, Work_Permit_OR_Visa_Expiry_Date__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Right to Work'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod4(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, NCTL_Number__c, Qualification_Type2__c, Qualification_Type__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Teacher Qualification'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod5(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Overseas_Police_Check__c, Live_Worked_Overseas_Start_Date__c, Live_Worked_Overseas_End_Date__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Overseas Police Check'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod6(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, NCTL_Number__c, NARIC_Approved__c, Qualification_Type2__c, Qualification_Type__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Overseas Teacher Qualifications'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod7(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Group_1_ID_Type__c, Name_Change_Document__c, Group_2a_ID_Type__c, Group_2b_ID_Type__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'ID'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod8(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Safeguarding_Date_Completed__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Safeguarding'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod9(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Relationship_to_You__c, Emergency_Contact_Address__c, Emergency_Contact_Home_Phone__c, Emergency_Contact_Mobile_Phone__c,
                                                Emergency_Contact_Work_Phone__c, Emergency_Contact_Name__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Emergency Contact'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod10(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, DBS_Form_Number__c, Update_Service_Status_Check__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'DBS'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod11(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, SET_Registration_Number__c, Qualification_Type2__c, SET_Expiry_Date__c, QTLS__c, 
                                                Qualification_Type__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Post 16 Qualifications'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod12(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Qualification_Type2__c, Qualification_Type__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Early Years Qualifications'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod13(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Qualification_Type2__c, Qualification_Type__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Support Qualifications'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod14(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Seeking_International_Position__c, Choice_of_Country__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'International'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod15(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, Barred_Check_URL__c, Barred_List_Results__c, EWC_Registration_Checked_Date__c, EWC__c, 
                                                Barred_List_Date_Checked__c, Barred_List_Expiry_Date_New__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Barred List'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod16(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id,qualificationName__c,Reference_Sent_Date__c,Reference_1_Text_Name__c,Reference_Received_Date__c,
                                                            Reference_1_Date_Range_End__c,Reference_1_Rating__c,Reference_2_Name__c,
                                                            Reference_2_Received_Date__c,Reference_2_Date_Rage__c,Reference_2_Date_Range_End__c,
                                                            Reference_2_Rating__c,Reference_3_Sent_Date__c,Reference_3_Text_Name__c,
                                                            Reference_3_Received_Date__c,Reference_3_Date_Range__c,Reference_3_Date_Range_End__c,
                                                            Reference_3_Rating__c, Reference_1_Contact_Details__c, Reference_1_Email__c, Reference_1_Type__c, Reference_1_Received__c, 
                                                            Reference_2_Contact_Details__c, Reference_2_Email__c, Reference_2_Type__c, Reference_2_Received__c, Reference_3_Contact_Details__c, 
                                                            Reference_3_Email__c, Reference_3_Type__c, Reference_3_Received__c, Reference_1_Date_Range__c, Reference_2_Text_Name__c, 
                                                            Barred_Check_URL__c, Reference_2_Sent_Date__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'References'];


        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

    @isTest
    static void testMethod17(){
        Test.startTest();
        contact con = [SELECT Id, LastName, FirstName, Email, MobilePhone, Phone, AccountId FROM Contact WHERE LastName =: 'Client'];
        TR1__Associated_Qualification__c qual = [SELECT Id, qualificationName__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE qualificationName__c =: 'Upload Photo'];
        ts_ProfileModule.editQuali(con.Id, qual.qualificationName__c, qual);
        Test.stopTest();
    }

}