public inherited sharing class billing_UpdateRequest extends billing_Request implements billing_IUpdateRequest, IRequestValidator {
    
    
    private String callingClassName;
    private String sobjectName;
    private String recordId;
    private Map<String,String> requestParameters;

    public billing_UpdateRequest(String callingClassName,String sObjectName,Map<String,String> parameters){
        this.callingClassName = callingClassName;
        this.sobjectName = sobjectName;
        this.requestParameters = parameters;
    }

    public billing_UpdateRequest(String recordId,String correlationId, String callingClassName,String sObjectName,Map<String,String> parameters){
        this.recordId = recordId;
        this.callingClassName = callingClassName;
        this.sobjectName = sobjectName;
        this.requestParameters = parameters;
        setCorrelationId(correlationId);
    }    

    public String getId(){
        return this.recordId;
    }

    public Map<String,String> validate(){
        Map<String,String> validationErrors = new Map<String,String>();
        return validationErrors;
    }

    public String getCallingClassName(){
        return this.callingClassName;
    }

    public Map<String,String> getParameters(){
        return this.requestParameters;
    }
    public String getSObjectName(){
        return this.sobjectName;
    }
}