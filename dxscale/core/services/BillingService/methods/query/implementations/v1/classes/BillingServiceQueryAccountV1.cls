public inherited sharing class BillingServiceQueryAccountV1 extends ZuoraBaseService implements IService_Implementation, IService_Implementation_Audit_Override {

  static String CLASSNAME = 'BillingServiceQueryAccountV1';


  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    billing_IRequest request = (billing_IRequest)inputData;
    return implementationBody(request);
  }

  billing_IQueryResponse implementationBody(billing_IRequest isi) {
    billing_IQueryResponse response;
    
    try{
      List<billing_BillingAccount> billingAccounts = ZuoraBillingAccountHelper.getBillingAccountInfo(isi.getSFAccountId(), isi.getCorrelationId());
      response = new billing_QueryResponse(billingAccounts);
    }catch(Exception e){
      response = new billing_QueryResponse(null);
      response.setState('FAIL');
      response.setErrorMessage(e.getMessage());
    }
    response.setCorrelationId(isi.getCorrelationId());    
    return response;

  }

  public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
    return isom;
  }   
  
}