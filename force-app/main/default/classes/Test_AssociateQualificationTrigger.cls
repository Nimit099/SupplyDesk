@isTest
public class Test_AssociateQualificationTrigger {
    
    @isTest public static void newRecord(){
      Test.startTest();   
    Contact con = new Contact();
    con.LastName = 'Demo';
    con.Compliance_Owner__c = UserInfo.getUserId();
    insert con;
    
    List<TR1__Qualification__c> quaList = new List<TR1__Qualification__c>();
    quaList.add(new TR1__Qualification__c(Name = 'Barred List'));
    quaList.add(new TR1__Qualification__c(Name = 'CV'));
    quaList.add(new TR1__Qualification__c(Name = 'DBS'));
    quaList.add(new TR1__Qualification__c(Name = 'Disqualification by Association'));
    quaList.add(new TR1__Qualification__c(Name = 'Early Years Qualifications'));
    quaList.add(new TR1__Qualification__c(Name = 'Emergency Contact'));
    quaList.add(new TR1__Qualification__c(Name = 'Face to Face Interview'));
    quaList.add(new TR1__Qualification__c(Name = 'Id'));
    quaList.add(new TR1__Qualification__c(Name = 'Medical'));
    quaList.add(new TR1__Qualification__c(Name = 'Overseas DBS Check'));
    quaList.add(new TR1__Qualification__c(Name = 'Overseas Police Check'));
    quaList.add(new TR1__Qualification__c(Name = 'Overseas Teacher Qualifications'));
    quaList.add(new TR1__Qualification__c(Name = 'passport'));
    quaList.add(new TR1__Qualification__c(Name = 'Perm DBS'));
    quaList.add(new TR1__Qualification__c(Name = 'Perm Qualification'));
    quaList.add(new TR1__Qualification__c(Name = 'Photo'));
    quaList.add(new TR1__Qualification__c(Name = 'Post 16 Qualifications'));
    quaList.add(new TR1__Qualification__c(Name = 'References'));
    quaList.add(new TR1__Qualification__c(Name = 'Right to Work'));
    quaList.add(new TR1__Qualification__c(Name = 'Safeguarding'));
    quaList.add(new TR1__Qualification__c(Name = 'Teacher Qualification'));
    quaList.add(new TR1__Qualification__c(Name = 'Terms and Registration Forms'));

    insert quaList;

    List<TR1__Associated_Qualification__c> assQuaList = new List<TR1__Associated_Qualification__c>();
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[0].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[1].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[2].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[3].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[4].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[5].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[6].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[7].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[8].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[9].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[10].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[11].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[12].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[13].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[14].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[15].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[16].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[17].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[18].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[19].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[20].Id));
    assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Requested',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[21].Id));
    //assQuaList.add(new TR1__Associated_Qualification__c(TR1__Status__c = 'Rejected',TR1__Contact__c = con.Id,TR1__Qualification__c = quaList[17].Id));

    insert assQuaList;

    List<TR1__Associated_Qualification__c> softUpdate = new List<TR1__Associated_Qualification__c>();
    //softUpdate.add(new TR1__Associated_Qualification__c(Id=assQuaList[0].Id ,TR1__Status__c = 'Submitted'));
    softUpdate.add(new TR1__Associated_Qualification__c(Id=assQuaList[1].Id ,TR1__Status__c = 'Expired'));
    //softUpdate.add(new TR1__Associated_Qualification__c(Id=assQuaList[2].Id , TR1__Status__c = 'In Progress'));
    softUpdate.add(new TR1__Associated_Qualification__c(Id=assQuaList[3].Id ,TR1__Status__c = 'Rejected'));
    //softUpdate.add(new TR1__Associated_Qualification__c(Id=assQuaList[17].Id ,Qualification_Type__c = 'BTEC',NCTL_Status__c = 'Provisionally Registered',NCTL_Checked_Date__c = system.today(),NCTL_Number__c = '1234', TR1__Status__c = 'Active'));

    update softUpdate;
   
    Test.stopTest();
      
    }
    @isTest
    public  static void newRecord1(){
        Contact con = new Contact();
        con.LastName = 'Demo';
        con.Compliance_Owner__c = UserInfo.getUserId();
        insert con;
        TR1__Qualification__c qul = new TR1__Qualification__c();
        qul.Name='Barred List';
        insert qul;
        List<TR1__Associated_Qualification__c> asstList = new List<TR1__Associated_Qualification__c>();
        TR1__Associated_Qualification__c asst= new TR1__Associated_Qualification__c();
        asst.TR1__Status__c='Requested';
        asst.TR1__Contact__c = con.Id;
        asst.TR1__Qualification__c = qul.Id;
        asstList.add(asst);
        insert asstList;
        delete asstList;
    }
}