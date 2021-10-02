public inherited sharing class RemoteCallResponse {
    public AccessTokenResponse tokenReponse;
    public boolean hasError = false;
    public String errorJSON;
    public Datetime createdDatetime;
    public Datetime expiryDatetime;

    public RemoteCallResponse(){

    }

    public class AccessTokenResponse {
        public String token_type;
        public Integer expires_in;
        public Integer ext_expires_in;
        public String access_token;
    }

}

