/***************************************************************************************
 * DESCRIPTION           : vacancy page shown in scheduler tab
 * CLASS                 : TRS_FilterJobs
 * TEST CLASS            : TRS_FilterJobsTestV2
 * DATE                  : 12 DECEMBER 2022 (LAST CHANGES)
 * AUTHOR                : 
 * LAST MODIFIED BY      : MIHIR RAMOLIYA (MV CLOUDS)
 ***************************************************************************************/
public with sharing class TRS_FilterJobs {
    
    public string DEBUG {get; set;}
    
    public List<Resource> resources {get; set;} 
    public TR1__Closing_Report__c ClosingRep {get; set;}
    public Boolean isPermanant {get; set;}
    public Contact contact {get; set;}
    public Contact tempcontact {get;set;}
    public Boolean noRecordSelected {get; set;}
    public TR1__Job__c jobForDate {get; set;}
    public Boolean isMidNight {get; set;}
    public Boolean weekdays {get; set;}
    public Boolean IsfilterDisplay {get;set;} 
    public Contact conToShowRate {get;set;}
    public Boolean positivedbs {get;set;}
    
    // pagination attribute
    public Integer SelectSize {get;set;}
    public integer OFFSETvalue {get;set;}  
    public integer recordSize {get;set;}
    public integer currentpage {get;set;}
    // end
    
    public Map<date,List<CSDJSDwrap>> csdJSDateMap{
        get;
        set;
    }
    public Map<Date,List<Candidate_Availability__c>> weekDayMap{
        get;
        set;
    }
    public Boolean isweekDayMapPopulated {
        get {
            return weekDayMap.size()>0?true:false;
        }
        set;
    }        
    public Map < Id,Closing_Report_Schedule__c > crsCSDMap{get;set;}
    
    public String startDateEnterred {get; set;}
    public String endDateEnterred   {get; set;}
    public String hiringManagerName   {get; set;}
    public String query {get; set;}
    
    public set<id> discAccSet {get; set;} // Set of Disclaimer approved Accounts.
    public set<id> blacklistedAccSet {get; set;} // Set of Blacklisted Accounts
    
    public Closing_Report_Schedule__c closeRepSchedule {get; set;}
    
    public Map < Id,Closing_Report_Schedule__c > crsJSDMap {get;set;}
    public Map < Date,List<Vacancy_D2D__c> > jsdDateMap{get;set;}
    
    
    public Boolean isEducation      {get; set;}
    Map < string , List < Vacancy_D2D__c >> JobD2DWithDTMap ;
    
    //variables for sorting
    public String sortDirection;
    public String sortExp;
    public Double offset{
        get{
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }
    
    Map<Id, List<Vacancy_D2D__c>> vacancyD2DMap;
    
    //Start - 9 Mar 18
    public Boolean isPersonPlaced {get;set;}
    public Boolean isSortingByDistances {get;set;}
    public Map<Id,String> mapToShowWithHeld{get;set;}
    public Map<Id,String> mapToShowPersonPlaced{get;set;}
    //End
    public string vacancyStartDate{get;set;}

    public List<String> strings{get;set;}
    public List<String> strings_r(){
        List<String> t = new List<String>();
        return t;
    }

    public List<SelectOption> StartTimePicklist {get; set;}
    public List<SelectOption> StartTimePicklist_t() {
        List<SelectOption> pickListValuesList= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = TR1__Job__c.Start_Time__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add(new SelectOption('--None--','--None--'));
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new SelectOption(pickListVal.getValue(),pickListVal.getLabel()));
        }     
        System.debug(pickListValuesList);
        return pickListValuesList;
    }
    public List<SelectOption> EndTimePicklist {get; set;}
    public List<SelectOption> EndTimePicklist_t() {
        List<SelectOption> pickListValuesList= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = TR1__Job__c.Start_Time__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add(new SelectOption('--None--','--None--'));
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new SelectOption(pickListVal.getValue(),pickListVal.getLabel()));
        }     
        System.debug(pickListValuesList);
        return pickListValuesList;
    }


    public Map<String, Map<String,String>> weekData {get; set;}

    // Constructor
    public TRS_FilterJobs(ApexPages.StandardController ctrl) {
        
        // Initialize Variables
        SelectSize = 100;
        OFFSETvalue = 0;
        recordSize = 0;
        currentpage = 1;
        query = '';
        system.debug('currentpage--'+currentpage);
        jobForDate = new TR1__Job__c(); 
        tempcontact = new Contact ();
        VacRec = new TR1__Job__c();
        weekDayMap = new Map<Date,List<Candidate_Availability__c>>();
        ClosingRep = new TR1__Closing_Report__c();
        whichVacancy = 'My Vacancies';
        sortDirection = 'ASC'; 
        sortExp = 'name';
        conToShowRate = new Contact();
        selectedSpecialism = new List<String>();
        contact = new Contact();
        conTemp = new Contact(Hidden_Scheduler_Filter__c = UserInfo.getUserId());
        conTemp.Division__c = [Select Branch__c from User where Id = :UserInfo.getUserId()].Branch__c;
        grossProfit = new TR1__Gross_Profit__c();
        discAccSet = new set<Id>();
        blacklistedAccSet = new set<Id>();
        isEducation = null;
        selectedSector = null;//new List<String>{};
        startDate = System.today().toStartOfWeek();
        endDate = startDate.addDays(6);
        noRecordSelected = false;
        strings = strings_r();
        weekData = new Map<String, Map<String,String>>();
        StartTimePicklist = StartTimePicklist_t();
        EndTimePicklist = EndTimePicklist_t();
        
        //Start 8 Mar 18 (To sort and show Withheld and Person Placed)
        isSortingByDistances = false;
        isPersonPlaced = false;
        mapToShowWithHeld = new Map<Id,String>();
        mapToShowPersonPlaced = new Map<Id,String>();
        //End
        
        if(ctrl == null || ctrl.getId() == null) {
            noRecordSelected = true;
        }
        else{
            ClosingRep.TR1__Person_Placed__c = ctrl.getId();
        }
        
        getCandidateDetails();
        
        if(Apexpages.currentPage().getParameters().containsKey('save') && ApexPages.currentPage().getParameters().get('save') != '')
        {
            Utility.AddInfoMessage('Booking completed on closing report No. '+ Apexpages.currentPage().getParameters().get('save') +' successfully');
            //returnPage = true;
            return;
        }
        
    }
    
    private String currentUserId = UserInfo.getUserId();
    
    public void getCandidateDetails (){
        VacRec = new TR1__Job__c();
        isEducation = false; 
        isPermanant = false;
        IsfilterDisplay = false;
        System.debug('@debug-->TR1__Person_Placed__c:'+ClosingRep.TR1__Person_Placed__c);
        if(ClosingRep.TR1__Person_Placed__c != null) {
            contact = [Select Name,Alert__c,OwnerId, Transport__c,Candidate_Alias__c, Distance_Will_Travel__c,Division__c, Phone, otherPhone, mailingPostalcode, Email, AccountId,Title,LEA__c,Preferred_LEA__c,Sub_LEA__c, TR1__Skills__c,Subjects_Job_Titles__c,MobilePhone,Compliance_Owner__c,Job_Title__c,Agreed_D2D_Pay_Rate__c,Sub_Sector__c,Job_Titles__c,TR1__State_Area__c,TR1__Regional_Area__c,Set_Contact_GeoLocation__Latitude__s,Set_Contact_GeoLocation__Longitude__s,
                       MailingCity, Nearest_Station__c, Registered_Postal_Code__c,Train_Station__r.Name,Compliance_Status__c,OtherPostalCode,Subject__c,SEN_Experience__c,SEN_Additional_Experience__c,Year_Key_Stage__c,Skills_Training_Experience__c,Qualificaitons__c,
                       TR1__Candidate_Status__c, Account.LEA_Region__c,RecordType.Name,Account.Agreed_D2D_Charge_Rate__c,Specialisms__c,Sector__c,Trained_As__c,TR1__Contact_GeoLocation__Longitude__s,TR1__Contact_GeoLocation__Latitude__s
                       from Contact
                       where Id = : ClosingRep.TR1__Person_Placed__c];
            System.debug('@debug-->contact:'+contact);
            VacRec.TR1__State_Area__c= (contact.TR1__State_Area__c== null)? null : contact.TR1__State_Area__c  ;
            VacRec.TR1__Regional_Area__c= (contact.TR1__Regional_Area__c== null)? null : contact.TR1__Regional_Area__c  ;
            VacRec.Qualifications__c = contact.Qualificaitons__c ;
            VacRec.Trained_As__c =  (contact.Trained_As__c== null)? null : contact.Trained_As__c  ;
            VacRec.Skills_Training_Experience__c = contact.Skills_Training_Experience__c;
            VacRec.Year_Key_Stage__c = contact.Year_Key_Stage__c;
            VacRec.SEN_Additional_Experience__c = contact.SEN_Additional_Experience__c; 
            VacRec.SEN_Experience__c = contact.SEN_Experience__c;
            conTemp.LEA__c = contact.LEA__c;
            VacRec.Subject2__c = contact.Subject__c;
            tempcontact.Job_Titles__c= contact.Job_Titles__c;
            conTemp.Preferred_LEA__c = (contact.Preferred_LEA__c== null)? null : contact.Preferred_LEA__c  ;
            conTemp.Sub_LEA__c = (contact.Sub_LEA__c== null)? null : contact.Sub_LEA__c;
            selectedSpecialism = (contact.Specialisms__c== null)?  new List<String>() :contact.Specialisms__c.split(';');
            conTemp.Sector__c = (contact.Sector__c== null)?  null : contact.Sector__c;
            
            if(contact.RecordType.Name == 'Client' || contact.RecordType.Name == 'Candidate'){        
                startDate = System.today().toStartOfWeek();
                endDate = startDate.addDays(6);
                noRecordSelected = false;
                
                // Get Blacklisted Accounts
                for(Blacklisted__c blackList : [Select  Candidate__c, Company__c, Reason_For_Blacklist__c from Blacklisted__c where Candidate__c = : contact.id]){
                    blacklistedAccSet.add(blackList.Company__c);
                }
                
                // If Status = Working on Disclaimer, get Approved Accounts.
                if(contact.Compliance_Status__c == 'Working on Disclaimer'){
                    for(TR1__Screening__c disc : [Select Company__c from  TR1__Screening__c where TR1__Contact__c = :contact.id]){
                        discAccSet.add(disc.Company__c);
                    }
                } 

                for(TR1__Associated_Qualification__c  ql : [SELECT id,Positive_DBS__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c = :contact.id AND qualificationName__c = 'DBS' LIMIT 1]){
                    positivedbs = ql.Positive_DBS__c;
                    System.debug('Positive DBS Alert:'+positivedbs);
                }
            }
            else {
                Utility.AddErrorMessage('Scheduling is only allowed for Candidate of Candidate or  Client. Please select an appropriate candidate.');
                isPermanant = true; 
                return;
            }              
        }
        getResourceAvailability();             
    }
    
    /* WEEK FUNCTIONS - START */
    public Date startDate  {get; set;}
    public Date endDate    {get; set;}
    
    public String startDateStr   {get; set;} 
    public String endDateStr   {get; set;}
    
    public String getWeek() {
        return  '' + Utility.getMonth(startDate.month()) + ' ' + startDate.day() + ' - ' + Utility.getMonth(endDate.month()) + ' ' + endDate.day();
    }
    
    // Go to Next Week
    public void nextWeek() {
        startDate = startDate.addDays(7);
        endDate   = endDate.addDays(7);
        getResourceAvailability();
    }
    
    // Go to Previous Week
    public void previousWeek() {
        startDate = startDate.addDays(-7);
        endDate   = endDate.addDays(-7);
        getResourceAvailability();
    }
    
    // Update Week based on the Week selected
    public void updateWeek() {
        startDate = date.parse(startDateStr);
        endDate = date.parse(endDateStr);
        getResourceAvailability();
    }
    
    public integer Count{get;set;} 
    
    // Set the WeekHeader
    public List<String> weekHeader {
        get {
            weekHeader = new List<String>();
            for(Integer i=0; i<=startDate.daysBetween(endDate); i++) {
                weekHeader.add(Utility.getDay(i) + '<br/>' + startDate.addDays(i).day() + '/' + startDate.addDays(i).month());
            }
            return weekHeader;
        }
        private set;
    }
    /* WEEK FUNCTIONS - END */
    
    /* FILTER VARIABLES - START */ 
    
    // Sorting Logic
    public String sortExpression{
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
    /* FILTER VARIABLES - END */
    
    
    /* WRAPPER CLASSES : START */
    
    public class DayDetailWrapper {
        public DayDetail dayDetail1 {get; set;}
        public DayDetail dayDetail2 {get; set;}
        public Boolean showDayDetail2 {get; set;}
        public Vacancy_D2D__c vacAvailabilityRec{ get; set;}
        public Candidate_Availability__c canAvailabilityRec {get;set;}
    }
    
    public class CSDJSDwrap {
        public Vacancy_D2D__c vaccAvail { get; set; }
        public Candidate_Availability__c canAvail{ get; set; }
        public String Colour{ get; set; }
        
        public CSDJSDwrap (Vacancy_D2D__c vaccAvail, Candidate_Availability__c canAvail,String Colour){
            this.vaccAvail = vaccAvail;
            this.canAvail = canAvail;
            this.Colour = Colour;
        }
    }
    
    public class Resource {
        public TR1__Job__c vacancy {get; set;}
        public Decimal distanceVal  {get; set;}
        public String tooltipContent  {get; set;}
        public transient Integer score;
        public Map < Date, List<DayDetailWrapper> > dateAvailMap{
            get;
            set;
        } 
        public list < DayDetailWrapper > dayDetailList {
            get;
            set;
        }
        public Map < Date,  List<Candidate_Availability__c>>  weekDayMap{
            get;
            set;
        }
        
        public Date enddate{
            get;
            set;
        }
        
        public Integer jobAvailCount{
            get;
            set;
        }
        
        public Resource(TR1__Job__c job, Decimal distanceVal, List<Vacancy_D2D__c> d2dList, Date startDate, Date endDate,
                        map<Id, Closing_Report_Schedule__c> crsJSDMap, Map<Date,  List<Candidate_Availability__c>> weekDayMap,Map < Date,List<Vacancy_D2D__c> > jsdDatesMap,Map < Id,Closing_Report_Schedule__c > crsCSDMap) {
                            this.vacancy = job;
                            this.distanceVal = distanceVal;
                            dateAvailMap = new Map < Date, List<DayDetailWrapper> > ();
                            this.weekDayMap = weekDayMap;
                            this.enddate = endDate;
                            dayDetailList = new list < DayDetailWrapper > ();
                            system.debug('===========================crsJSDMap======='+crsJSDMap); 
                            system.debug('===========================weekDayMap======='+weekDayMap); 
                            // Creating a Map of date associated with a List of Day Detail
                            for (Integer i = 0; i <= startDate.daysBetween(endDate); i++) {
                                if(jsdDatesMap.get(startDate.addDays(i))!=null){
                                    for(Vacancy_D2D__c jsd : jsdDatesMap.get(startDate.addDays(i))){
                                        DayDetailWrapper dayDetailWrap = new DayDetailWrapper();
                                        dayDetailWrap.dayDetail1 = new dayDetail(startDate.addDays(i), 'Unknown');        
                                        dayDetailWrap.vacAvailabilityRec = jsd;
                                        System.debug('jsd======>>>>'+ jsd);
                                        if(!dateAvailMap.containsKey(startDate.addDays(i))){dateAvailMap.put(startDate.addDays(i), new List<DayDetailWrapper>{dayDetailWrap});
                                        }
                                        else{dateAvailMap.get(startDate.addDays(i)).add(dayDetailWrap);
                                        }
                                        
                                        dayDetailList.add(dayDetailWrap);
                                    }
                                }else{
                                    DayDetailWrapper dayDetailWrap = new DayDetailWrapper();
                                    dayDetailWrap.dayDetail1 = new dayDetail(startDate.addDays(i), 'Unknown');         
                                    dayDetailList.add(dayDetailWrap);
                                    if(!dateAvailMap.containsKey(startDate.addDays(i))){dateAvailMap.put(startDate.addDays(i), new List<DayDetailWrapper>{dayDetailWrap});
                                    }
                                    else{dateAvailMap.get(startDate.addDays(i)).add(dayDetailWrap);
                                    }
                                }
                                //dayDetailWrap.candidD2DList1 = new List< Candidate_Availability__c >();
                            }
                            
                            System.debug('=============== dateAvailMap :'+dateAvailMap);
                            System.debug('=============== weekDayMap :'+weekDayMap);
                            // Step 2. Assign Candidate D2D to day detail
                            if (!weekDayMap.isEmpty()) {
                                for (Date dt: dateAvailMap.keySet()) {
                                    if (dateAvailMap.containsKey(dt)) {
                                        if(!weekDayMap.containsKey(dt)){
                                            Candidate_Availability__c canD2D = new Candidate_Availability__c();
                                            weekDayMap.put(dt,New List<Candidate_Availability__c>{canD2D});
                                        }
                                    }
                                }
                            }
                            System.debug('########### weekDayMap :'+weekDayMap);
                            // Query and obtain user ProfileName
                            String ProfileNameofUser = Utility.currentUserProfileName;
                            
                            score = 0;
                            jobAvailCount = 0;
                            for(Date dt : dateAvailMap.keySet()) {
                                for(DayDetailWrapper ddWrap : dateAvailMap.get(dt)){
                                    if(ddWrap.dayDetail1.Status== 'Available') continue;
                                    if(ddWrap.vacAvailabilityRec!=null){
                                        if(crsJSDMap.get(ddWrap.vacAvailabilityRec.Id)!=null){
                                            ddWrap.dayDetail1.Status = 'Booked';
                                            system.debug('==================================Here ==='+dt);
                                            ddWrap.canAvailabilityRec = crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Candidate_Availability__r;//weekDayMap.get(dt)[0]; // added
                                        }else{
                                            if(weekDayMap.get(dt)!=null){
                                                for(Candidate_Availability__c d2d : weekDayMap.get(dt)){
                                                    if(ddWrap.dayDetail1.Status== 'Available') continue;
                                                    if(ddWrap.vacAvailabilityRec.Start_Date_Time__c!=null &&ddWrap.vacAvailabilityRec.End_Date_Time__c!=null && d2d.End_Date_Time__c !=null && d2d.Start_Date_Time__c !=null){
                                                        if( d2d.Start_Date_Time__c<= ddWrap.vacAvailabilityRec.Start_Date_Time__c && d2d.End_Date_Time__c>= ddWrap.vacAvailabilityRec.End_Date_Time__c && !crsCSDMap.containsKey(d2d.Id)){
                                                            ddWrap.dayDetail1.Status = 'Available';
                                                            if(!crsCSDMap.containsKey(d2d.Id)){jobAvailCount  = jobAvailCount +1;
                                                            }
                                                        }    
                                                        else{ddWrap.dayDetail1.Status = 'Unknown';
                                                        }
                                                    }else{ddWrap.dayDetail1.Status = 'Unknown';
                                                    }
                                                }
                                                ddWrap.dayDetail1.showAssignButton = (ddWrap.dayDetail1.status=='Available') ? True : False ;
                                            }else{ddWrap.dayDetail1.Status = 'Available';
                                            }
                                        }
                                    }
                                    if (Utility.colorStsMap.containsKey(ddWrap.dayDetail1.status)) {ddWrap.dayDetail1.colorStyle = Utility.colorStsMap.get(ddWrap.dayDetail1.status);
                                    }  
                                }
                            }
                            
                            tooltipContent = '<table width="100%">';
                            tooltipContent += Utility.addTableRow('Vacancy Name', String.isNotBlank(vacancy.Name) ? Vacancy.Name : '');
                            tooltipContent += Utility.addTableRow('Client', String.isNotBlank(Vacancy.TR1__Account__r.Name) ? Vacancy.TR1__Account__r.Name : '');
                            tooltipContent += Utility.addTableRow('Start Date', vacancy.TR1__Estimated_Start_Date__c.format());
                            if (vacancy.TR1__Estimated_End_Date__c != null) {tooltipContent += Utility.addTableRow('End Date', vacancy.TR1__Estimated_End_Date__c.format());
                            } else {tooltipContent += Utility.addTableRow('End Date', ' ');
                            }
                            tooltipContent += Utility.addTableRow('Hourly Pay Rate', vacancy.Maximum_Hour_Pay_Rate__c);
                            tooltipContent += Utility.addTableRow('Half Day Pay Rate', vacancy.TR1__Minimum_Pay_Rate__c);
                            tooltipContent += Utility.addTableRow('Day Pay Rate', vacancy.TR1__Maximum_Pay_Rate__c);
                            tooltipContent += Utility.addTableRow('Hourly Charge Rate', vacancy.Maximum_Hour_Charge_Rate__c);
                            tooltipContent += Utility.addTableRow('Half Charge Pay Rate', vacancy.TR1__Minimum_Bill_Rate__c);
                            tooltipContent += Utility.addTableRow('Day Charge Rate', vacancy.TR1__Maximum_Bill_Rate__c);
                            tooltipContent += Utility.addTableRow('Booking Type', String.isNotBlank(vacancy.Booking_Type__c) ? vacancy.Booking_Type__c : '');
                            tooltipContent += Utility.addTableRow('Job Title', String.isNotBlank(vacancy.Job_Title__c) ? vacancy.Job_Title__c : '');
                            tooltipContent += Utility.addTableRow('Subject', String.isNotBlank(vacancy.Subject2__c) ? vacancy.Subject2__c : '');  
                            tooltipContent += Utility.addTableRow('Year/ Key Stage', String.isNotBlank(vacancy.Year_Key_Stage__c) ? vacancy.Year_Key_Stage__c : '');  
                            tooltipContent += '</table>';
                            
                            for(Date dt : dateAvailMap.keySet()) {
                                for(DayDetailWrapper daywrap1 : dateAvailMap.get(dt)){
                                    DayDetailWrapper ddWrap = daywrap1;
                                    if(ddWrap.dayDetail1 != null){
                                        if( ddWrap.dayDetail1.Status == 'Booked'&& crsJSDMap.get(ddWrap.vacAvailabilityRec.Id)!=null){
                                            ddWrap.dayDetail1.tooltipContent = '<table width="100%">';
                                            
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Candidate Assigned', String.isNotBlank( ddWrap.canAvailabilityRec.Candidate__r.Name) ?  ddWrap.canAvailabilityRec.Candidate__r.Name : '' );
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Vacancy Assigned', String.isNotBlank(ddWrap.vacAvailabilityRec.Vacancy__r.Name) ? ddWrap.vacAvailabilityRec.Vacancy__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Hourly Pay Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Hour_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Half Day Pay Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Half_Day_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Day Pay Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Day_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Maximum Charge Per Day', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Charge_Per_Day__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Maximum Pay Rate Per Day', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Pay_rate_Per_Day__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Hourly Charge Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Hour_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Half Charge Pay Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Half_Day_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Day Charge Rate', crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Maximum_Day_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Owner', String.isNotBlank( crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.TR1__Job_Credit__r.Name) ?  crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.TR1__Job_Credit__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Timesheet Approver', String.isNotBlank( crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.TR1__Timesheet_Approver__r.Name) ?  crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.TR1__Timesheet_Approver__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Booking Type', String.isNotBlank( crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Booking_Type__c) ?  crsJSDMap.get(ddWrap.vacAvailabilityRec.Id).Closing_Report__r.Booking_Type__c : '');
                                            tooltipContent += '</table>';
                                        }
                                    }
                                }
                            }
                        }
    }
    
    public class dayDetail {
        public Vacancy_D2D__c vacAvailabilityRec       {get; private set;}
        public TR1__Closing_Report__c closingReport     {get; private set;}
        public Candidate_Availability__c canAvailD2DRec  {get; private set;}
        public Closing_Report_Schedule__c closingReportSchedule{get; private set;}
        public String day      {get; private set;}
        public String Fullday    {get; private set;}
        public String status         {get; set;}
        public String VacAvailshift { get; private set; }
        public String CandidAvailshift { get; private set;}
        public String assignedJobName  {get; private set;}
        public Date VacancySelectedDate   {get; set;}
        public String VacancyDateSelected   {get; set;}
        public Boolean showAssignButton    {get; set;}
        public Boolean cancelAssignButton  {get; set;}
        public transient String toolTipContent { get; set;}
        public transient String colorStyle { get; set;}
        
        // Basic Constructor
        public dayDetail(Date dt, String status) {
            Date startDate = dt.toStartOfWeek();    
            VacancySelectedDate = dt;
            VacancyDateSelected = VacancySelectedDate.format();
            this.status = status;
            this.showAssignButton = false;
            this.cancelAssignButton = false;
            closingReportSchedule = new Closing_Report_Schedule__c();
        }
        
    }
    
    /* WRAPPER CLASSES : END */
    
    /* FILTER JOB LOGIC : START */
    
    public TR1__Job__c VacRec {get; set;}
    public TR1__Gross_Profit__c grossProfit {get; set;}
    public Contact conTemp {get; set;}
    public string selectedSector {get;set;}
    
    public List<Selectoption> getSectors() {
        Schema.DescribeFieldResult F = Schema.sObjectType.contact.fields.Sector__c;  //Contact.Job_Titles__c.getDescribe();
        F=F.getSObjectField().getDescribe();
        List < Selectoption > so = new List < Selectoption > ();
        for (Schema.PicklistEntry P: F.getPicklistValues()) {
            so.add(new Selectoption(p.getLabel(), p.getValue()));
        }
        return so;
    }
    
    public string sortFullExp = '';
    public List<string> selectedSpecialism {get;set;}
    
    public List<Selectoption> specialisms {
        get {
            Schema.DescribeFieldResult F= Schema.sObjectType.Contact.fields.Specialisms__c; //Contact.Specialisms__c.getDescribe();
            F=F.getSObjectField().getDescribe();
            List < Selectoption > so = new List < Selectoption > ();
            for (Schema.PicklistEntry P: F.getPicklistValues()) {
                so.add(new Selectoption(p.getLabel(), p.getValue()));
            }
            return so;
        }
        set;
    }
    
    public String whichVacancy  {get; set;}
    
    public List<SelectOption> whichVacancyOptions {
        get {
            if(whichVacancyOptions == null) {
                whichVacancyOptions = new List<SelectOption>();
                whichVacancyOptions.add(new SelectOption('My Vacancies', 'My Vacancies'));
                whichVacancyOptions.add(new SelectOption('All Vacancies', 'All Vacancies'));
            } 
            return whichVacancyOptions;
        }
        private set;
    }
    
    public PageReference resetFilters(){
        VacRec.TR1__State_Area__c= null;
        VacRec.TR1__Account__c=null;
        VacRec.TR1__Regional_Area__c=null;
        VacRec.Trained_As__c = null;
        conTemp.Preferred_LEA__c = null;
        conTemp.Sub_LEA__c = null;
        conTemp.LEA__c = null;
        selectedSpecialism = new List<String>();
        selectedSector = null;//new List<String>();
        VacRec.Qualifications__c = null;
        VacRec.Skills_Training_Experience__c = null;
        VacRec.Year_Key_Stage__c = null;
        VacRec.SEN_Additional_Experience__c = null; 
        VacRec.SEN_Experience__c = null;
        VacRec.Subject2__c= null;
        tempcontact.Job_Titles__c = null;
        conTemp.Hidden_Scheduler_Filter__c= null;
        conTemp.Division__c= null;
        whichVacancy = 'All Vacancies';
        getResourceAvailability();
        conTemp.Sector__c = null;
        VacRec.Booking_Type__c = null;
        return null;
        
    }    
    
    public void previouspaginaton(){
        if(SelectSize >= OFFSETvalue ){
            OFFSETvalue = SelectSize - OFFSETvalue;
            system.debug('OFFSETvalue--'+OFFSETvalue);
            getResourceAvailability();
        }else{
            OFFSETvalue = OFFSETvalue - SelectSize ;
            getResourceAvailability();
        }
    }
    
    public void nextpaginaton(){
        OFFSETvalue += SelectSize;
        getResourceAvailability();
    }
    
    public pageReference changeListsize(){
        pageReference pr = null;
        system.debug('changeListsize SelectSize'+SelectSize);
        //SelectSize
        getResourceAvailability();
        return pr;
    }
    
    public void getResourceAvailability() {
        Count = 0 ;
        try{
            VacRec.Booking_Type__c = '';
            System.debug('=======================ClosingRep.TR1__Person_Placed__c ===='+ClosingRep.TR1__Person_Placed__c);
            System.debug('=========== weekDayMap value is :'+weekDayMap);
            if(ClosingRep.TR1__Person_Placed__c != null) {
                weekDayMap.clear();
                //Adding values to weekDay Map 
                System.debug('contact.id'+contact.id);
                System.debug('startDate'+startDate);
                System.debug('endDate'+endDate);
                for(Candidate_Availability__c candidate : [SELECT Start_Date__c,Candidate__r.Candidate_Alias__c,End_Date__c, End_Date_Time__c, Start_Date_Time__c, Candidate__c, Applicable_Days__c,Type__c 
                                                           FROM Candidate_Availability__c
                                                           WHERE Candidate__c = :contact.id AND Start_Date__c >= :startDate AND End_Date__c <= :endDate
                                                        //    WHERE Candidate__c = :contact.id 
                                                           ORDER BY createdDate
                                                          ]){
                                                              System.debug('=======================candidate ===='+candidate);                                         
                                                              if(!weekDayMap.containsKey(candidate.Start_Date__c))
                                                                  weekDayMap.put(candidate.Start_Date__c, new List<Candidate_Availability__c>{candidate});
                                                              else
                                                                  weekDayMap.get(candidate.Start_Date__c).add(candidate);
                                                              Count++;
                                                              System.debug('candidate ==> '+candidate);
                                                          }
            } 
            System.debug('weekDayMap==>'+weekDayMap);
            System.debug('=======================in here weekDayMap ===='+weekDayMap +'Count value is :'+Count);
            System.debug('Count value is :'+Count);
            resources = new List<Resource>();
            sortFullExp = sortExpression  + ' ' + sortDirection;
            System.debug('=========================sortFullExp======'+sortFullExp);
            // Create Query for Vacancy
            query = 'Select Candidate_Assigned__c,Vacancy__r.Candidate__r.OtherPostalCode,Vacancy__r.Candidate__r.MailingPostalCode, Vacancy__r.TR1__Account__r.School_Alias__c,Status__c,Vacancy_Date__c, Vacancy__c, Vacancy__r.Shift__c, Vacancy__r.TR1__Estimated_End_Date__c, Vacancy__r.Sector1__c, Vacancy__r.Sub_Sector__c,Vacancy__r.Maximum_Hour_Pay_Rate__c, '
                + ' Vacancy__r.Job_Title__c, Vacancy__r.Specialism__c,Vacancy__r.TR1__Account__r.Agreed_D2D_Charge_Rate__c, Closing_Report_Schedule_Secondary__c, Closing_Report_Schedule__c, '
                + ' Vacancy__r.TR1__City__c , Vacancy__r.Name , Vacancy__r.LEA__c , Vacancy__r.Booking_Type__c ,Vacancy__r.TR1__Regional_Area__c,Vacancy__r.TR1__Account__r.LEA_Region__c,  '
                + ' Vacancy__r.TR1__Hiring_Manager__r.Name,Vacancy__r.TR1__Contact__r.Name ,Vacancy__r.TR1__State_Area__c , End_Date_Time__c,Start_Date_Time__c,Vacancy__r.TR1__Account__c,Vacancy__r.TR1__Primary_Background__c ,Vacancy__r.Subject__c,Vacancy__r.Subject2__c,Vacancy__r.TR1__Account__r.LEA__c,Shift__c , '
                +' Closing_Report_Schedule__r.Shift__c, Closing_Report_Schedule__r.createdById, Closing_Report_Schedule_Secondary__r.createdById,'
                +' Closing_Report_Schedule__r.Closing_Report__r.Booking_Type__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Bill_Rate__c,  Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__r.Name,'
                +' Closing_Report_Schedule__r.Closing_Report__r.TR1__Pay_Rate__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job_Credit__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__c,'
                +' Closing_Report_Schedule__r.Closing_Report__r.Shift__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report_Schedule_Secondary__r.Shift__c, '
                +' Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__r.Name, Vacancy__r.Trained_As__c'
                + ' From Vacancy_D2D__c '
                + ' where Vacancy_Date__c != null and   Vacancy_Date__c >= :startDate and Vacancy_Date__c <= :endDate '
                // + ' where '
                + ' and (Vacancy__r.TR1__Status__c = \'Open\'  or Vacancy__r.TR1__Status__c = \'Hold\' or (Vacancy__r.TR1__Status__c = \'Closed\'  and (Vacancy__r.TR1__Closed_Reason__c = \'Assigned\' or Vacancy__r.TR1__Closed_Reason__c = \'Filled\')))';
            
            system.debug('conTemp.OtherPostalCode----'+conTemp.OtherPostalCode);
            
            if(String.isNotBlank(conTemp.OtherPostalCode)){
                string postalcode = '%'+conTemp.OtherPostalCode+'%';
                query += ' and Vacancy__r.Candidate__r.OtherPostalCode Like \''+postalcode+'\'';
            }
            
            if(blacklistedAccSet.size() > 0){
                query += ' and Vacancy__r.TR1__Account__c Not In :blacklistedAccSet' ;
            }
            system.debug('query---'+query);
            if(discAccSet.size() > 0 && contact != null && contact.Compliance_Status__c == 'Working on Disclaimer'){
                query += ' and Vacancy__r.TR1__Account__c in :discAccSet' ;
            }
            
            System.debug('VacRec.TR1__Account__c : '+ VacRec.TR1__Account__c);
            if (String.isNotBlank(VacRec.TR1__Account__c)){
                query += ' and Vacancy__r.TR1__Account__c = \'' + VacRec.TR1__Account__c + '\'';
            }
            
            if(String.isNotBlank(VacRec.TR1__State_Area__c)) {
                query += ' and Vacancy__r.TR1__State_Area__c = \'' + VacRec.TR1__State_Area__c + '\'';
            }
            
            if(String.isNotBlank(VacRec.Booking_Type__c)) {
                query += ' and Vacancy__r.Booking_Type__c = \'' + VacRec.Booking_Type__c + '\'';
            }
            
            if(String.isNotBlank(conTemp.Sector__c)){
                List<String> testSector = conTemp.Sector__c.split(';');
                query += ' and Vacancy__r.Sector1__c IN : testSector ';
            }
            
            if(selectedSpecialism.size()>0 && selectedSpecialism!=null) {
                query += ' and Vacancy__r.Specialism__c in :selectedSpecialism';
            }
            
            if(grossProfit.TR1__Job__c != null){ 
                query += ' and Vacancy__c = \'' + grossProfit.TR1__Job__c + '\'';     
                
            }
            
            if(String.isNotBlank(VacRec.TR1__Regional_Area__c)) {
                query += ' and Vacancy__r.TR1__Regional_Area__c = \'' + VacRec.TR1__Regional_Area__c + '\'';
            }
            
            if(String.isNotBlank(VacRec.TR1__Contact__c)) {
                query += ' and Vacancy__r.TR1__Contact__c = \'' + VacRec.TR1__Contact__c + '\'';
            }
            
            if(String.isNotBlank(conTemp.LEA__c)){
                query += ' and Vacancy__r.LEA__c = \'' + conTemp.LEA__c + '\'';
            }
            
            if(String.isNotBlank(conTemp.Hidden_Scheduler_Filter__c)){ 
                query += ' and Vacancy__r.OwnerId  = \'' + conTemp.Hidden_Scheduler_Filter__c + '\'';
            }
            
            if(String.isNotBlank(conTemp.Preferred_LEA__c)){
                List<String> testLEA = conTemp.Preferred_LEA__c.split(';');
                query += ' and Vacancy__r.sub_LEA__c IN : testLEA' ;//conTemp.Sub_LEA__c+'\''; 
            }
            
            if(String.isNotBlank(conTemp.Division__c)){ 
                query += ' and Vacancy__r.Branch__c  = \'' + conTemp.Division__c + '\'';
            }
            else{
                if(String.isNotBlank(whichVacancy)) {
                    if(whichVacancy == 'My Vacancies') { 
                        query += ' and Vacancy__r.OwnerId = :currentUserId'; 
                    }
                }
            }
            
            if (String.isNotBlank(VacRec.Subject2__c)){
                query += ' AND Vacancy__r.Subject2__c INCLUDES (' + createStringForMultiSelectFields(VacRec.Subject2__c) + ')';
            }
            
            if(String.isNotBlank(tempcontact.Job_Titles__c)) {
                List<String> testJobtitle = tempcontact.Job_Titles__c.split(';');
                query += ' AND Vacancy__r.Job_Title__c IN : testJobtitle'  ;//IN :selectedJobTitle';
            }
            
            if (String.isNotBlank(VacRec.Qualifications__c)){
                query += ' AND Vacancy__r.Qualifications__c INCLUDES (' + createStringForMultiSelectFields(VacRec.Qualifications__c) + ')';
            }
            
            if (String.isNotBlank(VacRec.Trained_As__c)){
                query += ' AND Vacancy__r.Trained_As__c INCLUDES (' + createStringForMultiSelectFields(VacRec.Trained_As__c) + ')';
            }
            
            if (String.isNotBlank(VacRec.SEN_Experience__c)){
                query += ' AND Vacancy__r.SEN_Experience__c INCLUDES (' + createStringForMultiSelectFields(VacRec.SEN_Experience__c) + ')';
            }
            
            if (String.isNotBlank(VacRec.Skills_Training_Experience__c)){
                query += ' AND Vacancy__r.Skills_Training_Experience__c INCLUDES (' + createStringForMultiSelectFields(VacRec.Skills_Training_Experience__c) + ')';
            }
            
            if (String.isNotBlank(VacRec.SEN_Additional_Experience__c)){
                query += ' AND Vacancy__r.SEN_Additional_Experience__c INCLUDES (' + createStringForMultiSelectFields(VacRec.SEN_Additional_Experience__c) + ')';
            }
            
            if (String.isNotBlank(VacRec.Year_Key_Stage__c)){
                query += ' AND Vacancy__r.Year_Key_Stage__c INCLUDES (' + createStringForMultiSelectFields(VacRec.Year_Key_Stage__c) + ')';
            }
            
            query += ' ORDER BY '+sortFullExp; // Added 6th Apr 17
            Integer queryLimit = 1000;
            queryLimit = 1000;
            
            if (Label.Scheduler_Query_Limit != null && String.isNotBlank(Label.Scheduler_Query_Limit)) { 
                queryLimit = Integer.valueOf(Label.Scheduler_Query_Limit);
            }
            system.debug('SelectSize------'+SelectSize);
            query += ' LIMIT ' + queryLimit;
            
            System.debug('Vacancy Availability Query : '+query);
            
            // Create Map of VacancyId with Vacancy D2D records
            vacancyD2DMap = new Map<Id, List<Vacancy_D2D__c>>();
            JobD2DWithDTMap = new Map < string , List < Vacancy_D2D__c >> ();
            List<Vacancy_D2D__c> vaclist = new List<Vacancy_D2D__c>();
            vaclist = Database.query(query);
            System.debug('==vaclist== '+vaclist.size());
            
            for(Vacancy_D2D__c d2d : (List<Vacancy_D2D__c>)Database.query(query)) {
                String key = d2d.Vacancy__c+'~'+d2d.Vacancy_Date__c;
                if(vacancyD2DMap.containsKey(d2d.Vacancy__c)){vacancyD2DMap.get(d2d.Vacancy__c).add(d2d);}
                else{vacancyD2DMap.put(d2d.Vacancy__c, new List<Vacancy_D2D__c>{d2d}); }
                system.debug('vacancyD2DMap--'+vacancyD2DMap.values());                
                if(JobD2DWithDTMap.containsKey(key)){JobD2DWithDTMap.get(key).add(d2d); }
                else{JobD2DWithDTMap.put(key,new List<Vacancy_D2D__c>{d2d});}
            }
            
            map<Integer, List<Resource>> resourceMap = new map < Integer, List < Resource >> ();
            map<String , List<Resource>> sortingMap  = new map < String , List< Resource >> ();
            set<id> pearsonplacedId = new set<id>();
            
            if(!vacancyD2DMap.isEmpty()){
                Set<Id> vaccId = vacancyD2DMap.keySet();
                system.debug('@developer-->vaccId:'+vaccId);
                String closingReportQuery = 'Select TR1__Job__r.Name, TR1__Job__c, LEA__c, Invoicing_Person__c,TR1__Timesheet_Approver__c,TR1__Person_Placed__c,TR1__Job_Credit__c , TR1__Job_Credit__r.Name,TR1__Person_Placed__r.Name, '
                    + 'TR1__Pay_Rate__c, TR1__Bill_Rate__c, Shift__c, Booking_Type__c,TR1__Timesheet_Approver__r.Name ,TR1__Candidate_Credit__c ,TR1__Job_Percentage__c, TR1__Candidate_Percentage__c, '
                    + '(Select Schedule_Date__c, Shift__c From Closing_Report_Schedules__r '
                    + ' where Schedule_Date__c >= :startDate and Schedule_Date__c <= :endDate) '
                    + 'From TR1__Closing_Report__c '
                    + 'where TR1__Job__c in :vaccId ' 
                    + 'and RecordType.Name = \'' + TRS_VacancyHelper.CONSULTING + '\'';
                
                map<Id, list<TR1__Closing_Report__c>> closingReportMap = new map<Id, list<TR1__Closing_Report__c>>();
                for(TR1__Closing_Report__c closingReport : (List<TR1__Closing_Report__c>)Database.query(closingReportQuery)) {
                    if(closingReportMap.containsKey(closingReport.TR1__Job__c)){closingReportMap.get(closingReport.TR1__Job__c).add(closingReport);}
                    else{closingReportMap.put(closingReport.TR1__Job__c, new List<TR1__Closing_Report__c>{closingReport});}
                    pearsonplacedId.add(closingReport.TR1__Person_Placed__c);
                }
                
                String crsScheduleQuery = 'Select Schedule_Date__c,Candidate_Availability__r.Candidate__r.Candidate_Alias__c,Shift__c, Closing_Report__c,Candidate_Availability__c,Vacancy_Schedule__c, Closing_Report__r.TR1__Person_Placed__c,Closing_Report__r.TR1__Job_Credit__r.Name, '
                    + 'Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report__r.TR1__Job__r.Name, Closing_Report__r.TR1__Job__c, Closing_Report__r.Shift__c, '
                    + 'CreatedById, Closing_Report__r.TR1__Job_Percentage__c, Closing_Report__r.TR1__Candidate_Percentage__c,Closing_Report__r.TR1__Timesheet_Approver__r.Name,Candidate_Availability__r.Candidate__r.Name, '
                    + 'Closing_Report__r.TR1__Pay_Rate__c, Closing_Report__r.TR1__Bill_Rate__c, Closing_Report__r.Booking_Type__c,Closing_Report__r.Maximum_Hour_Pay_Rate__c,Closing_Report__r.Maximum_Hour_Charge_Rate__c,Closing_Report__r.Maximum_Half_Day_Pay_Rate__c,Closing_Report__r.Maximum_Half_Day_Charge_Rate__c,Closing_Report__r.Maximum_Day_Pay_Rate__c,Closing_Report__r.Maximum_Charge_Per_Day__c,Closing_Report__r.Maximum_Pay_rate_Per_Day__c,Closing_Report__r.Maximum_Day_Charge_Rate__c '
                    + 'FROM Closing_Report_Schedule__c '
                    + 'Where Closing_Report__r.TR1__Job__c in :vaccId ' 
                    + 'And Schedule_Date__c >= :startDate and Schedule_Date__c <= :endDate And Status__c=\'Booked\''
                    + 'And Closing_Report__r.RecordType.Name = \'Consulting\' '
                    + 'And Closing_Report__r.Booking_Type__c != \'Extra Duties\''; 
                
                Map<Id, Map<Id, Closing_Report_Schedule__c>> vacancyCRSMap = new Map<Id, Map<Id, Closing_Report_Schedule__c>>();
                crsJSDMap =new Map < Id,Closing_Report_Schedule__c > ();
                crsCSDMap =new Map < Id,Closing_Report_Schedule__c > ();
                
                for(Closing_Report_Schedule__c crs: (List<Closing_Report_Schedule__c>) Database.query(crsScheduleQuery)) {
                    
                    if(vacancyCRSMap.containsKey(crs.Closing_Report__r.TR1__Job__c)) {vacancyCRSMap.get(crs.Closing_Report__r.TR1__Job__c).put(crs.Id, crs);}
                    else {
                        Map<Id, Closing_Report_Schedule__c> crsMap = new Map<Id, Closing_Report_Schedule__c>();
                        crsMap.put(crs.Id, crs);
                        vacancyCRSMap.put(crs.Closing_Report__r.TR1__Job__c, crsMap);
                    }
                    
                    if (!crsJSDMap.containsKey(crs.Vacancy_Schedule__c)) {crsJSDMap.put(crs.Vacancy_Schedule__c,crs); }
                    
                    if(crs.Candidate_Availability__c!=null){crsCSDMap.put(crs.Candidate_Availability__c,crs);
                    }
                }
                queryLimit = SelectSize;
                System.debug('Vacancy CRS map '+vacancyCRSMap); 
                mapToShowWithHeld = new Map<Id, String>();
                mapToShowPersonPlaced = new Map<Id, String>();
                integer recordCount = 0;
                Integer z = 0; // for multiple vacancies with name 
                for(TR1__Job__c job : [Select Job_Title__c, TR1__Experience_Requirements__c, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c,TR1__Maximum_Bill_Rate__c,TR1__Account__r.Name,Sector1__c,Maximum_Hour_Pay_Rate__c,TR1__Maximum_Pay_Rate__c,Maximum_Hour_Charge_Rate__c,TR1__Minimum_Bill_Rate__c,Subject2__c,Year_Key_Stage__c,
                                       TR1__Account__r.Set_Account_GeoLocation__Latitude__s, TR1__Account__r.Set_Account_GeoLocation__Longitude__s,
                                       TR1__Contact__r.Set_Contact_GeoLocation__Latitude__s , TR1__Contact__r.Set_Contact_GeoLocation__Longitude__s, 
                                       TR1__Account__c, TR1__Hiring_Manager__r.Name,TR1__Contact__r.Name,TR1__Account_Name__c, Reports_To__c, Minimum_Annual_Salary__c, Maximum_Annual_Salary__c,TR1__Minimum_Pay_Rate__c, Sub_Sector__c, Specialism__c,Sub_LEA__c,
                                       LEA__c, Booking_Type__c, Applicable_Days__c, Name, Shift__c ,TR1__Primary_Background__c,TR1__Account__r.LEA__c,TR1__Account__r.LEA_Region__c, Reports_To__r.LastName
                                       From TR1__Job__c limit :queryLimit OFFSET :OFFSETvalue]) {
                                    //    where Id in :vacancyD2DMap.keySet() and TR1__Estimated_Start_Date__c != null and TR1__Estimated_End_Date__c != null limit :queryLimit OFFSET :OFFSETvalue]) {
                                       
                                           
                                           List < Vacancy_D2D__c > vacD2DList = (vacancyD2DMap.containsKey(job.Id)) ? vacancyD2DMap.get(job.Id) : new List < Vacancy_D2D__c > ();
                                        //    List < Vacancy_D2D__c > vacD2DList = new List < Vacancy_D2D__c > ();
                                           System.debug('####$$$$vacD2DList=>'+vacD2DList);
                                           jsdDateMap = new Map < Date,List<Vacancy_D2D__c> > ();
                                           mapToShowWithHeld.put(job.TR1__Account__c, '');
                                           mapToShowPersonPlaced.put(job.TR1__Account__c,'');

                                           if(vacancyD2DMap.containsKey(job.Id)){
                                                System.debug('test if_---------------------------------------------------');
                                                for( Vacancy_D2D__c jsd :vacancyD2DMap.get(job.Id)){
                                                    if(jsdDateMap.containsKey(jsd.Vacancy_Date__c)){jsdDateMap.get(jsd.Vacancy_Date__c).add(jsd);
                                                    }
                                                    else{jsdDateMap.put(jsd.Vacancy_Date__c,new List<Vacancy_D2D__c>{jsd});    
                                                    }
                                                }
                                                system.debug('==============job===='+job);
                                                Decimal distanceValue = 0;
                                                if(job.TR1__Account__r.Set_Account_GeoLocation__Latitude__s != null && job.TR1__Account__r.Set_Account_GeoLocation__Longitude__s != null && 
                                                   contact.Set_Contact_GeoLocation__Latitude__s != null && contact.Set_Contact_GeoLocation__Longitude__s != null){
                                                       Location siteLocation = Location.newInstance(job.TR1__Account__r.Set_Account_GeoLocation__Latitude__s, job.TR1__Account__r.Set_Account_GeoLocation__Longitude__s);
                                                       Location centerLocation = Location.newInstance(contact.Set_Contact_GeoLocation__Latitude__s, contact.Set_Contact_GeoLocation__Longitude__s);
                                                       distanceValue = Location.getDistance(centerLocation, siteLocation, 'mi');
                                                       distanceValue = distanceValue.setscale(2);
                                                   } 
                                                
                                                List<TR1__Closing_Report__c> closingReportList = (closingReportMap.containsKey(job.Id)) ? closingReportMap.get(job.Id) : new List<TR1__Closing_Report__c>();
                                                Map<Id, Closing_Report_Schedule__c> crsMap = (vacancyCRSMap.containsKey(job.Id)) ? vacancyCRSMap.get(job.Id) : new Map<Id, Closing_Report_Schedule__c>();
                                                Resource res = new Resource(job, distanceValue, vacD2DList, startDate, endDate, crsJSDMap, weekDayMap,jsdDateMap,crsCSDMap);
                                                // Populationg resource Map
                                                if (resourceMap.containsKey(res.score)){resourceMap.get(res.score).add(res);
                                                }
                                                else{resourceMap.put(res.score, new List < Resource > {res});
                                                }
                                                if(!sortingMap.containsKey(job.Name)){sortingMap.put(job.Name,new List < Resource > {res});

                                                }
                                                else if(sortingMap.containsKey(job.Name)){ // for multiple vacancies with name 
                                                    String jobName = job.Name+'-'+z;
                                                    sortingMap.put(jobName,new List < Resource > {res});
                                                    
                                                }
                                                z++; // for multiple vacancies with name 
                                                
                                                recordCount++;
                                                crsMap = null;
                                            }else{
                                               System.debug('test else_---------------------------------------------------');

                                               system.debug('==============job2===='+job);
                                               Decimal distanceValue = 0;
                                               if(job.TR1__Account__r.Set_Account_GeoLocation__Latitude__s != null && job.TR1__Account__r.Set_Account_GeoLocation__Longitude__s != null && 
                                                  contact.Set_Contact_GeoLocation__Latitude__s != null && contact.Set_Contact_GeoLocation__Longitude__s != null){
                                                      Location siteLocation = Location.newInstance(job.TR1__Account__r.Set_Account_GeoLocation__Latitude__s, job.TR1__Account__r.Set_Account_GeoLocation__Longitude__s);
                                                      Location centerLocation = Location.newInstance(contact.Set_Contact_GeoLocation__Latitude__s, contact.Set_Contact_GeoLocation__Longitude__s);
                                                      distanceValue = Location.getDistance(centerLocation, siteLocation, 'mi');
                                                      distanceValue = distanceValue.setscale(2);
                                                  } 
                                                List<TR1__Closing_Report__c> closingReportList = (closingReportMap.containsKey(job.Id)) ? closingReportMap.get(job.Id) : new List<TR1__Closing_Report__c>();
                                                Map<Id, Closing_Report_Schedule__c> crsMap = (vacancyCRSMap.containsKey(job.Id)) ? vacancyCRSMap.get(job.Id) : new Map<Id, Closing_Report_Schedule__c>();
                                                Resource res = new Resource(job, distanceValue, vacD2DList, startDate, endDate, crsJSDMap, weekDayMap,jsdDateMap,crsCSDMap);

                                                System.debug('closingReportList=> . '+closingReportList);
                                                System.debug('crsMap=> . '+crsMap);
                                                System.debug('res=> . '+res);

                                                if (resourceMap.containsKey(res.score)){resourceMap.get(res.score).add(res);
                                                }
                                                else{resourceMap.put(res.score, new List < Resource > {res});
                                                }
                                                if(!sortingMap.containsKey(job.Name)){sortingMap.put(job.Name,new List < Resource > {res});
                                                }
                                                else if(sortingMap.containsKey(job.Name)){ // for multiple vacancies with name 
                                                    String jobName = job.Name+'-'+z;
                                                    sortingMap.put(jobName,new List < Resource > {res});
                                                }
                                                z++; // for multiple vacancies with name 
                                                
                                                recordCount++;
                                                crsMap = null;
                                           }
                                       }
                recordSize = recordCount;
                vacancyCRSMap = null;
                pearsonplacedId = null;
                
                //WithHeld &  Previously Placed Candidates
                if(contact.id != null){
                    
                    //Previously Placed Candidates
                    for(TR1__Closing_Report__c cr : [Select Id,TR1__Person_Placed__c,TR1__Account__c From TR1__Closing_Report__c Where TR1__Person_Placed__c = :contact.id AND TR1__Account__c != null]){
                        mapToShowPersonPlaced.put(cr.TR1__Account__c,'*');
                    }
                    
                    //WithHeld
                    Map<Id, Set<String>> schoolWitheld = new Map<Id, Set<String>>();
                    for(Withheld__c w : [Select Id, School__c, Candidate__c, Withheld_Type__c From Withheld__c Where Candidate__c = :contact.id]){
                        if(!schoolWitheld.containsKey(w.School__c)){schoolWitheld.put(w.School__c, new Set<String>());
                        }
                        schoolWitheld.get(w.School__c).add(w.Withheld_Type__c);
                    }
                    
                    for(Id accId : schoolWitheld.keySet()){
                        List<String> sortedTypes = new List<String>();
                        sortedTypes.addAll(schoolWitheld.get(accId));
                        sortedTypes.sort();
                        mapToShowWithHeld.put(accId, '');
                        String glue = '';
                        for(String typ : sortedTypes){
                            mapToShowWithHeld.put(accId, mapToShowWithHeld.get(accId)+glue+typ);
                            glue = ',';
                        }
                    }       
                }
                system.debug('===mapToShowWithHeld'+mapToShowWithHeld);
            }
            
            //Sorting on basis of score
            if (!resourceMap.isEmpty()) {
                list < Integer > scoreList = new list < Integer > ();
                scoreList.addAll(resourceMap.keyset());
                scoreList.sort();
                
                Integer pageSize = 150;
                if (Label.Scheduler_Page_Size != null && String.isNotBlank(Label.Scheduler_Page_Size)){ pageSize = Integer.valueOf(Label.Scheduler_Page_Size);
                }
                resources = new List<Resource>();
                for (Integer i = scoreList.size() - 1; i >= 0; i--) {
                    if (resourceMap.containsKey(scoreList[i])) {
                        for (Resource res: resourceMap.get(scoreList[i])) {
                            resources.add(res);
                            if (resources.size() >= pageSize){break;

                            }
                        }
                    }
                }
                resourceMap.clear();
            }
            
            // sorting on basis of Vacancy Name
            if(!sortingMap.isEmpty()) {
                
                List< String > vacancyNameList = new List< String > ();
                List< String > tempvacancyNameList = new List< String > ();
                vacancyNameList.addAll(sortingMap.keyset());
                for(String s : tempvacancyNameList){
                    if(s.contains('-')){
                        String[] strArr = s.split('-');
                        vacancyNameList.add(strArr[0]);
                    }else{vacancyNameList.add(s); 
                    }
                }
                vacancyNameList.sort();
                
                if(sortDirection == 'ASC'){
                    resources = new List<Resource>();
                    for(String vacName : vacancyNameList){
                        if(sortingMap.containsKey(vacName)){
                            for (Resource res: sortingMap.get(vacName)) { 
                                resources.add(res);
                            }    
                        }
                    }
                }
                else {
                    resources = new List<Resource>();
                    for (Integer i = vacancyNameList.size() - 1; i >= 0; i--) {
                        if (sortingMap.containsKey(vacancyNameList[i])) {
                            for (Resource res: sortingMap.get(vacancyNameList[i])) {
                                resources.add(res);
                            } 
                        }
                    }   
                }
                
                if(isSortingByDistances && contact != null && contact.id != null){
                    List<Decimal> lstDistances = new List<Decimal>();
                    Set<Decimal> setDistances = new Set<Decimal>();
                    Map<Decimal,List<Resource>> mapRess = new Map<Decimal,List<Resource>>();
                    for (Resource res : resources) {
                        lstDistances.add(res.distanceVal);
                        if(!mapRess.containsKey(res.distanceVal)){mapRess.put(res.distanceVal,new List<Resource>());
                        }
                        mapRess.get(res.distanceVal).add(res);
                    }
                    if(lstDistances.size() > 0){
                        lstDistances.sort();
                        for(Decimal dval : lstDistances){
                            setDistances.add(dval);
                        }
                    }
                    resources = new List<Resource>();
                    if(setDistances.size() > 0){
                        for(Decimal dv : setDistances){
                            if(mapRess.containsKey(dv)){
                                for(Resource r : mapRess.get(dv)){
                                    resources.add(r);
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Error '+e+'Line number --'+e.getLineNumber());
        }
    }
    /* FILTER JOB LOGIC : END */
    
    /*  CREATE BOOKING DAILOG : START*/
    
    public TR1__Job__c VacancyRecord {get; set;} //Hardik : 04Dec2016 : to be removed as this is not used on Page
    public TR1__Closing_Report__c closingReport {get; set;}
    
    public String vacancyName   {get; set;}
    public String vacancyId    {get; set;}
    
    TR1__Job__c vacancyRec ;
    
    public Boolean showAssignmentDialogBox { //Used to show/Hide Book Candidate Popup
        get {
            if(showAssignmentDialogBox == null){showAssignmentDialogBox = false;
            }
            return showAssignmentDialogBox; 
        }
        set;
    }
    
    Boolean partialsave = false;
    
    public void matchCSDJSDslots(){
        
        String Job1  = ApexPages.currentPage().getParameters().get('Job1');
        csdJSDateMap = new Map<date,List<CSDJSDwrap>>();
        
        if(vacancyD2DMap.containsKey(Job1) && vacancyD2DMap.get(Job1).size()>0){
            System.debug('vacancyStartDate -->'+vacancyStartDate);
            if(vacancyStartDate != '' && string.isNotEmpty(vacancyStartDate)){
                Map<string,string> MapMonthList = new Map<string,string>();
                MapMonthList.put('jan','01');
                MapMonthList.put('feb','02');
                MapMonthList.put('mar','03');
                MapMonthList.put('apr','04');
                MapMonthList.put('may','05');
                MapMonthList.put('jun','06');
                MapMonthList.put('jul','07');
                MapMonthList.put('aug','08');
                MapMonthList.put('sep','09');
                MapMonthList.put('oct','10');
                MapMonthList.put('nov','11');
                MapMonthList.put('dec','12');    
    
                String myDate = vacancyStartDate;
                String strMnth = myDate.substring(4,7).toLowerCase();
                String day = myDate.substring(8,10);
                String year = myDate.substring(24,28);   
                
                String strMonth ;
                if(MapMonthList.containsKey(strMnth)){strMonth = MapMonthList.get(strMnth);
                } 
                vacancyStartDate = day+'/'+strMonth+'/'+year;
            }
            
            
            for(resource res :resources){
                if(res.vacancy.id != Job1) continue;
                
                for(Date dt: res.dateAvailMap.Keyset()){
                    String key = Job1+'~'+dt;
                    
                    if(JobD2DWithDTMap.Keyset().contains(key)){
                        for(Vacancy_D2D__c ddwrap :JobD2DWithDTMap.get(key)){
                            
                            if( ddwrap.Start_Date_Time__c==null || ddwrap.End_Date_Time__c==null) continue;
                            
                            CSDJSDwrap comwrap =new CSDJSDwrap(new Vacancy_D2D__c(),new Candidate_Availability__c(),'none');
                            
                            if(weekDayMap.get(dt)[0].Id!=null){
                                for(Candidate_Availability__c csd :weekDayMap.get(dt)){
                                    if(csd.Start_Date_Time__c==null || csd.End_Date_Time__c==null) continue;
                                    
                                    if(ddwrap.Start_Date_Time__c >= csd.Start_Date_Time__c && csd.End_Date_Time__c >= ddwrap.End_Date_Time__c &&  (!crsCSDMap.containsKey(csd.Id) && crsCSDMap.get(csd.Id)==null)){
                                        
                                        comwrap = crsJSDMap.get(ddwrap.Id) != null ? new CSDJSDwrap(ddwrap,csd,'redColorStyle') : new CSDJSDwrap(ddwrap,csd,'greenColorStyle');
                                        
                                        if(!csdJSDateMap.containsKey(dt)){csdJSDateMap.put(dt,new List<CSDJSDwrap>{comwrap});   
                                        }
                                        else{csdJSDateMap.get(dt).add(comwrap);
                                        }
                                        if(comwrap.Colour.equals('greenColorStyle')) break;
                                    }
                                }
                            }
                            else{
                                comwrap = new CSDJSDwrap(ddwrap,new Candidate_Availability__c(),'grayColorStyle');
                                if(!csdJSDateMap.containsKey(dt)){csdJSDateMap.put(dt,new List<CSDJSDwrap>{comwrap});
                                }
                                else{csdJSDateMap.get(dt).add(comwrap);
                                }
                            }   
                        } 
                    }
                    else{Continue;
                        System.debug('No candidate Availablity found for selected Contact : '+ key);
                    }
                }
            }
        }else{
            Utility.AddInfoMessage('No matching Vacancy found');
        }
    }

    public transient String clientContact{get; set;}
    public transient String hManager{get; set;}
    public void openDialogForClosingReport() {
        
        matchCSDJSDslots();
        closingReport = new TR1__Closing_Report__c();
        closeRepSchedule = new Closing_Report_Schedule__c();
        VacancyRecord = new TR1__Job__c();
        vacancyRecord.RecordTypeId = TRS_VacancyHelper.CONSULTING_RTID;
        closingReport.Annual_Leave_Entitlement__c = '65';
        closingReport.School_Working_Days__c = 195.0;
        closingReport.Pay_Type__c = Utility.getPageParameter('vacancyPayType');
        
        // Get the Parameters passed
        vacancyId = Utility.getPageParameter('Job1');
        String vacancyDate = String.valueOf(endDate);
        String DateValue  = Date.valueOf(vacancyDate).format();
        
        vacancyRec = [SELECT Name, TR1__Estimated_Start_Date__c, TR1__Contact__r.FirstName, TR1__Contact__r.LastName, TR1__Estimated_End_Date__c, Applicable_Days__c,TR1__Hiring_Manager__r.Name, Timesheet_Approver__c, TR1__Account__r.Agreed_D2D_Charge_Rate__c, TR1__Account__r.BillingStreet,
                      TR1__Account__r.Set_Account_GeoLocation__Latitude__s, TR1__Account__r.Set_Account_GeoLocation__Longitude__s,Maximum_Hour_Charge_Rate__c,TR1__Minimum_Pay_Rate__c,TR1__Minimum_Bill_Rate__c,
                      TR1__Contact__r.Set_Contact_GeoLocation__Latitude__s , TR1__Contact__r.Set_Contact_GeoLocation__Longitude__s,TR1__Maximum_Pay_Rate__c,TR1__Maximum_Bill_Rate__c,
                      TR1__Account__r.BillingCity, TR1__Account__r.BillingState, TR1__Account__r.BillingPostalCode, TR1__Account__r.Invoice_Contact__c, Booking_Type__c,Booking_Reason__c,Maximum_Hour_Pay_Rate__c ,
                      (SELECT Vacancy_Date__c, Shift__c, Closing_Report_Schedule__c FROM Vacancy_D2Ds__r WHERE Vacancy_Date__c >= :startDate AND Vacancy_Date__c <= :endDate)
                      FROM TR1__Job__c 
                      WHERE id = :vacancyId]; 
        
        VacancyRecord.Booking_Type__c = vacancyRec.Booking_Type__c;
        VacancyRecord.Booking_Reason__c = vacancyRec.Booking_Reason__c;
        VacancyRecord.Maximum_Hour_Pay_Rate__c = vacancyRec.Maximum_Hour_Pay_Rate__c;
        VacancyRecord.Maximum_Hour_Charge_Rate__c = vacancyRec.Maximum_Hour_Charge_Rate__c;
        VacancyRecord.TR1__Maximum_Pay_Rate__c = vacancyRec.TR1__Maximum_Pay_Rate__c;
        VacancyRecord.TR1__Maximum_Bill_Rate__c = vacancyRec.TR1__Maximum_Bill_Rate__c;
        VacancyRecord.TR1__Minimum_Pay_Rate__c = vacancyRec.TR1__Minimum_Pay_Rate__c;
        VacancyRecord.TR1__Minimum_Bill_Rate__c = vacancyRec.TR1__Minimum_Bill_Rate__c;
        vacancyName = vacancyRec.Name;
        String cFName = vacancyRec.TR1__Contact__r.FirstName!= null? vacancyRec.TR1__Contact__r.FirstName:'';
        String cLName = vacancyRec.TR1__Contact__r.LastName!= null?vacancyRec.TR1__Contact__r.LastName:'';
        hManager = vacancyRec.TR1__Hiring_Manager__r.Name!= null?vacancyRec.TR1__Hiring_Manager__r.Name:'';
        
        map<Date, Vacancy_D2D__c> vacancyAvailMap = new map<Date, Vacancy_D2D__c>();
        if(vacancyRec != null && vacancyRec.Vacancy_D2Ds__r != null && vacancyRec.Vacancy_D2Ds__r.size() > 0) {
            for(Vacancy_D2D__c vacD2D : vacancyRec.Vacancy_D2Ds__r) {
                vacancyAvailMap.put(vacD2D.Vacancy_Date__c, vacD2D);
            }
        }
        
        TR1__Closing_Report__c[] closingReports = [Select Name,TR1__Start_Date__c, TR1__End_Date__c, TR1__Bill_Rate__c, TR1__Pay_Rate__c, Shift__c, Booking_Type__c, TR1__Candidate_Credit__c ,TR1__Job_Percentage__c, TR1__Candidate_Percentage__c,
                                                   TR1__Timesheet_Type__c, TR1__Timesheet_Approver__c, TR1__OT_Bill_Rate_Multiplier_Percentage__c, TR1__Job_Credit__c, TR1__Person_Placed__c,TR1__Job_Credit__r.Name, 
                                                   TR1__Candidate_Credit__r.Name, TR1__Timesheet_Approver__r.Name, TR1__Marketing_Credit__c, TR1__Marketing_Credit__r.Name, TR1__Marketing_Percentage__c, 
                                                   TR1__Other_Credit__c, TR1__Other_Credit__r.Name, TR1__Other_Percentage__c,Shift_Multiple__c,Comparator_Full_Time_Annual_Salary__c ,School_Working_Days__c,Annual_Leave_Entitlement__c,Maximum_Hour_Pay_Rate__c,Maximum_Hour_Charge_Rate__c,Maximum_Day_Pay_Rate__c,Maximum_Charge_Per_Day__c,Maximum_Pay_rate_Per_Day__c,Maximum_Day_Charge_Rate__c,Maximum_Half_Day_Pay_Rate__c,Maximum_Half_Day_Charge_Rate__c,Pay_Type__c ,
                                                   TR1__Other2_Credit__c, TR1__Other2_Credit__r.Name, TR1__Other2_Percentage__c,
                                                   TR1__Job__r.TR1__Maximum_Bill_Rate__c,TR1__Job__r.TR1__Maximum_Pay_Rate__c,TR1__Job__r.Maximum_Hour_Pay_Rate__c,TR1__Job__r.Maximum_Hour_Charge_Rate__c,TR1__Job__r.TR1__Minimum_Pay_Rate__c,TR1__Job__r.TR1__Minimum_Bill_Rate__c 
                                                   from TR1__Closing_Report__c 
                                                   where   TR1__Person_Placed__c = :contact.id 
                                                   and   TR1__Job__c = :vacancyId
                                                   and   RecordType.Name = :TRS_VacancyHelper.CONSULTING
                                                   and TR1__Start_Date__c <= :startDate
                                                   and TR1__End_Date__c >= :endDate
                                                   order by TR1__Start_Date__c];
        
        Date selectedDate = Date.parse(DateValue);
        Date startoftheWeekDate = selectedDate.toStartOfWeek();
        
        if(vacancyStartDate != null){
            startDateEnterred=vacancyStartDate;
            endDateEnterred = vacancyStartDate;
        }
        else
        {
            startDateEnterred = Date.valueOf(vacancyRec.TR1__Estimated_Start_Date__c).format();//Utility.DateFormat(Date.today());//Updated on 2-DEC-2016
            endDateEnterred = Utility.DateFormat(vacancyRec.TR1__Estimated_End_Date__c);
        }
        
        
        hiringManagerName = vacancyRec.TR1__Hiring_Manager__r.Name;
        if(closingReports != null && closingReports.size() > 0) {
            Boolean isFound = false;
            Integer i =1;
            for(TR1__Closing_Report__c tempCR : closingReports){
                
                if(i == 1){
                    
                    if(selectedDate < tempCR.TR1__Start_Date__c){
                        closingReport = tempCR;
                        isFound = true;
                        break;
                    }   
                    
                    i++;
                }
                
                if(selectedDate >= tempCR.TR1__Start_Date__c && selectedDate <= tempCR.TR1__End_Date__c){
                    closingReport = tempCR;
                    isFound = true; 
                    break;
                }
            }
            System.debug('closingReport::::'+closingReport);
            if(isFound == false){closingReport = closingReports[closingReports.size()-1];
                System.debug('closingReport is :'+closingReport);
            }
            
            closingReport = closingReports[0];
        }
        else {
            
            closingReport.TR1__Job__c                   = vacancyId;
            closingReport.TR1__Person_Placed__c         = contact.id;
            closingReport.Invoicing_Person__c           = vacancyRec.TR1__Account__r.Invoice_Contact__c;
            closingReport.TR1__Start_Date__c            = Date.parse(startDateEnterred);
            closingReport.TR1__End_Date__c              = Date.parse(endDateEnterred);
            closingReport.RecordTypeId                  = Utility.CONSULTING_RTID;
            closingReport.TR1__Bill_Rate__c             = vacancyRec.TR1__Account__r.Agreed_D2D_Charge_Rate__c;  
            closingReport.TR1__Pay_Rate__c              = contact.Agreed_D2D_Pay_Rate__c;
            closingReport.TR1__Timesheet_Approver__c    = vacancyRec.Timesheet_Approver__c;
            closingReport.TR1__Job_Credit__c            = userinfo.getUserId();
            closingReport.Booking_Type__c               = vacancyRec.Booking_Type__c; 
            closingReport.Booking_Reason__c             = vacancyRec.Booking_Reason__c;
            closingReport.Shift_Multiple__c             = 1;
            closingReport.TR1__Account__c               = vacancyRec.TR1__Account__c; 
            closingReport.TR1__Billing_Street__c        = vacancyRec.TR1__Account__r.BillingStreet;     
            closingReport.TR1__Billing_City__c          = vacancyRec.TR1__Account__r.BillingCity;
            closingReport.Hiring_Manager__c             = vacancyRec.TR1__Hiring_Manager__c;
            clientContact 								=  cFName+ ' ' +cLName ;
            
            conToShowRate = [Select Id, Daily_Rate_Agreed__c, Half_Day_Rate_Agreed__c, Hourly_Rate_Agreed__c FROM Contact where Id =: closingReport.TR1__Person_Placed__c limit 1];

            if(vacancyRec.TR1__Account__r.BillingState  != null){
                String shippingState = vacancyRec.TR1__Account__r.BillingState ;
                if(vacancyRec.TR1__Account__r.BillingState .length() >3){
                    String State =shippingState.substring(0, 3);
                    closingReport.TR1__Billing_State__c = state;
                }
                else {closingReport.TR1__Billing_State__c = shippingState;
                }
            }
        }  
        showAssignmentDialogBox = true;
    }
    
    public PageReference saveClosingReport() {
        Savepoint sp = Database.setSavepoint();
        try {
            if(string.isBlank(startDateEnterred) && string.isBlank(endDateEnterred)){
                Utility.AddErrorMessage('Please Enter the Start Date and End Date ');
                return null ;
            }
            if(string.isBlank(startDateEnterred)){
                Utility.AddErrorMessage('Please Enter the Start Date ');
                return null ;
            }
            if(string.isBlank(endDateEnterred)){
                Utility.AddErrorMessage('Please Enter the End Date ');
                return null ;
            }
            
            if(closingReport.School_Working_Days__c == null || String.isBlank(closingReport.Annual_Leave_Entitlement__c)){
                Utility.AddErrorMessage('Please populate all required fields.');
                return null ;
            }
            
            date startdateforcr = Date.parse(startDateEnterred);
            date enddateforcr   = Date.parse(endDateEnterred);
            Boolean validDaterange = false;
            for (Integer i = 0; i <= startdateforcr.daysBetween(enddateforcr); i++) {
                csdJSDateMap.containsKey(startdateforcr.addDays(i));
                validDaterange = True;
            }
            if(!validDaterange){
                Utility.AddErrorMessage('Please select valid date range as no slots for booking found in this range.');
                return null;
            }else{
                Map<Date,List<Vacancy_D2D__c>> tempVacAvailmap =new  Map<Date,List<Vacancy_D2D__c>>();
                Map<Date,List<Candidate_Availability__c>> tempCanAvailmap = new Map<Date,List<Candidate_Availability__c>>();
                
                // First Upsert the Closing Report
                if(closingReport.Id == null){
                    closingReport.TR1__Start_Date__c = startdateforcr;
                    closingReport.TR1__End_Date__c = enddateforcr;
                    closingReport.Contract_End_Date__c = enddateforcr;
                    closingReport.Booking_Type__c = VacancyRecord.Booking_Type__c;
                    
                    if(test.isRunningTest()) closingReport.TR1__Job_Percentage__c=100;
                    if(closingReport.Pay_Type__c=='Hourly' && (closingReport.Maximum_Hour_Pay_Rate__c==null || closingReport.Maximum_Hour_Charge_Rate__c==null)){
                    }else {
                        ClosingReportTriggerHelper.FromJobboard = True ;
                        Contact con = [Select Id, Daily_Rate_Agreed__c, Half_Day_Rate_Agreed__c, Hourly_Rate_Agreed__c FROM Contact where Id =: closingReport.TR1__Person_Placed__c limit 1];
                        
                        if(closingReport.Maximum_Day_Pay_Rate__c != null){
                            if(closingReport.Maximum_Day_Pay_Rate__c > con.Daily_Rate_Agreed__c){
                                ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Day Pay Rate	 More then Maximum Day Pay Rate'));
                                return null;
                            }
                        }
                        
                        if(closingReport.Maximum_Day_Pay_Rate__c == null) closingReport.Maximum_Day_Pay_Rate__c = con.Daily_Rate_Agreed__c;
                        
                        if(closingReport.Maximum_Half_Day_Pay_Rate__c != null){
                            if(closingReport.Maximum_Half_Day_Pay_Rate__c > con.Half_Day_Rate_Agreed__c){
                                ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Half Day Pay Rate More then Maximum Half Day Pay Rate'));
                                return null;
                            }
                        }
                        
                        if(closingReport.Maximum_Half_Day_Pay_Rate__c == null) closingReport.Maximum_Half_Day_Pay_Rate__c = con.Half_Day_Rate_Agreed__c;
                        
                        if(closingReport.Maximum_Hour_Pay_Rate__c != null){
                            if(closingReport.Maximum_Hour_Pay_Rate__c > con.Hourly_Rate_Agreed__c){
                                ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Hour Pay Rate More then Maximum Hour Day Pay Rate'));
                                return null;
                            }
                        }
                        
                        if(closingReport.Maximum_Hour_Pay_Rate__c == null) closingReport.Maximum_Hour_Pay_Rate__c = con.Hourly_Rate_Agreed__c;
                        
                        if(closingReport.Maximum_Day_Charge_Rate__c == null) closingReport.Maximum_Day_Charge_Rate__c = VacancyRecord.TR1__Maximum_Bill_Rate__c; 
                        
                        if(closingReport.Maximum_Half_Day_Charge_Rate__c == null) closingReport.Maximum_Half_Day_Charge_Rate__c = VacancyRecord.TR1__Minimum_Bill_Rate__c;
                        
                        if(closingReport.Maximum_Hour_Charge_Rate__c == null ) closingReport.Maximum_Hour_Charge_Rate__c = VacancyRecord.Maximum_Hour_Charge_Rate__c;  
                        
                        insert closingReport;    
                    }
                    
                }  
                
                List <Closing_Report_Schedule__c> crsList = new List <Closing_Report_Schedule__c>();
                
                
                if( enddateforcr <=  enddate){
                    
                    for(Date dt : csdJSDateMap.keyset()){
                        
                        for(CSDJSDwrap ddwrap : csdJSDateMap.get(dt)){
                            if(ddwrap.Colour=='greenColorStyle'){
                                Closing_Report_Schedule__c CRS = new Closing_Report_Schedule__c();
                                CRS.Schedule_Date__c = dt;
                                CRS.Closing_Report__c  =closingReport.Id;
                                CRS.Candidate_Availability__c = ddwrap.canAvail.Id;
                                CRS.Vacancy_Schedule__c = ddwrap.vaccAvail.ID;
                                CRS.Status__c  = 'Booked';
                                crsList.add(CRS);
                            }
                        }
                        if(dt == enddateforcr){break;
                        }
                    }
                }else{
                    for (Candidate_Availability__c candD2D : [Select Start_Date__c,Candidate__r.Candidate_Alias__c,End_Date__c,End_Date_Time__c,Start_Date_Time__c,Candidate__c,Applicable_Days__c,Type__c
                                                              from  Candidate_Availability__c
                                                              where Candidate__c = : closingReport.TR1__Person_Placed__c
                                                              and   Start_Date__c >= : startDate and Start_Date__c <= : enddateforcr
                                                              order By createdDate]) {
                                                                  if(!tempCanAvailmap.containsKey(candD2D.Start_Date__c)){tempCanAvailmap.put(candD2D.Start_Date__c, New List<Candidate_Availability__c>{candD2D});
                                                                  }
                                                                  else{ tempCanAvailmap.get(candD2D.Start_Date__c).add(candD2D);
                                                                  }
                                                                  
                                                                  // If cpu limit reached break loop and return whatever search result    
                                                                  if(Limits.getCpuTime() >= (Limits.getLimitCpuTime() * Decimal.valueOf(Label.TRS_FC_CPU_Threshold))){
                                                                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Since CPU limit reached '+Limits.getCpuTime()+'/'+Limits.getLimitCpuTime()+', we could not search all records. Please refine your search criteria to ensure you get required result'));
                                                                      break;
                                                                  }
                                                                  // If memory limit reached break loop and return whatever search result    
                                                                  if(Limits.getHeapSize() >= (Limits.getLimitHeapSize() * Decimal.valueOf(Label.TRS_FC_HeapSize_Threshold))){
                                                                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Since memory limit reached '+Limits.getHeapSize()+'/'+Limits.getLimitHeapSize()+', we could not search all records. Please refine your search criteria to ensure you get required result'));
                                                                      break;
                                                                  }            
                                                              }
                    
                    for (Vacancy_D2D__c vacD2D: [Select Candidate_Assigned__c, Shift__c, Status__c, Vacancy__c, Vacancy_Date__c,Start_Date_Time__c,End_Date_Time__c,Closing_Report_Schedule__c, Closing_Report_Schedule__r.Shift__c, Closing_Report_Schedule__r.createdById, Closing_Report_Schedule_Secondary__r.createdById,
                                                 Closing_Report_Schedule__r.Closing_Report__r.Booking_Type__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Bill_Rate__c, Closing_Report_Schedule_Secondary__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__r.Name,
                                                 Closing_Report_Schedule__r.Closing_Report__r.TR1__Pay_Rate__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job_Credit__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__c,
                                                 Closing_Report_Schedule__r.Closing_Report__r.Shift__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report_Schedule_Secondary__r.Shift__c, Vacancy__r.Booking_Type__c,
                                                 Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__r.Name,Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Day_Pay_Rate__c,Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Day_Charge_Rate__c,Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Half_Day_Pay_Rate__c,
                                                 Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Half_Day_Charge_Rate__c,Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Hour_Pay_Rate__c,Closing_Report_Schedule_Secondary__r.Closing_Report__r.Maximum_Hour_Charge_Rate__c
                                                 from Vacancy_D2D__c
                                                 where Vacancy__c =: vacancyId and Vacancy_Date__c >=: startdateforcr and Vacancy_Date__c <=: enddateforcr and Start_Date_Time__c != null and End_Date_Time__c != null
                                                ]) {
                                                    if(!tempVacAvailmap.containsKey(vacD2D.Vacancy_Date__c)){tempVacAvailmap.put(vacD2D.Vacancy_Date__c, new List<Vacancy_D2D__c>{vacD2D});
                                                    }
                                                    else{tempVacAvailmap.get(vacD2D.Vacancy_Date__c).add(vacD2D);
                                                    }
                                                }
                    Integer numberDaysDue = startDate.daysBetween(enddateforcr);
                    Set<Id> candidateAvailablityIdSet = new Set<Id>();
                    for(integer dt = 0; dt<=numberDaysDue; dt++){
                        Utility.AddErrorMessage('dates are -- '+startdateforcr.addDays(dt));
                        
                        if(tempVacAvailmap.get(startDate.addDays(dt))==null){continue;
                        }
                        for(Vacancy_D2D__c vcc : tempVacAvailmap.get(startDate.addDays(dt))){
                            if(tempCanAvailmap.get(startDate.addDays(dt))==null)
                                continue;
                            for(Candidate_Availability__c candt : tempCanAvailmap.get(startDate.addDays(dt))){
                                if((candt.Start_Date_Time__c <= vcc.Start_Date_Time__c && vcc.End_Date_Time__c <= candt.End_Date_Time__c)&&(candt.Start_Date_Time__c !=Null&& vcc.Start_Date_Time__c!=Null  && vcc.End_Date_Time__c!=Null&&candt.End_Date_Time__c!=Null) && !candidateAvailablityIdSet.contains(candt.id)){
                                    Closing_Report_Schedule__c CRS = new Closing_Report_Schedule__c();
                                    CRS.Schedule_Date__c = startDate.addDays(dt);
                                    CRS.Closing_Report__c  =closingReport.Id;
                                    CRS.Candidate_Availability__c = candt.Id;
                                    CRS.Vacancy_Schedule__c = vcc.ID;
                                    CRS.Status__c  = 'Booked';
                                    crsList.add(CRS);
                                    candidateAvailablityIdSet.add(candt.Id);
                                }
                            }
                        }
                        if(startDate.addDays(dt) == enddateforcr){break; 

                        }
                    }
                }
                
                
                
                Database.SaveResult[] srList;
                if(closingReport.Pay_Type__c=='Hour' && (closingReport.Maximum_Hour_Pay_Rate__c==null || closingReport.Maximum_Hour_Charge_Rate__c==null)){
                    Utility.AddErrorMessage('Please enter the Hour charge rate and pay rate. ');
                    return null ;
                }else if(closingReport.Pay_Type__c=='Day' && (closingReport.Maximum_Day_Pay_Rate__c==null || closingReport.Maximum_Day_Charge_Rate__c==null)){
                    Utility.AddErrorMessage('Please enter the Day charge rate and pay rate. ');
                    return null ;
                }
                else if(closingReport.Pay_Type__c=='Half-Day' && (closingReport.Maximum_Half_Day_Pay_Rate__c==null || closingReport.Maximum_Half_Day_Charge_Rate__c==null)){
                    Utility.AddErrorMessage('Please enter the Half-Day charge rate and pay rate. ');
                    return null ;
                }
                partialsave =  Boolean.valueOf(Utility.getPageParameter('partialsave'));
                if(partialsave){
                    if(crsList.size()>0){
                        srList = Database.insert(crsList, false);
                        refresh();
                        Utility.AddInfoMessage('Booking completed sucessfully .'); 
                    }
                    else {
                        Database.rollback(sp);
                        Utility.AddErrorMessage('Please check with date range as no availability slots found in range you provided  .'); 
                    }
                }else{
                    if(crsList.size()>0){
                        srList = Database.insert(crsList, True);
                        refresh();
                        Utility.AddInfoMessage('Booking completed sucessfully .'); 
                    }
                    else {
                        Database.rollback(sp);
                        Utility.AddErrorMessage('Please check with date range as no availability slots found in range you provided  .'); 
                    }
                }
            }
            List <TR1__Closing_Report__c> crlist=[Select Name from TR1__Closing_Report__c where Id= :closingReport.id limit 1 ];
            return new PageReference('/apex/TRS_FilterJobs?id='+closingReport.TR1__Person_Placed__c+'&&save='+crlist[0].Name).setRedirect(true);
        }
        catch (DMLException e) {
            Utility.AddErrorMessage('' +e.getDmlMessage(0));
            Database.rollback(sp);
            closingReport.id = null;
            return null;
        }
        catch(Exception e) {
            Utility.AddErrorMessage('Closing Report Save failed. Following Exception occurred: ' + e.getMessage() +' '+ e.getLineNumber());
            Database.rollback(sp);
            closingReport.id = null;
            return null;
        }
    }
    
    public void refresh() {
        getResourceAvailability();
        showAssignmentDialogBox = false;
        vacancyName = '';
        vacancyId = '';
        jobForDate.TR1__Estimated_Start_Date__c =  null;
        jobForDate.TR1__Estimated_End_Date__c = null;
    }
    /*  CREATE BOOKING DAILOG : END */
    
    /*  CREATE VACANCY RECORD DAILOG : START */
    public TR1__Job__c vacRecord { get; set; }
    public Boolean showCreateVacancyRecord { get; set; }
    public Boolean editCreateVacancyRecord { get; set; }
    public string SchoolType{get;set;}
    
    public void openCreateVacancyRecordDialog() { 
        showCreateVacancyRecord = true;
        
        vacRecord = new TR1__Job__c(
            RecordTypeId = TRS_VacancyHelper.CONSULTING_RTID,
            Booking_Type__c = 'Daily',
            Ownerid = UserInfo.getUserId()
        );
    }

    public Vacancy_D2D__c vD2D {get;set;}

    public void openEditVacancyRecordDialog() { 
        editCreateVacancyRecord = true;
        String Id = Apexpages.currentPage().getParameters().get('firstParam');
        System.debug('id vacancy D2d=====>>>>>>>>>>>>>>>>>'+ Apexpages.currentPage().getParameters().get('firstParam'));
        if(Id != null ){

            vD2D = [SELECT Id,Name,Candidate_Assigned__c,Closing_Report_Schedule__c,Closing_Report_Schedule_Secondary__c,End_Date_Time__c,Shift__c,Start_Date_Time__c,Status__c,Vacancy__c,Vacancy__r.Name,Vacancy__r.Start_Time__c,Vacancy__r.End_Time__c,Vacancy_Date__c FROM Vacancy_D2D__c WHERE Id =: Id LIMIT 1];
        }
        System.debug('vD2d===[]]][][===>'+vD2D);
    }
    
    public PageReference saveCreateVacancyRecord() {
        Savepoint sp = Database.setSavepoint();

        try {

            if(vacRecord.Selected_Week_Days__c){
                TRS_VacancyHelper.boolcheck = false;
                System.debug('ByPass Trigger on TRS_FilterJobs');

                List<String> applicableDaysSet_new = vacRecord.Applicable_Days__c.split(';');
                boolean daysTime = false;
                String MST = Apexpages.currentPage().getParameters().get('weekdaysTime');
                Map<String, Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(MST);
                for(String st : applicableDaysSet_new){
                    if(rawObj.get(st) != null){
                        String tg = JSON.serialize(rawObj.get(st));
                        String fg = tg.replaceAll('\\\\', '');
                        fg = fg.substring(1, fg.length() - 1);
                        Map<String, Object> TimeToken = (Map<String,Object>)JSON.deserializeUntyped(fg);
                        if(TimeToken.get('ST') == null && TimeToken.get('ET') == null && TimeToken.get('ST') == '--None--' && TimeToken.get('ET') == '--None--'){
                            daysTime = true;
                            break;
                        }
                        else{
                            Map<String, String> temp_map = new Map<String, String>();
                            temp_map.put('ST', JSON.serialize(TimeToken.get('ST')));
                            temp_map.put('ET', JSON.serialize(TimeToken.get('ET')));
                            weekData.put(st, temp_map);
                        }
                    }
                    else{
                        daysTime = true;
                        break;
                    }
                }

                if(daysTime){
                    Utility.AddErrorMessage('Please populate all the Applicable days Time field. ');
                    return null ;
                }

                if(String.isBlank(vacRecord.TR1__Account__c) || String.isBlank(vacRecord.Shift__c) || String.isBlank(vacRecord.School_Type__c) || String.isBlank(vacRecord.TR1__Contact__c) || 
                   vacRecord.TR1__Estimated_Start_Date__c == null || String.isBlank(vacRecord.Booking_Type__c) || vacRecord.TR1__Estimated_End_Date__c == null || String.isBlank(vacRecord.Name) || String.isBlank(vacRecord.Job_Title__c) || String.isBlank(vacRecord.Applicable_Days__c)){
                       Utility.AddErrorMessage('Please populate all the required field. ');
                       return null ;
                   }
                
                if(String.isBlank(vacRecord.Subject2__c) && String.isBlank(vacRecord.Year_Key_Stage__c)){Utility.AddErrorMessage('You need to populate either \'Subject\' or \'Year/ Key Stage\'');
                    return null ;
                }
                if(!isMidNight && vacRecord.TR1__Estimated_Start_Date__c!=null && (formatDateTimefromDate(vacRecord.TR1__Estimated_Start_Date__c,vacRecord.Start_Time__c) > formatDateTimefromDate(vacRecord.TR1__Estimated_Start_Date__c,vacRecord.End_Time__c))){Utility.AddErrorMessage('Start Time should be less than End Time. If you are booking an overnight shift, please check the \'Overnight Shift?\' checkbox.');
                    return null;
                }

                vacRecord.End_Time__c = '3:00 PM';
                vacRecord.Start_Time__c = '1:00 PM';
                vacRecord.weekDaysTime__c = JSON.serialize(weekData);

                insert vacRecord;

                showCreatevacancyRecord = false;

                //List to hold the Vacancy records of Consulting record type.
                List<TR1__Job__c> vacancyList = new List<TR1__Job__c>();
                List<TR1__Job__c> vacancyList_def = new List<TR1__Job__c>();
                vacancyList_def.add(vacRecord);
                
                set<id> vacancyIdset = new set<id>();
                Map<Id, List<TR1__Job__c>> AccJobMap = new Map<Id ,List<TR1__Job__c>>();
                
                //Looping through the new Vacancy records and adding to the vacancyList as per the record type.    
                for(TR1__Job__c vacancy : vacancyList_def){
                    if(vacancy.RecordTypeId == Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId()){
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

                                    System.debug('dayOfWeek'+dayOfWeek);

                                    // System.debug(weekData.get(dayOfWeek)['ST']);

                                    //Checking if the day is there in applicable days selected by the user and creating the d2dVacancy record.  
                                    if(applicableDaysSet.contains(dayOfWeek)){

                                        Map<String, String> Wtime = weekData.get(dayOfWeek);
                                        String Stime = Wtime.get('ST').replaceAll('"', '');
                                        String Etime = Wtime.get('ET').replaceAll('"', '');
                                        System.debug(Stime);
                                        System.debug(Etime);

                                        if(String.isNotBlank(Stime) && String.isNotBlank(Etime)){
                                            if(formatDateTimefromDate(startDateNew, Stime) > formatDateTimefromDate(startDateNew, Etime)){
                                                d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                        Vacancy__c=vacancy.Id,
                                                        Status__c='Open',
                                                        Start_Date_Time__c = formatDateTimefromDate(startDateNew,Stime),
                                                        End_Date_Time__c = formatDateTimefromDate(startDateNew+1,Etime),
                                                        Vacancy_Date__c = startDateNew,
                                                        Shift__c = vacancy.Shift__c
                                                    )
                                                );
                                            }else{
                                                d2dVacancyInsertList.add(new Vacancy_D2D__c(
                                                        Vacancy__c=vacancy.Id,
                                                        Status__c='Open',
                                                        Start_Date_Time__c = formatDateTimefromDate(startDateNew,Stime),
                                                        End_Date_Time__c = formatDateTimefromDate(startDateNew,Etime),
                                                        Vacancy_Date__c = startDateNew,
                                                        Shift__c = vacancy.Shift__c
                                                    )
                                                );
                                            }

                                        }
                                        
                                    }   
                                }
                            } 
                        }       
                    }

                    //Inserting d2dVacancy records  
                    if(!d2dVacancyInsertList.isEmpty()){
                        Database.SaveResult[] srList = Database.insert(d2dVacancyInsertList, true);
                        System.debug('d2dVacancyInsertList'+d2dVacancyInsertList);
                    }
                }

                Utility.AddConfirmMessage('Vacancy created successfully.'); 
                
                // Redirect User to Vacancy Scheduler page.
                PageReference vacSchedulerPage = Page.TRS_FilterCandidates; 
                vacSchedulerPage.getParameters().put('id', vacRecord.Id);
                vacSchedulerPage.setRedirect(true);
                return vacSchedulerPage;
                
            }else{
                System.debug(vacRecord.TR1__Account__c);
                System.debug(vacRecord.Shift__c);
                System.debug(vacRecord.School_Type__c);
                System.debug(vacRecord.TR1__Estimated_Start_Date__c);
                System.debug(vacRecord.Booking_Type__c);
                System.debug(vacRecord.TR1__Estimated_End_Date__c);
                System.debug(vacRecord.Name);
                System.debug(vacRecord.Start_Time__c);
                System.debug(vacRecord.Job_Title__c);
                System.debug(vacRecord.End_Time__c);
                System.debug(vacRecord.Applicable_Days__c);
                
                if(String.isBlank(vacRecord.TR1__Account__c) || String.isBlank(vacRecord.Shift__c) || String.isBlank(vacRecord.School_Type__c) || String.isBlank(vacRecord.TR1__Contact__c) || 
                   vacRecord.TR1__Estimated_Start_Date__c == null || String.isBlank(vacRecord.Booking_Type__c) || vacRecord.TR1__Estimated_End_Date__c == null || String.isBlank(vacRecord.Name) || String.isBlank(vacRecord.Start_Time__c) || String.isBlank(vacRecord.Job_Title__c) || String.isBlank(vacRecord.End_Time__c) || String.isBlank(vacRecord.Applicable_Days__c)){
                       Utility.AddErrorMessage('Please populate all the required field. ');
                       return null ;
                   }
                
                if(String.isBlank(vacRecord.Subject2__c) && String.isBlank(vacRecord.Year_Key_Stage__c)){Utility.AddErrorMessage('You need to populate either \'Subject\' or \'Year/ Key Stage\'');
                    return null ;
                }
                if(!isMidNight && vacRecord.TR1__Estimated_Start_Date__c!=null && (formatDateTimefromDate(vacRecord.TR1__Estimated_Start_Date__c,vacRecord.Start_Time__c) > formatDateTimefromDate(vacRecord.TR1__Estimated_Start_Date__c,vacRecord.End_Time__c))){Utility.AddErrorMessage('Start Time should be less than End Time. If you are booking an overnight shift, please check the \'Overnight Shift?\' checkbox.');
                    return null;
                }
                
                insert vacRecord;
                
                Utility.AddConfirmMessage('Vacancy created successfully.'); 
                showCreatevacancyRecord = false;
                
                // Redirect User to Vacancy Scheduler page.
                PageReference vacSchedulerPage = Page.TRS_FilterCandidates; 
                vacSchedulerPage.getParameters().put('id', vacRecord.Id);
                vacSchedulerPage.setRedirect(true);
                return vacSchedulerPage;
                
            }

            
        }
        catch(Exception e) {
            Utility.AddErrorMessage('Exception occured '+e.getmessage()+'Line number '+e.getLineNumber());
            Database.rollback(sp);  
        }
        return null;
    }
    public PageReference saveEditVacancyRecord() {
        if(Test.isRunningTest()){
            editCreatevacancyRecord = false;
        }
        Savepoint sp = Database.setSavepoint();
        try {

            System.debug('111>>>'+vD2D.Vacancy__r.Start_Time__c);
            System.debug('111>>>'+vD2D.Vacancy__r.End_Time__c);
            System.debug('112>>>'+vD2D.Id);
            System.debug('113>>>'+vD2D.Vacancy_Date__c);
            System.debug('114>>>'+vD2D.Closing_Report_Schedule__c);
            System.debug('115>>>'+vD2D.Closing_Report_Schedule_Secondary__c);
            System.debug('116>>>'+vD2D.End_Date_Time__c);
            System.debug('117>>>'+vD2D.Shift__c);
            System.debug('118>>>'+vD2D.Candidate_Assigned__c);

            System.debug('editCreatevacancyRecord>>'+editCreatevacancyRecord);

            if(editCreatevacancyRecord){
                if(!String.isBlank(vD2D.Id) ){
                    Vacancy_D2D__c vD2D_edit = [SELECT Id,Name,Candidate_Assigned__c,Closing_Report_Schedule__c,Closing_Report_Schedule_Secondary__c,End_Date_Time__c,Shift__c,Start_Date_Time__c,Status__c,Vacancy__c,Vacancy__r.Name,Vacancy__r.Start_Time__c,Vacancy__r.End_Time__c,Vacancy_Date__c FROM Vacancy_D2D__c WHERE Id =: vD2D.Id LIMIT 1];
    
                    vD2D_edit.Start_Date_Time__c = formatDateTimefromDate(vD2D.Vacancy_Date__c,vD2D.Vacancy__r.Start_Time__c);
                    vD2D_edit.End_Date_Time__c = formatDateTimefromDate(vD2D.Vacancy_Date__c,vD2D.Vacancy__r.End_Time__c);
                    System.debug(vD2D_edit);
                    update vD2D_edit;

                    Utility.AddConfirmMessage('Vacancy edited successfully.'); 
                    editCreatevacancyRecord = false;
                }
            }else{
                Utility.AddConfirmMessage('Start time and End time are overlaping.'); 
            }
            
            // Redirect User to Vacancy Scheduler page.
            PageReference vacSchedulerPage = Page.TRS_FilterJobs; 
            vacSchedulerPage.setRedirect(true);
            return vacSchedulerPage;
        }
        catch(Exception e) {
            Utility.AddErrorMessage('Exception occured '+e.getmessage()+'Line number '+e.getLineNumber());
            Database.rollback(sp);  
        }
        return null;
    }
    
    public void doSchoolNamePopulate(){
        if(vacRecord.TR1__Account__c != null){
            for(Account acc : [Select Id,School_Type__c,Payroll_Primary_Contact__c,Standard_Hourly_Rate__c,Agreed_D2D_Charge_Rate__c,Standard_Half_Day_Rate__c,Payroll_Primary_Hiring_Manager__c From Account Where Id =: vacRecord.TR1__Account__c limit 1]){
                vacRecord.School_Type__c = acc.School_Type__c;
                vacRecord.TR1__Contact__c = acc.Payroll_Primary_Contact__c;
                vacRecord.TR1__Hiring_Manager__c = acc.Payroll_Primary_Hiring_Manager__c;
                vacRecord.Timesheet_Approver__c = acc.Payroll_Primary_Hiring_Manager__c;
                vacRecord.Maximum_Hour_Charge_Rate__c = acc.Standard_Hourly_Rate__c;
                vacRecord.TR1__Maximum_Bill_Rate__c = acc.Agreed_D2D_Charge_Rate__c;
                vacRecord.TR1__Minimum_Bill_Rate__c = acc.Standard_Half_Day_Rate__c;
            }
        }
    }
    
    public void cancelVacancyCreation() {
        showCreatevacancyRecord = false;
        vacRecord = null;
        
    }
    public PageReference deleteEditVacancyCreation() {
        // System.debug('112>>>'+vD2D.Id);
        if(vD2D != null){
            String Id = vD2D.Id;
            Vacancy_D2D__c vD2D_edit = [SELECT Id FROM Vacancy_D2D__c WHERE Id =: Id LIMIT 1];
            delete vD2D_edit;
        }
        
        Utility.AddConfirmMessage('Vacancy edited successfully.'); 
        
        editCreatevacancyRecord = false;
        vD2D = null;
        PageReference vacSchedulerPage = Page.TRS_FilterJobs; 
        vacSchedulerPage.setRedirect(true);
        return vacSchedulerPage;
    }

    public void cancelEditVacancyCreation() {
        editCreatevacancyRecord = false;
        vD2D = null;
    }
    
    public PageReference dummyFunction(){
        if(vacRecord.Shift__c=='Hourly' || vacRecord.Shift__c=='Daily'){
            vacRecord.Start_Time__c = '8:30 AM';
            vacRecord.End_Time__c = '3:30 PM';
        }else if(vacRecord.Shift__c=='AM'){
            vacRecord.Start_Time__c = '8:30 AM';
            vacRecord.End_Time__c = '12:00 PM';
        }
        else if(vacRecord.Shift__c=='PM'){
            vacRecord.Start_Time__c = '1:00 PM';
            vacRecord.End_Time__c = '3:30 PM';
        }else{
           	 Utility.AddErrorMessage('Error');
        }
        return null;
    }
    public PageReference weekdayFunction(){
        System.debug('weekdayFunction');

        System.debug(vacRecord.Applicable_Days__c);

        if(vacRecord.Applicable_Days__c != null){
            List<String> tl = vacRecord.Applicable_Days__c.split(';');

            strings = new List<String>();
            strings = tl;
            System.debug(tl);
        }
        else{
            strings = new List<String>();
        }
        return null;
    }
    /*  CREATE VACANCY RECORD DAILOG : END */
    
    /* UTILIY FUNCTIONS : START */
    
    //This will convert A;B;C to 'A','B','C'
    public String createStringForMultiSelectFields(String selectedOptions){
        Set <String> selectedLeaSet = new Set<String>();
        selectedLeaSet.addAll(selectedOptions.split(';'));
        String selectedOptionsString = '';
        Boolean firstElementFlag = true;
        for(String s : selectedLeaSet){
            if(firstElementFlag){
                selectedOptionsString += '\''+s+'\'';
                firstElementFlag = false;
            }
            else
                selectedOptionsString += ',\''+s+'\'';
        }
        return selectedOptionsString;
    }
    
    DateTime formatDateTimefromDate(Date dateVar,String startTime){
        
        String startDateTime = dateVar.format();
        
        String startTimeHour = startTime.split(':')[0];
        String startTimeMinute = startTime.split(':')[1].remove(' AM').remove(' PM');
        
        if (startTime.contains(' AM') && startTimeHour=='12') {startTimeHour = '00';
        }
        
        Datetime returnDt = Datetime.newInstance(
            dateVar.year(),
            dateVar.month(),
            dateVar.day(),
            Integer.valueOf(startTimeHour),
            Integer.valueOf(startTimeMinute),
            00
        );
        
        if (startTime.contains(' PM') && startTimeHour !='12') {returnDt = returnDt.addHours(12);
        }
        
        return returnDt;        
    }
    /* UTILIY FUNCTIONS : END */ 
    
    public void test(){
        Integer a,b,c;
        a = 0;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
        b = a;
        c = b;
        a = c;
    }
}