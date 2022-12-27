trigger AgreementTrigger on echosign_dev1__SIGN_Agreement__c (Before update, After insert, After update) {

    AgreementTriggerHandler handler = new AgreementTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    
    if(trigger.isBefore){
        // if(trigger.isInsert){
        //     handler.BeforeInsertEvent();
        // }
    // else 
        if(trigger.isUpdate){
                handler.BeforeUpdateEvent();
        }
        // else if(trigger.isDelete){
    //         handler.BeforeDeleteEvent();
    }

    if(trigger.isAfter){
        // if(trigger.isInsert){
        //     handler.AfterInsertEvent();
        // }else 
        if(trigger.isUpdate){
            if(!AgreementTriggerHandler.recursionController){
                AgreementTriggerHandler.recursionController = true;
                handler.AfterUpdateEvent();
            }
        }
        // else if(trigger.isDelete){
        //     handler.AfterDeleteEvent();
        // }else if(trigger.isUndelete){
        //     handler.AfterUndeleteEvent();
        // }
    }
}