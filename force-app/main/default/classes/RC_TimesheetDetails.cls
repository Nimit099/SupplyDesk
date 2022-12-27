public with sharing class RC_TimesheetDetails {


    public List<TR1__Timesheet_Detail__c> lstTimesheetDetailRecords   {get;set;}        // List to have TimesheetDetail record
    public List<Schema.FieldSetMember> fieldSetTimesheetDetail {get;set;}               // list of FieldSetMember for Detail section
    public List<Schema.FieldSetMember> fieldSetTimesheetHeader {get;set;}               // list of FieldSetMember for Header section
    public List<Schema.FieldSetMember> fieldSetTimesheetHeaderApprover {get;set;}       // list of FieldSetMember for Header section for approver
    public List<Schema.FieldSetMember> fieldSetTimesheetFooter {get;set;}               // list of FieldSetMember for Footer section
    public List<Schema.FieldSetMember> fieldSetTimesheetAdditionalInfo {get;set;}       // list of FieldSetMember for AdditionlInfo section

    public TR1__Timesheet__c objTS {get;set;}                                           // Timesheet object

    public Boolean isClient {get;set;}                                                  // To check loggedin user type
    public Boolean isEdit {get;set;}
    public Boolean noParameter {get;set;}                                                  // To cehck Parameter tsId
    public Contact objContact {get;set;}
    private String strQueryTSD;                                                         // querry for TimesheetDetail
    private String strQueryTS;                                                          // query for Timesheet
    private String tsId;                                                                // Timesheet id captured from page parameters
    private List<Schema.FieldSetMember> lstFieldSet;
    Private string strContactId;
    //constructor
    public RC_TimesheetDetails(){
        init(); //Initialize method
    }

    //Initilize method, called from constructor
    private void init(){
        if(Apexpages.currentPage().getParameters().containsKey('tsId'))
            tsId = Apexpages.currentPage().getParameters().get('tsId');
        else
        {
            noParameter = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Timesheet Id found'));
            return;
        }


        isClient = false;
        strQueryTSD = 'Select TR1__Date__c, TR1__Day__c ';
        strQueryTS = 'Select Name, TR1__Approvers_Notes__c,Teacher_Rating__c,TR1__Job_Order__r.TR1__Job_Title__c,Message_to_Job_Owner__c,Request_Quality_Call__c ';
        strContactId = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1].ContactId;

        //objContact = [Select Community_Contact_Type__c from Contact where Id = :strContactId];
        fetchContactInfo();

        String nameSpace = ''; //will be used for package namespace
        fieldSetTimesheetDetail = new List<Schema.FieldSetMember>();
        fieldSetTimesheetHeader = new List<Schema.FieldSetMember>();
        fieldSetTimesheetHeaderApprover = new List<Schema.FieldSetMember>();
        fieldSetTimesheetFooter = new List<Schema.FieldSetMember>();
        fieldSetTimesheetAdditionalInfo = new List<Schema.FieldSetMember>();

        Map<String, Schema.FieldSet> mapFieldset = SObjectType.TR1__Timesheet__c.FieldSets.getMap();

        fieldSetTimesheetDetail = SObjectType.TR1__Timesheet_Detail__c.FieldSets.getMap().get(nameSpace+'RC_TimesheetDetail').getFields();
        fieldSetTimesheetHeader = mapFieldset.get(nameSpace+'RC_TimesheetHeader').getFields();
        fieldSetTimesheetHeaderApprover = mapFieldset.get(nameSpace+'RC_TimesheetHeaderApprover').getFields();
        fieldSetTimesheetFooter = mapFieldset.get(nameSpace+'RC_TimesheetFooter').getFields();
        fieldSetTimesheetAdditionalInfo = mapFieldset.get(nameSpace+'RC_TimesheetAdditionalInfo').getFields();

        for(Schema.FieldSetMember objFSM: fieldSetTimesheetDetail)
            strQueryTSD += ', ' + objFSM.getFieldPath() ;

        Set<String> setFieldNames = new Set<String>{'Id'};

        for(Schema.FieldSetMember field : fieldSetTimesheetHeader)
            setFieldNames.add(field.getFieldPath());

        for(Schema.FieldSetMember field : fieldSetTimesheetHeaderApprover)
            setFieldNames.add(field.getFieldPath());

        for(Schema.FieldSetMember field : fieldSetTimesheetFooter)
            setFieldNames.add(field.getFieldPath());

        for(Schema.FieldSetMember field : fieldSetTimesheetAdditionalInfo)
            setFieldNames.add(field.getFieldPath());

        // //Comman list of fieldset-Member
        // List<Schema.FieldSetMember> lstFSM = new List<Schema.FieldSetMember>();
        // lstFSM.addAll(fieldSetTimesheetHeader);
        // //lstFSM.addAll(fieldSetTimesheetHeaderApprover);
        // lstFSM.addAll(fieldSetTimesheetFooter);
        // lstFSM.addAll(fieldSetTimesheetAdditionalInfo);

        for(String str: setFieldNames)
            strQueryTS += ', ' + str;

        if(!strQueryTS.contains('All_Approver__c'))
            strQueryTS += ',All_Approver__c ';
        if(!strQueryTS.contains('TR1__Consultant__c'))
            strQueryTS += ',TR1__Consultant__c ';

        strQueryTS += ' from TR1__Timesheet__c where Id = \'' + tsId  + '\'';
        strQueryTSD += ' from TR1__Timesheet_Detail__c where TR1__Timesheet__c = \'' + tsId  + '\'';
        System.debug('----- ** strQueryTSD : '+strQueryTSD);
        String whereClauseTSD = ' AND (All_Approver__c like \'%'+ ((String)objContact.Id).left(15) +'%\' OR TR1__Consultant__c = \'' + strContactId + '\') ';
        system.debug(':::strQueryTS::'+strQueryTS);
        system.debug(':::strContactId:::'+strContactId);

        List<TR1__Timesheet__c> lstTS = RC_AccessController.query(strQueryTS+whereClauseTSD);

        if(!lstTs.isEmpty())
            objTS = lstTS[0];
        if(objTS != null && objTS.TR1__Status__c=='Approved')
            isEdit =False ;
        else if(objTS != null && objTS.TR1__Status__c=='Submitted')
            isEdit = True;


        if(objTS == null)
        {
            noParameter = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Timesheet not accessible for you'));
            return;
        }
        else
        {

            if( (objContact.Community_Contact_Type__c == 'Candidate' || objContact.Community_Contact_Type__c == 'C and C') && strContactId == objTS.TR1__Consultant__c)
                isClient = false;
            else if( (objContact.Community_Contact_Type__c == 'Client' || objContact.Community_Contact_Type__c == 'C and C') && objTS.All_Approver__c.contains(((String)objContact.Id).left(15)))
                isClient = true;
        }
        objTS.Message_to_Job_Owner__c = '';
        System.debug('------ strQueryTSD : '+strQueryTSD);
        lstTimesheetDetailRecords = RC_AccessController.query(strQueryTSD);

    }

    /*
    Name - saveTimesheetDetails
    returnType - PageReference
    Description - Called by Candidate to save a timesheet
    */
    /*public PageReference saveTimesheetDetails(){
        try
        {
            RC_AccessController.updateRecords(lstTimesheetDetailRecords);
            RC_AccessController.updateRecord(objTS);
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/TimesheetListing?save='+objTS.Name).setRedirect(true);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    */
    /*
    Name - saveNSubmitTimesheetDetails
    returnType - PageReference
    Description - Called by Candidate to submit and save a timesheet
    */
    /*public PageReference saveNSubmitTimesheetDetails(){
        try
        {
            update lstTimesheetDetailRecords;
            objTS.TR1__Status__c = 'Submitted';
            update objTS;
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/TimesheetListing?save='+objTS.Name).setRedirect(true);
        }
        catch(Exception ex)
        {
            System.debug('---- ex.getMessage() : '+ex.getMessage());
            System.debug('----- ex.getStackTraceString() : '+ex.getStackTraceString());
            System.debug('----- ex.getLineNumber() : '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
     public void editTimesheet(){
            isEdit = True;
            Utility.adderrormessage('editmethod called '+isEdit);
            //return new PageReference('/TimesheetDetails?tsId='+objTS.Id).setRedirect(false);
    }
    */
     /*
    Name - approveTimesheet
    returnType - PageReference
    Description - Called by Client to approve a timesheet of a candidate
    */
    /*public PageReference approveTimesheet(){
        try
        {
            objTS.TR1__Status__c = 'Approved';
            update objTS;
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/TimesheetListing?save='+objTS.Name).setRedirect(true);
        }
        catch(Exception ex)
        {
            System.debug('----approveTimesheet ex.getMessage() : '+ex.getMessage());
            System.debug('-----approveTimesheet ex.getStackTraceString() : '+ex.getStackTraceString());
            System.debug('-----approveTimesheet ex.getLineNumber() : '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }*/
      /*
    Name - approveTimesheet
    returnType - PageReference
    Description - Called by Client to approve and save timesheet of a candidate
    */
    public PageReference approveandSaveTimesheet(){
        try
        {
           RC_AccessController.updateRecords(lstTimesheetDetailRecords);
            objTS.TR1__Status__c = 'Approved';
            RC_AccessController.updateRecord(objTS);
            if(Test.isRunningTest())
                Integer i = 1/0;
                isEdit = false;
            return new PageReference('/TimesheetListing?save='+objTS.Name).setRedirect(true);
        }
        catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));
            return null;
        }
        catch(Exception ex)
        {
            System.debug('----approveTimesheet ex.getMessage() : '+ex.getMessage());
            System.debug('-----approveTimesheet ex.getStackTraceString() : '+ex.getStackTraceString());
            System.debug('-----approveTimesheet ex.getLineNumber() : '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    public PageReference clearDetails(){
    list<TR1__Timesheet_Detail__c> newlist=new list<TR1__Timesheet_Detail__c>();
    system.debug('clearDetails<><><>+clearDetails');
        if(Apexpages.currentPage().getParameters().containsKey('DetailId')){
        system.debug('DetailIdtimesheet<>**+DetailId');
            String tsdId = Apexpages.currentPage().getParameters().get('DetailId');
            //Test for W-4222976
            //TR1__Timesheet_Detail__c tsdRec  = [Select Id, Name,Day__c,Closing_Report_Schedule__c,Half_Day__c,TR1__Regular_Hours__c from TR1__Timesheet_Detail__c where Id =: tsdId limit 1 ];
            TR1__Timesheet_Detail__c tsdRec  = RC_AccessController.getTimesheetById(tsdId);
            tsdRec.DayShift__c = False;
            tsdRec.Half_Day__c = False;
            tsdRec.TR1__Regular_Hours__c = null;
            tsdRec.Closing_Report_Schedule__c=null;
            RC_AccessController.updateRecords(lstTimesheetDetailRecords);
            RC_AccessController.updateRecord(tsdRec);
            system.debug('tsdRec***+tsdRec'+tsdRec);

            return new pagereference ('/TimesheetDetails?tsId='+objTS.Id);

        }else{
        system.debug('*****');
            Utility.addErrorMessage('No Timesheet Detail Record found for this day');
            return null;
        }

    }
    /*
    Name - rejectTimesheet
    returnType - PageReference
    Description - Called by Client to reject a timesheet of a candidate
    */
    public PageReference rejectTimesheet(){
        try
        {
            objTS.TR1__Status__c = 'Rejected';
            RC_AccessController.updateRecord(objTS);
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/TimesheetListing?reject='+objTS.Name).setRedirect(true);
        }
         catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));
            return null;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }

    //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
            fetchContactInfo();
           return null;
        }

        catch(Exception e)
        {
            return null;
        }
    }

    //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        Integer index = 0;

        String strQuery = 'Select Id,Community_Contact_Type__c';

        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();

        for(Schema.FieldSetMember field : lstFieldSet)
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath();
        }

        strQuery  += fieldNames + ' from Contact where id =: strContactId' ;

        system.debug('---strQuery-'+strQuery);

        List<Contact> lstContact = Database.query(strQuery);

        if(!lstContact.isEmpty())
            objContact = lstContact[index];


    }

    //To send email to Job Owner about with Message
    public PageReference sendMessageToSupplyDesk(){
        RC_AccessController.updateRecord(new TR1__Timesheet__c(Id=objTS.id, Message_to_Job_Owner__c = objTS.Message_to_Job_Owner__c));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Message sent successfully.'));
        return null;
    }
}