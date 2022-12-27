/************************************************************************************************************************
Class Name:            TRS_VacancyHelper
Created By: 
Created Date:          December 2014    
Description:           This is a helper class for VacancyTrigger written on TR1__Job__c object. This class contains the 
                       methods to perform various operations on insert or update of vacancy records.    
Modification History:  15 Dec 2013 >> Version 1.0 >> Created                
************************************************************************************************************************/
public class TRS_VacancyHelper {
    
    public static final String CONSULTING = 'Consulting';
    // Consulting Record Type Id
    public static final String CONSULTING_RTID = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get(CONSULTING).getRecordTypeId(); 
    
    public static Boolean EXECUTED_UPDATE_D2D_VACANCY = false;
    public static Boolean EXECUTED_UPDATE_VACANCY = false;
    
    /************************************************************************************************************************ 
    Method Name:       insertD2DVacancy
    Parameters:        List of vacancy records (TR1__Job__c)
    Retun type:        void 
    Description:       This method is used to create day to day vacancy records on the basis of start date, end date and 
                       applicable days of given vacancy record. 
    ************************************************************************************************************************/
    public static void insertD2DVacancy(List<TR1__Job__c> vacancyListFromTrigger){

        //List to hold the Vacancy records of Consulting record type.
        List<TR1__Job__c> vacancyList = new List<TR1__Job__c>();
        
        set<id> vacancyIdset = new set<id>();
        Map<Id, List<TR1__Job__c>> AccJobMap = new Map<Id ,List<TR1__Job__c>>();
        
        //Looping through the new Vacancy records and adding to the vacancyList as per the record type.    
        for(TR1__Job__c vacancy : vacancyListFromTrigger){
            if(vacancy.RecordTypeId == CONSULTING_RTID){
                vacancyList.add(vacancy);
                vacancyIdset.add(vacancy.id);
                List<TR1__Job__c> tempList = new List<TR1__Job__c>();
                if(AccJobMap.containsKey(vacancy.TR1__Account__c)){
                    tempList = AccJobMap.get(vacancy.TR1__Account__c);
                    tempList.add(vacancy);
                    AccJobMap.put(vacancy.TR1__Account__c ,tempList);
                }
                else{
                    tempList.add(vacancy);
                    AccJobMap.put(vacancy.TR1__Account__c ,tempList);                   
                }
            }
        }
        
        
        
        //Calling the helper class.    
        if(!vacancyList.isEmpty()){
            //List to hold the records which needs to be inserted.
            List<Vacancy_D2D__c> d2dVacancyInsertList = new List<Vacancy_D2D__c>();
            
            //Base saturday date used for Calculation.    
            Date oldDate = DATE.newInstance(2000, 1, 1);
        
            //Looping through the new vacancy list  
            for(TR1__Job__c vacancy : vacancyList){
                
                //Adding the applicable days to the set.
                Set<String> applicableDaysSet = new Set<String>();//Set to hold the values of applicable days.
                if(vacancy.Applicable_Days__c != null && vacancy.TR1__Estimated_Start_Date__c != null && vacancy.TR1__Estimated_End_Date__c != null){
                    applicableDaysSet.addAll(vacancy.Applicable_Days__c.split(';'));    
                    
                    //Checking whether there are any applicable days selected by the user.  
                    if(applicableDaysSet.size() > 0){
                        //Calculating the number of days between start date and end date.   
                        Integer actualNoOfDays = vacancy.TR1__Estimated_Start_Date__c.daysBetween(vacancy.TR1__Estimated_End_Date__c);
                        
                        //Looping through all the days between start date and end date.
                        for(Integer i = 0; i <= actualNoOfDays; i++){
                            Date startDateNew = vacancy.TR1__Estimated_Start_Date__c + i;
                            DateTime startDateTimeNew = DateTime.newInstance(startDateNew,Time.newInstance(0,0,0,0));
                            String dayOfWeek = startDateTimeNew.format('EEEE');
                            
                            //Checking if the day is there in applicable days selected by the user and creating the d2dVacancy record.  
                            if(applicableDaysSet.contains(dayOfWeek) && String.isNotBlank(vacancy.Start_Time__c) && String.isNotBlank(vacancy.End_Time__c)){
                            	
						    if(formatDateTimefromDate(startDateNew, vacancy.Start_Time__c) > formatDateTimefromDate(startDateNew, vacancy.End_Time__c)){
						              d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                                                    Vacancy__c=vacancy.Id,
                                                                                    Status__c='Open',
                                                                                    Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                    End_Date_Time__c = formatDateTimefromDate(startDateNew+1,vacancy.End_Time__c),
                                                                                    Vacancy_Date__c = startDateNew,
                                                                                    Shift__c = vacancy.Shift__c
                                                                                   )
						               						);
						        }else{
						                d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                                                    Vacancy__c=vacancy.Id,
                                                                                    Status__c='Open',
                                                                                    Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                    End_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.End_Time__c),
                                                                                    Vacancy_Date__c = startDateNew,
                                                                                    Shift__c = vacancy.Shift__c
                                                                                   )
						            								);
						        }
                                  /*  Vacancy_D2D__c d2dVacancy = new Vacancy_D2D__c(
                                                                                    Vacancy__c=vacancy.Id,
                                                                                    Status__c='Open',
                                                                                    Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                    End_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.End_Time__c),
                                                                                    Vacancy_Date__c = startDateNew,
                                                                                    Shift__c = vacancy.Shift__c
                                                                                   );*/
                                   // d2dVacancyInsertList.add(d2dVacancy);
                            }   
                        }
                    } 
                }       
            }
            //Inserting d2dVacancy records  
            if(!d2dVacancyInsertList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(d2dVacancyInsertList, true);
            }
        }
    }

    
    /**
    Update CR with Cancelled Status when job.status == Cancelled 
    **/
    public static void changeStatusOfCR(List < TR1__Job__c > Joblist, Map < Id, TR1__Job__c > jobOldMap) {
        set < ID > jobIDs = new set < ID > ();
        for(TR1__Job__c job: Joblist) {
            if((jobOldMap.get(job.Id).TR1__Status__c== 'Closed' ||jobOldMap.get(job.Id).TR1__Status__c== 'Open') && job.TR1__Status__c=='Cancelled')  // &
                jobIDs.add(job.Id);  
        }
        if(jobIDs!= null){
            List<TR1__Closing_Report__c> crList = new List<TR1__Closing_Report__c>();       
            for(TR1__Closing_Report__c cr : [select Id, TR1__Job__r.Name ,Status__c, TR1__Person_Placed__r.Name,TR1__Person_Placed__r.MobilePhone  from TR1__Closing_Report__c where TR1__Job__c  IN: jobIDs]){
                cr.Status__c = 'Cancelled';
                crList.add(cr);
            }
            if(crList.size()>0)
                update crList;
        }
        
    }
    
    
    
    /************************************************************************************************************************
    Method Name:       updateD2DVacancy
    Parameters:        List of vacancy D2D records and Map of Vacancy Id with vacancy Record
    Retun type:        void
    Description:       This method is used to delete/recreate Vacancy D2D records. 
    Scenarios:
        1. Start Date and End Date are changed
        2. Start Time and End Time are changed
        3. Applicablle Days are changed
    ************************************************************************************************************************/
    public static void updateD2DVacancyRecord (list<TR1__Job__c> vacancyList, map<Id,TR1__Job__c> oldVacancyMap){     
        
        Savepoint sp = Database.setSavepoint();

        List<Vacancy_D2D__c> d2dVacancyInsertList = new List<Vacancy_D2D__c>();
        set<id> vacancyIdset = new set<id>(); //Used to fetch Holiday record for that job
        
        for(TR1__Job__c vacancy : vacancyList){
            if(vacancy.TR1__Estimated_Start_Date__c == null || vacancy.TR1__Estimated_End_Date__c == null || 
               String.isBlank(vacancy.Applicable_Days__c) || String.isBlank(vacancy.Start_Time__c) || String.isBlank(vacancy.End_Time__c) || vacancy.RecordTypeId != CONSULTING_RTID){
                continue;
            }
            
            if(vacancy.Start_Time__c != oldVacancyMap.get(vacancy.id).Start_Time__c || vacancy.End_Time__c != oldVacancyMap.get(vacancy.id).End_Time__c
               || vacancy.TR1__Estimated_Start_Date__c != oldVacancyMap.get(vacancy.id).TR1__Estimated_Start_Date__c || vacancy.TR1__Estimated_End_Date__c != oldVacancyMap.get(vacancy.id).TR1__Estimated_End_Date__c
               || vacancy.Applicable_Days__c != oldVacancyMap.get(vacancy.id).Applicable_Days__c){
                vacancyIdset.add(vacancy.id);
            }
        }
        
        List<Vacancy_D2D__c> vacancyD2DToBeDeleted = [Select Shift__c,Status__c,Vacancy__c,Vacancy_Date__c, Closing_Report_Schedule__c from Vacancy_D2D__c where Vacancy__c IN :vacancyIdset];
        
        try{
            delete vacancyD2DToBeDeleted;
        }
        catch(Exception e){
            Database.rollback(sp);
            return;
        }
        
        
        // Creating a Map for set of holiday Dates
        
        //Base saturday date used for Calculation.    
        Date oldDate = DATE.newInstance(2000, 1, 1);
        
        //Looping through the new vacancy list  
        for(TR1__Job__c vacancy : vacancyList){
            
            if(vacancy.TR1__Estimated_Start_Date__c == null || vacancy.TR1__Estimated_End_Date__c == null || 
               String.isBlank(vacancy.Start_Time__c) || String.isBlank(vacancy.End_Time__c) || 
               String.isBlank(vacancy.Applicable_Days__c) || vacancy.RecordTypeId != CONSULTING_RTID){
                continue;
            }
            
            //Adding the applicable days to the set.
            Set<String> applicableDaysSet = new Set<String>();//Set to hold the values of applicable days.
            if(vacancy.Start_Time__c != oldVacancyMap.get(vacancy.id).Start_Time__c || vacancy.End_Time__c != oldVacancyMap.get(vacancy.id).End_Time__c
               || vacancy.TR1__Estimated_Start_Date__c != oldVacancyMap.get(vacancy.id).TR1__Estimated_Start_Date__c || vacancy.TR1__Estimated_End_Date__c != oldVacancyMap.get(vacancy.id).TR1__Estimated_End_Date__c 
               || vacancy.Applicable_Days__c != oldVacancyMap.get(vacancy.id).Applicable_Days__c){
                   
                applicableDaysSet.addAll(vacancy.Applicable_Days__c.split(';'));
                
                //Checking whether there are any applicable days selected by the user.  
                if(applicableDaysSet.size() > 0){
                    //Calculating the number of days between start date and end date.   
                    Integer actualNoOfDays = vacancy.TR1__Estimated_Start_Date__c.daysBetween(vacancy.TR1__Estimated_End_Date__c);
                    
                    //Looping through all the days between start date and end date.
                    for(Integer i = 0; i <= actualNoOfDays; i++){
                        Date startDateNew = vacancy.TR1__Estimated_Start_Date__c + i;
                        DateTime startDateTimeNew = DateTime.newInstance(startDateNew,Time.newInstance(0,0,0,0));
                        String dayOfWeek = startDateTimeNew.format('EEEE');
                        
                        //Checking if the day is there in applicable days selected by the user and creating the d2dVacancy record.  
                        if(applicableDaysSet.contains(dayOfWeek) && String.isNotBlank(vacancy.Start_Time__c) && String.isNotBlank(vacancy.End_Time__c)){
                               /* Vacancy_D2D__c d2dVacancy = new Vacancy_D2D__c(
                                                                                Vacancy__c=vacancy.Id,
                                                                                Status__c='Open',
                                                                                Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                End_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.End_Time__c),
                                                                                Vacancy_Date__c = startDateNew,
                                                                                Shift__c = vacancy.Shift__c
                                                                               );
                                                                               */
                               System.debug('>> '+formatDateTimefromDate(startDateNew, vacancy.Start_Time__c)+' <<>> '+formatDateTimefromDate(startDateNew, vacancy.End_Time__c));                              
                               if(formatDateTimefromDate(startDateNew, vacancy.Start_Time__c) > formatDateTimefromDate(startDateNew, vacancy.End_Time__c)){
						              d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                                                    Vacancy__c=vacancy.Id,
                                                                                    Status__c='Open',
                                                                                    Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                    End_Date_Time__c = formatDateTimefromDate(startDateNew+1,vacancy.End_Time__c),
                                                                                    Vacancy_Date__c = startDateNew,
                                                                                    Shift__c = vacancy.Shift__c
                                                                                   )
						               						);
						        }else{
						                d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                                                    Vacancy__c=vacancy.Id,
                                                                                    Status__c='Open',
                                                                                    Start_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.Start_Time__c),
                                                                                    End_Date_Time__c = formatDateTimefromDate(startDateNew,vacancy.End_Time__c),
                                                                                    Vacancy_Date__c = startDateNew,
                                                                                    Shift__c = vacancy.Shift__c
                                                                                   )
						            								);
						        }                                            
                               //d2dVacancyInsertList.add(d2dVacancy);
                        }   
                    }
                } 
            }       
        }
        //Inserting d2dVacancy records  
        if(!d2dVacancyInsertList.isEmpty()){
            Database.SaveResult[] srList = Database.insert(d2dVacancyInsertList, true);
        }
    }
    
    
    
    
    //This fuction is used to convert Date & Time picklist field to Date/Time
    static DateTime formatDateTimefromDate(Date dateVar,String startTime){
        
        String startDateTime = dateVar.format();
        
        String startTimeHour = startTime.split(':')[0];
        String startTimeMinute = startTime.split(':')[1].remove(' AM').remove(' PM');
        
        if (startTime.contains(' AM') && startTimeHour=='12') {
            startTimeHour = '00';
        }
        
        Datetime returnDt = Datetime.newInstance(
            dateVar.year(),
            dateVar.month(),
            dateVar.day(),
            Integer.valueOf(startTimeHour),
            Integer.valueOf(startTimeMinute),
            00
        );
        
        if (startTime.contains(' PM') && startTimeHour !='12') {
            
            returnDt = returnDt.addHours(12);
        }
        
        return returnDt;        
    }
    
}