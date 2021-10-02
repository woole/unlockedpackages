public inherited sharing class ZuoraUpdateRequest_Stub extends ZuoraBaseService implements IService_Implementation {

  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    return stubBody(inputData);
  }

  IService_Output_Master stubBody(IService_Input_Master isi) {
    billing_IUpdateRequest updateRequest = (billing_IUpdateRequest)isi;
    billing_Response reponse = new billing_Response();
    
    String objName = updateRequest.getSObjectName();
    if(objName.equalsIgnoreCase('Dummy')){
      setReturnState(reponse,'FAIL','Zuora API call failed (update '+objName+'). Check logs');
    }else{
      setReturnState(reponse,'SUCCESS','Update to ' + objName + ' Complete');
    }
    return reponse;
  }


}
