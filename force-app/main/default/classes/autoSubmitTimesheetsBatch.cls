public class autoSubmitTimesheetsBatch implements Database.Batchable < TR1__Timesheet__c >,Database.Stateful {
    public Map<Id,String> entityToErrorMessageMap;
    public List<String> toAddressList;
    public Set<Id> successList;
    
    public autoSubmitTimesheetsBatch(){
        entityToErrorMessageMap = new Map<Id,String>();
        toAddressList = new List<String>();
        successList = new Set<Id>();
        //Populate Email Recepient List
        Set<String> toAddressesSet = new Set<String>();
        toAddressesSet.add(UserInfo.getUserEmail());
        if(String.isNotBlank(Label.SubmitTimesheet_EmailNotificationList)){
            toAddressesSet.addAll(Label.SubmitTimesheet_EmailNotificationList.split(','));
        }
        toAddressList.addAll(toAddressesSet);        
    }
    
    public Iterable < TR1__Timesheet__c > start(Database.BatchableContext BC) {
        date currWeekStart = date.today().toStartofWeek();
        String currStartWeekDay = TimesheetUtility.dayOfDate(currWeekStart);
        Date upcomingSundayDate;
        if (currStartWeekDay == 'Monday')
            upcomingSundayDate = currWeekStart.addDays(6);
        else if (currStartWeekDay == 'Sunday')
            upcomingSundayDate = currWeekStart.addDays(7);
        System.debug('===================upcomingSundayDate==================' + upcomingSundayDate);
        String query = '';
        
        if(!Test.isRunningTest()){
            query = 'SELECT Id, TR1__Status__c FROM TR1__Timesheet__c WHERE TR1__Status__c = \'Unsubmitted\' AND TR1__Week_Ending__c != null AND Client_account_number__c != null AND Payroll_number__c != null AND TR1__Total_Bill_Override__c != 0 AND TR1__Total_Pay_Override__c != 0 ';
            query += ' AND TR1__Closing_Report__r.Booking_Confirmed__c = true AND TR1__Week_Ending__c <=: upcomingSundayDate';
        }
        else
        {
            query = 'SELECT Id, TR1__Status__c FROM TR1__Timesheet__c WHERE TR1__Status__c = \'Unsubmitted\' ';
        }
        
        List < TR1__Timesheet__c > timesheetLIst =  Database.query(query);
        system.debug('=================================timesheetLIst===='+timesheetLIst);
        return timesheetLIst;  
    }

    public void execute(Database.BatchableContext BC, List < TR1__Timesheet__c > scopeTimesheetList) {
        List < TR1__Timesheet__c > updateTimesheetList = New List < TR1__Timesheet__c > ();
        for (TR1__Timesheet__c t: scopeTimesheetList) {
            t.TR1__Status__c = 'Submitted';
            updateTimesheetList.add(t);
        } // end for 
        system.debug('==========================updateTimesheetList====' + updateTimesheetList);
        if (updateTimesheetList.size() > 0) {
            List < Database.SaveResult > srList = Database.update(updateTimesheetList, false);
            for (Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    entityToErrorMessageMap.put(sr.getId(),sr.getErrors()[0].getMessage());
                }
                else {
                    successList.add(sr.getId());
                }
            }            
        }
    }

    public void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddressList);
        mail.setSubject('Auto Submit Timesheet : Completed : '+context.getJobId());
        String htmlBody = 'The "Auto Submit Timesheet" Apex job # '+context.getJobId()+' finished update of timesheets with ' + successList.size() +' success and '+ entityToErrorMessageMap.size() + ' errors.<br/><br/>';
        
        if(successList.size()>0) {
            htmlBody += '****************Success List*************************<br/><br/>'; 
            for(String s : successList) {
                htmlBody += s+'<br/>'; 
            }
        }
        
        if(entityToErrorMessageMap.size()>0) {
            htmlBody += '****************Error List***************************<br/><br/>'; 
            Integer i = 1;
            for(String id : entityToErrorMessageMap.keyset()){
                htmlBody += (i++)+' :: Entity Id : '+ id +' :: Error : '+entityToErrorMessageMap.get(id) + '<br/><br/>';
            }
        }
        
        mail.setHTMLBody(htmlBody);
        if(!Test.isRunningTest() && toAddressList.size()>0){ //Send email if they have specified atleat 1 email address
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }        
    }
}