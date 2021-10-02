public inherited sharing class TokenAuthRequest extends ServiceInputMaster implements ITokenAuthRequest,IRequestValidator{
    private String authCredentials;

    public Map<String,String> validate(){
        Map<String,String> validationErrors = new Map<String,String>();
        if(String.isBlank(this.authCredentials)){
            validationErrors.put('authCredentials','Is mandatory');
        }
        return validationErrors;
    }

    // Deprecatad
    public TokenAuthRequest(String correlationId){
        setCorrelationId(correlationId);
    }

    public TokenAuthRequest(String correlationId,String authCredentials){
        setCorrelationId(correlationId);
        this.authCredentials = authCredentials;
    }

    public String getAuthCredentials(){
        return this.authCredentials;
    }
}