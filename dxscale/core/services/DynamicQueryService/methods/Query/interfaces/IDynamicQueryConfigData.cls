public interface IDynamicQueryConfigData extends IService_Input_Master {

    String getWhereClause();
    Integer getLimitRows();
    Boolean hasLimitRows();
    Boolean hasEnforceSecurity();
    String getEnforceSecurityClause();
    Boolean hasApplyUserFLS();
    AccessType getApplyUserFLS();
    String getOrderByClause();
    String getQueryId();
    void setQueryId(String id);
    String getObjectType();
    List<IDynamicQueryConfigItem> getFields();
    List<String> getQueryFieldAPIs();

    List<sObject> runQuery (String queryId);


}
