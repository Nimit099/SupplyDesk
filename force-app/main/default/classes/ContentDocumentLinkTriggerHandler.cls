/******************************************************************************
 * Name: ContentDocumentLinkTriggerHandler
 * Trigger: ContentDocumentLinkTrigger
 * Test class: ContentDocumentLinkTriggerHandler_Test
 * CreatedDate: 26 May 2022
 * Author: Prakash Mewada (MV Clouds)
 * Description: This is a Trigger Handler on ContentDocumentLinkTrigger for updating
 ******************************************************************************/
public without sharing class ContentDocumentLinkTriggerHandler {
    
    public void ContentDocumentLinkTriggerHandler() {}

    public void OnAfterInsertEvent(List<ContentDocumentLink> recordNewList){
        updateContactDocumentonLink(recordNewList);
    }

    public void updateContactDocumentonLink(List<ContentDocumentLink> newContentDocuments) {
        try{
            System.debug('In updateContactDocumentonLink()');
            Map<Id, List<ContentDocumentLink>> conLinkMap = new Map<Id, List<ContentDocumentLink>>();
            Map<Id, String> docNameMap = new Map<Id, String>();
            List<Id> contentDocIds = new List<Id>();
            List<TR1__ContactDocument__c> trCDList = new List<TR1__ContactDocument__c>();
            // List<Contact> upConList = new List<Contact>();
            // List<Id> delCDList = new List<Id>();

            for(ContentDocumentLink cdl : newContentDocuments) {
                String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(sObjName == 'Contact') {
                    if(!conLinkMap.containsKey(cdl.LinkedEntityId)) {
                        conLinkMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
                    }
                    conLinkMap.get(cdl.LinkedEntityId).add(cdl);
                    contentDocIds.add(cdl.ContentDocumentId);
                }
            }

            if(contentDocIds.size() > 0) {
                for(ContentDocument cd : [SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds]) {
                    docNameMap.put(cd.Id, cd.Title);
                    System.debug('Id --- '+cd.Id);
                    System.debug('Title --- '+cd.Title);
                }
            }

            if(conLinkMap.size() > 0) {
                for(Contact con : [SELECT Id, Name, Form_Map_Data__c FROM Contact WHERE Id IN :conLinkMap.keySet()]) {
                    if(!String.isBlank(con.Form_Map_Data__c) && con.Form_Map_Data__c.contains('GFormContact')) {
                        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                        if(conLinkMap.get(con.Id) != null) {
                            cdList = conLinkMap.get(con.Id);
                        }
                        if(cdList.size() == 1){
                            TR1__ContactDocument__c trCD = new TR1__ContactDocument__c();
                            if(docNameMap.get(cdList[0].ContentDocumentId) != null){
                                trCD.Name = docNameMap.get(cdList[0].ContentDocumentId);
                            }else{
                                trCD.Name = 'Document-'+cdList[0].ContentDocumentId;
                            }
                            trCD.TR1__Contact__c = con.Id;
                            trCD.TR1__ContentDocumentId__c = cdList[0].ContentDocumentId;
                            trCD.TR1__Type__c = 'Resume';
                            trCDList.add(trCD);

                            // delCDList.add(cdList[0].Id);
                            // con.Form_Map_Data__c = '';
                            // upConList.add(con);
                        }
                    }
                }
            }

            if(trCDList.size() > 0) {
                insert trCDList;
                System.debug('Inserted ContactDocument Record.');
            }
            // if(upConList.size() > 0) {
            //     update upConList;
            //     System.debug('Updated Contact Record.');
            // }
            // if(delCDList.size() > 0) {
            //     delete [SELECT Id FROM ContentDocumentLink WHERE Id IN :delCDList];
            //     System.debug('Deleted ContentDocumentLink.');
            // }
        }catch(Exception e) {
            System.debug('Exception :: In updateContactDocumentonLink() Method :: ContentDocumentLinkTriggerHandler class ----> '+e.getMessage()+' || '+e.getStackTraceString());
        }
    }
}