public class ConfirmationLetterPDFController {
    
    public Id crId {get;set;}
    public String group1Id {get;set;}
    public date barredListDateChecked {get;set;}
    public String dbsDisclosureIdnumber {get;set;}
    public date dbsCheckedOnlineDate {get;set;}
    public boolean clearDbs {get;set;}
    
    public String prohibitionFromTeachingCheck {get;set;}
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
    
    public String nameOfcandidate {get;set;} 
    public String nameOfclient {get;set;}   
    public String photoImgUrl {get; set;}
    public String hmName {get; set;}
    public String docChecked1 {get; set;}
    public String docChecked2A {get; set;}
    public String docChecked2B {get; set;}
    public datetime cteatedate {get; set;}
    public datetime birthdate {get; set;}
    public datetime barredate {get; set;}
    public datetime EWCrdate {get; set;}
    public datetime EWCrcdate {get; set;}
    public datetime DBSissuedate {get; set;}
    public datetime DBSlastcheckeddate {get; set;}
    public datetime RTWdate {get; set;}
    public datetime SETcheckedate {get; set;}
    public datetime NCTLchecked {get; set;}
    public datetime QTSawarded {get; set;}
    public datetime group1doc {get; set;}
    public datetime ProhibitionOrder {get; set;}
    public datetime NQTinductiondate {get; set;}
    public datetime OPCdate {get; set;}
    public datetime QualCopies {get; set;}
    public datetime registrationform {get; set;}

    public String DBSdiscloseredate {get; set;}
    public String DBSclear {get; set;}
    public String ownername {get; set;}
    public String branch {get; set;}
    public String jobtitle {get; set;}
    public String training {get; set;}
    public String DBAchecked {get; set;}
    public String Qualification {get; set;}
    public String policeCheck {get; set;}
    public String latterofgood {get; set;}
    public String QTLShidden {get; set;}
    public String NumberHidden {get; set;}
    public String NCTLnumber {get; set;}
    public String NQTinduction {get; set;}
    public String clearBarred {get; set;}
    public String QualificationVerified {get; set;}

