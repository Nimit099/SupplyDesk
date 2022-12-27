trigger ContactTrigger on Contact (after insert, after update,before Update,before insert) {
    
    ContactTriggerHandler ch = new ContactTriggerHandler();
    ch.contactTriggerHandler(trigger.new, trigger.OldMap);
     
    if(trigger.isBefore && trigger.isInsert){
        ch.OnBeforeInsertEvent();    
     }
    
    if(trigger.isBefore && trigger.isUpdate){
        ch.OnBeforeUpdateEvent();    
    }
    if(trigger.isAfter && trigger.isInsert){
        ch.OnAfterInsertEvent();    
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        ch.OnAfterUpdateEvent();    
    }
    
}