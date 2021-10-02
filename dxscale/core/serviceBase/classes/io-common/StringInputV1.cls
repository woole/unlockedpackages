global inherited sharing class StringInputV1 implements IStringInput, IService_Flow_Input {

    private String msg;
    private String correlationId;

    public String getInputMessage () {
        return msg;
    }

    public void setInputMessage (String msg) {
        this.msg = msg;
    }

    public Map<String,Object> createFlowInput() {
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('inputMessage',getInputMessage());
        return inputMap;
     }
  
    public void setCorrelationId(String correlationId){
        this.correlationId = correlationId;
    }

    public String getCorrelationId(){
        return this.correlationId;
    }

}

