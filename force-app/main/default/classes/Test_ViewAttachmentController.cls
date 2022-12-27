@isTest
public class Test_ViewAttachmentController {
	@isTest
    static void testInsertAccount(){
                
        Contact con = new Contact();
        con.LastName = 'Demo';
        con.Compliance_Owner__c = UserInfo.getUserId();
        insert con;
        TR1__Qualification__c qul = new TR1__Qualification__c();
        qul.Name='Photo';
        insert qul;
        
        TR1__Associated_Qualification__c asst= new TR1__Associated_Qualification__c();
        asst.TR1__Status__c='Requested';
        asst.TR1__Contact__c = con.Id;
        asst.TR1__Qualification__c = qul.Id;
        Insert asst;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=asst.id;
        insert attach;
        
      	ViewAttachmentController.getContents(con.Id);
    }
}