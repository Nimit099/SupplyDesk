global class AssociateQualificationsBatch implements Database.Batchable<SObject>, Database.stateful{
    
    public string query;
    
    public AssociateQualificationsBatch(String query){
        this.query = query;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(query);
        System.debug(database.query(query));
        return Database.getQueryLocator(query);  
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('scope>>>>>>>>>>>>>'+scope);
        
        List<TR1__Associated_Qualification__c> AssocitatedQualificatinList = new List<TR1__Associated_Qualification__c>();
        
        for(SObject sbj : scope){
            if(String.valueOf(sbj.Id.getSObjectType()) == 'TR1__Associated_Qualification__c'){
                TR1__Associated_Qualification__c AQT = (TR1__Associated_Qualification__c) sbj;
                AQT.isBatch_updated__c = true;
                AssocitatedQualificatinList.add(AQT);
            }
        }
        System.debug('scope>>>>>>>>>>>>> before Update'+scope);
        System.debug('AssocitatedQualificatinList>>>>>>>>>>>>> before Update'+AssocitatedQualificatinList);
        try{
            if(AssocitatedQualificatinList.size() > 0){
            
                List<Database.SaveResult> results = Database.update(AssocitatedQualificatinList, false);
                for (Database.SaveResult result : results) {
                  if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                      System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                  }
                }
                
            } else{
                database.update(scope, false);
            }
       
        }catch (exception e){
            System.debug('Exception Caught:'+e.getmessage());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {}
}