public class AssociateQualificationTriggerHandler {
    
    List<TR1__Associated_Qualification__c> recordNewList = new List<TR1__Associated_Qualification__c>();
    List<TR1__Associated_Qualification__c> recordOldList = new List<TR1__Associated_Qualification__c>();
    Map<Id, TR1__Associated_Qualification__c> recordNewMap = new Map<Id, TR1__Associated_Qualification__c>();
    Map<Id, TR1__Associated_Qualification__c> recordOldMap = new Map<Id, TR1__Associated_Qualification__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public AssociateQualificationTriggerHandler(List<TR1__Associated_Qualification__c> newList, List<TR1__Associated_Qualification__c> oldList, Map<Id, TR1__Associated_Qualification__c> newMap, Map<Id, TR1__Associated_Qualification__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void BeforeUpdateEvent(){}
    
    public void BeforeDeleteEvent(){
        //getAssoiciateData();
    }
    
    public void AfterInsertEvent(){
        getAssoiciateData();
    }
    
    public void AfterUpdateEvent(){
        getAssoiciateData();
        updateComplianceAQ();
    }
    
    public void AfterDeleteEvent(){
        //getAssoiciateData();
    }
    
    public void AfterUndeleteEvent(){}
    
    public void getAssoiciateData(){
        Set<Id> con_ids = new set<Id>();
        Map<Id,Map<Id,List<TR1__Associated_Qualification__c>>> QualwithAssociate = new Map<Id,Map<Id,List<TR1__Associated_Qualification__c>>>();
        Map<Id,String> qualiNameMap = new Map<Id,String>();

        for(TR1__Qualification__c qual : [select Id,Name from TR1__Qualification__c]){
            qualiNameMap.put(qual.Id,qual.Name);
        }

        for(TR1__Associated_Qualification__c ast : recordNewList){
            if(ast.TR1__Contact__c != null){
                con_ids.add(ast.TR1__Contact__c);
                if(QualwithAssociate.containsKey(ast.TR1__Contact__c)){
                    Map<Id,List<TR1__Associated_Qualification__c>> temp_map = new Map<Id,List<TR1__Associated_Qualification__c>>();
                    temp_map = QualwithAssociate.get(ast.TR1__Contact__c);
                    if(temp_map.containsKey(ast.TR1__Qualification__c)){
                        temp_map.get(ast.TR1__Qualification__c).add(ast);
                    }else{
                        temp_map.put(ast.TR1__Qualification__c,new List<TR1__Associated_Qualification__c>{ast});
                    }
                }else{
                    Map<Id,List<TR1__Associated_Qualification__c>> temp_map = new Map<Id,List<TR1__Associated_Qualification__c>>();
                    temp_map.put(ast.TR1__Qualification__c,new List<TR1__Associated_Qualification__c>{ast});
                    QualwithAssociate.put(ast.TR1__Contact__c,temp_map);
                }
            }
        }

        for(TR1__Associated_Qualification__c ast : [Select Id,TR1__Contact__c,TR1__Qualification__c,TR1__Qualification__r.Name,TR1__Status__c from TR1__Associated_Qualification__c where TR1__Contact__c IN: con_ids]){
            if(QualwithAssociate.containsKey(ast.TR1__Contact__c)){
                Map<Id,List<TR1__Associated_Qualification__c>> temp_map = new Map<Id,List<TR1__Associated_Qualification__c>>();
                temp_map = QualwithAssociate.get(ast.TR1__Contact__c);
                if(temp_map.containsKey(ast.TR1__Qualification__c)){
                    temp_map.get(ast.TR1__Qualification__c).add(ast);
                }else{
                    temp_map.put(ast.TR1__Qualification__c,new List<TR1__Associated_Qualification__c>{ast});
                }
            }else{
                Map<Id,List<TR1__Associated_Qualification__c>> temp_map = new Map<Id,List<TR1__Associated_Qualification__c>>();
                temp_map.put(ast.TR1__Qualification__c,new List<TR1__Associated_Qualification__c>{ast});
                QualwithAssociate.put(ast.TR1__Contact__c,temp_map);
            }
        }

        List<Contact> conList = new List<Contact>();
        for(Id conId : QualwithAssociate.keyset()){
            Contact con = [SELECT Id, Safeguarding_Training_Hidden__c FROM Contact WHERE Id = :conId];
            for(Id quaId : QualwithAssociate.get(conId).keyset()){
                List<TR1__Associated_Qualification__c> assQuali = new List<TR1__Associated_Qualification__c>();
                assQuali = QualwithAssociate.get(conId).get(quaId);
                String qualName = '';
                qualName = qualiNameMap.get(quaId);
                if(qualName == 'Barred List'){
                    con.QC_Barred_List_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'CV'){
                    con.QC_CV_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'DBS'){
                    con.QC_DBS_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Disqualification by Association'){
                    con.QC_Disqualification_by_Association_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Early Years Qualifications'){
                    con.QC_Early_Years_Qualification_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Emergency Contact'){
                    con.QC_Emergency_Contact_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Face to Face Interview'){
                    con.QC_Face_to_Face_Interview_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Id'){
                    con.QC_Id_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Medical'){
                    con.QC_Medical_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Overseas DBS Check'){
                    con.QC_Overseas_DBS_Check_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Overseas Police Check'){
                    con.QC_Overseas_Police_Check_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Overseas Teacher Qualifications'){
                    con.QC_Overseas_Teacher_Qualifications_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'passport'){
                    con.QC_passport_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Perm DBS'){
                    con.QC_Perm_DBS_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Perm Qualification'){
                    con.QC_Perm_Qualification_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Photo'){
                    con.QC_Photo_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Post 16 Qualifications'){
                    con.QC_Post_16_Qualifications_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'References'){
                    con.QC_Refrence_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Right to Work'){
                    con.QC_Right_to_Work_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Safeguarding'){
                    con.QC_Safeguarding_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Teacher Qualification'){
                    con.QC_Teacher_Qualification_s__c = calculateStatus(qualName,assQuali);
                }
                if(qualName == 'Terms and Registration Forms'){
                    con.QC_Terms_and_Registration_Forms_s__c = calculateStatus(qualName,assQuali);
                }
            }
            // Added below code to update the Safeguarding Training (Hidden) Field on Contact Record. ********** START **********
            if(!String.isBlank(con.Safeguarding_Training_Hidden__c) && con.Safeguarding_Training_Hidden__c.contains('GForm_Safeguarding')){
                con.Safeguarding_Training_Hidden__c = 'Yes';
            }
            // ********** END **********
            conList.add(con);  
        }

        if(conList.size() > 0){
            update conList;
        }
    }

    public String calculateStatus(String Quali_name,List<TR1__Associated_Qualification__c> ass_Quali){
        String finalStatus = '';
        Set<String> assStatus = new Set<String>();
        List<String> assYesStatus = new List<String>();

        for(TR1__Associated_Qualification__c ast : ass_Quali){
            assStatus.add(ast.TR1__Status__c);
            if(ast.TR1__Status__c == 'Active'){
                assYesStatus.add(ast.TR1__Status__c);
            }
        }

        if(Quali_name != 'Refrence'){
            if(assStatus.contains('Active')){
                finalStatus = 'Active';
            }else if(assStatus.contains('Submitted')){
                finalStatus = 'Submitted';
            }else if(assStatus.contains('Expired')){
                finalStatus = 'Expired';
            }else if(assStatus.contains('In Progress')){
                finalStatus = 'In Progress';
            }else if(assStatus.contains('Requested')){
                finalStatus = 'Requested';
            }else{
                finalStatus = 'Rejected';
            }
        }else{
            if(assStatus.contains('Rejected')){
                finalStatus = 'Rejected';
            }else if(assStatus.contains('Requested')){
                finalStatus = 'Requested';
            }else if(assStatus.contains('In Progress')){
                finalStatus = 'In Progress';
            }else if(assStatus.contains('Expired')){
                finalStatus = 'Expired';
            }else if(assStatus.contains('Submitted')){
                finalStatus = 'Submitted';
            }else if(assStatus.contains('Active')){
                finalStatus = 'Active';
            }else{
                finalStatus = 'Rejected';
            }
        }
        return finalStatus;
    }

    public void updateComplianceAQ(){

        List<Id> contactIds = new List<Id>();
        Map<Id, List<TR1__Associated_Qualification__c>> aqualListMap = new Map<Id, List<TR1__Associated_Qualification__c>>();
        List<Contact> updateConList = new List<Contact>();

        try{
            for(TR1__Associated_Qualification__c aqual : recordNewList){
                contactIds.add(aqual.TR1__Contact__c);
            }
            System.debug('Contact Ids ::::: '+contactIds);
            
            for(TR1__Associated_Qualification__c aqual : [SELECT Id, Name, TR1__Contact__c, TR1__Status__c FROM TR1__Associated_Qualification__c WHERE TR1__Contact__c IN: contactIds]){
                if(!aqualListMap.containsKey(aqual.TR1__Contact__c)){
                    aqualListMap.put(aqual.TR1__Contact__c, new List<TR1__Associated_Qualification__c>());
                }
                aqualListMap.get(aqual.TR1__Contact__c).add(aqual);
            }
            System.debug('AQ Keys :::::: '+aqualListMap.keySet());
            System.debug('AQ Values :::::: '+aqualListMap.values());

            for(Contact con : [SELECT Id, Name, Active_Compliance_AQ__c FROM Contact WHERE Id IN: contactIds]){
                if(aqualListMap.get(con.Id) != null){
                    Integer totalAQCount = aqualListMap.get(con.Id).size();
                    Integer activeAQCount = 0;
                    for(TR1__Associated_Qualification__c aqual : aqualListMap.get(con.Id)){
                        if(aqual.TR1__Status__c == 'Active'){
                            activeAQCount += 1;
                        }
                    }
                    con.Active_Compliance_AQ__c = activeAQCount + '/' + totalAQCount;
                    updateConList.add(con);
                }
            }
            if(updateConList.size() > 0){
                update updateConList;
            }
        }catch(Exception e){
            System.debug('Error --- '+e.getMessage()+' --- '+e.getStackTraceString());
        }
    }
}