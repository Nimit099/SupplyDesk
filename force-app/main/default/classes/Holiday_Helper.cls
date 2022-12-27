public with sharing class Holiday_Helper {
    
    
    /* On Insert of a new Holiday , all vacancies related to the holiday account are querried and its respective d2d records falling in the holiday range is deleted */
    
    public static Boolean Execute_OnInsert_Holiday = true;

    // Boolean variable to determine if Holiday needs to be applied for Vacancies
    public static Boolean APPLY_HOLIDAY_FOR_VACANCY = true;

    // Boolean variabe to determine if holiday needs to be created for Vacancies from Company
    public static Boolean CREATE_HOLIDAY_ON_VACANCY = true;

    public static Boolean Execute_OnDelete_Holiday = false; 

    // Boolea variable to determine if vacancytrigger will fire or not.
    public static boolean is_createHolidayOnVacancy_MethodFired = false;
    
    // Delete Vacancy Schedules for the Holiday record
    public static void deleteHolidaySchedules(List<Holiday__c> holidayList){
        
        set<Id> vacancyIdSet = new set<Id>();
        // Looping through the holiday List and adding accountId to a set
        for(Holiday__c holiday : holidayList){
            if(holiday.Account__c == null && holiday.Vacancy__c != null){
                vacancyIdSet.add(holiday.Vacancy__c);
            }
        }

        if(vacancyIdSet.isEmpty())
            return;

        // Map of Vacancy Id with the corresponding list of Schedule Records
        Map<Id, List<Vacancy_D2D__c>> VacD2DMap = new Map<Id, List<Vacancy_D2D__c>>();
        
        // Making a Map of vacencies associated with its list of D2D records
        for(Vacancy_D2D__c d2d : [Select Vacancy__c ,Vacancy_Date__c , Shift__c from Vacancy_D2D__c where Vacancy__c = :vacancyIdSet and Vacancy__r.RecordTypeId = : TRS_VacancyHelper.CONSULTING_RTID]){
            if(VacD2DMap.containsKey(d2d.Vacancy__c)){
                vacD2DMap.get(d2d.Vacancy__c).add(d2d);
            }
            else {
                VacD2DMap.put(d2d.Vacancy__c, new list<Vacancy_D2D__c>{d2d});
            }
        }
        
        if(vacD2DMap.isEmpty())
            return;
        
        // List of Schedule records to be deleted.
        Map<Id,Vacancy_D2D__c> d2dListToDelete = new Map<Id,Vacancy_D2D__c>();
        
        // Looping through the List of Holiday and adding D2D records to the List to be deleted
        for(Holiday__c holiday :holidayList){
            
            if(holiday.Vacancy__c != null && vacD2DMap.containsKey(holiday.Vacancy__c)) {

                for(Vacancy_D2D__c d2d : vacD2DMap.get(holiday.Vacancy__c)){
                    if(d2d.Vacancy_Date__c >= holiday.Start_Date__c && d2d.Vacancy_Date__c <= holiday.End_Date__c){
                        d2dListToDelete.put(d2d.Id,d2d);
                    }                           
                }
            }
        }

        // Delete d2d records
        if(d2dListToDelete.keySet().size() > 0){
            deleteCrsOnVacD2Ddelete(d2dListToDelete.values());
            delete d2dListToDelete.values();
        }
    }

    // Method to create holiday record under vacencies
    public static void createHolidayOnVacancy(List<Holiday__c> holidayList){
        set<id> accountIdset = new set<id>();
        List<TR1__Job__c> vacancyList = new List<TR1__Job__c>();
        List<Holiday__c> holidayListToinsert = new List<Holiday__c>();
        Map<Id , List<TR1__Job__c>> accvacListMap = new Map<Id , List<TR1__Job__c>>();

        // Loop through the holiday List and check if the acoount is populated and vacancy is null
        for(Holiday__c holid : holidayList){
            
            if(holid.Account__c != null && holid.Vacancy__c == null){
                accountIdset.add(holid.Account__c);
            }
        }

        // Querying all the vacancies related to the holiday account
        if(accountIdset.size() > 0){
            vacancyList = [Select id , TR1__Account__c, Booking_Type__c  from TR1__Job__c where TR1__Account__c = :accountIdset and RecordTypeId = : TRS_VacancyHelper.CONSULTING_RTID];   
        }
        
        // Making a map of Account Id with its associated vacencies
        for(TR1__Job__c job :vacancyList){
            List<TR1__Job__c> tempList = new List<TR1__Job__c>();
            if(accvacListMap.containsKey(job.TR1__Account__c)){
                tempList = accvacListMap.get(job.TR1__Account__c);
                tempList.add(job);
                accvacListMap.put(job.TR1__Account__c , tempList);
            }
            else {
                tempList.add(job);
                accvacListMap.put(job.TR1__Account__c , tempList);
            }
        }   

        //Loop through the holiday List
        for(Holiday__c holid : holidayList){
            List<TR1__Job__c> tempVacList = new List<TR1__Job__c>();

            if(accvacListMap.containsKey(holid.Account__c)){
                tempVacList = accvacListMap.get(holid.Account__c);
                for(TR1__Job__c job : tempVacList){
                    Holiday__c holiday = new Holiday__c(Name = holid.Name, Vacancy__c =  job.id, Start_Date__c = holid.Start_Date__c, End_Date__c = holid.End_Date__c);
                    holidayListToinsert.add(holiday);
                }
            }
        }

        // Create Holiday List for Vacancies
        if(holidayListToinsert.size() > 0){
            is_createHolidayOnVacancy_MethodFired = true;
            insert holidayListToinsert;
        }
    }

    // Method to update Holiday record on Vacancies if Holiday record on Account is updated.
    public static void updateVacancyHolidays(Map<Id , Holiday__c> newHolidayMap , Map<Id , Holiday__c> oldHolidayMap){

        set<id> accIdset = new set<id>();
        List<Holiday__c> holidayList = new List<Holiday__c>();
        

        for(Holiday__c holid : newHolidayMap.values()){
            if(holid.Account__c != null && holid.Vacancy__c == null){
                if(oldHolidayMap != null && (oldHolidayMap.get(holid.id).Start_Date__c != holid.Start_Date__c || oldHolidayMap.get(holid.id).End_Date__c != holid.End_Date__c)){
                    holidayList.add(holid);
                    accIdset.add(holid.Account__c);
                }
            }
        }

        // Querying all vacancies Associated with this account
        if(accIdset.size() > 0){

            // Map of Account Id with the List of Vacancies
            Map<Id , List<TR1__Job__c>> accVaccMap = new Map<Id , List<TR1__Job__c>>();
            set<id> vaccIdset = new set<id>();
            
            // Looping through the vacancies and adding them to a map
            for(TR1__Job__c job : [Select id , TR1__Account__c, Booking_Type__c  from TR1__Job__c where TR1__Account__c = :accIdset]){
                List<TR1__Job__c> tempList = new List<TR1__Job__c>();
                if(accVaccMap.containsKey(job.TR1__Account__c)){
                    tempList = accVaccMap.get(job.TR1__Account__c);
                    tempList.add(job);
                    accVaccMap.put(job.TR1__Account__c, tempList);
                }
                else {
                    tempList.add(job);
                    accVaccMap.put(job.TR1__Account__c, tempList);
                }
                vaccIdset.add(job.id);
            }
            
            // Map of Vacancy Id with the List of Holiday
            Map<Id , List<Holiday__c>> vacHolidayMap = new Map<Id , List<Holiday__c>>();
            
            // Loop through the holiday List and add them to a map of Vaciency and its related holiday
            for(Holiday__c holid: [Select Id , Start_Date__c ,End_Date__c,Account__c,Vacancy__c from Holiday__c where Vacancy__c = : vaccIdset]){
                List<Holiday__c> tempHolidayList = new List<Holiday__c>();
                if(vacHolidayMap.containsKey(holid.Vacancy__c)){
                    tempHolidayList = vacHolidayMap.get(holid.Vacancy__c);
                    tempHolidayList.add(holid);
                    vacHolidayMap.put(holid.Vacancy__c, tempHolidayList);
                }
                else {
                    tempHolidayList.add(holid);
                    vacHolidayMap.put(holid.Vacancy__c, tempHolidayList);
                }
            }
            
            // List of Vacancy Holidays to be updated.
            List<Holiday__c> holidayListToUpdate = new List<Holiday__c>();

            // Looping through the holiday List of which start date or end date has changed
            for(Holiday__c holid : holidayList){
                
                if(accVaccMap.containsKey(holid.Account__c)){

                    Holiday__c oldHoliday = oldHolidayMap.get(holid.Id);

                    // Get the Vacancies for this Holidays Account
                    for(TR1__Job__c job : accVaccMap.get(holid.Account__c)){
                        if(vacHolidayMap.containsKey(job.id)){
                            for(Holiday__c hol : vacHolidayMap.get(job.id)){
                                // Update the Dates only if the Start and End Date match with the Old Holiday records.
                                if(hol.Start_Date__c == oldHoliday.Start_Date__c && hol.End_Date__c == oldHoliday.End_Date__c) {
                                    hol.Start_Date__c = holid.Start_Date__c;
                                    hol.End_Date__c = holid.End_Date__c;
                                    holidayListToUpdate.add(hol);
                                }
                            }
                        }
                    }
                }
            }

            // Update the Holiday List
            if(holidayListToUpdate.size() > 0){
                update holidayListToUpdate;
            }
        }
    }

    //Method to delete all holiday records assocaited with vacencies if holiday record on Account is deleted
    public static void deleteHolidayOnVaccancy(List<Holiday__c> oldHolidayList){ 

        // Set of Account Ids
        set<id> accIdset = new set<id>();
        for(Holiday__c holid : oldHolidayList){
            if(holid.Account__c != null && holid.Vacancy__c == null)
                accIdset.add(holid.Account__c); 
        }

        if(accIdset.size() > 0){
            // Set of Vacancy Ids
            set<id> vaccIdset = new set<id>();
            
            // Map of Account and List of Job
            Map<Id, List<TR1__Job__c>> accVaccMap = new Map<Id, List<TR1__Job__c>>();
            
            // Looping through the vacancies and adding them to a map
            for(TR1__Job__c job : [Select id , TR1__Account__c, Booking_Type__c  from TR1__Job__c where TR1__Account__c = :accIdset and RecordTypeId = : TRS_VacancyHelper.CONSULTING_RTID]){
                List<TR1__Job__c> tempList = new List<TR1__Job__c>();
                if(accVaccMap.containsKey(job.TR1__Account__c)){
                    tempList = accVaccMap.get(job.TR1__Account__c);
                    tempList.add(job);
                    accVaccMap.put(job.TR1__Account__c , tempList);
                }
                else {
                    tempList.add(job);
                    accVaccMap.put(job.TR1__Account__c , tempList);
                }
                vaccIdset.add(job.id);
            }
            
            // Map of Vacancy Id and List of Holidays
            Map<Id , List<Holiday__c>> vacHolidayMap = new Map<Id , List<Holiday__c>>();
            
            // Loop through the holiday List and add them to a map of Vaciency and its related holiday
            for(Holiday__c holid : [Select Start_Date__c, End_Date__c, Account__c, Vacancy__c from Holiday__c where Vacancy__c = : vaccIdset]){
                List<Holiday__c> tempHolidayList = new List<Holiday__c>();
                if(vacHolidayMap.containsKey(holid.Vacancy__c)){
                    tempHolidayList = vacHolidayMap.get(holid.Vacancy__c);
                    tempHolidayList.add(holid);
                    vacHolidayMap.put(holid.Vacancy__c ,tempHolidayList);
                }
                else {
                    tempHolidayList.add(holid);
                    vacHolidayMap.put(holid.Vacancy__c ,tempHolidayList);
                }
            }

            list<Holiday__c> holidayListToDelete = new list<Holiday__c>();
            // Looping through Holiday Records which have been deleted.
            for(Holiday__c holid : oldHolidayList) {
                if(accVaccMap.containsKey(holid.Account__c)) {
                    for(TR1__Job__c job : accVaccMap.get(holid.Account__c)){
                        if(vacHolidayMap.containsKey(job.id)){
                            for(Holiday__c hol : vacHolidayMap.get(job.id)){
                                // If the Holiday Start and End Date matches, delete the Holiday
                                if(hol.Start_Date__c == holid.Start_Date__c && hol.End_Date__c == holid.End_Date__c) {
                                    holidayListToDelete.add(hol);
                                }
                            }
                        }
                    }
                }
            }

            if(holidayListToDelete.size() > 0){
                delete holidayListToDelete;
            }
        }
    }

    // Method to update d2d records of vacancy on update of Holiday on Vacancy
    public static void updateVacancyHolidaySchedules(Map<Id , Holiday__c> newHolidayMap , Map<Id , Holiday__c> oldHolidayMap){

        set<id> vaccIdset = new set<id>();
        List<Holiday__c> holidayList = new List<Holiday__c>(); 
        
        // Loop through and get the Holiday records which have Start Date or End Date changed and related to Vacancy.
        for(Holiday__c holid : newHolidayMap.values()){
            if(holid.Vacancy__c != null && holid.Account__c == null){
                if(oldHolidayMap != null && (oldHolidayMap.get(holid.id).Start_Date__c != holid.Start_Date__c || oldHolidayMap.get(holid.id).End_Date__c != holid.End_Date__c )){
                    vaccIdset.add(holid.Vacancy__c);
                    holidayList.add(holid);
                }   
            }
        }

        if(vaccIdSet.size() > 0){

            // Map of Vacancy Id with Schedule List
            Map<Id , List<Vacancy_D2D__c>> vacD2DMap = new Map<Id , List<Vacancy_D2D__c>>();
            for(Vacancy_D2D__c vacd2d : [Select Vacancy__c, Vacancy_Date__c from Vacancy_D2D__c where Vacancy__c = :vaccIdset and Vacancy__r.RecordTypeId = : TRS_VacancyHelper.CONSULTING_RTID]){
                System.debug('vacd2d:'+vacd2d);
                List<Vacancy_D2D__c> tempD2DList = new List<Vacancy_D2D__c>();
                if(vacD2DMap.containsKey(vacd2d.Vacancy__c)){
                    tempD2DList = vacD2DMap.get(vacd2d.Vacancy__c);
                    tempD2DList.add(vacd2d);
                    vacD2DMap.put(vacd2d.Vacancy__c ,tempD2DList);
                }
                else {
                    tempD2DList.add(vacd2d);
                    vacD2DMap.put(vacd2d.Vacancy__c ,tempD2DList);
                }
            }
            
            System.debug('vacD2DMap:'+vacD2DMap);
            // List of D2D records to be deleted.       
            List<Vacancy_D2D__c> d2dListToDelete = new List<Vacancy_D2D__c>();

            for(Holiday__c holiday : holidayList){
                System.debug('holiday:'+holiday);
                System.debug('map return'+vacD2DMap.get(holiday.Vacancy__c));
                if(holiday.Vacancy__c != null){
                    for(Vacancy_D2D__c d2d : vacD2DMap.get(holiday.Vacancy__c)) {
                        if(d2d.Vacancy_Date__c >= holiday.Start_Date__c && d2d.Vacancy_Date__c <= holiday.End_Date__c){
                            d2dListToDelete.add(d2d);
                        }
                    }
                }    
            }
            
            if(d2dListToDelete.size() > 0){
                deleteCrsOnVacD2Ddelete(d2dListToDelete);
                delete d2dListToDelete;
            }
        }   
    }
    
    // Method to create vacancy D2D records when a holiday record is deleted on Vacancy.
    public static void createD2DonVacancyOnHolidayDelete(List<Holiday__c> oldHolidayList){

        set<id> vaccId = new set<id>();
        List<TR1__Job__c> jobList = new List<TR1__Job__c>();
        List<Vacancy_D2D__c> d2dList = new List<Vacancy_D2D__c>();
        Map<Id , List<Vacancy_D2D__c>> VacD2DMap = new Map<Id , List<Vacancy_D2D__c>>();
        Map<Date , List<Vacancy_D2D__c>> VacD2DdateMap = new Map<Date , List<Vacancy_D2D__c>>();
        List<Vacancy_D2D__c> d2dListToInsert = new List<Vacancy_D2D__c>();

        for(Holiday__c hol : oldHolidayList){
            if(hol.Vacancy__c != null && hol.Account__c == null){
                vaccId.add(hol.Vacancy__c); 
            }
        }
        
        // Querry VacD2D and Vacancy Records
        if(vaccId.size() > 0){
            jobList = [Select id , TR1__Account__c, Booking_Type__c  from TR1__Job__c where id = :vaccId];
            d2dList = [Select id,Vacancy__c,Vacancy_Date__c,Vacancy__r.Monday_s_Shift__c,Vacancy__r.Tuesday_s_Shift__c,
                                        Vacancy__r.Wednesday_s_Shift__c,Vacancy__r.Thursday_s_Shift__c,
                                        Vacancy__r.Friday_s_Shift__c,Vacancy__r.Saturday_s_Shift__c,Vacancy__r.Sunday_s_Shift__c
                                        from Vacancy_D2D__c where Vacancy__c = :vaccId];    
        }
    
        // Adding values to Vac D2D map
        if(d2dList.size() > 0){
            for(Vacancy_D2D__c d2d : d2dList){
                List<Vacancy_D2D__c> tempList = new List<Vacancy_D2D__c>();
                if(VacD2DMap.containsKey(d2d.Vacancy__c)){
                    tempList = VacD2DMap.get(d2d.Vacancy__c);
                    tempList.add(d2d);
                    VacD2DMap.put(d2d.Vacancy__c ,tempList);
                }
                else {
                    tempList.add(d2d);
                    VacD2DMap.put(d2d.Vacancy__c ,tempList);
                }
            }
        }
        
        // Adding values to D2D map with respective dates
        if(d2dList.size() > 0){
            for(Vacancy_D2D__c d2d : d2dList){
                List<Vacancy_D2D__c> tempList = new List<Vacancy_D2D__c>();
                if(VacD2DdateMap.containsKey(d2d.Vacancy_Date__c)){
                    tempList = VacD2DdateMap.get(d2d.Vacancy_Date__c);
                    tempList.add(d2d);
                    VacD2DdateMap.put(d2d.Vacancy_Date__c ,tempList);
                }
                else {
                    tempList.add(d2d);
                    VacD2DdateMap.put(d2d.Vacancy_Date__c ,tempList);
                }
            }
        }
        
        // Loop through Holiday list and create D2D records
        for(Holiday__c hol : oldHolidayList){

            Integer actualNoOfDays = hol.Start_Date__c.daysBetween(hol.End_Date__c);
            String shift;
            List<Vacancy_D2D__c> tempd2dList = new List<Vacancy_D2D__c>();
            for(integer i = 0; i <= actualNoOfDays; i++){
                Date startDateNew = hol.Start_Date__c + i;
                DateTime selectedDate = startDateNew;
                String selectedDay = selectedDate.format('EEEE');
                
                if(!VacD2DdateMap.containsKey(startDateNew)){
                    if(VacD2DMap.containsKey(hol.Vacancy__c)){
                        tempd2dList = vacD2DMap.get(hol.Vacancy__c);

                        for(Vacancy_D2D__c d2dRec : tempd2dList){
                            if(selectedDay == 'Monday' && d2dRec.Vacancy__r.Monday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Monday_s_Shift__c;
                            }
                            else if (selectedDay == 'Tuesday' && d2dRec.Vacancy__r.Tuesday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Tuesday_s_Shift__c;
                            }
                            else if (selectedDay == 'Wednesday' && d2dRec.Vacancy__r.Wednesday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Wednesday_s_Shift__c;
                            }
                            else if( selectedDay == 'Thursday' && d2dRec.Vacancy__r.Thursday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Thursday_s_Shift__c;
                            }
                            else if(selectedDay == 'Friday' && d2dRec.Vacancy__r.Friday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Friday_s_Shift__c;
                            }
                            else if(selectedDay == 'Saturday' && d2dRec.Vacancy__r.Saturday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Saturday_s_Shift__c;
                            }
                            else if(selectedDay == 'Sunday' && d2dRec.Vacancy__r.Sunday_s_Shift__c != null){
                                shift = d2dRec.Vacancy__r.Sunday_s_Shift__c ; 
                            }
                        }
                    }
                    // If shift does not exist for the paticular day , D2D record would not be created.
                    if(String.isNOTBlank(shift)){
                        Vacancy_D2D__c d2d = new Vacancy_D2D__c(Vacancy__c = hol.Vacancy__c , Vacancy_Date__c = startDateNew ,Shift__c = shift);
                        d2dListToInsert.add(d2d);   
                    }
                    
                }
            }
        }
        // inserting D2D records
        if(d2dListToInsert.size() > 0){
            insert d2dListToInsert;
        }
    }
    
    // Method executes when holiday record on vacancy is updated
    public static void CreateD2DonHolidayUpdate(Map<Id , Holiday__c> newHolidayMap , Map<Id , Holiday__c> oldHolidayMap){
        
        List<Holiday__c> holidayList = new List<Holiday__c>();
        List<Holiday__c> oldHolidayList = new List<Holiday__c>();
        Map<Date , List<Holiday__c>> holidayDateMap = new Map<Date , List<Holiday__c>>();
        set<id> vaccIdset = new set<id>();
        List<Vacancy_D2D__c> d2dList = new List<Vacancy_D2D__c>();
        Map<Id , List<Vacancy_D2D__c>> VacD2DMap = new Map<Id , List<Vacancy_D2D__c>>();
        List<Vacancy_D2D__c> d2dListToInsert = new List<Vacancy_D2D__c>();
        
        
        for(Holiday__c holid : newHolidayMap.values()){
            if(holid.Vacancy__c != null && holid.Account__c == null && oldHolidayMap != null && (oldHolidayMap.get(holid.id).Start_Date__c != holid.Start_date__c || oldHolidayMap.get(holid.id).End_Date__c != holid.End_Date__c )){
                holidayList.add(holid);
                vaccIdset.add(holid.Vacancy__c);
            }
        }
        
        if(vaccIdset.size() > 0){
            d2dList = [Select id,Vacancy__c,Vacancy_Date__c,Vacancy__r.Monday_s_Shift__c,Vacancy__r.Tuesday_s_Shift__c,
                                        Vacancy__r.Wednesday_s_Shift__c,Vacancy__r.Thursday_s_Shift__c,
                                        Vacancy__r.Friday_s_Shift__c,Vacancy__r.Saturday_s_Shift__c,Vacancy__r.Sunday_s_Shift__c
                                        from Vacancy_D2D__c where Vacancy__c = :vaccIdset and Vacancy__r.RecordTypeId = :TRS_VacancyHelper.CONSULTING_RTID];
        }
        
        if(d2dList.size() >0){
            for(Vacancy_D2D__c d2d : d2dList){
                List<Vacancy_D2D__c> tempList = new List<Vacancy_D2D__c>();
                if(VacD2DMap.containsKey(d2d.Vacancy__c)){
                    tempList = VacD2DMap.get(d2d.Vacancy__c);
                    tempList.add(d2d);
                    VacD2DMap.put(d2d.Vacancy__c ,tempList);
                }
                else {
                    tempList.add(d2d);
                    VacD2DMap.put(d2d.Vacancy__c ,tempList);
                }
            }
        }
        
        if(holidayList.size() >0){ 
            for(Holiday__c hol : holidayList){
                List<Holiday__c> tempHolidayList = new List<Holiday__c>();
                Integer actualNoOfDays = hol.Start_Date__c.daysBetween(hol.End_Date__c);
                
                for(integer i = 0; i <= actualNoOfDays; i++){
                    Date startDateNew = hol.Start_Date__c + i;
                    
                    if(holidayDateMap.containsKey(startDateNew)){
                        tempHolidayList = holidayDateMap.get(startDateNew);
                        tempHolidayList.add(hol);
                        holidayDateMap.put(startDateNew , tempHolidayList);
                    }
                    else {
                        tempHolidayList.add(hol);
                        holidayDateMap.put(startDateNew , tempHolidayList);
                    }
                }
            }
        }       
        
        // Looping through old Holiday records and creating Vac D2D records if holiday record is updated        
        for(Holiday__c hol : oldHolidayMap.values()){
            List<Vacancy_D2D__c> tempList = new List<Vacancy_D2D__c>();
            if(hol.Start_Date__c != null && hol.End_Date__c != null){
                Integer actualNoOfDays = hol.Start_Date__c.daysBetween(hol.End_Date__c);
            
            
                String shift;
                 
                for(integer i = 0; i <= actualNoOfDays; i++){
                    Date startDateNew = hol.Start_Date__c + i;
                    DateTime selectedDate = startDateNew;
                    String selectedDay = selectedDate.format('EEEE');
                    
                    if(!holidayDateMap.containsKey(startDateNew)){  
                        if(VacD2DMap.containsKey(hol.Vacancy__c)){
                            tempList = VacD2DMap.get(hol.Vacancy__c);
                            
                            for(Vacancy_D2D__c d2dRec :tempList){
                                if(selectedDay == 'Monday' && d2dRec.Vacancy__r.Monday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Monday_s_Shift__c;
                                }
                                else if (selectedDay == 'Tuesday' && d2dRec.Vacancy__r.Tuesday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Tuesday_s_Shift__c;
                                }
                                else if (selectedDay == 'Wednesday' && d2dRec.Vacancy__r.Wednesday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Wednesday_s_Shift__c;
                                }
                                else if( selectedDay == 'Thursday' && d2dRec.Vacancy__r.Thursday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Thursday_s_Shift__c;
                                }
                                else if(selectedDay == 'Friday' && d2dRec.Vacancy__r.Friday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Friday_s_Shift__c;
                                }
                                else if(selectedDay == 'Saturday' && d2dRec.Vacancy__r.Saturday_s_Shift__c != null){
                                    shift = d2dRec.Vacancy__r.Saturday_s_Shift__c;
                                }
                                else if(selectedDay == 'Sunday' && d2dRec.Vacancy__r.Sunday_s_Shift__c != null){ 
                                    shift = d2dRec.Vacancy__r.Sunday_s_Shift__c ; 
                                }
                            }
                        }
                        // If shift does not exist for the paticular day , D2D record would not be created.
                        if(String.isNotBlank(shift)){
                            Vacancy_D2D__c d2d = new Vacancy_D2D__c(Vacancy__c = hol.Vacancy__c , Vacancy_Date__c = startDateNew ,Shift__c = shift);
                            d2dListToInsert.add(d2d);   
                        }
                    }
                }
            }
        }
        // inserting D2D records
        if(d2dListToInsert.size() > 0){
            insert d2dListToInsert;
        }
    }
    
    
    public static void deleteCrsOnVacD2Ddelete(List<Vacancy_D2D__c> vacD2DList){
        
        set<id> vacIdset = new set<id>();
        for(Vacancy_D2D__c d2d : vacD2DList){
            vacIdset.add(d2d.Vacancy__c);
        }         
        
        List<Closing_Report_Schedule__c> crsList = [Select Closing_Report__r.TR1__Job__c ,Schedule_Date__c from Closing_Report_Schedule__c where Closing_Report__r.TR1__Job__c = :vacIdset and Closing_Report__r.TR1__Job__r.RecordTypeId = : TRS_VacancyHelper.CONSULTING_RTID];
        System.debug('List1 :'+crsList);
        
        map<Date , Set<Closing_Report_Schedule__c>> crsDateMap = new Map<Date , Set<Closing_Report_Schedule__c>>();
        if(crsList.size()>0){
            for(Closing_Report_Schedule__c crs : crsList){
                if(!crsDateMap.containsKey(crs.Schedule_Date__c))
                    crsDateMap.put(crs.Schedule_Date__c , new Set<Closing_Report_Schedule__c>{crs});
                else
                    crsDateMap.get(crs.Schedule_Date__c).add(crs);        
            }
        }
        
        Set<Closing_Report_Schedule__c> crsToDetete = new set<Closing_Report_Schedule__c>();
        for(Vacancy_D2D__c d2d : vacD2DList){
            if(crsDateMap.containsKey(d2d.Vacancy_Date__c)){
                crsToDetete.addAll(crsDateMap.get(d2d.Vacancy_Date__c));
            }
        }
        if(crsToDetete.size()>0){
            System.debug('List :'+crsToDetete);
            List<Closing_Report_Schedule__c> crsListToDelete = new List<Closing_Report_Schedule__c>();
            for(Closing_Report_Schedule__c crs : crsToDetete){
                crsListToDelete.add(crs);
            }
            delete crsListToDelete;
        }
    }
}