public with sharing class RC_ContactAssociatedQualifications  {
    
    public RC_ContactAssociatedQualifications()
    {
        
    }
    
    public void onAfterInsert(Map<Id, Contact> mapOldContact, List<Contact> lstNewContact)
    {
         createAQRecords(mapOldContact,lstNewContact);
    }
    
    public void onAfterUpdate(Map<Id, Contact> mapOldContact, List<Contact> lstNewContact)
    {
        createAQRecords(mapOldContact,lstNewContact);
    }
  
    private void createAQRecords(Map<Id, Contact> mapOldContactParam, List<Contact> lstNewContact)
    {
        Map<String, TR1__Associated_Qualification__c> assQlfToUpsert = new Map<String, TR1__Associated_Qualification__c>();
        Map<String, List<TR1__Associated_Qualification__c>> mapPayType_ListAssoQual  = new Map<String, List<TR1__Associated_Qualification__c>>();
        Map<Id, String> mapContactIdToPayType = new Map<Id, String>();
        Map<Id, Contact> mapOldContact  = mapOldContactParam;
        Map<String,TR1__Associated_Qualification__c> mapExternalId = New Map<String,TR1__Associated_Qualification__c>();
        List<String> externalIdStringList = New List<String>();
        List<TR1__Associated_Qualification__c> oldAQList = New List<TR1__Associated_Qualification__c>();
        List<Id> contactIds = New List<Id>();
        
        for(Contact contact :lstNewContact)
        {
            if(trigger.isUpdate && (contact.Pay_Type__c != mapOldContact.get(contact.Id).Pay_Type__c || (contact.Override_AQ_Upsertion__c && contact.Override_AQ_Upsertion__c != mapOldContact.get(contact.Id).Override_AQ_Upsertion__c)) )
                mapContactIdToPayType.put(contact.Id, contact.Pay_Type__c);
            if(trigger.isInsert  ){
                mapContactIdToPayType.put(contact.Id, contact.Pay_Type__c);
            }
            
            contactIds.add(contact.Id);
        }
        system.debug('===============================contactIds====='+contactIds);
        system.debug('===============================mapContactIdToPayType====='+mapContactIdToPayType);
        // Modified by Bashetty Naveen on May-22-2017 W-005637 . start===
        List<TR1__Qualification_Package__c> listqps = [Select Id,TR1__Name__c, (Select Id, TR1__Qualification__c, TR1__Qualification_Package__c,qualificationName__c,TR1__External_ID__c From TR1__Associated_Qualifications__r WHERE TR1__Contact__c = null) 
                                                From TR1__Qualification_Package__c Where TR1__Name__c IN : mapContactIdToPayType.values() LIMIT 5000];
        for(TR1__Qualification_Package__c qp : listqps)
        {
            mapPayType_ListAssoQual.put(qp.TR1__Name__c, qp.TR1__Associated_Qualifications__r);
        } // end 
        
        // to create map for existing TR1__External_ID__c 
        //When compliance package changes, to retain value of  Clear_DBS__c flag on DBS AQ.
        oldAQList = [SELECT ID,TR1__External_ID__c,Clear_DBS__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c IN : contactIds ];
        for( TR1__Associated_Qualification__c aq : oldAQList){
            if(aq.TR1__External_ID__c != null){
                mapExternalId.put(aq.TR1__External_ID__c,aq);
            }
        }

        system.debug('===============================mapPayType_ListAssoQual====='+mapPayType_ListAssoQual);
        for(Id conId :  mapContactIdToPayType.keyset())
        {
            if(String.isNotEmpty(mapContactIdToPayType.get(conId)) && mapPayType_ListAssoQual.containsKey(mapContactIdToPayType.get(conId)))
            {
                for(TR1__Associated_Qualification__c caq : mapPayType_ListAssoQual.get(mapContactIdToPayType.get(conId)))
                {
                    TR1__Associated_Qualification__c assQlf = new TR1__Associated_Qualification__c();
                    String qualificationName =  caq.qualificationName__c;
                    TR1__Associated_Qualification__c oldAQ = New TR1__Associated_Qualification__c();
                    String externalIDKey = conId+'_'+caq.TR1__Qualification__c;
                    if(!mapExternalId.isEmpty() && mapExternalId.containsKey(externalIDKey))
                        oldAQ = mapExternalId.get(externalIDKey);
                    
                    if(qualificationName == 'DBS' && oldAQ!=null)
                        assQlf.Clear_DBS__c = oldAQ.Clear_DBS__c; // When DBS AQ updated
                    else if(qualificationName == 'DBS' && oldAQ==null)
                        assQlf.Clear_DBS__c = false; // When DBS AQ inserted
                    else
                        assQlf.Clear_DBS__c = true;
                    assQlf.TR1__Qualification__c = caq.TR1__Qualification__c;    
                    assQlf.TR1__Qualification_Package__c = caq.TR1__Qualification_Package__c; //updated on 30 NOV 2016
                    assQlf.TR1__Contact__c = conId;
                    assQlf.TR1__External_ID__c = externalIDKey;
                    //assQlf.Source_Associated_Qualification__c = caq.Id;  //source assoc qual.
                    assQlfToUpsert.put(assQlf.TR1__External_ID__c, assQlf);
                }
            }
        }
        
        if(assQlfToUpsert.keySet().size() > 0)
            upsert assQlfToUpsert.values() TR1__External_ID__c;
    }

}