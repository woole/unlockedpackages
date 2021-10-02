public interface IHTTPRequest extends IService_Input_Master{
    
    Map<String,String> getAuthHeaders();
    Map<String,String> getRequestHeaders();
    String getRequestBody();
    HTTPOperation getOperation();
    String getCredentialsName();
    String getURLInfo();

}
