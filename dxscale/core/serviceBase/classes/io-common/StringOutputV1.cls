public inherited sharing class StringOutputV1 extends ServiceOutputMaster implements IStringOutput, IService_Flow_Output {

    public String msg;

    public String getOutputMessage () {
        return msg;
    }

    public void setOutputMessage (String msg) {
        this.msg = msg;
    }

    // TODO - need to find a better way to deal with test coverage for the flow implementation scenario
    public void processFlowOutput(Flow.Interview myFlow) {
        setOutputMessage(myFlow == null ? 'outputMessage':(String) myFlow.getVariableValue('outputMessage'));
        setState(myFlow == null ? 'ERROR':(String) myFlow.getVariableValue('state'));
        setErrorMessage(myFlow == null ? 'errorMessage':(String) myFlow.getVariableValue('errorMessage'));
     }
  

}
