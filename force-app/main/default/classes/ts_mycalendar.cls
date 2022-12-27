public with sharing class ts_mycalendar {
    
    // @AuraEnabled public User loggedInUser = new User();                                             //to store logged in  user

    @AuraEnabled
    public static List<Contact> getContactId() {
      return [SELECT Id FROM Contact WHERE Id = '0030C00000SPlMiQAL'];
    //   return loggedInUser.ContactId;
    }
    
}