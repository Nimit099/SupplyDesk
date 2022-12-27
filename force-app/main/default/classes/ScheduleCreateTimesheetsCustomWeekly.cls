global class ScheduleCreateTimesheetsCustomWeekly implements Schedulable {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext sc) {
        Date sow = Date.today().toStartOfWeek().addDays(7);
        Date eow = Date.today().toStartOfWeek().addDays(13);        
        String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
        String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');
        
        String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c, TR1__Payroll_Type__c, Timesheet_Frequency__c FROM TR1__Closing_Report__c WHERE TR1__Assignment_Ended__c=\'No\' and  (RecordTypeId = \'';

        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        query += crconsultingId + '\') AND TR1__Generate_Timesheet__c = true AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';         

        system.debug(query);            
        ID batchprocessid = Database.executeBatch(new CreateTimesheetsCustomWeekly(query),Integer.valueOf(Label.WeeklyTimesheetCreationBatchSize));
        system.debug(batchprocessid);     
    }
}