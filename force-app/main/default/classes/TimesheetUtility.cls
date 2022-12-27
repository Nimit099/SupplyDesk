public with sharing class TimesheetUtility {
    /********************************Added for CRS Logic*****************************************/
    public static boolean CheckIfCompleteWeekIsHoliday(TR1__Closing_Report__c cr, Date weekEndate, map < Id, set < Date >> mapJobAgainstSetOfWeekEndDate) {
        boolean temp = false;
        if (mapJobAgainstSetOfWeekEndDate.get(cr.TR1__Job__c) != null){ //Added for CRS check if avaliable then only create timesheets
            if (mapJobAgainstSetOfWeekEndDate.get(cr.TR1__Job__c).contains(weekEndate)){ //Added for CRS check if avaliable then only create timesheets
                temp = true;
            }
        }
        return temp;
    }
    
    public static date calculateEndDateBasedOnTimesheetType(Date selectedDate,String source){
        Date endDate;
        if(source == 'Batch'){
            endDate = SelectedDate.toStartOfWeek().addDays(13);
        }
        else{
            endDate = SelectedDate.toStartOfWeek().addDays(6);
        }
        return endDate;
    }
    
    public static date calculateStartDateBasedOnTimesheetType(Date selectedDate,String source){
        Date startDate; 
        if(source == 'Batch'){
            startDate = SelectedDate.toStartOfWeek().addDays(7);
        }
        else{
            startDate = SelectedDate.toStartOfWeek();
        }
        return startDate;
    }

    // This method will be called from CreateTimesheetsCustomWeekly Apex Class and used to create Timesheet & Timesheet Detail records
    public static List<String> CreateTimesheetAndTimesheetDetailForBatch(List<TR1__Closing_Report__c> closingReportList,Date runDate){
        
        Map<Id,TR1__Timesheet__c> closingReportIdToTimesheetToBeInsertedMap = new Map<Id,TR1__Timesheet__c>();
        Map<Id,TR1__Closing_Report__c> closingReportMap = new Map<Id,TR1__Closing_Report__c>();
        Map<Id,Id> closingReportIdToTimesheetIdMap = new Map<Id,Id> ();
        List<TR1__Timesheet_Detail__c> timesheetDetailListToBeInserted = new List<TR1__Timesheet_Detail__c>();
        Map<Id,String> closingReportToTimesheetInsertResult = new Map<Id,String>();
        List<String> batchResult = new List<String>();
        
        for(TR1__Closing_Report__c cr : closingReportList){
            if(cr.TR1__Start_Date__c==null) continue;
            
            Date weekenddate = calculateEndDateBasedOnTimesheetType(runDate,'Batch');
            
            if(cr.TR1__End_Date__c!=null){
                weekenddate = weekenddate < cr.TR1__End_Date__c ? weekenddate : cr.TR1__End_Date__c;
            }
            
            TR1__Timesheet__c ts = new TR1__Timesheet__c(
                                                            TR1__Status__c = 'Unsubmitted',
                                                            TR1__Closing_Report__c = cr.Id,
                                                            TR1__Consultant__c = cr.TR1__Person_Placed__c,
                                                            TR1__Job_Order__c = cr.TR1__Job__c,
                                                            TR1__Approver__c = cr.TR1__Timesheet_Approver__c,
                                                            TR1__Timesheet_Second_Approver__c = cr.TR1__Timesheet_Second_Approver__c,
                                                            TR1__Client__c = cr.TR1__Account__c,
                                                            TR1__Week_Ending__c = weekenddate,
                                                            TR1__Pay_Week_Ending__c = weekenddate
                                                        );
            closingReportIdToTimesheetToBeInsertedMap.put(cr.Id,ts);
            closingReportMap.put(cr.Id,cr);
        }
        
        if(!closingReportIdToTimesheetToBeInsertedMap.isEmpty()){
            Database.saveResult[] resultList =  Database.insert(closingReportIdToTimesheetToBeInsertedMap.values(),false);
            integer i=0;
            for(Id crId : closingReportIdToTimesheetToBeInsertedMap.keyset()){
                String str = closingReportMap.get(crId).Name + ' : ';
                if(String.isNotBlank(closingReportIdToTimesheetToBeInsertedMap.get(crId).Id)){
                    str += 'Successfully Created.';
                    closingReportIdToTimesheetIdMap.put(closingReportMap.get(crId).Id,closingReportIdToTimesheetToBeInsertedMap.get(crId).Id);
                }
                else if(!resultList[i].isSuccess()){
                    Database.SaveResult sr = resultList[i];
                    str += sr.getErrors()[0].getMessage();
                }
                closingReportToTimesheetInsertResult.put(closingReportMap.get(crId).Id,str);
                i++;
            }
        }
        
        for(TR1__Closing_Report__c cr : closingReportList){
            if(cr.TR1__Start_Date__c == null || !closingReportIdToTimesheetIdMap.containsKey(cr.Id)){
                continue;
            }
            
            Date weekStartDate = calculateStartDateBasedOnTimesheetType(runDate ,'Batch');
            Date weekEndDate = calculateEndDateBasedOnTimesheetType(runDate,'Batch');
            
            weekStartDate = (weekStartDate >= cr.TR1__Start_Date__c) ? weekStartDate : cr.TR1__Start_Date__c;
            
            
            if(cr.TR1__End_Date__c!=null){
                weekEndDate = weekEndDate <= cr.TR1__End_Date__c ? weekEndDate : cr.TR1__End_Date__c;
            }
            
            Integer numberDaysDue = weekStartDate.daysBetween(weekEndDate);
            
            for (Integer i = 0 ; i <= numberDaysDue; i++) {
                TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c(
                                                                            TR1__Timesheet__c = closingReportIdToTimesheetIdMap.get(cr.Id),
                                                                            TR1__Date__c = weekStartDate.addDays(i),
                                                                            TR1__Day__c = dayOfDate(weekStartDate.addDays(i))
                                                                           );
                timesheetDetailListToBeInserted.add(td);
            }
        }
        
        Set<Id> timesheetSetToBeReviewed = new Set<Id>();
        
        if(!timesheetDetailListToBeInserted.isEmpty()){
            Database.insert(timesheetDetailListToBeInserted,false);
            for(TR1__Timesheet_Detail__c td : timesheetDetailListToBeInserted){
                if(String.isBlank(td.id)){
                    timesheetSetToBeReviewed.add(td.TR1__Timesheet__c);
                }
            }
        }
        
        List<TR1__Timesheet__c> timesheetListToBeDeleted = new List<TR1__Timesheet__c>();
        
        if(!timesheetSetToBeReviewed.isEmpty()){
            List<TR1__Timesheet__c> timesheetListToBeReviewed = [SELECT Id, TR1__Closing_Report__c, TR1__Closing_Report__r.Name, (SELECT Id FROM TR1__Timecards__r) FROM TR1__Timesheet__c WHERE Id IN :timesheetSetToBeReviewed];
            for(TR1__Timesheet__c ts : timesheetListToBeReviewed){
                if(ts.TR1__Timecards__r.isEmpty()){
                    timesheetListToBeDeleted.add(ts);
                }
            }
        }
        
        if(!timesheetListToBeDeleted.isEmpty()){
            for(TR1__Timesheet__c ts : timesheetListToBeDeleted){
                closingReportToTimesheetInsertResult.put(ts.TR1__Closing_Report__c, ts.TR1__Closing_Report__r.Name + ' : An Error occured while inserting Timesheet Detail for its Timesheet. Hence Timesheet Deleted.');
            }
            Database.delete(timesheetListToBeDeleted,false);
        }
        
        batchResult = closingReportToTimesheetInsertResult.values();
        return batchResult;
    }
    
    /*Old Method
    public static String insertTimesheetDetail(TR1__Closing_Report__c cr,Date startDate,Date endDate){
        
        system.debug('SelectedDate---'+startDate+'EndOfWeek==='+endDate);
        
        if(cr.TR1__Start_Date__c==null) return null;

        List < TR1__Timesheet__c > timesheets = new List < TR1__Timesheet__c > ();        
        List < TR1__Timesheet_Detail__c > timesheetdetails = new List < TR1__Timesheet_Detail__c > ();
        
        for(Date runDate=startDate;runDate<=endDate;){
            Date weekenddate = calculateEndDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
            if(cr.TR1__End_Date__c!=null){
                weekenddate = weekenddate < cr.TR1__End_Date__c ? weekenddate : cr.TR1__End_Date__c;
            }
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            //ts.CurrencyIsoCode = cr.CurrencyIsoCode;
            ts.TR1__Status__c = 'Unsubmitted';
            ts.TR1__Closing_Report__c = cr.Id;
            ts.TR1__Consultant__c = cr.TR1__Person_Placed__c;
            ts.TR1__Job_Order__c = cr.TR1__Job__c;
            ts.TR1__Approver__c = cr.TR1__Timesheet_Approver__c;
            ts.TR1__Timesheet_Second_Approver__c = cr.TR1__Timesheet_Second_Approver__c;
            ts.TR1__Client__c = cr.TR1__Account__c;
            ts.TR1__Week_Ending__c = weekenddate;
            ts.TR1__Pay_Week_Ending__c = weekenddate;
            timesheets.add(ts);  
            runDate = cr.Timesheet_Frequency__c=='Calendar Monthly'?runDate.addMonths(1):runDate.addDays(7);           
        }
        
        system.debug('timesheets---'+timesheets);
        
        try{
            if(timesheets.size()>0) {
                insert timesheets;
                //Start Timesheet Detail Creation
                for(TR1__Timesheet__c t : timesheets){
                    Date runDate =  t.TR1__Week_Ending__c;   
                    Date StartOfWeek = calculateStartDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
                    StartOfWeek = (StartOfWeek >= cr.TR1__Start_Date__c) ? StartOfWeek : cr.TR1__Start_Date__c;
                    
                    Date EndOfWeek = calculateEndDateBasedOnTimesheetType(runDate,cr.Timesheet_Frequency__c);
                    if(cr.TR1__End_Date__c!=null){
                        EndOfWeek = EndOfWeek <= cr.TR1__End_Date__c ? EndOfWeek : cr.TR1__End_Date__c;
                    }
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
*/
    
    //New Method copied from TimesheetUtility_v1 Apex Class
    // This method will be called from ClosingReportTriggerHelper Apex Class and used to create Timesheet & Timesheet Detail records
    public static String insertTimesheetDetail(TR1__Closing_Report__c cr,Date startDate,Date endDate){
        if(cr.TR1__End_Date__c==null || cr.TR1__Start_Date__c==null) return null;

        List < TR1__Timesheet__c > timesheets = new List < TR1__Timesheet__c > ();        
        List < TR1__Timesheet_Detail__c > timesheetdetails = new List < TR1__Timesheet_Detail__c > ();
        
        for(Date runDate=startDate;runDate<=endDate;){
            Date weekenddate = calculateEndDateBasedOnTimesheetType(runDate,'realtimetrigger');
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
                    Date StartOfWeek = calculateStartDateBasedOnTimesheetType(runDate,'realtimetrigger');
                    StartOfWeek = (StartOfWeek >= cr.TR1__Start_Date__c) ? StartOfWeek : cr.TR1__Start_Date__c;
                    
                    Date EndOfWeek = calculateEndDateBasedOnTimesheetType(runDate,'realtimetrigger');
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
           
        TR1__Debug_Log__c log=new TR1__Debug_Log__c();
        log.TR1__Additional_Message__c='CAUSE'+ex.getCause()+'LINE NUMBER'+ex.getLineNumber();
        log.TR1__Class_Name__c='TimesheetUtility';
        log.TR1__Message__c=ex.getMessage();
        log.TR1__Log_Type__c='Error';
        log.TR1__Stack_Trace_String__c=ex.getStackTraceString();
        log.TR1__Alias_Id__c=String.valueOf(cr.Id);
            insert log;
            
            return 'Timesheet cannot be created due to the following Reasons:<br/>'+Label.TimesheetCreation_ErrorMessage+'<br/>Error Details:'+ex.getMessage();
        }  
        return 'Timesheet cannot be created due to the following Reasons:<br/>'+Label.TimesheetCreation_ErrorMessage;
    }

    /******************************************************************************************/
    public static map < Id, set < Date >> GetHolidaysAgaintsVacancy(set < Id > setJobIds) {
        map < Id, set < Date >> mapJobAgainstSetOfWeekEndDate = new map < Id, set < Date >> ();
        for (Holiday__c hol: [Select h.Vacancy__c, h.Start_Date__c, h.Start_Date_WeekEndDate__c,
                h.Name, h.Id, h.How_many_compelete_week_holiday__c, h.End_Date__c,
                h.End_Date_WeekEndDate__c, h.Complete_Week_Starts_From__c, h.Account__c
                From Holiday__c h where Vacancy__c in : setJobIds
            ]) {
            if (hol.How_many_compelete_week_holiday__c > 0 && hol.Complete_Week_Starts_From__c != null) {
                if (mapJobAgainstSetOfWeekEndDate.get(hol.Vacancy__c) != null) {
                    set < date > tempset = new set < date > ();
                    for (integer i = 1; i <= hol.How_many_compelete_week_holiday__c; i++) {
                        if (i == 1)
                            mapJobAgainstSetOfWeekEndDate.get(hol.Vacancy__c).add(hol.Complete_Week_Starts_From__c.addDays(6 * i));
                        else
                            mapJobAgainstSetOfWeekEndDate.get(hol.Vacancy__c).add(hol.Complete_Week_Starts_From__c.addDays(6 + (7 * (i - 1))));
                    }
                    //mapJobAgainstSetOfWeekEndDate.get(hol.Vacancy__c).add(hol.Complete_Week_Starts_From__c.addDays(6));

                } else {
                    set < date > tempset = new set < date > ();
                    for (integer i = 1; i <= hol.How_many_compelete_week_holiday__c; i++) {
                        if (i == 1)
                            tempset.add(hol.Complete_Week_Starts_From__c.addDays(6 * i));
                        else
                            tempset.add(hol.Complete_Week_Starts_From__c.addDays(6 + (7 * (i - 1))));
                    }
                    mapJobAgainstSetOfWeekEndDate.put(hol.Vacancy__c, tempset);
                }
            }
        }
        return mapJobAgainstSetOfWeekEndDate;

    }

    public static String dayOfDate(Date d) {
        Datetime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('EEEE'); //returns Sunday or Monday or .. 
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