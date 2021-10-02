public inherited sharing class GenericHTTPResponse extends ServiceOutputMaster implements IHTTPResponse{

    final List<Integer> OK_RESPONSES = new List<Integer>{200,201,202,204};

    private String responseBody;
    private Integer statusCode;
    private Boolean hasError = false;

    public GenericHTTPResponse(String responseBody, Integer statusCode){
        this.responseBody = responseBody;
        this.statusCode = statusCode;
        if(!OK_RESPONSES.contains(statusCode)){
            this.hasError = true;
        }
    }

    public String getResponseBody(){
        return this.responseBody;
    }

    public Integer getStatusCode(){
        return this.statusCode;    
    }

    public void setHasError(Boolean value){
        this.hasError = value;
    }

    public Boolean hasError(){
        return this.hasError;
    }

}
