public with sharing class VacancyD2DTriggerHandler {
    
    List<Vacancy_D2D__c> recordNewList = new List<Vacancy_D2D__c>();
    List<Vacancy_D2D__c> recordOldList = new List<Vacancy_D2D__c>();
    Map<Id,Vacancy_D2D__c> recordNewMap = new Map<Id,Vacancy_D2D__c>();
    Map<Id,Vacancy_D2D__c> recordOldMap = new Map<Id,Vacancy_D2D__c>();
    
    public VacancyD2DTriggerHandler(List<Vacancy_D2D__c> recordNewList,List<Vacancy_D2D__c> recordOldList,Map<Id,Vacancy_D2D__c> recordNewMap,Map<Id,Vacancy_D2D__c> recordOldMap){
        this.recordNewList = recordNewList;
        this.recordOldList = recordOldList;
        this.recordNewMap = recordNewMap;
        this.recordOldMap = recordOldMap;
    }
    
    public void onBeforeInsertEvents(){
        
        preventTimeOverlapingOnVacancySchedule();
    }
    
    public void onBeforeUpdateEvents(){
        
        preventTimeOverlapingOnVacancySchedule();
    }
    
    public void onBeforeDeleteEvents(){
        preventDeletionOfVacancySchedule();
    }
    
    
    
    public void preventTimeOverlapingOnVacancySchedule(){
        Set<Id> vacancyIds = new Set<Id>();
        
        for(Vacancy_D2D__c vs: recordNewList) {
            vacancyIds.add(vs.Vacancy__c);
            
        }
        
        Map<Id,TR1__Job__c> contactMap = new Map<Id,TR1__Job__c>([select Id, (Select Id, Name, Start_Date_Time__c, End_Date_Time__c from Vacancy_D2Ds__r where Start_Date_Time__c != null and End_Date_Time__c != null) from TR1__Job__c where Id IN: vacancyIds]);                
        if(contactMap.isEmpty()) return;
        
        for(Vacancy_D2D__c vs: recordNewList) {
            for(Vacancy_D2D__c vsExisting: contactMap.get(vs.Vacancy__c).Vacancy_D2Ds__r){
                if(vsExisting.Id==vs.Id) continue;
                
                if(vs.Start_Date_Time__c <= vsExisting.Start_Date_Time__c){
                    if(vs.End_Date_Time__c <= vsExisting.Start_Date_Time__c){
                        continue;
                    }
                    else{
                        vs.addError('Overlapping Vacancy Schedule cannot be created. Existing Vacancy Schedule: '+vsExisting.Name);
                    }
                }
                else{
                    if(vs.Start_Date_Time__c > vsExisting.End_Date_Time__c){
                        continue;
                    }
                    else{
                        vs.addError('Overlapping Vacancy Schedule cannot be created. Existing Vacancy Schedule: '+vsExisting.Name);
                    }
                }
            }
        }
    }
    
    public void preventDeletionOfVacancySchedule(){
        
        Map<Id,Closing_Report_Schedule__c> vacancyD2DIdToCRSMap = new Map<Id,Closing_Report_Schedule__c>();
        
        for(Closing_Report_Schedule__c crs : [Select Id,Vacancy_Schedule__c,Name from Closing_Report_Schedule__c WHERE Status__c = 'Booked' AND Vacancy_Schedule__c IN :recordOldMap.keySet()]){
            vacancyD2DIdToCRSMap.put(crs.Vacancy_Schedule__c,crs);
        }
        
        for(Vacancy_D2D__c vs : recordOldList){
            if(vacancyD2DIdToCRSMap.containsKey(recordOldMap.get(vs.id).id)){
                vs.addError('Vacancy Schedule cannot be deleted as there exist booking '+vacancyD2DIdToCRSMap.get(recordOldMap.get(vs.id).id).Name+' for it. Please delete Booking first');
            }
        }
    }
}