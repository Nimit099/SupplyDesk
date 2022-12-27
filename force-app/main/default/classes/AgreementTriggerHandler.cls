public class AgreementTriggerHandler {

    List<echosign_dev1__SIGN_Agreement__c> newList = new List<echosign_dev1__SIGN_Agreement__c>();
    List<echosign_dev1__SIGN_Agreement__c> oldList = new List<echosign_dev1__SIGN_Agreement__c>();
    Map<Id, echosign_dev1__SIGN_Agreement__c> newMap = new Map<Id, echosign_dev1__SIGN_Agreement__c>();
    Map<Id, echosign_dev1__SIGN_Agreement__c> oldMap = new Map<Id, echosign_dev1__SIGN_Agreement__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public AgreementTriggerHandler(List<echosign_dev1__SIGN_Agreement__c> newList, List<echosign_dev1__SIGN_Agreement__c> oldList, Map<Id, echosign_dev1__SIGN_Agreement__c> newMap, Map<Id, echosign_dev1__SIGN_Agreement__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeUpdateEvent(){
        System.debug('Before Update Event');
        User usr = [SELECT Id, Name, Title, Email, Branch__c, Branch_Phone__c, Branch_Email__c FROM User WHERE Id =: UserInfo.getUserId()];
        for(echosign_dev1__SIGN_Agreement__c agr : newList){
            if(agr.echosign_dev1__Status__c == 'Draft' && agr.echosign_dev1__Recipient__c != null && agr.echosign_dev1__Message__c == null){
                Contact contact = [SELECT Id, FirstName, Name FROM Contact WHERE Id =: agr.echosign_dev1__Recipient__c];
                System.debug('Name -- -'+agr.Name);
                if(!agr.Name.contains(contact.Name)){
                    agr.Name += ' - [' + contact.Name + ']';
                }
                String messageText = '';
                if(agr.Name.contains('SD/Teach in Teacher Registration Pack')){
                    messageText = messageString1(contact, usr);
                }else{
                    messageText = messageString(contact, usr);
                }
                agr.echosign_dev1__Message__c = messageText;
                System.debug('Test message ----- '+agr.echosign_dev1__Message__c);
            }
        }
    }

    public void AfterUpdateEvent(){
        System.debug('After Update Event');
        List<Id> contUpIds = new List<Id>();
        List<Id> signAgreementIds = new List<Id>(); 
        Map<Id, String> ofcAgreementList = new Map<Id, String>();
        List<Id> contactIds = new List<Id>();
        List<ContentDocumentLink> newdocumentlink = new List<ContentDocumentLink>();

        try{
            for(echosign_dev1__SIGN_Agreement__c agr : newList){
                if(agr.echosign_dev1__Status__c == 'Out for Signature'){
                    contUpIds.add(agr.echosign_dev1__Recipient__c);
                    ofcAgreementList.put(agr.echosign_dev1__Recipient__c, agr.Name);
                }
                if(agr.echosign_dev1__Status__c == 'Signed'){
                    contactIds.add(agr.echosign_dev1__Recipient__c);
                    System.debug('Contact --- '+ agr.echosign_dev1__Recipient__c);
                    signAgreementIds.add(agr.Id);
                }
            }
            
            if(signAgreementIds.size() > 0){
                Map<Id, List<ContentDocumentLink>> contDocMap = new Map<Id, List<ContentDocumentLink>>();
                for(ContentDocumentLink codl : [SELECT Id, ContentDocument.Title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: signAgreementIds]){
                    if(!contDocMap.containsKey(codl.LinkedEntityId)){
                        contDocMap.put(codl.LinkedEntityId, new List<ContentDocumentLink>());
                    }
                    contDocMap.get(codl.LinkedEntityId).add(codl);
                }

                Map<Id, List<TR1__Associated_Qualification__c>> aQualMap = new Map<Id, List<TR1__Associated_Qualification__c>>();
                for(TR1__Associated_Qualification__c aq : [SELECT Id, Name, TR1__Contact__c, TR1__Qualification__r.Name FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c IN: contactIds]){
                    if(!aQualMap.containsKey(aq.TR1__Contact__c)){
                        aQualMap.put(aq.TR1__Contact__c, new List<TR1__Associated_Qualification__c>());
                    }
                    aQualMap.get(aq.TR1__Contact__c).add(aq);
                }

                String text = System.Label.Template_Names;
                List<String> stList = text.split(';');
                for(Integer i=0; i<stList.size(); i++){
                    stList[i] = stList[i] + ' - signed.pdf';
                    System.debug( 'List String ['+i+'] -- '+ stList[i]);
                }

                for(echosign_dev1__SIGN_Agreement__c agr : newList){
                    if(contDocMap.get(agr.Id) != null){
                        for(ContentDocumentLink codl : contDocMap.get(agr.Id)){
                            if(aQualMap.get(agr.echosign_dev1__Recipient__c) != null){
                                if(codl.ContentDocument.Title == stList[0] || codl.ContentDocument.Title == stList[1] || codl.ContentDocument.Title == stList[4] || codl.ContentDocument.Title == stList[5]){
                                    for(TR1__Associated_Qualification__c aq : aQualMap.get(agr.echosign_dev1__Recipient__c)){
                                        if(aq.TR1__Qualification__r.Name == 'Terms and Registration Forms'){
                                            ContentDocumentLink cdlink = new ContentDocumentLink();
                                            cdlink.LinkedEntityId = aq.Id;
                                            cdlink.ContentDocumentId = codl.ContentDocumentId;
                                            newdocumentlink.add(cdlink);
                                            System.debug('Terms and Registration Forms -- '+codl.ContentDocument.Title);
                                        }
                                    }
                                }
                                if(codl.ContentDocument.Title == stList[3]){
                                    for(TR1__Associated_Qualification__c aq : aQualMap.get(agr.echosign_dev1__Recipient__c)){
                                        if(aq.TR1__Qualification__r.Name == 'References'){
                                            ContentDocumentLink cdlink = new ContentDocumentLink();
                                            cdlink.LinkedEntityId = aq.Id;
                                            cdlink.ContentDocumentId = codl.ContentDocumentId;
                                            newdocumentlink.add(cdlink);
                                            System.debug('References -- '+codl.ContentDocument.Title);
                                        }
                                    }
                                }
                                if(codl.ContentDocument.Title == stList[2]){
                                    for(TR1__Associated_Qualification__c aq : aQualMap.get(agr.echosign_dev1__Recipient__c)){
                                        if(aq.TR1__Qualification__r.Name == 'DBS'){
                                            ContentDocumentLink cdlink = new ContentDocumentLink();
                                            cdlink.LinkedEntityId = aq.Id;
                                            cdlink.ContentDocumentId = codl.ContentDocumentId;
                                            newdocumentlink.add(cdlink);
                                            System.debug('DBS -- '+codl.ContentDocument.Title);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //************ Below code is to update Contact data. ************//
            List<Contact> contactList = new List<Contact>();
            for(Contact con : [SELECT Id, Name, Enable_Community_User__c, Registration_Agreement_Names__c, Agreement_Sent__c, Compliance_Status__c FROM Contact WHERE Id IN: contUpIds]){
                if(con.Compliance_Status__c != 'Not Registered'){
                	con.Enable_Community_User__c = true;
            	}
                con.Agreement_Sent__c = true;
                String agrName = ofcAgreementList.get(con.Id);
                List<String> agrNameList = agrName.split('-');

                if(String.isNotBlank(con.Registration_Agreement_Names__c)){
                    String nameUpdate = con.Registration_Agreement_Names__c;
                    List<String> nameUpdateList = nameUpdate.split('\n');
                    System.debug('agrNameList[0] ---- '+agrNameList[0].removeEnd(' '));
                    System.debug('nameUpdateList ---- '+nameUpdateList);
                    Boolean checkbool = false;
                    for(String checkString : nameUpdateList){
                        System.debug('checkString --- '+checkString);
                        if(agrNameList[0].removeEnd(' ') == checkString){
                            checkbool = true;
                            break;
                        }else{
                            checkbool = false;
                        }
                    }
                    System.debug('checkbool --- '+checkbool);
                    if(!checkbool){
                        con.Registration_Agreement_Names__c = con.Registration_Agreement_Names__c + '\n' + agrNameList[0].removeEnd(' ');
                    }
                }else{
                    con.Registration_Agreement_Names__c = agrNameList[0].removeEnd(' ');
                }
                contactList.add(con);
            }
        
            if(!contactList.isEmpty()){
                update contactList;
                System.debug('Contact Updated.');
            }
            if(!newdocumentlink.isEmpty()){
                insert newdocumentlink;
                System.debug('Document Transferred.');
            }
        }catch(Exception e){
            System.debug('Error --- '+e.getMessage()+' --- '+e.getStackTraceString());
            // Added below Email send system whenever Exception throws...
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String toEmail = System.label.Exception_To_Email;
            List<String> toEmailAddress = new List<String>();
            if(toEmail.contains(',')){	toEmailAddress.addAll(toEmail.split(','));
            }else{
                toEmailAddress.add(toEmail);
            }
            
            email.setToAddresses(toEmailAddress);
            email.setSubject('Exception while Agreement Trigger runs | Supply Desk Project');

            String bodyText = 'Hi All, <br/><br/>This Email is due to Exception occured when Agreement Trigger runs. <br/>Below is the Exception details,<br/><br/>'+'Exception Cause ::: '+e.getCause()+'<br/>'+'Line Number ::: '+e.getLineNumber()+'<br/>'+'Exception Message ::: '+e.getMessage()+'<br/>'+'Stack Trace       ::: '+e.getStackTraceString()+'<br/>'+'Exception Type    ::: '+e.getTypeName()+'<br/>';

            email.setHtmlBody(bodyText);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }

    public String messageString(Contact contact, User usr) {
        String messageText = 'Dear '+contact.FirstName+', \n\n';
        messageText += 'Thank you for your time on the phone, I am delighted to confirm your registration interview with Supply Desk (details below). Please allow approximately 1 hour for your registration interview.'+'\n\n';
        messageText += 'Prior to your interview, it is essential that you read and complete our registration & application forms, Terms of Engagement, DBS, and safeguarding documents by clicking the link below and following all instructions.'+'\n\n';
        messageText += 'Please note: If you are unable to provide any of the information and/or documentation requested this may result in a delay in the clearance process.'+'\n\n';
        messageText += 'Interview Details:-'+'\n';
        messageText += 'Name of consultant: '+usr.Name+'\n';
        messageText += 'Date & Time: '+'\n';

        if(usr.Branch__c == 'Brighton Secondary'){
            messageText += 'Location: Unit 4, Hove Business Centre, Fonthill Road, Hove BN3 6HA'+'\n';
            messageText += 'Link to google maps: https://goo.gl/maps/x4FLoVJ5ABGUQDCA9 '+'\n';
        }else if(usr.Branch__c == 'Brighton Primary'){
            messageText += 'Location: Unit 4, Hove Business Centre, Fonthill Road, Hove BN3 6HA'+'\n';
            messageText += 'Link to google maps: https://goo.gl/maps/x4FLoVJ5ABGUQDCA9 '+'\n';
        }else if(usr.Branch__c == 'Southampton'){
            messageText += 'Location: Basepoint Enterprise Centre Andersons Rd, 27-28, Southampton SO14 5FE'+'\n';
            messageText += 'Link to google maps: https://www.google.co.uk/maps/place/Supply+Desk/@50.8991118,-1.3950685,17z/data=!3m1!4b1!4m5!3m4!1s0x48747135928e689d:0x13ebcfc3a365a4d3!8m2!3d50.8992127!4d-1.3928594 '+'\n';
        }else if(usr.Branch__c == 'Kent'){
            messageText += 'Location: River House, Stour Street, Canterbury, Kent, CT1 2NZ'+'\n';
            messageText += 'Link to google maps: https://goo.gl/maps/yFaJrRt63KirP3sk9 '+'\n';
        }else if(usr.Branch__c == 'Watford'){
            messageText += 'Location: Suite 3.3, 34 Clarendon Rd, Watford, Hertfordshire, WD17 1JJ'+'\n';
            messageText += 'Link to google maps: https://www.google.com/maps/place/34+Clarendon+Rd,+Watford/@51.6586006,-0.3987453,17z/data=!3m1!4b1!4m5!3m4!1s0x48766ac6d30f94cd:0x4912e021b5f22e0c!8m2!3d51.6585973!4d-0.3965566 '+'\n';
        }else if(usr.Branch__c == 'Manchester'){
            messageText += 'Location: 10th Floor, 3 Hardman Street, Spinningfields, Manchester, M3 3HF'+'\n';
            messageText += 'Link to google maps: https://goo.gl/maps/44ewxwCokM6t21Xk8 '+'\n';
        }else if(usr.Branch__c == 'Leeds'){
            messageText += 'Location: First Floor, 11 Park Square East, Leeds, LS1 2NG'+'\n';
            messageText += 'Link to google maps: https://www.google.com/maps/search/First+Floor,+11+Park+Square+East,+Leeds,+LS1+2NG/@53.7984902,-1.5531062,17z/data=!3m1!4b1 '+'\n';
        }else if(usr.Branch__c == 'Cardiff'){
            messageText += 'Location: Albion House, Oxford St, Taff\'s Well, Cardiff CF15 7TR'+'\n';
            messageText += 'Link to google maps: https://www.google.com/maps/search/albion+house+nantgarw+cf157tr '+'\n';
        }else {
            messageText += 'Location: '+'\n';
            messageText += 'Link to google maps:  '+'\n';
        }

        if(String.isNotBlank(usr.Branch_Phone__c)){
            messageText += 'Branch Tel. No.: '+usr.Branch_Phone__c+'\n';
        }else{
            messageText += 'Branch Tel. No.: \n';
        }

        if(String.isNotBlank(usr.Branch_Email__c)){
            messageText += 'Branch Email: '+usr.Branch_Email__c+' \n\n';
        }else{
            messageText += 'Branch Email: \n\n';
        }

        messageText += 'Yours sincerely,'+'\n';
        messageText += usr.Name+'\n';
        if(String.isNotBlank(usr.Title)){
            messageText += usr.Title+'\n';
        }
        if(String.isNotBlank(usr.Email)){
            messageText += 'e. '+usr.Email+'\n';
        }else{
            messageText += 'e. \n';
        }
        if(String.isNotBlank(usr.Branch_Phone__c)){
            messageText += 't. '+usr.Branch_Phone__c;
        }else {
            messageText += 't. ';
        }

        return messageText;
    }

    public String messageString1(Contact contact, User usr) {
        String messageText = 'Hi '+contact.Name+', \n\n';
        messageText += 'Please complete and sign the remaining compliance documents as discussed so we can get you compliant to teach in the UK. \n\n';
        messageText += 'Yours sincerely,'+'\n';
        messageText += usr.Name+'\n';
        if(String.isNotBlank(usr.Title)){
            messageText += usr.Title+'\n';
        }
        if(String.isNotBlank(usr.Email)){
            messageText += 'e. '+usr.Email+'\n';
        }else{
            messageText += 'e. \n';
        }
        if(String.isNotBlank(usr.Branch_Phone__c)){
            messageText += 't. '+usr.Branch_Phone__c;
        }else {
            messageText += 't. ';
        }

        return messageText;
    }
}