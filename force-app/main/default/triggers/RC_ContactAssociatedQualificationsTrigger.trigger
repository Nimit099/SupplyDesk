// Trigger to Create Associated Qualifications on Job When Add Associated Qualifications checkbox is checked
// It Pull all Associated Qualifications from Client and UPSERT them for Job also
// After creating Associated Qualifications, we are updating Add Associated Qualifications checkbox to false
trigger RC_ContactAssociatedQualificationsTrigger on Contact (after insert, after update) {
    RC_ContactAssociatedQualifications objAQ = new RC_ContactAssociatedQualifications();
    if(trigger.isAfter && trigger.isInsert)
        objAQ.onAfterInsert(Trigger.oldMap, Trigger.new);
    else if(trigger.isAfter && trigger.isUpdate)
        objAQ.onAfterUpdate(Trigger.oldMap, Trigger.new);
}