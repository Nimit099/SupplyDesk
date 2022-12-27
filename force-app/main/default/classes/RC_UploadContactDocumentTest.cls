/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RC_UploadContactDocumentTest {

    static testMethod void UploadContactDocumentTest()
    {
    	User objUser = RC_UtilityClass.returnCommunityUser();
        
        insert new TR1__TalentRoverProperties__c(SetupOwnerId=UserInfo.getOrganizationId(), TR1__Salesforce_Host__c='eu10.salesforce.com', TR1__UpdateExistingEducationHistory__c = true, TR1__UpdateExistingWorkHistory__c = true, Apex_Email_Service__c = 'emailservice@tr.com');
 

        system.runAs(objUser)
        {
	        Test.startTest();
	        	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	         	Apexpages.currentPage().getParameters().put('ExpId', '');
	        	RC_UploadContactDocument objUploadDocument = new RC_UploadContactDocument();
            Contact cName = new contact();
            cName.FirstName = 'FirstTest';
            cName.LastName = 'LastTest';
            cName.Email = 'test@test.com';
	        	insert cName;
	        	Apexpages.currentPage().getParameters().put('ExpId', objUser.contactId);
	        	RC_UploadContactDocument objUploadDocumentTest = new RC_UploadContactDocument();
            	objUploadDocumentTest.strDocumentType = 'Resume';
	        	//objUploadDocumentTest.objAttachment = objAttachment;
            objUploadDocumentTest.attbody = blob.valueOf('Test');
            objUploadDocumentTest.attname = 'test';
            objUploadDocumentTest.atttype = 'Application/WSword';

	        	objUploadDocumentTest.uploadDocument();
            	//check another type of attachment
            	objUploadDocumentTest.strDocumentType = null;
            	objUploadDocumentTest.uploadDocument();
            	
	        	objUploadDocumentTest.objAttachment.Name = 'TestAttachment';
	        	objUploadDocumentTest.objAttachment.body = bodyBlob;
	        	objUploadDocumentTest.UploadExpenseAttachment();
	        	//system.assertEquals(strContactId, objUploadDocumentTest.objAttachment.ParentId);
	        Test.stopTest();
        }
        Attachment objAttachment = [Select ParentId,IsPrivate from Attachment LIMIT 1];
        system.assertEquals(objUser.contactId, objAttachment.ParentId);
        system.assertEquals(false, objAttachment.IsPrivate);
    }
}