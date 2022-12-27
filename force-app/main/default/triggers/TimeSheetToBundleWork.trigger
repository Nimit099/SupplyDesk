/************************************************************************************************************************
Trigger Name:          TimeSheetToBundleWork 
Object:                TR1__Timesheet__c 
Events:                after update
Created By:            bverma@talentrover.com
Created Date:          14th Sept, 2016  
Description:           This trigger is responsible to create new Bundle Work Detail on TimeSheet Approval
************************************************************************************************************************/
trigger TimeSheetToBundleWork on TR1__Timesheet__c (after update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        Set<Id> approvedTimeheetIds = new Set<Id>();
        for(TR1__Timesheet__c t : trigger.new){
            if(t.TR1__Status__c != trigger.oldMap.get(t.Id).TR1__Status__c && t.TR1__Status__c == 'Approved'){
                approvedTimeheetIds.add(t.Id);
            }
        }
        
        if(approvedTimeheetIds.size() > 0){
            List<TR1__Timesheet__c> approvedTimesheets = new List<TR1__Timesheet__c>([Select Id, Name, TR1__Total_Days_Worked__c, TR1__Job_Order__c, 
                    TR1__Job_Order__r.Active_Bundle__c, TR1__Job_Order__r.Active_Bundle__r.Total_Remaining_Days__c,Total_Days__c, Total_Half_Days__c, TR1__Total_Regular_Hours__c 
                From TR1__Timesheet__c Where Id IN :approvedTimeheetIds AND TR1__Job_Order__c != null AND TR1__Job_Order__r.Active_Bundle__c != null]);
            List<Bundle_Work__c> bundleWorkToCreate = new List<Bundle_Work__c>();
            Map<String, Decimal> daysGoingToBeDebited = new Map<String, Decimal>();
            
            for(TR1__Timesheet__c t : approvedTimesheets){
                if(t.TR1__Job_Order__c != null && t.TR1__Job_Order__r.Active_Bundle__c != null){
                    if(!daysGoingToBeDebited.containsKey(t.TR1__Job_Order__r.Active_Bundle__c)){
                        daysGoingToBeDebited.put(t.TR1__Job_Order__r.Active_Bundle__c, 0);
                    }
                    daysGoingToBeDebited.put(t.TR1__Job_Order__r.Active_Bundle__c, 
                        daysGoingToBeDebited.get(t.TR1__Job_Order__r.Active_Bundle__c)+t.TR1__Total_Days_Worked__c);
                    
                    if(daysGoingToBeDebited.get(t.TR1__Job_Order__r.Active_Bundle__c) > t.TR1__Job_Order__r.Active_Bundle__r.Total_Remaining_Days__c){
                        trigger.new.get(0).addError('Current Active Bundle don\'t have sufficient balance');
                    }
                }
            }
                
            for(TR1__Timesheet__c t : approvedTimesheets){
                if(t.TR1__Job_Order__c != null
                    && t.TR1__Job_Order__r.Active_Bundle__c != null){
                    Bundle_Work__c bw = new Bundle_Work__c();
                    bw.Bundle__c = t.TR1__Job_Order__r.Active_Bundle__c;
                    bw.Timesheet__c = t.Id;
                    bw.External_Id__c = t.Id;
                    bw.Time_Spent_in_Days__c = t.Total_Days__c + t.Total_Half_Days__c/2 ; //+ t.TR1__Total_Regular_Hours__c/8; //t.TR1__Total_Days_Worked__c;
                    bundleWorkToCreate.add(bw);
                }
            }
            
            if(bundleWorkToCreate.size() > 0){
                upsert bundleWorkToCreate External_Id__c;
            }
        }
    }
}