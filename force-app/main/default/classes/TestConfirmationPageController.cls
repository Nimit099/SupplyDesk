public with sharing class TestConfirmationPageController {
    
    public Id crId {get;set;}
    public String group1Id {get;set;}
    public date barredListDateChecked {get;set;}
    public date dbsIssueDate {get;set;}
    public String dbsDisclosureIdnumber {get;set;}
    public date dbsCheckedOnlineDate {get;set;}
    public boolean clearDbs {get;set;}
    public String nameOfcandidate {get;set;}
    public String nameOfclient {get;set;}
    public String prohibitionFromTeachingCheck {get;set;}
    public String nctlNumber {get;set;}
    public date nctlCheckedDate {get;set;}
    public date qtsAwardedDate {get;set;}
    public boolean nqtInductionComplete {get;set;}
    public date setCheckedDate {get;set;}
    public boolean qtls {get;set;}
    public String overseasChecksTab {get;set;}
    public String overseasPoliceCheck {get;set;}
    public boolean letterOfGoodConductReceived {get;set;}
    public String qualificationStatusActive {get;set;} // Enter YES if Qualification --Status = Active
    public String disqualification {get;set;}//[Yes/No] Disqualification by association check
    public Attachment personPlacedPhoto {get; set;}
    public String photoImgUrl {get; set;}
    
    public String Testval {get; set;}
    public String recordId {get; set;}

    public TestConfirmationPageController(ApexPages.StandardController sc){   
        try{ 
        
            // Testval = 'Page Loadedvaluepopopo';

            System.debug('recordId=>'+recordId);

    
        // url='https://' + headerdata+ urlvalue;

        crId = ApexPages.currentPage().getParameters().get('id');
        System.debug('crId==>'+crId);
        
        Map<string,TR1__Associated_Qualification__c> aqMap = new Map<string,TR1__Associated_Qualification__c>();
        
        if(String.isBlank(crId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Closing Report Id not found.'));
            return;
        }
        
        List<TR1__Closing_Report__c> crList = [SELECT Id, Name, TR1__Person_Placed__c, TR1__Account__r.Name FROM TR1__Closing_Report__c WHERE Id =:crId];
        
        if(crList.size()==0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Closing Report record not found.'));
            return;
        }
        
        List<contact> contactList = [SELECT Id, Name  FROM Contact WHERE Id= :crList[0].TR1__Person_Placed__c];
        
        if(contactList.size()==0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Contact record for person placed not found.'));
            return;
        }
        
        List<TR1__Associated_Qualification__c> aqList = [SELECT Id, Name, TR1__Contact__c,TR1__Qualification__r.Name, Group_1_ID_Type__c, Barred_List_Date_Checked__c, DBS_Date_of_Issue__c, DBS_Disclosure_ID_Number__c, 
                                                                DBS_Checked_Online__c, Clear_DBS__c, NCTL_Number__c, NCTL_Checked_Date__c, QTS_Awarded_Date__c, NQT_Induction_Complete__c, SET_Checked_Date__c,
                                                                QTLS__c, Overseas_Police_Check__c, Letter_of_Good_Conduct_Received__c,TR1__Status__c 
                                                         FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c = :contactList[0].Id]; 
        Id photoQualificationId = null;
        for(TR1__Associated_Qualification__c a : aqList ){
            AqMap.put(a.TR1__Qualification__r.Name,a );
            // to get photo qualification Id
            if(a.TR1__Qualification__r.Name == 'Photo' && a.TR1__Status__c != null  && a.TR1__Status__c != 'Requested')
                photoQualificationId = a.Id;
        }
        
        system.debug('========photoQualificationId========'+photoQualificationId);
        if(photoQualificationId != null ){
            
            ID personPlacedPhotoIdd = [SELECT Id,Name,parentId FROM Attachment WHERE parentId =: photoQualificationId LIMIT 1].Id;
            if(personPlacedPhotoIdd != null)
                photoImgUrl = '/servlet/servlet.FileDownload?file='+personPlacedPhotoIdd;
            else
                photoImgUrl = '';
        }
        else
            photoImgUrl = '';
            
        
        group1Id = aqMap.containsKey('DBS') ? aqMap.get('DBS').Group_1_ID_Type__c : '';      
        barredListDateChecked = aqMap.containsKey('Barred List') ? aqMap.get('Barred List').Barred_List_Date_Checked__c: date.TODAY();
        //dbsIssueDate= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').DBS_Date_of_Issue__c : date.TODAY();
        dbsDisclosureIdnumber= aqMap.containsKey('DBS') ? aqMap.get('DBS').DBS_Disclosure_ID_Number__c : '';
        //dbsCheckedOnlineDate= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').DBS_Checked_Online__c : date.TODAY();
        //clearDbs= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Clear_DBS__c : False;
        nameOfcandidate= contactList.size()>0 ? contactList[0].Name : '';
        nameOfclient= crList.size()>0 ? crList[0].TR1__Account__r.Name : '';
        //prohibitionFromTeachingCheck= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : ''; 
        nctlNumber= aqMap.containsKey('Overseas Teacher Qualifications') ? aqMap.get('Overseas Teacher Qualifications').NCTL_Number__c : '';
        //nctlCheckedDate= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').NCTL_Checked_Date__c : date.TODAY();
        qtsAwardedDate= aqMap.containsKey('Overseas Teacher Qualifications') ? aqMap.get('Overseas Teacher Qualifications').QTS_Awarded_Date__c : date.TODAY();
        //nqtInductionComplete= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').NQT_Induction_Complete__c : False;
        //setCheckedDate= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').SET_Checked_Date__c : date.TODAY();
        qtls= aqMap.containsKey('perm Qualification') ? aqMap.get('perm Qualification').QTLS__c : false;  
        //overseasChecksTab= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : '';  
        overseasPoliceCheck= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : '';
        letterOfGoodConductReceived= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Letter_of_Good_Conduct_Received__c : false;
        //qualificationStatusActive= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : '';
        //disqualification= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : '';
        }
        Catch(Exception e){
            system.debug('==================Exception==='+e.getMessage());
        }
    }
}