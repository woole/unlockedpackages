public interface IExternalRequest {
    String getPath();
    String getRequestJSON();
    String getAuthName();
    String getFunctionName();
    HTTPOperation getOperation();
}
