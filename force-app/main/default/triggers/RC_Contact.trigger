trigger RC_Contact on Contact (before Insert, After Insert,  Before update) {
    
    RC_ContactHandler objContactHandler = new RC_ContactHandler();
    
    if(Trigger.isInsert && Trigger.isAfter)
        objContactHandler.onAfterInsert(Trigger.newMap, Trigger.new, Trigger.oldMap);
    
    if(Trigger.isUpdate &&  Trigger.isBefore)
        objContactHandler.onBeforeUpdate(Trigger.New, Trigger.oldMap);

}