    public ConfirmationLetterPDFController(ApexPages.StandardController sc){   
        try{ 
            
            crId = ApexPages.currentPage().getParameters().get('Id');
            
            Map<string,TR1__Associated_Qualification__c> aqMap = new Map<string,TR1__Associated_Qualification__c>();
            
            if(String.isBlank(crId)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Closing Report Id not found.'));
                return;
            }
            
            List<TR1__Closing_Report__c> crList = [SELECT Id, Name, TR1__Person_Placed__c, TR1__Person_Placed__r.FirstName, TR1__Account__r.Name,CreatedDate
                                                            ,Hiring_Manager__r.FirstName,TR1__Person_Placed__r.Date_of_Birth__c, TR1__Person_Placed__r.Group_1_ID_Type_Hidden__c, 
                                                            TR1__Person_Placed__r.Group_2A_ID_Type_Hidden__c, TR1__Person_Placed__r.Group_2B_ID_Type_Hidden__c, 
                                                            TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c, TR1__Person_Placed__r.EWC_Registration_Date_Hidden__c, 
                                                            TR1__Person_Placed__r.EWC_Registration_Checked_Date_Hidden__c, TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c, 
                                                            TR1__Person_Placed__r.DBS_Disclosure_ID_Number_Hidden__c, TR1__Person_Placed__r.DBS_Last_Checked_Date_Hidden__c, 
                                                            TR1__Person_Placed__r.Clear_DBS_Hidden__c,TR1__Job__r.Owner.Name, TR1__Job__r.Branch__c, Job_Title__c, TR1__Person_Placed__r.Safeguarding_Training_Hidden__c,
                                                            TR1__Person_Placed__r.DBA_Check_Hidden__c,TR1__Person_Placed__r.Right_to_Work_Sited_Date_Hidden__c, TR1__Person_Placed__r.Qualifications_Hidden__c, 
                                                            TR1__Person_Placed__r.OS_Police_Check_Hidden__c, TR1__Person_Placed__r.Letter_of_Good_Conduct_Hidden__c, 
                                                            TR1__Person_Placed__r.QTLS_Hidden__c, TR1__Person_Placed__r.SET_Checked_Date_Hidden__c, TR1__Person_Placed__r.SET_Number_Hidden__c,
                                                            TR1__Person_Placed__r.NCTL_Number_Hidden__c,TR1__Person_Placed__r.NCTL_Checked_Date_Hidden__c, TR1__Person_Placed__r.QTS_Awarded_Date_Hidden__c, 
                                                            TR1__Person_Placed__r.NQT_Induction_Complete_Hidden__c, TR1__Person_Placed__r.Group1_doc_date_sighted_Hidden__c, TR1__Person_Placed__r.Clear_Barred_List_Check_Hidden__c,
                                                            TR1__Person_Placed__r.Prohibition_Order_Hidden__c,TR1__Person_Placed__r.NQT_Induction_Completed_Date_Hidden__c, TR1__Person_Placed__r.overseas_police_check_Hidden__c,
                                                            TR1__Person_Placed__r.Qualification_Verified_Hidden__c, TR1__Person_Placed__r.Qual_copies_received_date_Hidden__c, TR1__Person_Placed__r.Registration_Form_Received_Hidden__c  FROM TR1__Closing_Report__c WHERE Id =:crId];
            
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
                if(a.TR1__Qualification__r.Name == 'Photo' && a.TR1__Status__c != null  && a.TR1__Status__c != 'Requested')
                    photoQualificationId = a.Id;
            }
            
            if(photoQualificationId != null ){
                ID personPlacedPhotoIdd = [SELECT Id,Name,parentId FROM Attachment WHERE parentId =: photoQualificationId LIMIT 1].Id;
                if(personPlacedPhotoIdd != null)
                    photoImgUrl = '/servlet/servlet.FileDownload?file='+personPlacedPhotoIdd;
                else
                    photoImgUrl = '';
            }
            else{
                photoImgUrl = '';
            }
                
            
            group1Id = aqMap.containsKey('DBS') ? aqMap.get('DBS').Group_1_ID_Type__c : '';      
            barredListDateChecked = aqMap.containsKey('Barred List') ? aqMap.get('Barred List').Barred_List_Date_Checked__c: date.TODAY();
            dbsDisclosureIdnumber= aqMap.containsKey('DBS') ? aqMap.get('DBS').DBS_Disclosure_ID_Number__c : '';
            nameOfcandidate= contactList.size()>0 ? contactList[0].Name : '';
            nameOfclient= crList.size()>0 ? crList[0].TR1__Account__r.Name : '';
            nctlNumber= aqMap.containsKey('Overseas Teacher Qualifications') ? aqMap.get('Overseas Teacher Qualifications').NCTL_Number__c : '';
            qtsAwardedDate= aqMap.containsKey('Overseas Teacher Qualifications') ? aqMap.get('Overseas Teacher Qualifications').QTS_Awarded_Date__c : date.TODAY();
            qtls= aqMap.containsKey('perm Qualification') ? aqMap.get('perm Qualification').QTLS__c : false;
            overseasPoliceCheck= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Overseas_Police_Check__c : '';
            letterOfGoodConductReceived= aqMap.containsKey('Overseas Police Check') ? aqMap.get('Overseas Police Check').Letter_of_Good_Conduct_Received__c : false;

            cteatedate = crList[0].CreatedDate;
            birthdate = crList[0].TR1__Person_Placed__r.Date_of_Birth__c;
            barredate = crList[0].TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c;
            EWCrdate = crList[0].TR1__Person_Placed__r.EWC_Registration_Date_Hidden__c;
            EWCrcdate = crList[0].TR1__Person_Placed__r.EWC_Registration_Checked_Date_Hidden__c;
            DBSissuedate = crList[0].TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c;
            DBSdiscloseredate = crList[0].TR1__Person_Placed__r.DBS_Disclosure_ID_Number_Hidden__c;
            DBSlastcheckeddate = crList[0].TR1__Person_Placed__r.DBS_Last_Checked_Date_Hidden__c;
            RTWdate = crList[0].TR1__Person_Placed__r.Right_to_Work_Sited_Date_Hidden__c;
            SETcheckedate = crList[0].TR1__Person_Placed__r.SET_Checked_Date_Hidden__c;
            QTSawarded = crList[0].TR1__Person_Placed__r.QTS_Awarded_Date_Hidden__c;
            NCTLchecked = crList[0].TR1__Person_Placed__r.NCTL_Checked_Date_Hidden__c;
            group1doc = crList[0].TR1__Person_Placed__r.Group1_doc_date_sighted_Hidden__c;
            ProhibitionOrder = crList[0].TR1__Person_Placed__r.Prohibition_Order_Hidden__c;
            NQTinductiondate = crList[0].TR1__Person_Placed__r.NQT_Induction_Completed_Date_Hidden__c;
            OPCdate = crList[0].TR1__Person_Placed__r.overseas_police_check_Hidden__c;
            QualCopies = crList[0].TR1__Person_Placed__r.Qual_copies_received_date_Hidden__c;
            registrationform = crList[0].TR1__Person_Placed__r.Registration_Form_Received_Hidden__c;

            hmName = crList.size()>0 ? crList[0].Hiring_Manager__r.FirstName : '';
            docChecked1 = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Group_1_ID_Type_Hidden__c : '';
            docChecked2A = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Group_2A_ID_Type_Hidden__c : '';
            docChecked2B = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Group_2B_ID_Type_Hidden__c : '';
            DBSclear = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Clear_DBS_Hidden__c : '';
            branch = crList.size()>0 ? crList[0].TR1__Job__r.Branch__c : '';
            ownername = crList.size()>0 ? crList[0].TR1__Job__r.Owner.Name : '';
            jobtitle = crList.size()>0 ? crList[0].Job_Title__c : '';
            training = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Safeguarding_Training_Hidden__c : '';
            DBAchecked = crList.size()>0 ? crList[0].TR1__Person_Placed__r.DBA_Check_Hidden__c : '';
            Qualification = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Qualifications_Hidden__c : '';
            latterofgood = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Letter_of_Good_Conduct_Hidden__c : '';
            policeCheck = crList.size()>0 ? crList[0].TR1__Person_Placed__r.OS_Police_Check_Hidden__c : '';
            NumberHidden = crList.size()>0 ? crList[0].TR1__Person_Placed__r.SET_Number_Hidden__c : '';
            QTLShidden = crList.size()>0 ? crList[0].TR1__Person_Placed__r.QTLS_Hidden__c : '';
            NQTinduction = crList.size()>0 ? crList[0].TR1__Person_Placed__r.NQT_Induction_Complete_Hidden__c : '';
            NCTLnumber = crList.size()>0 ? crList[0].TR1__Person_Placed__r.NCTL_Number_Hidden__c : '';
            clearBarred = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Clear_Barred_List_Check_Hidden__c : '';
            QualificationVerified = crList.size()>0 ? crList[0].TR1__Person_Placed__r.Qualification_Verified_Hidden__c : '';
        }
        Catch(Exception e){
            System.debug(e);
            GenericException Exp = ExceptionHandler.logException(e, 'ConfirmationLetterPDFController', 'ConfirmationLetterPDFController');
        }
    }
}