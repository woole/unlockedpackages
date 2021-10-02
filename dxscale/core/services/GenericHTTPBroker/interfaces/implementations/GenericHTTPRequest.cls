public inherited sharing class GenericHTTPRequest extends ServiceInputMaster implements IHTTPRequest{

    private transient Map<String,String> authHeaders;
    private Map<String,String> requestHeaders;
    private String requestBody;
    private HTTPOperation operation;
    private String credentialsName;
    private String urlInfo;


    public GenericHTTPRequest(Map<String,String> requestHeaders,String requestBody, HTTPOperation operation, String credentialsName, String urlInfo){
        this.authHeaders = new Map<String,String>();
        this.requestHeaders = requestHeaders;
        this.requestBody = requestBody;
        this.operation = operation;
        this.credentialsName = credentialsName;
    
        this.urlInfo = urlInfo;
    }

    public GenericHTTPRequest(Map<String,String> requestHeaders,String requestBody, HTTPOperation operation, String credentialsName, String urlInfo,String correlationId){
        this(requestHeaders,requestBody,operation,credentialsName,urlInfo);
        setCorrelationId(correlationId);
    }    

    public void addBearerAuth(String token){
        authHeaders.put('Authorization', 'Bearer ' + token); 
    }

    public Map<String,String> getAuthHeaders(){
        return this.authHeaders;   
    }

    public Map<String,String> getRequestHeaders(){
        return this.requestHeaders;
    }

    public String getRequestBody(){
        return this.requestBody;    
    }

    public HTTPOperation getOperation(){
        return this.operation;
    }

    public String getCredentialsName(){
        return this.credentialsName;
    }
    

    public String getURLInfo(){
        return this.urlInfo;
    }
}
