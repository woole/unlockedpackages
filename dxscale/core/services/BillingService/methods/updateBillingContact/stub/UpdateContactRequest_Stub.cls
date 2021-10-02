public inherited sharing class UpdateContactRequest_Stub extends ZuoraBaseService implements IService_Implementation {

	public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
		super.prepare(inputData);
		return stubBody(inputData);
	}

	IService_Output_Master stubBody(IService_Input_Master isi) {
    	billing_IContactUpdateRequest updateRequest = (billing_ContactUpdateRequest)isi;
    	billing_Response response = new billing_Response();
    	String email = updateRequest.getNewEmailAddress();
    	String accountId = updateRequest.getSFAccountId();
    	List<Account> accounts = [SELECT id, Name FROM Account WHERE Id = :accountId];    
      
    	if (email.contains('Error')){
    		setReturnState(response,'FAIL','Update Failed');
    	} else if (accounts.isEmpty()) {
        	setReturnState(response,'FAIL','Account does not exist');
    	} else {
    		setReturnState(response,'SUCCESS','Update to Complete');
    	}

    	return response;
  }
}
