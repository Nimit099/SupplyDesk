public class AssociatedQualificationDetailCtrl {
    private ApexPages.StandardController stdcontroller;
    public String fieldsetLabel {get;set;}
    public TR1__Associated_Qualification__c assoQual {get;set;}
    public boolean showPanel {get;set;}
    public boolean showNotePanel {get;set;}
    public Note oNote {get;set;}
    public String noteTitle {get;set;}
    public String noteBody {get;set;}
    public boolean privateNote {get;set;}
    public AssociatedQualificationDetailCtrl(ApexPages.StandardController stdcontroller){
        showPanel = true;
        showNotePanel = false;
        oNote = new Note();
        noteTitle ='';
        noteBody ='';
        privateNote = false;
        if(!test.isRunningTest())
            stdController.addFields(new List<String>{'TR1__Contact__c','TR1__Qualification__c','TR1__Qualification__r.TR1__Field_Set_ID__c'});
        this.assoQual = (TR1__Associated_Qualification__c)stdController.getRecord();
        this.stdController = stdController;
        fieldsetLabel = '';
        fieldsetLabel = String.isNotBlank(assoQual.TR1__Qualification__c)  &&  String.isNotBlank(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) 
            &&  Schema.SObjectType.TR1__Associated_Qualification__c.fieldSets.getMap().containsKey(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) 
            ?  Schema.SObjectType.TR1__Associated_Qualification__c.fieldSets.getMap().get(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c).getLabel() : '';
    }
    
    public PageReference goToStandardPage(){
        String  recordId = (String)assoQual.Id;
        if( assoQual.TR1__Contact__c == null || (!test.isRunningTest() && (String.isEmpty(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c)
                                                                           || !SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().containskey(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) )) )
        {
            return new PageReference('/'+recordId+'?nooverride=1').setRedirect(true);
        }else
        {
            Set<String> setFields = new Set<String>{'TR1__Contact__c','TR1__Qualification__c','TR1__Qualification__r.TR1__Field_Set_ID__c'};
                if(!test.isRunningTest())
                for(Schema.FieldSetMember field : SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c).getFields())
                setFields.add(field.getFieldPath());
            for(Schema.FieldSetMember field : SObjectType.TR1__Associated_Qualification__c.FieldSets.page_override.getFields())
                setFields.add(field.getFieldPath());
            String strQuery = 'Select '+ String.join(new List<String>(setFields), ', ') + ' from TR1__Associated_Qualification__c where Id=:recordId limit 1';
            assoQual = database.query(strQuery);
            return null;
        }
    }
    
    public PageReference backToContact(){
        return new PageReference('/'+assoQual.TR1__Contact__c).setRedirect(true);
    }
    
    public void clickAddNote(){
        showPanel = false;
    }
    
    public PageReference createNote(){
        try{
            oNote = new Note();
            oNote.ParentId = (String)assoQual.Id;
            oNote.title = noteTitle;
            oNote.Body = noteBody;
            oNote.isPrivate = privateNote;
            insert oNote;
            return new PageReference('/'+assoQual.Id).setRedirect(true);
            
        }
        catch(exception e){
            System.debug('##### Error message :'+e.getMessage());
        }
        return null;
    }
    
    public PageReference backToCurrentRecord(){
        return new PageReference('/'+assoQual.Id).setRedirect(true);
    }
}