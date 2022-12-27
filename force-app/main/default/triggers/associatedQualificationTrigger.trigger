trigger associatedQualificationTrigger on TR1__Associated_Qualification__c (after insert, after update) {
         associatedQualificationTriggerHandler objAQ = new associatedQualificationTriggerHandler();
         String errorMessage ='';
        if(trigger.isAfter && trigger.isInsert){
            errorMessage =objAQ.onAfterInsert(Trigger.oldMap, Trigger.new); 
           // errorMessage = UpdateContactWhenAQSavedTriggerHandler.updateContact(Trigger.oldMap, Trigger.new);
        }     
        else if(trigger.isAfter && trigger.isUpdate) {
           errorMessage = objAQ.onAfterUpdate(Trigger.oldMap, Trigger.new);
            //errorMessage = UpdateContactWhenAQSavedTriggerHandler.updateContact(Trigger.oldMap, Trigger.new);
        } 
        
        if (errorMessage != null && errorMessage != '') {
                    trigger.new[0].addError(errorMessage); 
        }
        
            
}