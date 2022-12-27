public class ts_HomePageController {

    
    @AuraEnabled
    public static Contact fetchContact(){

        Id idContact = [SELECT Id, ContactId FROM User where Id=: UserInfo.getUserId()].ContactId;

        if(idContact != null){
            Contact con = [SELECT Id,Community_Contact_Type__c, Consol_URL__c FROM Contact WHERE Id = :idContact];
            System.debug('con>>>'+con);
            return con;
        }
        return null;    
    }
}