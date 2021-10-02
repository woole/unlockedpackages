public inherited sharing class TokenAuthResponse extends ServiceOutputMaster implements ITokenAuthResponse{

    private String accessToken;

    public TokenAuthResponse(){}

    public TokenAuthResponse(String token){
        this.accessToken = token;
    }
    public void setAccessToken(String accessToken){
        this.accessToken = accessToken;
    }

    public String getAccessToken(){
        return this.accessToken;
    }


}