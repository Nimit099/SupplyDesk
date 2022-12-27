public class SchoolRequiredPreparationController {
    
    public string isCovRiskAssesmet{get; set;}
    public string isSupplyCandidateWorking{get; set;}
    public string isNotifyToSupplyDeskoCovidCase{get; set;}
    public string AdditionalComment{get; set;}
    public List<SelectOption> PickListVal {get;set;} 
    Public String RecordId = '';
    
    public SchoolRequiredPreparationController(){
        isCovRiskAssesmet = 'Yes';
        isSupplyCandidateWorking = 'Yes';
        isNotifyToSupplyDeskoCovidCase = 'Yes';
        RecordId = ApexPages.currentPage().getParameters().get('id');
        getPickVal();
    }
    
    public void getPickVal(){
        PickListVal = new List<SelectOption>();

        PickListVal.add(new SelectOption('Yes','Yes'));
        PickListVal.add(new SelectOption('No','No'));
    }
    
    public void Submit(){
        System.debug('isCovRiskAssesmet'+isCovRiskAssesmet);
        if(String.isNotBlank(RecordId) && String.isNotEmpty(RecordId)){
            Contact ct = new Contact();
            ct.Id = RecordId;
            ct.Is_school_carried_COVID19_Risk_asse__c = isCovRiskAssesmet == 'Yes' ? true : false;
            ct.Is_supply_candidate_receive_training__c = isSupplyCandidateWorking == 'Yes' ? true : false;
            ct.is_Notify_Supply_Desk_on_Conform_Covid19__c = isNotifyToSupplyDeskoCovidCase == 'Yes' ? true : false;
            ct.Covid_19_Risk_Assesment_Additional_Notes__c = AdditionalComment;
            update ct;
        }
    }
    
    public void echoVal(){
     System.debug('isCovRiskAssesmet'+isCovRiskAssesmet);
        System.debug('isSupplyCandidateWorking'+isSupplyCandidateWorking);
        System.debug('isNotifyToSupplyDeskoCovidCase'+isNotifyToSupplyDeskoCovidCase);
    }

}