global inherited sharing class StringIO extends ServiceOutputMaster implements IStringOutput, IStringInput, IService_Flow_Input, IService_Flow_Output {

    @InvocableVariable @AuraEnabled public String msg;

    // pattern could be to have these populated and then to call setter methods?
    public class FlowInputs {
        /* Flow Enabling Fields - only use in flow contexts */
        @InvocableVariable public String invocationName;
        /* Public Fields - so usable in flow contexts */
        @InvocableVariable public String msg1;
    }

    public class FlowOutputs {
        /* Public Fields - so usable in flow contexts */
        @InvocableVariable public StringIO outputData;
    }


    public String getInputMessage () {
        return msg;
    }

    public void setInputMessage (String msg) {
        this.msg = msg;
    }

    public String getStringValue () {
        return msg;
    }

    public void setStringValue (String msg) {
        this.msg = msg;
    }

    public String getOutputMessage () {
        return msg;
    }

    public void setOutputMessage (String msg) {
        this.msg = msg;
    }

    public Map<String,Object> createFlowInput() {
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('inputMessage',getInputMessage());
        return inputMap;
     }

    // TODO - need to find a better way to deal with test coverage for the flow implementation scenario
    public void processFlowOutput(Flow.Interview myFlow) {
        setOutputMessage(myFlow == null ? 'outputMessage':(String) myFlow.getVariableValue('outputMessage'));
        setState(myFlow == null ? 'ERROR':(String) myFlow.getVariableValue('state'));
        setErrorMessage(myFlow == null ? 'errorMessage':(String) myFlow.getVariableValue('errorMessage'));
     }
  

}
