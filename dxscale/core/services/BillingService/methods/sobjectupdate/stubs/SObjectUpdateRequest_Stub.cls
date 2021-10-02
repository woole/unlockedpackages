public inherited sharing class SObjectUpdateRequest_Stub extends ZuoraBaseService implements IService_Implementation {

  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    return stubBody(inputData);
  }

  IService_Output_Master stubBody(IService_Input_Master isi) {
    billing_IUpdateSObjectRequest updateRequest = (billing_IUpdateSObjectRequest)isi;
    billing_Response reponse = new billing_Response();
    List<billing_IUpdateRequest> records = updateRequest.getRequests();
    if(records != null){
      billing_IUpdateRequest request = records[0];
      String objName = request.getSObjectName();
      if(objName.equalsIgnoreCase('Dummy')){
        setReturnState(reponse,'FAIL','SObject update failed for '+objName+'). Check logs');
      }else{
        setReturnState(reponse,'SUCCESS','Update to ' + objName + ' Complete');
      }   
    }else{
      setReturnState(reponse,'FAIL','invalid SObject update request');
    }
    
    
    return reponse;
  }


}
