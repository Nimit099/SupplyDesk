public class ViewAttachmentController {
    
    @AuraEnabled
    public static String getContents(Id conId){
        return '/servlet/servlet.FileDownload?file='+[Select Id From Attachment where ParentId =: [Select Id from TR1__Associated_Qualification__c where TR1__Contact__c =: conId AND TR1__Qualification__r.Name = 'Photo' ORDER BY createdDate DESC LIMIT 1].Id ORDER BY CreatedDate DESC  LIMIT 1].Id;
    }
}