/**
 * This service uses an SObject / map appraoch to update some Salesforce SObjects. Approach could be more widely used if it proves itself
 * It means we don't need to have reference to the underlying object so removes the dependency on pacakges and so on we don't own
 * also means things can be stubbed
 */
public inherited sharing virtual class ZuoraSObjectUpdateServiceV1 extends ZuoraBaseService implements IService_Implementation, IService_Implementation_Audit_Override {

  static String CLASSNAME = 'ZuoraSObjectUpdateServiceV1';
  

  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    billing_IUpdateSObjectRequest updateRequest = (billing_IUpdateSObjectRequest)inputData;
    return implementationBody(updateRequest);
  }
  
  
  billing_IResponse implementationBody(billing_IUpdateSObjectRequest isi) {
    billing_IResponse response = new billing_Response();
    List<billing_IUpdateRequest> sObjectRequests = isi.getRequests();
    
    String correlationId = isi.getCorrelationId();
    response.setCorrelationId(correlationId);

    List<SObject> updateList = new List<SObject>();

    for(billing_IUpdateRequest request:sObjectRequests){
      String objName = request.getSObjectName();
      String recordId = request.getId();
      System.debug(LoggingLevel.DEBUG, 'updating : ' + objName);
      SObject sobj = Schema.getGlobalDescribe().get(objName).newSObject(recordId) ;  
      Map<String,Object> fieldUpdateMap = request.getParameters();
      for (String field : fieldUpdateMap.keySet()){
        sobj.put(field , fieldUpdateMap.get(field));
      }
      updateList.add(sobj);
    }
    try{
      runUppdate(updateList);
    }catch(DmlException e){
      ExceptionLogger.logException(CLASSNAME,correlationId,e,'failed to update SObjects : ' + JSon.serialize(sObjectRequests) ,true);
      response.setState('FAIL');
      response.setErrorMessage('failed to update SObjects : ' + e.getMessage());
    }
    
    return response;
  }

  @TestVisible
  protected virtual void runUppdate(List<SObject> updateList){
    update updateList;
  }

  public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
    return isom;
  }  

}