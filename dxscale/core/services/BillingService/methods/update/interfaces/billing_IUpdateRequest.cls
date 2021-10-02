public interface billing_IUpdateRequest extends billing_IRequest {
    String getId();
    String getCallingClassName();
    Map<String,String> getParameters();
    String getSObjectName();
}