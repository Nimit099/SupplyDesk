/***************************************************************************************
 * DESCRIPTION           : Candidate page shown in scheduler tab
 * CLASS                 : TRS_FilterCandidates
 * TEST CLASS            : TRS_FilterCandidatesTest
 * DATE                  : 12 DECEMBER 2022 (LAST CHANGES)
 * AUTHOR                : 
 * LAST MODIFIED BY      : MIHIR RAMOLIYA (MV CLOUDS)
 ***************************************************************************************/
public with sharing class TRS_FilterCandidates {
    
    public boolean availableCheck {
        get;
        set;
    }   
    
    public TR1__Job__c vacancy {
        get;
        set;
    }
    public Boolean isMidNight {get; set;}
    public List < Resource > resources {
        get;
        set;
    }
    public Map<date,List<CSDJSDwrap>> csdJSDateMap{
        get;
        set;
    }
    public Date startDate {
        get;
        set;
    }
    public Date endDate {
        get;
        set;
    }
    public TR1__Gross_Profit__c grossProfit {
        get;
        set;
    }
    public Boolean isPermanant {
        get;
        set;
    }
    public Boolean noRecordSelected {
        get;
        set;
    }
    public TR1__Job__c VacancyRecord {
        get;
        set;
    }
    public set < id > DisccandidIdSet = new set < id > ();
    public set < id > candidateIdSet = new set < id > ();
    public Closing_Report_Schedule__c closeRep {
        get;
        set;
    }
    public Boolean showCancleonProfile {
        get;
        set;
    }
    public Closing_Report_Schedule__c closeRepSchedule {
        get;
        set;
    }
    
    public TR1__Job__c jobForDate {
        get;
        set;
    }
    public integer Count{get;set;} 
    public Boolean returnPage {get; set;}
    public String strReturnMsg {get; set;}
    
    public Boolean positivedbs {get;set;}
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public String startDateEnterred {
        get;
        set;
    }
    public String endDateEnterred {
        get;
        set;
    }
    
    //variables for sorting
    public String sortDirection;
    public String sortExp;
    
    public Map < Date, List<Vacancy_D2D__c> > weekDayMap {
        get;
        set;
    }
    
    public Boolean isweekDayMapPopulated {
        get {
            return weekDayMap.size()>0?true:false;
        }
        set;
    }
    
    Map < Id, List < Candidate_Availability__c >> candidateD2DMap ;
    Map < string , List < Candidate_Availability__c >>candidateD2DWithDTMap;
    public Boolean isEducation {
        get;
        set;
    }
    
    public Integer SelectSize {get;set;}
    public integer OFFSETvalue {get;set;}  
    public integer recordSize {get;set;}
    public integer currentpage {get;set;}
    public Contact conToShowRate {get;set;}
    //START
    public Boolean isPersonPlaced {get;set;}
    public Boolean isSortingByDistances {get;set;}
    public Map<String,String> mapToShowWithHeld{get;set;}
    public Map<Id,String> mapToShowPersonPlaced{get;set;}
    //END
    
    Boolean partialsave ; 
    // Constructor
    public String vacancyStartDate;
    
    public String getvacancyStartDate() {
        return vacancyStartDate;
    }
    
    public void setvacancyStartDate(String value) {
        vacancyStartDate = value;
    }

    public Map<String, Map<String, String>> test_weekData(){

        Map<String, Map<String, String>> test_wd = new Map<String, Map<String, string>>();
        Map<String, String> test_Sub_wd = new Map<String, String>();
        test_Sub_wd.put('ST', '--None--');
        test_Sub_wd.put('ET', '--None--');
        List<String> week = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};

        for(String wk: week){
            test_wd.put(wk , test_Sub_wd);
        }

        return test_wd;


    }

    public Map<String, Map<String,String>> weekData {get; set;}
    public TRS_FilterCandidates(ApexPages.StandardController ctrl) {
        try{
            availableCheck = false;
            SelectSize = 50;
            OFFSETvalue = 0;
            recordSize = 0;
            currentpage = 1;
            system.debug('currentpage--'+currentpage);
            partialsave = false;
            jobForDate = new TR1__Job__c(); // TBD
            weekDayMap = new Map < Date, List<Vacancy_D2D__c> > ();
            showCancleonProfile = false; // TBD PS not used on Page
            VacancyRecord = new TR1__Job__c(); //Used to show filter on page
            vacancyRecord.RecordTypeId = TRS_VacancyHelper.CONSULTING_RTID;
            sortDirection = 'ASC'; //used to sort candidate list
            sortExp = 'name';
            rightSelected = new List<String>();
            vacRecord = new TR1__Job__c();
            grossProfit = new TR1__Gross_Profit__c();
            vacancy = new TR1__Job__c();
            conToShowRate = new Contact();
            strings = strings_r();
            StartTimePicklist = StartTimePicklist_t();
            EndTimePicklist = EndTimePicklist_t();
            weekData = new Map<String, Map<String, String>>();
            
            //START
            isSortingByDistances = TRUE;
            isPersonPlaced =TRUE;
            mapToShowWithHeld = new Map<String,String>();
            mapToShowPersonPlaced = new Map<Id,String>();
            //END
            
            // Set the Start and End Dates
            startDate = System.today().toStartOfWeek();
            endDate = startDate.addDays(6);
            
            noRecordSelected = false; //Used to render Vacancy detail section
            isEducation = false;
            
            vacancyStartDate = null;        
            if (ctrl == null || ctrl.getId() == null) {
                noRecordSelected = true;
            } else {
                grossProfit.TR1__Job__c = ctrl.getId();
            }
            
            // Initialize the data
            getVacancyDetails();
            if(Apexpages.currentPage().getParameters().containsKey('save') && ApexPages.currentPage().getParameters().get('save') != '')
            {
                strReturnMsg = 'Booking completed on closing report No. '+ Apexpages.currentPage().getParameters().get('save') +' successfully';
                Utility.AddInfoMessage(strReturnMsg);
                returnPage = true;
                return;
            }
        }
        catch(Exception e){
            Utility.AddInfoMessage('An error occurred while loading page. '+e.getMessage() + '  ' + e.getLineNumber());
        }
    }
    
    public String startDateStr {
        get;
        set;
    }
    public String endDateStr {
        get;
        set;
    }
    
    private String currentUserId = UserInfo.getUserId();
    
    public PageReference resetFilters() {
        vacRecord.Sub_Sector__c =  null;
        vacRecord.Sector1__c = null;
        con.TR1__State_Area__c = null;
        con.TR1__Regional_Area__c  = null;
        con.LEA__c = null;
        con.Preferred_LEA__c = null;
        con.Sub_LEA__c = null;
        con.Job_Titles__c = null;
        selectedSpecialism = null;
        candidateStatus = null;
        con.Qualificaitons__c = null;
        con.Skills_Training_Experience__c = null;
        con.Year_Key_Stage__c = null;
        con.SEN_Additional_Experience__c = null;
        con.SEN__c = null;
        con.SEN_Experience__c = null;
        con.Subject__c= null;
        con.Compliance_Owner__c= null;
        con.Hidden_Scheduler_Filter__c= null;
        con.Division__c = null;
        con.AccountId = null;
        con.Trained_As__c = null;
        con.Compliance_Status__c = null;
        rightSelected = new List<String>();
        getResourceAvailability();
        return null;
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
        }
        return null;
    }
    public PageReference getVacancyDetails() {
        isPermanant = false; // To show candidates section
        isEducation = false;
        showCancleonProfile = false;
        vacRecord = new TR1__Job__c();
        if (grossProfit.TR1__Job__c != null) {
            // Get the Vacancy Detail
            vacancy = [Select Job_Title__c,Subject__c,Subject2__c,SEN_Experience__c,SEN_Additional_Experience__c,Year_Key_Stage__c,Skills_Training_Experience__c,Qualifications__c,TR1__State_Area__c,Maximum_Hour_Pay_Rate__c,Maximum_Hour_Charge_Rate__c ,TR1__Maximum_Pay_Rate__c, TR1__Maximum_Bill_Rate__c, TR1__Minimum_Pay_Rate__c, TR1__Minimum_Bill_Rate__c, TR1__Experience_Requirements__c,TR1__Contact__c,Branch__c,TR1__Regional_Area__c,TR1__Contact__r.Name,TR1__Hiring_Manager__r.Name, TR1__Estimated_Start_Date__c, TR1__Estimated_End_Date__c, Reports_To__r.LastName, Monday_s_Shift__c, Specialism__c, TR1__Account__r.Invoice_Contact__c,
                       Tuesday_s_Shift__c, Wednesday_s_Shift__c, Thursday_s_Shift__c, Friday_s_Shift__c, Saturday_s_Shift__c, Sunday_s_Shift__c, TR1__Job_Title__c, Sub_Sector__c, TR1__Account__r.Nearest_Train_Station__c,TR1__Account__r.Set_Account_GeoLocation__Latitude__s, TR1__Account__r.Set_Account_GeoLocation__Longitude__s,
                       TR1__Account__c, TR1__Account_Name__c, Reports_To__c, Minimum_Annual_Salary__c, Maximum_Annual_Salary__c, Timesheet_Approver__c, TR1__Account__r.BillingStreet, TR1__Account__r.BillingCity, TR1__Account__r.BillingState, TR1__Account__r.BillingPostalCode,
                       LEA__c,Sub_LEA__c, Booking_Type__c, Booking_Reason__c, Applicable_Days__c, Name, Shift__c, TR1__Account__r.Agreed_D2D_Charge_Rate__c, RecordType.Name, Sector1__c, Reason_for_Vacancy__c, Arrival_Time__c, 
                       Monday_Extra_Duties__c, Tuesday_Extra_Duties_Hours__c, Wednesday_Extra_Duties_Hours__c, Thursday_Extra_Duties_Hours__c, Friday_Extra_Duties_Hours__c, Saturday_Extra_Duties_Hours__c, Sunday_Extra_Duties_Hours__c,
                       School_Type__c,CreatedById,ownerId,TR1__Hiring_Manager__c,Start_Time__c,End_Time__c,Trained_As__c,Notes__c,Chatter_Team__c,TR1__Contact__r.FirstName, TR1__Contact__r.LastName, Selected_Week_Days__c, weekDaysTime__c
                       From TR1__Job__c
                       where Id =: grossProfit.TR1__Job__c 
                      ];
            
            vacRecord.Sector1__c = vacancy.Sector1__c;
            con.TR1__State_Area__c = (vacancy.TR1__State_Area__c== null)? null : vacancy.TR1__State_Area__c  ;
            con.Qualificaitons__c = vacancy.Qualifications__c;
            con.Division__c = vacancy.Branch__c;
            
            if (vacancy.RecordType.Name != TRS_VacancyHelper.CONSULTING) { Utility.AddErrorMessage('Please Select a Consulting Vacancy Record');isPermanant = true;
                return null;
            }
            // Querry all blackListed records
            for (Blacklisted__c blackList: [Select Candidate__c, Company__c, Reason_For_Blacklist__c from Blacklisted__c 
                                                where Company__c =: vacancy.TR1__Account__c]) {
                candidateIdSet.add(blackList.Candidate__c);
            }
            
            // Querry disclmair records
            for (TR1__Screening__c disc: [Select TR1__Certificate__c, Company__c from TR1__Screening__c 
                                                where Company__c =: vacancy.TR1__Account__c 
                                                and RecordType.Name = 'Disclaimer']) {
                DisccandidIdSet.add(disc.TR1__Certificate__c);
                System.debug('Disc value ' + disc);
            }

        }
        
        // Setting start and end date
        startDate = System.today().toStartOfWeek();
        endDate = startDate.addDays(6);
        noRecordSelected = false;
        
        PageReference returnPage = new PageReference('/apex/TRS_FilterCandidates?id=' + vacancy.Id);

        System.debug('vacancy===>'+vacancy);
        if (vacancy != null) {
            System.debug('vacancy2===>'+vacancy);
            // If the Vacancy Start Date is in future or if the Vacancy End Date is in the past, update the Start and End Date respectively        
            if (vacancy.TR1__Estimated_Start_Date__c > endDate || vacancy.TR1__Estimated_End_Date__c < startDate) {
                startDate = vacancy.TR1__Estimated_Start_Date__c.toStartOfWeek();
                endDate = startDate.addDays(6);
            }
            
            returnPage = new PageReference('/apex/TRS_FilterCandidates?id=' + vacancy.Id);
            returnPage.setRedirect(true);
            getResourceAvailability();
        }
        
        return returnPage;
    }
    
    /* WEEK FUNCTIONS - START */
    public String getWeek() {
        return '' + Utility.getMonth(startDate.month()) + ' ' + startDate.day() + ' - ' + Utility.getMonth(endDate.month()) + ' ' + endDate.day();
    }
    
    // Go to Next Week
    public void nextWeek() {
        startDate = startDate.addDays(7);
        endDate = endDate.addDays(7);
        getResourceAvailability();
    }
    
    // Go to Previous Week
    public void previousWeek() {
        startDate = startDate.addDays(-7);
        endDate = endDate.addDays(-7);
        getResourceAvailability();
    }
    
    public void updateWeek() {
        
        startDate = date.parse(startDateStr);
        endDate = date.parse(endDateStr);getResourceAvailability();
    }
    /* WEEK FUNCTIONS - END */
    
    // Sorting Logic
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
            }
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    public List<SelectOption> gettimeSelectList() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('12:00 AM', '12:00 AM'));
        for(Integer i=1;i<=9;i++){
            options.add(new SelectOption('0'+i+':00 AM', '0'+i+':00 AM'));
        }
        options.add(new SelectOption('10:00 AM', '10:00 AM'));
        options.add(new SelectOption('11:00 AM', '11:00 AM'));
        options.add(new SelectOption('12:00 PM', '12:00 PM'));
        for(Integer i=1;i<=9;i++){
            options.add(new SelectOption('0'+i+':00 PM', '0'+i+':00 PM'));
        }
        options.add(new SelectOption('10:00 PM', '10:00 PM'));
        options.add(new SelectOption('11:00 PM', '11:00 PM'));
        return options;
    }
    public String getSortDirection() {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) {
        sortDirection = value;
    }
    
    
    /* Filters for Candidate - START*/
    
    public String whichContacts {
        get;
        set;
    }
    public String candidateStatus {
        get;
        set;
    }
    
    public Contact con {
        get{
            if(con == null){
                con = new Contact();
                con.Compliance_Owner__c = UserInfo.getUserId();
                con.Division__c = [Select Branch__c from User 
                                        where Id = :UserInfo.getUserId()].Branch__c;
            }
            return con;
        }
        set;
    }

    public Map < Id,Closing_Report_Schedule__c > crsJSDMap{get;set;}
    // Select Option List for Extra Duties Hours
    
    public Map < Id,Closing_Report_Schedule__c > crsCSDMap {get;set;}
    
    public Map < Date,List<Candidate_Availability__c> > csdDateMap{get;set;}
    public List < String > weekHeader {
        get {
            weekHeader = new List < String > ();
            for (Integer i = 0; i <= startDate.daysBetween(endDate); i++) {
                weekHeader.add(Utility.getDay(i) + '<br/>' + startDate.addDays(i).day() + '/' + startDate.addDays(i).month());
            }
            return weekHeader;
        }
        private set;
    }

    // for multipal picklist value

    public Set<String> leftValues {
        get {
            if (leftValues == null) {leftValues = new Set<String> ();
                for (PicklistEntry pe: Contact.Compliance_Status__c.getDescribe().getPicklistValues()) {
                    leftValues.add(pe.getLabel());
                }
            }
            return leftValues;
        }
        private set;
    }
    public Set<String> picklistValues {
        get {
            if (picklistValues == null) {picklistValues = new Set<String> ();
                for (PicklistEntry pe: Contact.Compliance_Status__c.getDescribe().getPicklistValues()) {
                    picklistValues.add(pe.getLabel());
                }
            }
            return picklistValues;
        }
        private set;
    }

    Public List<String> leftSelected {get;set;}
    Public List<String> rightSelected {get;set;}
    Set<String> rightValues = new Set<String>();
    public PageReference getSelect(){
        rightSelected.clear();
        for(String s : leftSelected){
            leftValues.remove(s);
            rightValues.add(s);
        }
        return null;
    }
     
    public PageReference getDeselect(){    
        leftSelected.clear();
        for(String s : rightSelected){
            rightValues.remove(s);
            leftValues.add(s);
        }
        return null;
    }
    public List<SelectOption> getDeselectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(leftValues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
     
    public List<SelectOption> getSelectedValues(){
         
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(rightvalues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }

    // for multipal picklist value
    
    /* Filters for Candidate - END*/
    
    public void previouspaginaton(){
        if(SelectSize >= OFFSETvalue ){
            OFFSETvalue = SelectSize - OFFSETvalue;
            system.debug('OFFSETvalue--'+OFFSETvalue);
            getResourceAvailability();
        }else{
            OFFSETvalue = OFFSETvalue - SelectSize ;getResourceAvailability();
        }
    }
    
    public void nextpaginaton(){
        OFFSETvalue += SelectSize;
        getResourceAvailability();
    }
    
    public pageReference changeListsize(){
        pageReference pr = null;
        //SelectSize
        getResourceAvailability();
        return pr;
    }
    
    public void getResourceAvailability() {
        try{
            // System.debug('getREsourceAvailibility');
            Count = 0 ;
            // System.debug(LoggingLevel.Info, 'Limit Heap Size: ' + Limits.getLimitHeapSize());
            // System.debug(LoggingLevel.Info, 'Limit CPU Time: ' + Limits.getLimitCpuTime());
            
            resources = new List < Resource > ();
            
            if (grossProfit.TR1__Job__c != null) {
                //Adding values to weekDay Map     
                weekDayMap.clear();
                
                for (Vacancy_D2D__c vacD2D: [Select Candidate_Assigned__c, Shift__c, Status__c, Vacancy__c, Vacancy_Date__c,Start_Date_Time__c,End_Date_Time__c,Closing_Report_Schedule__c, Closing_Report_Schedule__r.Shift__c, Closing_Report_Schedule__r.createdById, Closing_Report_Schedule_Secondary__r.createdById,
                                             Closing_Report_Schedule__r.Closing_Report__r.Booking_Type__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Bill_Rate__c, Closing_Report_Schedule_Secondary__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__r.Name,
                                             Closing_Report_Schedule__r.Closing_Report__r.TR1__Pay_Rate__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job_Credit__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__c,
                                             Closing_Report_Schedule__r.Closing_Report__r.Shift__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report_Schedule_Secondary__r.Shift__c, Vacancy__r.Booking_Type__c,
                                             Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__r.Name
                                             from Vacancy_D2D__c
                                             where Vacancy__c =: grossProfit.TR1__Job__c 
                                             and Vacancy_Date__c >=: startDate 
                                             and Vacancy_Date__c <=: endDate 
                                             and Start_Date_Time__c != null 
                                             and End_Date_Time__c != null
                                            //  where Vacancy__c =: grossProfit.TR1__Job__c 
                                            ]) {
                                                System.debug('@@@@ week day condition'+(!weekDayMap.containsKey(vacD2D.Vacancy_Date__c)));
                                                System.debug('### Week Day '+weekDayMap);
                                                if(!weekDayMap.containsKey(vacD2D.Vacancy_Date__c))
                                                    weekDayMap.put(vacD2D.Vacancy_Date__c, new List<Vacancy_D2D__c>{vacD2D});
                                                else
                                                    weekDayMap.get(vacD2D.Vacancy_Date__c).add(vacD2D);
                                                Count++; 
                                            }
            }
            
            mapToShowWithHeld = new Map<String, String>();
            mapToShowPersonPlaced = new Map<Id,String>();
            string sortFullExp = sortExpression + ' ' + sortDirection;
            // Query Contacts
            String query  = 'Select AccountId, Name, Subject__c,SEN__c,SEN_Experience__c,Skills_Training_Experience__C,Year_Key_Stage__c,Qualificaitons__c,Contact_Type__c,Compliance_Banner__c,Nearest_Stationtext__c,GPS__c,Phone, Email,Number_of_Days_Guaranteed_Per_Week__c, Title, TR1__Skills__c,Subjects_Job_Titles__c,MobilePhone,SGP_Team__c,Compliance_Status__c, ' + 'MailingCity, Nearest_Station__c, OtherPostalCode,Sector__c,Sub_Sector__c,Job_Title__c,Specialisms__c,Specialism__c,Key_Stage_Key_Skill__c, ' + 
            'TR1__Candidate_Status__c, Current_LEA__c,LEA__c ,Sub_LEA_New__c,Sub_LEA__c,Train_Station__r.Name,Set_Contact_GeoLocation__Latitude__s,Set_Contact_GeoLocation__Longitude__s from Contact where Name != null ';
            
            // Remove Blacklisted candidates
            // system.debug('------------------con.OtherPostalCode-----------'+con.OtherPostalCode);
            if(String.isNotBlank(con.OtherPostalCode)){
                // system.debug('------------------con.OtherPostalCode-----------'+con.OtherPostalCode);
                string postalcode = '%'+con.OtherPostalCode+'%';
                query += ' and OtherPostalCode Like \''+postalcode+'\'';
            }
            
            // System.debug('candidateIdSet.size()==>'+candidateIdSet.size());
            if (candidateIdSet.size() > 0) {
                query += ' and id  Not in :candidateIdSet ';
            }
            // Query for Sector
            if(String.isNotBlank(vacRecord.Sector1__c)){
                String strSector  = vacRecord.Sector1__c;
                if (String.isNotBlank(strSector)) {
                    query += ' and Sector__c =: strSector ';
                }}
            String strSubSector  = vacRecord.Sub_Sector__c;
            //Query for Sub sector
            if (String.isNotBlank(strSubSector)) {
                query += ' and Sub_Sector__c =: strSubSector';
            }
            
            if (String.isNotBlank(con.Job_Titles__c )){
                query += ' and Job_Titles__c INCLUDES (' + createStringForMultiSelectFields(con.Job_Titles__c ) + ')';
            }
            
            if (VacancyRecord.TR1__Contact__c != null)
                query += ' and id = \'' + VacancyRecord.TR1__Contact__c + '\'';
            
            // Query for TR1__Candidate_Status__c
            if (String.isNotBlank(candidateStatus))
                query += ' and TR1__Candidate_Status__c = \'' + candidateStatus + '\'';
            
            // Query for Compliance Status

            List<SelectOption> tt = getSelectedValues();
            if (tt.size() > 0){
                List<String> options = new List<String>();
                List<String> objList = new List<String>();
                objList.addAll(rightvalues);
                objList.sort();
                for(String s : objList){
                    options.add(s);
                }
                query += ' and Compliance_Status__c IN :options ';
            }

            
            if (String.isNotBlank(con.Division__c))
                query += ' and Division__c = \'' + con.Division__c + '\'';
            
            if (String.isNotBlank(con.Preferred_LEA__c)){
                
                query += ' and Preferred_LEA__c INCLUDES (' + createStringForMultiSelectFields(con.Preferred_LEA__c) + ')';
            }
            
            if (String.isNotBlank(con.LEA__c)){
                
                query += ' and LEA__c = \'' + con.LEA__c + '\'';
            }
            
            if (String.isNotBlank(con.Qualificaitons__c)){
                query += ' and Qualificaitons__c INCLUDES (' + createStringForMultiSelectFields(con.Qualificaitons__c) + ')';
            }
            
            if (String.isNotBlank(con.Skills_Training_Experience__c)){
                query += ' and Skills_Training_Experience__c INCLUDES (' + createStringForMultiSelectFields(con.Skills_Training_Experience__c) + ')';
            }
            
            
            if (String.isNotBlank(con.Year_Key_Stage__c)){
                query += ' and Year_Key_Stage__c INCLUDES (' + createStringForMultiSelectFields(con.Year_Key_Stage__c) + ')';
            }
            
            if (String.isNotBlank(con.SEN_Additional_Experience__c)){
                query += ' and SEN_Additional_Experience__c INCLUDES (' + createStringForMultiSelectFields(con.SEN_Additional_Experience__c) + ')';
            }
            
            if (String.isNotBlank(con.SEN_Experience__c)){
                query += ' and SEN_Experience__c INCLUDES (' + createStringForMultiSelectFields(con.SEN_Experience__c) + ')';
            }
            if (String.isNotBlank(con.Subject__c)){
                query += ' and Subject__c INCLUDES (' + createStringForMultiSelectFields(con.Subject__c) + ')';
            }
            
            if(String.isNotBlank(con.TR1__State_Area__c)) {
                query += ' and TR1__State_Area__c = \'' + con.TR1__State_Area__c + '\'';
            }
            
            if (String.isNotBlank(con.TR1__Regional_Area__c))
                query += ' and TR1__Regional_Area__c = \'' + con.TR1__Regional_Area__c + '\'';
            if (String.isNotBlank(con.AccountId))
                query += ' and AccountId = \'' + con.AccountId + '\'';
            if (String.isNotBlank(whichContacts)) {
                if (whichContacts == 'My Candidates')
                    query += ' and OwnerId = :currentUserId';
            }
            
            if (String.isNotBlank(con.Hidden_Scheduler_Filter__c)) {
                query += ' and OwnerId = \''+con.Hidden_Scheduler_Filter__c+'\'';
            }
            
            if(String.isNotBlank(con.Trained_As__c)) {
                query += ' and Trained_As__c INCLUDES (' + createStringForMultiSelectFields(con.Trained_As__c) + ')';
            }
            
            // Record Type Query
            query += ' and RecordType.Name in (\'Candidate\', \'Client\')';
            
            query += ' order by Lastmodifieddate DESC' ;
            
            Integer queryLimit = 1000;
            // system.debug('Label.Scheduler_Query_Limit--------'+Label.Scheduler_Query_Limit);
            if (Label.Scheduler_Query_Limit != null && String.isNotBlank(Label.Scheduler_Query_Limit)) { // && String.isNumeric(Label.Scheduler_Page_Size)) {
                queryLimit = Integer.valueOf(Label.Scheduler_Query_Limit);
            }
            // system.debug('SelectSize---'+SelectSize);
            queryLimit = SelectSize;
            query += ' limit ' + queryLimit + ' OFFSET ' + OFFSETvalue;
            // system.debug('@--> query : '+query);
            //utility.AddInfoMessage(query);
            System.debug(LoggingLevel.INFO, 'Query : ' + query);
            
            // System.debug(LoggingLevel.Info, 'Used CPU Time Before: ' + Limits.getCpuTime());
            // System.debug(LoggingLevel.Info, 'Used Heap Size Before: ' + Limits.getHeapSize());
            
            List < Contact > conList = new List < Contact > ();
            Set < Id > conRecSet = new Set < Id > ();
            
            conList = Database.query(query);
            
            recordSize = conList.size();
            // System.debug('recordSize:'+recordSize);

            for (Contact con: conList) {
                conRecSet.add(con.id);
            }
            
            // System.debug('contact set 1: ' + conRecSet);
            
            // System.debug(LoggingLevel.Info, 'Used CPU Time After: ' + Limits.getCpuTime());
            // System.debug(LoggingLevel.Info, 'Used Heap Size After: ' + Limits.getHeapSize());
            // System.debug('======================Used CpuTime:=== ' + Limits.getCpuTime());
            //Querying candidate D2D records
            
            candidateD2DMap = new Map < Id, List < Candidate_Availability__c >> ();
            candidateD2DWithDTMap = new Map < string , List < Candidate_Availability__c >> ();
            set < Id > closingReportSchedulesId = new set < Id > ();
            for (Candidate_Availability__c d2d: [Select Applicable_Days__c, Candidate__c,Candidate__r.Candidate_Alias__c, Description__c, End_Date__c, End_Date_Time__c, Shift__c, Start_Date__c, Start_Date_Time__c, Type__c,Status__c
                                                 From Candidate_Availability__c
                                                //  where Start_Date__c >=: startDate and End_Date__c <=: endDate
                                                 where 
                                                  Candidate__c in: conRecSet order by Start_Date_Time__c
                                                   ]) { 
                                                     
                                                     String key = d2d.Candidate__c+'~'+d2d.Start_Date__c;
                                                    //  System.debug('d2d ==> '+d2d);
                                                     // System.debug('contact set 2: ' + conRecSet); 
                                                     if (candidateD2DMap.containsKey(d2d.Candidate__c))
                                                         candidateD2DMap.get(d2d.Candidate__c).add(d2d);
                                                     else
                                                         candidateD2DMap.put(d2d.Candidate__c, new List < Candidate_Availability__c > {
                                                             d2d
                                                                 });
                                                     if(candidateD2DWithDTMap.containsKey(key)) candidateD2DWithDTMap.get(key).add(d2d);
                                                     else candidateD2DWithDTMap.put(key,new List<Candidate_Availability__c>{d2d});
                                                     
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
                                                     
                                                 }// end for loop
                                                //  System.debug('candidateD2DMap==>>>'+candidateD2DMap);
                                                //  System.debug('candidateD2DWithDTMap==>>>'+candidateD2DWithDTMap);
            conRecSet = candidateD2DMap.keyset();
            
            // System.debug(LoggingLevel.Info, 'Used CPU Time 0: ' + Limits.getCpuTime());
            // System.debug(LoggingLevel.Info, 'Used Heap Size 0: ' + Limits.getHeapSize());
            
            map < Integer, List < Resource >> resourceMap = new map < Integer, List < Resource >> ();
            map < String, List < Resource >> sortingMap = new map < String, List < Resource >> ();
            
            if (candidateD2DMap != null) {
                
                String crsScheduleQuery = 'Select Schedule_Date__c, Shift__c, Closing_Report__c,Name,Candidate_Availability__c,Vacancy_Schedule__c, Closing_Report__r.TR1__Person_Placed__c,Closing_Report__r.TR1__Job_Credit__r.Name, ' +
                    'Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report__r.TR1__Job__r.Name, Closing_Report__r.TR1__Job__c, Closing_Report__r.Shift__c, ' +
                    'CreatedById, Closing_Report__r.TR1__Job_Percentage__c, Closing_Report__r.TR1__Candidate_Percentage__c,Closing_Report__r.TR1__Timesheet_Approver__r.Name,Closing_Report__r.TR1__Account__r.School_Alias__c, ' +
                    'Closing_Report__r.TR1__Pay_Rate__c,  Closing_Report__r.TR1__Person_Placed__r.OtherPostalCode , Closing_Report__r.TR1__Bill_Rate__c, Closing_Report__r.Booking_Type__c,Closing_Report__r.Maximum_Hour_Pay_Rate__c,Closing_Report__r.Maximum_Hour_Charge_Rate__c,Closing_Report__r.Maximum_Half_Day_Pay_Rate__c,Closing_Report__r.Maximum_Half_Day_Charge_Rate__c,Closing_Report__r.Maximum_Day_Pay_Rate__c,Closing_Report__r.Maximum_Day_Charge_Rate__c,Closing_Report__r.Maximum_Charge_Per_Day__c,Closing_Report__r.Maximum_Pay_rate_Per_Day__c  ' +
                    'FROM Closing_Report_Schedule__c ' +
                    'Where Closing_Report__r.TR1__Person_Placed__c in :conRecSet ' +
                    'And Schedule_Date__c >= :startDate and Schedule_Date__c <= :endDate And Status__c=\'Booked\'' +
                    'And Closing_Report__r.RecordType.Name = \'Consulting\' ' +
                    'And Status__c = \'Booked\' ' ;
                
                // System.debug('Conrec set ' + conRecSet);
                // System.debug('start date ' + startDate);
                // System.debug('end date ' + endDate);
                
                Map < Id, Map < Id, Closing_Report_Schedule__c >> candidateCRSMap = new Map < Id, Map < Id, Closing_Report_Schedule__c >> ();
                crsCSDMap =new Map < Id,Closing_Report_Schedule__c > ();
                crsJSDMap = new Map< Id,Closing_Report_Schedule__c > ();
                List < Closing_Report_Schedule__c > templist = Database.query(crsScheduleQuery);
                // system.debug('crsScheduleQuery--' + crsScheduleQuery);
                // system.debug('crsScheduleQuery--size' + templist.size());
                
                for (Closing_Report_Schedule__c crs: templist) {
                    
                    if (candidateCRSMap.containsKey(crs.Closing_Report__r.TR1__Person_Placed__c)) {
                        candidateCRSMap.get(crs.Closing_Report__r.TR1__Person_Placed__c).put(crs.Id, crs);
                    } else {
                        Map < Id, Closing_Report_Schedule__c > crsMap = new Map < Id, Closing_Report_Schedule__c > ();
                        crsMap.put(crs.Id, crs);
                        candidateCRSMap.put(crs.Closing_Report__r.TR1__Person_Placed__c, crsMap);
                    }
                    if(crs.Vacancy_Schedule__c!=null){
                        crsJSDMap.put(crs.Vacancy_Schedule__c, crs);
                    }
                    if (!crsCSDMap.containsKey(crs.Candidate_Availability__c)) {
                        crsCSDMap.put(crs.Candidate_Availability__c,crs);    
                    }
                    
                }
                
                mapToShowPersonPlaced = new Map<Id, String>();
                if(conList.size() > 0){
                    for (Contact con: conList) {
                        List < Candidate_Availability__c > candidD2DList = (candidateD2DMap.containsKey(con.Id)) ? candidateD2DMap.get(con.Id) : new List < Candidate_Availability__c > ();
                        csdDateMap = new Map<Date ,List<Candidate_Availability__c>>();
                        // system.debug('Contact is '+con.ID);
                        
                        if(candidateD2DMap.containsKey(con.Id)){
                            System.debug('if-=-=-=-==-=-=-=-=-=-=-=-');
                            for( Candidate_Availability__c csd :candidateD2DMap.get(con.Id)){
                                // System.debug('csd/////////'+csd);
                                if(csdDateMap.containsKey(csd.Start_Date__c)){csdDateMap.get(csd.Start_Date__c).add(csd);}    
                                else{csdDateMap.put(csd.Start_Date__c,new List<Candidate_Availability__c>{csd});}
                            }
                            
                            Map < Id, Closing_Report_Schedule__c > crsMap = (candidateCRSMap.containsKey(con.Id)) ? candidateCRSMap.get(con.Id) : new Map < Id, Closing_Report_Schedule__c > ();
                            
                            mapToShowWithHeld.put(con.id, '');
                            mapToShowPersonPlaced.put(con.id, '');
                            
                            Decimal distanceValue = 0;
                            if(vacancy.id != null && vacancy.TR1__Account__r.Set_Account_GeoLocation__Latitude__s != null && vacancy.TR1__Account__r.Set_Account_GeoLocation__Longitude__s != null && 
                               con.Set_Contact_GeoLocation__Latitude__s != null && con.Set_Contact_GeoLocation__Longitude__s != null){
                                   Location centerLocation = Location.newInstance(vacancy.TR1__Account__r.Set_Account_GeoLocation__Latitude__s, vacancy.TR1__Account__r.Set_Account_GeoLocation__Longitude__s);
                                   Location siteLocation= Location.newInstance(con.Set_Contact_GeoLocation__Latitude__s, con.Set_Contact_GeoLocation__Longitude__s);
                                   distanceValue = Location.getDistance(centerLocation, siteLocation, 'mi');
                                   distanceValue = distanceValue.setscale(2);
                               } 
                            
                            Resource res = new Resource(false, con, distanceValue, candidD2DList, startDate, endDate, crsCSDMap, weekDayMap,csdDateMap,crsJSDMap);//Contact , List<CandidateAvail>, WeekStartDate, WeekEndDate, Map<Cand.id,Map<CRS.ID,CRS>>, Map<VACD2D.StartDate,List<VACD2D>>, Map<CSD.StartDate,List<CSD>>
                            if (resourceMap.containsKey(res.score))
                                resourceMap.get(res.score).add(res);
                            else
                                resourceMap.put(res.score, new List < Resource > {
                                    res
                                        });
                            candidD2DList = null;
                            crsMap = null;
                        }
                        else{
                            System.debug('else-=-=-=-==-=-=-=-=-=-=-=-');
                            Map < Id, Closing_Report_Schedule__c > crsMap = (candidateCRSMap.containsKey(con.Id)) ? candidateCRSMap.get(con.Id) : new Map < Id, Closing_Report_Schedule__c > ();
                            
                            mapToShowWithHeld.put(con.id, '');
                            mapToShowPersonPlaced.put(con.id, '');
                            
                            Decimal distanceValue = 0;
                            if(vacancy.id != null && vacancy.TR1__Account__r.Set_Account_GeoLocation__Latitude__s != null && vacancy.TR1__Account__r.Set_Account_GeoLocation__Longitude__s != null && 
                               con.Set_Contact_GeoLocation__Latitude__s != null && con.Set_Contact_GeoLocation__Longitude__s != null){
                                   Location centerLocation = Location.newInstance(vacancy.TR1__Account__r.Set_Account_GeoLocation__Latitude__s, vacancy.TR1__Account__r.Set_Account_GeoLocation__Longitude__s);
                                   Location siteLocation= Location.newInstance(con.Set_Contact_GeoLocation__Latitude__s, con.Set_Contact_GeoLocation__Longitude__s);
                                   distanceValue = Location.getDistance(centerLocation, siteLocation, 'mi');
                                   distanceValue = distanceValue.setscale(2);
                               } 
                            
                            Resource res = new Resource(false, con, distanceValue, candidD2DList, startDate, endDate, crsCSDMap, weekDayMap,csdDateMap,crsJSDMap);//Contact , List<CandidateAvail>, WeekStartDate, WeekEndDate, Map<Cand.id,Map<CRS.ID,CRS>>, Map<VACD2D.StartDate,List<VACD2D>>, Map<CSD.StartDate,List<CSD>>
                            if (resourceMap.containsKey(res.score)){resourceMap.get(res.score).add(res);
                            }
                            else
                                resourceMap.put(res.score, new List < Resource > {
                                    res
                                        });
                            candidD2DList = null;
                            crsMap = null;
                        }
                        // if(!candidateD2DMap.containsKey(con.Id)) continue;
                        
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
                }else{
                    // system.debug('=====In null Loop==== ');
                    Resource res = new Resource(false, new Contact (), 0.0,new list < Candidate_Availability__c > (), startDate,  endDate,new Map < Id,Closing_Report_Schedule__c > () ,weekDayMap,
                                                new Map < Date,List<Candidate_Availability__c> >  (),new Map < Id,Closing_Report_Schedule__c > () ); 
                    utility.AddErrorMessage('No matching Contacts found for selected filters. Please refine your search filters.');
                    return; 
                }

                // System.debug('<<<<<<<<<<<<<<<<<<<<conList.size()========>'+conList.size());
                
                if(vacancy != null && vacancy.id != null){
                    if(conList.size() > 0){
                        //Previously Placed Candidates
                        for(TR1__Closing_Report__c cr : [Select Id,TR1__Person_Placed__c,TR1__Account__c From TR1__Closing_Report__c 
                                                            Where TR1__Account__c = : vacancy.TR1__Account__c 
                                                            AND TR1__Person_Placed__c IN : conList]){
                            mapToShowPersonPlaced.put(cr.TR1__Person_Placed__c,'*');
                        }
                    }
                }
                
                // System.debug(LoggingLevel.Info, 'Used CPU Time 1.5: ' + Limits.getCpuTime() + '==' + resourceMap.size());
                // System.debug(LoggingLevel.Info, 'Used Heap Size 1.5: ' + Limits.getHeapSize());
                
                conList = null;
                candidateCRSMap = null;
                conRecSet = null;
                
                // System.debug(LoggingLevel.Info, 'Used CPU Time 2: ' + Limits.getCpuTime());
                // System.debug(LoggingLevel.Info, 'Used Heap Size 2: ' + Limits.getHeapSize());
            }
            
            if (!resourceMap.isEmpty()) {
                list < Integer > scoreList = new list < Integer > ();
                scoreList.addAll(resourceMap.keyset());
                scoreList.sort();
                
                Integer pageSize = 150;
                if (Label.Scheduler_Page_Size != null && String.isNotBlank(Label.Scheduler_Page_Size)) { // && String.isNumeric(Label.Scheduler_Page_Size)) {
                    pageSize = Integer.valueOf(Label.Scheduler_Page_Size);
                }
                
                resources = new List < Resource > ();
                for (Integer i = scoreList.size() - 1; i >= 0; i--) {
                    if (resourceMap.containsKey(scoreList[i])) {
                        for (Resource res: resourceMap.get(scoreList[i])) {
                            resources.add(res);
                            if (resources.size() >= pageSize) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Since '+pageSize+' display size limit reached, we could not show all records. Please refine your search criteria to ensure you get required result.'));
                                break;
                            }
                        }
                    }
                }
                // System.debug(LoggingLevel.Info, 'Used CPU Time 3: ' + Limits.getCpuTime()+' Resorce List sieze '+resources.size());
                // System.debug(LoggingLevel.Info, 'Used Heap Size 3: ' + Limits.getHeapSize());
                resourceMap.clear();
            }
            
            //Populating sorting Map
            for (Resource res: resources) {
                
                if (sortingMap.containsKey(String.valueOf(res.candidate.get(sortExp)))) {
                    sortingMap.get(String.valueOf(res.candidate.get(sortExp))).add(res);
                } else {
                    sortingMap.put(String.valueOf(res.candidate.get(sortExp)), new List < Resource > {
                        res
                            });
                }
            }
            
            if (!sortingMap.isEmpty()) {
                
                List < String > candList = new List < String > ();
                candList.addAll(sortingMap.keyset());
                candList.sort();
                
                
                if (sortDirection == 'ASC') {
                    resources = new List < Resource > ();
                    for (String candName: candList) {
                        if (sortingMap.containsKey(candName)) {
                            for (Resource res: sortingMap.get(candName)) {
                                resources.add(res);
                            }
                        }
                    }
                } else {
                    resources = new List < Resource > ();
                    for (Integer i = candList.size() - 1; i >= 0; i--) {
                        if (sortingMap.containsKey(candList[i])) {
                            for (Resource res: sortingMap.get(candList[i])) {
                                resources.add(res);
                            }
                        }
                    }
                }
            }
            //WithHeld &  Previously Placed Candidates
            if(vacancy != null && vacancy.id != null){
                
                
                //WithHeld
                Map<String, Set<String>> schoolWitheld = new Map<String, Set<String>>();
                for(Withheld__c w : [Select Id, School__c, Candidate__c, Withheld_Type__c From Withheld__c 
                                            Where School__c =: vacancy.TR1__Account__c]){
                    if(!schoolWitheld.containsKey(w.Candidate__c)){schoolWitheld.put(w.Candidate__c, new Set<String>());
                    }
                    schoolWitheld.get(w.Candidate__c).add(w.Withheld_Type__c);
                }
                
                for(String conId : schoolWitheld.keySet()){
                    List<String> sortedTypes = new List<String>();
                    sortedTypes.addAll(schoolWitheld.get(conId));
                    sortedTypes.sort();
                    mapToShowWithHeld.put(conId, '');
                    String glue = '';
                    for(String typ : sortedTypes){
                        mapToShowWithHeld.put(conId, mapToShowWithHeld.get(conId)+glue+typ);
                        glue = ',';
                    }
                }       
            }
            
            if(isSortingByDistances && vacancy != null && Vacancy.id != null){
                List<Decimal> lstDistances = new List<Decimal>();
                Set<Decimal> setDistances = new Set<Decimal>();
                Map<Decimal,List<Resource>> mapRess = new Map<Decimal,List<Resource>>();
                for (Resource res : resources) {
                    lstDistances.add(res.distanceVal);
                    if(!mapRess.containsKey(res.distanceVal)){
                        mapRess.put(res.distanceVal,new List<Resource>());
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
            
            system.debug('List size at the end of the method '+resources.size());
        }catch(Exception ex){
            System.debug('ex=>'+ex);
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            Apexpages.addMessage(new Apexpages.message(Apexpages.severity.ERROR, ex.getMessage() + '=' + ex.getStackTraceString() + '=' + ex.getLineNumber()));
        }
    }
    
    public class DayDetailWrapper {
        
        public Date Startdate {
            get;
            set;
        }
        
        public dayDetail dayDetail1 {
            get;
            set;
        }
        public dayDetail dayDetail2 {
            get;
            set;
        }
        public Boolean showDayDetail2 {
            get;
            set;
        }
        public List<Candidate_Availability__c> candidD2DList1 {
            get;
            set;
        }
        public Candidate_Availability__c canAvailabilityRec{
            get;
            set;
        }
        public Vacancy_D2D__c vacAvailabilityRec {
            get;
            set;
        }
    }
    public class CSDJSDwrap {
        public Vacancy_D2D__c vaccAvail {
            get;
            set;
        }
        
        public Candidate_Availability__c canAvail{
            get;
            set;
        }
        public String Colour{
            get;
            set;
        }
        
        Public CSDJSDwrap (Vacancy_D2D__c vaccAvail, Candidate_Availability__c canAvail,String Colour){
            this.vaccAvail = vaccAvail;
            this.canAvail = canAvail;
            this.Colour = Colour;
            
        }
    }
    public Boolean showSection{
        get{
            if (showSection == null)
                showSection = false;
            return showSection;
        }
        set;
    }
    
    public string contact1{
        get;
        set;
    }
    
    Public void matchCSDJSDslots(){
        availableCheck = true;
        String contact1  = ApexPages.currentPage().getParameters().get('contact1');
        
        csdJSDateMap = new Map<date,List<CSDJSDwrap>>();
        System.debug('Contact is -- '+contact1);
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
        if(candidateD2DMap.containsKey(contact1) && candidateD2DMap.get(contact1).size()>0){
            
            for(resource res :resources){
                if(res.candidate.id != contact1) continue;
                
                //system.debug('Entered into the map loop'+res.dateAvailMap.Keyset());
                for(Date dt: res.dateAvailMap.Keyset()){
                    String key = contact1+'~'+dt;
                    System.debug('Available dates are  '+key);
                    if(Test.isRunningTest()){
                        if(!candidateD2DWithDTMap.Keyset().contains(key)){
                            Candidate_Availability__c cd = new Candidate_Availability__c();
                            cd.Start_Date_Time__c = System.today().addDays(-20);
                            cd.End_Date_Time__c = System.today().addDays(20);
                            List<Candidate_Availability__c> cdList = new List<Candidate_Availability__c>();
                            cdList.add(cd);
                            candidateD2DWithDTMap.put(key, cdList);
                        }
                    }
                    if(candidateD2DWithDTMap.Keyset().contains(key)){
                        for(Candidate_Availability__c ddwrap :candidateD2DWithDTMap.get(key)){
                            if( ddwrap.Start_Date_Time__c==null || ddwrap.End_Date_Time__c==null){
                            } 
                            CSDJSDwrap comwrap =new CSDJSDwrap(new Vacancy_D2D__c(),new Candidate_Availability__c(),'none');
                            if(weekDayMap.get(dt)[0].Id!=null){
                                for(Vacancy_D2D__c jsd :weekDayMap.get(dt)){
                                    if(jsd.Start_Date_Time__c==null || jsd.End_Date_Time__c==null){continue;
                                    }
                                    if(ddwrap.Start_Date_Time__c <= jsd.Start_Date_Time__c && jsd.End_Date_Time__c <= ddwrap.End_Date_Time__c && (!crsJSDMap.containsKey(jsd.Id) && crsJSDMap.get(jsd.Id)==null)){
                                        if(crsCSDMap.get(ddwrap.Id)!=null){comwrap = new CSDJSDwrap(jsd,ddwrap,'redColorStyle');
                                        }else {
                                            if(ddwrap.Type__c != 'Available'){comwrap = new CSDJSDwrap(jsd,ddwrap,'blueColorStyle');
                                            }
                                            else{comwrap = new CSDJSDwrap(jsd,ddwrap,'greenColorStyle');
                                            }
                                        }
                                        if(!csdJSDateMap.containsKey(dt)){csdJSDateMap.put(dt,new List<CSDJSDwrap>{comwrap});   
                                        }else{csdJSDateMap.get(dt).add(comwrap);
                                        }
                                        
                                        if(comwrap.Colour.equals('greenColorStyle')){break;}
                                            
                                        
                                        System.debug('adding to wrapper:'+key);
                                    }
                                }
                            }else{
                                comwrap = new CSDJSDwrap(new Vacancy_D2D__c(),ddwrap,'grayColorStyle');
                                if(!csdJSDateMap.containsKey(dt)){csdJSDateMap.put(dt,new List<CSDJSDwrap>{comwrap});   
                                }
                                else{csdJSDateMap.get(dt).add(comwrap);
                                }
                            }   
                            
                        } 
                    }
                    else{
                        System.debug('No candidate Availablity found for selected Contact : '+ key);
                        Continue;
                    }
                }
            }
        }else{
            System.debug('No matching contact found');
            Utility.AddInfoMessage('No matching contact found');
        }
        showAssignmentDialogBox = true;
        openDialogForClosingReport();
    }
    
    public PageReference MassSMSmethod(){
        set<String> setCandidateid = new set<String>();
        String candidateid;
        for(Resource r : Resources){
            if(r.isSelected == true){
                candidateid = r.candidate.id;
                if(String.isNotBlank(candidateid)) {candidateid = candidateid.trim();setCandidateid.add(candidateid);
                }
            }
            system.Debug('setCandidateid---'+setCandidateid);
            system.Debug('setCandidateid.size()---'+setCandidateid.size());
            
        }
        List<String> candidateidList = new List<String> (setCandidateid);
        PageReference pr = new PageReference('/apex/SendBulkSMS2');
        pr.getParameters().put('candidateids', String.join(candidateidList, ',') );
        pr.getParameters().put('retURL', 'apex/TRS_FilterCandidates' );
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.
        return pr;
        
    }
    
    public void AllSelectcandidate(){
        set<id> setCandidateid = new set<id>();
        for(Resource r : Resources){
            if(r.isSelected == false){
                r.isSelected = true;
            }
            
            system.Debug('setCandidateid---'+setCandidateid);
            system.Debug('setCandidateid.size()---'+setCandidateid.size());
        }
    }
    
    public class Resource {
        
        public boolean isSelected {
            get;
            set;
        }
        
        public Contact candidate {
            get;
            set;
        }
        public Decimal distanceVal  {get; set;}
        public transient String tooltipContent {
            get;
            set;
        }
        public transient Integer score = 0;
        
        
        public Map < Date, List<DayDetailWrapper> > dateAvailMap{
            get;
            set;
        }
        public list < DayDetailWrapper > dayDetailList {
            get;
            set;
        }
        public Map < Date, List<Vacancy_D2D__c> > weekDayMap{
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
        
        public Resource(boolean isSelected, Contact con, Decimal distanceVal, list < Candidate_Availability__c > d2dList, Date startDate, Date endDate,
                        Map < Id,Closing_Report_Schedule__c > crsCSDMap, Map < Date, List<Vacancy_D2D__c> > weekDayMap,Map < Date,List<Candidate_Availability__c> > csdDatesMap,Map< Id,Closing_Report_Schedule__c > crsJSDMap ) {
                            this.isSelected = isSelected;
                            this.candidate = con;
                            this.distanceVal = distanceVal;
                            jobAvailCount = 0 ;
                            // Step 1. Create a map for the 7 days with the Status as Unknown
                            dateAvailMap = new Map < Date, List<DayDetailWrapper> > ();
                            this.weekDayMap = weekDayMap;
                            this.enddate = endDate;
                            dayDetailList = new list < DayDetailWrapper > ();
                            //system.debug('===========================d2dList====='+d2dList);
                            // Creating a Map of date associated with a List of Day Detail
                            for (Integer i = 0; i <= startDate.daysBetween(endDate); i++) {
                                if(csdDatesMap.containsKey(startDate.addDays(i))){
                                    if(csdDatesMap.get(startDate.addDays(i))!=null){
                                        for(Candidate_Availability__c csd : csdDatesMap.get(startDate.addDays(i))){
                                            DayDetailWrapper dayDetailWrap = new DayDetailWrapper();
                                            //String csdTYpe = csd.Type__c;
                                            dayDetailWrap.dayDetail1 = new dayDetail(startDate.addDays(i), 'Unknown');        
                                            dayDetailWrap.canAvailabilityRec = csd;
                                            //system.debug('==============================csd========================='+csd);
                                            if(!dateAvailMap.containsKey(startDate.addDays(i)))
                                                dateAvailMap.put(startDate.addDays(i), new List<DayDetailWrapper>{dayDetailWrap});
                                            else
                                                dateAvailMap.get(startDate.addDays(i)).add(dayDetailWrap);
                                            
                                            dayDetailList.add(dayDetailWrap);
                                        }
                                    }else{
                                        DayDetailWrapper dayDetailWrap = new DayDetailWrapper();
                                        dayDetailWrap.dayDetail1 = new dayDetail(startDate.addDays(i), 'Unknown');         
                                        dayDetailList.add(dayDetailWrap);
                                        if(!dateAvailMap.containsKey(startDate.addDays(i))){dateAvailMap.put(startDate.addDays(i), new List<DayDetailWrapper>{dayDetailWrap});
                                        }
                                        else
                                            dateAvailMap.get(startDate.addDays(i)).add(dayDetailWrap);
                                    }    
                                }else{
                                    DayDetailWrapper dayDetailWrap = new DayDetailWrapper();
                                    dayDetailWrap.dayDetail1 = new dayDetail(startDate.addDays(i), 'Unknown');         
                                    dayDetailList.add(dayDetailWrap);
                                    if(!dateAvailMap.containsKey(startDate.addDays(i)))
                                        dateAvailMap.put(startDate.addDays(i), new List<DayDetailWrapper>{dayDetailWrap});
                                    else
                                        dateAvailMap.get(startDate.addDays(i)).add(dayDetailWrap);
                                }
                            }
                            // system.debug('========dateAvailMap=============='+dateAvailMap);
                            // Step 2. Assign Vacancy D2D to day detail
                            if (!weekDayMap.isEmpty()) {
                                for (Date dt: dateAvailMap.keySet()) {
                                    if (dateAvailMap.containsKey(dt)) {
                                        if(!weekDayMap.containsKey(dt)){
                                            Vacancy_D2D__c vacD2D = new Vacancy_D2D__c();
                                            weekDayMap.put(dt,New List<Vacancy_D2D__c>{vacD2D});
                                        }
                                    }
                                }
                            }
                            
                            // Query and obtain user ProfileName
                            String ProfileNameofUser = Utility.currentUserProfileName;
                            //score = 0;
                            for (Date dt: dateAvailMap.keySet()) {
                                for(DayDetailWrapper ddWrap : dateAvailMap.get(dt)){
                                    // system.debug('=============================ddWrap======='+ddWrap);
                                    if(ddWrap.dayDetail1.Status== 'Available') continue;
                                    if(ddWrap.canAvailabilityRec!=null){
                                        if(crsCSDMap.get(ddWrap.canAvailabilityRec.Id)!=null){
                                            ddWrap.dayDetail1.Status = 'Booked';
                                            ddWrap.dayDetail1.assignedJobName = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name;
                                            ddWrap.dayDetail1.assignedJobId = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__c;
                                            ddWrap.dayDetail1.personPlacedName = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name;
                                            ddWrap.dayDetail1.personPlacedId = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__c;
                                            ddWrap.dayDetail1.shift = ddWrap.vacAvailabilityRec.CLosing_Report_Schedule__r.Shift__c;
                                            ddWrap.dayDetail1.closingReportSchedule = crsCSDMap.get(ddWrap.canAvailabilityRec.Id);
                                        }else{
                                            system.debug('=============================ddWrap.dayDetail1.Status======='+ddWrap.dayDetail1.Status);
                                            system.debug('=============================dt======='+dt);
                                            
                                            if(weekDayMap.get(dt)!=null){
                                                for(Vacancy_D2D__c d2d : weekDayMap.get(dt)){
                                                    system.debug('=============================d2d======='+d2d);
                                                    if(ddWrap.dayDetail1.Status== 'Available' ) continue;
                                                    if(ddWrap.canAvailabilityRec.Start_Date_Time__c!=null &&ddWrap.canAvailabilityRec.End_Date_Time__c!=null && d2d.End_Date_Time__c !=null && d2d.Start_Date_Time__c !=null){
                                                        if( d2d.Start_Date_Time__c>= ddWrap.canAvailabilityRec.Start_Date_Time__c && d2d.End_Date_Time__c<= ddWrap.canAvailabilityRec.End_Date_Time__c && !crsJSDMap.containsKey(d2d.Id))    {
                                                            system.debug('=============================here==111== ddWrap.canAvailabilityRec.Type__c==='+ ddWrap.canAvailabilityRec);
                                                            //ddWrap.dayDetail1.Status = 'Available';
                                                            System.debug('## Job Availability count'+(!crsJSDMap.containsKey(d2d.Id)));
                                                            System.debug('## Map'+crsJSDMap);
                                                            System.debug('## Id value::'+d2d.Id);
                                                            if(ddWrap.canAvailabilityRec.Type__c != 'Available'){ddWrap.dayDetail1.Status = 'UnknownScheduler';
                                                            }
                                                            else{
                                                                ddWrap.dayDetail1.Status = 'Available';
                                                                
                                                                if(!crsJSDMap.containsKey(d2d.Id)){jobAvailCount = jobAvailCount +1 ;
                                                                }
                                                            }
                                                        }
                                                        else{
                                                            ddWrap.dayDetail1.Status = 'Unknown';
                                                        }    
                                                    }else{
                                                        ddWrap.dayDetail1.Status = 'Unknown';
                                                    }
                                                    
                                                }
                                                ddWrap.dayDetail1.assignedJobName = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name;
                                                ddWrap.dayDetail1.assignedJobId = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__c;
                                                ddWrap.dayDetail1.personPlacedName = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name;
                                                ddWrap.dayDetail1.personPlacedId = ddWrap.vacAvailabilityRec.Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__c;
                                                ddWrap.dayDetail1.shift = ddWrap.vacAvailabilityRec.CLosing_Report_Schedule__r.Shift__c;
                                                ddWrap.dayDetail1.showAssignButton = (ddWrap.dayDetail1.status=='Available') ? True : False ;
                                            }else{
                                                system.debug('============================= ddWrap.canAvailabilityRec.Type__c  HERE======='+ddWrap.canAvailabilityRec.Type__c);
                                                if(ddWrap.canAvailabilityRec.Type__c != 'Available')
                                                    ddWrap.dayDetail1.Status = 'UnknownScheduler';
                                                else
                                                    ddWrap.dayDetail1.Status = 'Available';
                                            }
                                        }
                                    }
                                    if (Utility.colorStsMap.containsKey(ddWrap.dayDetail1.status)) {
                                        ddWrap.dayDetail1.colorStyle = Utility.colorStsMap.get(ddWrap.dayDetail1.status);
                                    }  
                                }
                            }
                            // Tooltip Content
                            tooltipContent = '<table width="100%" style="table-layout:fixed">';
                            tooltipContent += Utility.addTableRow('Candidate Name', String.isNotBlank(candidate.Name) ? candidate.Name : '');
                            tooltipContent += Utility.addTableRow('Phone', String.isNotBlank(candidate.Phone) ? candidate.Phone : '');
                            tooltipContent += Utility.addTableRow('Mobile No.', String.isNotBlank(candidate.MobilePhone) ? candidate.MobilePhone : '');
                            tooltipContent += Utility.addTableRow('Email', candidate.Email + '  <a href= mailto:' + candidate.Email + ' >Send Email</a>');
                            tooltipContent += Utility.addTableRow('Subject', String.isNotBlank(candidate.Subject__c) ? candidate.Subject__c : ''); 
                            tooltipContent += Utility.addTableRow('Skills Training Experience', String.isNotBlank(candidate.Skills_Training_Experience__C) ? candidate.Skills_Training_Experience__C : ''); 
                            tooltipContent += Utility.addTableRow('Year/Key Stage', String.isNotBlank(candidate.Year_Key_Stage__c) ? candidate.Year_Key_Stage__c : ''); 
                            tooltipContent += Utility.addTableRow('SEN Qualifications', String.isNotBlank(candidate.Qualificaitons__c) ? candidate.Qualificaitons__c : '');
                            tooltipContent += Utility.addTableRow('SEN', String.isNotBlank(candidate.SEN__c) ? candidate.SEN__c : ''); 
                            tooltipContent += Utility.addTableRow('SEN Experience', String.isNotBlank(candidate.SEN_Experience__c) ? candidate.SEN_Experience__c : ''); 
                            tooltipContent += Utility.addTableRow('Nearest Station', String.isNotBlank(candidate.Train_Station__r.Name) ? candidate.Train_Station__r.Name : '');
                            tooltipContent += Utility.addTableRow('Postcode', String.isNotBlank(candidate.OtherPostalCode) ? candidate.OtherPostalCode : '');
                            tooltipContent += Utility.addTableRow('GPS', String.isNotBlank(candidate.GPS__c) ? candidate.GPS__c : '');
                            tooltipContent += '</table>';
                            
                            
                            
                            for (Date dt: dateAvailMap.keySet()) {
                                for(DayDetailWrapper daywrap1 : dateAvailMap.get(dt)){
                                    DayDetailWrapper ddWrap = daywrap1;
                                    if (ddWrap.dayDetail1 != null) {
                                        if (ddWrap.dayDetail1.closingReportSchedule != null) {
                                            ddWrap.dayDetail1.tooltipContent = '<table width="100%">';
                                            
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Vacancy Assigned', String.isNotBlank(ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Job__r.Name) ? ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Job__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Candidate Assigned', String.isNotBlank(ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Person_Placed__r.Name) ? ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Person_Placed__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Hourly Pay Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Hour_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Half Day Pay Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Half_Day_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Day Pay Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Day_Pay_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Hourly Charge Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Hour_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Half Charge Pay Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Half_Day_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Day Charge Rate', ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Maximum_Day_Charge_Rate__c);
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Owner', String.isNotBlank(ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Job_Credit__r.Name) ? ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Job_Credit__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Timesheet Approver', String.isNotBlank(ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Timesheet_Approver__r.Name) ? ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.TR1__Timesheet_Approver__r.Name : '');
                                            ddWrap.dayDetail1.tooltipContent += Utility.addTableRow('Booking Type', String.isNotBlank(ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Booking_Type__c) ? ddWrap.dayDetail1.closingReportSchedule.Closing_Report__r.Booking_Type__c : '');
                                            
                                            tooltipContent += '</table>';
                                        }
                                    }
                                }
                            }
                        }
    }
    
    
    public class dayDetail {
        public Closing_Report_Schedule__c closingReportSchedule {
            get;
            private set;
        }
        
        public String status {
            get;
            private set;
        }
        
        // Other Details
        public String assignedJobName {
            get;
            private set;
        }
        public String assignedJobId {
            get;
            private set;
        }
        public String personPlacedName {
            get;
            private set;
        }
        public String personPlacedId {
            get;
            private set;
        }
        public String shift {
            get;
            private set;
        }
        public String VacAvailshift {
            get;
            private set;
        }
        public String CandidAvailshift {
            get;
            private set;
        }
        
        public Date VacancySelectedDate {
            get;
            set;
        }
        public String VacancyDateSelected {
            get;
            set;
        }
        
        public Boolean showAssignButton {
            get;
            set;
        }
        public Boolean cancelAssignButton {
            get;
            set;
        }
        
        public transient String toolTipContent {
            get;
            set;
        }
        public transient String colorStyle {
            get;
            set;
        }
        
        public dayDetail(Date dt, String status) {
            VacancySelectedDate = dt;
            VacancyDateSelected = VacancySelectedDate.format();
            this.status = status;
            
            closingReportSchedule = new Closing_Report_Schedule__c();
        }
    }
    
    /* Create Closing Report - START */
    public TR1__Closing_Report__c closingReport {get; set;}
    public Contact candidateRecord {
        get;
        set;
    }
    
    List < Closing_Report_Schedule__c > schedulesForInsert = new List < Closing_Report_Schedule__c > ();
    
    public Boolean showAssignmentDialogBox {
        get {
            if (showAssignmentDialogBox == null){showAssignmentDialogBox = false;
            }
            return showAssignmentDialogBox;
        }
        set;
    }
    
    public String CandidateName {
        get;
        set;
    }
    public String candidateId {
        get;
        set;
    }
    
    public class ShiftClass {
        public boolean isActive {
            get;
            set;
        }
        public String selectedType {
            get;
            set;
        }
        public list < SelectOption > optionList {
            get;
            private set;
        }
        public Date shiftDate {
            get;
            set;
        }
        public String bookingType {
            get;
            set;
        }
        
    }
    public transient String clientContact{get; set;}
    
    public void openDialogForClosingReport() {
        
        String cFName = vacancy.TR1__Contact__r.FirstName!= null ? vacancy.TR1__Contact__r.FirstName:'';
        String cLName = vacancy.TR1__Contact__r.LastName!= null ? vacancy.TR1__Contact__r.LastName:'';
        
        closingReport = new TR1__Closing_Report__c();
        closingReport.Pay_Type__c = vacancy.Shift__c;//updated on 5-DEC-16 
        VacancyRecord.Booking_Type__c = Vacancy.Booking_Type__c;
        VacancyRecord.Booking_Reason__c = Vacancy.Booking_Reason__c;
        closingReport.Annual_Leave_Entitlement__c = '65 Days';
        closingReport.School_Working_Days__c = 195.0;
        
        
        startDateEnterred = vacancy.TR1__Estimated_Start_Date__c.format();
        endDateEnterred = vacancy.TR1__Estimated_End_Date__c.format();
        
        
        if(vacancyStartDate != '' && string.isNotEmpty(vacancyStartDate)){
            startDateEnterred = vacancyStartDate;
            endDateEnterred = vacancyStartDate;
        }  
        candidateId = Utility.getPageParameter('contact1');
        System.debug('##### candidateId value is :'+candidateId);
        contact1  = candidateId;
        
        if(!test.isRunningTest()){
            conToShowRate = [Select Id, Daily_Rate_Agreed__c, Half_Day_Rate_Agreed__c, Hourly_Rate_Agreed__c FROM Contact where Id =: candidateId limit 1];
        }
        
        candidateName = Utility.getPageParameter('candidateName');
        String vacancyDate = String.valueOf(endDate);
        system.debug('vacancyDate is --'+vacancyDate);
        String DateValue  = Date.valueOf(vacancyDate).format();
        System.debug('Vacancy Ownerid is======@@@@@>'+vacancy.OwnerId);
        
        decimal payRate = 0;
        
        map < Date, Candidate_Availability__c > candidateAvailMap = new map < Date, Candidate_Availability__c > ();
        for (Candidate_Availability__c candD2D : [Select Start_Date__c, End_Date__c,End_Date_Time__c,Start_Date_Time__c,Candidate__c,Applicable_Days__c,Type__c
                                                  from  Candidate_Availability__c
                                                  where Candidate__c = : candidateId
                                                  and   Start_Date__c >= : startDate 
                                                  and End_Date__c <= : endDate
                                                  order By createdDate]) {candidateAvailMap.put(candD2D.Start_Date__c, candD2D);
                                                  }
        System.debug('CR Start Date :'+startDate);
        System.debug('CR End Date:'+endDate);
        TR1__Closing_Report__c[] closingReports = [Select TR1__Start_Date__c, TR1__End_Date__c, TR1__Bill_Rate__c, TR1__Pay_Rate__c, Shift__c, Booking_Type__c, TR1__Candidate_Credit__c, TR1__Job_Percentage__c, TR1__Candidate_Percentage__c,
                                                   TR1__Timesheet_Type__c,TR1__Person_Placed__c, TR1__Timesheet_Approver__c, TR1__OT_Bill_Rate_Multiplier_Percentage__c, TR1__Job_Credit__c, TR1__Job_Credit__r.Name, TR1__Candidate_Credit__r.Name,
                                                   TR1__Timesheet_Approver__r.Name, TR1__Marketing_Credit__c, TR1__Marketing_Credit__r.Name, TR1__Marketing_Percentage__c,TR1__Job__r.TR1__Maximum_Pay_Rate__c,TR1__Job__r.TR1__Maximum_Bill_Rate__c,
                                                   TR1__Other_Credit__c, TR1__Other_Credit__r.Name, TR1__Other_Percentage__c,Shift_Multiple__c,
                                                   TR1__Other2_Credit__c, TR1__Other2_Credit__r.Name, TR1__Other2_Percentage__c,Pay_Type__c,Comparator_Full_Time_Annual_Salary__c,School_Working_Days__c,Annual_Leave_Entitlement__c,Maximum_Hour_Pay_Rate__c,Maximum_Hour_Charge_Rate__c,Maximum_Day_Pay_Rate__c,Maximum_Day_Charge_Rate__c,Maximum_Half_Day_Pay_Rate__c,Maximum_Half_Day_Charge_Rate__c,Maximum_Charge_Per_Day__c,Maximum_Pay_rate_Per_Day__c
                                                   from   TR1__Closing_Report__c
                                                   where   TR1__Person_Placed__c = : candidateId
                                                   and   TR1__Job__c = : vacancy.Id
                                                   and   RecordType.Name = :TRS_VacancyHelper.CONSULTING
                                                   and TR1__Start_Date__c <= :startDate
                                                   and TR1__End_Date__c >= :endDate
                                                   order by TR1__Start_Date__c];
        
        Date selectedDate = Date.parse(DateValue);
        Date startoftheWeekDate = selectedDate.toStartOfWeek();
        closingReport.TR1__Job_Credit__c= vacancy.OwnerId;
        if(String.isNotBlank(startDateEnterred)){
            jobForDate.TR1__Estimated_Start_Date__c = Date.parse(startDateEnterred);
        }
        if(String.isNotBlank(endDateEnterred)){
            jobForDate.TR1__Estimated_End_Date__c  = Date.parse(endDateEnterred);
        }
        
        
        candidateAvailMap = null;
        System.debug('Candidate Id: '+candidateId);
        for(TR1__Associated_Qualification__c  ql : [SELECT id,Positive_DBS__c FROM TR1__Associated_Qualification__c 
                                                        WHERE TR1__Contact__c = :candidateId 
                                                        AND qualificationName__c = 'DBS' LIMIT 1]){positivedbs = ql.Positive_DBS__c;
            System.debug('Positive DBS Alert:'+positivedbs);
        }

        if (closingReports != null && closingReports.size() > 0) {
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
        } else {
            closingReport.TR1__Job__c = vacancy.Id;
            closingReport.TR1__Person_Placed__c = candidateId;
            closingReport.Invoicing_Person__c = vacancy.TR1__Account__r.Invoice_Contact__c;
            closingReport.TR1__Start_Date__c = startDate;
            closingReport.TR1__End_Date__c = startDate;
            closingReport.RecordTypeId = Utility.CONSULTING_RTID;
            closingReport.TR1__Bill_Rate__c = vacancy.TR1__Account__r.Agreed_D2D_Charge_Rate__c;
            closingReport.TR1__Pay_Rate__c = payRate;
            closingReport.TR1__Timesheet_Approver__c = vacancy.Timesheet_Approver__c;
            closingReport.TR1__Account__c = vacancy.TR1__Account__c;
            closingReport.Booking_Type__c =VacancyRecord.Booking_Type__c;
            closingReport.Booking_Reason__c =VacancyRecord.Booking_Reason__c;
            closingReport.TR1__Billing_Street__c = vacancy.TR1__Account__r.BillingStreet; 
            closingReport.TR1__Billing_City__c = vacancy.TR1__Account__r.BillingCity;
            closingReport.TR1__Billing_Zip_Code__c = vacancy.TR1__Account__r.BillingPostalCode;
            closingReport.Hiring_Manager__c = vacancy.TR1__Hiring_Manager__c;
            clientContact                               = cFName + ' ' + cLName;
            closingReport.TR1__Job_Percentage__c = 100;
            if(vacancy.TR1__Account__r.BillingState  != null){
                String shippingState = vacancy.TR1__Account__r.BillingState ;
                if(vacancy.TR1__Account__r.BillingState .length() >3){
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
            if(string.isBlank(startDateEnterred) && string.isBlank(endDateEnterred)){Utility.AddErrorMessage('Please Enter the Start Date and End Date ');
                return null ;
            }
            if(string.isBlank(startDateEnterred)){Utility.AddErrorMessage('Please Enter the Start Date ');
                return null ;
            }
            if(string.isBlank(endDateEnterred)){Utility.AddErrorMessage('Please Enter the End Date ');
                return null ;
            }
            
            date startdateforcr = Date.parse(startDateEnterred);
            date enddateforcr   = Date.parse(endDateEnterred);
            if(startdateforcr > enddateforcr) {utility.addInfomessage('Selected start date should be less than selected end date '); return null; 
            }
            Map<Date,List<Vacancy_D2D__c>> tempVacAvailmap =new  Map<Date,List<Vacancy_D2D__c>>();
            Map<Date,List<Candidate_Availability__c>> tempCanAvailmap = new Map<Date,List<Candidate_Availability__c>>();
            
            // First Upsert the Closing Report
            if (closingReport.Id == null) {
                closingReport.TR1__Start_Date__c = startdateforcr;
                closingReport.TR1__End_Date__c = enddateforcr;
                closingReport.Contract_End_Date__c = enddateforcr;
                closingReport.TR1__Person_Placed__c = Id.valueOf(contact1);
                System.debug('========================= Contact 1 value is :'+Id.valueOf(contact1));
                Contact con = [Select Id, Daily_Rate_Agreed__c, Half_Day_Rate_Agreed__c, Hourly_Rate_Agreed__c FROM Contact where Id =: closingReport.TR1__Person_Placed__c limit 1];
                
                if(closingReport.Maximum_Day_Pay_Rate__c != null){
                    if(closingReport.Maximum_Day_Pay_Rate__c > con.Daily_Rate_Agreed__c){ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Day Pay Rate	 More then Maximum Day Pay Rate'));
                        return null;
                    }
                }
                
                if(closingReport.Maximum_Day_Pay_Rate__c == null){closingReport.Maximum_Day_Pay_Rate__c = con.Daily_Rate_Agreed__c;
                }
                
                if(closingReport.Maximum_Half_Day_Pay_Rate__c != null){
                    if(closingReport.Maximum_Half_Day_Pay_Rate__c > con.Half_Day_Rate_Agreed__c){ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Half Day Pay Rate More then Maximum Half Day Pay Rate'));
                        return null;
                    }
                }
                if(closingReport.Maximum_Half_Day_Pay_Rate__c == null){closingReport.Maximum_Half_Day_Pay_Rate__c = con.Half_Day_Rate_Agreed__c;
                }
                
                
                if(closingReport.Maximum_Hour_Pay_Rate__c != null){
                    if(closingReport.Maximum_Hour_Pay_Rate__c > con.Hourly_Rate_Agreed__c){ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You Cannot Enter : Hour Pay Rate More then Maximum Hour Day Pay Rate'));
                        return null;
                    }
                }
                if(closingReport.Maximum_Hour_Pay_Rate__c == null){closingReport.Maximum_Hour_Pay_Rate__c = con.Hourly_Rate_Agreed__c;
                }
                
                
                System.debug('============= :'+closingReport.Maximum_Hour_Pay_Rate__c);
                
                if(closingReport.Maximum_Day_Charge_Rate__c == null){closingReport.Maximum_Day_Charge_Rate__c = vacancy.TR1__Maximum_Bill_Rate__c; 
                }   
                
                if(closingReport.Maximum_Half_Day_Charge_Rate__c == null){closingReport.Maximum_Half_Day_Charge_Rate__c = vacancy.TR1__Minimum_Bill_Rate__c;
                }
                
                if(closingReport.Maximum_Hour_Charge_Rate__c == null ){closingReport.Maximum_Hour_Charge_Rate__c = vacancy.Maximum_Hour_Charge_Rate__c;  
                }
                
                if(test.isRunningTest())closingReport.TR1__Job_Percentage__c=100;
                if(closingReport.Pay_Type__c=='Hour' && (closingReport.Maximum_Hour_Pay_Rate__c==null || closingReport.Maximum_Hour_Charge_Rate__c==null)){Utility.AddErrorMessage('Please enter the Hour charge rate and pay rate. ');
                    return null ;
                }else if(closingReport.Pay_Type__c=='Day' && (closingReport.Maximum_Day_Pay_Rate__c==null || closingReport.Maximum_Day_Charge_Rate__c==null)){Utility.AddErrorMessage('Please enter the Day charge rate and pay rate. ');
                    return null ;
                }
                else if(closingReport.Pay_Type__c=='Half-Day' && (closingReport.Maximum_Half_Day_Pay_Rate__c==null || closingReport.Maximum_Half_Day_Charge_Rate__c==null)){Utility.AddErrorMessage('Please enter the Half-Day charge rate and pay rate. ');
                    return null ;
                }else{
                    ClosingReportTriggerHelper.FromJobboard = True ;
                    insert closingReport;
                }
                
            }
            
            
            List <Closing_Report_Schedule__c> crsList = new List <Closing_Report_Schedule__c>();
            if( enddateforcr <=  enddate){
                List<Date>datelist = new List<date>();
                for(date dt : csdJSDateMap.keyset()){
                    datelist.add(dt);
                }
                
                datelist.sort();
                integer diffdates = startdateforcr.daysBetween(enddateforcr);
                for(integer dt=0 ;dt<=diffdates;dt++){
                    System.debug('Processig dates are '+startdateforcr.addDays(dt));
                    if(csdJSDateMap.containsKey(startdateforcr.addDays(dt))){
                        for(CSDJSDwrap ddwrap : csdJSDateMap.get(startdateforcr.addDays(dt))){
                            if(ddwrap.Colour=='greenColorStyle'){
                                Closing_Report_Schedule__c CRS = new Closing_Report_Schedule__c();
                                CRS.Schedule_Date__c = startdateforcr.addDays(dt);
                                CRS.Closing_Report__c  =closingReport.Id;
                                CRS.Candidate_Availability__c = ddwrap.canAvail.Id;
                                CRS.Vacancy_Schedule__c = ddwrap.vaccAvail.ID;
                                CRS.Status__c  = 'Booked';
                                crsList.add(CRS);
                            }
                            
                        }
                    }
                    
                    if(startdateforcr.addDays(dt) == enddateforcr){break; 

                    }
                }
            }else{
                for (Candidate_Availability__c candD2D : [Select Start_Date__c, End_Date__c,End_Date_Time__c,Start_Date_Time__c,Candidate__c,Applicable_Days__c,Type__c from  Candidate_Availability__c where Candidate__c = : closingReport.TR1__Person_Placed__c and Start_Date__c >= : startdateforcr and Start_Date__c <= : enddateforcr order By createdDate]) {
                                                              if(!tempCanAvailmap.containsKey(candD2D.Start_Date__c)){tempCanAvailmap.put(candD2D.Start_Date__c, New List<Candidate_Availability__c>{candD2D});
                                                              }
                                                              else{  tempCanAvailmap.get(candD2D.Start_Date__c).add(candD2D);
                                                              }
                                                          }
                for (Vacancy_D2D__c vacD2D: [Select Candidate_Assigned__c, Shift__c, Status__c, Vacancy__c, Vacancy_Date__c,Start_Date_Time__c,End_Date_Time__c,Closing_Report_Schedule__c, Closing_Report_Schedule__r.Shift__c, Closing_Report_Schedule__r.createdById, Closing_Report_Schedule_Secondary__r.createdById,
                                             Closing_Report_Schedule__r.Closing_Report__r.Booking_Type__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Bill_Rate__c, Closing_Report_Schedule_Secondary__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__r.Name,
                                             Closing_Report_Schedule__r.Closing_Report__r.TR1__Pay_Rate__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job_Credit__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Job__c, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__c,
                                             Closing_Report_Schedule__r.Closing_Report__r.Shift__c, Closing_Report_Schedule__r.Closing_Report__r.TR1__Timesheet_Approver__r.Name, Closing_Report_Schedule_Secondary__r.Shift__c, Vacancy__r.Booking_Type__c,
                                             Closing_Report_Schedule__r.Closing_Report__r.TR1__Person_Placed__r.Name, Closing_Report_Schedule__r.Closing_Report__r.TR1__Job__r.Name, Closing_Report_Schedule_Secondary__r.Closing_Report__r.TR1__Person_Placed__r.Name
                                             from Vacancy_D2D__c
                                             where Vacancy__c =: grossProfit.TR1__Job__c and Vacancy_Date__c >=: startdateforcr and Vacancy_Date__c <=: enddateforcr and Start_Date_Time__c != null and End_Date_Time__c != null]) {
                                                if(!tempVacAvailmap.containsKey(vacD2D.Vacancy_Date__c)){tempVacAvailmap.put(vacD2D.Vacancy_Date__c, new List<Vacancy_D2D__c>{vacD2D});
                                                }
                                                else{ tempVacAvailmap.get(vacD2D.Vacancy_Date__c).add(vacD2D);
                                                }
                                            }
                
                Integer numberDaysDue = startDate.daysBetween(enddateforcr);
                Set<Id> candidateAvailablityIdSet = new Set<Id>();
                
                for(integer dt = 0; dt<=numberDaysDue; dt++){
                    if(tempVacAvailmap.get(startDate.addDays(dt))==null){continue;
                    }
                    for(Vacancy_D2D__c vcc : tempVacAvailmap.get(startDate.addDays(dt))){
                        if(tempCanAvailmap.get(startDate.addDays(dt))==null){continue;
                        }
                        for(Candidate_Availability__c candt : tempCanAvailmap.get(startDate.addDays(dt))){
                            if((candt.Start_Date_Time__c <= vcc.Start_Date_Time__c && vcc.End_Date_Time__c <= candt.End_Date_Time__c)&&(candt.Start_Date_Time__c !=Null&& vcc.Start_Date_Time__c!=Null  && vcc.End_Date_Time__c!=Null&&candt.End_Date_Time__c!=Null) && !candidateAvailablityIdSet.contains(candt.Id)){
                                Closing_Report_Schedule__c CRS = new Closing_Report_Schedule__c();
                                CRS.Schedule_Date__c = startDate.addDays(dt);
                                CRS.Closing_Report__c  = closingReport.Id;
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
            partialsave =  Boolean.valueOf(Utility.getPageParameter('partialsave'));
            
            if(partialsave){
                if(crsList.size()>0){
                    srList = Database.insert(crsList, false);
                    refresh();
                    Utility.AddInfoMessage('Booking completed sucessfully.'); 
                }
                else {
                    Database.rollback(sp);
                    Utility.AddErrorMessage('Please check with date range as no availability slots found in range you provided.');
                    return null;
                }
            }else{
                if(crsList.size()>0){
                    srList = Database.insert(crsList,  true);
                    refresh();
                    Utility.AddInfoMessage('Booking completed sucessfully.'); 
                }
                else {
                    Database.rollback(sp);
                    Utility.AddErrorMessage('Please check with date range as no availability slots found in range you provided.'); 
                    return null;
                }
            }            
            List <TR1__Closing_Report__c> crlist=[Select Name from TR1__Closing_Report__c where Id= :closingReport.id limit 1 ];
            return new PageReference('/apex/TRS_FilterCandidates?id='+grossProfit.TR1__Job__c+'&&save='+crlist[0].Name).setRedirect(true);
            
        }
        catch (DMLException e) {
            Utility.AddErrorMessage('' +e.getDmlMessage(0));
            Database.rollback(sp);
            closingreport.id = null;
            return null;
        }
        catch (Exception e) {
            Utility.AddErrorMessage('Closing Report & CRS Save failed. Following Exception occurred: ' + e.getMessage() + ' at line number '+ e.getLineNumber());
            Database.rollback(sp);
            closingReport.id = null;
            return null;
        }
    }
    
    public void refresh() {
        showAssignmentDialogBox = false;
        candidateId = null;
        candidateName = null;
        getResourceAvailability();
        jobForDate.TR1__Estimated_Start_Date__c = null;
        jobForDate.TR1__Estimated_End_Date__c = null;
    }
    /* Create Closing Report - END */
    
    
    
    /* DELETE CLOSING REPORT SCHEDULE RECORD - END */
    
    /* Create Vacancy Record Record */
    
    public TR1__Job__c vacRecord {
        get;
        set;
    }
    
    public Boolean showCreateVacancyRecord {
        get {
            if (showCreateVacancyRecord == null)
                showCreateVacancyRecord = false;
            return showCreateVacancyRecord;
        }
        set;
    }
    
    public void openCreateVacancyRecordDialog() {
        showCreateVacancyRecord = true;

        clonevacancy = false;
        
        vacRecord = new TR1__Job__c();
        vacRecord.RecordTypeId = TRS_VacancyHelper.CONSULTING_RTID;
        vacRecord.Booking_Type__c = 'Daily';
        if(vacRecord.ownerId == null || vacRecord.ownerId == ''){
            vacRecord.ownerId = UserInfo.getUserId();
        }

        weekData = test_weekData();
    }
    
    public boolean clonevacancy = false;
    
    public void openCloneVacancyrecordDialog() {
        
        clonevacancy = true;
        vacRecord = new TR1__Job__c();
        
        vacRecord = vacancy.clone(false);

        System.debug('clone value Old>>>'+ vacancy.Selected_Week_Days__c);
        System.debug('clone value New>>>'+ vacRecord.Selected_Week_Days__c);
        System.debug('clone value New>>>'+ vacRecord.weekDaysTime__c);
        
        vacRecord.RecordTypeId = TRS_VacancyHelper.CONSULTING_RTID;

        if(vacancy.Selected_Week_Days__c){
            if(vacRecord.Applicable_Days__c != null){
                List<String> tl = vacRecord.Applicable_Days__c.split(';');
    
                strings = new List<String>();
                strings = tl;
                System.debug(tl);
            }
            else{
                strings = new List<String>();
            }
        }

        weekData = test_weekData();
        System.debug(vacancy.weekDaysTime__c);
        System.debug(vacRecord.weekDaysTime__c);
        String weekdataa = vacancy.weekDaysTime__c;
        weekdataa = weekdataa.replaceAll('"', '');
        if(vacancy.weekDaysTime__c != null){
            Map<String, Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(weekdataa.substring(1, weekdataa.length() -1));
            System.debug(rawObj);
            for(String st : rawObj.keySet()){
                String tg = JSON.serialize(rawObj.get(st));
                String fg = tg.replaceAll('\\\\', '');
                fg = fg.substring(1, fg.length() - 1);
                Map<String, Object> temp_map = (Map<String,Object>)JSON.deserializeUntyped(fg);
                
                Map<String, String> temp_map_2 = new Map<String,String>();
                temp_map_2.put('ST', JSON.serialize(temp_map.get('ST')).substring(1, 9));
                temp_map_2.put('ET', JSON.serialize(temp_map.get('ET')).substring(1, 9));
                
                System.debug(temp_map);
                System.debug(temp_map_2);
                // weekData.put(st, temp_map_2);
            }
        }

        showCreateVacancyRecord = true;
    }

    public PageReference saveCreateVacancyRecord() {
        Savepoint sp = Database.setSavepoint();
        try {
            // weekData = new Map<String, Map<String,String>>();
            System.debug(vacRecord.Selected_Week_Days__c);
            if(vacRecord.Selected_Week_Days__c){
                TRS_VacancyHelper.boolcheck = false;
                System.debug('ByPass Trigger on TRS_FilterJobs');


                List<String> applicableDaysSet_new = vacRecord.Applicable_Days__c.split(';');
                System.debug(applicableDaysSet_new);
                boolean daysTime = false;
                String MST = Apexpages.currentPage().getParameters().get('weekdaysTime');

                System.debug(MST);
                Map<String, Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(MST);
                for(String st : applicableDaysSet_new){
                    System.debug(rawObj.get(st));

                    if(!clonevacancy){
                        if(rawObj.get(st) != null){
                            String tg = JSON.serialize(rawObj.get(st));
                            String fg = tg.replaceAll('\\\\', '');
                            fg = fg.substring(1, fg.length() - 1);
                            Map<String, Object> TimeToken = (Map<String,Object>)JSON.deserializeUntyped(fg);
                            System.debug(TimeToken);
                            if(TimeToken.get('ST') == null && TimeToken.get('ET') == null && TimeToken.get('ST') == '--None--' && TimeToken.get('ET') == '--None--'){
                                daysTime = true;
                                break;
                            }
                            else{
                                Map<String, String> temp_map = new Map<String, String>();
                                temp_map.put('ST', JSON.serialize(TimeToken.get('ST')).substring(1, 9));
                                temp_map.put('ET', JSON.serialize(TimeToken.get('ET')).substring(1, 9));
                                weekData.put(st, temp_map);
                            }
                        }
                        else{
                            daysTime = true;
                            break;
                        }

                    }
                    else{
                        if(weekData.get(st) != null){
                            Map<String, Object> TimeToken = (Map<String,Object>)weekData.get(st);
                            if(TimeToken.get('ST') == null && TimeToken.get('ET') == null && TimeToken.get('ST') == '--None--' && TimeToken.get('ET') == '--None--'){
                                daysTime = true;
                                break;
                            }
                            else{
                                Map<String, String> temp_map = new Map<String, String>();
                                temp_map.put('ST', JSON.serialize(TimeToken.get('ST')).substring(1, 9));
                                temp_map.put('ET', JSON.serialize(TimeToken.get('ET')).substring(1, 9));
                                weekData.put(st, temp_map);
                            }
                        }
                        else{
                            daysTime = true;
                            break;
                        }

                        System.debug(weekData.get(st));
                    }
                }

                System.debug(weekData);
                System.debug(daysTime);

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
        } catch (Exception e) {
            System.debug('Exception ' + e);
            Database.rollback(sp);
        }
        return null;
    }
    
    public void cancelVacancyCreation() {
        showCreatevacancyRecord = false;
        vacRecord = null;
    }
    /* END VACANCY RECORD CREATION */
    
    public String selectedSector {
        get;
        set;
    }
    
    public string selectedSubSector {
        get;
        set;
    }
    
    public String selectedSpecialism {
        get;
        set;
    }
    
    public Boolean isJobTitleDisplay {
        get;
        set;
    }
    public String selectedLEA {
        get;
        set;
    }
    public String selectedSubLEA {
        get;
        set;
    }
    
    
    public List < Selectoption > getLEAOption() {
        Schema.DescribeFieldResult F = Account.LEA__c.getDescribe();
        List < Selectoption > so = new List < Selectoption > ();
        for (Schema.PicklistEntry P: F.getPicklistValues()) {
            so.add(new Selectoption(p.getLabel(), p.getValue()));
        }
        return so;
    }
    public list < SelectOption > LEAOption {
        get {
            Schema.DescribeFieldResult F = Account.LEA__c.getDescribe();
            List < Selectoption > so = new List < Selectoption > ();
            for (Schema.PicklistEntry P: F.getPicklistValues()) {
                so.add(new Selectoption(p.getLabel(), p.getValue()));
            }
            return so;
        }
        set;
    }
    
    public List < Selectoption > getsubLEAs() {
        Schema.DescribeFieldResult F = Account.LEA_Region__c.getDescribe();
        List < Selectoption > so = new List < Selectoption > ();
        for (Schema.PicklistEntry P: F.getPicklistValues()) {
            so.add(new Selectoption(p.getLabel(), p.getValue()));
        }
        return so;
    }
    
    
    
    
    public List < Selectoption > getSectors() {
        Schema.DescribeFieldResult F = TR1__Job__c.Sector1__c.getDescribe();
        List < Selectoption > so = new List < Selectoption > ();
        so.add(new Selectoption('', '--None--'));
        for (Schema.PicklistEntry P: F.getPicklistValues()) {
            so.add(new Selectoption(p.getLabel(), p.getValue()));
        }
        return so;
    }
    
    public list < SelectOption > jobTitles {
        get {
            Schema.DescribeFieldResult F = Schema.sObjectType.contact.fields.Job_Titles__c; //TR1__Job__c.Job_Title__c.getDescribe();//Updated on 2-DEC-2016
            List < Selectoption > so = new List < Selectoption > ();
            for (Schema.PicklistEntry P: F.getPicklistValues()) {
                so.add(new Selectoption(p.getLabel(), p.getValue()));
            }
            return so;
        }
        set;
    }
    
    /* End of  filter section */

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
    
    public void doSchoolNamePopulate(){
        system.debug('$$calling function :'+vacRecord.Shift__c);
        if(vacRecord.TR1__Account__c != null){
            system.debug('calling '+ vacRecord.TR1__Account__c);
            for(Account acc : [Select Id,School_Type__c,Payroll_Primary_Contact__c,Standard_Hourly_Rate__c,Agreed_D2D_Charge_Rate__c,Standard_Half_Day_Rate__c,Payroll_Primary_Hiring_Manager__c From Account 
                                    Where Id =: vacRecord.TR1__Account__c limit 1]){
                system.debug('Enter in this');
                vacRecord.School_Type__c = acc.School_Type__c;
                vacRecord.TR1__Contact__c = acc.Payroll_Primary_Contact__c;
                vacRecord.TR1__Hiring_Manager__c = acc.Payroll_Primary_Hiring_Manager__c;
                vacRecord.Timesheet_Approver__c = acc.Payroll_Primary_Hiring_Manager__c;
                vacRecord.Maximum_Hour_Charge_Rate__c = acc.Standard_Hourly_Rate__c;
                vacRecord.TR1__Maximum_Bill_Rate__c = acc.Agreed_D2D_Charge_Rate__c;
                vacRecord.TR1__Minimum_Bill_Rate__c = acc.Standard_Half_Day_Rate__c;
                system.debug('Enter in this :'+vacRecord.Maximum_Hour_Charge_Rate__c +'@@@@@@@@@@@@@@'+vacRecord.TR1__Maximum_Bill_Rate__c+'@@@@@@@@@@@@@@'+vacRecord.TR1__Minimum_Bill_Rate__c);
                
            }
        }
    }
    
    public DateTime formatDateTimefromDate(Date dateVar,String startTime){
        
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
    /* UTILIY FUNCTIONS : END */ 

    public Boolean editCreateVacancyRecord { get; set; }
    public Vacancy_D2D__c vD2D {get;set;}

    public Candidate_Availability__c Candidate_ava {get; set;}


    public void openEditVacancyRecordDialog() { 
        editCreateVacancyRecord = true;
        String Id = Apexpages.currentPage().getParameters().get('firstParam');
        System.debug('id vacancy D2d=====>>>>>>>>>>>>>>>>>'+ Apexpages.currentPage().getParameters().get('firstParam'));
        if(Id != null ){

            Candidate_ava = [SELECT Id,Name,Applicable_Days__c,Candidate__c,Description__c,End_Date_Time__c,Shift__c,Start_Date_Time__c,Status__c,End_Date__c,Start_Date__c,Type__c FROM Candidate_Availability__c WHERE Id =: Id LIMIT 1];
        }
        System.debug('vD2d===[]]][][===>'+Candidate_ava);
    }

    public PageReference saveEditVacancyRecord() {
        if(Test.isRunningTest()){
            editCreatevacancyRecord = false;
        }
        Savepoint sp = Database.setSavepoint();
        try {

            System.debug('111>>>'+Candidate_ava);
            // System.debug('111>>>'+vD2D.Vacancy__r.End_Time__c);
            // System.debug('112>>>'+vD2D.Id);
            // System.debug('113>>>'+vD2D.Vacancy_Date__c);
            // System.debug('114>>>'+vD2D.Closing_Report_Schedule__c);
            // System.debug('115>>>'+vD2D.Closing_Report_Schedule_Secondary__c);
            // System.debug('116>>>'+vD2D.End_Date_Time__c);
            // System.debug('117>>>'+vD2D.Shift__c);
            // System.debug('118>>>'+vD2D.Candidate_Assigned__c);

            // System.debug('editCreatevacancyRecord>>'+editCreatevacancyRecord);

            // if(editCreatevacancyRecord){
            //     if(!String.isBlank(vD2D.Id) ){
            //         Vacancy_D2D__c vD2D_edit = [SELECT Id,Name,Candidate_Assigned__c,Closing_Report_Schedule__c,Closing_Report_Schedule_Secondary__c,End_Date_Time__c,Shift__c,Start_Date_Time__c,Status__c,Vacancy__c,Vacancy__r.Name,Vacancy__r.Start_Time__c,Vacancy__r.End_Time__c,Vacancy_Date__c FROM Vacancy_D2D__c WHERE Id =: vD2D.Id LIMIT 1];
    
            //         vD2D_edit.Start_Date_Time__c = formatDateTimefromDate(vD2D.Vacancy_Date__c,vD2D.Vacancy__r.Start_Time__c);
            //         vD2D_edit.End_Date_Time__c = formatDateTimefromDate(vD2D.Vacancy_Date__c,vD2D.Vacancy__r.End_Time__c);
            //         System.debug(vD2D_edit);
            //         update vD2D_edit;

            //         Utility.AddConfirmMessage('Vacancy edited successfully.'); 
            //         editCreatevacancyRecord = false;
            //     }
            // }else{
            //     Utility.AddConfirmMessage('Start time and End time are overlaping.'); 
            // }
            
            // Redirect User to Vacancy Scheduler page.
            PageReference vacSchedulerPage = Page.TRS_FilterCandidates; 
            vacSchedulerPage.setRedirect(true);
            return vacSchedulerPage;
        }
        catch(Exception e) {
            Utility.AddErrorMessage('Exception occured '+e.getmessage()+'Line number '+e.getLineNumber());
            Database.rollback(sp);  
        }
        return null;
    }

    public void cancelEditVacancyCreation() {
        editCreatevacancyRecord = false;
        vD2D = null;
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

        PageReference vacSchedulerPage = Page.TRS_FilterCandidates; 
        vacSchedulerPage.setRedirect(true);
        return vacSchedulerPage;
    }

    public List<String> strings{get;set;}
    public List<String> strings_r(){
        List<String> t = new List<String>();
        return t;
    }

    public PageReference weekdayFunction(){
        System.debug('weekdayFunction');

        // System.debug(vacRecord.Applicable_Days__c);

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
}