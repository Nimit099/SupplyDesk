public class CreateTimesheetExportController {
    public Boolean isDisableButton  {get;set;}   
    public Boolean enablePoller     {get;set;}   
    Timesheet_Export__c timesheetExport = new Timesheet_Export__c();
    public pagereference doTimesheetExport(){        
        try{            
            List<TR1__Timesheet__c> timesheetList =  [select Id,Name, TR1__Status__c, AWR_Days__c, Bundle_Work__c, TR1__Closing_Report__c, TR1__Job_Owner__c, TR1__Pay_Week_Ending__c, 
                                                      Unit_1__c, Unit_2__c, Unit_3__c,Charge_Rate_1__c , Charge_Rate_2__c , Charge_Rate_3__c ,Timesheet_Approved_By__c, 
                                                      TR1__Week_Ending__c, TR1__Client__c, TR1__Closing_Report__r.Work_Description__c, Client_account_number__c, TR1__Closing_Report__r.Office_name__c, Pay_Rate_1__c,
                                                      Pay_Rate_2__c, Pay_Rate_3__c, Payroll_number__c, Pay_Type_1__c, Pay_Type_2__c, Pay_Type_3__c, PO_number__c,Start_date__c,Timesheet_Week__c,Year__c,Tax_Year__c,End_date__c,JobOwnerId__c
                                                      FROM TR1__Timesheet__c where TR1__Status__c = 'Approved'  AND Timesheet_Export_Line_Item__c = null AND (Total_Days__c>0 OR Total_Half_Days__c>0 OR TR1__Total_Regular_Hours__c>0)];
            Map<Id,TR1__Timesheet__c> timesheetMap = new Map<Id,TR1__Timesheet__c>();
            List<Timesheet_Export_Line_Item__c > teliList = new List<Timesheet_Export_Line_Item__c>();
            
            if(timesheetList.size()>0){      
                enablePoller = true;
                isDisableButton = true;
                timesheetExport = new Timesheet_Export__c();
                insert timesheetExport;
                
                for(TR1__Timesheet__c ts : timesheetList){
                    ID jobOwnerID = (Id)ts.JobOwnerId__c;
                    Timesheet_Export_Line_Item__c timesheetExpLineItem = new Timesheet_Export_Line_Item__c(
                        Timesheet_Export__c = timesheetExport.Id,
                        Timesheet__c = ts.Id,
                        AWR_Days__c = ts.AWR_Days__c == 0 ? null : ts.AWR_Days__c,
                        Timesheet_Approved_By__c = ts.Timesheet_Approved_By__c,
                        Bundle_Work__c = ts.Bundle_Work__c,
                        Closing_Report__c  = ts.TR1__Closing_Report__c ,
                        Consultant_User__c = jobOwnerID,
                        Pay_Week_Ending__c = ts.TR1__Pay_Week_Ending__c, 
                        Unit_1__c = ts.Unit_1__c == 0 ? null : ts.Unit_1__c, 
                        Unit_2__c = ts.Unit_2__c == 0 ? null : ts.Unit_2__c, 
                        Unit_3__c = ts.Unit_3__c == 0 ? null : ts.Unit_3__c, 
                        Work_Description__c  = ts.TR1__Closing_Report__r.Work_Description__c == null ? null : ts.TR1__Closing_Report__r.Work_Description__c,          
                        Account__c = ts.TR1__Client__c,
                        Charge_Rate_1__c = ts.Charge_Rate_1__c == 0 ? null : ts.Charge_Rate_1__c,
                        Charge_Rate_2__c = ts.Charge_Rate_2__c == 0 ? null : ts.Charge_Rate_2__c,
                        Charge_Rate_3__c = ts.Charge_Rate_3__c == 0 ? null : ts.Charge_Rate_3__c,                        
                        Client_account_number__c = ts.Client_account_number__c == null ? null : ts.Client_account_number__c,
                        Office_name__c = ts.TR1__Closing_Report__r.Office_name__c == null ? null : ts.TR1__Closing_Report__r.Office_name__c,
                        Pay_Rate_1__c = ts.Pay_Rate_1__c == 0 ? null : ts.Pay_Rate_1__c,
                        Pay_Rate_2__c = ts.Pay_Rate_2__c == 0 ? null : ts.Pay_Rate_2__c,                        
                        Pay_Rate_3__c = ts.Pay_Rate_3__c == 0 ? null : ts.Pay_Rate_3__c,
                        Payroll_number__c = ts.Payroll_number__c == null ? null : ts.Payroll_number__c,
                        Pay_Type_1__c = ts.Pay_Type_1__c == null ? null : ts.Pay_Type_1__c,
                        Pay_Type_2__c = ts.Pay_Type_2__c == null ? null : ts.Pay_Type_2__c,
                        Pay_Type_3__c = ts.Pay_Type_3__c == null ? null : ts.Pay_Type_3__c,
                        PO_number__c = ts.PO_number__c == null ? null : ts.PO_number__c,
                        Start_date__c = ts.Start_date__c,
                        Timesheet_Week__c = ts.Timesheet_Week__c == 0 ? null : ts.Timesheet_Week__c,
                        Year__c = ts.Tax_Year__c == null ? null : ts.Tax_Year__c, 
                        Week_Ending__c = ts.TR1__Week_Ending__c,
                        End_Date__c = ts.End_date__c
                    );                                        
                    teliList.add(timesheetExpLineItem); 
                    timesheetMap.put(ts.Id,ts );
                }
                
                if(teliList.size()>0){
                    insert teliList;
                    doTimesheetUpdate(teliList,  timesheetMap);
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There are no eligible Timesheet(s) to create Timesheet Export.'));
                isDisableButton = true;
                enablePoller = false;
                return null;
            }
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Unexpected Error occured. Message : '+ e.getmessage()+'. '+ 'Line number : ' +e.getlinenumber()));
            enablePoller = false;
            isDisableButton = false;
            return null;
        }
        return null;
    }
    
    public void doTimesheetUpdate(List<Timesheet_Export_Line_Item__c> teliList,  Map<Id,TR1__Timesheet__c> timesheetMap){
        List<TR1__Timesheet__c> timesheetListToUpdate = new List<TR1__Timesheet__c>();
        for(Timesheet_Export_Line_Item__c t : teliList){
            TR1__Timesheet__c tempTs = timesheetMap.get(t.Timesheet__c);
            tempTs.Timesheet_Export_Line_Item__c = t.Id;
            tempTs.UpdateFromExport__c = True;
            timesheetListToUpdate.add(tempTs);
        }
        
        if(timesheetListToUpdate.size()>0){
            integer i = 1;
            integer batchSize = String.isNotBlank(Label.BatchSizeForTimesheetUpdateQueueableClass) ? Integer.valueOf(Label.BatchSizeForTimesheetUpdateQueueableClass) : 50;
            for(List<SObject> entityList : sliceList(timesheetListToUpdate,batchSize)){
                ID jobID = System.enqueueJob(new BulkTimesheetUpdateQueueable(entityList,(i++)));
            }
        }
    }
    
    public static string redirectToReport(Id timesheetId){        
       	List<Timesheet_Export__c> TimesheetList = [Select Name, Id from Timesheet_Export__c where Id = :timesheetId limit 1];
		return TimesheetList[0].Name;
    } 
  
	Integer functionCallCount = 0;
	public PageReference checkAsyncJobStatus () {
	    functionCallCount++;
        ApexClass queueuableClass = [
          SELECT Id, Name
          FROM ApexClass
          WHERE Name = 'BulkTimesheetUpdateQueueable'
        ];
    
        Set<String> openStatuses = new Set<String>();
        openStatuses.add('Holding');
        openStatuses.add('Queued');
        openStatuses.add('Preparing');
        openStatuses.add('Processing');
    
        List<AsyncApexJob> queueableJobs = [
          SELECT Status
          FROM AsyncApexJob
          WHERE ApexClassId = : queueuableClass.Id
          AND Status IN : openStatuses
        ];
    
        isDisableButton = !queueableJobs.isEmpty();
        
        if(!isDisableButton && functionCallCount>1 && timesheetExport.Id!=null) {
            return new pagereference('/00O580000041trZ?pv0=' + redirectToReport(timesheetExport.Id)); 
        }
        else
            return null;
	}
	
	public static List<List<SObject>> sliceList(List<SObject> objs, Integer size){
        List<List<SObject>> resultList = new List<List<SObject>>();
        Integer numberOfChunks = objs.size() / size;
        for(Integer j = 0; j < numberOfChunks; j++ ){
            List<SObject> someList = new List<SObject>();
            for(Integer i = j * size; i < (j+1) * size; i++){
                someList.add(objs[i]);
            }
            resultList.add(someList);
        }
        if(numberOfChunks * size < objs.size()){
            List<SObject> aList = new List<SObject>();
            for(Integer k = numberOfChunks * size ; k < objs.size(); k++){
                aList.add(objs[k]);
            }
            resultList.add(aList);
        }
        return resultList;
  }
}