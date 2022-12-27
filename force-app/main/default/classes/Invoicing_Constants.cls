public with sharing class Invoicing_Constants {
    
    // Record Type OPTIONS
    public static final string CONSULTING           = 'Consulting';
    public static final string PERMANENT_CONVERSION = 'Permanent/Conversion/Retained';
    public static final String PERMANENT            = 'Permanent';
    public static final String CONVERSION           = 'Conversion';
    public static final String RETAINED             = 'Retained';
    public static final String RETAINED_INVOICE     = 'Retained Invoice';// aDDED by nikhil for Retained invoice 24-04-2014
    
    // Period dropdown options
    public static final String WEEKLY           = 'Weekly';
    public static final String BIWEEKLY         = 'BiWeekly';
    public static final String MONTHLY          = 'Monthly';
    
    // Invoice Template  
    public static final String INVOICING_EDUCATION_CONSULTING_TEMPLATE = 'Invoicing_ConsultingEducation';
    public static final String INVOICING_EDUCATION_PERMANANT_TEMPLATE = 'Invoicing_PermanantEducationEmailTemplate';
    public static final String INVOICING_CONSTRUCTION_CONSULTING_TEMPLATE = 'Invoicing_ConsultingConstructionEmailTemplate';
    public static final String INVOICING_CONSTRUCTION_PERMANANT_TEMPLATE = 'Invoicing_PermanantConstructionEmailTemplate';
    
	public static final String INVOICING_EMAIL_TEMPLATE = 'Invoicing_Email';
    public static final String INVOICING_CONSTRUCTION_EMAIL_TEMPLATE = 'Invoicing_Construction_Email';
    
	
	    
    // Invoice Status
    public static final String EMAILED = 'Emailed';
    public static final String PRINTED = 'Printed';
    public static final String PENDING = 'Pending';
    
    // Invoice Number Query param
    public static final String INVOICE_NUMBER   = 'Invoice_Number';
    public static final String CLIENT_LOGO      = 'Client_Logo';
    
    // CreateTimesheet for closing report constant
    public static boolean CreateTimesheetConstant = true;
    
    public static final ID EducationRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' limit 1].Id; 
}