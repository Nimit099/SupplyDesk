trigger TimesheetTrigger on TR1__Timesheet__c (after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        TimesheetTriggerHandler.afterInsert(Trigger.new);
    }else if(Trigger.isUpdate && Trigger.isAfter){
        TimesheetTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}