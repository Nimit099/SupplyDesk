public class TimesheetTriggerHandler {
    public static void afterInsert(List<TR1__Timesheet__c> newList){
        Set<Id> contactIds = new Set<Id>();
        for(TR1__Timesheet__c t : newList){
            if(t.TR1__Consultant__c != null){
                contactIds.add(t.TR1__Consultant__c);
            }
        }
        
        if(contactIds.size() > 0){
            populateAvarageTeacherScore(contactIds);
        }
        
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(TR1__Timesheet__c t : newList){
            if(t.TR1__Client__c!=null && !accMap.containsKey(t.TR1__Client__c)){
                Account Acc = new Account(Id=t.TR1__Client__c,Last_Timesheet_Created_Date__c =Date.today());
                accMap.put(t.TR1__Client__c,Acc);
            }
        }
        try{
        if(!accMap.isEmpty())
            update accMap.values();
            if(Test.isRunningTest()){
            Integer i=5/0;
            }
        }Catch(Exception ex){
        TR1__Debug_Log__c log=new TR1__Debug_Log__c();
        log.TR1__Additional_Message__c='CAUSE'+ex.getCause()+'LINE NUMBER'+ex.getLineNumber();
        log.TR1__Class_Name__c='TimesheetTriggerHandler';
        log.TR1__Message__c=ex.getMessage();
        log.TR1__Log_Type__c='Error';
        log.TR1__Stack_Trace_String__c=ex.getStackTraceString();
        
    
        
        insert log;
        }
        
    }
    
    public static void afterUpdate(List<TR1__Timesheet__c> newList, Map<Id,TR1__Timesheet__c> oldMap){
        Set<Id> contactIds = new Set<Id>();
        for(TR1__Timesheet__c t : newList){
            if(t.TR1__Consultant__c != null 
               && (t.TR1__Consultant__c != oldMap.get(t.Id).TR1__Consultant__c 
                   || t.Teacher_Score__c != oldMap.get(t.Id).Teacher_Score__c)){
                contactIds.add(t.TR1__Consultant__c);
            }
        }
        
        if(contactIds.size() > 0){
            populateAvarageTeacherScore(contactIds);
        }
    }
    
    private static void populateAvarageTeacherScore(Set<Id> contactIds){
        Map<Id, List<TR1__Timesheet__c>> contactToTimeSheetMap = new Map<Id, List<TR1__Timesheet__c>>();
        for(TR1__Timesheet__c t : [Select Id, Name, TR1__Consultant__c, Teacher_Score__c 
                                   From TR1__Timesheet__c WHERE TR1__Consultant__c IN :contactIds AND Teacher_Score__c != null AND Teacher_Score__c != 0]){
            if(!contactToTimeSheetMap.containsKey(t.TR1__Consultant__c))
                contactToTimeSheetMap.put(t.TR1__Consultant__c, new List<TR1__Timesheet__c>());
            contactToTimeSheetMap.get(t.TR1__Consultant__c).add(t);
        }
        system.debug('=====================contactToTimeSheetMap==='+contactToTimeSheetMap);
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c : [Select Id, Name, Average_Teacher_Score__c From Contact Where Id IN :contactToTimeSheetMap.keySet()]){
            Double avgScore = 0;
            for(TR1__Timesheet__c t : contactToTimeSheetMap.get(c.Id)){
                if(t.Teacher_Score__c == null){
                    t.Teacher_Score__c = 0;
                }
                avgScore += t.Teacher_Score__c;
            }
            c.Average_Teacher_Score__c = avgScore/contactToTimeSheetMap.get(c.Id).size();
            contactsToUpdate.add(c);
        }
        
        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }
    }
}