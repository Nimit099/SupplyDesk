/*******************************************************
* Name          : ExceptionInfo
* Author        : 
* Create Date   : 01/08/2022
* UsedBy        : Used in community site components
* Description   : Call this component when exception occurred
* Test Class    : ts_ProfileModuleTest => testMethod1 and testMethod2
*******************************************************/
public with sharing class ExceptionInfo {
    
    public String type {get;set;}
    public String reasonCode {get;set;}
    public String message {get;set;}
    public String stackTrace {get;set;}
    public Boolean isCustomException {get;set;}
    private static final string CLASS_NAME = 'ExceptionInfo';   
    
    public String asString(){
            return   'ExceptionInfo: [ TYPE - ' + type + '\n' +
                                   ' CODE - ' + reasonCode + '\n' +
                                   ' MESSAGE - ' + message + '\n' +
                                   ' STACKTRACE - ' + stackTrace + ' ]';  
    } 
}