/************************************************************************************************************************
Trigger Name:          VacancyTrigger
Object:                TR1__Job__c
Events:                after delete, after insert, after undelete, after update
Created By: 
Created Date:          December 2014    
Description:           This trigger fires when a DML operation is done on TR1__Job__c object and is used to call the 
                       TRS_VacancyHelper class which in-turn performs the logic.
Modification History:  15 Dec 2013 >> Version 1.0 >> Created   
                       28 Jan 2014 >> Version 1.1 >> Updated to add logic to calculate sum of Outstanding Pipeline from vacancy to Account  (Chirag Mehta)           
************************************************************************************************************************/
trigger VacancyTrigger on TR1__Job__c (after delete, after insert, after undelete, after update){

    
    if(trigger.isAfter && trigger.isInsert) {
        
        TRS_VacancyHelper.insertD2DVacancy(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
          if(!TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY) {
                TRS_VacancyHelper.EXECUTED_UPDATE_D2D_VACANCY = true;
                    TRS_VacancyHelper.updateD2DVacancyRecord(trigger.new, trigger.oldMap);
          }
          TRS_VacancyHelper.changeStatusOfCR(trigger.new, trigger.oldMap);
    }
}