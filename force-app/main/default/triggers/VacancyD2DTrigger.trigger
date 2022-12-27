/************************************************************************************************************************
Trigger Name:          VacancyD2DTrigger
Object:                Vacancy_D2D__c
Events:                after Update
Created By: 
Created Date:          December 2014    
Description:           This trigger fires when a DML operation is done on Vacancy_D2D__c object and is used to call the 
                       VacancyD2DHelper class which in-turn performs the logic.
Modification History:  15 Dec 2013 >> Version 1.0 >> Created                
************************************************************************************************************************/
trigger VacancyD2DTrigger on Vacancy_D2D__c (before insert, before update, before delete, after insert , after update , after delete) {
	VacancyD2DTriggerHandler vth = new VacancyD2DTriggerHandler(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
	
	if(trigger.isBefore && trigger.isInsert){
		vth.onBeforeInsertEvents();
	}
	else if(trigger.isBefore && trigger.isUpdate){
		vth.onBeforeUpdateEvents();
	}
	else if(trigger.isBefore && trigger.isDelete){
		vth.onBeforeDeleteEvents();
	}
}