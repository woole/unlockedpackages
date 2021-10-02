/**
 * This service does a basic wrap around the Zuora API and therefore allows us to stub out those calls that would fail
 * When Zuora isn't connected / configured or licensed for.
 */
public inherited sharing virtual class ZuoraUpdateServiceV1 extends ZuoraBaseService implements IService_Implementation, IService_Implementation_Audit_Override {

  static String CLASSNAME = 'ZuoraUpdateServiceV1';
  

  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    billing_IUpdateRequest updateRequest = (billing_IUpdateRequest)inputData;
    return implementationBody(updateRequest);
  }

  billing_IResponse implementationBody(billing_IUpdateRequest isi) {
    billing_IResponse response = new billing_Response();
    String correationId = isi.getCorrelationId();
    response.setCorrelationId(correationId);

    String objName = isi.getSObjectName();
    String executedFromClass = isi.getCallingClassName();
    Map<String,Object> fieldValueByNameMap = isi.getParameters();
    
    Boolean success = updateZuoraObject(objName, fieldValueByNameMap, executedFromClass,correationId);
    if(!success){
      setReturnState(response,'FAIL','Zuora API call failed (update '+objName+'). Check logs');
    }else{
      setReturnState(response,'SUCCESS','Update to ' + objName + ' Complete');
    }
    return response;
  }

  protected virtual String getCallableClassName(){
    return 'ZuoraUpdateUtility';
  }

  private Boolean updateZuoraObject(String objName, Map<String,Object> fieldValueByNameMap, String executedFromClass, String correlationId){
      Boolean result = false;
      //prepare the parameters to send in a map of maps
      Map<String,Object> parameters = new Map<String,Object>();
      Map<String,String> callerInfo = new Map<String,String>{'exectingclass'=>executedFromClass, 'correlationId'=>correlationId};
      parameters.put('CallerInfo',callerInfo);
      parameters.put('FieldValues',fieldValueByNameMap);
      //Runtime lookup of the ZuoraUpdateUtility
      String calzzName = getCallableClassName();
      System.debug(LoggingLevel.DEBUG, 'calling : ' + calzzName);
      try{
        Callable zuoraUpdater = (Callable) Type.forName(calzzName).newInstance();
        result = (Boolean)zuoraUpdater.call(objName,parameters);
        
      }catch(Exception e){
        ExceptionLogger.logException(CLASSNAME,correlationId,e,'failed to call ZuoraUpdateUtility',true);
      }
      return result;  
  }

  public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
    return isom;
  }  


}