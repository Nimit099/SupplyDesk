//  created on 12-16-2015 by Bashetty Naveen to populating closing report details from contact when it saving and update it while contact update 

public class ClosingReportTriggerHelper {
    public static Boolean FromJobboard = False;
    public static Boolean createTimesheetsForPastOrThisWeekFlag = False;
    
    public static void bulkBookingfromJobboard(List <TR1__Closing_Report__c> crlist){
        database.setSavepoint();
        set<ID> PPIds = new set<ID> ();
        set<ID> VACIds = new set<ID> ();
        List<Closing_Report_Schedule__c> crsList = new List<Closing_Report_Schedule__c>();
        List<Candidate_Availability__c> canAvailList = new List<Candidate_Availability__c>();
        Map<Id,Candidate_Availability__c>canVaccAvail = new Map<Id,Candidate_Availability__c>();
        Map<Date,Vacancy_D2D__c>dateJSMap = new Map<Date,Vacancy_D2D__c>();
        // for(TR1__Closing_Report__c cr : crlist){
        //     PPIds.add(cr.TR1__Person_Placed__c);
        //     VACIds.add(cr.TR1__Job__c);
        // }
        List<Vacancy_D2D__c> vacScheduleList= [select Id,Name,Vacancy__c,Vacancy_Date__c,Start_Date_Time__c,End_Date_Time__c from Vacancy_D2D__c where Vacancy__c =:crlist[0].TR1__Job__c and Vacancy_Date__c >= :crlist[0].TR1__Start_Date__c and Vacancy_Date__c <= :crlist[0].TR1__End_Date__c ];
        
        for(Vacancy_D2D__c vacc: vacScheduleList){
            Candidate_Availability__c canAvail = new Candidate_Availability__c();
            canAvail = new Candidate_Availability__c(Candidate__c = crlist[0].TR1__Person_Placed__c, End_Date__c=vacc.Vacancy_Date__c, Start_Date__c=vacc.Vacancy_Date__c, Start_Date_Time__c=vacc.Start_Date_Time__c, End_Date_Time__c=vacc.End_Date_Time__c);
            canAvailList.add(canAvail);
            dateJSMap.put(vacc.Vacancy_Date__c,vacc);
        }
        Database.SaveResult[] srList = database.insert(canAvailList, false) ;
        for(Candidate_Availability__c csd :[select Id,Name,Candidate__c,Start_Date__c,Start_Date_Time__c,End_Date_Time__c from Candidate_Availability__c where Candidate__c =:crlist[0].TR1__Person_Placed__c and Start_Date__c >= :crlist[0].TR1__Start_Date__c and Start_Date__c <= :crlist[0].TR1__End_Date__c]){
            if(dateJSMap.containskey(csd.Start_Date__c) && dateJSMap.get(csd.Start_Date__c).Start_Date_Time__c >= csd.Start_Date_Time__c &&  dateJSMap.get(csd.Start_Date__c).Start_Date_Time__c <= csd.End_Date_Time__c){
                //system.debug('canVaccAvail-->'+canVaccAvail.get(vacc.Id).Id);
                Closing_Report_Schedule__c CRS = new Closing_Report_Schedule__c();
                CRS.Schedule_Date__c = dateJSMap.get(csd.Start_Date__c).Vacancy_Date__c;
                CRS.Closing_Report__c  = crlist[0].Id;
                CRS.Candidate_Availability__c = csd.Id;
                CRS.Vacancy_Schedule__c = dateJSMap.get(csd.Start_Date__c).Id;
                CRS.Status__c  = 'Booked';
                crsList.add(CRS);    
            }
        }
        Database.SaveResult[] srList2 = database.insert(crsList, True) ;
    }
    
    public static void updateCRS(List <TR1__Closing_Report__c> crlist, Map<Id, TR1__Closing_Report__c> crOldMap,Map<Id,TR1__Closing_Report__c> crNewMap){
        set<ID> CRIds = new set<ID> ();

        for(TR1__Closing_Report__c cr : crlist){
            if(cr.Status__c != crOldMap.get(cr.Id).Status__c && cr.Status__c=='Cancelled')
                CRIds.add(cr.Id);
        }
        List<Closing_Report_Schedule__c> crsList = [select Id , Name , Status__c, Closing_Report__c From Closing_Report_Schedule__c where Closing_Report__c IN: CRIds];
        for(Closing_Report_Schedule__c crs: crsList){
            crs.Status__c = 'Cancelled';
            //crs.Reason_for_Cancellation__c = crNewMap.get(crs.Closing_Report__c).Reason_for_Cancelling_the_Job__c;
        }
        update crsList; 
    } 
    
    public static void updateClientStatus(List <TR1__Closing_Report__c> crlist){
        set<ID> CRaccIds = new set<ID> ();

        for(TR1__Closing_Report__c cr : crlist){
            if(cr.TR1__Account__c != null)
                CRaccIds.add(cr.TR1__Account__c);
        }
        List<Account> accList = [select Id, Name, Status__c, Last_Closing_Report_Created_Date__c From Account where Id IN: CRaccIds];
        if(accList.size()>0){
            for(Account acc: accList){
                acc.Status__c = 'Client';
                acc.Last_Closing_Report_Created_Date__c = Date.Today();
                //crs.Reason_for_Cancellation__c = crNewMap.get(crs.Closing_Report__c).Reason_for_Cancelling_the_Job__c;
            }
            update accList; 
        }
        
    } 
    
