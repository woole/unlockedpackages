public inherited sharing class UpdateBillingContactV1 extends ZuoraBaseService implements IService_Implementation, IService_Implementation_Audit_Override {

  static String CLASSNAME = 'UpdateBillingContactV1';


  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    super.prepare(inputData);
    billing_IContactUpdateRequest request = (billing_IContactUpdateRequest)inputData;
    return implementationBody(request);
  }

  billing_IResponse implementationBody(billing_IContactUpdateRequest isi) {
    String correlationId = isi.getCorrelationId();
    billing_Response response = new billing_Response();
    
    String updatedEmail = isi.getNewEmailAddress();
    String existingEmail = isi.getExistingEmailAddress();
    String contactId = isi.getContactId();
    String accountId = isi.getSFAccountId();
    //Update the SF contact
    try{
        updateContact(existingEmail,updatedEmail,contactId,response,correlationId);
    }catch(Exception e){
        String errorMessage = 'Error updating Contact';
        ExceptionLogger.logException(CLASSNAME,correlationId,e,errorMessage,true);
        setReturnState(response,'FAIL',errorMessage + ' ' +e.getMessage());
        return response;
    }
    
    billing_BillingAccount billngContactEmailUpdate = getBillingAccount(accountId,correlationId);

    String zuoraBillToId;
    String zuoraAccountId;
    //if we have one, update the Billing account
    if(billngContactEmailUpdate != null){
        
        zuoraBillToId = billngContactEmailUpdate.getBillToId();
        zuoraAccountId = billngContactEmailUpdate.getBillingId();
        
        //Generic way to update the Zuora objects without needing the managed package
        GenericServiceInvoker updateinvoker = new GenericServiceInvoker('BillingServiceV1_sObjectUpdate');
        Map<String,String> params = new Map<String,String>{'Zuora__BillToWorkEmail__c' => updatedEmail};
        billing_IUpdateRequest billingAccountRecord = new billing_UpdateRequest(billngContactEmailUpdate.getId(),correlationId,CLASSNAME,'Zuora__CustomerAccount__c',params);
        billing_IUpdateSObjectRequest zuoraSObjectUpdaterequest = new billing_UpdateSObjectRequest(correlationId,new List<billing_IUpdateRequest>{billingAccountRecord});
        IService_Output_Master updateOutput = updateinvoker.call(zuoraSObjectUpdaterequest);
        
        if(updateOutput.getState() !=  'SUCCESS'){
            setReturnState(response,'FAIL','Failed to update Zuora__CustomerAccount__c : ' + updateOutput.getErrorMessage());
            return response;
        }else{
            //call the billing update service which calls out the zAPI to actually update Zuora
            Map<String,String> udateParams = new Map<String, String>{
              'Id' => zuoraBillToId,
              'AccountId' => zuoraAccountId,
              'WorkEmail' => updatedEmail
            };           
            billing_IUpdateRequest request = new billing_UpdateRequest(CLASSNAME,'Contact',udateParams);
            GenericServiceInvoker invoker = new GenericServiceInvoker('BillingServiceV1_updateZuora');
            IService_OUtput_Master updateResult = invoker.call(request);
            System.debug(LoggingLevel.DEBUG, updateResult);
            super.setReturnState(response,updateResult.getState(),updateResult.getErrorMessage());
        
        }
    } 

    return response;
  }

  private void updateContact(String existingEmail,String updatedEmail,String contactId,billing_Response response,String correlationId){
          //update the contact
          List<SObject> updateList = new List<SObject>();
          if(String.isNotBlank(existingEmail)){
            List<Contact> matchedContacts = [SELECT id, email FROM Contact WHERE id = :contactId AND Email = :existingEmail];
            System.debug(LoggingLevel.DEBUG, 'contacts to update matched : ' + matchedContacts);
            for (Contact c : matchedContacts) {
                c.email = updatedEmail;
                updateList.add(c);
            } 
          }
          try{
              update updateList;
          }catch(Exception e){
              String errorMessage = 'Error updating Contact';
              ExceptionLogger.logException(CLASSNAME,correlationId,e,errorMessage,true);
              setReturnState(response,'FAIL',errorMessage + ' ' +e.getMessage());
          }    
  }

  public billing_BillingAccount getBillingAccount(string accountId,String correlationId){
    List<billing_BillingAccount> billingAccounts = ZuoraBillingAccountHelper.getBillingAccountInfo(accountId,correlationId);
    System.debug(LoggingLevel.DEBUG, billingAccounts);
    billing_BillingAccount billingAccount = null;
    if(!billingAccounts.isEmpty()){
      billingAccount = billingAccounts[0];
    }else if(billingAccounts.size() > 1){
      ExceptionLogger.logInfo(CLASSNAME,correlationId,accountId,'Multiple Billing account exist for ' + accountId,ExceptionLogger.ERROR_TYPE.INFO);
    }
    return billingAccount;
  }

  public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
    return isom;
  }   

}