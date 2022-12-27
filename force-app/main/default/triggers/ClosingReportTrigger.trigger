trigger ClosingReportTrigger on TR1__Closing_Report__c(after insert, before update, before insert, after update, after delete) {
    
    if(trigger.isAfter) {
        if(trigger.isUpdate){  
            // Calling createtimesheethelper to cretae timesheets
            ClosingReportTriggerHelper.updateCRS(trigger.new, trigger.OldMap,trigger.NewMap);
            ClosingReportTriggerHelper.populateSmallestDate(trigger.new,trigger.OldMap);
            
            // to send confirmetion letter pdf attachemnt and email 
            //Call future method to send Email if contact email Id is not null and Label.Send_Conf_Of_Check_Flag is true
            if(Boolean.valueOf(Label.Send_Conf_Of_Check_Flag)){
                set<Id> crIdSet = new set<Id>();
                for(TR1__Closing_Report__c cr: trigger.New ){
                    if(String.isNotBlank(cr.Hiring_manger_Email__c) && cr.Booking_Confirmed__c && cr.Booking_Confirmed__c != trigger.OldMap.get(cr.Id).Booking_Confirmed__c ){
                        crIdSet.add(cr.Id);                    
                    }
                }
                if(crIdSet.size() > 0 && !SendConfirmationLetter.sendConfirmationLetterFlag){
                    SendConfirmationLetter.sendVF(crIdSet);
                }
            } // end if 
            
        } 
            
    }
    
    if(trigger.isafter ) {
        if(trigger.isinsert){ 
            ClosingReportTriggerHelper.updateClientStatus(trigger.new);// Will used to flip the status of account.status
            ClosingReportTriggerHelper.populateSmallestDate(trigger.new, null);
            if(!ClosingReportTriggerHelper.createTimesheetsForPastOrThisWeekFlag){
              ClosingReportTriggerHelper.createTimesheetsForPastOrThisWeek(trigger.new);// Will used to flip the status of account.status
            }
            /*
            //Call future method to send Email if contact email Id is not null
            set<Id> crIdSet = new set<Id>();
            for(TR1__Closing_Report__c cr: trigger.New ){
                if(String.isNotBlank(cr.Contact_Email__c) ){
                    crIdSet.add(cr.Id);                    
                }
            }
            if(crIdSet.size() > 0 && !SendConfirmationLetter.sendConfirmationLetterFlag){
                system.debug('===== Here =====');
                SendConfirmationLetter.sendVF(crIdSet);
            }
            */
            if(!ClosingReportTriggerHelper.FromJobboard){
                ClosingReportTriggerHelper.bulkBookingfromJobboard(trigger.new); // will create the availability and booking accordingly.
            }
        }  
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
        ClosingReportTriggerHelper.populateSmallestDate(trigger.old, null);
    }
}