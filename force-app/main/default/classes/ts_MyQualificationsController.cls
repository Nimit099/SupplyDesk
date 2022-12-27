public without sharing class ts_MyQualificationsController {


    @AuraEnabled
    public static List<TR1__Associated_Qualification__c> getQualification(){
        try {

            User usr = [SELECT Id,ContactId FROM User Where Id=:UserInfo.getUserId()];
            List<Schema.FieldSetMember> lstFieldSet = new List<Schema.FieldSetMember>(); 
            Contact con = [SELECT Id FROM Contact WHERE Id =: usr.ContactId]; //Added for test
            System.debug('test');
            List<TR1__Associated_Qualification__c> qualiList = new List<TR1__Associated_Qualification__c>();
            String fieldNames ='';
            String strQuery = 'Select Id'; 
            lstFieldSet = SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get('RC_QualificationInfo').getFields(); 
            
            for(Schema.FieldSetMember field : lstFieldSet){
                fieldNames += ', ' + field.getFieldPath();
            }
            
            strQuery  += fieldNames + ' from TR1__Associated_Qualification__c where TR1__Contact__c = \'' + con.Id + '\' ORDER BY Name ASC' ;      
            qualiList = Database.query(strQuery);
            return qualiList;
            
        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            GenericException Exp = ExceptionHandler.logException(e, 'ts_MyQualificationsController', 'getQualification');
            return null;
        }


    }
}