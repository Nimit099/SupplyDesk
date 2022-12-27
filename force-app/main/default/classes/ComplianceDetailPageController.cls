public without sharing class ComplianceDetailPageController {
    public String conid {set;get;} 
    public List<WrapClass> listqualifications{set;get;}
    public Map<String,TR1__Associated_Qualification__c> mapasscs {set;get;}
    public Map<String,TR1__Qualification__c> qualificationsMap = New Map<String,TR1__Qualification__c>();
    public ComplianceDetailPageController(ApexPages.StandardController controller) {
    listqualifications = new List<WrapClass>();
        conid = (String)controller.getId();
          Contact objContact = new Contact();
        if(!Test.isRunningTest()){
        controller.addFields(new List<String>{'Pay_Type__c'});
        objContact = (Contact)controller.getRecord();
        }else{
            objContact = [select Pay_Type__c from contact where Id =:conid];
        }
        
        List< TR1__Qualification__c > listqlfns = [Select Id,Name, Description__c from TR1__Qualification__c order by Name ASC NUllS LAST ];
       // map pf qualification name to qualification
       for(TR1__Qualification__c q : listqlfns){
           if(!qualificationsMap.containskey(q.Name))
                qualificationsMap.put(q.Name,q);
       }
       
        List< TR1__Associated_Qualification__c > listasqlfns = [Select Id,Name, TR1__Status__c, TR1__Qualification__c, TR1__Qualification__r.Name, ComplianceStatus__c, Compliance_Status__c, TR1__Contact__c, TR1__Contact_Qualification__c,TR1__Contact_Qualification__r.Name,TR1__Qualification_Package__c from TR1__Associated_Qualification__c where TR1__Contact__c=:conid AND TR1__Qualification_Package__r.TR1__Name__c =: objContact.Pay_Type__c Order By Name ASC]; 

        mapasscs = new Map<String,TR1__Associated_Qualification__c>();
        if(listasqlfns.size()>0){
            for(TR1__Associated_Qualification__c eachassc : listasqlfns){
                mapasscs.put(eachassc.TR1__Qualification__r.Name,eachassc);
            }
        }
        for(TR1__Qualification__c eachqlfn : qualificationsMap.values()){
            if(mapasscs.containsKey(eachqlfn.Name)){
                listqualifications.add(new WrapClass(eachqlfn,mapasscs.get(eachqlfn.Name)));
            }/*else{
                listqualifications.add(new WrapClass(eachqlfn,new TR1__Associated_Qualification__c(TR1__Status__c='')));
            }*/
        }
        //system.debug('=====================listqualifications===='+listqualifications);
        
    }
    public class WrapClass{
        public TR1__Qualification__c qualfcn{set;get;}
        public TR1__Associated_Qualification__c asscqualfcn{set;get;}
        public WrapClass(TR1__Qualification__c qualfcn1,TR1__Associated_Qualification__c asscqualfcn1){
            qualfcn = qualfcn1;
            asscqualfcn = asscqualfcn1;
       }
    }
    
    public PageReference redirectToCompliance(){
        PageReference pr = null;
        if(conid!=null){
           pr = new PageReference('/apex/CompliancePage3?id='+conid); 
        }
        return pr;
    }
}