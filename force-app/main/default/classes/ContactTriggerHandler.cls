public class ContactTriggerHandler {
    
    List<contact> recordsNewList = new List<contact>();
    Map<Id,contact> recordsOldMap = new Map<Id,contact>();
    String toEmail = System.label.Exception_To_Email;
    List<String> toEmailAddress = new List<String>();
    
    public void ContactTriggerHandler(List<contact> recordsNewList, Map<Id,contact> recordsOldMap){        
        this.recordsNewList = recordsNewList;
        this.recordsOldMap = recordsOldMap;
        if(toEmail.contains(',')){  toEmailAddress.addAll(toEmail.split(','));
        }else{  toEmailAddress.add(toEmail);    }    
    }
    
    public void OnBeforeInsertEvent(){
        if(TR1__TalentRoverProperties__c.getOrgDefaults()!=null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Disable_Zipcode_Mapping__c){
            updateStateRegional(recordsNewList,recordsOldMap);
        }
        createGravityFormContacts(recordsNewList);
    } 

    public void OnBeforeUpdateEvent(){
        if(TR1__TalentRoverProperties__c.getOrgDefaults()!=null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Disable_Zipcode_Mapping__c){
            updateStateRegional(recordsNewList,recordsOldMap);
        }
        updateOnChngVettingQuestions(recordsNewList);
    }

    public void OnAfterInsertEvent(){
        CreateAvailability(true);
    } 
    
    public void OnAfterUpdateEvent(){
        CreateAvailability(false);
        updateSafeguardingConsent(recordsNewList);
    } 

    public static Boolean CountryPicklistenabled() {
        try
        {
            sObject testObject = new Contact();
            testObject.get( 'OtherCountryCode' );
            return true;
        }
        catch( Exception ex )
        {
            return false;
        }
    }

    public static void updateStateRegional(List<Contact> newContacts,Map<Id,Contact> oldContactMap){
        Set<String> zipcodes = new Set<String>();   
        Set<Id> usrIds = new Set<Id>();
        for(Contact con: newContacts)
        {
             if(con.OtherPostalCode != null && con.OtherPostalCode != '')
             {
                  zipcodes.add(con.OtherPostalCode);
                  if(con.OtherPostalCode.length()>=2){
                      zipcodes.add(con.OtherPostalCode.subString(0,2));
                  }
                  if(con.OtherPostalCode.length()>=3){
                      zipcodes.add(con.OtherPostalCode.subString(0,3));
                  }
                  if(con.OtherPostalCode.length()>=4){
                      zipcodes.add(con.OtherPostalCode.subString(0,4));
                  }
             }
             if(oldContactMap != null)
             {
                if(con.OwnerId != oldContactMap.get(con.Id).OwnerId )
                      usrIds.add(con.OwnerId);
             }
             else
                usrIds.add(con.OwnerId);    
        }
        Map<Id,User> usrMap = new Map<Id,User>([select id,Name from user where Id in :usrIds]);
        
        Map<String, TR1__Zip_Code_Mapping__c> zipmap = new Map<String, TR1__Zip_Code_Mapping__c>();     
        if(!zipcodes.isempty()){
            for(TR1__Zip_Code_Mapping__c zipregion: [SELECT Id,
                                                            Name,
                                                            TR1__Regional_Area__c,
                                                            TR1__State_Area__c 
                                                    FROM TR1__Zip_Code_Mapping__c 
                                                    where Name IN :zipcodes]){
                                                        
                    if(!zipmap.containsKey(zipregion.Name))
                        zipmap.put(zipregion.Name,zipregion);
            }
            
            for(Contact con: newContacts){
                if(con.OtherPostalCode != null ){
                    if(zipmap.containsKey(con.OtherPostalCode)  ){
                        con.TR1__Regional_Area__c = zipmap.get(con.OtherPostalCode).TR1__Regional_Area__c;
                        con.TR1__State_Area__c = zipmap.get(con.OtherPostalCode).TR1__State_Area__c;
                        if(CountryPicklistenabled()){
                            con.put('OtherCountryCode',Label.ZipCode_Country);
                        }else{
                            con.OtherCountry = Label.ZipCode_Country; 
                        }
                    }else if(con.OtherPostalCode.length()>=4 && zipmap.containsKey(con.OtherPostalCode.subString(0,4))){
                        con.TR1__Regional_Area__c = zipmap.get(con.OtherPostalCode.subString(0,4)).TR1__Regional_Area__c;
                        con.TR1__State_Area__c = zipmap.get(con.OtherPostalCode.subString(0,4)).TR1__State_Area__c;
                        if(CountryPicklistenabled()){
                            con.put('OtherCountryCode',Label.ZipCode_Country);
                        }else{
                            con.OtherCountry = Label.ZipCode_Country; 
                        }
                   }else if(con.OtherPostalCode.length()>=3 && zipmap.containsKey(con.OtherPostalCode.subString(0,3))){
                        con.TR1__Regional_Area__c = zipmap.get(con.OtherPostalCode.subString(0,3)).TR1__Regional_Area__c;
                        con.TR1__State_Area__c = zipmap.get(con.OtherPostalCode.subString(0,3)).TR1__State_Area__c;
                        if(CountryPicklistenabled()){
                            con.put('OtherCountryCode',Label.ZipCode_Country);
                        }else{
                            con.OtherCountry = Label.ZipCode_Country; 
                        }
                   }else if(con.OtherPostalCode.length()>=2 && zipmap.containsKey(con.OtherPostalCode.subString(0,2))){
                        con.TR1__Regional_Area__c = zipmap.get(con.OtherPostalCode.subString(0,2)).TR1__Regional_Area__c;
                        con.TR1__State_Area__c = zipmap.get(con.OtherPostalCode.subString(0,2)).TR1__State_Area__c;
                        if(CountryPicklistenabled()){
                            con.put('OtherCountryCode',Label.ZipCode_Country);
                        }else{
                            con.OtherCountry = Label.ZipCode_Country; 
                        }
                   }
                    
                }
               
               if(usrMap.containskey(con.OwnerId))
                {
                  con.TR1__Owner_Name__c = usrmap.get(con.OwnerId).Name;
                }
            }
        }
    }   
    
    public void CreateAvailability(Boolean isInsert){
        
        List<Contact> contactList = new List<Contact>();   
        Set<String> daySet = new Set<String>{'Monday','Tuesday','Wednesday','Thursday','Friday'};  //add Name of week day whose availabilty is to be created           
            
            
            if(isInsert){
            for(Contact con : recordsNewList){  
                
                if(con.Compliance_Status__c =='Cleared' || con.Compliance_Status__c == 'Clearance Pending' ) {
                  // &&(recordsOldMap.get(con.Id).Compliance_Status__c !='Cleared' && recordsOldMap.get(con.Id).Compliance_Status__c !='Clearance Pending')){            
                    contactList.add(con);
                }                
            }
            }
        else{
            for(Contact con : recordsNewList){  
                
                if((con.Compliance_Status__c =='Cleared' || con.Compliance_Status__c == 'Clearance Pending' ) &&(recordsOldMap.get(con.Id).Compliance_Status__c !='Cleared' && recordsOldMap.get(con.Id).Compliance_Status__c !='Clearance Pending')){            
                    contactList.add(con);
                }                
            } 
        }
        
        Map<Date, Candidate_Availability__c>  candidateAvailMap= new Map<Date,Candidate_Availability__c>();//Map will have CA that are already created for this contacts and have start dates greater than tomorrow date
        for(Candidate_Availability__c ca : [select Name, Id,Start_Date__c,Candidate__c from  Candidate_Availability__c where Candidate__c IN :contactList AND Start_Date__c > = :date.Today().addDays(1)]){
            candidateAvailMap.put(ca.Start_Date__c, ca);
        }    
        
        List<Candidate_Availability__c> candidateAvailablityToAdd = new List<Candidate_Availability__c>();//List of CA to be created 
        
        for(Contact con: contactList){            
            Date startDate = date.today().addDays(1);
            Date EndDate = startDate.AddDays(13);
            Integer actualNoOfDays = StartDate.daysBetween(EndDate);
            for(Integer i = 0; i <= actualNoOfDays; i++){    
                Date iterableDate = StartDate + i;
                DateTime DateValue = iterableDate;
                String selectedDay = DateValue.format('EEEE');                                        
                
                //check if there is already an Availability created for iterableDate and this contact
                if(!candidateAvailMap.containsKey(iterableDate)){
                     //check if daySet contains selectedDay
                    if(daySet.contains(selectedDay) ){
                        candidateAvailablityToAdd.add(
                            new Candidate_Availability__c(
                                Start_Date__c = iterableDate,
                                Start_Date_Time__c = formatDateTimefromDate(iterableDate,'08:30'),
                                Candidate__c = con.Id,
                                End_Date__c = iterableDate,
                                End_Date_Time__c = formatDateTimefromDate(iterableDate,'15:30'),
                                Type__c = 'Available'
                            )
                        );
                    }
                }
            }
            
        }
        
        if(candidateAvailablityToAdd.size()>0){
            insert candidateAvailablityToAdd;
        }
    }
    
    //Method to convert seperate date and string time into DateTime dataType
    DateTime formatDateTimefromDate(Date dateVar,String startTime){
        
        String startDateTime = dateVar.format();            
        String startTimeHour = startTime.split(':')[0];
        String startTimeMinute = startTime.split(':')[1].remove(' AM').remove(' PM');
        
        if (startTime.contains(' AM') && startTimeHour=='12') {
            startTimeHour = '00';
        }
        
        Datetime returnDt = Datetime.newInstance(
            dateVar.year(),
            dateVar.month(),
            dateVar.day(),
            Integer.valueOf(startTimeHour),
            Integer.valueOf(startTimeMinute),
            00
        );
        
        if (startTime.contains(' PM') && startTimeHour !='12') {
            
            returnDt = returnDt.addHours(12);
        }
        
        return returnDt;        
    }

    /***************************************************************************************
     * Description : Before Insert of Contact from Gravity Form it will assign Resourcer Owner to it.
     * Date        : 16 May 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void createGravityFormContacts(List<Contact> newContacts) { 
        System.debug('************************ In createGravityFormContacts Method ************************');
        for(Contact con : newContacts) {
            Id recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'UNKNOWN DO NOT DELETE'];
            User usr = [SELECT Id, Name FROM User WHERE Name = 'Katherine Gibson' LIMIT 1];
            Map<String, List<String>> OtherFieldsDataMap = new Map<String, List<String>>();

            if(!String.isBlank(con.Form_Map_Data__c) && con.Form_Map_Data__c.contains('GFormContact')){
                System.debug('In If condition');
                OtherFieldsDataMap = (Map<String, List<String>>)JSON.deserialize(con.Form_Map_Data__c, Map<String,List<String>>.class);

                if(OtherFieldsDataMap.get('GFormContact')[0] == 'UK_site') {
                    ukSiteGravityFormContact(recordtypeId, acc, OtherFieldsDataMap, con);
                }
                
                if(OtherFieldsDataMap.get('GFormContact')[0] == 'AUS_site') {
                    ausSiteGravityFormContact(usr, recordtypeId, acc, OtherFieldsDataMap, con);
                }

                if(OtherFieldsDataMap.get('GFormContact')[0] == 'CAN_site') {
                    canSiteGravityFormContact(usr, recordtypeId, acc, OtherFieldsDataMap, con);
                }
            }
        }
    }

    /***************************************************************************************
     * Description : Before Insert of Contact from Gravity Form (UK site) it will assign Resourcer Owner to it.
     * Date        : 16 May 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void ukSiteGravityFormContact(Id recordtypeId, Account acc, Map<String, List<String>> OtherFieldsDataMap, Contact con) {
        try{
            System.debug('************************ In ukSiteGravityFormContact Method ************************');
            // String str = System.label.Resourcer_Owner;
            // List<String> strlist = new List<String>();
            // strlist = str.split(',');
            Set<String> emailList = new Set<String>();
            List<SD_LEA_DivisionUsers__mdt> divUsers = SD_LEA_DivisionUsers__mdt.getall().values();
            for(Integer i=0; i<divUsers.size(); i++) {
                emailList.add(divUsers[i].Owner_Email__c);
            }
            Map<String, Id> usrMap = new Map<String, Id>();
            for(User usr : [SELECT Id, Email FROM User WHERE Email IN :emailList AND IsActive = True]) {
                System.debug('usrMap Email -- '+usr.Email);
                usrMap.put(usr.Email, usr.Id);
            }
            /**
             * 0 - leanne.clark@supplydesk.co.uk
             * 1 - rachel.marsden@supplydesk.co.uk
             * 2 - zaynah.desai@supplydesk.co.uk
             * 3 - Jennifer.Harrison@supplydesk.co.uk
             * 4 - errika.nikokavuras@supplydesk.co.uk
             * 5 - sam.wilkins@supplydesk.co.uk
             * 6 - rebecca.dorey@supplydesk.co.uk
             * 7 - errika.nikokuvarus@supplydesk.co.uk
             * 8 - charmian.burgess@supplydesk.co.uk
             */
            con.RecordTypeId = recordtypeId;
            con.AccountId = acc.Id;
            con.TR1__Client_Status__c = 'Not Applicable';
            con.TR1__Candidate_Status__c = 'Prospect';
            con.Resource_Status_Type__c	 = 'Awaiting Availability';
            con.Compliance_Status__c = 'Not Registered'; 

            /* Fields which will be populated using Map data */ /* START */
            // Qualification Field
            if(OtherFieldsDataMap.get('Qualification') != null) {
                List<String> qualList = OtherFieldsDataMap.get('Qualification');
                System.debug('qualList ---- '+qualList);
                for(Integer i=0; i<qualList.size(); i++) {
                    if(!String.isBlank(qualList[i].replace(';',''))) {
                        System.debug('qualList '+i+' -- '+qualList[i]);
                        List<String> qualValue = qualList[i].split(';');
                        System.debug('qualValue ---- '+qualValue[0]);
                        con.Qualificaitons__c = qualValue[0];
                    }
                }
            }

            // Years of Experience Field
            if(OtherFieldsDataMap.get('Years of Experience') != null) {
                List<String> yoeList = OtherFieldsDataMap.get('Years of Experience');
                System.debug('yoeList ---- '+yoeList);
                for(Integer i=0; i<yoeList.size(); i++) {
                    if(!String.isBlank(yoeList[i].replace(';',''))) {
                        System.debug('yoeList '+i+' -- '+yoeList[i]);
                        List<String> yoeValue = yoeList[i].split(';');
                        System.debug('yoeValue ---- '+yoeValue[0]);
                        con.Years_of_Experience__c = yoeValue[0];
                    }
                }
            }

            // Preferred LEA Field
            if(OtherFieldsDataMap.get('Preferred LEA') != null) {
                List<String> preLEAList = OtherFieldsDataMap.get('Preferred LEA');
                System.debug('preLEAList ---- '+preLEAList);
                for(Integer i=0; i<preLEAList.size(); i++) {
                    if(!String.isBlank(preLEAList[i].replace(';',''))) {
                        System.debug('preLEAList '+i+' -- '+preLEAList[i]);
                        List<String> preLEAValue = preLEAList[i].split(';');
                        System.debug('preLEAValue ---- '+preLEAValue[0]);
                        con.Preferred_LEA__c = preLEAValue[0];
                    }
                }
            }

            // Source Field
            if(OtherFieldsDataMap.get('Source') != null) {
                List<String> sourceList = OtherFieldsDataMap.get('Source');
                System.debug('sourceList ---- '+sourceList);
                for(Integer i=0; i<sourceList.size(); i++) {
                    if(!String.isBlank(sourceList[i].replace(';',''))) {
                        System.debug('sourceList '+i+' -- '+sourceList[i]);
                        List<String> sourceValue = sourceList[i].split(';');
                        System.debug('sourceValue ---- '+sourceValue[0]);
                        con.TR1__Source__c = sourceValue[0];
                    }
                }
            }

            // Time will Travel? Field
            if(OtherFieldsDataMap.get('Time will Travel') != null) {
                List<String> timeList = OtherFieldsDataMap.get('Time will Travel');
                System.debug('timeList ---- '+timeList);
                for(Integer i=0; i<timeList.size(); i++) {
                    if(!String.isBlank(timeList[i].replace(';',''))) {
                        System.debug('timeList '+i+' -- '+timeList[i]);
                        List<String> timeValue = timeList[i].split(';');
                        System.debug('timeValue ---- '+timeValue[0]);
                        con.Time_Will_Travel__c = '<'+timeValue[0];
                    }
                }
            }
            /* END */

            // Below whole Nested Ifelse conditions are for setting fields -- Resourcer Owner, Person Owner, Branch */ /* START */
            List<SD_LEA_DivisionUsers__mdt> leaList = new List<SD_LEA_DivisionUsers__mdt>();
            System.debug('con.LEA__c --> '+con.LEA__c);
            System.debug('con.Preferred_LEA__c --> '+con.Preferred_LEA__c);
            
            for(Integer i=0; i<divUsers.size(); i++) {
                if(divUsers[i].LEA__c == con.LEA__c) {
                    if(!String.isBlank(divUsers[i].PreferredLEA__c) && divUsers[i].PreferredLEA__c.contains(con.Preferred_LEA__c)) {
                        leaList.add(divUsers[i]);
                        System.debug(i+'-leaList --> '+divUsers[i]);
                    }
                }
            }
            
            if(leaList.size() == 0) {
                for(Integer i=0; i<divUsers.size(); i++) {
                    if(divUsers[i].LEA__c == con.LEA__c && String.isBlank(divUsers[i].PreferredLEA__c)) {
                        leaList.add(divUsers[i]);
                        System.debug(i+'---leaList --> '+divUsers[i]);
                    }
                }
            }
            
            if(leaList.size() > 0) {
                con.TR1__Secondary_Owner__c = usrMap.get(leaList[0].Owner_Email__c);
                con.OwnerId = usrMap.get(leaList[0].Owner_Email__c);
                con.Division__c = leaList[0].Division__c;
            }
            System.debug('con.TR1__Secondary_Owner__c --> '+con.TR1__Secondary_Owner__c);
            System.debug('con.OwnerId --> '+con.OwnerId);
            System.debug('con.Division__c --> '+con.Division__c);

            // if(con.LEA__c == 'North East' || con.LEA__c == 'West Midlands') {
            //     SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Other');
            //     con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //     con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     con.Division__c = 'Other';

            // }else if(con.LEA__c == 'Yorkshire & Humberside') {
            //     SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Leeds');
            //     con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //     con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     con.Division__c = 'Leeds';

            // }else if(con.LEA__c == 'North West') {
            //     SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Manchester');
            //     con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //     con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     con.Division__c = 'Manchester';

            // }else if(con.LEA__c == 'East Midlands') {
            //     /** Below code for setting up Resourcer Owner and Person Owner Field */
            //     if(con.Preferred_LEA__c == 'Derbyshire') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Manchester');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Manchester';
            //     }else if(con.Preferred_LEA__c == 'Northhamptonshire') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Buckinghamshire_Bedfordshire');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Buckinghamshire & Bedfordshire';
            //     }else {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Other');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Other';
            //     }

            // }else if(con.LEA__c == 'Eastern England') {
            //     if(con.Preferred_LEA__c == 'Cambridgeshire' || con.Preferred_LEA__c == 'City of Peterborough' || con.Preferred_LEA__c == 'Hertfordshire' || con.Preferred_LEA__c == 'Luton') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('North_London_Hertfordshire');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'North London & Hertfordshire';
                    
            //     }else if(con.Preferred_LEA__c == 'Essex' || con.Preferred_LEA__c == 'Norfolk' || con.Preferred_LEA__c == 'Southend' || con.Preferred_LEA__c == 'Suffolk' || con.Preferred_LEA__c == 'Thurrock') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('East_London_Essex');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'East London & Essex';
                    
            //     }else if(con.Preferred_LEA__c == 'Bedfordshire') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Buckinghamshire_Bedfordshire');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Buckinghamshire & Bedfordshire';

            //     }

            // }else if(con.LEA__c == 'Greater London') {
            //     /** Below code for setting up Resourcer Owner and Person Owner Field */
            //     con.Division__c = 'London';
            //     if(con.Preferred_LEA__c == 'Barking' || con.Preferred_LEA__c == 'Havering' || con.Preferred_LEA__c == 'Newham' || con.Preferred_LEA__c == 'Redbridge' || con.Preferred_LEA__c == 'Waltham Forest') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('East_London_Essex');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'East London & Essex';
            //     }else if(con.Preferred_LEA__c == 'Bexley' || con.Preferred_LEA__c == 'Bromley') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('London_2');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     }else if(con.Preferred_LEA__c == 'Sutton' || con.Preferred_LEA__c == 'Westminster') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('London_3');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     }else {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('London_1');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     }

            // }else if(con.LEA__c == 'South East England') {
            //     if(con.Preferred_LEA__c == 'Bracknell Forest' || con.Preferred_LEA__c == 'Buckinghamshire' || con.Preferred_LEA__c == 'Milton Keynes' || con.Preferred_LEA__c == 'Oxfordshire' || con.Preferred_LEA__c == 'Reading' || con.Preferred_LEA__c == 'Slough' || con.Preferred_LEA__c == 'West Berkshire' || con.Preferred_LEA__c == 'Windsor and Maidenhead' || con.Preferred_LEA__c == 'Wokingham') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Buckinghamshire_Bedfordshire');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Buckinghamshire & Bedfordshire';

            //     }else if(con.Preferred_LEA__c == 'Brighton and Hove' || con.Preferred_LEA__c == 'East Sussex' || con.Preferred_LEA__c == 'Surrey' || con.Preferred_LEA__c == 'West Sussex') {
            //         if(con.Year_Key_Stage__c.contains('EYFS') || con.Year_Key_Stage__c.contains('KS1') || con.Year_Key_Stage__c.contains('KS2')) {
            //             SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Brighton_Primary');
            //             con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //             con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //             con.Division__c = 'Brighton Primary';
            //         } else {
            //             SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Brighton_Secondary');
            //             con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //             con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //             con.Division__c = 'Brighton Secondary';
            //         }

            //     }else if(con.Preferred_LEA__c == 'Hampshire' || con.Preferred_LEA__c == 'Isle of Wight' || con.Preferred_LEA__c == 'Portsmouth' || con.Preferred_LEA__c == 'Southampton') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Southampton');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Southampton';

            //     }else if(con.Preferred_LEA__c == 'Kent' || con.Preferred_LEA__c == 'Medway') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Kent');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Kent';

            //     }

            // }else if(con.LEA__c == 'South West England') {
            //     /** Below code for setting up Resourcer Owner and Person Owner Field */
            //     if(con.Preferred_LEA__c == 'Bath and North East Somerset' || con.Preferred_LEA__c == 'Bournemouth' || con.Preferred_LEA__c == 'Dorset' || con.Preferred_LEA__c == 'Poole' || con.Preferred_LEA__c == 'Wiltshire') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Southampton');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Southampton';

            //     }else if(con.Preferred_LEA__c == 'City of Bristol' || con.Preferred_LEA__c == 'Gloustershire' || con.Preferred_LEA__c == 'South Gloustershire') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Cardiff');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Cardiff';

            //     }else if(con.Preferred_LEA__c == 'City of Plymouth' || con.Preferred_LEA__c == 'Cornwall' || con.Preferred_LEA__c == 'Devon' || con.Preferred_LEA__c == 'North Somerset' || con.Preferred_LEA__c == 'Somerset' || con.Preferred_LEA__c == 'Swindon' || con.Preferred_LEA__c == 'Torbay') {
            //         SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Other');
            //         con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //         con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //         con.Division__c = 'Other';

            //     }

            // }else if(con.LEA__c == 'Wales') {
            //     SD_DivisionUsersDetails__mdt divUser = SD_DivisionUsersDetails__mdt.getInstance('Cardiff');
            //     con.TR1__Secondary_Owner__c = usrMap.get(divUser.Owner_Email__c);
            //     con.OwnerId = usrMap.get(divUser.Owner_Email__c);
            //     con.Division__c = 'Cardiff';
                
            // }
            // /* END */

            // Below code for Setting Subject field based on Year/Key Stage field.
            if(con.Year_Key_Stage__c.contains('EYFS') && !con.Year_Key_Stage__c.contains('KS3/4') && !con.Year_Key_Stage__c.contains('KS5')) {
                con.Subject__c = 'All Primary';
            }else if(con.Year_Key_Stage__c.contains('KS1') && !con.Year_Key_Stage__c.contains('KS3/4') && !con.Year_Key_Stage__c.contains('KS5')) {
                con.Subject__c = 'All Primary';
            }else if(con.Year_Key_Stage__c.contains('KS2') && !con.Year_Key_Stage__c.contains('KS3/4') && !con.Year_Key_Stage__c.contains('KS5')) {
                con.Subject__c = 'All Primary';
            }

            //Below Code for Caution/Convictions field update due to the Gravity Form Question is diffrently asked and its vice versa.
            if(con.Cautions_Convictions_Candidate__c == 'Yes') {
                con.Cautions_Convictions_Candidate__c = 'No';
            } else if(con.Cautions_Convictions_Candidate__c == 'No') {
                con.Cautions_Convictions_Candidate__c = 'Yes';
            }

        }catch(Exception e) {
            System.debug('Exception :: In ukSiteGravityFormContact() Method :: ContactTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toEmailAddress);
            email.setSubject('Exception while Creating Contact From Gravity Form (UK Site) | Supply Desk Project');
            email.setHtmlBody('Hi All, <br/><br/>This Email is due to Exception occured on Creating Contact From Gravity Form (UK Site). <br/>Below is the Exception details,<br/><br/>'+'Exception Cause   ::: '+e.getCause()+'<br/>'+'Line Number       ::: '+e.getLineNumber()+'<br/>'+'Exception Message ::: '+e.getMessage()+'<br/>'+'Stack Trace       ::: '+e.getStackTraceString()+'<br/>'+'Exception Type    ::: '+e.getTypeName()+'<br/>');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }

    /***************************************************************************************
     * Description : Before Insert of Contact from Gravity Form (AUSTRALIA site) it will assign Resourcer Owner to it.
     * Date        : 16 May 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void ausSiteGravityFormContact(User usr, Id recordtypeId, Account acc, Map<String, List<String>> OtherFieldsDataMap, Contact con) {
        try{
            System.debug('************************ In ausSiteGravityFormContact Method ************************');
            con.TR1__Secondary_Owner__c = usr.Id;
            con.OwnerId = usr.Id;
            con.RecordTypeId = recordtypeId;
            con.Division__c = 'Aus-NZ';
            con.AccountId = acc.Id;
            con.TR1__Client_Status__c = 'Not Applicable';
            con.TR1__Candidate_Status__c = 'Prospect';
            con.Resource_Status_Type__c	 = 'No Verbal Contact';
            con.Compliance_Status__c = 'Not Registered';
            con.OS_Sourced__c = true;

            /* Fields which will be populated using Map data */ /* START */
            //Regional Area Field
            if(OtherFieldsDataMap.get('Regional Area') != null) {
                List<String> regAreaList = OtherFieldsDataMap.get('Regional Area');
                System.debug('regAreaList ---- '+regAreaList);
                for(Integer i=0; i<regAreaList.size(); i++) {
                    if(!String.isBlank(regAreaList[i].replace(';',''))) {
                        System.debug('regAreaList '+i+' -- '+regAreaList[i]);
                        List<String> regAreaValue = regAreaList[i].split(';');
                        System.debug('regAreaValue ---- '+regAreaValue[0]);
                        con.TR1__Regional_Area__c = regAreaValue[0];
                    }
                }
            }

            // Source Category Field
            if(OtherFieldsDataMap.get('Source Category') != null) {
                List<String> souCatList = OtherFieldsDataMap.get('Source Category');
                for(Integer i=0; i<souCatList.size(); i++) {
                    if(!String.isBlank(souCatList[i].replace(';',''))) {
                        List<String> souCatValue = souCatList[i].split(';');
                        if(souCatValue[0] == 'Email') {
                            con.Source_Category__c = 'Campaigns';
                            con.TR1__Source__c = 'Aus-Recycle';
                        }else if(souCatValue[0] == 'Event') {
                            con.Source_Category__c = souCatValue[0];
                            con.TR1__Source__c = 'Event';
                        }else if(souCatValue[0] == 'University') {
                            if(OtherFieldsDataMap.get('Source') != null) {
                                List<String> sourceList = OtherFieldsDataMap.get('Source');
                                for(Integer j=0; j<sourceList.size(); j++) {
                                    if(!String.isBlank(sourceList[j].replace(';',''))) {
                                        List<String> sourceValue = sourceList[j].split(';');
                                        if(sourceValue[0].contains('(NZ)') || sourceValue[0] == 'Auckland University' || sourceValue[0] == 'University of Canterbury (NZ)' || sourceValue[0] == 'University of Otago' || sourceValue[0] == 'University of Waikato' || sourceValue[0] == 'Victoria University (NZ)' ) {
                                            con.Source_Category__c = 'NZ-Uni';
                                            con.TR1__Source__c = sourceValue[0];
                                        }else {
                                            con.Source_Category__c = 'Aus-Uni';
                                            con.TR1__Source__c = sourceValue[0];
                                        }
                                    }
                                }
                            }
                        }else {
                            con.Source_Category__c = souCatValue[0];
                            if(OtherFieldsDataMap.get('Source') != null) {
                                List<String> sourceList = OtherFieldsDataMap.get('Source');
                                for(Integer j=0; j<sourceList.size(); j++) {
                                    if(!String.isBlank(sourceList[j].replace(';',''))) {
                                        List<String> sourceValue = sourceList[j].split(';');
                                        con.TR1__Source__c = sourceValue[0];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            /* END */

            if(!String.isBlank(String.valueOf(con.Job_Titles__c))) {
                List<String> jobRoles = new List<String>();
                jobRoles = con.Job_Titles__c.split(';');

                // Below code is for Candidate Type, Qualification, Year/Key Stage value
                if(jobRoles.contains('EYFS Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'EYFS';
                    con.Year_Key_Stage__c = 'EYFS';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Primary Teacher') && jobRoles.contains('Secondary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Primary & Secondary';
                    con.Year_Key_Stage__c = 'KS1;KS2;KS3/4';

                }else if(jobRoles.contains('Primary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Primary';
                    con.Year_Key_Stage__c = 'KS1;KS2';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Secondary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Secondary';
                    con.Year_Key_Stage__c = 'KS3/4;KS5';

                }else if(jobRoles.contains('Special Needs Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Special Needs';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('FE Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'FE';
                    con.Year_Key_Stage__c = 'KS5';

                }else if(jobRoles.contains('TA General')) {
                    con.Candidate_Type__c = 'Support Staff';
                    con.Qualificaitons__c = 'TA General';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Other')) {
                    con.Candidate_Type__c = 'Support Staff';
                    con.Qualificaitons__c = 'TA General';
                    con.Subject__c = 'All Primary';

                }
            }

            if(!String.isBlank(con.Alert__c)) {
                List<String> alertList = con.Alert__c.split(';;;');
                con.Alert__c = '<p><b>1. When are you thinking about heading to the UK?</b></p><p>Ans. '+(!String.isBlank(alertList[0]) ? alertList[0] : '-')+'</p><p><b>2. Do you have a question?</b></p><p>Ans. '+(alertList.size() == 2 ? alertList[1] : '-')+'</p>';
            }
        }catch(Exception e) {
            System.debug('Exception :: In ausSiteGravityFormContact() Method :: ContactTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toEmailAddress);
            email.setSubject('Exception while Creating Contact From Gravity Form (Australia Site) | Supply Desk Project');
            email.setHtmlBody('Hi All, <br/><br/>This Email is due to Exception occured on Creating Contact From Gravity Form (Australia Site). <br/>Below is the Exception details,<br/><br/>'+'Exception Cause   ::: '+e.getCause()+'<br/>'+'Line Number       ::: '+e.getLineNumber()+'<br/>'+'Exception Message ::: '+e.getMessage()+'<br/>'+'Stack Trace       ::: '+e.getStackTraceString()+'<br/>'+'Exception Type    ::: '+e.getTypeName()+'<br/>');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }

    /***************************************************************************************
     * Description : Before Insert of Contact from Gravity Form (CANADA site) it will assign Resourcer Owner to it.
     * Date        : 16 May 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void canSiteGravityFormContact(User usr, Id recordtypeId, Account acc, Map<String, List<String>> OtherFieldsDataMap, Contact con) {
        try{
            System.debug('************************ In canSiteGravityFormContact Method ************************');
            con.TR1__Secondary_Owner__c = usr.Id;
            con.OwnerId = usr.Id;
            con.RecordTypeId = recordtypeId;
            con.Division__c = 'Aus-NZ';
            con.AccountId = acc.Id;
            con.TR1__Client_Status__c = 'Not Applicable';
            con.TR1__Candidate_Status__c = 'Prospect';
            con.Resource_Status_Type__c	 = 'No Verbal Contact';
            con.Compliance_Status__c = 'Not Registered';
            con.OS_Sourced__c = true;

            /* Fields which will be populated using Map data */ /* START */
            // Source Category Field
            if(OtherFieldsDataMap.get('Source Category') != null) {
                List<String> souCatList = OtherFieldsDataMap.get('Source Category');
                for(Integer i=0; i<souCatList.size(); i++) {
                    if(!String.isBlank(souCatList[i].replace(';',''))) {
                        List<String> souCatValue = souCatList[i].split(';');
                        if(souCatValue[0] == 'Email') {
                            con.Source_Category__c = 'Campaigns';
                            con.TR1__Source__c = 'Can-Recycle';
                        }else if(souCatValue[0] == 'Event') {
                            con.Source_Category__c = souCatValue[0];
                            con.TR1__Source__c = 'Event';
                        }else if(souCatValue[0] == 'University') {
                            if(OtherFieldsDataMap.get('Source') != null) {
                                List<String> sourceList = OtherFieldsDataMap.get('Source');
                                for(Integer j=0; j<sourceList.size(); j++) {
                                    if(!String.isBlank(sourceList[j].replace(';',''))) {
                                        List<String> sourceValue = sourceList[j].split(';');
                                        con.Source_Category__c = 'Can-Uni';
                                        con.TR1__Source__c = sourceValue[0];
                                    }
                                }
                            }
                        }else {
                            con.Source_Category__c = souCatValue[0];
                            if(OtherFieldsDataMap.get('Source') != null) {
                                List<String> sourceList = OtherFieldsDataMap.get('Source');
                                for(Integer j=0; j<sourceList.size(); j++) {
                                    if(!String.isBlank(sourceList[j].replace(';',''))) {
                                        List<String> sourceValue = sourceList[j].split(';');
                                        con.TR1__Source__c = sourceValue[0];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            /* END */

            if(!String.isBlank(String.valueOf(con.Job_Titles__c))) {
                List<String> jobRoles = new List<String>();
                jobRoles = con.Job_Titles__c.split(';');

                // Below code is for Candidate Type, Qualification, Year/Key Stage value
                if(jobRoles.contains('EYFS Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'EYFS';
                    con.Year_Key_Stage__c = 'EYFS';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Primary Teacher') && jobRoles.contains('Secondary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Primary & Secondary';
                    con.Year_Key_Stage__c = 'KS1;KS2;KS3/4';

                }else if(jobRoles.contains('Primary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Primary';
                    con.Year_Key_Stage__c = 'KS1;KS2';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Secondary Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Secondary';
                    con.Year_Key_Stage__c = 'KS3/4;KS5';

                }else if(jobRoles.contains('Special Needs Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'Special Needs';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('FE Teacher')) {
                    con.Candidate_Type__c = 'Qualified Teacher';
                    con.Qualificaitons__c = 'FE';
                    con.Year_Key_Stage__c = 'KS5';

                }else if(jobRoles.contains('TA General')) {
                    con.Candidate_Type__c = 'Support Staff';
                    con.Qualificaitons__c = 'TA General';
                    con.Subject__c = 'All Primary';

                }else if(jobRoles.contains('Other')) {
                    con.Candidate_Type__c = 'Support Staff';
                    con.Qualificaitons__c = 'TA General';
                    con.Subject__c = 'All Primary';

                }
            }

            if(!String.isBlank(con.Alert__c)) {
                List<String> alertList = con.Alert__c.split(';;;');
                con.Alert__c = '<p><b>1. When are you thinking about heading to the UK?</b></p><p>Ans. '+(!String.isBlank(alertList[0]) ? alertList[0] : '-')+'</p><p><b>2. Please tell us about your experience.</b></p><p>Ans. '+(alertList.size() == 2 ? alertList[1] : '-')+'</p>';
            }
        }catch(Exception e) {
            System.debug('Exception :: In canSiteGravityFormContact() Method :: ContactTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toEmailAddress);
            email.setSubject('Exception while Creating Contact From Gravity Form (Canada Site) | Supply Desk Project');
            email.setHtmlBody('Hi All, <br/><br/>This Email is due to Exception occured on Creating Contact From Gravity Form (Canada Site). <br/>Below is the Exception details,<br/><br/>'+'Exception Cause   ::: '+e.getCause()+'<br/>'+'Line Number       ::: '+e.getLineNumber()+'<br/>'+'Exception Message ::: '+e.getMessage()+'<br/>'+'Stack Trace       ::: '+e.getStackTraceString()+'<br/>'+'Exception Type    ::: '+e.getTypeName()+'<br/>');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }

    /***************************************************************************************
     * Description : Before Update of Contact it will check Candidate and consultant Vetting Questions answers and update Candidate Status value accordingly.
     * Date        : 17 May 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void updateOnChngVettingQuestions(List<Contact> newContacts) {
        try{
            System.debug('************************ In updateOnChngVettingQuestions Method ************************');
            for(Contact con : newContacts) {
                if(con.Right_to_work_Candidate__c != null && con.Right_to_work__c != null) {
                    if(con.Right_to_work_Candidate__c == 'In progress' && con.Right_to_work__c == 'In progress') {
                        con.TR1__Candidate_Status__c = 'Investigate';
                        
                    }else if(con.Right_to_work_Candidate__c == 'No' && con.Right_to_work__c == 'In progress') {
                        con.TR1__Candidate_Status__c = 'Investigate';
                        
                    }else if(con.Right_to_work_Candidate__c == 'No' && con.Right_to_work__c == 'No') {
                        con.TR1__Candidate_Status__c = 'Reject';
                        
                    }else {
                        if(con.References_Candidate__c != null && con.References_not_agreed__c != null &&
                        con.Cautions_Convictions_Candidate__c != null && con.Cautions_Convictions__c != null &&
                        con.Disciplinary_Candidate__c != null && con.Disciplinary__c != null) {
                            System.debug('Inside If condition || No value equals to Null');
                            if (con.References_Candidate__c == 'Yes' && con.References_not_agreed__c == 'Yes' &&
                                con.Right_to_work_Candidate__c == 'Yes' && con.Right_to_work__c == 'Yes' &&
                                con.Cautions_Convictions_Candidate__c == 'No' && con.Cautions_Convictions__c == 'No' &&
                                con.Disciplinary_Candidate__c == 'No' && con.Disciplinary__c == 'No') {
                                    con.TR1__Candidate_Status__c = 'Vetted';
                            }else {
                                con.TR1__Candidate_Status__c = 'Investigate';
                            }
                        }
                    }
                }
                System.debug('Safeguarding_Training_Hidden__c-------> '+con.Safeguarding_Training_Hidden__c);
                System.debug('recordsOldMap - Safeguarding_Training_Hidden__c-------> '+recordsOldMap.get(con.Id).Safeguarding_Training_Hidden__c);
                if(con.Safeguarding_Training_Hidden__c.contains('GForm_Safeguarding') && recordsOldMap.get(con.Id).Safeguarding_Training_Hidden__c != null && recordsOldMap.get(con.Id).Safeguarding_Training_Hidden__c == 'Yes') {
                    con.Safeguarding_Training_Hidden__c = 'Yes';
                }
            }
        }catch(Exception e) {
            System.debug('Exception :: In updateOnChngVettingQuestions() Method :: ContactTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
        }

    }

    /***************************************************************************************
     * Description : Before Update of Contact it will check for Safeguarding and GDPR Consent from Gravity form.
     * Date        : 05 June 2022
     * Author      : Prakash Mewada (MV Clouds)
     ***************************************************************************************/
    public void updateSafeguardingConsent(List<Contact> newContacts) {
        try {
            System.debug('****************** In updateSafeguardingConsent ******************');
            Map<String, List<String>> OtherFieldsDataMap = new Map<String, List<String>>();

            Set<Id> conIds = new Set<Id>();
            Map<Id, List<TR1__Associated_Qualification__c>> conAQMap = new Map<Id, List<TR1__Associated_Qualification__c>>();
            List<TR1__Associated_Qualification__c> updateAQList = new List<TR1__Associated_Qualification__c>();
            for(Contact con : newContacts) {
                conIds.add(con.Id);
            }
            for(TR1__Associated_Qualification__c aq : [SELECT Id, Name, TR1__Contact__c, Safeguarding_Date_Completed__c, Safeguarding_Training__c, Consent_Received__c, TR1__Qualification__c, TR1__Qualification__r.Name FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c IN :conIds AND ( TR1__Qualification__r.Name Like '%Safeguarding%' OR TR1__Qualification__r.Name Like '%Terms and Registration Forms%' )]) {
                if(!conAQMap.containsKey(aq.TR1__Contact__c)) {
                    conAQMap.put(aq.TR1__Contact__c, new List<TR1__Associated_Qualification__c>());
                }
                conAQMap.get(aq.TR1__Contact__c).add(aq);
            }

            for(Contact con : newContacts) {
                if(!String.isBlank(con.Safeguarding_Training_Hidden__c) && con.Safeguarding_Training_Hidden__c.contains('GForm_Safeguarding')){
                    List<TR1__Associated_Qualification__c> aqList = new List<TR1__Associated_Qualification__c>();
                    if(conAQMap.get(con.Id) != null) {
                        aqList = conAQMap.get(con.Id);
                    }
                    for(TR1__Associated_Qualification__c aqRec : aqList) {
                        if(aqRec.TR1__Qualification__r.Name.contains('Safeguarding')) {
                            aqRec.Safeguarding_Date_Completed__c = Date.today();
                            aqRec.Safeguarding_Training__c = True;
                            aqRec.TR1__Status__c = 'Submitted';
                        }else if(aqRec.TR1__Qualification__r.Name.contains('Terms and Registration Forms')) {
                            aqRec.Consent_Received__c = Date.today();
                            aqRec.TR1__Status__c = 'Submitted';
                        }
                        updateAQList.add(aqRec);
                    }
                }
            }

            if(updateAQList.size() > 0) {
                update updateAQList;
            }
        }catch(Exception e) {
            System.debug('Exception :: In updateSafeguardingConsent() Method :: ContactTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
        }

    }
}