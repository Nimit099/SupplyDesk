public with sharing class TRS_CandidateCalendar {

    public Contact contact {get; set;}
    public string contactId {get; set;}
    public TR1__Job__c tempVacancy {get; set;}
    public TR1__Job__c tempVacancy1 {get; set;}
    public Candidate_Availability__c tempCandidateAvailability {get; set;}
    public String candidateType {get; set;}
    /*
    public void settempCandidateAvailability(Candidate_Availability__c c){
        this.tempCandidateAvailability = c;
    }
    public Candidate_Availability__c gettempCandidateAvailability(){
        return tempCandidateAvailability;
    }
   */
    public TRS_CandidateCalendar() {
        //try {
            tsw = new timeslotWrapper();
            contactId = Utility.getPageParameter('contactid') != null ? Utility.getPageParameter('contactid') : Utility.getContactId();
            if(String.isNotBlank(contactId)) {
                //tempVacancy = new TR1__Job__c(Start_Time__c='08:30 AM',End_Time__c='03:30 PM');
                tempVacancy1 = new TR1__Job__c(Start_Time__c='08:30 AM',End_Time__c='03:30 PM');
                tempVacancy = [SELECT Id, Shift__c, Name,Start_Time__c,End_Time__c, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c, RecordTypeId, Timesheet_Approver__c, TR1__Contact__c, Booking_Type__c, CreatedById, Notes__c
                    FROM TR1__Job__c LIMIT 1 ];
                tempCandidateAvailability = new Candidate_Availability__c(); // Type__c='Available'
                contact = [Select Name, Phone, Email, Title, TR1__Skills__c,Subjects_Job_Titles__c,MobilePhone,LastName,FirstName,OwnerId,
                                                MailingCity, Nearest_Station__c, Registered_Postal_Code__c,
                                                TR1__Candidate_Status__c, Account.LEA_Region__c, Compliance_Status__c
                                            from Contact
                                            where Id = : contactId];
                getAvailbilityDetails();
            }
            else {
                Utility.AddErrorMessage('No Contact found.');
            }
      /*  }
        catch(Exception e) {
            Utility.AddErrorMessage('an error occured while loading page. '+ e.getMessage() + ' ' + e.getLineNumber());
        }
        */
    }

    public void getAvailbilityDetails() {
        createAvailMap();

    }

    // Color Codes
    // private final static String GREENCOLOR  = '#90D93F';
    // private final static String REDCOLOR    = '#D95252';
    // private final static String YELLOWCOLOR = '#FFEF93';
    // private final static String BLACKCOLOR  = '#000000';
    private final static String WHITECOLOR  = '#FFFFFF';

    private static map<String, String> colorMap = new map<String, String> {
        'AM'            => '#90D93F',
        'PM'            => '#90D93F',
        'Full Day'      => '#90D93F',
        'Available'      => '#90D93F',
        'Unavailable'   => '#00BFFF',
        'Holiday'       => '#00BFFF',
        'Interview'     => '#00BFFF',
        'Sick'          => '#00BFFF',
        'Working for Another Agency' => '#00BFFF',
        'Booked'        => '#D95252'
    };




    public PageReference calenderSchedule(){
        PageReference pagRef = new PageReference('/apex/TRS_FilterJobs?id=' + contactId);
        pagRef.setRedirect(true);
        return pagRef;
    }

    // Check if the user is a portal user or not
    public boolean isInternalUser {
        get {
            if(isInternalUser == null)
                isInternalUser = Utility.isInternalUser();
            return isInternalUser;
        }
        private set;
    }

    public String eventId {get; set;}
    // Delete Scheduled Event
    public void deleteCalEvent() {
        showCreateAvailRecord  = false;
       // try {
            if(String.isNotBlank(eventId)) {
                if(eventId.startsWith('a1a')){
                    List<Candidate_Availability__c> availablity = [Select Id from Candidate_Availability__c where id =:eventId];

                    if(availablity != null && availablity.size() > 0) {
                        delete availablity;

                        eventId = null;
                        getAvailbilityDetails();
                        Utility.AddConfirmMessage('Availability deleted successfully.'+showCreateAvailRecord);
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
                            tsd.Populated_By__c = 'Cancelled CRS : TRS_CandidateCalendar';
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
            }
            else {
                showCreateAvailRecord = false;
                Utility.AddErrorMessage('No data passed for cancellation.');
            }
     /*   }
        catch(Exception e) {
            Utility.AddErrorMessage('Error in cancellation: ' + e.getMessage());
        }

    */
    }

    public void refresh(){
        calenderSchedule();
    }

    public String dayType {get; set;}

    // Dates
    public Date selectedDate            {get; set;}
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

    public Boolean showCreateAvailRecord {
        get {
            if(showCreateAvailRecord == null)
                showCreateAvailRecord = false;
            return showCreateAvailRecord;
        }
        set;
    }

    public void setCandidateTypeValue(){
        String ctype = System.currentPageReference().getParameters().get('ctype');
        if(ctype == null || ctype == '')
            candidateType = 'Available';
        system.debug('=====================candidateType=========='+candidateType);
        //candidateType =ctype;
    }

    public void openCreateAvailRecordDialog() {
       // try {
            resetCreateAvailData();

            String dateStr = Utility.getPageParameter('dateStr');
            system.debug('###dateStr' + dateStr);
            selectedDate = Date.parse(dateStr);

            selectedDateStartOfWeek = selectedDate.toStartOfWeek();
            selectedDateEndOfWeek = selectedDateStartOfWeek.addDays(6);
            showCreateAvailRecord = true;
       /* }
        catch(Exception e) {
            Utility.addErrorMessage('Following exception occurred: ' + e.getMessage()+'--'+e.getlinenumber());
            return;
        }
        */
    }


    public Boolean isWeekSelected {get; set;}

    private void resetCreateAvailData() {

        tempVacancy.TR1__Estimated_Start_Date__c = null;
        tempVacancy.TR1__Estimated_End_Date__c = null;
        tempVacancy.Start_Time__c='08:30 AM';
        tempVacancy.End_Time__c='03:30 PM';
        tempVacancy1.Start_Time__c='08:30 AM';
        tempVacancy1.End_Time__c='03:30 PM';
        tempCandidateAvailability.Type__c='Available';
        tempVacancy = this.tempVacancy;
        selectedDate = null;
        selectedDateStartOfWeek = null;
        selectedDateEndOfWeek = null;
        candidateType = '';
        isWeekSelected = false;
    }

    //Base saturday date used for Calculation.
    Date baseDate = DATE.newInstance(2000, 1, 1);



    public timeslotWrapper tsw {get;set;} //This will be used to take time and day input while creation of Candidate Availability from Popup
    public String candidateEventString {get;set;} // This will be JSON which will be pased on Page to show Candidate Availability in Calendar
    public List<CalendarEvent> candidateEventList = new List<CalendarEvent>();

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

    public Boolean isMidNight {get; set;}
    //This function will be called when user clicks on Save Button
    public void saveCreateAvailRecord() {
        Savepoint sp = Database.setSavepoint();
        if(candidateType == '' || candidateType == null)
            candidateType = 'Available';
       // try {
            system.debug('tempVacancy.Start_Time__c--'+tempVacancy.Start_Time__c+'tempVacancy.End_Time__c---'+tempVacancy.End_Time__c);

            tempCandidateAvailability.Type__c = candidateType;
            if(String.isBlank(tempCandidateAvailability.Type__c)){
                Utility.AddErrorMessage('Please populate Type of Availability.');
                return;
            }
            if(String.isBlank(tempVacancy.Start_Time__c) && !isWeekSelected){
                Utility.AddErrorMessage('Please populate Start Time.');
                return;
            }
            if(String.isBlank(tempVacancy.End_Time__c) && !isWeekSelected){
                Utility.AddErrorMessage('Please populate End Time.');
                return;
            }
            if(String.isBlank(tempVacancy1.Start_Time__c) && isWeekSelected){
                Utility.AddErrorMessage('Please populate Start Time.');
                return;
            }
            if(String.isBlank(tempVacancy1.End_Time__c) && isWeekSelected){
                Utility.AddErrorMessage('Please populate End Time.');
                return;
            }
            if(tempVacancy.Start_Time__c == tempVacancy.End_Time__c){
                Utility.AddErrorMessage('Start Time & End Time cannot be same.');
                return;
            }
             if(!isMidNight && selectedDate!=null && (formatDateTimefromDate(selectedDate,tempVacancy.Start_Time__c) > formatDateTimefromDate(selectedDate,tempVacancy.End_Time__c))){
                Utility.AddErrorMessage('Start Time should be less than  End Time.');
                return;
            }
            if(!isMidNight && tempVacancy.TR1__Estimated_Start_Date__c!=null && (formatDateTimefromDate(tempVacancy.TR1__Estimated_Start_Date__c,tempVacancy1.Start_Time__c) > formatDateTimefromDate(tempVacancy.TR1__Estimated_Start_Date__c,tempVacancy1.End_Time__c))){
                Utility.AddErrorMessage('Start Time should be less than  End Time.');
                return;
            }/*
            if(tempVacancy.TR1__Estimated_Start_Date__c!=null && tempVacancy.TR1__Estimated_Start_Date__c <date.Today()){
                Utility.AddErrorMessage('Please select start date Today or greater than Today.');
                return;
            }
            */
            List<Candidate_Availability__c> candidateAvailablityToAdd = new List<Candidate_Availability__c>();

            Set<String> daySet = new Set<String>();
            if(tsw.isMon){daySet.add('Monday');}
            if(tsw.isTue){daySet.add('Tuesday');}
            if(tsw.isWed){daySet.add('Wednesday');}
            if(tsw.isThu){daySet.add('Thursday');}
            if(tsw.isFri){daySet.add('Friday');}
            if(tsw.isSat){daySet.add('Saturday');}
            if(tsw.isSun){daySet.add('Sunday');}

            if(!isWeekSelected) {
              if(selectedDate!=null && (formatDateTimefromDate(selectedDate,tempVacancy.Start_Time__c) > formatDateTimefromDate(selectedDate,tempVacancy.End_Time__c))){
                   candidateAvailablityToAdd.add(
                       new Candidate_Availability__c(
                           Start_Date__c = selectedDate,
                           Start_Date_Time__c = formatDateTimefromDate(selectedDate,tempVacancy.Start_Time__c),
                           Candidate__c = contactId,
                           End_Date__c = selectedDate,
                           End_Date_Time__c = formatDateTimefromDate(selectedDate+1,tempVacancy.End_Time__c),
                           Type__c = tempCandidateAvailability.Type__c
                       )
                   );
                 /*   candidateAvailablityToAdd.add(
                       new Candidate_Availability__c(
                           Start_Date__c = selectedDate+1,
                           Start_Date_Time__c = formatDateTimefromDate(selectedDate+1,'12:00 AM'),
                           Candidate__c = contactId,
                           End_Date__c = selectedDate,
                           End_Date_Time__c = formatDateTimefromDate(selectedDate+1, tempVacancy.End_Time__c),
                           Type__c = tempCandidateAvailability.Type__c
                       )
                   );*/
               }else{
                   candidateAvailablityToAdd.add(
                       new Candidate_Availability__c(
                           Start_Date__c = selectedDate,
                           Start_Date_Time__c = formatDateTimefromDate(selectedDate,tempVacancy.Start_Time__c),
                           Candidate__c = contactId,
                           End_Date__c = selectedDate,
                           End_Date_Time__c = formatDateTimefromDate(selectedDate,tempVacancy.End_Time__c),
                           Type__c = tempCandidateAvailability.Type__c
                       )
                   );
                }
            }
            else {
                Date startDate = tempVacancy.TR1__Estimated_Start_Date__c;
                Date EndDate = tempVacancy.TR1__Estimated_End_Date__c;
                Integer actualNoOfDays = StartDate.daysBetween(EndDate);
                for(Integer i = 0; i <= actualNoOfDays; i++){
                    Date iterableDate = StartDate + i;
                    DateTime DateValue = iterableDate;
                    String selectedDay = DateValue.format('EEEE');
                    Integer noOfDays = baseDate.daysBetween(selectedDate);
                    Integer reminder = math.mod(noOfDays,7);
                    if(daySet.contains(selectedDay)){
                      if(tempVacancy.TR1__Estimated_Start_Date__c !=null && (formatDateTimefromDate(tempVacancy.TR1__Estimated_Start_Date__c,tempVacancy1.Start_Time__c) > formatDateTimefromDate(tempVacancy.TR1__Estimated_Start_Date__c,tempVacancy1.End_Time__c))){
                          candidateAvailablityToAdd.add(
                              new Candidate_Availability__c(
                                  Start_Date__c = iterableDate,
                                  Start_Date_Time__c = formatDateTimefromDate(iterableDate,tempVacancy1.Start_Time__c),
                                  Candidate__c = contactId,
                                  End_Date__c = iterableDate,
                                  End_Date_Time__c = formatDateTimefromDate(iterableDate+1,tempVacancy1.End_Time__c),
                                  Type__c = tempCandidateAvailability.Type__c
                              )
                          );
                          /*candidateAvailablityToAdd.add(
                              new Candidate_Availability__c(
                                  Start_Date__c = iterableDate+1,
                                  Start_Date_Time__c = formatDateTimefromDate(iterableDate+1,'12:00 AM'),
                                  Candidate__c = contactId,
                                  End_Date__c = iterableDate,
                                  End_Date_Time__c = formatDateTimefromDate(iterableDate+1,tempVacancy1.End_Time__c),
                                  Type__c = tempCandidateAvailability.Type__c
                              )
                          );*/
                      }else{
                        candidateAvailablityToAdd.add(
                            new Candidate_Availability__c(
                                Start_Date__c = iterableDate,
                                Start_Date_Time__c = formatDateTimefromDate(iterableDate,tempVacancy1.Start_Time__c),
                                Candidate__c = contactId,
                                End_Date__c = iterableDate,
                                End_Date_Time__c = formatDateTimefromDate(iterableDate,tempVacancy1.End_Time__c),
                                Type__c = tempCandidateAvailability.Type__c
                            )
                        );
                    }
                  }
                }
            }



       /*     if(!isWeekSelected) {
                system.debug('====tempVacancy.Start_Time__c==='+tempVacancy.Start_Time__c);
                system.debug('====tempVacancy.End_Time__c==='+tempVacancy.End_Time__c);
                system.debug('==== tempCandidateAvailability.Type__c==='+ tempCandidateAvailability.Type__c);
                candidateAvailablityToAdd.add(
                    new Candidate_Availability__c(
                        Start_Date__c = selectedDate,
                        Start_Date_Time__c = formatDateTimefromDate(selectedDate,tempVacancy.Start_Time__c),
                        Candidate__c = contactId,
                        End_Date__c = selectedDate,
                        End_Date_Time__c = formatDateTimefromDate(selectedDate,tempVacancy.End_Time__c),
                        Type__c = tempCandidateAvailability.Type__c
                    )
                );
            }
            else {
                Date startDate = tempVacancy.TR1__Estimated_Start_Date__c;
                Date EndDate = tempVacancy.TR1__Estimated_End_Date__c;
                system.debug('===startDate=============================='+startDate);
                system.debug('===EndDate=============================='+EndDate);
                system.debug('====tempVacancy1.Start_Time__c==='+tempVacancy1.Start_Time__c);
                system.debug('====tempVacancy1.End_Time__c==='+tempVacancy1.End_Time__c);
                Integer actualNoOfDays = StartDate.daysBetween(EndDate);
                for(Integer i = 0; i <= actualNoOfDays; i++){
                    Date iterableDate = StartDate + i;
                    DateTime DateValue = iterableDate;
                    String selectedDay = DateValue.format('EEEE');
                    Integer noOfDays = baseDate.daysBetween(selectedDate);
                    Integer reminder = math.mod(noOfDays,7);
                    if(daySet.contains(selectedDay)){
                        candidateAvailablityToAdd.add(
                            new Candidate_Availability__c(
                                Start_Date__c = iterableDate,
                                Start_Date_Time__c = formatDateTimefromDate(iterableDate,tempVacancy1.Start_Time__c),
                                Candidate__c = contactId,
                                End_Date__c = iterableDate,
                                End_Date_Time__c = formatDateTimefromDate(iterableDate,tempVacancy1.End_Time__c),
                                Type__c = tempCandidateAvailability.Type__c
                            )
                        );
                    }
                }
            }*/


            if(candidateAvailablityToAdd.size() > 0){
                try{
                    system.debug('==============candidateAvailablityToAdd===='+candidateAvailablityToAdd);
                    insert candidateAvailablityToAdd;
                    Utility.AddConfirmMessage('Availability created successfully.');
                }
                catch(Exception e){
                    System.debug('Following exception occuew'+e.getMessage()+'Line number '+e.getlinenumber());
                }
            }
            createAvailMap();
            showCreateAvailRecord = false;
      /*  }
        catch(Exception e) {
            Database.rollback(sp);
        }
        */
    }

    DateTime formatDateTimefromDate(Date dateVar,String startTime){

        String startDateTime = dateVar.format();
        String startTimeHour = '';
        String startTimeMinute = '';


        if(startTime != null && startTime != '') {
            startTimeHour = startTime.split(':')[0];
            startTimeMinute = startTime.split(':')[1].remove(' AM').remove(' PM');
        }

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

    public class CalendarEvent {
        public String id;
        public String title {
            get;
            set;
        }
        public Boolean allDay = false;
        public String start;
        public String endDateTime;
        public String tooltip;
        public String description;
        public String color;
        public String textColor;
        public String tooltipTitle;
        public String tooltipStyleClass;
        public Boolean editable;
        public String status;
        public String shift;
        public String multi;
        public Boolean isDayBooked {
            get;
            set;
        }

        public CalendarEvent(Candidate_Availability__c ca) {
            this.status = ca.Type__c;
            this.isDayBooked = false;
            this.shift = status;
            this.start = ca.Start_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.endDateTime = ca.End_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.id = ca.id;
            this.color = colorMap.get(status);
            this.textColor = WHITECOLOR;
            this.tooltipStyleClass = 'ui-tooltip-shadow ui-tooltip-green';
            this.tooltiptitle = status;
            this.title = status;
            this.tooltip = status;

            tooltip = '<table width="100%">';
            tooltip += Utility.addTableRow('Status', ca.Type__c);
            tooltip += Utility.addTableRow('Start Time', ca.Start_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += Utility.addTableRow('End Time', ca.End_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += '</table>';
            this.description = tooltip;
        }

        public CalendarEvent(Candidate_Availability__c ca, Closing_Report_Schedule__c crs) {
            this.status = 'Booked';
            this.isDayBooked = false;
            this.shift = status;
            this.start = ca.Start_Date_Time__c.format('MM/dd/yyyy hh:mm a'); //It needs to be in this format as full calendar expects month first
            this.endDateTime = ca.end_Date_Time__c.format('MM/dd/yyyy hh:mm a');
            this.id = crs.id;
            this.color = colorMap.get(status);
            this.textColor = WHITECOLOR;
            this.tooltipStyleClass = 'ui-tooltip-shadow ui-tooltip-red';
            this.tooltipTitle = crs.Closing_Report__r.TR1__Job__r.Name;
            this.tooltip = status;
            this.title = crs.Closing_Report__r.TR1__Job__r.Name;

            tooltip = '<table width="100%">';
            tooltip += Utility.addTableRow('Time',  ca.Start_Date_Time__c.format('dd/MM/yyyy hh:mm a') +'-'+ca.End_Date_Time__c.format('dd/MM/yyyy hh:mm a'));
            tooltip += Utility.addTableRow('Vacancy', String.isNotBlank(crs.Closing_Report__r.TR1__Job__r.Name) ? crs.Closing_Report__r.TR1__Job__r.Name : '');
            tooltip += Utility.addTableRow('Timesheet Approver', String.isNotBlank(crs.Closing_Report__r.TR1__Timesheet_Approver__r.Name) ? crs.Closing_Report__r.TR1__Timesheet_Approver__r.Name : '');
            tooltip += '</table>';
            this.description = tooltip;
        }
    }

    //This method will fetch Candidate Availability record and Candidate Availablity D2D record and show on calendar
    public void createAvailMap() {

        candidateEventList.clear();
        candidateEventString='';
        Map<Id,Candidate_Availability__c> candidateAvailabilityMap = new Map<Id,Candidate_Availability__c>([Select Id,Name,Start_Date_Time__c,End_Date_Time__c,Type__c,Candidate__r.Owner.Name from Candidate_Availability__c where Candidate__c = :contactId and Start_Date_Time__c != null and End_Date_Time__c != null]);
        Map<Id,Closing_Report_Schedule__c> closingReportScheduleMap = new Map<Id,Closing_Report_Schedule__c>();
        for(Closing_Report_Schedule__c crs : [Select Id,Candidate_Availability__c,Name,Closing_Report__r.Booking_Type__c, Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report__r.TR1__Job__r.Name from Closing_Report_Schedule__c WHERE Status__c = 'Booked' AND Candidate_Availability__c IN :candidateAvailabilityMap.keySet()]){
            closingReportScheduleMap.put(crs.Candidate_Availability__c,crs);
        }

        for(Candidate_Availability__c ca : candidateAvailabilityMap.values()){
            CalendarEvent calEvent_v2;
            if(closingReportScheduleMap.containsKey(ca.id)){
                calEvent_v2 = new CalendarEvent(ca,closingReportScheduleMap.get(ca.id));
            }
            else{
                calEvent_v2 = new CalendarEvent(ca);
            }
            candidateEventList.add(calEvent_v2);
        }

        candidateEventString = JSON.serialize(candidateEventList);
        while(candidateEventString.contains('endDateTime')) {
            candidateEventString = candidateEventString.replace('endDateTime', 'end');
        }
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