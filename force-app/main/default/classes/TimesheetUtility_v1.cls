//*********************************//
// Description: Timesheet Utility Class to hold some common function which can be used from anywhere.
// Created By: Chirag Mehta 
//*********************************//
public class TimesheetUtility_v1 {        
    public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or .. 
    }
        
    /**        
        Added below logic to calculate start and end date based on timsheet type ie weekly or bi-weekly etc
     **/    
    public static date calculateStartDateBasedOnTimesheetType(Date selectedDate, String TimesheetType){
        Date returndate; 
        if(TimesheetType == 'Weekly')
            returndate = SelectedDate.toStartOfWeek();
        else if(TimesheetType == 'Calendar Monthly')
            returndate = SelectedDate.toStartOfMonth();
        else //default to Weekly
            returndate = SelectedDate.toStartOfWeek();        
        return returndate;
    }

    public static date calculateEndDateBasedOnTimesheetType(Date selectedDate, String TimesheetType){
        Date returndate;
        if(TimesheetType == 'Weekly')
            returndate = SelectedDate.toStartOfWeek().addDays(6);
        else if(TimesheetType == 'Calendar Monthly')
            returndate = SelectedDate.toStartOfMonth().addMonths(1)-1;
        else //default to Weekly
            returndate = SelectedDate.toStartOfWeek().addDays(6);
        return returndate;
    }
    
    public static String insertTimesheetDetail(List<TR1__Closing_Report__c> CRList,Date runDate){
        List < TR1__Timesheet__c > timesheets = new List < TR1__Timesheet__c > ();
        List < TR1__Timesheet_Detail__c > timesheetdetails = new List < TR1__Timesheet_Detail__c > ();
        Map<Id,Id> closingReportToTimesheetIdMap = new Map<Id,Id> ();
        for(TR1__Closing_Report__c cr : CRList){
            if(cr.TR1__End_Date__c==null || cr.TR1__Start_Date__c==null) continue;
            Date weekenddate = calculateEndDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
            weekenddate = weekenddate < cr.TR1__End_Date__c ? weekenddate : cr.TR1__End_Date__c;
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            ts.TR1__Status__c = 'Unsubmitted';
            ts.TR1__Closing_Report__c = cr.Id;
            ts.TR1__Consultant__c = cr.TR1__Person_Placed__c;
            ts.TR1__Job_Order__c = cr.TR1__Job__c;
            ts.TR1__Approver__c = cr.TR1__Timesheet_Approver__c;
            ts.TR1__Client__c = cr.TR1__Account__c;
            ts.TR1__Week_Ending__c = weekenddate;
            ts.TR1__Pay_Week_Ending__c = getPayWeekendingDate(ts.TR1__Week_Ending__c);//Hardik@10May2016 : Updated logic to set 7th Day of Week i.e. Sunday even if closing report has end date in between week.
            timesheets.add(ts);             
        }
        try{
            if(timesheets.size()>0) {
                insert timesheets;
                for(TR1__Timesheet__c ts : timesheets){
                    closingReportToTimesheetIdMap.put(ts.TR1__Closing_Report__c,ts.Id);
                }
            }
            system.debug('\n@@@@@@ no error while inserting Timesheet details'); 
        }catch (DMLException ex) {
            system.debug('\n@@@@@@ error while inserting Timesheet details'); 
        }
        for(TR1__Closing_Report__c cr : CRList){
            if(cr.TR1__End_Date__c==null || cr.TR1__Start_Date__c==null) continue;
            
            Date StartOfWeek = calculateStartDateBasedOnTimesheetType(runDate , cr.Timesheet_Frequency__c);
            StartOfWeek = (StartOfWeek >= cr.TR1__Start_Date__c) ? StartOfWeek : cr.TR1__Start_Date__c;
            
            Date EndOfWeek = calculateEndDateBasedOnTimesheetType(runDate , cr.Timesheet_Frequency__c);
            EndOfWeek = (EndOfWeek <= cr.TR1__End_Date__c) ? EndOfWeek : cr.TR1__End_Date__c;

            Integer numberDaysDue = StartOfWeek.daysBetween(EndOfWeek);
            for (Integer i = 0 ; i <= numberDaysDue; i++) {
                TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = closingReportToTimesheetIdMap.get(cr.Id), TR1__Date__c = StartOfWeek.addDays(i), TR1__Day__c = dayOfDate(StartOfWeek.addDays(i)));
                timesheetdetails.add(td);
            }
        }
        try{
            if(timesheetdetails.size()>0) {
                insert timesheetdetails;
            }
            String msg = String.valueOf(timesheets[0].Id);            
            return msg;                
        }catch (Exception ex) {
            String msg = 'Timesheet cannot be created due to the following Reasons:<br/>'+Label.TimesheetCreation_ErrorMessage+'<br/>Error Details:'+ex.getMessage();
            return msg;
        }        
    }  
    
    public static String insertTimesheetDetail(TR1__Closing_Report__c cr,Date startDate,Date endDate){
        if(cr.TR1__End_Date__c==null || cr.TR1__Start_Date__c==null) return null;

        List < TR1__Timesheet__c > timesheets = new List < TR1__Timesheet__c > ();        
        List < TR1__Timesheet_Detail__c > timesheetdetails = new List < TR1__Timesheet_Detail__c > ();
        
        for(Date runDate=startDate;runDate<=endDate;){
            Date weekenddate = calculateEndDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
            weekenddate = weekenddate < cr.TR1__End_Date__c ? weekenddate : cr.TR1__End_Date__c;
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            ts.TR1__Status__c = 'Unsubmitted';
            ts.TR1__Closing_Report__c = cr.Id;
            ts.TR1__Consultant__c = cr.TR1__Person_Placed__c;
            ts.TR1__Job_Order__c = cr.TR1__Job__c;
            ts.TR1__Approver__c = cr.TR1__Timesheet_Approver__c;
            ts.TR1__Timesheet_Second_Approver__c = cr.TR1__Timesheet_Second_Approver__c;
            ts.TR1__Client__c = cr.TR1__Account__c;
            ts.TR1__Week_Ending__c = weekenddate;
            ts.TR1__Pay_Week_Ending__c = getPayWeekendingDate(ts.TR1__Week_Ending__c);//Hardik@10May2016 : Updated logic to set 7th Day of Week i.e. Sunday even if closing report has end date in between week.
            timesheets.add(ts);  
            runDate = cr.Timesheet_Frequency__c=='Calendar Monthly'?runDate.addMonths(1):runDate.addDays(7);           
        }
        try{
            if(timesheets.size()>0) {
                insert timesheets;
                //Start Timesheet Detail Creation
                for(TR1__Timesheet__c t : timesheets){
                    Date runDate =  t.TR1__Week_Ending__c;   
                    Date StartOfWeek = calculateStartDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
                    StartOfWeek = (StartOfWeek >= cr.TR1__Start_Date__c) ? StartOfWeek : cr.TR1__Start_Date__c;
                    
                    Date EndOfWeek = calculateEndDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
                    EndOfWeek = (EndOfWeek <= cr.TR1__End_Date__c) ? EndOfWeek : cr.TR1__End_Date__c;
        
                    Integer numberDaysDue = StartOfWeek.daysBetween(EndOfWeek);
                    for (Integer i = 0 ; i <= numberDaysDue; i++) {
                        TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = t.Id, TR1__Date__c = StartOfWeek.addDays(i), TR1__Day__c = dayOfDate(StartOfWeek.addDays(i)));
                        timesheetdetails.add(td);
                    }
                }
                if(timesheetdetails.size()>0) {
                    insert timesheetdetails;
                    return String.valueOf(timesheets[0].Id);            
                }                
            }
        }catch (DMLException ex) {
            system.debug('\n@@@@@@ error while inserting Timesheet details'); 
            return 'Timesheet cannot be created due to the following Reasons:<br/>'+Label.TimesheetCreation_ErrorMessage+'<br/>Error Details:'+ex.getMessage();
        }  
        return 'Timesheet cannot be created due to the following Reasons:<br/>'+Label.TimesheetCreation_ErrorMessage;
    }
    
    public static Date getPayWeekendingDate(Date weekendingDate){//Hardik@10May2016 : Updated logic to set 7th Day of Week i.e. Sunday even if closing report has end date in between week.
        if(dayOfDate(weekendingDate) == 'Sunday'){
            return weekendingDate;
        }
        else{
            return weekendingDate.toStartOfWeek().addDays(6);
        }
    }
}