    public static void createTimesheetsForPastOrThisWeek(List <TR1__Closing_Report__c> recordNewList) {
    	
    	//added by Manmeet to find if Timesheet was already created for the CR
    	Map<String, TR1__Timesheet__c> mapJobMaxTimesheetData = new Map<String, TR1__Timesheet__c>();
    	Set<String> setJobs = new Set<String>();
    	for(TR1__Closing_Report__c cr : [Select Id, TR1__Job__c From TR1__Closing_Report__c where Id in : recordNewList]){
    		setJobs.add(cr.TR1__Job__c);
    	}
    	for(TR1__Job__c job : [Select Id, (Select Id, TR1__Week_Ending__c from TR1__Timesheets__r 
    									order by TR1__Week_Ending__c DESC 
    									limit 1) 
    									From TR1__Job__c where Id in : setJobs]){
			if(job.TR1__Timesheets__r.size() > 0){
				mapJobMaxTimesheetData.put(job.id, job.TR1__Timesheets__r[0]);	
			}
    	}
    	
        for(TR1__Closing_Report__c cr : recordNewList){
            Date nextStartDate;
             if(cr.Timesheet_Frequency__c=='Calendar Monthly'){
            nextStartDate=System.today().toStartOfMonth().addMonths(1);  
            }
            else{
                Date d = System.today();
				Datetime dt = (DateTime)d;
				String dayOfWeek = dt.format('u');
                if(dayOfWeek=='6' || dayOfWeek=='7'){
                     nextStartDate=System.today().toStartOfWeek().addDays(14);
                }
                else{
                     nextStartDate=System.today().toStartOfWeek().addDays(7);
                }
                    
            } 
            
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            if((cr.TR1__Start_Date__c < nextStartDate || (mapJobMaxTimesheetData.containsKey(cr.TR1__Job__c) && cr.TR1__Start_Date__c <= mapJobMaxTimesheetData.get(cr.TR1__Job__c).TR1__Week_Ending__c)) 
            	&& cr.RecordTypeId == crconsultingId && cr.TR1__Generate_Timesheet__c == true && cr.TR1__Start_Date__c!=null && cr.TR1__End_Date__c!=null && cr.TR1__Assignment_Ended__c=='No'){   
                Date startDate = cr.Timesheet_Frequency__c=='Calendar Monthly'?cr.TR1__Start_Date__c.toStartOfMonth():cr.TR1__Start_Date__c.toStartOfWeek();
                
                    
                Date endDate = cr.TR1__End_Date__c < nextStartDate ? cr.TR1__End_Date__c : nextStartDate.addDays(-1);
                if(cr.TR1__Start_Date__c > nextStartDate){
                	endDate = cr.TR1__End_Date__c < mapJobMaxTimesheetData.get(cr.TR1__Job__c).TR1__Week_Ending__c ? cr.TR1__End_Date__c : mapJobMaxTimesheetData.get(cr.TR1__Job__c).TR1__Week_Ending__c.addDays(-1);
                }
                string str = TimesheetUtility.insertTimesheetDetail(cr,startDate,endDate);
            }
        }
    }
    
    public static void populateSmallestDate( List <TR1__Closing_Report__c> crlist, Map<Id, TR1__Closing_Report__c> OldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        for(TR1__Closing_Report__c oCls :crlist){
            if(oCls.TR1__Person_Placed__c != null && (OldMap == null || (OldMap != null && (oCls.TR1__Start_Date__c != oldMap.get(oCls.Id).TR1__Start_Date__c || oCls.TR1__Person_Placed__c != oldMap.get(oCls.Id).TR1__Person_Placed__c )))){
                contactMap.put(oCls.TR1__Person_Placed__c, null);
            }
            if(OldMap != null && oCls.TR1__Person_Placed__c != oldMap.get(oCls.Id).TR1__Person_Placed__c && oldMap.get(oCls.Id).TR1__Person_Placed__c != null){
                contactMap.put(oldMap.get(oCls.Id).TR1__Person_Placed__c, null);
            }
        }
        if(contactMap.size() > 0){
            contactMap = new map<Id, Contact>([Select Id, Placement_Start_Date__c from Contact where Id IN : contactMap.keySet()]);
            for(AggregateResult agr : [Select TR1__Person_Placed__c, MIN(TR1__Start_Date__c) TR1__Start_Date__c From TR1__Closing_Report__c WHERE TR1__Person_Placed__c IN :contactMap.keySet() GROUP BY TR1__Person_Placed__c]){
                Id contactId = (Id)agr.get('TR1__Person_Placed__c');
                Date crStartDate = (Date)agr.get('TR1__Start_Date__c');
                contactMap.get(contactId).Placement_Start_Date__c = crStartDate;
            }
            if(contactMap.size() >0){
                update contactMap.values();
            }
        }
    }
}