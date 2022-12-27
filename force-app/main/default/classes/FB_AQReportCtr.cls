public class FB_AQReportCtr {
    
    public transient List<AQWrapper> lstAQWrapper {get;set;}
    
    public List<TR1__Qualification__c> aqNames {get; set;}
    public Contact con {get;set;}
    public List<Contact> eligiblCandidates {get; set;}
    public Integer candidateCounts {get; set;}
    public Integer iStart {get; set;}
    public Integer pageSize {get; set;}
    public Boolean needToCallAgain {get; set;}
    public List<SelectOption> complianceStatusList {get;set;}
    public String[] selectedcmplianceStatus { get; set; }
   
    public FB_AQReportCtr(){
        try{
            con = new Contact();
            pageSize = 100;
            iStart = 0;
            needToCallAgain = true;
            candidateCounts = 0;
            aqNames = new List<TR1__Qualification__c>();
            eligiblCandidates = new List<Contact>();
            lstAQWrapper= new List<AQWrapper>();
            selectedcmplianceStatus = new List<String>();
            complianceStatusList = new List<SelectOption>();
            complianceStatusList.add(new SelectOption('Cleared','Cleared'));
            complianceStatusList.add(new SelectOption('Clearance Pending','Clearance Pending'));
            complianceStatusList.add(new SelectOption('Interview Complete','Interview Complete'));
            complianceStatusList.add(new SelectOption('Interview Complete Missing Docs','Interview Complete Missing Docs'));
            complianceStatusList.add(new SelectOption('Not Clear','Not Clear'));
            complianceStatusList.add(new SelectOption('Vet Complete','Vet Complete'));
            complianceStatusList.add(new SelectOption('Vet Perm','Vet Perm'));
            complianceStatusList.add(new SelectOption('Vet FLTP','Vet FLTP'));
        }catch(exception ex){
            Apexpages.addMessage(new Apexpages.message(Apexpages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public void doGenerate(){
        try{
            candidateCounts = 0;
			String soql = 'Select Id, Name, Compliance_Status__c, Compliance_Owner__c, Compliance_Owner__r.email FROM Contact Where RecordType.Name IN (\'Candidate\', \'C&C\')';
            System.debug('=============== Selected compliance status '+selectedcmplianceStatus );
            if(selectedcmplianceStatus != null && selectedcmplianceStatus.size() > 0){
                soql += ' AND Compliance_Status__c IN :selectedcmplianceStatus';
            }
			
            if(con.Division__c != null && con.Division__c != ''){
                String conDivision = con.Division__c;
                soql += ' AND Division__c =: conDivision';
            }

            if(con.Compliance_Owner__c != null){
                Id conComplianceOwner = con.Compliance_Owner__c;
                soql += ' AND Compliance_Owner__c =: conComplianceOwner';
            }
            
            if(con.OwnerId != null){
                Id conOwnerId = con.OwnerId;
                soql += ' AND OwnerId =: conOwnerId';
            }
            
            if(con.Placement_Start_Date__c != null){
                Date conDate = con.Placement_Start_Date__c;
                soql += ' AND Placement_Start_Date__c =: conDate';
            }
            
            if(con.TR1__Secondary_Owner__c != null){
                Id conSecondaryOwner = con.TR1__Secondary_Owner__c;
                soql += ' AND TR1__Secondary_Owner__c =: conSecondaryOwner';
            }
            
            soql += ' limit '+Label.FB_AQ_Report_Max_Contact_Limit;
            iStart = 0;
            System.debug('=============== SOQL '+SOQL);
            eligiblCandidates = (List<Contact>) database.query(soql);
            aqNames = new List<TR1__Qualification__c>([Select Id, Name, Abbreviation__c From TR1__Qualification__c Order By Abbreviation__c]);
            
            candidateCounts = eligiblCandidates.size();
            if(aqNames.size() == 0){
                candidateCounts = 0;
            }
            doGenerateContinuse();
        }catch(exception ex){
            Apexpages.addMessage(new Apexpages.message(Apexpages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public void doGenerateContinuse(){
        try{
            Integer tempIStart = null;
            if(Apexpages.currentPage().getParameters().containsKey('iStart')){
                System.debug('========= iStart :'+iStart);
            	tempIStart = Integer.valueOf(Apexpages.currentPage().getParameters().get('iStart'));
            }
            if(tempIStart == null || (tempIStart != iStart && tempIStart > iStart)){
                if(tempIStart != null){
                    iStart = tempIStart;
                }
                Map<Id, AQWrapper> aqwMap = new Map<Id, AQWrapper>();
                Map<Id,Contact> mapContactRecord = new Map<Id,Contact>();
                Integer tempStart = iStart;
                Integer tempEnd = tempStart + pageSize;
                if(tempEnd >= (candidateCounts-1)){
                    tempEnd = (candidateCounts-1);
                    needToCallAgain = false;
                }else{
                    needToCallAgain = true;
                }
                
                while(tempStart <= tempEnd){
                    mapContactRecord.put(eligiblCandidates.get(tempStart).id,eligiblCandidates.get(tempStart));
                    tempStart++;
                }
    
                Map<String,TR1__Associated_Qualification__c> mapAQ = new Map<String,TR1__Associated_Qualification__c>();
                for(TR1__Associated_Qualification__c aq : [Select Id, Name, TR1__Contact__c,TR1__Qualification__c,TR1__Qualification__r.Name,TR1__Qualification__r.Abbreviation__c,
                                                           TR1__Contact__r.Compliance_Owner__r.email,TR1__Status__c, ComplianceStatus__c from TR1__Associated_Qualification__c 
                                                           Where TR1__Contact__c IN : mapContactRecord.KeySet()]){
                    System.debug('=============== aq '+aq);
					if(!aqwMap.containsKey(aq.TR1__Contact__c)){
                        aqwMap.put(aq.TR1__Contact__c, new AQWrapper(mapContactRecord.get(aq.TR1__Contact__c), aqNames));
                    }
                    aqwMap.get(aq.TR1__Contact__c).mapAssociateQalification.put(aq.TR1__Qualification__r.Abbreviation__c, aq.ComplianceStatus__c);
                }
                lstAQWrapper = aqwMap.values();
                System.debug('=============== lstAQWrapper '+lstAQWrapper);
            }
        }catch(exception ex){
            Apexpages.addMessage(new Apexpages.message(Apexpages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public class AQWrapper{
        public String candidateId {get;set;}
        public String candidateName {get;set;}
        public String complianceStatus {get;set;}
        public String complianceOwnerEmail {get;set;}
        public Map<String, String> mapAssociateQalification {get;set;}
        public AQWrapper(Contact cont, List<TR1__Qualification__c> qNames){
            this.candidateId = cont.Id;
            this.candidateName = cont.Name;
            this.complianceStatus = cont.Compliance_Status__c;
            this.complianceOwnerEmail = cont.Compliance_Owner__r.email;
            this.mapAssociateQalification = new Map<String, String>();
            for(TR1__Qualification__c q : qNames){
                this.mapAssociateQalification.put(q.Abbreviation__c,'');
            }
        }
    }
}