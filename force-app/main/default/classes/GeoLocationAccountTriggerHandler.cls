public class GeoLocationAccountTriggerHandler {
    public static void onAfterInsert(List<Account> triggerNew){
        insertForGeolocation(triggerNew);
    }
    public static void afterUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        updateForGeolocation(triggerNew, triggerOldMap);
    }
    
    public static void insertForGeolocation(List<Account> triggerNew){
        for(Account acc : triggerNew){
            System.debug(LoggingLevel.DEBUG, '***Geocoding Account - ' + acc.Name);
            SiteGeocodeAddressAccount.DoAddressGeocode(acc.id);
        }
    }
    
    public static void updateForGeolocation(List<Account> triggerNew, Map<Id, Account> triggerOldMap){       
        for(Account acc : triggerNew){
            Boolean addressChangedFlag = false;
            Account oldcSite = triggerOldMap.get(acc.Id);
            if((acc.BillingStreet != oldcSite.BillingStreet) || 
               (acc.BillingCity != oldcSite.BillingCity) ||
               (acc.BillingState != oldcSite.BillingState) ||
               (acc.BillingCountry != oldcSite.BillingCountry) || 
               (acc.BillingPostalCode != oldcSite.BillingPostalCode)){              
                   addressChangedFlag = true;                   
                   System.debug(LoggingLevel.DEBUG, '***Address changed for - ' + oldcSite.Name);
			}
            // if address is null or has been changed, geocode it
            if ((acc.Set_Account_GeoLocation__Latitude__s == null) || (addressChangedFlag == true)) {
                System.debug(LoggingLevel.DEBUG, '***Geocoding Account - ' + acc.Name);
                SiteGeocodeAddressAccount.DoAddressGeocode(acc.id);
            }
        }       
    }
}