/************************************************************************************************************************
Trigger Name:          BundleJobJunctionTrigger
Object:                Bundle_Job_Junction__c
Events:                after insert, after update
Created By:            bverma@talentrover.com
Created Date:          14th Sept, 2016  
Description:           This trigger will ensure that we can have at max one active bundle on Jobs
                       And also populate current active bundle on Job
************************************************************************************************************************/
trigger BundleJobJunctionTrigger on Bundle_Job_Junction__c (after insert, after update) {
    Set<Id> jobIds = new Set<Id>();
    Map<Id, List<Bundle__c>> activeBundlesPerJob = new Map<Id, List<Bundle__c>>();
    for(Bundle_Job_Junction__c ob : trigger.new){
        if(ob.Job__c != null){
            jobIds.add(ob.Job__c);
        }
    }
    
    for(Bundle_Job_Junction__c ob : [SELECT Id, Bundle__c, Bundle__r.Id, Bundle__r.Name, Job__c FROM Bundle_Job_Junction__c 
        WHERE Job__c IN :jobIds AND Active__c = TRUE]){
        if(!activeBundlesPerJob.containsKey(ob.Job__c)){
            activeBundlesPerJob.put(ob.Job__c, new List<Bundle__c>());
        }
        activeBundlesPerJob.get(ob.Job__c).add(ob.Bundle__r);
    }
    
    if(!activeBundlesPerJob.isEmpty()){
        String errorMessage = '', glue = '';
        for(Id jobId : activeBundlesPerJob.keySet()){
            if(activeBundlesPerJob.get(jobId).size() > 1){
                errorMessage += glue + 'ERROR: Can not have more then one active Bundle Job Junction for Job ['+jobId +']';
                glue = '\n';
            }
        }
        
        if(errorMessage != null && !errorMessage.trim().equals('')){
            trigger.new.get(0).addError(errorMessage );
        }
        
        List<TR1__Job__c> jobsToUpdate = new List<TR1__Job__c>([Select Id, Active_Bundle__c From TR1__Job__c Where Id IN :activeBundlesPerJob.keySet()]);
        for(TR1__Job__c ob : jobsToUpdate ){
            if(activeBundlesPerJob.containsKey(ob.Id) && activeBundlesPerJob.get(ob.Id).size() == 1){
                ob.Active_Bundle__c = activeBundlesPerJob.get(ob.Id).get(0).Id;
            }
        }
        update jobsToUpdate;
    }
}