@isTest
public class H_Utility_Test {

    Private static Account objAccount;

  public static TR1__Qualification__c createQualification(String qualificationName)
    {
        TR1__Qualification__c objQualifiation = new TR1__Qualification__c(Name = 'Graduation', TR1__Field_Set_ID__c= 'Graduation');
        insert objQualifiation;
        return objQualifiation;
    }
    //Id contactId, Id qualificationPkg both are optional, null can be send
    public static TR1__Associated_Qualification__c createAssociateQualification(Id qualificationId, Id contactId, Id qualificationPkg)
    {
        TR1__Associated_Qualification__c objAQ = new TR1__Associated_Qualification__c(TR1__Qualification__c = qualificationId, TR1__Contact__c = contactId, TR1__Qualification_Package__c = qualificationPkg);
        insert objAQ;
        return objAQ;
    }

}