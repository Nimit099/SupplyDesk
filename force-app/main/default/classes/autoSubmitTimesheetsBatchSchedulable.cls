global class autoSubmitTimesheetsBatchSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      autoSubmitTimesheetsBatch b = new autoSubmitTimesheetsBatch(); 
      database.executebatch(b,50);
   }
}