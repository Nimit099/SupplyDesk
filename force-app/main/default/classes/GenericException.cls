/*******************************************************
* Name          : GenericException
* Author        : 
* Create Date   : 01/08/2022
* UsedBy        : Used in community site components
* Description   : Call this component when exception occurred
* Test Class    : ts_ProfileModuleTest => testMethod1 and testMethod2
*******************************************************/
public with sharing class GenericException extends Exception {

    //TODO - add more features
    private String reasonCode; //a short form describing the exception
    private String errorMsg;
    
    /**
    * Constructs a new GenericException with the specified Reason Code message.
    * @params
    * String reasonCode
    * String errorMsg
    */
    public GenericException(String reasonCode,String errorMsg) {
        this.reasonCode = reasonCode;
        this.errorMsg = errorMsg;
        System.debug('reasonCode--->'+reasonCode);
        System.debug('errorMsg--->'+errorMsg);
    }

    
    /**
    *
    * Returns the Error Message.
    */  
    public String getErrorMsg() {
        return errorMsg;
    }
    
    /**
    *
    * Returns the Reason Code.
    */  
    public String getReasonCode() {
        return reasonCode;
    }
}