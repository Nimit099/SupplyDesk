public with sharing class ClosingReportSchedule_Helper {
    public static Boolean Execute_OnInsertAndDelete_ClosingReport = true;
    public static void updateCRDate(Map < Id, Closing_Report_Schedule__c > crScheduleMap) {
        
        set < id > crsId = new set < id > ();
        set < Id > crIdset = new set < id > ();
        
        
        //Loop through map values and add closing report and schedule ids to their respective sets
        for (Closing_Report_Schedule__c crs: crScheduleMap.values()) {
            crsId.add(crs.id);
            crIdset.add(crs.Closing_Report__c);
        }
        System.debug('crs.id:' + crsId);
        System.debug('crIdset:' + crIdset);
        
        
        List < Closing_Report_Schedule__c > crsList = new List < Closing_Report_Schedule__c > ();
        //Query the closing report schedules
        if (crsId.size() > 0) {
            crsList = [Select Closing_Report__c, Person_Placed__c, Schedule_Date__c, Shift__c from Closing_Report_Schedule__c where Closing_Report__c = : crIdset order by Schedule_Date__c];
        }
        System.debug('crsList::' + crsList);
        
        Map < Id, Date > minCRSMap = new Map < Id, Date > ();
        Map < Id, Date > maxCRSMap = new Map < Id, Date > ();
        //Loop through the closing report schedules and adding them to the map according to min and max
        if (crsList.size() > 0) {
            for (Closing_Report_Schedule__c crs: crsList) {
                
                if (!minCRSMap.containsKey(crs.Closing_Report__c)) {
                    minCRSMap.put(crs.Closing_Report__c, crs.Schedule_Date__c);
                }
                maxCRSMap.put(crs.Closing_Report__c, crs.Schedule_Date__c);
            }
        }
        
        System.debug('minCRSMap::' + minCRSMap);
        System.debug('maxCRSMap::' + maxCRSMap);
        
        List < TR1__Closing_Report__c > crToUpdate = new List < TR1__Closing_Report__c > ();
        List < TR1__Closing_Report__c > crToDelete = new List < TR1__Closing_Report__c > ();
        if (crIdset.size() > 0) {
            
            for (Id crId: crIdset) {
                TR1__Closing_Report__c cr = new TR1__Closing_Report__c(Id = crId, TR1__Start_Date__c = minCRSMap.get(crId), Contract_End_Date__c = maxCRSMap.get(crId));
                if (cr.TR1__Start_Date__c == null && cr.Contract_End_Date__c == null) {
                    crToDelete.add(cr);
                }
                crToUpdate.add(cr);
            }
        }
        
        System.debug('crToUpdate::' + crToUpdate);
        
        if (crToUpdate.size() > 0) {
            update crToUpdate;
        }
        if (crToDelete.size() > 0) {
            //      delete crToDelete;
        }
    }
    
    public static void updateCandidateStatusOnCRSDelete(List < Closing_Report_Schedule__c > crsList) {
        
        
        set < id > closingreportIdset = new set < id > ();
        for (Closing_Report_Schedule__c crs: crsList) {
            
            if (crs.Schedule_Date__c == System.today()) {
                closingreportIdset.add(crs.Closing_Report__c);
            }
        }
        
        set < id > contactIdset = new set < id > ();
        if (closingreportIdset.size() > 0) {
            List < TR1__Closing_Report__c > crList = [Select id, TR1__Person_Placed__c
                                                      from TR1__Closing_Report__c
                                                      where id = : closingreportIdset
                                                      and Booking_Type__c != 'Extra Duties'
                                                     ];
            
            if (crList.size() > 0) {
                
                for (TR1__Closing_Report__c cr: crList) {
                    contactIdset.add(cr.TR1__Person_Placed__c);
                }
            }
        }
        
        List < Contact > contactListToUpdate = new List < Contact > ();
        
        if (contactIdset.size() > 0) {
            
            //   List < Candidate_Availability_D2D__c > candidateD2dList = [Select Availability_Date__c, Candidate_Availability__r.Candidate__c, Closing_Report_Schedule__c, Closing_Report_Schedule_Secondary__c
            //    from Candidate_Availability_D2D__c
            //        where Candidate_Availability__r.Candidate__c = : contactIdset
            //       and Availability_Date__c = : System.today()
            //  ];
            
            set<id> conIdset = new set<id>();
            //     if (candidateD2dList.size() > 0) {
            //          for (Candidate_Availability_D2D__c d2d: candidateD2dList) {
            
            //             if (d2d.Closing_Report_Schedule__c == null && d2d.Closing_Report_Schedule_Secondary__c == null) {
            
            //     conIdset.add(d2d.Candidate_Availability__r.Candidate__c);
            //    }
            ///            }
            //       }
            if(conIdset.size()>0){
                for(Id tempconId : conIdset){
                    Contact con = new Contact(id = tempconId, TR1__Candidate_Status__c = 'Available');
                    contactListToUpdate.add(con);
                }
            }
        }
        if (contactListToUpdate.size() > 0) {
            update contactListToUpdate;
        }
    }
    
    /******************************For mapping CRS records with Timesheet Details***********************/
    public static void mapCRSwithTimesheetDetails(List < Closing_Report_Schedule__c > crsList) {
        Set < Id > setCRIds = new Set < Id > ();
        map < Id, map < date, List<TR1__Timesheet_Detail__c> >> mapCRwithDateWithTimesheetDetail = new map < Id, map < date, List<TR1__Timesheet_Detail__c> >> ();
        
        List < TR1__Timesheet_Detail__c > toBeUpdatedTD = new List < TR1__Timesheet_Detail__c > ();
        List < TR1__Timesheet_Detail__c > toBeInsertedTD = new List < TR1__Timesheet_Detail__c > ();
        
        //17May2017:Satrang:Added Logic to Create Additional TD for Additional CRS on SingleDay
        Set <Id> existingTSDetailIdSet = New Set <Id>();
        List<TR1__Timesheet_Detail__c> insertTDList = New List<TR1__Timesheet_Detail__c>();
        Map<String,Closing_Report_Schedule__c> dupCRSMap = New Map<String,Closing_Report_Schedule__c>();
        //END
        
        for (Closing_Report_Schedule__c crs: crsList) {
            setCRIds.add(crs.Closing_Report__c);
        }
        
        //system.debug('mapCRwithDateandCRS: ' + mapCRwithDateandCRS);
        if (!setCRIds.isEmpty()) {
            for (TR1__Timesheet_Detail__c td: [Select Id, TR1__Timesheet__c, TR1__Date__c, TR1__Day__c, Closing_Report_Schedule__c, Closing_Report_Id__c
                                               From TR1__Timesheet_Detail__c t where TR1__Timesheet__r.TR1__Closing_Report__c!=null and TR1__Timesheet__r.TR1__Closing_Report__c in : setCRIds
                                              ]) {
                                                  if (mapCRwithDateWithTimesheetDetail.get(td.Closing_Report_Id__c) != null) {
                                                      if(mapCRwithDateWithTimesheetDetail.get(td.Closing_Report_Id__c).containsKey(td.TR1__Date__c)){
                                                          mapCRwithDateWithTimesheetDetail.get(td.Closing_Report_Id__c).get(td.TR1__Date__c).add(td);
                                                      }
                                                      else
                                                          mapCRwithDateWithTimesheetDetail.get(td.Closing_Report_Id__c).put(td.TR1__Date__c, New List<TR1__Timesheet_Detail__c> {td });
                                                      
                                                  } else {
                                                      map < date, List<TR1__Timesheet_Detail__c> > tempmap = new map < date, List<TR1__Timesheet_Detail__c> > ();
                                                      tempmap.put(td.TR1__Date__c, new List<TR1__Timesheet_Detail__c>{td});
                                                      mapCRwithDateWithTimesheetDetail.put(td.Closing_Report_Id__c, tempmap);
                                                  }
                                              }
            system.debug('mapCRwithDateWithTimesheetDetail: ' + mapCRwithDateWithTimesheetDetail);
            if (!mapCRwithDateWithTimesheetDetail.isEmpty()) {
                for (Closing_Report_Schedule__c crs: crsList) {
                    if(crs.Status__c=='Booked') {
                        system.debug('CR::' + crs.Closing_Report__c + ' ScheduleDate:' + crs.Schedule_Date__c);
                        if (mapCRwithDateWithTimesheetDetail.get(crs.Closing_Report__c) != null) {
                            system.debug('mapCRwithDateWithTimesheetDetail::::' + mapCRwithDateWithTimesheetDetail.get(crs.Closing_Report__c));
                            if (mapCRwithDateWithTimesheetDetail.get(crs.Closing_Report__c).get(crs.Schedule_Date__c) != null) {
                                system.debug('mapCRwithDateWithTimesheetDetail::::::::' + mapCRwithDateWithTimesheetDetail.get(crs.Closing_Report__c).get(crs.Schedule_Date__c));
                                Boolean isFound = false;
                                Id tsId = null;
                                for(TR1__Timesheet_Detail__c tempTD : mapCRwithDateWithTimesheetDetail.get(crs.Closing_Report__c).get(crs.Schedule_Date__c)){
                                    tsId = tempTD.TR1__Timesheet__c;
                                    if(tempTD.Closing_Report_Schedule__c!=null) continue;
                                    tempTD.Populated_By__c = 'Update : ClosingReportSchedule_Helper';
                                    tempTD.Closing_Report_Schedule__c = crs.Id;
                                    tempTD.crs_name__c = crs.Name;
                                    setTimesheetData(crs,tempTD);
                                    toBeUpdatedTD.add(tempTD);
                                    isFound = true;
                                    break;
                                }
                                if(!isFound) {
                                    System.debug('===existingTSDetailIdSet==='+existingTSDetailIdSet);
                                    TR1__Timesheet_Detail__c tempTD = New TR1__Timesheet_Detail__c();
                                    tempTD.Populated_By__c = 'Insert : ClosingReportSchedule_Helper';
                                    tempTD.TR1__Date__c=crs.Schedule_Date__c;
                                    tempTD.TR1__Day__c=TimesheetUtility.dayOfDate(crs.Schedule_Date__c);
                                    tempTD.TR1__Timesheet__c = tsId;
                                    setTimesheetData(crs,tempTD);
                                    toBeInsertedTD.add(tempTD);
                                }
                            }
                        }
                    }
                }
            }
            system.debug('===toBeUpdatedTD:' + toBeUpdatedTD);
            system.debug('====toBeInsertedTD:' + toBeInsertedTD);
            if (!toBeUpdatedTD.isEmpty()) {
                TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion = true;
                try {
                    update toBeUpdatedTD;
                } catch (Exception e) {
                    system.debug('-----update in TD------>' + e.getMessage()+e.getlinenumber());
                }
            }
            if(!toBeInsertedTD.isEmpty()){
                try{
                    insert toBeInsertedTD;
                }catch (Exception e) {
                    system.debug('--------insert in TD------------>' + e.getMessage()+e.getlinenumber());
                }
            }
        }
    }
    
    private static void setTimesheetData(Closing_Report_Schedule__c crsTemp,TR1__Timesheet_Detail__c td){
        td.Closing_Report_Schedule__c = crsTemp.Id;
        td.crs_name__c = crsTemp.Name;
        td.Half_Day__c = false;
        // Test for W-4222976
        td.DayShift__c = false;
        td.TR1__Regular_Hours__c = null;
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
                td.TR1__Regular_Hours__c = hours;
            }else {
                td.AddError('Start time and End time are not present on candidate availablitily record ');
            }
        }else if( crsTemp.Vacancy_Schedule__c!=null && crsTemp.Vacancy_Shift_Type__c == 'Daily'){
            //Test for W-4222976
            td.DayShift__c = True;
        }
    }
    
    public Static Boolean VALIDATE_DUPLICATECLOSINGREPORTSCHEDULE = true;
    public static void preventDuplicateCRS(List<Closing_Report_Schedule__c> list_crs){ //used in scheduler
        set<Date> date_set = new set<Date>();
        set<Id> canAvail_ids = new set<Id>();
        set<Id> vacAvail_ids = new set<Id>();
        set<Id> crs_ids = new set<Id>();
        Map<String,Id> Query_result_JSMap = new Map<String,Id>();
        Map<String,Id> Query_result_CSMap = new Map<String,Id>();
        for(Closing_Report_Schedule__c crs : list_crs){
            system.debug('CRs IDs are  -->'+crs.id);
            date_set.add(crs.Schedule_Date__c);
            canAvail_ids.add(crs.Candidate_Availability__c);
            vacAvail_ids.add(crs.Vacancy_Schedule__c);
            crs_ids.add(crs.Id);
        }
        system.debug('CRs IDs set -->'+crs_ids);
        
        for(Closing_Report_Schedule__c crs: [select Id,Closing_Report__c,Schedule_Date__c,Person_Placed__c,Candidate_Availability__c,Vacancy_Schedule__c from Closing_Report_Schedule__c
                                             where (Candidate_Availability__c IN: canAvail_ids or Vacancy_Schedule__c IN:vacAvail_ids) and ID NOT IN: crs_ids and Status__c='Booked']){
                                                 System.debug('Map Contetnst Keys --->'+crs.Candidate_Availability__c+'-'+crs.Vacancy_Schedule__c+'MAp Values ---->'+crs.Id);
                                                 Query_result_CSMap.put(crs.Candidate_Availability__c,crs.Id);
                                                 Query_result_JSMap.put(crs.Vacancy_Schedule__c,crs.Id);
                                             }
        for(Closing_Report_Schedule__c crs : list_crs){
            if(Query_result_CSMap.containsKey(crs.Candidate_Availability__c)){
                crs.addError('You can not add same closing report schedule. There is already a similar Closing Report schedule.');
            }
            if(Query_result_JSMap.containsKey(crs.Vacancy_Schedule__c)){
                crs.addError('You can not add same closing report schedule. There is already a similar Closing Report schedule.');
            }
        }
    }
    
    public static void splitCSDRecords(List<Closing_Report_Schedule__c> list_crs){                                       //used in scheduler
        List<Candidate_Availability__c> csdToInsertList = new List<Candidate_Availability__c>() ;
        List<Candidate_Availability__c> csdToUpdateist = new List<Candidate_Availability__c>() ;
        set<Id>csdSets = new set<Id>();
        Map<Id,Id> csdCandidatemap= new Map<Id,Id> ();
        // Map<Date,List<Closing_Report_Schedule__c>> mapcrsondate = new Map<Date, List<Closing_Report_Schedule__c>>();
        for(Closing_Report_Schedule__c crs : list_crs) {
            csdSets.add(crs.Candidate_Availability__c);
            /*if(mapcrsondate.ContainsKey(crs.Schedule_Date__c)){
mapcrsondate.get(crs.Schedule_Date__c).add(crs);
}else{
mapcrsondate.put(crs.Schedule_Date__c,new List<Closing_Report_Schedule__c>{crs});
}*/
        }
        for(Candidate_Availability__c csd : [select Id,candidate__c from Candidate_Availability__c where Id IN:csdSets]){
            csdCandidatemap.put(csd.Id,csd.candidate__c);
        }
        /*Map<Id,List<Candidate_Availability__c>> mapcrscs = new Map<Id,List<Candidate_Availability__c>>();
for(Date eachdate : mapcrsondate.keySet()){
if(mapcrsondate.get(eachdate).size()>0){
DateTime strattime;DateTime endtime;
for(Closing_Report_Schedule__c eachcrs : mapcrsondate.get(eachdate)){
if(strattime!=null && endtime!=null){
if((strattime>eachcrs.JSD_Start_Time__c && strattime>eachcrs.JSD_End_Time__c) && (endtime>eachcrs.JSD_Start_Time__c && endtime>eachcrs.JSD_End_Time__c)){
strattime = eachcrs.JSD_End_Time__c;endtime = strattime;
}else{
strattime = endtime; endtime = eachcrs.JSD_Start_Time__c;
}
}else{
strattime = eachcrs.JSD_Start_Time__c;endtime = eachcrs.JSD_End_Time__c;
}
csdToInsertList.add(new Candidate_Availability__c(Candidate__c=csdCandidatemap.get(eachcrs.Candidate_Availability__c), End_Date__c=eachcrs.Schedule_Date__c,Start_Date_Time__c = eachcrs.JSD_Start_Time__c,Type__c='Available', End_Date_Time__c = eachcrs.JSD_End_Time__c,Start_Date__c = eachcrs.Schedule_Date__c));
}
csdToUpdateist.add(new Candidate_Availability__c(Id=mapcrsondate.get(eachdate)[0].Candidate_Availability__c,Start_Date_Time__c = strattime, End_Date_Time__c = endtime));
}
}*/
        for(Closing_Report_Schedule__c crs : list_crs) {System.debug('VS ==>>'+ crs.Vacancy_Schedule__c+' CS ==>>'+ crs.Candidate_Availability__c);
                                                        //crs.adderror('Candidate Id '+crs.Person_Placed_Id__c);
                                                        if(crs.CSD_Start_Time__c == crs.JSD_Start_Time__c && crs.CSD_End_Time__c > crs.JSD_End_Time__c){
                                                            Candidate_Availability__c csdToUpdate = new Candidate_Availability__c(Start_Date_Time__c = crs.JSD_Start_Time__c, End_Date_Time__c = crs.JSD_End_Time__c, Id = crs.Candidate_Availability__c);
                                                            csdToUpdateist.add(csdToUpdate);  System.debug('from 1');
                                                            //crs.adderror('In 1st loop '+csdCandidatemap.get(crs.Candidate_Availability__c));
                                                            Candidate_Availability__c csdToInsert = new Candidate_Availability__c(Candidate__c=csdCandidatemap.get(crs.Candidate_Availability__c), End_Date__c=crs.Schedule_Date__c, Start_Date_Time__c = crs.JSD_End_Time__c,Type__c='Available', End_Date_Time__c = crs.CSD_End_Time__c, Start_Date__c = crs.Schedule_Date__c);
                                                            csdToInsertList.add(csdToInsert);
                                                        }
                                                        else if(crs.CSD_Start_Time__c < crs.JSD_Start_Time__c && crs.CSD_End_Time__c == crs.JSD_End_Time__c){
                                                            Candidate_Availability__c csdToInsert = new Candidate_Availability__c(Candidate__c=csdCandidatemap.get(crs.Candidate_Availability__c), End_Date__c=crs.Schedule_Date__c,Start_Date_Time__c = crs.CSD_Start_Time__c,Type__c='Available', End_Date_Time__c = crs.JSD_Start_Time__c, Start_Date__c = crs.Schedule_Date__c);
                                                            csdToInsertList.add(csdToInsert);System.debug('from 2');
                                                            //crs.adderror('In 2nd loop '+csdCandidatemap.get(crs.Candidate_Availability__c));
                                                            Candidate_Availability__c csdToUpdate = new Candidate_Availability__c(Start_Date_Time__c = crs.JSD_Start_Time__c, End_Date_Time__c = crs.JSD_End_Time__c, Id = crs.Candidate_Availability__c);
                                                            csdToUpdateist.add(csdToUpdate);
                                                        }
                                                        else if(crs.CSD_Start_Time__c < crs.JSD_Start_Time__c && crs.CSD_End_Time__c > crs.JSD_End_Time__c){
                                                            Candidate_Availability__c csdToInsertLeft = new Candidate_Availability__c(Candidate__c=csdCandidatemap.get(crs.Candidate_Availability__c), End_Date__c=crs.Schedule_Date__c,Start_Date_Time__c = crs.CSD_Start_Time__c,Type__c='Available', End_Date_Time__c = crs.JSD_Start_Time__c, Start_Date__c = crs.Schedule_Date__c);
                                                            csdToInsertList.add(csdToInsertLeft);System.debug('from 3');
                                                            //crs.adderror('In 3rd loop '+csdCandidatemap.get(crs.Candidate_Availability__c));
                                                            Candidate_Availability__c csdToUpdate = new Candidate_Availability__c(Start_Date_Time__c = crs.JSD_Start_Time__c, End_Date_Time__c = crs.JSD_End_Time__c, Id = crs.Candidate_Availability__c);
                                                            csdToUpdateist.add(csdToUpdate);
                                                            Candidate_Availability__c csdToInsertRight = new Candidate_Availability__c(Candidate__c=csdCandidatemap.get(crs.Candidate_Availability__c), End_Date__c=crs.Schedule_Date__c,Start_Date_Time__c = crs.JSD_End_Time__c,Type__c='Available', End_Date_Time__c = crs.CSD_End_Time__c,Start_Date__c = crs.Schedule_Date__c);
                                                            csdToInsertList.add(csdToInsertRight);
                                                        }
                                                       }
        
        if(!csdToUpdateist.isEmpty())
            update csdToUpdateist;
        if(!csdToInsertList.isEmpty())
            insert csdToInsertList;
        
        /*for(Closing_Report_Schedule__c crs : list_crs) {
for(Candidate_Availability__c each : csdToInsertList){
if(csdCandidatemap.get(crs.Candidate_Availability__c) == each.Candidate__c && crs.JSD_Start_Time__c == each.Start_Date_Time__c){
crs.Candidate_Availability__c = each.Id;
}
}
} */
    }
    
    public static void updateTimsheetDetailOnCRSDelete(map < Id, Closing_Report_Schedule__c > oldMap) {
        system.debug('*******updateTimsheetDetailOnCRSDelete********' + oldMap.keyset());
        List < TR1__Timesheet_Detail__c > listTimesheetDetailToUpdate = new List < TR1__Timesheet_Detail__c > ();
        for (Closing_Report_Schedule__c crs: [Select Id, (Select Id, Closing_Report_Schedule__c,
                                                          Closing_Report_Id__c, CRS_Name__c From Timesheet_Details__r)
                                              From Closing_Report_Schedule__c c
                                              where id in : oldMap.keyset()
                                             ]) {
                                                 for (TR1__Timesheet_Detail__c td: crs.Timesheet_Details__r) {
                                                     td.CRS_Name__c = null;
                                                     listTimesheetDetailToUpdate.add(td);
                                                 }
                                             }
        try {
            
            if (!listTimesheetDetailToUpdate.isEmpty()) {
                TimesheetDetailTriggerHandler.TimesheetDetailTriggerRecurssion = true;
                update listTimesheetDetailToUpdate;
            }
        } catch (Exception e) {
            system.debug('-------------------->' + e.getMessage());
        }
    }
    
    public static void updateClosingReportFiels(List<Closing_Report_Schedule__c> newList){
        set<Id> setClosingReport = new set<Id>();
        for(Closing_Report_Schedule__c oCRS : newList){
            if(oCRS.Closing_Report__c != NULL){
                setClosingReport.add(oCRS.Closing_Report__c);
            }
        }
        if(setClosingReport.size() > 0){
            handleClosingReportUpdate(setClosingReport);
        }
    }
    
    public static void updateCandidateStatus(List<Closing_Report_Schedule__c> newList, Map<Id, Closing_Report_Schedule__c> oldMap){
        Map<String, Contact> candidateMap = new Map<String, Contact>();
        for(Closing_Report_Schedule__c crs : newList){
            if(String.isNotBlank(crs.Person_Placed_Id__c) && String.isNotBlank(crs.LastTimeTriggerExecuted__c)
              	&& oldMap != null && crs.LastTimeTriggerExecuted__c != oldMap.get(crs.Id).LastTimeTriggerExecuted__c){
                if(crs.LastTimeTriggerExecuted__c == 'Started'){
                    candidateMap.put(crs.Person_Placed_Id__c, new Contact(id = crs.Person_Placed_Id__c, TR1__Candidate_Status__c = 'Assigned'));
                }else if(crs.LastTimeTriggerExecuted__c == 'Ended'){
                    candidateMap.put(crs.Person_Placed_Id__c, new Contact(id = crs.Person_Placed_Id__c, TR1__Candidate_Status__c = 'Available'));
                }
            }
        }
        if(candidateMap.values().size() > 0){
            update candidateMap.values();
        }
    }
    
    @future
    public Static void handleClosingReportUpdate(set<Id> setClosingReportId){
        if(setClosingReportId.size() > 0){
            list<TR1__Closing_Report__c> lstClosingReport = new list<TR1__Closing_Report__c>();
            map<Id,list<Closing_Report_Schedule__c>> mapClosingReportIdWiseClosingReportSchedule = new map<Id,list<Closing_Report_Schedule__c>>();
            for(Closing_Report_Schedule__c oCRS : [Select Id,Name,Closing_Report__c,Candidate_Availability__c,Candidate_Availability__r.Start_Date_Time__c,
                                                   		  Candidate_Availability__r.End_Date_Time__c 
                                                   From Closing_Report_Schedule__c 
                                                   Where Closing_Report__c IN : setClosingReportId]){
                if(!mapClosingReportIdWiseClosingReportSchedule.containsKey(oCRS.Closing_Report__c)){
                    mapClosingReportIdWiseClosingReportSchedule.put(oCRS.Closing_Report__c,new list<Closing_Report_Schedule__c>());
                }
                mapClosingReportIdWiseClosingReportSchedule.get(oCRS.Closing_Report__c).add(oCRS);
            }
            if(mapClosingReportIdWiseClosingReportSchedule.size() > 0){
                for(TR1__Closing_Report__c oClosingReport: [Select Id,Name,Booking_End_Time__c,Booking_Day__c,Booking_Start_Time__c,
                                                            	   TR1__Job__c,TR1__Job__r.Start_Time__c,TR1__Job__r.End_Time__c 
                                                            From TR1__Closing_Report__c 
                                                            Where Id IN :mapClosingReportIdWiseClosingReportSchedule.keyset()]){
                    if(mapClosingReportIdWiseClosingReportSchedule.containsKey(oClosingReport.id)){
                        String BookingDays = '';
                        oClosingReport.Booking_Start_Time__c = oClosingReport.TR1__Job__r.Start_Time__c;
                        oClosingReport.Booking_End_Time__c = oClosingReport.TR1__Job__r.End_Time__c;
                        for(Closing_Report_Schedule__c oCRS : mapClosingReportIdWiseClosingReportSchedule.get(oClosingReport.id)){
                            if(oCRS.Candidate_Availability__r.Start_Date_Time__c != null){
                                if(BookingDays == ''){
                                    BookingDays = oCRS.Candidate_Availability__r.Start_Date_Time__c.format('EEEE');
                                }else{
                                    BookingDays += ';' + oCRS.Candidate_Availability__r.Start_Date_Time__c.format('EEEE');
                                }
                            }
                        }
                        oClosingReport.Booking_Day__c = BookingDays;
                        lstClosingReport.add(oClosingReport);
                    }
                }
                if(lstClosingReport.size() > 0){
                    update lstClosingReport;
                }
            }
        }
    }
}