/******************************************************************************
 * Name: ContentDocumentLinkTrigger
 * Handler: ContentDocumentLinkTriggerHandler
 * CreatedDate: 26 May 2022
 * Author: Prakash Mewada (MV Clouds)
 * Description: This is a Trigger on ContentDocumentLink Object for updating
 ******************************************************************************/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (After insert) {
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
    if(Trigger.isAfter && Trigger.isInsert) {
        handler.OnAfterInsertEvent(Trigger.new);
    }
}