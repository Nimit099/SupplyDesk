public with sharing class TimesheetPrintController_v2 {


    public String[] timesheetIds                           {get;set;}
    public transient List<TR1__Timesheet__c> timesheetList                      {get;set;}
    public transient List<TimesheetPrintWrapper> TimesheetPrintWrapperList          {get;set;}
    public integer LastPdf {get;set;}
    public Boolean isClient {get;set;}
    public User loggedInUser ;
    public Contact objContactPage {get;set; }

    // public integer getPageCount(){
    //     return TimesheetPrintWrapperList.size();
    // }

    public TimesheetPrintController_v2() {

        TimesheetPrintWrapperList = new List<TimesheetPrintWrapper> ();
        system.debug('TimesheetList: '+System.currentPageReference().getParameters().get('timesheetIds'));
        String[] timesheetIds = ((String)System.currentPageReference().getParameters().get('timesheetIds')).split(';');
        loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
        if(!test.isrunningtest()){
            objContactPage = [Select Community_Contact_Type__c,Name from Contact where Id =:loggedInUser.ContactId limit 1];


            if(objContactPage.Community_Contact_Type__c == 'Candidate' || objContactPage.Community_Contact_Type__c == 'C And C'  ){
                isClient = false;
            }else if(objContactPage.Community_Contact_Type__c == 'Client'){
                isClient = true;
            }
        }

        timesheetList = RC_AccessController.getTimesheetsByIds(timesheetIds);
        
        calculatehours();
    }

    public void calculatehours(){
        integer lstCount = 0;
        for(TR1__Timesheet__c timesheet : timesheetList) {
            TimesheetPrintWrapper wrapper = new TimesheetPrintWrapper(timesheet , ++lstCount)  ;
            for(TR1__Timesheet_Detail__c td : timesheet.TR1__Timecards__r){
                if(td.TR1__Double_Time_Hours__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Double_Time_Hours__c;
                if(td.TR1__Expenses__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Expenses__c;
                if(td.TR1__Overtime_Hours__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Overtime_Hours__c;
                if(td.TR1__Regular_Hours__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Regular_Hours__c;
                if(td.TR1__Sick_Time_Hours__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Sick_Time_Hours__c;
                if(td.TR1__Vacation_Hours__c != null)
                    wrapper.totalHours = wrapper.totalHours + td.TR1__Vacation_Hours__c;
            }
            TimesheetPrintWrapperList.add(wrapper);
        }
        LastPdf = TimesheetPrintWrapperList.size();
    }

    public class TimesheetPrintWrapper {

        public Double totalHours               {get;set;}
        public integer index                 {get;set;}
        public TR1__Timesheet__c timesheet      {get;set;}

        public TimesheetPrintWrapper(TR1__Timesheet__c timesheet,integer index) {
            this.timesheet =  timesheet;
            totalHours = 0;
            this.index = index;

        }
    }
}