public with sharing class TRS_JobCalendar {

    // Color Codes
    private final static String GREENCOLOR  = '#90D93F';
    private final static String REDCOLOR    = '#D95252';
    private final static String YELLOWCOLOR = '#FFEF93';
    private final static String BLACKCOLOR  = '#000000';
    private final static String WHITECOLOR  = '#FFFFFF';

    //Base saturday date used for Calculation.
    Date baseDate = DATE.newInstance(2000, 1, 1);

    public String vacancyEventString {get;set;} // Used to create the Events on the Calendar
    public TR1__Job__c vacancy {get; set;}//To be removed
    public TR1__Job__c vacancy1 {get; set;}
    public string vacancyId {get; set;}
    public String eventId {get; set;}
    public timeslotWrapper tsw {get;set;}
    public String selectedDt {get; set;}
    public Date selectedDate {get; set;}
    public Boolean isWeekSelected { get; set;}
    public Boolean isMidNight { get; set;}
    public Boolean deleteOldschedules { get; set;}

    public Boolean showCreateAvailRecord {
        get {
            if(showCreateAvailRecord == null)
                showCreateAvailRecord = false;
            return showCreateAvailRecord;
        }
        set;
    } // To show create Vacancy Schedule Dialog

    private void resetCreateAvailData() {
        vacancy.TR1__Estimated_Start_Date__c = null;
        vacancy.TR1__Estimated_End_Date__c = null;
        selectedDate = null;
        selectedDateStartOfWeek = null;
        selectedDateEndOfWeek = null;
        isWeekSelected = false;
        deleteOldschedules = False;
        vacancy = this.vacancy;
        vacancy1 = this.vacancy1;
        vacancy.Shift__c ='Daily';
        vacancy.Start_Time__c = '08:30 AM';
        vacancy.End_Time__c = '03:30 PM';
        vacancy1.Start_Time__c = '08:30 AM';
        vacancy1.End_Time__c = '03:30 PM';
    }

    public String getSelectedDateStr() {
        if(selectedDate != null) {
            return selectedDate.format();
        }
        return '';
    }

    public Date selectedDateStartOfWeek {get; set;}

    public String getSelectedDateStartOfWeekStr() {
        if(selectedDateStartOfWeek != null)
            return selectedDateStartOfWeek.format();
        return '';
    }

    public Date selectedDateEndOfWeek   {get; set;}
    public String getSelectedDateEndOfWeekStr() {
        if(selectedDateEndOfWeek != null)
            return selectedDateEndOfWeek.format();
        return '';
    }

    List<CalendarEvent> calanderList = new List<CalendarEvent>();

    // Check if the user is a portal user or not
    public boolean isInternalUser {
        get {
            if(isInternalUser == null)
                isInternalUser = Utility.isInternalUser();
            return isInternalUser;
        }
        private set;
    }

    public TRS_JobCalendar() {
        calanderList.clear();
        vacancyEventString='';
        vacancyId = Utility.getPageParameter('vacancyId');
        vacancy = [SELECT Id, Shift__c, Name,Start_Time__c,End_Time__c, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c, RecordTypeId, Timesheet_Approver__c, TR1__Contact__c, Booking_Type__c, CreatedById, Notes__c
                    FROM TR1__Job__c
                    WHERE Id = :vacancyId
                  ];
        vacancy1 = [SELECT Id, Shift__c, Name,Start_Time__c,End_Time__c, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c, RecordTypeId, Timesheet_Approver__c, TR1__Contact__c, Booking_Type__c, CreatedById, Notes__c
                    FROM TR1__Job__c
                    WHERE Id = :vacancyId
                  ];
        tsw = new timeslotWrapper();
        getAvailbilityDetails();
        dummyFunction();
    }

    public void getAvailbilityDetails() {
        createAvailMap();
        updateEventString();
    }

    public void getVacancyData(){
          vacancy = [SELECT Id, Shift__c, Name,Start_Time__c,End_Time__c, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c, RecordTypeId, Timesheet_Approver__c, TR1__Contact__c, Booking_Type__c, CreatedById, Notes__c
                    FROM TR1__Job__c
                    WHERE Id = :vacancyId
                  ];

    }

    private void createAvailMap() {

        Map<Id,Closing_Report_Schedule__c> closingReportScheduleMap = new Map<Id,Closing_Report_Schedule__c>();
        Map<Id,Vacancy_D2D__c> VacancyD2DMap = new Map<Id,Vacancy_D2D__c>([ SELECT Name,Candidate_Assigned__c, Status__c,Shift__c,Vacancy_Date__c,Vacancy__c,Vacancy__r.TR1__Estimated_End_Date__c,Vacancy__r.TR1__City__c , End_Date_Time__c, Start_Date_Time__c, Vacancy__r.Name , Vacancy__r.LEA__c,Closing_Report_Schedule__c,Closing_Report_Schedule_Secondary__c
                                                                            ,Vacancy__r.TR1__Contact__c,Vacancy__r.TR1__Contact__r.Name,Vacancy__r.TR1__Job_Number__c FROM Vacancy_D2D__c
                                                                            WHERE Vacancy_Date__c != null AND Vacancy__c = :vacancyId]);



        for(Closing_Report_Schedule__c crs : [Select Schedule_Date__c, Closing_Report__r.TR1__Timesheet_Approver__c, Closing_Report__r.TR1__Pay_Rate__c,
                                                     Closing_Report__r.Shift__c,Closing_Report__r.Booking_Type__c,Closing_Report__r.TR1__DT_Bill_Rate__c,
                                                     Closing_Report__r.TR1__Burden_Multiplier__c,Closing_Report__r.TR1__Bill_Rate__c,Closing_Report__r.TR1__Person_Placed__r.Name,
                                                     Closing_Report__r.TR1__Timesheet_Approver__r.Name,Closing_Report__r.TR1__Job__c, Closing_Report__r.TR1__Job__r.Name, Closing_Report__c,
                                                     Closing_Report__r.TR1__Job_Credit__r.Name , Shift__c,Vacancy_Schedule__c,Vacancy_Schedule__r.Vacancy__r.OwnerId,Vacancy_Schedule__r.Vacancy__r.Owner.Name
                                              FROM Closing_Report_Schedule__c
                                              WHERE Status__c = 'Booked' AND Vacancy_Schedule__c IN :VacancyD2DMap.keySet()]){
            closingReportScheduleMap.put(crs.Vacancy_Schedule__c,crs);
        }

        for(Vacancy_D2D__c vs : VacancyD2DMap.values()){
            CalendarEvent calEvent;
            if(closingReportScheduleMap.containsKey(vs.id)){
                calEvent = new CalendarEvent(vs,closingReportScheduleMap.get(vs.id));
            }
            else{
                calEvent = new CalendarEvent(vs);
            }
            calanderList.add(calEvent);
        }
    }

    public void updateEventString() {
        vacancyEventString = JSON.serialize(calanderList);
        while(vacancyEventString.contains('endDateTime')) {
            vacancyEventString = vacancyEventString.replace('endDateTime', 'end');
        }
        calanderList.clear();
    }
    public PageReference calenderSchedule(){
        PageReference pagRef = new PageReference('/apex/TRS_FilterCandidates?id=' + vacancyId);
        pagRef.setRedirect(true);
        return pagRef;
    }
    public void saveCreateAvailRecord() {
        Savepoint sp = Database.setSavepoint();
        try {
            if(String.isBlank(vacancy.Start_Time__c) && !isWeekSelected){
                Utility.AddErrorMessage('Please populate Start Time.');
                return;
            }
            if(String.isBlank(vacancy.End_Time__c) && !isWeekSelected){
                Utility.AddErrorMessage('Please populate End Time.');
                return;
            }
             if(String.isBlank(vacancy1.Start_Time__c) && isWeekSelected){
                Utility.AddErrorMessage('Please populate Start Time.');
                return;
            }
            if(String.isBlank(vacancy1.End_Time__c) && isWeekSelected){
                Utility.AddErrorMessage('Please populate End Time.');
                return;
            }
            if(vacancy.Start_Time__c == vacancy.End_Time__c){
                Utility.AddErrorMessage('Start Time & End Time cannot be same.');
                return;
            }
            if(vacancy.Shift__c == null){
                Utility.AddErrorMessage('Shift cannot be empty.');
                return;
            }
            if(isWeekSelected && (vacancy.TR1__Estimated_Start_Date__c == null || vacancy.TR1__Estimated_End_Date__c == null)){
                Utility.AddErrorMessage('Start Date & End Date both should be populated.');
                return;
            }
            if(isWeekSelected && (vacancy.TR1__Estimated_Start_Date__c > vacancy.TR1__Estimated_End_Date__c)){
                Utility.AddErrorMessage('Start Date should be before End Date.');
                return;
            }
            if(!isMidNight && selectedDate!=null && (formatDateTimefromDate(selectedDate,vacancy.Start_Time__c) > formatDateTimefromDate(selectedDate,vacancy.End_Time__c))){
                Utility.AddErrorMessage('Start Time should be less than  End Time.');
                return;
            }
            if(!isMidNight && vacancy.TR1__Estimated_Start_Date__c!=null && (formatDateTimefromDate(vacancy.TR1__Estimated_Start_Date__c,vacancy1.Start_Time__c) > formatDateTimefromDate(vacancy.TR1__Estimated_Start_Date__c,vacancy1.End_Time__c))){
                Utility.AddErrorMessage('Start Time should be less than  End Time.');
                return;
            }/*
            if(vacancy.TR1__Estimated_Start_Date__c!=null && vacancy.TR1__Estimated_Start_Date__c <date.Today()){
                Utility.AddErrorMessage('Please select start date Today or greater than Today.');
                return;
            }*/


            List<Vacancy_D2D__c> vacancyD2DListToAdd = new List<Vacancy_D2D__c>();

            Set<String> daySet = new Set<String>();
            if(tsw.isMon){daySet.add('Monday');}
            if(tsw.isTue){daySet.add('Tuesday');}
            if(tsw.isWed){daySet.add('Wednesday');}
            if(tsw.isThu){daySet.add('Thursday');}
            if(tsw.isFri){daySet.add('Friday');}
            if(tsw.isSat){daySet.add('Saturday');}
            if(tsw.isSun){daySet.add('Sunday');}




            if(!isWeekSelected) {
              if(selectedDate!=null && (formatDateTimefromDate(selectedDate,vacancy.Start_Time__c) > formatDateTimefromDate(selectedDate,vacancy.End_Time__c))){
                  vacancyD2DListToAdd.add(
                          new Vacancy_D2D__c(
                           Vacancy__c = vacancyId,
                           Vacancy_Date__c = selectedDate,
                           Start_Date_Time__c = formatDateTimefromDate(selectedDate,vacancy.Start_Time__c),
                           End_Date_Time__c = formatDateTimefromDate(selectedDate+1,vacancy.End_Time__c),
                           Shift__c = vacancy.Shift__c,
                           Status__c = 'Open'
                       )
                   );
                  /* vacancyD2DListToAdd.add(
                           new Vacancy_D2D__c(
                           Vacancy__c = vacancyId,
                           Vacancy_Date__c = selectedDate+1,
                           Start_Date_Time__c = formatDateTimefromDate(selectedDate+1,'12:00 AM'),
                           End_Date_Time__c = formatDateTimefromDate(selectedDate+1, vacancy.End_Time__c),
                           Shift__c = vacancy.Shift__c,
                           Status__c = 'Open'
                       )
                   );*/
                 }else{
                    vacancyD2DListToAdd.add(
                        new Vacancy_D2D__c(
                        Vacancy__c = vacancyId,
                        Vacancy_Date__c = selectedDate,
                        Start_Date_Time__c = formatDateTimefromDate(selectedDate,vacancy.Start_Time__c),
                        End_Date_Time__c = formatDateTimefromDate(selectedDate,vacancy.End_Time__c),
                        Shift__c = vacancy.Shift__c,
                        Status__c = 'Open'
                    )
                );
            }
          }
          else {
                Date startDate = vacancy.TR1__Estimated_Start_Date__c;
                Date EndDate = vacancy.TR1__Estimated_End_Date__c;
                Integer actualNoOfDays = StartDate.daysBetween(EndDate);
                for(Integer i = 0; i <= actualNoOfDays; i++){
                    Date iterableDate = StartDate + i;
                    DateTime DateValue = iterableDate;
                    String selectedDay = DateValue.format('EEEE');
                    Integer noOfDays = baseDate.daysBetween(selectedDate);
                    Integer reminder = math.mod(noOfDays,7);
                    if(daySet.contains(selectedDay)){
                      if(vacancy.TR1__Estimated_Start_Date__c!=null && (formatDateTimefromDate(vacancy.TR1__Estimated_Start_Date__c,vacancy1.Start_Time__c) > formatDateTimefromDate(vacancy.TR1__Estimated_Start_Date__c,vacancy1.End_Time__c))){
                              vacancyD2DListToAdd.add(
                                  new Vacancy_D2D__c(
                                  Vacancy__c = vacancyId,
                                  Vacancy_Date__c = iterableDate,
                                  Start_Date_Time__c = formatDateTimefromDate(iterableDate,vacancy1.Start_Time__c),
                                  End_Date_Time__c = formatDateTimefromDate(iterableDate+1, vacancy1.End_Time__c),
                                  Shift__c = vacancy.Shift__c,
                                  Status__c = 'Open'
                              )
                          );
                             /* vacancyD2DListToAdd.add(
                                  new Vacancy_D2D__c(
                                  Vacancy__c = vacancyId,
                                  Vacancy_Date__c = iterableDate+1,
                                  Start_Date_Time__c = formatDateTimefromDate(iterableDate+1,'12:00 AM'),
                                  End_Date_Time__c = formatDateTimefromDate(iterableDate+1,vacancy1.End_Time__c),
                                  Shift__c = vacancy.Shift__c,
                                  Status__c = 'Open'
                              )
                          );*/
                      }else{
                            vacancyD2DListToAdd.add(
                                new Vacancy_D2D__c(
                                Vacancy__c = vacancyId,
                                Vacancy_Date__c = iterableDate,
                                Start_Date_Time__c = formatDateTimefromDate(iterableDate,vacancy1.Start_Time__c),
                                End_Date_Time__c = formatDateTimefromDate(iterableDate,vacancy1.End_Time__c),
                                Shift__c = vacancy.Shift__c,
                                Status__c = 'Open'
                            )
                        );
                      }
                    }
                }
            }

          /*  if(!isWeekSelected) {
                system.debug('====Here===');
                system.debug('====vacancy.Start_Time__c==='+vacancy.Start_Time__c);
                system.debug('====vacancy.End_Time__c==='+vacancy.End_Time__c);
                vacancyD2DListToAdd.add(
                    new Vacancy_D2D__c(
                        Vacancy__c = vacancyId,
                        Vacancy_Date__c = selectedDate,
                        Start_Date_Time__c = formatDateTimefromDate(selectedDate,vacancy.Start_Time__c),
                        End_Date_Time__c = formatDateTimefromDate(selectedDate,vacancy.End_Time__c),
                        Shift__c = vacancy.Shift__c,
                        Status__c = 'Open'

                    )
                );

            }
            else {
                Date startDate = vacancy.TR1__Estimated_Start_Date__c;
                Date EndDate = vacancy.TR1__Estimated_End_Date__c;
                Integer actualNoOfDays = StartDate.daysBetween(EndDate);
                system.debug('====vacancy1.Start_Time__c==='+vacancy1.Start_Time__c);
                system.debug('====vacancy1.End_Time__c==='+vacancy1.End_Time__c);
                for(Integer i = 0; i <= actualNoOfDays; i++){
                    Date iterableDate = StartDate + i;
                    DateTime DateValue = iterableDate;
                    String selectedDay = DateValue.format('EEEE');
                    Integer noOfDays = baseDate.daysBetween(selectedDate);
                    Integer reminder = math.mod(noOfDays,7);
                    if(daySet.contains(selectedDay)){
                        vacancyD2DListToAdd.add(
                            new Vacancy_D2D__c(
                                Vacancy__c = vacancyId,
                                Vacancy_Date__c = iterableDate,
                                Start_Date_Time__c = formatDateTimefromDate(iterableDate,vacancy1.Start_Time__c),
                                End_Date_Time__c = formatDateTimefromDate(iterableDate,vacancy1.End_Time__c),
                                Shift__c = vacancy.Shift__c,
                                Status__c = 'Open'
                            )
                        );
                    }
                }
            }
            */

            if(vacancyD2DListToAdd.size() > 0){
                try{
                    Boolean Sucess = CreateNewVacancySchedules(vacancyD2DListToAdd,deleteOldschedules);
                    if(Sucess){
                        system.debug('======================================vacancyD2DListToAdd===='+vacancyD2DListToAdd);
                        insert vacancyD2DListToAdd;
                        Utility.AddConfirmMessage('Vacancy Schedule created successfully.');
                    }
                }catch(Exception e){
                    System.debug(e.getMessage());
                }

            }
            getAvailbilityDetails();
            getVacancyData();
            showCreateAvailRecord = false;
        }
        catch(Exception e) {
            System.debug('===Exception='+e.getMessage()+'==at line='+e.getLineNumber());
            Database.rollback(sp);
        }
    }
    public Boolean CreateNewVacancySchedules( List <Vacancy_D2D__c> recordNewList , Boolean deleteoldSH){
        try {
            Set<Date> vacancyDate = new Set<Date>();
            Set<Id> vacancyIds = new Set<Id>();
            Map<Id,Closing_Report_Schedule__c> crsD2DMap = new Map<Id,Closing_Report_Schedule__c>();
            List<Vacancy_D2D__c> vaccD2DOldList = new List<Vacancy_D2D__c> ();
            List<Closing_Report_Schedule__c>  crsList = new List<Closing_Report_Schedule__c> ();
            for(Vacancy_D2D__c vs: recordNewList) {
                vacancyDate.add(vs.Vacancy_Date__c);
                vacancyIds.add(vs.Vacancy__c);
            }

            crsList =  [Select Id, Name, Schedule_Date__c, Vacancy_Schedule__c, Candidate_Availability__c, Shift__c From Closing_Report_Schedule__c where Schedule_Date__c IN: vacancyDate and Vacancy_Schedule__r.Vacancy__c IN:vacancyIds];

            vaccD2DOldList = [Select Id,Vacancy__c, Name, Vacancy_Date__c, Start_Date_Time__c, End_Date_Time__c, Shift__c From Vacancy_D2D__c where Vacancy_Date__c IN: vacancyDate and Vacancy__c IN:vacancyIds];

            if(crsList.size()>0 && deleteoldSH && vaccD2DOldList.size()>0){
                delete crsList;
                delete vaccD2DOldList ;

            }
            else if( deleteoldSH && vaccD2DOldList.size()>0){
                   delete vaccD2DOldList ;
            }
            return true;
        }catch(exception ex){
            utility.addErrorMessage(ex.getMessage());
            return false;
        }

    }
    public void openCreateAvailRecordDialog() {
        try {
            resetCreateAvailData();

            String dateStr = Utility.getPageParameter('dateStr');
            selectedDate = Date.parse(dateStr);

            selectedDateStartOfWeek = selectedDate.toStartOfWeek();
            selectedDateEndOfWeek = selectedDateStartOfWeek.addDays(6);

            // Set Default values if previously existing data for week is found.
            for(Vacancy_D2D__c d2d : [Select Vacancy_Date__c, Status__c, Closing_Report_Schedule__c,Closing_Report_Schedule__r.Shift__c
                                                                FROM    Vacancy_D2D__c
                                                                WHERE   Vacancy__c = :vacancyId
                                                                AND     Vacancy_Date__c >= :selectedDateStartOfWeek
                                                                AND     Vacancy_Date__c <= :selectedDateEndOfWeek
                                                                order by CreatedDate asc]) {
                Integer noOfDays = baseDate.daysBetween(d2d.Vacancy_Date__c);

            }

            showCreateAvailRecord = true;
        }
        catch(Exception e) {
            Utility.addErrorMessage('Following exception occurred: ' + e.getMessage());
            return;
        }
    }

    //Delete Scheduled Event
    public void deleteCalEvent() {
        try {
            if(String.isNotBlank(eventId)) {
                if(eventId.startsWith('a1h')){
                    List<Vacancy_D2D__c> vacancy = [Select Id from Vacancy_D2D__c where id =:eventId];
                    if(vacancy != null && vacancy.size() > 0) {
                        delete vacancy;
                        eventId = null;
                        getAvailbilityDetails();
                        Utility.AddConfirmMessage('Availability deleted successfully.');
                    }
                }
                else{
                    List<Closing_Report_Schedule__c> crsListToBeUpdated = new List<Closing_Report_Schedule__c>();
                    List<Id> crsIdList = New List<Id>();
                    for(Closing_Report_Schedule__c crs : [Select Id from Closing_Report_Schedule__c where Id =:eventId]){
                        crs.Status__c = 'Cancelled';
                        crsIdList.add(crs.Id);
                        crsListToBeUpdated.add(crs);
                    }
                    TR1__Timesheet__c updateTs;
                    List<TR1__Timesheet_Detail__c> tsDetailListToBeUpdated =  [SELECT ID,TR1__Timesheet__c,DayShift__c,Half_Day__c,TR1__Regular_Hours__c,Closing_Report_Schedule__c FROM TR1__Timesheet_Detail__c WHERE Closing_Report_Schedule__c IN : crsIdList];
                    List<TR1__Timesheet_Detail__c> finaltsDetailListToBeUpdated = New List<TR1__Timesheet_Detail__c>();
                    if(tsDetailListToBeUpdated.size() > 0) {
                        ID tsId = tsDetailListToBeUpdated[0].TR1__Timesheet__c;
                        List<TR1__Timesheet_Detail__c> alltsDetailsLIst = [SELECT ID,TR1__Timesheet__c FROM TR1__Timesheet_Detail__c WHERE TR1__Timesheet__c=:tsId AND (DayShift__c = true OR Half_Day__c= true OR TR1__Regular_Hours__c!= null) AND Closing_Report_Schedule__c NOT IN : crsIdList];
                        if(alltsDetailsLIst == null || alltsDetailsLIst.size() == 0) {
                            updateTs = New TR1__Timesheet__c(Id=tsId,TR1__Status__c='Unsubmitted');
                        }
                        for(TR1__Timesheet_Detail__c tsd : tsDetailListToBeUpdated){
                            tsd.DayShift__c = false;
                            tsd.Half_Day__c = false;
                            tsd.TR1__Regular_Hours__c = null;
                            tsd.Closing_Report_Schedule__c = null;
                            tsd.CRS_Name__c = '';
                            tsd.Populated_By__c = 'Cancelled CRS : TRS_JobCalendar';
                            finaltsDetailListToBeUpdated.add(tsd);
                        }
                    }
                    if(crsListToBeUpdated != null && crsListToBeUpdated.size() > 0) {
                        update crsListToBeUpdated;
                        if(finaltsDetailListToBeUpdated!= null && finaltsDetailListToBeUpdated.size() > 0){
                            if(updateTs!= null)
                                Update updateTs;
                            Update finaltsDetailListToBeUpdated;
                        }
                        eventId = null;
                        getAvailbilityDetails();
                        Utility.AddConfirmMessage('Assignment cancelled successfully.');
                    }
                }
                getVacancyData();
            }
            else {
                Utility.AddErrorMessage('No data passed for cancellation.');
            }

        }
        catch(Exception e) {
            Utility.AddErrorMessage('Error in cancellation: ' + e.getMessage());
        }
    }

    DateTime formatDateTimefromDate(Date dateVar,String startTime){

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

    public class timeslotWrapper {
        public Boolean isMon        { get; set; }
        public Boolean isTue        { get; set; }
        public Boolean isWed        { get; set; }
        public Boolean isThu        { get; set; }
        public Boolean isFri        { get; set; }
        public Boolean isSat        { get; set; }
        public Boolean isSun        { get; set; }

        public timeslotWrapper() {
            isMon = true;
            isTue = true;
            isWed = true;
            isThu = true;
            isFri = true;
            isSat = false;
            isSun = false;
        }
    }

    public class CalendarEvent {
        public String   id;
        public String   title   {get; set;}
        public Boolean  allDay  = false;
        public String   start;
        public String   endDateTime;
        public String   tooltip;
        public String   description;
        public String   color;
        public String   textColor;
        public String   tooltipTitle;
        public String   tooltipStyleClass;
        public Boolean  editable;
        public String   status;
        public String shift;

        public CalendarEvent(Vacancy_D2D__c d2d) {
            this.start = d2d.Start_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.endDateTime = d2d.End_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.status = d2d.Status__c;
            this.id = d2d.id;
            this.color              = GREENCOLOR;
            this.textColor          = WHITECOLOR;
            this.tooltipStyleClass  = 'ui-tooltip-shadow ui-tooltip-green';
            this.tooltiptitle       = status;
            this.title              = status;
            this.tooltip            = status;

            tooltip = '<table width="100%">';
            tooltip += Utility.addTableRow('Vacancy Name ', d2d.Vacancy__r.Name);
            tooltip += Utility.addTableRow('Vacancy # ', d2d.Vacancy__r.TR1__Job_Number__c );
            tooltip += Utility.addTableRow('Contact',String.isNotBlank(d2d.Vacancy__r.TR1__Contact__r.Name)?d2d.Vacancy__r.TR1__Contact__r.Name:'');
            tooltip += Utility.addTableRow('Start Time', d2d.Start_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += Utility.addTableRow('End Time', d2d.End_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += '</table>';
            this.description = tooltip;

        }


         public CalendarEvent(Vacancy_D2D__c d2d, Closing_Report_Schedule__c crs) {
            this.status = 'Booked';
            this.start = d2d.Start_Date_Time__c.format('MM/dd/yyyy hh:mm a'); //It needs to be in this format as full calendar expects month first
            this.endDateTime = d2d.end_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.id = crs.id;
            this.color = REDCOLOR;
            this.textColor = WHITECOLOR;
            this.tooltipStyleClass = 'ui-tooltip-shadow ui-tooltip-red';

            this.tooltipTitle = crs.Closing_Report__r.TR1__Person_Placed__r.Name;
            this.title = crs.Closing_Report__r.TR1__Person_Placed__r.Name;

            tooltip = '<table width="100%">';
            tooltip += Utility.addTableRow('Time',  d2d.Start_Date_Time__c.format('dd/MM/yyyy hh:mm a') +'-'+d2d.End_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += Utility.addTableRow('Candidate', crs.Closing_Report__r.TR1__Person_Placed__r.Name);
            tooltip += Utility.addTableRow('Timesheet Approver', String.isNotBlank(crs.Closing_Report__r.TR1__Timesheet_Approver__r.Name) ? crs.Closing_Report__r.TR1__Timesheet_Approver__r.Name : '');
            tooltip += Utility.addTableRow('Vacancy Owner', String.isNotBlank(crs.Vacancy_Schedule__r.Vacancy__r.Owner.Name) ? crs.Vacancy_Schedule__r.Vacancy__r.Owner.Name : '');
            tooltip += '</table>';
            this.description = tooltip;
        }

    }

    public PageReference dummyFunction(){
        if(vacancy.Shift__c=='Hourly' || vacancy.Shift__c=='Daily'){
            vacancy.Start_Time__c = '08:30 AM';
            vacancy.End_Time__c = '03:30 PM';
            vacancy1.Start_Time__c = '08:30 AM';
            vacancy1.End_Time__c = '03:30 PM';
        }else if(vacancy.Shift__c=='AM'){
            vacancy.Start_Time__c = '08:30 AM';
            vacancy.End_Time__c = '12:00 PM';
            vacancy1.Start_Time__c = '08:30 AM';
            vacancy1.End_Time__c = '12:00 PM';
        }
        else if(vacancy.Shift__c=='PM'){
            vacancy.Start_Time__c = '01:00 PM';
            vacancy.End_Time__c = '03:30 PM';
            vacancy1.Start_Time__c = '01:00 PM';
            vacancy1.End_Time__c = '03:30 PM';
        }
        return null;
    }

    public PageReference resetDaySelection(){
        tsw.isMon = false;
        tsw.isTue = false;
        tsw.isWed = false;
        tsw.isThu = false;
        tsw.isFri = false;
        tsw.isSat = false;
        tsw.isSun = false;
        return null;
    }
}