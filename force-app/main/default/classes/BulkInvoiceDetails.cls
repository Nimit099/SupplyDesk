public with sharing class BulkInvoiceDetails {
    
    /* Variables */
    public decimal regularHours     {get; set;}
    public decimal regularBilled    {get; set;}
    public decimal OtHours          {get; set;}
    public decimal OTBilled         {get; set;}
    public decimal DTHours          {get; set;}
    public decimal DTBilled         {get; set;}
    public decimal Bonus            {get; set;}
    public decimal invoiceTotal     {get; set;}
    public String weekEndingDate    {get; set;}
    public Account acc              {get; set;}
    public List<TR1__Closing_Report__c> closingReport  {get; private set;}
    public List<TR1__Timesheet__c> timesheetList {get; private set;}
    public decimal VatAmount       {get; set;} //Added for Engage after migration Nikhil
    public decimal VatTotal        {get; set;} //Added for Engage after migration Nikhil
    public String invoiceNumber     {get; set;}
    public String poNumber          {get; set;}
    public String PeriodFrom        {get; set;}
    public String PeriodTo          {get; set;}
    public String PayType			{get; set;}
    public TR1__Closing_Report__c  creport {get;set;}
    public TR1__Closing_Report__c  closingRep {get;set;}
    
    // May not be needed any longer. 
    public Boolean poValueforHeader     {get; set;}
    
    private Date DueDate;
    public String getDueDate() {
        return dueDate.format();
    }
    
    private Date invDate;
    public string  getinvDate(){
        return invDate.format();
    }
    
    private Date CLRstartDate;
    public string getCLRstartDate(){
        return CLRstartDate.format();
    }
    
    /* Variables - END */
    
    // Constructor for Consulting
    public BulkInvoiceDetails(decimal regularHours, decimal regularBilled , decimal OtHours, 
                                decimal OTBilled, decimal DTHours ,decimal DTBilled ,decimal Bonus,
                                decimal invoiceTotal, String invoiceNumber, String weekEndingDate, Account acc , 
                                Date DueDate, Date invDate, List<TR1__Closing_Report__c> closingReport, List<TR1__Timesheet__c> timesheetList , String PeriodFrom , String PeriodTo,String PayType , String ponumber){
                                    
        this.regularHours = regularHours;
        this.regularBilled = regularBilled;
        this.OtHours = OtHours;
        this.OTBilled = OTBilled;
        this.DTHours = DTHours;
        this.DTBilled = DTBilled;
        this.Bonus = Bonus;
        this.invoiceTotal = invoiceTotal;
        this.acc = acc;
        this.invoiceNumber = invoiceNumber;
        this.weekEndingDate = weekEndingDate;
        this.DueDate = DueDate;
        this.invDate = invDate;
        this.closingReport = closingReport;
        this.timesheetList = timesheetList;
        this.PeriodFrom = PeriodFrom;
        this.PeriodTo = PeriodTo;
        this.payType  = PayType;
        this.VatAmount = 0.2 * invoiceTotal; //Added for Engage after migration Nikhil
        this.VatTotal = invoiceTotal + vatAmount; //Added for Engage after migration Nikhil
		this.creport = closingReport[0];
		this.ponumber = ponumber ;
    }
    
    // Constructor for Permanent/Conversion
    public BulkInvoiceDetails(decimal invoiceTotal, String invoiceNumber, String weekEndingDate, Account acc, 
                                Date DueDate, Date invDate, List<TR1__Closing_Report__c> closingReport, String ponumber, Boolean poValueforHeader , String PeriodFrom , String PeriodTo) {
        
        this.invoiceTotal = invoiceTotal;
        this.acc = acc;
        this.invoiceNumber = invoiceNumber;
        this.weekEndingDate = weekEndingDate;
        this.DueDate = DueDate;
        this.invdate = invDate;
        this.closingReport = closingReport;
        this.ponumber = ponumber ;
        this.poValueforHeader = poValueforHeader;
        this.PeriodFrom = PeriodFrom;
        this.PeriodTo = PeriodTo;
        this.VatAmount = 0.2 * invoiceTotal; //Added for Engage after migration Nikhil
        this.VatTotal = invoiceTotal + vatAmount; //Added for Engage after migration Nikhil
        
    }
}