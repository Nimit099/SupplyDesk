public with sharing class CandidateAvailabilityTriggerHandler {
    
    List<Candidate_Availability__c> recordNewList = new List<Candidate_Availability__c>();
    List<Candidate_Availability__c> recordOldList = new List<Candidate_Availability__c>();
    Map<Id,Candidate_Availability__c> recordNewMap = new Map<Id,Candidate_Availability__c>();
    Map<Id,Candidate_Availability__c> recordOldMap = new Map<Id,Candidate_Availability__c>();
    
    public CandidateAvailabilityTriggerHandler(List<Candidate_Availability__c> recordNewList,List<Candidate_Availability__c> recordOldList,Map<Id,Candidate_Availability__c> recordNewMap,Map<Id,Candidate_Availability__c> recordOldMap){
        this.recordNewList = recordNewList;
        this.recordOldList = recordOldList;
        this.recordNewMap = recordNewMap;
        this.recordOldMap = recordOldMap;
    }
    
    
    public void onBeforeInsertEvents(){
        preventTimeOverlapingOnCandidateAvailability(); 
    }
    
    public void onBeforeUpdateEvents(){
        preventTimeOverlapingOnCandidateAvailability();
    }
    
    public void onBeforeDeleteEvents(){
        preventDeletionOfCandidateAvailability();
    }
    
    public void preventTimeOverlapingOnCandidateAvailability(){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> candidateAvailabilityIds = new Set<Id>();
        
        for(Candidate_Availability__c ca: recordNewList) {
            contactIds.add(ca.Candidate__c);
            candidateAvailabilityIds.add(ca.Id);
        }
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>([select Id, (Select Id, Name, Start_Date_Time__c, End_Date_Time__c from Candidate_Availabilitys__r where Start_Date_Time__c != null and End_Date_Time__c != null) from Contact where Id IN: contactIds]);                
        if(contactMap.isEmpty()) return;
        
        for(Candidate_Availability__c ca: recordNewList) {
            if(contactMap.get(ca.Candidate__c)==null) continue;
            for(Candidate_Availability__c caInner: contactMap.get(ca.Candidate__c).Candidate_Availabilitys__r){
                if(caInner.Id==ca.Id) continue;
                
                if(ca.Start_Date_Time__c <= caInner.Start_Date_Time__c){
                    if(ca.End_Date_Time__c <= caInner.Start_Date_Time__c){
                        continue;
                    }
                    else{
                        ca.addError('Overlapping Candidate Availability cannot be created. Existing Candidate Availability: '+caInner.Name);
                    }
                }
                else{
                    if(ca.Start_Date_Time__c >= caInner.End_Date_Time__c){
                        continue;
                    }
                    else{
                        ca.addError('Overlapping Candidate Availability cannot be created. Existing Candidate Availability: '+caInner.Name);
                    }
                }
            }
        }
    }
    
    public void preventDeletionOfCandidateAvailability(){
        
        Map<Id,Closing_Report_Schedule__c> candidateAvailityIdToCRSMap = new Map<Id,Closing_Report_Schedule__c>();
        
        for(Closing_Report_Schedule__c crs : [Select Id,Candidate_Availability__c,Name from Closing_Report_Schedule__c WHERE Status__c = 'Booked' AND Candidate_Availability__c IN :recordOldMap.keySet()]){
            candidateAvailityIdToCRSMap.put(crs.Candidate_Availability__c,crs);
        }
        
        for(Candidate_Availability__c ca : recordOldList){
            if(candidateAvailityIdToCRSMap.containsKey(recordOldMap.get(ca.id).id)){
                ca.addError('Candidate Availability cannot be deleted as there exist booking '+candidateAvailityIdToCRSMap.get(recordOldMap.get(ca.id).id).Name+' for it. Please delete Booking first');
            }
        }
    }
}