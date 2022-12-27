public  class TimesheetPrintController_v1 {
  
  
    public String[] timesheetIds                           {get;set;}  
    public transient List<TR1__Timesheet__c> timesheetList                      {get;set;}
    public transient List<TimesheetPrintWrapper> TimesheetPrintWrapperList          {get;set;}
    public integer LastPdf {get;set;}
    
    public integer getPageCount(){
        return TimesheetPrintWrapperList.size();
    } 
  
    public TimesheetPrintController_v1() {
    
        TimesheetPrintWrapperList = new List<TimesheetPrintWrapper> ();
        system.debug('TimesheetList: '+System.currentPageReference().getParameters().get('timesheetIds'));
        String[] timesheetIds = ((String)System.currentPageReference().getParameters().get('timesheetIds')).split(';');
     
        timesheetList = [Select t.TR1__Consultant_Name__c, t.TR1__Consultants_Notes__c,  t.TR1__Status__c, t.TR1__Week_Ending__c, t.TR1__Assignment_Continuing__c, 
                            t.TR1__Recruiter__c, TR1__Total_Hours__c, TR1__Total_Regular_Hours__c, TR1__Total_Overtime_Hours__c, TR1__Total_Double_Time_Hours__c, 
                            TR1__Total_Sick_Time_Hours__c, TR1__Total_Vacation_Hours__c,TR1__Approver__c, t.TR1__Approvers_Notes__c, t.Id, t.TR1__Job_Order__c,
                            Timesheet_Approved_Date_Time__c, Timesheet_Approved_By__c, Name, TR1__Total_Days_Worked__c,
                            t.TR1__Client_Name__c,t.TR1__Client__r.BillingPostalCode ,
                            t.TR1__Job_Order__r.name,t.TR1__Job_Order__r.TR1__Job_Title__c,t.TR1__Job_Order__r.Sector1__c ,t.TR1__Closing_Report__r.TR1__Job__r.TR1__Account__r.RecordType.Name,
                            t.TR1__Closing_Report__c,t.TR1__Closing_Report__r.TR1__Job_Credit__c,t.TR1__Closing_Report__r.TR1__Job_Credit__r.name,t.TR1__Closing_Report__r.TR1__PO_Number__c,
                            TR1__Approver__r.name, Timesheet_Approved_By__r.Name,(Select TR1__Date__c, TR1__Day__c, TR1__Double_Time_Hours__c, Id,
                            TR1__Overtime_Hours__c, TR1__Regular_Hours__c, TR1__Sick_Time_Hours__c,TR1__Timesheet__c, TR1__Vacation_Hours__c, TR1__Expenses__c,
                            Start_Time__c,End_Time__c
                            From TR1__Timecards__r where Closing_Report_Schedule__c != null order by TR1__date__c asc) from TR1__Timesheet__c t where id in : timesheetIds];       

        
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