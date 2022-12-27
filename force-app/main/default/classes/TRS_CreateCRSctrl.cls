public class TRS_CreateCRSctrl {
    Public TR1__Job__c objVacc{get;set;}
    Public TR1__Closing_Report__c objCR{get;set;}
    Public Closing_Report_Schedule__c objCRS{get;set;}
    Public Date selectedDate {get;set;}
    Public String contact1 {get;set;} 
    Public List<Candidate_Availability__c> canAvail {get;set;}
    Public List <Vacancy_D2D__c> vacAvail  {get;set;}
    Public String jsdID ;
    Public String csdID ;
    Public List <TR1__Closing_Report__c> objCRTemp;
    Public Boolean noRecordSelected ;
    Public TRS_CreateCRSctrl(ApexPages.StandardController ctrl) {
        objCRS = new Closing_Report_Schedule__c ();
        objCR= new TR1__Closing_Report__c();
        objCRTemp= new List <TR1__Closing_Report__c>();
        canAvail  = new List<Candidate_Availability__c>();
        vacAvail= new List<Vacancy_D2D__c>();
        if(ctrl == null || ctrl.getId() == null) {
          noRecordSelected = true;
          Utility.AddErrormessage('No Vacancy Selected');
          return;
        }
        else{
          String vaccId = ctrl.getId();
          objVacc = [Select Id,Name,TR1__Account__r.BillingPostalCode,TR1__Account__r.BillingCity,TR1__Account__r.BillingStreet,TR1__Account__c,Timesheet_Approver__c,TR1__Closed_Date__c,TR1__Account__r.Agreed_D2D_Charge_Rate__c,TR1__Account__r.Invoice_Contact__c from TR1__Job__c where Id=:vaccId];
          //objCRS.Closing_Report__c = ctrl.getId();
        }
        //selectedDate  = Date.today();
        jsdID = '';
        csdID = '';
    }
    public PageReference Cancel() {
        return new PageReference('/'+objVacc.Id).setRedirect(true);
    }
    public PageReference RedirectTocalendar() { 
         if(!string.isBlank(objCR.TR1__Person_Placed__c))
            return new PageReference('/apex/TRS_CandidateCalendar?contactId='+objCR.TR1__Person_Placed__c);
        else{
            Utility.AddErrormessage('Please select person placed first.');
            return null;
        }
            
    }
    public PageReference FetchCandidateId() { 
        if(Apexpages.currentPage().getParameters().containsKey('contact1') && ApexPages.currentPage().getParameters().get('contact1 ') != '')
            {
              contact1 = ApexPages.currentPage().getParameters().get('contact1 ');
            }
        return null;
    }
    public PageReference saveClosingReportSch() {
        try{
                // Utility.AddErrormessage('Person placed .'+objCR.TR1__Person_Placed__c);
                // return null;
                List<Closing_Report_Schedule__c> crsList =new List<Closing_Report_Schedule__c>();
                canAvail = [Select Id ,Name, Status__c,Start_Date_Time__c,End_Date_Time__c,Start_Date__c,Candidate__c from Candidate_Availability__c where Start_Date__c= :objCRS.Schedule_Date__c and  Candidate__c = :objCR.TR1__Person_Placed__c];
                vacAvail = [Select Id ,Name, Shift__c,Vacancy_Date__c,Start_Date_Time__c,End_Date_Time__c,Vacancy__c from Vacancy_D2D__c where Vacancy_Date__c= :objCRS.Schedule_Date__c and Vacancy__c = :objVacc.Id  ];
                objCRTemp = [Select Id,Name,TR1__Job__c,TR1__Person_Placed__c,TR1__End_Date__c,Contract_End_Date__c,TR1__Start_Date__c from TR1__Closing_Report__c where TR1__Person_Placed__c =:objCR.TR1__Person_Placed__c AND  TR1__Job__c =:objVacc.Id AND TR1__Start_Date__c<= :objCRS.Schedule_Date__c AND TR1__End_Date__c >= :objCRS.Schedule_Date__c limit 1 ];
                if(objCRTemp.size()>0){
                     if(canAvail.size()>0){
                       if(vacAvail.size()==0){
                            for(Candidate_Availability__c candt: canAvail){                         
                                    Vacancy_D2D__c vacc= new Vacancy_D2D__c(Status__c='Open',Shift__c = 'Hourly',Start_Date_Time__c=candt.Start_Date_Time__c,End_Date_Time__c=candt.End_Date_Time__c,Vacancy__c=objVacc.Id,Vacancy_Date__c=candt.Start_Date__c);
                                    vacAvail.add(vacc);
                             }
                         insert vacAvail;
                        }
                         
                        for(Candidate_Availability__c candt: canAvail){
                            for(Vacancy_D2D__c vcc: vacAvail){
                                if((candt.Start_Date_Time__c <= vcc.Start_Date_Time__c && vcc.End_Date_Time__c <= candt.End_Date_Time__c)&&(candt.Start_Date_Time__c !=Null&& vcc.Start_Date_Time__c!=Null  && vcc.End_Date_Time__c!=Null&&candt.End_Date_Time__c!=Null)){
                                    Closing_Report_Schedule__c crs1= new Closing_Report_Schedule__c();
                                    crs1.Closing_Report__c  =objCRTemp[0].Id;
                                    crs1.Schedule_Date__c = objCRS.Schedule_Date__c;
                                    crs1.Candidate_Availability__c = candt.Id;
                                    crs1.Vacancy_Schedule__c = vcc.Id;
                                    crs1.Status__c  = 'Booked';
                                    crs1.Trial_Day__c = True;
                                    crsList.add(crs1);
                                }else{
                                    Continue;      
                                }
                            }
                        }
                        if(crsList.size()>0)
                        insert crsList;
                        else{
                            Utility.AddErrormessage('No Matching Available slots found for job/candidate on this closing report .');
                                    return null;  
                        }
                        return new PageReference('/'+objCRTemp[0].Id).setRedirect(true);
                    }else{
                        Utility.AddErrormessage('Booking failed as job/Candidate does not have availability on date you selected .');
                        return null;        
                    }     
                }else{
                    TR1__Closing_Report__c closingReport = new TR1__Closing_Report__c();
                    closingReport.TR1__Job__c = objVacc.Id;
                    //closingReport.Pay_Type__c = vacancy.Timesheet_Pay_Type__c;
                    closingReport.TR1__Person_Placed__c = objCR.TR1__Person_Placed__c;
                    closingReport.Invoicing_Person__c = objVacc.TR1__Account__r.Invoice_Contact__c;
                    closingReport.TR1__Start_Date__c = objCRS.Schedule_Date__c;
                    closingReport.TR1__End_Date__c = objCRS.Schedule_Date__c;
                    closingReport.RecordTypeId = Utility.CONSULTING_RTID;
                    closingReport.TR1__Bill_Rate__c = objVacc.TR1__Account__r.Agreed_D2D_Charge_Rate__c;
                    closingReport.TR1__Job_Credit__c = userinfo.getUserId();
                    //closingReport.TR1__Pay_Rate__c = payRate;
                    closingReport.TR1__Job_Percentage__c = 100;
                    closingReport.TR1__Timesheet_Approver__c = objVacc.Timesheet_Approver__c;
                    closingReport.TR1__Account__c = objVacc.TR1__Account__c;
                    closingReport.TR1__Billing_Street__c = objVacc.TR1__Account__r.BillingStreet; 
                    closingReport.TR1__Billing_City__c = objVacc.TR1__Account__r.BillingCity;
                    closingReport.TR1__Billing_Zip_Code__c = objVacc.TR1__Account__r.BillingPostalCode;
                    closingReport.Maximum_Day_Pay_Rate__c = objCR.Maximum_Day_Pay_Rate__c ;
                    closingReport.Maximum_Day_Charge_Rate__c = objCR.Maximum_Day_Charge_Rate__c;
                    closingReport.Maximum_Half_Day_Pay_Rate__c = objCR.Maximum_Half_Day_Pay_Rate__c ;
                    closingReport.Maximum_Half_Day_Charge_Rate__c = objCR.Maximum_Half_Day_Charge_Rate__c;
                    closingReport.Maximum_Hour_Pay_Rate__c = objCR.Maximum_Hour_Pay_Rate__c;
                    closingReport.Maximum_Hour_Charge_Rate__c = objCR.Maximum_Hour_Charge_Rate__c;
                    objCRTemp.add(closingReport);
                    ClosingReportTriggerHelper.FromJobboard = True;
                    insert objCRTemp;
                    if(canAvail.size()>0 ){
                        if(vacAvail.size()==0){
                            for(Candidate_Availability__c candt: canAvail){                         
                                    Vacancy_D2D__c vacc= new Vacancy_D2D__c(Status__c='Open',Shift__c = 'Hourly',Start_Date_Time__c=candt.Start_Date_Time__c,End_Date_Time__c=candt.End_Date_Time__c,Vacancy__c=objVacc.Id,Vacancy_Date__c=candt.Start_Date__c);
                                    vacAvail.add(vacc);
                             }
                         insert vacAvail;
                        }
                        for(Candidate_Availability__c candt: canAvail){
                            for(Vacancy_D2D__c vcc: vacAvail){
                                if((candt.Start_Date_Time__c <= vcc.Start_Date_Time__c && vcc.End_Date_Time__c <= candt.End_Date_Time__c)&&(candt.Start_Date_Time__c !=Null&& vcc.Start_Date_Time__c!=Null  && vcc.End_Date_Time__c!=Null&&candt.End_Date_Time__c!=Null)){
                                    Closing_Report_Schedule__c crs1= new Closing_Report_Schedule__c();
                                    crs1.Closing_Report__c  = objCRTemp[0].Id;
                                    crs1.Schedule_Date__c = objCRS.Schedule_Date__c;
                                    crs1.Candidate_Availability__c = candt.Id;
                                    crs1.Vacancy_Schedule__c = vcc.Id;
                                    crs1.Status__c  = 'Booked';
                                    crs1.Trial_Day__c = True;
                                    crsList.add(crs1);
                                }else{
                                    Continue;      
                                }
                            }
                        }
                        if(crsList.size()>0)
                        insert crsList;
                        else{
                            Utility.AddErrormessage('No Matching Available slots found for job/candidate on this closing report .');
                                    return null;  
                        }
                        //objCRS.Schedule_Date__c = selectedDate;
                        
                        return new PageReference('/'+objCRTemp[0].Id).setRedirect(true);
                    }else{
                        Utility.AddErrormessage('Booking failed as job/Candidate does not have availability on date you selected .');
                        return null;        
                    }
                }
               
                
        }catch(Exception ex){
            Utility.AddErrormessage('Exception occured '+ex.getmessage()+'Line Number '+ex.getLinenumber());
            return null;
        }
    }

}