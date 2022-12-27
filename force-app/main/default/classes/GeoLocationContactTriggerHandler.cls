public class GeoLocationContactTriggerHandler {
    public static void onAfterInsert(List<Contact> triggerNew){
        insertForGeolocation(triggerNew);
    }
    public static void afterUpdate(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap){
        updateForGeolocation(triggerNew, triggerOldMap);
    }
    
    public static void insertForGeolocation(List<Contact> triggerNew){
        for(Contact cs : triggerNew){
            if(cs.OtherStreet  != null  || cs.OtherCity  != null  || cs.OtherState  != null  || cs.OtherCountry != null  ||cs.OtherPostalCode != null){
                System.debug(LoggingLevel.DEBUG, '***Geocoding Contact - ' + cs.Name);
                SiteGeocodeAddress.DoAddressGeocode(cs.id);
            }
        }
    }
    
    public static void updateForGeolocation(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap){       
        for(Contact cs : triggerNew){
            Boolean addressChangedFlag = false;
            Boolean isaddressnullFlag = True;
            Contact oldcSite = triggerOldMap.get(cs.Id);
            if((cs.OtherStreet != oldcSite.OtherStreet) || 
               (cs.OtherCity != oldcSite.OtherCity) ||
               (cs.OtherState != oldcSite.OtherState) ||
               (cs.OtherCountry != oldcSite.OtherCountry) || 
               (cs.OtherPostalCode != oldcSite.OtherPostalCode)){              
                   addressChangedFlag = true;                   
                   System.debug(LoggingLevel.DEBUG, '***Address changed for - ' + oldcSite.Name);
            }
            if(cs.OtherStreet  != null  || cs.OtherCity  != null  || cs.OtherState  != null  || cs.OtherCountry != null  ||cs.OtherPostalCode != null){
               isaddressnullFlag = False;
            }
            // if address is null or has been changed, geocode it
            if ((cs.Set_Contact_GeoLocation__Latitude__s == null && !isaddressnullFlag) || (addressChangedFlag == true)) {
                System.debug(LoggingLevel.DEBUG, '***Geocoding Contact - ' + cs.Name);
                SiteGeocodeAddress.DoAddressGeocode(cs.id);
            }
        }       
    }
}