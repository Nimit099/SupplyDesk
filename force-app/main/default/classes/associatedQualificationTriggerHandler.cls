global class associatedQualificationTriggerHandler {
    
    global associatedQualificationTriggerHandler(){
        
    } 
    
    public string  onAfterInsert(Map<Id, TR1__Associated_Qualification__c> mapOldContact, List<TR1__Associated_Qualification__c> lstNewContact)
    {   String msg = '';
        return msg = updateContact(mapOldContact,lstNewContact);
    }
    
    public string onAfterUpdate(Map<Id, TR1__Associated_Qualification__c> mapOldContact, List<TR1__Associated_Qualification__c> lstNewContact)
    { 
        String msg = '';
        return msg = updateContact(mapOldContact,lstNewContact);
    }
   //added by veda on 26/9/2016 to join multi select picklist values.
    public static String format(set<String> values) {
      if (values == null) return null;

      List<String> l = new List<String>(values);
      return String.join(l, ';');
    }
   //End by veda on 26/9/2016.
    public string updateContact(Map<Id, TR1__Associated_Qualification__c> mapOldAQParam, List<TR1__Associated_Qualification__c> lstNewAQ)
    {
        
        Set<ID> aqIds = New Set<Id>();
        Set<ID> contactIds = New Set<Id>();
        Set<ID> updateConIds = New Set<Id>();
        List<Contact> contactList = New List<Contact>();
        List<Contact> updateContactList = New List<Contact>();
        Map<Id,Contact> contactMap = New Map<Id,Contact>();
        List<TR1__Associated_Qualification__c> aqList = New List<TR1__Associated_Qualification__c>();
        String errorMsg = '';
        For(TR1__Associated_Qualification__c aq: lstNewAQ){
            contactIds.add(aq.TR1__Contact__c);
        }
        system.debug('========================contactIds==='+contactIds);
        contactList = [SELECT ID,Barred_List_Date_Checked_Hidden__c,Qualifications_Hidden__c,Barred_List_AQ_Hidden__c,CV_AQ_Hidden__c,EWC_Registration_Date_Hidden__c,EWC_Registration_Checked_Date_Hidden__c,Perm_Qualification_AQ_Hidden__c,SET_Number_Hidden__c,SET_Checked_Date_Hidden__c,
                       NCTL_Number_Hidden__c,NCTL_Checked_Date_Hidden__c,DBS_AQ_Hidden__c,DBS_Disclosure_ID_Number_Hidden__c,DBS_Issue_Date_Hidden__c,DBS_Last_Checked_Date_Hidden__c,
                       Clear_DBS_Hidden__c,OS_Police_Check_Hidden__c,Letter_of_Good_Conduct_Hidden__c,ID_AQ_Hidden__c,Group_1_ID_Type_Hidden__c,Group_2A_ID_Type_Hidden__c,Group_2B_ID_Type_Hidden__c,QTS_Awarded_Date_Hidden__c,
                       NQT_Induction_Complete_Hidden__c,Medical_AQ_Hidden__c,DBA_AQ_Hidden__c,References_AQ_Hidden__c,TOE_AQ_Hidden__c,Right_to_Work_AQ_Hidden__c,Teacher_Qualification_Hidden__c,F2F_Interview_AQ_Hidden__c,OS_Police_Check_AQ_Hidden__c,OS_Teacher_Quals_AQ_Hidden__c,
                       Support_Quals_AQ_Hidden__c,Post_16_Quals_AQ_Hidden__c,DBA_Check_Hidden__c,QTLS_Hidden__c FROM Contact WHERE ID IN : contactIds];
        
        contactMap = New Map<Id,Contact>(contactList);
        if(contactList.size() > 0) {
            for(TR1__Associated_Qualification__c aq : lstNewAQ)  {
                String QualificationStatus = '';
                QualificationStatus = aq.TR1__Status__c != null ? aq.TR1__Status__c : '';
                String qualificationName = aq.qualificationName__c;
                Contact con = New Contact();
                if(!contactMap.isEmpty()){
                     con = contactMap.get(aq.TR1__Contact__c);
              //Added by veda on 26/9/2016 to update contact's qualification fron AQ's Qualification Type.      
                  if((aq.Qualification_Type2__c != null && aq.Qualification_Type2__c != '') && 
                     (aq.Qualification_Type__c != null && aq.Qualification_Type__c != '')){ 
                         Set<string> qualifType = New Set<string>();
                         
                    for(string str : aq.Qualification_Type__c.split(';')){ 
                        if(con.Qualifications_Hidden__c==null || !con.Qualifications_Hidden__c.contains(str))
                        qualifType.add(str); 
                     }
                         if(con.Qualifications_Hidden__c==null)con.Qualifications_Hidden__c = format(qualifType);
                         else con.Qualifications_Hidden__c += ';'+format(qualifType) ;
                     
                         
                   } 
              //End by Veda       
                 }
                if(qualificationName=='Safeguarding'){
                if(aq.Safeguarding_Training__c){
                   con.Safeguarding_Training_Hidden__c = 'Yes' ;
                }
                else{
                    con.Safeguarding_Training_Hidden__c = 'No' ;
                }
                }    
                 
                if(qualificationName == 'CV'){
                    con.CV_AQ_Hidden__c = QualificationStatus;
                }
                else if(qualificationName == 'Barred List'){
                     con.Barred_List_AQ_Hidden__c = QualificationStatus;
                     con.Barred_List_Date_Checked_Hidden__c = aq.Barred_List_Date_Checked__c;
                     con.EWC_Registration_Date_Hidden__c = aq.EWC__c;
                     con.EWC_Registration_Checked_Date_Hidden__c = aq.EWC_Registration_Checked_Date__c;
                }
                else if(qualificationName == 'Perm Qualification'){
                     con.Perm_Qualification_AQ_Hidden__c = QualificationStatus;
                     con.SET_Number_Hidden__c = aq.SET_Registration_Number__c;
                     con.SET_Checked_Date_Hidden__c = aq.SET_Checked_Date__c;
                     con.NCTL_Number_Hidden__c = aq.NCTL_Number__c;
                     con.NCTL_Checked_Date_Hidden__c = aq.NCTL_Checked_Date__c;
                     //con.QTLS_Hidden__c = aq.QTLS__c;
                     if(aq.QTLS__c)
                        con.QTLS_Hidden__c = 'Yes';
                     else if(!aq.QTLS__c)  
                        con.QTLS_Hidden__c = '';
                }
                else if(qualificationName == 'DBS'){
                     con.DBS_AQ_Hidden__c = QualificationStatus;
                     con.DBS_Disclosure_ID_Number_Hidden__c = aq.DBS_Disclosure_ID_Number__c;
                     con.DBS_Issue_Date_Hidden__c = aq.DBS_Disclosure_Valid_From__c;
                     con.DBS_Last_Checked_Date_Hidden__c = aq.DBS_Checked_Online__c;
                     if(aq.Clear_DBS__c)
                        con.Clear_DBS_Hidden__c = 'Yes';
                     else if(!aq.Clear_DBS__c)
                        con.Clear_DBS_Hidden__c = 'No';
                     con.OS_Police_Check_Hidden__c = aq.Overseas_Police_Check__c;
                     
                     if(aq.Letter_of_Good_Conduct_Received__c)
                        con.Letter_of_Good_Conduct_Hidden__c = 'Yes'; 
                     else if(!aq.Letter_of_Good_Conduct_Received__c)
                        con.Letter_of_Good_Conduct_Hidden__c = '';
                     //con.Letter_of_Good_Conduct_Hidden__c = aq.Letter_of_Good_Conduct_Received__c;
                }
                else if(qualificationName == 'ID'){
                     con.ID_AQ_Hidden__c = QualificationStatus;
                     con.Group_1_ID_Type_Hidden__c = aq.Group_1_ID_Type__c;
                     con.Group_2A_ID_Type_Hidden__c = aq.Group_2a_ID_Type__c;
                     con.Group_2B_ID_Type_Hidden__c = aq.Group_2b_ID_Type__c;
                 }
                 else if(qualificationName == 'Teacher Qualification'){
                     con.Teacher_Qualification_Hidden__c = QualificationStatus;
                     con.NCTL_Number_Hidden__c = aq.NCTL_Number__c;
                     con.NCTL_Checked_Date_Hidden__c = aq.NCTL_Checked_Date__c;
                     con.QTS_Awarded_Date_Hidden__c = aq.QTS_Awarded_Date__c;
                     if(aq.NQT_Induction_Complete__c)
                        con.NQT_Induction_Complete_Hidden__c = 'Yes';
                     else if(!aq.NQT_Induction_Complete__c)  
                        con.NQT_Induction_Complete_Hidden__c = 'No';
                     //con.NQT_Induction_Complete_Hidden__c = aq.NQT_Induction_Complete__c;
                 }
                 else if(qualificationName == 'Medical'){
                     con.Medical_AQ_Hidden__c = QualificationStatus;
                     
                 }
                 else if(qualificationName == 'References'){
                     con.References_AQ_Hidden__c = QualificationStatus;
                 }
                 else if(qualificationName == 'Disqualification by Association'){
                    con.DBA_AQ_Hidden__c = QualificationStatus;
                    /*if(aq.Disqualification_by_Association_Check__c)
                        con.DBA_Check_Hidden__c = 'Yes';
                    else if(!aq.Disqualification_by_Association_Check__c)  
                        con.DBA_Check_Hidden__c = 'No';
                    */
                    if(aq.DBA_Status__c == 'Clear')
                        con.DBA_Check_Hidden__c = 'Yes';
                    else if(aq.DBA_Status__c == 'Not Clear')  
                        con.DBA_Check_Hidden__c = 'No';
                 }
                 else if(qualificationName == 'Terms and Registration Forms'){
                     con.TOE_AQ_Hidden__c = QualificationStatus;
                 }
                 else if(qualificationName == 'Right to Work'){
                     con.Right_to_Work_AQ_Hidden__c = QualificationStatus;
                     con.Right_to_Work_Sited_Date_Hidden__c = aq.Right_to_Work_Sighted_Date__c;
                 }
                 else if(qualificationName == 'Face to Face Interview'){
                     con.F2F_Interview_AQ_Hidden__c = QualificationStatus;
                 } 
                 else if(qualificationName == 'Overseas Police Check'){
                     con.OS_Police_Check_AQ_Hidden__c = QualificationStatus;
                     con.OS_Police_Check_Hidden__c = aq.Overseas_Police_Check__c;
                     //con.Letter_of_Good_Conduct_Hidden__c = aq.Letter_of_Good_Conduct_Received__c;
                     if(aq.Letter_of_Good_Conduct_Received__c) 
                        con.Letter_of_Good_Conduct_Hidden__c = 'Yes';
                     else if(!aq.Letter_of_Good_Conduct_Received__c)
                        con.Letter_of_Good_Conduct_Hidden__c = '';
                 }
                 else if(qualificationName == 'Overseas Teacher Qualifications'){
                     con.OS_Teacher_Quals_AQ_Hidden__c = QualificationStatus;
                     con.NCTL_Number_Hidden__c = aq.NCTL_Number__c;
                     con.NCTL_Checked_Date_Hidden__c = aq.NCTL_Checked_Date__c;
                     con.QTS_Awarded_Date_Hidden__c = aq.QTS_Awarded_Date__c;
                 }
                 else if(qualificationName == 'Early Years Qualifications'){
                     con.EY_Quals_AQ_Hidden__c = QualificationStatus;
                 }
                 else if(qualificationName == 'Support Qualifications'){
                     con.Support_Quals_AQ_Hidden__c = QualificationStatus;
                 }
                 else if(qualificationName == 'Post 16 Qualifications'){
                     con.Post_16_Quals_AQ_Hidden__c = QualificationStatus;
                     con.SET_Number_Hidden__c = aq.SET_Registration_Number__c;
                     con.SET_Checked_Date_Hidden__c = aq.SET_Checked_Date__c;
                     if(aq.QTLS__c)
                        con.QTLS_Hidden__c = 'Yes';
                     else if(!aq.QTLS__c)  
                        con.QTLS_Hidden__c = '';
                     //con.QTLS_Hidden__c = aq.QTLS__c;
                 }
                 else if(qualificationName == 'Overseas DBS Check'){
                     con.OS_DBS_AQ_Hidden__c = QualificationStatus;
                 }
                
                if(con != null) {
                    if(updateConIds == null){
                         updateConIds.add(con.Id); 
                    }
                    else if(!updateConIds.contains(con.Id) && updateConIds != null) {   
                        updateConIds.add(con.Id); 
                        updateContactList.add(con);
                    }    
                }
            } // end for   
        }// end of If
         try{
             if(updateContactList.size() > 0){
                 system.debug('========================updateContactList==='+updateContactList);
                    update updateContactList;
             }        
          } 
        catch(DMLException ex){
            System.debug('==============Exception ======'+ex.getDMLMessage(0));
            errorMsg = ex.getDMLMessage(0);
        } 
        catch(Exception ex){
            System.debug('==============Exception ======'+ex.getMessage() + ' at ' + ex.getLineNumber());
            errorMsg = ex.getMessage();
        }  
      
        return errorMsg;
    }
    
    
}