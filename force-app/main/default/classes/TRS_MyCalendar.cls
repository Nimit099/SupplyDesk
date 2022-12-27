public with sharing class TRS_MyCalendar {
    public User loggedInUser {get;set;}                                             //to store logged in  user
    public TRS_MyCalendar() {
      loggedInUser = [Select ContactId from User where Id =:  UserInfo.getUserId() limit 1];
    }
}