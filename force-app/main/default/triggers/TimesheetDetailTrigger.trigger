trigger TimesheetDetailTrigger on TR1__Timesheet_Detail__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    TimesheetDetailTriggerHandler tdth = new TimesheetDetailTriggerHandler();
    
    if(trigger.isBefore){
        if(trigger.isUpdate){
            //system.debug('*****TimesheetDetailTrigger BeforeUpdate*****'+TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion);
            if(TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion == false || Test.isRunningTest())
                tdth.onBeforeUpdate(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert){
            //system.debug('*****TimesheetDetailTrigger BeforeInsert*****'+TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion);
            if(TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion == false || Test.isRunningTest())
                tdth.onBeforeInsert(trigger.new);
        }
        
    }
}