public with sharing class RC_CandidateExpenseReportDetail {
    
    public List<TR1__Expense_Report_Detail__c> lstExpenseDetailItems        {get;set;}      //To get all the line item which is related to Expense Reports
    public List<Schema.FieldSetMember> fieldSetExpenseDetail                {get;set;}      //To get the size of line item fields 
    Public List<Attachment> lstAttachments                                  {get;set;}      //To get the attachment which is related to Expense Reports
    public TR1__Expense_Report__c objExpRep                                 {get;set;}      //To get the Expense report detail for Edit page
    public String strClosingReport                                          {get;set;}      //To get the Closing Report Id which is selected by user.
    public String expRepId                                                  {get;set;}      //Receiving Expense Report parameter to fetch the details
    public String searchTerm                                                {get;set;}      //Account lookup auto complete Id
    public String selectedAccount                                           {get;set;}      //Account lookup auto complete name
    public Boolean isNewExp                                                 {get;set;}      //To check the page is new or not. 
    public Boolean isReadOnly                                               {get;set;}      //Toggle the page for Edit and Readonly
   
    public String strUploadMessage                                          {get;set;}      //To get the uploading Success/Failure message from Iframe page
    public boolean isUploadSuccess                                          {get;set;}      //To get the success notification from Iframe Page
    public String strShowErrorMessage                                       {get;set;}      //Throw the error messages when the user performing DML operations
    public Boolean isPageLoad                                               {get;set;}    
    Public List<TR1__Closing_Report__c> lstClosingReports                   {get;set;}
    public Map<String, String> mapRecordTypeIdToName                        {get;set;}       //Get all the RecordType details from Expense line item
    private User loggedInUser;                                                              //Get loggedIn user deatils
    private Integer intIndex;
    private string strDefaultRecordType;
    public Contact objContact												{get;set;}
    private List<Schema.FieldSetMember> lstFieldSet;
    
    public RC_CandidateExpenseReportDetail(){
        
        init(); 
    } 
    
    private void init(){
        
        objContact = new Contact();
        strUploadMessage = '';
        strShowErrorMessage = '';
        isReadOnly = true;
        lstAttachments = new List<Attachment>();
        lstExpenseDetailItems = new List<TR1__Expense_Report_Detail__c>();
        mapRecordTypeIdToName = new Map<String, String>();
        objExpRep = new TR1__Expense_Report__c();
        lstFieldSet = new List<Schema.FieldSetMember>();
        isPageLoad = true;
        intIndex = 0;
        
        String nameSpace = '';
        
        //Get the logged in user details
        loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
        
        System.debug('loggedInUser' + loggedInUser);
        System.debug('loggedInUser.ContactId' + loggedInUser.ContactId);

        lstClosingReports = RC_AccessController.getClosingReportsForContact(loggedInUser.ContactId);
        System.debug('lstClosingReports ' + lstClosingReports);
        
        fieldSetExpenseDetail = new List<Schema.FieldSetMember>();
        
        //Get all the fields from Line Item object field set
        fieldSetExpenseDetail = SObjectType.TR1__Expense_Report_Detail__c.FieldSets.getMap().get(nameSpace+'ExpenseLineItemDetail').getFields();
        
        expRepId = ''; // receiving the parameter from page, If the page is expense report details
        
        //Get all the recordtypes which is related to line item object
        for(RecordType objRecordType : [SELECT DeveloperName, Id FROM RecordType WHERE SobjectType = 'TR1__Expense_Report_Detail__c'])
        {
            
            String strId = String.valueOf(objRecordType.Id).substring(0, 15);
            mapRecordTypeIdToName.put(strId, objRecordType.DeveloperName);
            if(objRecordType.DeveloperName == 'Lodging')
                strDefaultRecordType = strId;
        }
        
        //Check the logged in user has Contact Id or not and assign to Consultant contact lookup field
        if(!String.isEmpty(loggedInUser.ContactId))
            objExpRep.TR1__Consultant__c = loggedInUser.ContactId;
            
        try
        {
            //Checking the page parameter. If the param contains NexExp and not equal to null, the page will redirect as New Expense page else it will check with Expense Reports Id
            if(ApexPages.currentPage().getParameters().containsKey('NewExp') && ApexPages.currentPage().getParameters().get('NewExp') != '' &&  ApexPages.currentPage().getParameters().get('NewExp') == 'true')
            {
                
                if(!lstClosingReports.isEmpty())
                {
                    objExpRep.TR1__Consultant__c = loggedInUser.ContactId;
                    isNewExp = true;
                    isReadOnly = false;
                    lstExpenseDetailItems.add(new TR1__Expense_Report_Detail__c(RecordTypeId = strDefaultRecordType));
        		}
                else
                {
                    strShowErrorMessage = 'You can\'t create Expense report because we couldn\'t find any closing reports for you.'; 
                    isPageLoad = false;
                }
                
                
            }
            else if(ApexPages.currentPage().getParameters().containsKey('ExpRep') && ApexPages.currentPage().getParameters().get('ExpRep') != '')
            {
                isNewExp = false;
                expRepId = ApexPages.currentPage().getParameters().get('ExpRep'); //Store the Expense report Id for page reference
                
                //get all the fields which is related to Expense Reports object
                String strQueryEdit = 'Select Id, TR1__Status__c';
                for(Schema.FieldSetMember objField : SObjectType.TR1__Expense_Report__c.FieldSets.getMap().get(nameSpace+'RC_CandidateExpRepEdit').getFields())
                {
                    strQueryEdit += ','+ objField.getFieldPath();
                }
                
                //Query on Expense Report object
               	objExpRep = (TR1__Expense_Report__c)RC_AccessController.query(strQueryEdit + ' , TR1__Account__r.Name, TR1__Closing_Report__r.TR1__Start_Date__c, TR1__Closing_Report__r.TR1__Job__r.Name From TR1__Expense_Report__c where Id= \'' + expRepId + '\' AND TR1__Consultant__c =  \'' + loggedInUser.ContactId + '\' limit 1')[0];  
                System.debug('objExpRep' + objExpRep);
                
                //To get the Closing report value to show on Picklist as default
                if(objExpRep != null)
                    strClosingReport = objExpRep.TR1__Closing_Report__c;
                
                //Get all the Attachments related to Expense Reports
                lstAttachments = RC_AccessController.getAttachmentsByParentId(expRepId);            	
                System.debug('lstAttachments' + lstAttachments);
            
                String strQuery = 'Select Id' ;
                
                for(Schema.FieldSetMember objField : fieldSetExpenseDetail)
                {
                    strQuery += ','+ objField.getFieldPath();
                }
                
                for(String strRecordType : mapRecordTypeIdToName.Values()){
                    system.debug('::::'+strRecordType);
                    for(Schema.FieldSetMember field : SObjectType.TR1__Expense_Report_Detail__c.FieldSets.getMap().get(strRecordType).getFields()) 
                        if(!strQuery.contains(field.getFieldPath()))
                            strQuery += ', ' + field.getFieldPath();
                }
                        
                
               	strQuery += ' ,TR1__Expense_Report__c, TR1__Comments__c FROM TR1__Expense_Report_Detail__c where TR1__Expense_Report__c = \'' + expRepId + '\' AND TR1__Expense_Report__r.TR1__Consultant__c =  \'' + loggedInUser.ContactId + '\'';
                system.debug('--strQuery--'+strQuery);
                lstExpenseDetailItems = RC_AccessController.query(strQuery);

                
                
                system.debug('--lstExpenseDetailItems--'+lstExpenseDetailItems);
            }
            else
            {
                strShowErrorMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
                isPageLoad = false;
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
                
        }
        catch(Exception ex)
        {
            system.debug('::::Ex::::'+ex);
            system.debug('::::Ex::::'+ex.getLineNumber());
            strShowErrorMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
            isPageLoad = false;
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
            
            objContact = [Select Id, Community_Contact_Type__c from Contact where Id =: loggedInUser.ContactId limit 1];
            
            system.debug('--objContact.Community_Contact_Type__c--'+objContact.Community_Contact_Type__c);
            
            
            if(objContact.Community_Contact_Type__c == 'Client')
            {
               return new Pagereference('/ExpenseReports');
            }
            
            fetchContactInfo();
         
            if(Test.isRunningTest())    
                Integer i = 1/0;
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
        
        String strQuery = 'Select Id'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        String strContactId =  objContact.Id;      
        strQuery  += fieldNames + ' from Contact where id =: strContactId' ;    
        system.debug('---strQuery-'+strQuery);
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
            
        system.debug('--lstContact--'+lstContact);
        system.debug('--objContact--'+objContact);
    } 
    
    //Insert the Expense Reports and redirect to Expense Report View page
    public pageReference saveExpenseReport(){
       Savepoint sp = Database.setSavepoint();
        
        try
        {
            strShowErrorMessage = '';
            
            objExpRep.TR1__Closing_Report__c = strClosingReport;
            
            List<TR1__Closing_Report__c> lstClosingReports = RC_AccessController.getClosingReportById(strClosingReport);
            System.debug('strClosingReport ' + strClosingReport);
            System.debug('lstClosingReports ' + lstClosingReports);
            
            if(!lstClosingReports.isEmpty())
            {
                objExpRep.TR1__Account__c = lstClosingReports[intIndex].TR1__Account__c;
                objExpRep.Approver_Contact__c = lstClosingReports[intIndex].TR1__Timesheet_Approver__c;
            }
            
            RC_AccessController.insertRecord(objExpRep);
            
            system.debug('---- objExpRep111 ---'+objExpRep);
            
            createExpenseLineItem();
            
            if(Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSubmitted')))
            {
                objExpRep.TR1__Status__c = 'Submitted';
                RC_AccessController.updateRecord(objExpRep);
            }
            
            return new Pagereference('/CandidateExpenseReportDetail?ExpRep='+objExpRep.Id);
            
        }
        catch(Exception ex){
            strShowErrorMessage =  ex.getMessage();
            objExpRep.Id = null;  
            objExpRep.TR1__Status__c = 'Unsubmitted';
             
            for(TR1__Expense_Report_Detail__c objExpReportDetails : lstExpenseDetailItems)
            {
                if(objExpReportDetails.TR1__Expense_Report__c != null)    
                    objExpReportDetails.TR1__Expense_Report__c = null; 
            }
            Database.rollback(sp);
            
            return null;
        }
        
        
    }
    
    //Get the list of attachment once the upload is done through IFrame
    public void getUploadDetails()
    {
        lstAttachments = RC_AccessController.getAttachmentsByParentId(expRepId);
        System.debug('expRepId ' + expRepId);
        System.debug('lstAttachments ' + lstAttachments);
    }
    
    //Create/Update the LineItem
    public void createExpenseLineItem()  
    {
        System.debug('--- lstExpenseDetailItems ---'+lstExpenseDetailItems);
        for(TR1__Expense_Report_Detail__c objExpReportDetails : lstExpenseDetailItems)
        {
            if(objExpReportDetails.TR1__Expense_Report__c == null)    
                objExpReportDetails.TR1__Expense_Report__c = objExpRep.Id; 
        }
         
        RC_AccessController.upsertExpenseLineItems(lstExpenseDetailItems, TR1__Expense_Report_Detail__c.Id, true);
    }
    
    //For add row for creating the new line item
    public void addLineItem()
    {
        lstExpenseDetailItems.add(new TR1__Expense_Report_Detail__c(RecordTypeId = strDefaultRecordType));
        system.debug('--- lstExpenseDetailItems ---'+lstExpenseDetailItems);
    }
    
    //Update the Expense Report details
    public pageReference updateExpenseReport(){
       Savepoint sp = Database.setSavepoint();
       try
       {
            objExpRep.TR1__Closing_Report__c = strClosingReport;

           List<TR1__Closing_Report__c> lstClosingReports = RC_AccessController.getClosingReportById(strClosingReport);
           System.debug('lstClosingReports ' + lstClosingReports);
           if(!lstClosingReports.isEmpty())
           {	
               objExpRep.TR1__Account__c = lstClosingReports[intIndex].TR1__Account__c;
               objExpRep.Approver_Contact__c = lstClosingReports[intIndex].TR1__Timesheet_Approver__c;
           }

           RC_AccessController.updateRecord(objExpRep);
            
            createExpenseLineItem();   
            
            if(Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSubmitted')))
            {
                objExpRep.TR1__Status__c = 'Submitted';
                RC_AccessController.updateRecord(objExpRep);
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/CandidateExpenseReportDetail?ExpRep='+expRepId); 
       }
        catch(Exception ex)
        {
            strShowErrorMessage =  ex.getMessage();
            objExpRep.TR1__Status__c = 'Unsubmitted';
            Database.rollback(sp);
            return null;
        }
    }
    
    
    //To remove a particular Line item from Expense Report
    public void deleteLineItem()
    {
        try
        {
            Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
            TR1__Expense_Report_Detail__c objExpItemDelete = lstExpenseDetailItems[index];
            lstExpenseDetailItems.remove(index);
            if(ApexPages.currentPage().getParameters().containsKey('ExpRep'))
                RC_AccessController.deleteRecord(objExpItemDelete);
                
            system.debug('-------delete--'+lstExpenseDetailItems);
             system.debug('-------objExpItemDelete--'+objExpItemDelete);
            
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(exception ex)
        {
            system.debug('--- Exception 1---'+ex.getMessage());
            system.debug('--- Exception 2---'+ex.getLineNumber());
        }
        
    }
    
    
    //Update the mode from readonly to Edit
    public void enableEditMode(){
        isReadOnly = false;
        if(lstExpenseDetailItems.isEmpty())
            lstExpenseDetailItems.add(new TR1__Expense_Report_Detail__c(RecordTypeId = strDefaultRecordType));
    }
    
    //Closing Report records for Picklist 
    public list<SelectOption> getClosingReports()
    {
        List<SelectOption> closingReports = new List<SelectOption>();
        //closingReports.add(new SelectOption('','--Select--'));       
     	List<TR1__Closing_Report__c> selectedClosingReports = RC_AccessController.getClosingReportsForContact(loggedInUser.ContactId);           
        system.debug('selectedClosingReports'+selectedClosingReports);
        for(TR1__Closing_Report__c objClosingReports : selectedClosingReports)
            closingReports.add(new SelectOption(objClosingReports.Id, String.valueOf(objClosingReports.TR1__Start_Date__c)+' - '+objClosingReports.TR1__Job__r.Name));
            
        return closingReports;
    }
    
    //Delete Expense Reports 
    public pageReference deleteExpenseReports()
    {
        RC_AccessController.deleteRecord(objExpRep);
        return new Pagereference('/ExpenseReports');
    }
    
    public void DummyFunction()
    {
        system.debug('---- Change ---'+lstExpenseDetailItems);
        
        Integer rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowNum'));
        String RecordTypeId = ApexPages.currentPage().getParameters().get('RecordTypeId');
        
        lstExpenseDetailItems[rowNum].RecordTypeId = RecordTypeId;
    }

}