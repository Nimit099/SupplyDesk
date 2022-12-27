@isTest
private class RC_ExpenseReportsTest 
{
	private static testMethod void test()  
	{
	    User u = RC_UtilityClass.returnCommunityContactTypeUser('c&c', 'testcc');
        User candidateUser = RC_UtilityClass.returnCommunityContactTypeUser('candidate', 'testcand');
        RC_ExpenseReports objExpenseReport = new RC_ExpenseReports();
        PageReference pg = objExpenseReport.redirectUnAuthenticatedUser();
        
        /* Create test data */
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c();
        objClosingReport.TR1__Job_Percentage__c = 20;
        objClosingReport.TR1__Candidate_Percentage__c  = 20;
        objClosingReport.TR1__Marketing_Percentage__c  = 20; 
        objClosingReport.TR1__Other_Percentage__c  = 20;
        objClosingReport.TR1__Other2_Percentage__c = 20; 
        objClosingReport.TR1__Job__c = objJob.id; 
        objClosingReport.TR1__Timesheet_Approver__c = u.ContactId;
        objClosingReport.TR1__Job_Credit__c = objJob.OwnerId;
        objClosingReport.TR1__Person_Placed__c = candidateUser.ContactId;
        insert objClosingReport;
        
        TR1__Expense_Report__c objExp = RC_UtilityClass.returnExpenseReport();
        objExp.TR1__Closing_Report__c = objClosingReport.id; 
        RC_AccessController.updateRecord(objExp);
        /* Create test data */
        
        
        System.assertEquals('/Signin',pg.getUrl());
        
        /*TR1__Expense_Report__c objExpRep = RC_UtilityClass.returnExpenseReport();*/
        objExp.TR1__Consultant__c = candidateUser.contactId;
        RC_AccessController.updateRecord(objExp);
        
        System.runAs(u)
        {
            objExpenseReport = new RC_ExpenseReports();
            pg = objExpenseReport.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg);
            
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0];  
            System.assertEquals('Submitted',objExp.TR1__Status__c);
            
            objExpenseReport.idExp = objExp.id;
            objExpenseReport.approveExp();
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0]; 
            System.assertEquals('Approved',objExp.TR1__Status__c);
            
            objExp.TR1__Status__c = 'Submitted';
            RC_AccessController.updateRecord(objExp);
            objExpenseReport.strComment = 'Test'; 
            objExpenseReport.rejectExp(); 
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0]; 
        
            System.assertEquals('Rejected',objExp.TR1__Status__c);  
            
            
        } 
	}

}