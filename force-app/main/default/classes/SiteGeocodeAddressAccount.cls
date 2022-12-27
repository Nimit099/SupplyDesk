public class SiteGeocodeAddressAccount {
    
    // static variable to determine if geocoding has already occurred
    private static Boolean geocodingCalled = false;
    // wrapper method to prevent calling future methods from an existing future context
    public static void DoAddressGeocode(id accId) {
        geocodeAddress(accId);
    }
    
    // we need a future method to call Google Geocoding API from Salesforce
    @future (callout=true)
    static private void geocodeAddress(id accId)
    { 
        
        String apiKey = null;
        Google_Map_API__c gApi = Google_Map_API__c.getInstance();
        if(gApi != null && String.isNotBlank(gApi.API_Key__c)){
            apiKey = gApi.API_Key__c;
        }
        // Key for Google Maps Geocoding API
        String geocodingKey = apiKey;
        
        // get the passed in address
        Account geoAcc = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                          FROM Account WHERE id = :accId];
        
        // check that we have enough information to geocode the address
        if ((geoAcc.BillingStreet == null) || (geoAcc.BillingCity == null)) {
            System.debug(LoggingLevel.WARN, 'Insufficient Data to Geocode Address');
            return;
        }
        // create a string for the address to pass to Google Geocoding API
        String geoAddress = '';
        if (geoAcc.BillingStreet != null)
            geoAddress += geoAcc.BillingStreet + ', ';
        if (geoAcc.BillingCity != null)
            geoAddress += geoAcc.BillingCity + ', ';
        if (geoAcc.BillingState != null)
            geoAddress += geoAcc.BillingState + ', ';
        if (geoAcc.BillingCountry != null)
            geoAddress += geoAcc.BillingCountry + ', ';
        if (geoAcc.BillingPostalCode != null)
            geoAddress += geoAcc.BillingPostalCode;
        
        // encode the string so we can pass it as part of URL
        geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');
        //build and make the callout to the Geocoding API
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + geoAddress + '&key=' + geocodingKey + '&sensor=false');
        request.setMethod('GET');
        request.setTimeout(60000);
        try {
            JSONParser responseParser;
            if(!Test.isRunningTest()) {
                // make the http callout
                HttpResponse response = http.send(request);
                // parse JSON to extract co-ordinates
                System.debug('===response.getBody()===' + response.getBody());  
                responseParser = JSON.createParser(response.getBody());
            }else {
                String resBody = '{"results" : [{"address_components" : [{"long_name" : "TestCity","short_name" : "TestCity","types" : '
                                + '[ "locality", "political" ]},{"long_name" : "TestState","short_name" : "RJ","types" : '
                                + '[ "administrative_area_level_1", "political" ]},{"long_name" : "India","short_name" : "IN","types" : '
                                + '[ "country", "political" ]},{"long_name" : "222222","short_name" : "222222","types" : [ "postal_code" ]}],'
                                + '"formatted_address" : "TestStreet, TestCity, TestState 222222, India","geometry" : {"location" : '
                                + '{"lat" : 26.8768473,"lng" : 75.80293159999999},"location_type" : "GEOMETRIC_CENTER","viewport" : {"northeast" : '
                                + '{"lat" : 26.8781962802915,"lng" : 75.80428058029149},"southwest" : {"lat" : 26.87549831970849,"lng" : 75.80158261970848}}},'
                                + '"place_id" : "ChIJiUHgcyy0bTkRJpRQmwX_Lzo","types" : [ "bank", "establishment", "finance", "point_of_interest" ]}],"status" : "OK"}';
                responseParser = JSON.createParser(resBody);
            }
            System.debug('===responseParser===' + responseParser);
            
            // initialize co-ordinates
            double latitude = null;
            double longitude = null;
            while (responseParser.nextToken() != null) {
                if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                    responseParser.nextToken();
                    while (responseParser.nextToken() != JSONToken.END_OBJECT) {
                        String locationText = responseParser.getText();
                        responseParser.nextToken();
                        if (locationText == 'lat')
                            latitude = responseParser.getDoubleValue();
                        else if (locationText == 'lng')
                            longitude = responseParser.getDoubleValue();
                    }
                }
            }
            // update co-ordinates on address if we get them back
            if (latitude != null) {
                geoAcc.Set_Account_GeoLocation__Latitude__s = latitude;
                geoAcc.Set_Account_GeoLocation__Longitude__s = longitude;
                update geoAcc;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error Geocoding Address - ' + e.getMessage());
        }
    }
}