trigger CandidateAvailabilityTrigger on Candidate_Availability__c (Before Insert, Before Update, Before Delete, after insert , after delete, after undelete) {
    
    //Added on Aug 25, 2016
    CandidateAvailabilityTriggerHandler cath = new CandidateAvailabilityTriggerHandler(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
    
    if(Trigger.isBefore && Trigger.isInsert){
        cath.onBeforeInsertEvents();
    }
    else if(Trigger.isBefore && Trigger.isUpdate){
        cath.onBeforeUpdateEvents();
    }
    else if(Trigger.isBefore && Trigger.isDelete){ 
        cath.onBeforeDeleteEvents();
    }
    	
}