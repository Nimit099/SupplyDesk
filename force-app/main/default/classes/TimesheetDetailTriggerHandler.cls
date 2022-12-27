public with sharing class TimesheetDetailTriggerHandler {
    public Static boolean TimesheetDetailTriggerRecurssion = false;

    public void onBeforeInsert(List < TR1__Timesheet_Detail__c > triggernew) {
        TimesheetDetailTriggerRecurssion = true;
        updateTimesheetDetailWithCRS(triggernew,true);
    }

    public void onBeforeUpdate(List < TR1__Timesheet_Detail__c > triggernew, map < Id, TR1__Timesheet_Detail__c > triggerOldMap) {
        TimesheetDetailTriggerRecurssion = true;
        updateTimesheetDetailWithCRS(triggernew,false);
    }

    public void updateTimesheetDetailWithCRS(List < TR1__Timesheet_Detail__c > triggernew, Boolean isInsert) {
        set < Id > setClosingReportId = new set < Id > ();
        map < Id, map < date, List<Closing_Report_Schedule__c> >> mapCRtoMapWeekEndToCRS = new map < Id, map < date, List<Closing_Report_Schedule__c> >> ();
        Map <Id, Closing_Report_Schedule__c> crsIdToCRSMap = new Map <Id, Closing_Report_Schedule__c>();
        List<TR1__Timesheet_Detail__c> tdToBeInserted = new List<TR1__Timesheet_Detail__c>();

        for (TR1__Timesheet_Detail__c td: triggernew) {
            if ((isInsert && td.Closing_Report_Schedule__c == null && td.Closing_Report_Id__c != null) || (!isInsert && td.Closing_Report_Id__c != null)) {
                setClosingReportId.add(td.Closing_Report_Id__c);
            }
        }
        if (!setClosingReportId.isEmpty()) {
            for (TR1__Closing_Report__c cr: [Select TR1__Start_Date__c, TR1__End_Date__c,Pay_Type__c, Name, Id, (Select Id, Name, Closing_Report__c, Schedule_Date__c, Shift__c,CSD_End_Time__c,CSD_Start_Time__c,
                        Person_Placed__c, Schedule_Past_Contract_End_Date__c, WeekEndDate__c,Vacancy_Shift_Type__c,Vacancy_Schedule__c From Closing_Report_Schedules__r where Status__c != 'Cancelled')
                    From TR1__Closing_Report__c where Id in : setClosingReportId
                ]) {
                map < Date, List<Closing_Report_Schedule__c> > mapDateToCRS = new map < Date, List<Closing_Report_Schedule__c> > ();
                for (Closing_Report_Schedule__c crs: cr.Closing_Report_Schedules__r) {
                    crsIdToCRSMap.put(crs.Id,crs);
                    if(!mapDateToCRS.containsKey(crs.Schedule_Date__c)){
                        mapDateToCRS.put(crs.Schedule_Date__c, New List <Closing_Report_Schedule__c> { crs } );
                    }
                    else{
                        mapDateToCRS.get(crs.Schedule_Date__c).add(crs);
                    }
                }
                 System.debug('mapDateToCRS>>> '+mapDateToCRS);
                mapCRtoMapWeekEndToCRS.put(cr.Id, mapDateToCRS);
            }

            system.debug('===mapCRtoMapWeekEndToCRS:' + mapCRtoMapWeekEndToCRS);
            system.debug('===isInsert:' + isInsert);
            if (!mapCRtoMapWeekEndToCRS.isEmpty()) {
                for (TR1__Timesheet_Detail__c td: triggernew) {
                    if(isInsert) {
                        if (mapCRtoMapWeekEndToCRS.get(td.Closing_Report_Id__c) != null && mapCRtoMapWeekEndToCRS.get(td.Closing_Report_Id__c).get(td.TR1__Date__c)!=null) {
                            List<Closing_Report_Schedule__c> crsTempList = mapCRtoMapWeekEndToCRS.get(td.Closing_Report_Id__c).get(td.TR1__Date__c);
                            if (!crsTempList.isEmpty()) {
                                for(Integer i=0;i<crsTempList.size();i++){
                                    if(i==0){
                                        td.Populated_By__c = 'Update : TimesheetDetailTriggerHandler';
                                        setTimesheetData(crsTempList[i],td,isInsert);
                                        System.debug('===td=after set Data=='+td);
                                    }
                                    else{
                                        TR1__Timesheet_Detail__c tempTD = new TR1__Timesheet_Detail__c();
                                        tempTD.Populated_By__c = 'Insert : TimesheetDetailTriggerHandler';
                                        setTimesheetData(crsTempList[i],tempTD, isInsert);
                                        tempTD.TR1__Date__c=crsTempList[i].Schedule_Date__c;
                                        tempTD.TR1__Day__c=TimesheetUtility.dayOfDate(crsTempList[i].Schedule_Date__c);
                                        tempTD.TR1__Timesheet__c = td.TR1__Timesheet__c;
                                        tdToBeInserted.add(tempTD);
                                    }
                                }
                            }
                        }
                    }
                    else {
                      system.debug('===isNotInsert:' + isInsert);
                        if(String.isBlank(td.Closing_Report_Schedule__c)) {
                          system.debug('CRS Not Found');
                            td.Populated_By__c = 'Emptied CRS : TimesheetDetailTriggerHandler';
                            td.crs_name__c = null;
                            td.Half_Day__c = false;
                            //Test for W-4222976
                            td.DayShift__c = false;
                            td.TR1__Regular_Hours__c = td.TR1__Regular_Hours__c;
                        }
                        else if(crsIdToCRSMap.containsKey(td.Closing_Report_Schedule__c)) {
                          system.debug('td>>>0 '+ td);
                            setTimesheetData(crsIdToCRSMap.get(td.Closing_Report_Schedule__c),td,isInsert);
                            system.debug('td>>>1 '+ td);
                        }
                    }
                }// end for trigger.new
                System.debug('===tdToBeInserted==='+tdToBeInserted);
                if(!tdToBeInserted.isEmpty()){
                    Database.insert(tdToBeInserted,false);
                }
            }
        }
    }
    private void setTimesheetData(Closing_Report_Schedule__c crsTemp,TR1__Timesheet_Detail__c td, Boolean isInsert){
        td.Closing_Report_Schedule__c = crsTemp.Id;
        td.crs_name__c = crsTemp.Name;
        td.Half_Day__c = false;
        //Test for W-4222976
        td.DayShift__c = false;
        //td.TR1__Regular_Hours__c = null;
        system.debug('Shift Type --'+crsTemp.Vacancy_Shift_Type__c);
        if( crsTemp.Vacancy_Schedule__c!=null && (crsTemp.Vacancy_Shift_Type__c == 'AM' || crsTemp.Vacancy_Shift_Type__c == 'PM')){
            td.Half_Day__c = True;
        }
        else if( crsTemp.Vacancy_Schedule__c!=null && crsTemp.Vacancy_Shift_Type__c == 'Hourly'){
            Closing_Report_Schedule__c tempCRS = crsTemp;
            if(tempCRS.CSD_End_Time__c!=null &&  tempCRS.CSD_Start_Time__c!=null ){
                Long dt1Long = tempCRS.CSD_End_Time__c.getTime();
                Long dt2Long = tempCRS.CSD_Start_Time__c.getTime();
                system.debug('dt1Long--'+dt1Long+'dt2Long--'+dt2Long);
                Long milliseconds = dt1Long - dt2Long ;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Double divBy60 = 60;
                Double hours = minutes / divBy60;
                if(isInsert)
                  td.TR1__Regular_Hours__c = hours;
                 system.debug('td>>>2 '+ td);
            }else {
                td.AddError('Start time and End time are not present on candidate availablitily record ');
            }
        }else if( crsTemp.Vacancy_Schedule__c!=null && crsTemp.Vacancy_Shift_Type__c == 'Daily'){
            //Test for W-4222976
            td.DayShift__c = True;
        }
    }
}