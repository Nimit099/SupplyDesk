/**
 * Class which does the query and gets all the Data
**/
public with sharing class BulkInvoiceClass {
    
    public static List<BulkInvoiceDetails> getBulkInvoiceDetails(String accountIds, Set<String> closingReportIds, String value,
                                                                    String invoiceDate, String recordType, String weekEndDate, String startDate, 
                                                                    String endDate, String InvoiceType){
        List<BulkInvoiceDetails> invoiceList = new List<BulkInvoiceDetails>();
        String invoiceNumber ;
        String weekEndingDate;
        String  ponumber;
        String Name;
        String PayType;
        List<TR1__Timesheet__c> timesheets;
        Date Duedate;
        String PaymentTerms; 
        Date invDate;
        List<Account> accountList; 
        Map<Id , Map<Id , List<TR1__Timesheet__c>>> AccountCRTmap = new Map<Id , Map<Id , List<TR1__Timesheet__c>>>();
        set<id>accIdset = new set<id>();
        
        String[] ids = accountIds.split(',');
        
        Integer InvValue;
        if(String.isNotBlank(value))
            InvValue = Integer.valueOf(value);
        else
            InvValue = getLastInvoiceNumber();
         
        if (accountIds != null) {
            invoiceDate = ApexPages.currentPage().getParameters().get('invoiceDate');
            if(String.isNotBlank(invoiceDate)){
                invDate = date.valueOf(invoiceDate); 
            }
            
            List<String> closingReportrecordType = new List<String>();
             
             if(InvoiceType == 'Single'){
               accountList = [select Name, BillingCity, BillingState, Registered_Postal_Code__c, Registered_Street_Address__c, Registered_Street_Address2__c,Invoice_Contact__r.Name,
                                  Payment_Terms__c, VAT_Number__c, RecordType.Name, Sales_Ledger_Number__c, D2D_Contact__r.Name , D2D_Contact__r.Phone, BillingCountry, BillingPostalCode, BillingStreet
                                  from account 
                                  where Id in :ids and (Invoice_Type__c = '' or Invoice_Type__c = 'Single')] ;
             }
             else {
               accountList = [select Name, BillingCity, BillingState, Registered_Postal_Code__c, Registered_Street_Address__c, Registered_Street_Address2__c,Invoice_Contact__r.Name,
                                  Payment_Terms__c, VAT_Number__c, RecordType.Name, Sales_Ledger_Number__c, D2D_Contact__r.Name , D2D_Contact__r.Phone, BillingCountry, BillingPostalCode, BillingStreet
                                  from account 
                                  where Id in :ids and Invoice_Type__c = 'Consolidated'] ;  
             }
            
            
            weekEndDate =  ApexPages.currentPage().getParameters().get('weekEndDate');
            timesheets = new List<TR1__Timesheet__c>();
            invoiceList = new List<BulkInvoiceDetails>(); 
            
            // Map of Account Id with corresponding list of Closing Reports
            Map<Id, List<TR1__Closing_Report__c>> accountClosingReportMap = new Map<Id, List<TR1__Closing_Report__c>>();
            // Map of Account Id with corresponding list of Timesheets
            Map<Id, List<TR1__Timesheet__c >> accountTimesheetMap = new Map<Id, List<TR1__Timesheet__c >>();  
            // Map of Closing Report corrosponding every timesheet
            Map<Id, List<TR1__Timesheet__c>> closingTimesheetMap = new Map<Id, List<TR1__Timesheet__c>>();
            
            if(recordType == Invoicing_Constants.PERMANENT_CONVERSION) {
                // Adding values to the Map for Permanent/Conversion Records
                for(TR1__Closing_Report__c closingReport : getClosingReportRecords(startDate, endDate, ids, closingReportIds, recordType)){
                    if(accountClosingReportMap.containsKey(closingReport.TR1__Account__c))
                        accountClosingReportMap.get(closingReport.TR1__Account__c).add(closingReport);
                    else 
                        accountClosingReportMap.put(closingReport.TR1__Account__c, new List<TR1__Closing_Report__c>{closingReport});
                }
            }
            else if(recordType == Invoicing_Constants.CONSULTING) {
                
                List<TR1__Timesheet__c> timesheetList = getTimesheetRecords(weekEndDate, ids, closingReportIds);
                Set<String> closingReportIdSet = new Set<String>();
                for(TR1__Timesheet__c timesheet : timesheetList) {
                    if(timesheet.TR1__Closing_Report__c != null)
                        closingReportIdSet.add(timesheet.TR1__Closing_Report__c);
                }
                
                // Creating a Map of account-CR-Timesheet
                
                for(TR1__Timesheet__c timesheet :timesheetList){
              
              Map<Id , List<TR1__Timesheet__c>> closingTimeshetMap = new Map<Id , List<TR1__Timesheet__c>>();
              
              if(AccountCRTmap.containsKey(timesheet.TR1__Closing_Report__r.TR1__Account__c)){
                closingTimeshetMap = AccountCRTmap.get(timesheet.TR1__Closing_Report__r.TR1__Account__c);
                
                if(closingTimeshetMap.containsKey(timesheet.TR1__Closing_Report__c)){
                  List<TR1__Timesheet__c> tempList = closingTimeshetMap.get(timesheet.TR1__Closing_Report__c);
                  tempList.add(Timesheet);
                  closingTimeshetMap.put(timesheet.TR1__Closing_Report__c ,tempList);
                }
                else {
                  List<TR1__Timesheet__c> tempList = new List<TR1__Timesheet__c>();
                  tempList.add(Timesheet);
                  closingTimeshetMap.put(timesheet.TR1__Closing_Report__c ,tempList);  
                }
                AccountCRTmap.put(timesheet.TR1__Closing_Report__r.TR1__Account__c, closingTimeshetMap);
              }
              else {
                List<TR1__Timesheet__c> tempList = new List<TR1__Timesheet__c>();
                tempList.add(Timesheet);
                closingTimeshetMap.put(timesheet.TR1__Closing_Report__c ,tempList);
                AccountCRTmap.put(timesheet.TR1__Closing_Report__r.TR1__Account__c, closingTimeshetMap);
                accIdset.add(timesheet.TR1__Closing_Report__r.TR1__Account__c);
              }  
            }
                
                // Adding values to the Map for Consulting
                for(TR1__Closing_Report__c closingReport : getClosingReportRecords(null, null, ids, closingReportIdSet, recordType)){
                    if(accountClosingReportMap.containsKey(closingReport.TR1__Account__c))
                        accountClosingReportMap.get(closingReport.TR1__Account__c).add(closingReport);
                    else 
                        accountClosingReportMap.put(closingReport.TR1__Account__c, new List<TR1__Closing_Report__c>{closingReport});
                }
                
                // Adding values to closingTimesheet Map
                for(TR1__Timesheet__c timesheet : timesheetList){
                    if(closingTimesheetMap.containsKey(timesheet.TR1__Closing_Report__c))
                        closingTimesheetMap.get(timesheet.TR1__Closing_Report__c).add(timesheet);
                    else
                        closingTimesheetMap.put(timesheet.TR1__Closing_Report__c , new List<TR1__Timesheet__c>{timesheet});         
                }   
            }   
            
            map<String, BulkInvoiceDetails> invoiceMap = new map<String, BulkInvoiceDetails>(); 
            
            // Looping Through the selected Accounts         
            for(Account acc : accountList){
               List<TR1__Closing_Report__c> crsList = new List<TR1__Closing_Report__c>();
              map<Id , List<TR1__Timesheet__c>> tempCRtimesheetmap = new Map<Id , List<TR1__Timesheet__c>>();
              tempCRtimesheetmap = AccountCRTmap.get(acc.Id);
        List<TR1__Timesheet__c> timesheetListTemp = new List<TR1__Timesheet__c>();  
                
        PaymentTerms = acc.Payment_Terms__c;    
                dueDate = invDate;

                // Carrying out Calculations for Consulting Job Type
                if(recordType == Invoicing_Constants.CONSULTING) {          
                    
                    List<TR1__Timesheet__c> timesheetList = new List<TR1__Timesheet__c>();
                        
                    if(acc.RecordType.Name == 'Education'){
                        duedate =  dueDate.addDays(14);   
                    }
                    else {
                      String temp = acc.Payment_Terms__c.subString(0,2);
                      Integer val = Integer.valueOf(temp);
                        duedate =  dueDate.addDays(val);
                    } 
                    
                    decimal Billrate;
                    decimal regularHours;
                    decimal regularBilled;
                    decimal OtHours;
                    decimal OTBilled;
                    decimal DTHours;
                    decimal DTBilled;
                    decimal Bonus;
                    decimal invoiceTotal;
                    string periodTo;
                    string periodFrom;
                    Boolean isConsolidated;
          isConsolidated = false;  
                    
                    if(accountClosingReportMap.containsKey(acc.id)) {
                        for(TR1__Closing_Report__c closingReport : accountClosingReportMap.get(acc.id)){
                          
                            if(closingTimesheetMap.containsKey(closingReport.id)){
                                
                                invoiceNumber = 'INV C - ' + InvValue;
                                PayType = closingReport.Timesheet_Pay_Type__c;
                                
                                ponumber = closingReport.TR1__PO_Number__c;
                          if(InvoiceType== 'Single'){
                            Billrate = 0;
                                  regularHours = 0;
                                  regularBilled =0;
                                  OtHours = 0;
                                  OTBilled = 0;
                                  DTHours = 0;
                                  DTBilled = 0;
                                  Bonus = 0;
                                  invoiceTotal = 0;
                                  periodTo = '';
                                  periodFrom = '';
                                  
                          }
                          else {
                            if(isConsolidated != true){
                              Billrate = 0;
                                    regularHours = 0;
                                    regularBilled =0;
                                    OtHours = 0;
                                    OTBilled = 0;
                                    DTHours = 0;
                                    DTBilled = 0;
                                    Bonus = 0;
                                    invoiceTotal = 0;
                                    periodTo = '';
                                    periodFrom = '';
                                    isConsolidated = true;
                            }
                          }
                          if(InvoiceType== 'Single'){
                            timesheetListTemp = tempCRtimesheetmap.get(closingReport.id);
                          }
                          else {
                            timesheetListTemp.addall(tempCRtimesheetmap.get(closingReport.id));      
                          }
                          
                                for(TR1__Timesheet__c timesheet : tempCRtimesheetmap.get(closingReport.id)){
                                    if (timesheet.Total_Bill_Amount__c != null) {  
                                        invoiceTotal += timesheet.TR1__Invoice_Amount__c;
                                    }
                                    if (timesheet.TR1__Total_Regular_Hours__c != null) {
                                        regularHours += timesheet.TR1__Total_Regular_Hours__c;
                                        Decimal temp = timesheet.TR1__Adjusted_Bill_Rate__c * timesheet.TR1__Total_Regular_Hours__c;
                                        regularBilled += temp.setScale(2, RoundingMode.HALF_UP);
                                    }
                                    if (timesheet.TR1__Total_Overtime_Hours__c != null) {
                                        OtHours += timesheet.TR1__Total_Overtime_Hours__c;
                                        Decimal temp = timesheet.TR1__Total_Overtime_Hours__c * timesheet.TR1__OT_Bill_Rate__c;
                                        OTBilled += temp.setScale(2, RoundingMode.HALF_UP);
                                    }
                                    if (timesheet.TR1__Total_Double_Time_Hours__c != null) {
                                        DTHours += timesheet.TR1__Total_Double_Time_Hours__c;
                                        Decimal temp = timesheet.TR1__Total_Double_Time_Hours__c * timesheet.TR1__DT_Bill_Rate__c;
                                        DTBilled += temp.setScale(2, RoundingMode.HALF_UP);
                                    }
                                    if (timesheet.TR1__Bonus__c != null) {
                                        Bonus += timesheet.TR1__Bonus__c;
                                    }
                                    //Calculating PeriodFrom and PeriodTo per Consulting Report
                                    if(timesheet.TR1__Closing_Report__r.Invoicing_Period__c == Invoicing_Constants.WEEKLY){
                                        periodTo   = Date.valueOf(weekEndDate).format();
                                        periodFrom = Date.valueOf(weekEndDate).addDays(-6).format();
                                    }
                                    else if (timesheet.TR1__Closing_Report__r.Invoicing_Period__c == Invoicing_Constants.BIWEEKLY){
                                        periodTo   = Date.valueOf(weekEndDate).format();
                                        periodFrom = Date.valueOf(weekEndDate).addDays(-13).format();
                                    }
                                    else {
                                        periodTo   = Date.valueOf(weekEndDate).format();
                                        periodFrom = Date.valueOf(weekEndDate).addmonths(-1).format();
                                    }
                                }
                                
                                crsList.add(closingReport);
                                
                                
                                if(InvoiceType == 'Single'){
                                  BulkInvoiceDetails temp = new BulkInvoiceDetails(regularHours, regularBilled, OtHours, OTBilled,
                                                                          DTHours, DTBilled, Bonus, invoiceTotal, 
                                                                          invoiceNumber, weekEndingDate, acc, 
                                                                          DueDate, invDate, new list<TR1__Closing_Report__c>{closingReport}, timesheetListTemp ,periodFrom,periodTo,PayType,ponumber); 
                                  
                                  invoiceMap.put(acc.Name+'-'+closingReport.id, temp);
                            }
                            }
                        }
                        if(InvoiceType == 'Consolidated'){
                          BulkInvoiceDetails temp = new BulkInvoiceDetails(regularHours, regularBilled, OtHours, OTBilled,
                                                                        DTHours, DTBilled, Bonus, invoiceTotal, 
                                                                        invoiceNumber, weekEndingDate, acc, 
                                                                        DueDate, invDate, crsList, timesheetListTemp ,periodFrom,periodTo,PayType,ponumber);
                                
                            invoiceMap.put(acc.Name, temp);
                        } 
                    }               
                }
                else if(recordType == Invoicing_Constants.PERMANENT_CONVERSION){
                    // Carrying out calculations for Permanent/Conversion Job Type
                    if(accountClosingReportMap.containsKey(acc.id)){
                     //   Decimal totalAmount = 0;
                        List<TR1__Closing_Report__c> closingRepList = new List<TR1__Closing_Report__c>();
                        string periodFrom = '';
                        string periodTo = '';
                        decimal invoiceTotal;
                        Boolean isConsolidated;
                        
                        for(TR1__Closing_Report__c closingRep : accountClosingReportMap.get(acc.id)) {
                            invoiceNumber = 'INV P- ' + InvValue;
                           
                           if(InvoiceType == 'Single'){
                             invoiceTotal = 0;  
                           }
                           else {
                             if(isConsolidated != true){
                               invoiceTotal = 0;
                               isConsolidated = true;
                             }
                           }    
                            
                            dueDate = Date.valueOf(invoiceDate);
                            
                            if(acc.RecordType.Name == 'Education'){
                                DueDate =  dueDate.addDays(14);   
                            }
                            else {
                              String temp = acc.Payment_Terms__c.subString(0,2);
                          Integer val = Integer.valueOf(temp);
                            duedate =  dueDate.addDays(val);
                            }       
                            
                            
                            ponumber = closingRep.TR1__PO_Number__c;
                            if(closingRep.RecordType.Name == 'Retained' || closingRep.RecordType.Name == 'Retained Invoice' ){
                                if (closingRep.TR1__Retained_Fee_Amount__c  != null) {
                                invoiceTotal += closingRep.TR1__Retained_Fee_Amount__c ;
                                }
                            }
                            else if (closingRep.TR1__Adjusted_Fee_Amount__c != null) {
                                invoiceTotal += closingRep.TR1__Adjusted_Fee_Amount__c;
                            }
                            periodTo   = Date.valueOf(EndDate).format();
                            periodFrom = Date.valueOf(startDate).format();
                            
                            closingRepList.add(closingRep);
                            
                            if(InvoiceType == 'Single'){
                              BulkInvoiceDetails temp = new BulkInvoiceDetails(invoiceTotal, invoiceNumber, weekEndingDate, acc, 
                                                                    DueDate, invDate, new list<TR1__Closing_Report__c>{closingRep} ,ponumber, true ,periodFrom ,periodTo);
 
                 invoiceMap.put(acc.Name+'-'+closingRep.id, temp);  
                            }
                        }
                        
                        if(InvoiceType == 'Consolidated'){
                        BulkInvoiceDetails temp = new BulkInvoiceDetails(invoiceTotal, invoiceNumber, weekEndingDate, acc, 
                            DueDate, invDate, closingRepList ,ponumber, true ,periodFrom ,periodTo);
 
               invoiceMap.put(acc.Name, temp); 
             }
                    }   
                }                           
            }
            
            if(!invoiceMap.isEmpty()) {
                list<String> accNameList = new list<String>();
                accNameList.addAll(invoiceMap.keyset());
                accNameList.sort();
                
                for(String accName : accNameList) {
                    invoiceList.add(invoiceMap.get(accName));    
                }
                for(BulkInvoiceDetails details : invoiceList){
                  if(recordType == Invoicing_Constants.PERMANENT_CONVERSION){
                    details.invoiceNumber = 'INV P - ' + InvValue;  
                  }
                  else {
                    details.invoiceNumber = 'INV C - ' + InvValue;
                  }
                  InvValue++;
                }
            }
        }
        return invoiceList;
    }
    
    // Function to get the Closing Report Details
    public static List<TR1__Closing_Report__c> getClosingReportRecords(String startDate, String endDate, String[] accountIds, Set<String> closingReportIds, String recordType) {
        String query = 'select TR1__Account__c, TR1__Start_Date__c, TR1__PO_Number__c, TR1__End_Date__c, TR1__Invoice_Date__c, Invoice_Status__c, TR1__Account__r.Inv_Contact_Email_Address__c,Timesheet_Pay_Type__c ,  ' 
                         + ' RecordType.Name, TR1__Job__c, TR1__Job__r.Name,TR1__Adjusted_Fee_Amount__c, Payment_Terms1__c, Name, Last_Invoice_Date__c ,TR1__Account__r.Invoice_Contact__c , ' 
                         + ' TR1__Account__r.Email__c, TR1__Retained_Fee_Amount__c,Invoicing_Period__c ,Payment_Term_Permanent__c,  ' 
                         + ' Invoicing_Person__c, Invoicing_Person__r.Name, Invoicing_Person__r.Email, Division__c, '
                         + ' Invoice_Contact__c, TR1__Bill_Rate__c, TR1__DT_Bill_Rate__c, TR1__OT_Bill_Rate__c, '
                         + ' TR1__Person_Placed__r.Name, TR1__Person_Placed__c, TR1__Adjusted_Bill_Rate__c, TR1__Account__r.Name '
                         + ' from TR1__Closing_Report__c'
                         + ' where (Invoice_Status__c = \'' + Invoicing_Constants.PENDING 
                                + '\' or Invoice_Status__c = \'' +  + '\')';
                                                     
        
        if(accountIds != null && accountIds.size() > 0)
            query += 'and TR1__Account__c in :accountIds '; 
        
        if(closingReportIds != null && closingReportIds.size() > 0)
            query += 'and Id in :closingReportIds ';
        
        if(recordType == Invoicing_Constants.CONSULTING) 
            query += ' and RecordType.Name = \'' + Invoicing_Constants.CONSULTING + '\'';
        else        
            query += ' and (RecordType.Name = \'' + Invoicing_Constants.PERMANENT 
                            + '\' or RecordType.Name = \'' + Invoicing_Constants.CONVERSION 
                            + '\' or RecordType.Name = \'' + Invoicing_Constants.RETAINED  
                            + '\' or RecordType.Name = \'' + Invoicing_Constants.RETAINED_INVOICE + '\' )';
                            
        
        if(startDate != null && endDate != null){
            Date startDt = Date.valueOf(startDate);
            Date endDt = Date.valueOf(endDate);
            query += ' and TR1__Invoice_Date__c >= :startDt and TR1__Invoice_Date__c <= :endDt';
        }
        
        query += ' order by TR1__Account__r.Name';
        
        return (List<TR1__Closing_Report__c>)Database.query(query);    
    }
    
    // Function to get the Timesheet Records
    public static List<TR1__Timesheet__c> getTimesheetRecords(String weekEndDate, String[] accountIds, Set<String> closingReportIds) {
        
        //timesheet query for weekly
        String timesheetquery = 'select TR1__Closing_Report__c, TR1__Closing_Report__r.TR1__PO_Number__c, Name,TR1__Job_Order__r.Name, Invoice_Status__c , TR1__Closing_Report__r.Timesheet_Pay_Type__c, '
                              + 'TR1__Job_Order__r.TR1__Account__c, TR1__Job_Order__r.TR1__Account__r.name , TR1__Client__c, TR1__Client__r.Email__c,TR1__Closing_Report__r.TR1__Account__c, '
                              + 'TR1__Week_Ending__c, TR1__Consultant_Name__c, TR1__Total_Regular_Hours__c, TR1__Pay_Rate__c,TR1__Closing_Report__r.TR1__Start_Date__c, '
                              + 'TR1__Total_Double_Time_Hours__c, TR1__Total_Overtime_Hours__c, TR1__Adjusted_Bill_Rate__c, TR1__Client__r.Name, '
                              + 'TR1__OT_Bill_Rate__c, Total_Bill_Amount__c,TR1__DT_Bill_Rate__c, TR1__Bonus__c ,TR1__Status__c, '
                              + 'TR1__Closing_Report__r.TR1__Person_Placed__r.Name, TR1__Closing_Report__r.TR1__Job__r.Name,TR1__Invoice_Amount__c, '
                              + 'TR1__Closing_Report__r.TR1__Adjusted_Bill_Rate__c ,TR1__Closing_Report__r.Invoicing_Period__c '
                              + 'from TR1__Timesheet__c '
                              + 'where TR1__Status__c  IN (\'Approved\') '
                              + 'and TR1__Closing_Report__r.RecordType.Name = \'' + Invoicing_Constants.CONSULTING + '\' '
                              + 'and TR1__Closing_Report__r.Invoicing_Period__c = \'' + Invoicing_Constants.WEEKLY + '\' '
                              + 'and (Invoice_Status__c = \'' + Invoicing_Constants.PENDING 
                                + '\' or Invoice_Status__c = \'\')';
                                      
        if(accountIds != null && accountIds.size() > 0)
            timesheetQuery += 'and TR1__Client__c in :accountIds ';
        
        if(closingReportIds != null && closingReportIds.size() > 0)
            timesheetQuery += 'and TR1__Closing_Report__c in :closingReportIds ';
            
        Date weekEndDt  = date.valueOf(weekEndDate);
        Date weekEndDt1 =  weekEndDt.addDays(-7);
        timesheetquery += 'and TR1__Week_Ending__c <= :weekEndDt ' 
                        + 'and TR1__Week_Ending__c > :weekEndDt1 ';
    
        timesheetquery += ' order by TR1__Job_Order__r.TR1__Account__r.name,TR1__Client__r.Name ';
        List<TR1__Timesheet__c> tempListforWeekly = Database.query(timesheetquery);
            
        // timesheet query for bi weekly
        String timesheetBiWeeklyquery = 'select TR1__Closing_Report__c, TR1__Closing_Report__r.TR1__PO_Number__c, Name,TR1__Job_Order__r.Name, Invoice_Status__c ,TR1__Closing_Report__r.Timesheet_Pay_Type__c, '
                          + 'TR1__Job_Order__r.TR1__Account__c, TR1__Job_Order__r.TR1__Account__r.name , TR1__Client__c, TR1__Client__r.Email__c,TR1__Closing_Report__r.TR1__Account__c, '
                          + 'TR1__Week_Ending__c, TR1__Consultant_Name__c, TR1__Total_Regular_Hours__c, TR1__Pay_Rate__c,TR1__Closing_Report__r.TR1__Start_Date__c, '
                          + 'TR1__Total_Double_Time_Hours__c, TR1__Total_Overtime_Hours__c, TR1__Adjusted_Bill_Rate__c, TR1__Client__r.Name, '
                          + 'TR1__OT_Bill_Rate__c, Total_Bill_Amount__c,TR1__DT_Bill_Rate__c, TR1__Bonus__c ,TR1__Status__c, ' 
                          + 'TR1__Closing_Report__r.TR1__Person_Placed__r.Name, TR1__Closing_Report__r.TR1__Job__r.Name,TR1__Invoice_Amount__c, '
                          + 'TR1__Closing_Report__r.TR1__Adjusted_Bill_Rate__c ,TR1__Closing_Report__r.Invoicing_Period__c '
                          + 'from TR1__Timesheet__c '
                          + 'where TR1__Status__c  IN (\'Approved\') '
                          + 'and TR1__Closing_Report__r.RecordType.Name = \'' + Invoicing_Constants.CONSULTING + '\' '
                          + 'and TR1__Closing_Report__r.Invoicing_Period__c = \'' + Invoicing_Constants.BIWEEKLY + '\' ' 
                          + 'and (Invoice_Status__c = \'' + Invoicing_Constants.PENDING 
                          + '\' or Invoice_Status__c = \'\')';
                          
        if(accountIds != null && accountIds.size() > 0)
            timesheetBiWeeklyquery += 'and TR1__Client__c in :accountIds ';
        
        if(closingReportIds != null && closingReportIds.size() > 0)
            timesheetBiWeeklyquery += 'and TR1__Closing_Report__c in :closingReportIds ';
            
        Date weekEndDt3 = date.valueOf(weekEndDate);
        Date weekEndDt4 = weekEndDt3.addDays(-14);
        timesheetBiWeeklyquery  += 'and TR1__Week_Ending__c <= :weekEndDt3 ' 
                                + 'and TR1__Week_Ending__c > :weekEndDt4 ';

        timesheetBiWeeklyquery += ' order by TR1__Job_Order__r.TR1__Account__r.name,TR1__Client__r.Name,createdDate ';
        List<TR1__Timesheet__c> tempListforBiWeekly = Database.query(timesheetBiWeeklyquery);

        // Timesheet query for monthly records
        String timesheetMonthlyquery = 'select TR1__Closing_Report__c, TR1__Closing_Report__r.TR1__PO_Number__c, Name,TR1__Job_Order__r.Name, Invoice_Status__c ,TR1__Closing_Report__r.Timesheet_Pay_Type__c,  '
                          + 'TR1__Job_Order__r.TR1__Account__c, TR1__Job_Order__r.TR1__Account__r.name , TR1__Client__c, TR1__Client__r.Email__c,TR1__Closing_Report__r.TR1__Account__c, '
                          + 'TR1__Week_Ending__c, TR1__Consultant_Name__c, TR1__Total_Regular_Hours__c, TR1__Pay_Rate__c,TR1__Closing_Report__r.TR1__Start_Date__c, '
                          + 'TR1__Total_Double_Time_Hours__c, TR1__Total_Overtime_Hours__c, TR1__Adjusted_Bill_Rate__c, TR1__Client__r.Name, '
                          + 'TR1__OT_Bill_Rate__c, Total_Bill_Amount__c,TR1__DT_Bill_Rate__c, TR1__Bonus__c ,TR1__Status__c, '
                          + 'TR1__Closing_Report__r.TR1__Person_Placed__r.Name, TR1__Closing_Report__r.TR1__Job__r.Name,TR1__Invoice_Amount__c, '
                          + 'TR1__Closing_Report__r.TR1__Adjusted_Bill_Rate__c , TR1__Closing_Report__r.Invoicing_Period__c '
                          + ' from TR1__Timesheet__c '
                          + 'where TR1__Status__c  IN (\'Approved\') '
                          + 'and TR1__Closing_Report__r.RecordType.Name = \'' + Invoicing_Constants.CONSULTING + '\' '
                          + 'and TR1__Closing_Report__r.Invoicing_Period__c = \'' + Invoicing_Constants.MONTHLY + '\' ' 
                          + 'and (Invoice_Status__c = \'' + Invoicing_Constants.PENDING 
                          + '\' or Invoice_Status__c = \'\')';
                          
        if(accountIds != null && accountIds.size() > 0)
            timesheetMonthlyquery += 'and TR1__Client__c in :accountIds ';
        
        if(closingReportIds != null && closingReportIds.size() > 0)
            timesheetMonthlyquery += 'and TR1__Closing_Report__c in :closingReportIds ';
            
        Date weekEndDt6 = date.valueOf(weekEndDate);
        Date weekEndDt7 = weekEndDt6.addDays(-21);
        timesheetMonthlyquery   +='and TR1__Week_Ending__c <= :weekEndDt6 ' 
                                + 'and TR1__Week_Ending__c >= :weekEndDt1.weekEndDt7 ';

        timesheetMonthlyquery += ' order by TR1__Job_Order__r.TR1__Account__r.name,TR1__Client__r.Name ,createdDate ';
        List<TR1__Timesheet__c> tempListforMonthly = Database.query(timesheetMonthlyquery);
        
        List<TR1__Timesheet__c> TimesheetRecordList = new List<TR1__Timesheet__c>();
        TimesheetRecordList.addall(tempListforWeekly);
        TimesheetRecordList.addall(tempListforBiWeekly);
        TimesheetRecordList.addall(tempListforMonthly);
        
        return TimesheetRecordList;
    }
    
    // Query Invoice Number value
    public static Integer getLastInvoiceNumber() {
        return Integer.valueOf(invoiceNumberOtherUtility().TR1__Value__c);
    }
    
    // Update Last Invoice Number
    public static void updateLastInvoiceNumber(Integer value) {
        TR1__Other_Utility__c otherUtility = invoiceNumberOtherUtility();
        otherUtility.TR1__Value__c = String.valueOf(value);
        upsert otherUtility;
    }
    
    public static TR1__Other_Utility__c invoiceNumberOtherUtility() {
        List<TR1__Other_Utility__c> otherUtility = [select TR1__Value__c from TR1__Other_Utility__c 
                                                                                    where Name = :Invoicing_Constants.INVOICE_NUMBER
                                                                                    and TR1__Value__c != null];
        if(otherUtility != null && otherUtility.size() == 1)
            return otherUtility[0];
        return new TR1__Other_Utility__c(Name = 'INVOICE_NUMBER', TR1__Description__c = Invoicing_Constants.INVOICE_NUMBER, TR1__Value__c = '0');                                                               
    }
    
    public static String logoURL {
        get {
            if(String.isBlank(logoURL)) {
                logoURL = getOtherUtilityValue(Invoicing_Constants.CLIENT_LOGO);                                                                
            }
            return logoURL;
        }
        private set;
    }
    
    public static String getOtherUtilityValue(String name) {
        String value = '';
        if(String.isNotBlank(name)) {
            TR1__Other_Utility__c[] otherUtility = [select TR1__Value__c from TR1__Other_Utility__c 
                                                                                    where Name = :name
                                                                                    and TR1__Value__c != null];
            if(otherUtility != null && otherUtility.size() == 1)
                value = otherUtility[0].TR1__Value__c;
        }
        return value;
    }
}