trigger ClosingReportScheduleUpdate on Closing_Report_Schedule__c (after delete , after insert ,After update, before delete,before insert, before update) {  
    
    //trigger.old[0].addError('Test error');
    System.debug('Boolean value1:'+ClosingReportSchedule_Helper.Execute_OnInsertAndDelete_ClosingReport);
    
    if(Trigger.isAfter && trigger.isInsert){
        if(ClosingReportSchedule_Helper.Execute_OnInsertAndDelete_ClosingReport){
            ClosingReportSchedule_Helper.Execute_OnInsertAndDelete_ClosingReport = false; 
            ClosingReportSchedule_Helper.updateCRDate(trigger.newMap);
        }
        //Added for new CRS TimesheetDetailMapping
        ClosingReportSchedule_Helper.mapCRSwithTimesheetDetails(trigger.new);
        ClosingReportSchedule_Helper.updateClosingReportFiels(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isDelete){
        if(ClosingReportSchedule_Helper.Execute_OnInsertAndDelete_ClosingReport || Test.isRunningTest()){
            
            ClosingReportSchedule_Helper.Execute_OnInsertAndDelete_ClosingReport = false;
            
            ClosingReportSchedule_Helper.updateCRDate(trigger.oldMap);
            //ClosingReportSchedule_Helper.deleteClosingReportOnClosingReportScheduleDelete(trigger.old);
        } 
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        ClosingReportSchedule_Helper.updateClosingReportFiels(trigger.new);
        ClosingReportSchedule_Helper.updateCandidateStatus(trigger.new, Trigger.oldMap);
    }
    
    //Prevent duplication for closing report schedule.
    if(trigger.isBefore && trigger.isInsert ){
        ClosingReportSchedule_Helper.preventDuplicateCRS(trigger.new);
        ClosingReportSchedule_Helper.splitCSDRecords(trigger.new); 
    }
    
    if(trigger.isAfter && trigger.isDelete) {
        // Update Candidate Status when bookings are deleted.
        ClosingReportSchedule_Helper.updateCandidateStatusOnCRSDelete(trigger.old); 
    }
    
    if(trigger.isBefore && trigger.isDelete){
        //Added for new CRS TimesheetDetailMapping
        ClosingReportSchedule_Helper.updateTimsheetDetailOnCRSDelete(trigger.oldMap);
    }
}