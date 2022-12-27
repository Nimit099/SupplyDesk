/*Code to Run this batch from Anonymous Window

Date sow = Date.today().addMonths(1).toStartOfWeek();
Date eow = sow.addDays(7);        
String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');

String query = 'SELECT Id,CurrencyIsoCode,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c, TR1__Payroll_Type__c, Timesheet_Frequency__c FROM TR1__Closing_Report__c WHERE Id = \'a093E0000009iqt\' AND TR1__Assignment_Ended__c=\'No\' and Timesheet_Frequency__c =\'weekly\' and  (RecordTypeId = \'';

Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
query += crconsultingId + '\') AND TR1__Generate_Timesheet__c = true AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';         

system.debug(query);            
ID batchprocessid = Database.executeBatch(new CreateTimesheetsCustomWeekly(query,sow),50);

*/

global class CreateTimesheetsCustomWeekly implements Database.Batchable<sObject>, Database.Stateful{    
    
    global List<String> batchResult;
    global final String query;
    global final Date runDate;

    global CreateTimesheetsCustomWeekly(String q) {
        this.query = q;
        this.runDate = Date.today();
        this.batchResult = new List<String>();
    }

    global CreateTimesheetsCustomWeekly(String q, String runDate) {
        this.query = q;
        this.runDate = Date.parse(runDate);
        this.batchResult = new List<String>();
    }
    
    global CreateTimesheetsCustomWeekly(String q, Date runDate) {//To Run the batch from Anonymous Window
        this.query = q;
        this.runDate = runDate;
        this.batchResult = new List<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Set < Id > closingReportIdSet = new Set < Id > ();
        Date weekenddate = runDate.toStartOfWeek().addDays(13);
        Map < Id, TR1__Timesheet__c > closingReportIdToExistingTimesheetMap = new Map < Id, TR1__Timesheet__c > ();
        
        //Find Existing Closing Report's Timesheet
        for (sObject s: scope) {
            TR1__Closing_Report__c cr = (TR1__Closing_Report__c) s;
            closingReportIdSet.add(cr.Id);
        }
        
        for (TR1__Timesheet__c ts: [SELECT Id, TR1__Closing_Report__c FROM TR1__Timesheet__c WHERE TR1__Closing_Report__c IN :closingReportIdSet AND TR1__Pay_Week_Ending__c = :weekenddate]){
            closingReportIdToExistingTimesheetMap.put(ts.TR1__Closing_Report__c, ts);
        }
        
        List <TR1__Closing_Report__c> closingReportList = new List <TR1__Closing_Report__c>();
        
        for (sObject s: scope) {
            TR1__Closing_Report__c cr = (TR1__Closing_Report__c) s;
            if (!closingReportIdToExistingTimesheetMap.containsKey(cr.Id)){
                closingReportList.add(cr);
            }
        }
        
        batchResult.addAll(TimesheetUtility.CreateTimesheetAndTimesheetDetailForBatch(closingReportList,runDate));
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = : BC.getJobId()];
        try {
            Set<String> toAddressesSet = new Set<String>();
            toAddressesSet.add(UserInfo.getUserEmail());
            if(String.isNotBlank(Label.WeeklyTimesheetCreationBatchEmailRecipient)){
                toAddressesSet.addAll(Label.WeeklyTimesheetCreationBatchEmailRecipient.split(','));
            }
            
            List<String> toAddressList = new List<String>();
            toAddressList.addAll(toAddressesSet);     
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddressList);
            mail.setSubject('Timesheet Creation Batch program Report');
            String htmlBody = 'The "Weekly Timesheet Creation" batch Apex job # '+a.Id+' processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' errors.<br/><br/>';
            
            for(String s : batchResult) {
                htmlBody += s + '<br/>';
            }
            
            mail.setHTMLBody(htmlBody);
            
            Boolean sendEmailNotification = String.isNotBlank(System.Label.SendEmailNotificationForWeeklyTimesheetCreationBatch) ? Boolean.valueOf(System.Label.SendEmailNotificationForWeeklyTimesheetCreationBatch) : false;
            if(!Test.isRunningTest() && sendEmailNotification){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        } catch (Exception ex) {
            
        }
    }
    
}