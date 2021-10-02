public interface IConfigCredentials {
    String getURL();
    Integer getCacheTTL();
    String getClientID();
    String getClientSecret();
    String getType();
    String getNamedCredentialName();
    String getProviderType();
    Integer getRequestTimeOut();
    String getScope();
}
