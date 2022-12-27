/*
* @description
* @author    	Vaishali Firake
* @deprecated  	False
*/
public class BulkTimesheetUpdateQueueable implements Queueable {
  List<TR1__Timesheet__c> tsList;
  Integer queueNumber;
  /*
  * @description  	Execute method which updates the records.
  * @author    		Vaishali Firake
  * @return
  * @param
  * @throws
  * @deprecated  False
  */
  public BulkTimesheetUpdateQueueable (List<TR1__Timesheet__c> tsList, integer queueNumber) {
    this.tsList = tsList;
    this.queueNumber = queueNumber;
  }

  /*
  * @description  	Execute method which updates the records.
  * @author    		Vaishali Firake
  * @return
  * @param
  * @throws
  * @deprecated  	False
  */
  public void execute (QueueableContext context) {
    List<Timesheet_Export_Line_Item__c> deleteTSExportLineItmsList = New List<Timesheet_Export_Line_Item__c>();
    Map<Id,TR1__Timesheet__c> TSMap = New Map<Id,TR1__Timesheet__c>(tsList);
    Database.SaveResult[] srList = Database.update(tsList, false);
    for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
            deleteTSExportLineItmsList.add(New Timesheet_Export_Line_Item__c(Id = TSMap.get(sr.getId()).Timesheet_Export_Line_Item__c));
        }
    }    
    
    if(deleteTSExportLineItmsList.size() > 0){
        delete deleteTSExportLineItmsList;
    }
  }
}