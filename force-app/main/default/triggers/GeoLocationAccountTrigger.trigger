trigger GeoLocationAccountTrigger on Account (after insert, after update) {
    Google_Map_API__c gApi = Google_Map_API__c.getInstance();
    if(gApi != null && gApi.isExecuteAccount__c){
        if(trigger.isAfter && trigger.isUpdate){
            GeoLocationAccountTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        if(trigger.isAfter && trigger.isInsert){
            GeoLocationAccountTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
}