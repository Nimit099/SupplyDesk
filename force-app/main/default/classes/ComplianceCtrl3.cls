public without sharing class ComplianceCtrl3 {

    public PageReference updateAsscQualfns() {
        PageReference pr = null;
        status = 'null';
        List<TR1__Associated_Qualification__c> listasscqualns = new List<TR1__Associated_Qualification__c>();
        for(WrapClass eachwrap : listqualifications){
            if(eachwrap.ischeck==true && eachwrap.asscqualfcn.TR1__Qualification__c==null){
                    eachwrap.asscqualfcn.TR1__Qualification__c=eachwrap.qualfcn.Id;
                    eachwrap.asscqualfcn.TR1__Contact__c = conid;
                    eachwrap.asscqualfcn.TR1__Status__c = 'Requested';
                    listasscqualns.add(eachwrap.asscqualfcn);
            }
            if(mapasscqualnsold.containsKey(eachwrap.asscqualfcn.Id) && mapasscqualnsold.get(eachwrap.asscqualfcn.Id) != eachwrap.asscqualfcn.TR1__Status__c){
                listasscqualns.add(eachwrap.asscqualfcn);
            }
         }
        if(listasscqualns.size()>0){
            try{
                Upsert listasscqualns;
                status = 'Success';
            }catch(Exception e){
                status = 'Fail';
            }
        }
        return null;
    }
    
    public String status{set;get;}
    public String conid{set;get;}
    public String contactname{set;get;}
    public List<WrapClass> listqualifications{set;get;}
    public Map<Id,String> mapasscqualnsold{set;get;}
    public Map<String,TR1__Associated_Qualification__c> mapasscs {set;get;}
    
    public ComplianceCtrl3(){
        listqualifications = new List<WrapClass>();
        mapasscqualnsold = new Map<Id,String>();
        conid = ApexPages.CurrentPage().getParameters().get('id');
        if(conid!=null){
            contactname = [Select Id,Name from Contact where id=:conid limit 1].Name;
        }
        List< TR1__Qualification__c > listqlfns = [Select Id,Name, Description__c from TR1__Qualification__c order by Sort_Order__c ASC NUllS LAST ];
        List< TR1__Associated_Qualification__c > listasqlfns = [Select Id,Name, TR1__Status__c, TR1__Qualification__c, TR1__Qualification__r.Name, Compliance_Status__c, ComplianceStatus__c, TR1__Contact__c, TR1__Contact_Qualification__c,TR1__Contact_Qualification__r.Name from TR1__Associated_Qualification__c where TR1__Contact__c=:conid]; 
        mapasscs = new Map<String,TR1__Associated_Qualification__c>();
        if(listasqlfns.size()>0){
            for(TR1__Associated_Qualification__c eachassc : listasqlfns){
                mapasscs.put(eachassc.TR1__Qualification__r.Name,eachassc);
            }
        }
        for(TR1__Qualification__c eachqlfn : listqlfns){
            if(mapasscs.containsKey(eachqlfn.Name)){
                listqualifications.add(new WrapClass(eachqlfn,mapasscs.get(eachqlfn.Name),true));
                mapasscqualnsold.put(mapasscs.get(eachqlfn.Name).Id,mapasscs.get(eachqlfn.Name).TR1__Status__c);
            }else{
                listqualifications.add(new WrapClass(eachqlfn,new TR1__Associated_Qualification__c(TR1__Status__c=''),false));
            }
        }
    }
    public class WrapClass{
        public Boolean ischeck{set;get;}
        public TR1__Qualification__c qualfcn{set;get;}
        public TR1__Associated_Qualification__c asscqualfcn{set;get;}
        public WrapClass(TR1__Qualification__c qualfcn1,TR1__Associated_Qualification__c asscqualfcn1,Boolean ischeck1){
            qualfcn = qualfcn1;
            asscqualfcn = asscqualfcn1;
            ischeck = ischeck1;
       }
    }
}