public without sharing class ts_Compilance {
    public ts_Compilance() {

    }

    // @AuraEnabled
    // public static string getpdfData(String crID){
    //     try {
    //         System.debug('Closing Report id-->'+crID);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    @AuraEnabled
    public static List<TR1__Closing_Report__c> getcrdata(String userid){
        try {
            System.debug('getcrdata');
            Id loggedInUserId = [SELECT Id, ContactId FROM User where Id =: userid].ContactId;
            List<TR1__Closing_Report__c> crlist = [SELECT Id, Name, TR1__Person_Placed__c FROM TR1__Closing_Report__c WHERE TR1__Person_Placed__c =: loggedInUserId];
            System.debug('crlist-->'+crlist);
            return crlist;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }
}