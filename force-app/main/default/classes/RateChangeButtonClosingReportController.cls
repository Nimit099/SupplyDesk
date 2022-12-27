public with sharing class RateChangeButtonClosingReportController{
    public TR1__Closing_Report__c currentcr{get;set;}
    public TR1__Closing_Report__c newcr{get;set;}
    public Boolean isSuccess{get;set;}
    private Set<String> accessibleNames = new Set<String>();
    
    //Constructor
    public RateChangeButtonClosingReportController(ApexPages.StandardController controller){
        
        Map<String, Schema.SobjectField> fields = Schema.SobjectType.TR1__Closing_Report__c.fields.getMap();
        for (String s : fields.keySet()) {           
            if (fields.get(s).getDescribe().isAccessible()){
                accessibleNames.add(s);
            }            
        }
        
        if(!Test.isrunningtest()){
            controller.addFields(new List<String>(accessibleNames));
            this.currentcr = (TR1__Closing_Report__c)controller.getRecord();
        }
        else{
            Id recordId = controller.getRecord().Id;
            this.currentcr = [
                              SELECT Id, TR1__Job__c, TR1__Account__c, TR1__Person_Placed__c, Maximum_Day_Charge_Rate__c, Maximum_Day_Pay_Rate__c, Maximum_Half_Day_Charge_Rate__c, Maximum_Half_Day_Pay_Rate__c,
                                     Maximum_Hour_Charge_Rate__c, Maximum_Hour_Pay_Rate__c, TR1__Generate_Timesheet__c, TR1__Receive_Timesheet_Email_Alerts__c, TR1__Conversion_Date__c, TR1__Job_Percentage__c,
                                     TR1__Candidate_Percentage__c, TR1__Marketing_Percentage__c, TR1__Other_Percentage__c, TR1__Other2_Percentage__c, TR1__Assignment_Ended__c, TR1__End_Date__c,
                                     TR1__Rate_Change_Effective_Date__c, TR1__Salary__c, RecordTypeId, TR1__Start_Date__c
                              FROM TR1__Closing_Report__c
                              WHERE Id = :recordId
                             ];
        }
        
        this.newcr = currentcr.clone();
        this.newcr.TR1__Start_Date__c = null;
        this.newcr.TR1__Booking_Date__c = null;
        this.isSuccess = false;
    }
    
    public void SaveRateChange(){
        
        if(newcr.TR1__Rate_Change_Effective_Date__c < currentcr.TR1__Start_Date__c ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Rate Change Effective Date should be greater than Closing Report Start Date.'));
            return;
        }
        
        if(newcr.TR1__Rate_Change_Effective_Date__c > currentcr.TR1__End_Date__c ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Rate Change Effective Date should be less than Closing Report End Date.'));
            return;
        }
        
        if(newcr.Maximum_Day_Charge_Rate__c < newcr.Maximum_Day_Pay_Rate__c ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Day Pay Rate cannot be greater than Day Charge Rate.'));
            return;
        }
        
        if(newcr.Maximum_Half_Day_Charge_Rate__c < newcr.Maximum_Half_Day_Pay_Rate__c ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Half Day Pay Rate cannot be greater than Half Day Pay Rate.'));
            return;
        }
        
        if(newcr.Maximum_Hour_Charge_Rate__c < newcr.Maximum_Hour_Pay_Rate__c ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Hour Pay Rate cannot be greater than Hour Charge Rate.'));
            return ;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            
            Date newEndDate = newcr.TR1__Rate_Change_Effective_Date__c.addDays(-1);
            
            newcr.Old_Hour_Charge_Rate__c =  currentcr.Maximum_Hour_Charge_Rate__c ;
            newcr.Old_Hour_Pay_Rate__c = currentcr.Maximum_Hour_Pay_Rate__c ;
            newcr.Old_Half_Day_Charge_Rate__c = currentcr.Maximum_Half_Day_Charge_Rate__c ;
            newcr.Old_Half_Day_Pay_Rate__c  = currentcr.Maximum_Half_Day_Pay_Rate__c ;
            newcr.Old_Day_Charge_Rate__c= currentcr.Maximum_Day_Charge_Rate__c ;
            newcr.Old_Day_Pay_Rate__c =  currentcr.Maximum_Day_Pay_Rate__c ;
            newcr.TR1__Assignment_Ended__c = 'No';
            newcr.TR1__Start_Date__c = newcr.TR1__Rate_Change_Effective_Date__c;
            
            currentcr.TR1__Generate_Timesheet__c = false;
            currentcr.TR1__Receive_Timesheet_Email_Alerts__c = false;
            currentcr.TR1__Assignment_Ended__c = 'Yes';
            currentcr.TR1__Assignment_Ended__c = 'Rate Change';
            currentcr.TR1__End_Date__c = newEndDate;
            currentcr.Contract_End_Date__c = newEndDate;
            
            if(currentcr!=null){
                update currentcr;
            }
            
            //Insert New CR
            if(newcr!= null){
                ClosingReportTriggerHelper.FromJobboard = True ;
                ClosingReportTriggerHelper.createTimesheetsForPastOrThisWeekFlag = true;
                SendConfirmationLetter.sendConfirmationLetterFlag = true;
                insert newcr;
            }
            
            //CRS reparenting
            list<Closing_Report_Schedule__c> closingReportScheduleToBeReparented = [
                                                                                    SELECT Name, Id,Closing_Report__r.Name,Candidate_Availability__c,Vacancy_Schedule__c 
                                                                                    FROM Closing_Report_Schedule__c 
                                                                                    WHERE Closing_Report__c =:currentcr.id AND Schedule_Date__c	> :newEndDate
                                                                                   ];
                                                                                   
            for(Closing_Report_Schedule__c crs : closingReportScheduleToBeReparented){
                crs.Closing_Report__c = newCR.id;
            }
            
            if(closingReportScheduleToBeReparented.size()>0){
                update closingReportScheduleToBeReparented;
            }
            
            //Query timesheets whose week ending is greater than rate change date selected 
            List<TR1__Timesheet__c> timesheetList = [
                                                  SELECT Id, Timesheet_Approved_Date_Time__c, Timesheet_Approved_By__c, TR1__Week_Ending__c, TR1__Timesheet_Type__c, TR1__Timesheet_Second_Approver__c, TR1__Status__c, TR1__Recruiter__c,
                                                         TR1__Payroll_Note__c, TR1__Consultant__c, TR1__Pay_Week_Ending__c, TR1__Closing_Report__c, TR1__Client__c, TR1__Job_Order__c
                                                  FROM TR1__Timesheet__c
                                                  WHERE TR1__Closing_Report__c = :currentcr.Id AND TR1__Week_Ending__c >= :newcr.TR1__Rate_Change_Effective_Date__c
                                                 ];
            
            List<TR1__Timesheet__c> timesheetToBeReparented = new List<TR1__Timesheet__c>();
            List<TR1__Timesheet__c> timesheetToCloned = new List<TR1__Timesheet__c>();
            for(TR1__Timesheet__c ts : timesheetList){
                if(ts.TR1__Week_Ending__c >= newcr.TR1__Rate_Change_Effective_Date__c.addDays(6)){
                    timesheetToBeReparented.add(ts);
                }
                else{
                    timesheetToCloned.add(ts);
                }
            }
            
            //Reparent Timesheets
            if(timesheetToBeReparented.size()>0){
                for(TR1__Timesheet__c ts : timesheetToBeReparented){
                    ts.TR1__Closing_Report__c = newCR.id;
                }
                update timesheetToBeReparented;
            }
            
            //Clone Timesheets & Reparent Timesheet Detail
            if(timesheetToCloned.size()>0){
                
                Set<Id> timesheetIdSet = (new Map<Id,TR1__Timesheet__c>(timesheetToCloned)).keySet();
                List<TR1__Timesheet_Detail__c> timesheetDetailToBeReparentedList = [SELECT Id, TR1__Day__c, TR1__Date__c, TR1__Timesheet__c FROM TR1__Timesheet_Detail__c WHERE TR1__Timesheet__c IN :timesheetIdSet AND TR1__Date__c >= :newcr.TR1__Rate_Change_Effective_Date__c]; 
                Map<Id,TR1__Timesheet__c> oldTimesheetToNewTimesheetMap = new Map<Id,TR1__Timesheet__c>();
                
                for(TR1__Timesheet__c ts : timesheetToCloned){
                    TR1__Timesheet__c tempTimesheet = ts.clone();
                    tempTimesheet.TR1__Closing_Report__c = newCR.id;
                    oldTimesheetToNewTimesheetMap.put(ts.id,tempTimesheet);
                }
                insert oldTimesheetToNewTimesheetMap.values();
                
                for(TR1__Timesheet_Detail__c tsd : timesheetDetailToBeReparentedList){
                    if(tsd.TR1__Date__c >= newcr.TR1__Rate_Change_Effective_Date__c){
                        if(oldTimesheetToNewTimesheetMap.containsKey(tsd.TR1__Timesheet__c)){
                            tsd.TR1__Timesheet__c = oldTimesheetToNewTimesheetMap.get(tsd.TR1__Timesheet__c).id;
                        }
                    }
                }
                
                TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion = false;
                update timesheetDetailToBeReparentedList;
            }
            
            this.isSuccess = true;  
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            Database.rollback(sp);
        }
    }
}