public virtual inherited sharing class ZuoraBaseService extends BaseServiceImplementation{
    
    private static final String CLASSNAME = 'ZuoraBaseService';

    private String correlationId;

    protected virtual void prepare(IService_Input_Master inputData) {
        setCorrelationId(inputData.getCorrelationId());

    }

    @TestVisible
    protected String getCorrelationId(){
        return this.correlationId;
    }

    @TestVisible
    protected void setCorrelationId(String correlationId){
        this.correlationId = correlationId;
    }
    
    @TestVisible
    protected virtual void setReturnState(IService_Output_Master response,String state,String error){
        response.setState(state);
        response.setCorrelationId(getCorrelationId());
        if(String.isNotBlank(error)){
          response.setErrorMessage(error);
        }
      } 

}
