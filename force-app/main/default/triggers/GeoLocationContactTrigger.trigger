trigger GeoLocationContactTrigger on Contact (after insert, after update) {
    Google_Map_API__c gApi = Google_Map_API__c.getInstance();
    if(gApi != null && gApi.isExecuteContact__c){
        if(trigger.isAfter && trigger.isUpdate){
            GeoLocationContactTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        if(trigger.isAfter && trigger.isInsert){
            GeoLocationContactTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
}