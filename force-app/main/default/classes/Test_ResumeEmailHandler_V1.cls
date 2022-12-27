@isTest
global class Test_ResumeEmailHandler_V1 {
  
  @isTest static void testEmailHandler(){

    Account acc = new Account(Name='CVP');
    insert acc;
    Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
    insert con;
    Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id);    
    insert job1;

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestCndiate/test/'+job1.TR1__Job_Number__c+'/test';
        email.fromname = 'FirstName LastName';
        email.htmlbody='[{"industryexperience":"Accounting & Finance Advertising, Marketing & Media Agriculture","subtype":"","primaryhomeaddress":"13 B ,New address","primaryhomezip/postalcode":"12346798","subtype":"","email":"test@missingFields.com","skypeaddress":"Missing address after change","registrationcomments":"NA","primaryhomecity":"TEste Home CIty","highestpositionheld":"MAnager","firstname":"For","systemsexperience":"ADP ADP 2001 ADP HRB","leadsourcedetail":"","leadsource":"Web","countriesworked":"USa","state/area":"Test State","primaryhomecountry":"Test COuntry","patinaoffice":"BRZ","travelpreference":"I am open to international travel","regionalarea":"Test Area","availableforboardofdirectorroles":"Yes","phonehome":"123465798","languages":"Test Language","preferredphone":"Phone - Mobile","phonemobile":"12354879","primaryhomestate/province":"AK","lastname":"Missing home address","yearsofexperience":"33","experiencelevel":"Executive"}]';
        env.fromAddress = 'someaddress@email.com';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('NAme : my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        ResumeEmailHandlerV1 emailProc=new ResumeEmailHandlerV1();
        emailProc.handleInboundEmail(email, env);
     
        
    }
  
@isTest static void testEmailHandler1(){

    Account acc1 = new Account(Name='CVP 1');
    insert acc1;
    Contact con1 = new Contact(LastName='CVP Contact 1 ',Email='test12@test.com');
    insert con1;
    Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    TR1__Job__c job2 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc1.Id,Name='Job 2',TR1__Contact__c=con1.Id);    
    insert job2;

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestCndiate/test/test';
        email.fromname = 'FirstName LastName';
       // email.htmlbody='[{"industryexperience":"Accounting & Finance Advertising, Marketing & Media Agriculture","subtype":"","primaryhomeaddress":"13 B ,New address","primaryhomezip/postalcode":"12346798","subtype":"","email":"test@missingFields.com","skypeaddress":"Missing address after change","registrationcomments":"NA","primaryhomecity":"TEste Home CIty","highestpositionheld":"MAnager","firstname":"For","systemsexperience":"ADP ADP 2001 ADP HRB","leadsourcedetail":"","leadsource":"Web","countriesworked":"USa","state/area":"Test State","primaryhomecountry":"Test COuntry","patinaoffice":"BRZ","travelpreference":"I am open to international travel","regionalarea":"Test Area","availableforboardofdirectorroles":"Yes","phonehome":"123465798","languages":"Test Language","preferredphone":"Phone - Mobile","phonemobile":"12354879","primaryhomestate/province":"AK","lastname":"Missing home address","yearsofexperience":"33","experiencelevel":"Executive"}]';
        env.fromAddress = 'someaddress@email.com';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('NAme : my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        ResumeEmailHandlerV1 emailProc=new ResumeEmailHandlerV1();
        emailProc.handleInboundEmail(email, env);
    
        
    }
  
}