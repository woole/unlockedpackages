public interface IHTTPResponse extends IService_Output_Master{
    
    String getResponseBody();
    Integer getStatusCode();
    Boolean hasError();
    
}
