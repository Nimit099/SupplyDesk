@isTest
global class SupplyDeskEmailHandlerTest {
    
    @isTest static void testEmailHandler(){
        
        Account acc = new Account(Name='CVP');
        insert acc;
        Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
        insert con;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test/JN -012018-508417/Internal/CV Library/Test/Jaime Walker/Test/NTest/ES/test@test.asd/123123123/32132131/GREENFLAG';
        email.fromname = 'FirstName LastName';
        email.htmlbody='[{"industryexperience":"Accounting & Finance Advertising, Marketing & Media Agriculture","subtype":"","primaryhomeaddress":"13 B ,New address","primaryhomezip/postalcode":"12346798","subtype":"","email":"test@missingFields.com","skypeaddress":"Missing address after change","registrationcomments":"NA","primaryhomecity":"TEste Home CIty","highestpositionheld":"MAnager","firstname":"For","systemsexperience":"ADP ADP 2001 ADP HRB","leadsourcedetail":"","leadsource":"Web","countriesworked":"USa","state/area":"Test State","primaryhomecountry":"Test COuntry","patinaoffice":"BRZ","travelpreference":"I am open to international travel","regionalarea":"Test Area","availableforboardofdirectorroles":"Yes","phonehome":"123465798","languages":"Test Language","preferredphone":"Phone - Mobile","phonemobile":"12354879","primaryhomestate/province":"AK","lastname":"Missing home address","yearsofexperience":"33","experiencelevel":"Executive"}]';
        env.fromAddress = 'someaddress@email.com';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('NAme : my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            SupplyDeskEmailHandler sup =new SupplyDeskEmailHandler();
        sup.handleInboundEmail(email, env);
    }
    @isTest static void testEmailHandler1(){
        
        Account acc = new Account(Name='CVP');
        insert acc;
        Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
        insert con;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test/JN -012018-508417/Test/CV/Library/Test/Jaime Walker/Test/NTest/ES/test@test.asd/123123123/32132131/GREENFLAG';
        email.fromname = 'FirstName LastName';
        email.htmlbody='[{"industryexperience":"Accounting & Finance Advertising, Marketing & Media Agriculture","subtype":"","primaryhomeaddress":"13 B ,New address","primaryhomezip/postalcode":"12346798","subtype":"","email":"test@missingFields.com","skypeaddress":"Missing address after change","registrationcomments":"NA","primaryhomecity":"TEste Home CIty","highestpositionheld":"MAnager","firstname":"For","systemsexperience":"ADP ADP 2001 ADP HRB","leadsourcedetail":"","leadsource":"Web","countriesworked":"USa","state/area":"Test State","primaryhomecountry":"Test COuntry","patinaoffice":"BRZ","travelpreference":"I am open to international travel","regionalarea":"Test Area","availableforboardofdirectorroles":"Yes","phonehome":"123465798","languages":"Test Language","preferredphone":"Phone - Mobile","phonemobile":"12354879","primaryhomestate/province":"AK","lastname":"Missing home address","yearsofexperience":"33","experiencelevel":"Executive"}]';
        env.fromAddress = 'someaddress@email.com';
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'NAme : my attachment text';
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };
            SupplyDeskEmailHandler sup =new SupplyDeskEmailHandler();
        sup.handleInboundEmail(email, env);
    }
    
}