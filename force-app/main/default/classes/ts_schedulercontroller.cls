/*******************************************************
* Name          : ts_schedulercontroller
* Author        : Nitin
* Create Date   : 26/07/2022
* UsedBy        : ts_scheduler components
* Description   : ts_schedulercontroller
* Test Class    : test_ts_schedulercontroller
* Code Coverage : 

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Nitin                       18/08/2022          Change in displaySelectedDateAvailability method. Sorted List in Ascending order.

*******************************************************/


public without sharing class ts_schedulercontroller {
    
    @AuraEnabled(cacheable=true)
    public static List<Candidate_Availability__c> fetchData(){
        try {
            User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId()];
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
            }
            return [SELECT Id,Start_Date_Time__c,End_Date_Time__c,Candidate__c,Start_Date__c,End_Date__c,Type__c FROM Candidate_Availability__c WHERE Candidate__c =: loggedInUser.contactId ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_schedulercontroller', 'fetchData');
            throw new AuraHandledException(e.getMessage());
        }
    }

    //? actually no need to return anything here because delete event will store in backend only
    @AuraEnabled
    public static void deleteCalEvent(Id eventid) {
        try {
            
            if (eventid !=null) {
                List<Candidate_Availability__c> availablity = [Select Id from Candidate_Availability__c where id =:eventId];
                if(availablity != null && availablity.size() > 0) {
                    delete availablity;
                    eventId = null;
                    fetchData();
                }
            }    else {
                List<Closing_Report_Schedule__c> crsListToBeUpdated = new List<Closing_Report_Schedule__c>();
                for(Closing_Report_Schedule__c crs : [Select Id from Closing_Report_Schedule__c where Id =:eventId]){
                    crs.Status__c = 'Cancelled';
                    crsListToBeUpdated.add(crs);
                }

                if(crsListToBeUpdated != null && crsListToBeUpdated.size() > 0) {
                    update crsListToBeUpdated;
                    eventId = null;
                    fetchData();
                }
            }
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_schedulercontroller', 'deleteCalEvent');
        }
    }

    @AuraEnabled
    public static Id saveCreateAvailRecord(String wrapperdata) {
        try {
            String contactId;
            if (String.isBlank(wrapperdata)) {
                return null;
            }
            
            Set<String> daySet = new Set<String>();

            Map<String,Object> eventMap = (Map<String, Object>) JSON.deserializeUntyped(wrapperdata);
            if(eventMap.get('mon') == true){daySet.add('Monday');}
            if(eventMap.get('tue') == true){daySet.add('Tuesday');}
            if(eventMap.get('wed') == true){daySet.add('Wednesday');}
            if(eventMap.get('thu') == true){daySet.add('Thursday');}
            if(eventMap.get('fri') == true){daySet.add('Friday');}
            if(eventMap.get('sat') == true){daySet.add('Saturday');}
            if(eventMap.get('sun') == true){daySet.add('Sunday');}

            String std = (String)eventMap.get('startDate');
            
            String endd = (String)eventMap.get('EndDate');

            Integer actualNoOfDays = Date.valueOf(std).daysBetween(Date.valueOf(endd));
    
            Candidate_Availability__c newCavail = new Candidate_Availability__c();
            newCavail.Type__c = eventMap.get('TypeValue') !=null ? (String)eventMap.get('TypeValue') :null;
    
            String startDate = eventMap.get('startDate') != null ? ((String)eventMap.get('startDate')).replace('T', ' '):null;
            
            String EndDate = eventMap.get('EndDate') != null ? 
                                ((String)eventMap.get('EndDate')).replace('T', ' '): 
                                null;
            
            newCavail.Start_Date_Time__c = startDate!=null ?  Datetime.valueOfGmt(startDate) : null;
            newCavail.End_Date_Time__c = EndDate != null ? Datetime.valueOfGmt(EndDate) : null;
            
            //todo uncomment the below logic for date conversion
            Datetime value = newCavail.Start_Date_Time__c;
            Datetime valueE = newCavail.End_Date_Time__c;

            String selectedDay = value.format('EEEE');
            
            Date sDateonly = Date.valueOf((newCavail.Start_Date_Time__c).date());       //? only for the start date value
            Date eDateOnly = Date.valueOf((newCavail.end_Date_Time__c).date());         //? only for the end date value
    
            id conId = [SELECT id,contactid from user where id=:userinfo.getuserId()].contactid;
            if(conId!=null)
                newCavail.Candidate__c	= conId;
            
            newCavail.Start_Date__c = sDateonly;
            newCavail.End_Date__c = eDateOnly;
    
            insert newCavail;
    
            return newCavail.Id;
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_schedulercontroller', 'saveCreateAvailRecord');
            return null;
        }
    }

    @AuraEnabled
    public static List<Candidate_Availability__c> saveDateRange(String wrapperdata){
        try{
            Set<String> daySet = new Set<String>();
            List<String> caIds = new List<String>();
            Id contactId = [SELECT id,contactid from user where id=:userinfo.getuserId()].contactid;
            
            List<Candidate_Availability__c> candidateAvailablityToAdd = new List<Candidate_Availability__c>();
            Map<String,Object> eventMap = (Map<String, Object>) JSON.deserializeUntyped(wrapperdata);

            if(eventMap.get('mon') == true){daySet.add('Monday');}
            if(eventMap.get('tue') == true){daySet.add('Tuesday');}
            if(eventMap.get('wed') == true){daySet.add('Wednesday');}
            if(eventMap.get('thu') == true){daySet.add('Thursday');}
            if(eventMap.get('fri') == true){daySet.add('Friday');}
            if(eventMap.get('sat') == true){daySet.add('Saturday');}
            if(eventMap.get('sun') == true){daySet.add('Sunday');}
    
            String std = (String)eventMap.get('startDate');
            
            String endd = (String)eventMap.get('EndDate');

            String StartDate = (String)eventMap.get('sd_dr');

            String EndDate = (String)eventMap.get('ed_dr');

            String startTime = (String)eventMap.get('st_dr');

            String endTime = (String)eventMap.get('et_dr');

            Integer actualNoOfDays = Date.valueOf(StartDate).daysBetween(Date.valueOf(EndDate));

            for(Integer i = 0; i <= actualNoOfDays; i++){
                Date iterableDate = Date.valueOf(StartDate) + i;
                String s = String.valueOf(Date.valueOf(iterableDate));
                s = s.split(' ')[0];       
                Date d = Date.valueOf(s);         
                DateTime DateValue = Datetime.valueOfGmt(iterableDate + ' ' + startTime + ':00.000Z');
                String selectedDay = DateValue.format('EEEE');       
                if(daySet.contains(selectedDay)){
                    if(StartDate!=null){
                        candidateAvailablityToAdd.add(
                            new Candidate_Availability__c(
                                Start_Date__c = iterableDate,
                                Start_Date_Time__c = Datetime.valueOfGmt(s + ' ' + startTime + ':00.000Z'),
                                Candidate__c = contactId,
                                End_Date__c = iterableDate,
                                End_Date_Time__c = Datetime.valueOfGmt(s + ' ' + endTime + ':00.000Z'),
                                Type__c = eventMap.get('TypeValue') !=null ? (String)eventMap.get('TypeValue') :null
                            )
                        );   
                    }
                }
            }   
            if(candidateAvailablityToAdd.size() > 0){
                insert candidateAvailablityToAdd;
            }

            for(Candidate_Availability__c ca : candidateAvailablityToAdd){
                caIds.add(ca.Id);
            }
            return candidateAvailablityToAdd;
            
        }catch(Exception e){
            System.debug(e);
            return null;
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 26/07/2022
    * Last Modified Date : 18/08/2022
    * UsedBy             : ts_scheduler Component
    * Description        : For displying avability record in selected date (Right Side DIV).
    ***************************************************/
    @AuraEnabled
    public static List<Candidate_Availability__c> displaySelectedDateAvailability(Date dateofAvail) {
        
        Datetime sdDateofAvail = dateofAvail;
        Datetime edDateofAvail = datetime.newInstance(dateofAvail.year(), dateofAvail.month(),dateofAvail.day(), 24,59,59);

        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<Candidate_Availability__c> avabilityList;
        try {
            avabilityList = [SELECT Id,Start_Date_Time__c,End_Date_Time__c,Candidate__c,Start_Date__c,End_Date__c,Type__c FROM Candidate_Availability__c 
            WHERE ((Start_Date_Time__c <=: edDateofAvail) AND (End_Date_Time__c >=: sdDateofAvail)) AND Candidate__c =: currentUser.ContactId  ORDER BY Start_Date_Time__c ASC];
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_schedulercontroller', 'displaySelectedDateAvailability');
        }
        return avabilityList;
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 05/09/2022
    * Last Modified Date : 05/09/2022
    * UsedBy             : ts_scheduler Component
    * Description        : For displying avability record when month and week button Clicked (Right Side DIV).
    ***************************************************/

    @AuraEnabled
    public static monthAvailibiltyWrapper displayMonthWeekAvailability(Datetime startDateAvail, Datetime endDateAvail) {
        
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<Candidate_Availability__c> avabilityList;
        Map<String, List<Candidate_Availability__c>> avaibilityMap = new Map<String, List<Candidate_Availability__c>>();
        Integer availableCount = 0;
        Integer unavailableCount = 0;
        Integer bookedByAnother = 0;
        monthAvailibiltyWrapper maw = new monthAvailibiltyWrapper();
        try {
            avabilityList = [SELECT Id,Start_Date_Time__c,End_Date_Time__c,Candidate__c,Start_Date__c,End_Date__c,Type__c FROM Candidate_Availability__c 
            WHERE (Start_Date_Time__c <: endDateAvail AND Start_Date_Time__c >=: startDateAvail) AND Candidate__c =: currentUser.ContactId  ORDER BY Start_Date_Time__c ASC];
            
            for (Candidate_Availability__c cal : avabilityList) {
                String currentDay = cal.Start_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', 'UTC').substring(8,10) + ' ' + cal.Start_Date_Time__c.format('MMMMM');
                
                if (avaibilityMap.containsKey(currentDay)) {
                    avaibilityMap.get(currentDay).add(cal);
                } else {
                    avaibilityMap.put(currentDay, new List<Candidate_Availability__c> { cal });
                }

                if (cal.Type__c == 'Available') {
                    availableCount +=1;
                } else if (cal.Type__c == 'Unavailable'){
                    unavailableCount +=1;
                } else if (cal.Type__c == 'Working for Another Agency'){
                    bookedByAnother +=1;
                }
            }
            maw.availableCount = availableCount;
            maw.unavailableCount = unavailableCount;
            maw.bookedByAnother = bookedByAnother;
            maw.monthAvailMap = avaibilityMap;
        
        } catch (Exception e) {
            System.debug(e);
            GenericException exp = ExceptionHandler.logException(e, 'ts_schedulercontroller', 'displaySelectedDateAvailability');
        }
        return maw;
    }

    public class monthAvailibiltyWrapper{
        @AuraEnabled public Integer availableCount;
        @AuraEnabled public Integer unavailableCount;
        @AuraEnabled public Integer bookedByAnother;
        @AuraEnabled public Map<String, List<Candidate_Availability__c>> monthAvailMap;
    }
}