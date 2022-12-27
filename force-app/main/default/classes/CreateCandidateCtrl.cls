public class CreateCandidateCtrl {
    
    public Contact con {get;set;}
    public Boolean showPanel {get;set;}
    public list<SelectOption> lstTrainedOption {get;set;}
    public list<SelectOption> lstSubjectOption {get;set;}
    public List<String> lstTrainedBy {get;set;}
    public List<String> lstSubject {get;set;}
    
    
    public CreateCandidateCtrl(){
        fetchTrainedBy();
        fetchSubject();
        lstTrainedBy = new List<String>();
        lstSubject = new List<String>();
        doInit();
    }
    
    public void doInit(){
        con = new Contact();
        showPanel =false;
    }
    
    public void fetchTrainedBy(){
        
        lstTrainedOption = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Contact.Trained_As__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            lstTrainedOption.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
    }
    
    public void fetchSubject(){
        lstSubjectOption = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Contact.Subject__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            lstSubjectOption.add(new SelectOption(f.getLabel(), f.getValue()));
        }  
    }
    
    public void doSubmit(){
        try{
            con.TR1__Candidate_Status__c = 'Pre-Reg';
            con.TR1__Client_Status__c = 'Not Applicable';
            con.Division__c = 'Aus-NZ';
            con.Candidate_Source__c = 'University Event - Australia';
            if(Schema.SObjectType.Contact.getRecordTypeInfosByName().containsKey('Candidate')){
                Id rt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                con.RecordTypeId = rt;
            }
            for(User u : [Select Id From User Where Name = 'Gemma Yates' limit 1]){
                con.OwnerId = u.id;
            }
            
            String trainedBy = '';
            Boolean Start = true;
            if(!lstTrainedBy.isEmpty()) {           
                for(String Str : lstTrainedBy) {
                    if(Start) {
                        trainedBy = Str;
                        Start = false;
                    } else {               
                        trainedBy = trainedBy + ';' + Str;
                    }
                }
            }
            con.Trained_As__c = trainedBy;
            
            //For Subject
            String Subject = '';
            Start = true;
            if(!lstSubject.isEmpty()) {           
                for(String Str : lstSubject) {
                    if(Start) {
                        Subject = Str;
                        Start = false;
                    } else {               
                        Subject = Subject + ';' + Str;
                    }
                }
            }
            con.Subject__c = Subject;
            
            insert con;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Information has been submitted successfully!')); 
            showPanel =true;
        }catch(exception ex){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));    
        }
    }
    
    public pageReference createNewCandidate(){
        pageReference pg = new pagereference('/CreateCandidate');
        pg.setRedirect(false);
        return pg;
    }
}