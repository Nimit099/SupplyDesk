public with sharing class ViewAssociatedQualification {
    public TR1__Associated_Qualification__c assoQual {
        get;
        set;
    }
    private ApexPages.StandardController stdController;
    public String fieldsetLabel {
        get;
        set;
    }
    public ViewAssociatedQualification(ApexPages.StandardController stdController) {
        if (!test.isRunningTest())
            stdController.addFields(new List < String > {
                'TR1__Contact__c',
                'TR1__Qualification__c',
                'TR1__Qualification__r.TR1__Field_Set_ID__c'
            });
        this.assoQual = (TR1__Associated_Qualification__c) stdController.getRecord();
        this.stdController = stdController;
        fieldsetLabel = '';
        system.debug('===================assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c======' + assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c);
        system.debug('===================assoQual.TR1__Qualification__r======' + assoQual.TR1__Qualification__r);
        fieldsetLabel = String.isNotBlank(assoQual.TR1__Qualification__c) && String.isNotBlank(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) &&
            Schema.SObjectType.TR1__Associated_Qualification__c.fieldSets.getMap().containsKey(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) ?
            Schema.SObjectType.TR1__Associated_Qualification__c.fieldSets.getMap().get(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c).getLabel() : '';
    }

    public PageReference goToStandardPage() {
        String recordId = (String) assoQual.Id;
        if (assoQual.TR1__Contact__c == null || (!test.isRunningTest() && (String.isEmpty(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c) ||
                !SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().containskey(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c)))) {
            return new PageReference('/' + recordId + '/e?nooverride=1').setRedirect(true);
        } else {
            Set < String > setFields = new Set < String > {
                'TR1__Contact__c',
                'TR1__Qualification__c',
                'TR1__Qualification__r.TR1__Field_Set_ID__c'
            };
            if (!test.isRunningTest())
                for (Schema.FieldSetMember field: SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get(assoQual.TR1__Qualification__r.TR1__Field_Set_ID__c).getFields())
                    setFields.add(field.getFieldPath());
            for (Schema.FieldSetMember field: SObjectType.TR1__Associated_Qualification__c.FieldSets.page_override.getFields())
                setFields.add(field.getFieldPath());
            String strQuery = 'Select ' + String.join(new List < String > (setFields), ', ') + ' from TR1__Associated_Qualification__c where Id=:recordId limit 1';
            assoQual = database.query(strQuery);
            return null;
        }
    }

    public PageReference saveAQ() {
        String recordId = (String) assoQual.Id;
        try {
            if (assoQual.TR1__Status__c == 'Active') {
                TR1__Qualification__c qualfn = [Select Id, Require_Documents__c from TR1__Qualification__c where Id =: assoQual.TR1__Qualification__c LIMIT 1];
                List < Attachment > att = [Select Id, ParentId from Attachment where ParentId =: assoQual.Id];
                if (qualfn.Require_Documents__c == true && att.size() == 0) {
                    String error = 'At Least One Document is Required';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, error));
                    return null;
                } else {
                    update assoQual;
                    return new PageReference('/' + recordId).setRedirect(true);
                }
            } else {
                update assoQual;
                return new PageReference('/' + recordId).setRedirect(true);
            }
        } catch (DMLException e) {
            ViewAssociatedQualification.AddFatalMessage(e.getDmlMessage(0));
            return null;
        } catch (Exception e) {
            ViewAssociatedQualification.AddFatalMessage(e.getMessage());
            return null;
        }
    }
    
    /* VF UTIL FUNCTIONS */
    public static void AddInfoMessage( String s) {   
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.INFO, s));
    }

    public static void AddWarningMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.WARNING, s));
    }

    public static void AddConfirmMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, s));
    }

    public static void AddErrorMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, s));
    }

    public static void AddFatalMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.FATAL, s));
    }

    public PageReference doCancelAQ(){
        String recordId = (String) assoQual.Id;
        PageReference pg;
        return new PageReference('/'+recordId).setRedirect(true);
    }    
}