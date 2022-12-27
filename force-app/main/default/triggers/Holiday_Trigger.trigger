trigger Holiday_Trigger on Holiday__c (after insert , after update ,after delete) {

    if(trigger.isAfter && trigger.isInsert){
        
        if(Holiday_Helper.APPLY_HOLIDAY_FOR_VACANCY) {
            //Holiday_Helper.APPLY_HOLIDAY_FOR_VACANCY = false;
            // Delete Holiday Schedules on Vacancy
            Holiday_Helper.deleteHolidaySchedules(trigger.new);
        }

        if(Holiday_Helper.CREATE_HOLIDAY_ON_VACANCY) {
            //Holiday_Helper.CREATE_HOLIDAY_ON_VACANCY = false;
            // Create Holiday record for Vacancy
            Holiday_Helper.createHolidayOnVacancy(trigger.new);
        }
    }

    if(trigger.isAfter && trigger.isUpdate){
        
        // Update the Holiday record on Vacancy when Account Holiday is updated.
        Holiday_Helper.updateVacancyHolidays(trigger.newMap, trigger.oldMap);

        // Update the Vacancy Schedule Records when Holiday record on Vacancy is updated.
        Holiday_Helper.updateVacancyHolidaySchedules(trigger.newMap, trigger.oldMap);

        Holiday_Helper.CreateD2DonHolidayUpdate(trigger.newMap, trigger.oldMap);
    }

    if(trigger.isAfter && trigger.isDelete){
        if(!Holiday_Helper.Execute_OnDelete_Holiday){
            Holiday_Helper.Execute_OnDelete_Holiday = true;

            // Delete Holiday on Vacancy when Holiday on Account is deleted.
            Holiday_Helper.deleteHolidayOnVaccancy(trigger.old); 
        }

        // Delete Vacancy Schedule records when Holiday on Vacancy is deleted.
        Holiday_Helper.createD2DonVacancyOnHolidayDelete(trigger.old);
    }
}