public with sharing class ClosingReportButtonsCtrl{
    public TR1__Closing_Report__c currentcr{get;set;}
    public TR1__Closing_Report__c newcr{get;set;}
    public Boolean isSuccess{get;set;}
    private Set<String> accessibleNames = new Set<String>();
    public Id unknownAccountId;
    
    public Pagereference SaveEndAssignment(){
       //Added on 5/22 - Start
        Contact con = new Contact(Id = currentcr.TR1__Person_Placed__c);        
        con.TR1__Candidate_Status__c = 'Consult Hot';        
        if(TR1__TalentRoverProperties__c.getOrgDefaults() != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Candidate_Status_When_Assignment_Ended__c != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Candidate_Status_When_Assignment_Ended__c.trim() != '')
        	con.TR1__Candidate_Status__c = TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Candidate_Status_When_Assignment_Ended__c;
        	
        if(unknownAccountId != null) con.AccountId = unknownAccountId;
        
         //Added on 5/22 - End
        currentcr.TR1__Generate_Timesheet__c = false;
        currentcr.TR1__Receive_Timesheet_Email_Alerts__c = false;
        currentcr.TR1__Assignment_Ended__c = 'Yes';
        
        //Added on 30Mar2017
        List<Closing_Report_Schedule__c> CRS_List = [SELECT Id,Status__c FROM Closing_Report_Schedule__c WHERE Schedule_Date__c >: currentcr.TR1__End_Date__c AND Closing_Report__c =:currentcr.Id];
        for(Closing_Report_Schedule__c crs : CRS_List){
            crs.Status__c = 'Cancelled';
        }
        system.debug('=============================Con====='+con);
        
        try{
            update currentcr;
            //Added on 30Mar2017
            update CRS_List;
            //Added on 5/22 
            update con;
            this.isSuccess = true;
            return null;
        }
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getDMLMessage(0)));
            return null;
        }  
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }       
    }   

    public ClosingReportButtonsCtrl(ApexPages.StandardController controller) 
    {
        Map<String, Schema.SobjectField> fields = Schema.SobjectType.TR1__Closing_Report__c.fields.getMap();
        for (String s : fields.keySet()) {           
            if (fields.get(s).getDescribe().isAccessible()){
                accessibleNames.add(s);
            }            
        }
        if(!Test.isrunningtest())
        {
            controller.addFields(new List<String>(accessibleNames));
            this.currentcr = (TR1__Closing_Report__c)controller.getRecord();
        }
        else
        {
             Id recordId = controller.getRecord().Id;
             this.currentcr = [select Id,TR1__Generate_Timesheet__c ,TR1__Receive_Timesheet_Email_Alerts__c ,TR1__Conversion_Date__c,
                                TR1__Job_Percentage__c,TR1__Candidate_Percentage__c  ,TR1__Marketing_Percentage__c ,
                                TR1__Other_Percentage__c ,TR1__Other2_Percentage__c ,TR1__Assignment_Ended__c ,TR1__End_Date__c,TR1__Rate_Change_Effective_Date__c
                                , TR1__Salary__c,TR1__Job__c,TR1__Person_Placed__c from TR1__Closing_Report__c
                                where Id = :recordId ];
        
        }
        this.newcr = currentcr.clone();
        this.newcr.TR1__Start_Date__c = null;
        this.newcr.TR1__Booking_Date__c = null;
        this.isSuccess = false;
        
        try{
            Account acc = [SELECT Id FROM Account Where Name = 'Unknown'];
            this.unknownAccountId = acc.Id;
        }
        catch(Exception ex){}
    }
}