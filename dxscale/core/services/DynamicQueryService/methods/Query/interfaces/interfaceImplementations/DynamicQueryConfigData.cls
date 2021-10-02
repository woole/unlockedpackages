public inherited sharing class DynamicQueryConfigData implements IDynamicQueryConfigData {

    // Add in all the display fields with each @AuraEnabled
    @AuraEnabled public String whereClause;
    @AuraEnabled public boolean enforceSecurity;
    @AuraEnabled public String applyUserFLS;
    @AuraEnabled public Integer limitRows;
    @AuraEnabled public String orderByClause; // can include ASC and DESC in this
    @AuraEnabled public String id;
    @AuraEnabled public String objectType;
    @AuraEnabled public List<ConfigItem> fields;
    private String correlationId;

    public String getCorrelationId() {
        return correlationId;
    }    
    public void setCorrelationId(String correlationId) {
        this.correlationId = correlationId;
    }      

    public String getOrderByClause() {
        return orderByClause;
    }

    public String getWhereClause() {
        return whereClause;
    }

    public boolean hasEnforceSecurity() {
        return ((enforceSecurity != null && enforceSecurity== true)? true : false);
    }

    public String getEnforceSecurityClause() {
        return (hasEnforceSecurity() ? ' WITH SECURITY_ENFORCED ' : '');
    }

    public boolean hasApplyUserFLS() {
        return (applyUserFLS != null);
    }

    public AccessType getApplyUserFLS() {
        switch on applyUserFLS {
            when 'CREATABLE' { return AccessType.CREATABLE;}
            when 'READABLE' { return AccessType.READABLE;}
            when 'UPDATABLE' { return AccessType.UPDATABLE;}
            when 'UPSERTABLE' { return AccessType.UPSERTABLE;}
        }
        return null;
    }
    
    public Boolean hasLimitRows() {
        return (limitRows != null && limitRows > 0);
    }

    public Integer getLimitRows() {
        return limitRows;
    }

    public String getQueryId() {
        return id;
    }

    public void setQueryId(String id) {
        this.id = id;
    }

    public String getObjectType() {
        return objectType;
    }

    public List<ConfigItem> getFields() {
        return fields;
    }

    public List<String> getQueryFieldAPIs() {
        List<String> apis = new List<String>();
        for (ConfigItem ci : fields) {
            apis.add(ci.getApi());
        }
        return apis;
    }
 

    public class ConfigItem implements IDynamicQueryConfigItem {
        @AuraEnabled public String api;
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean display;
        @AuraEnabled public String filterOperator;
        @AuraEnabled public List<String> filterValues;

        public String getApi() {
            return api;
        }

        public String getLabel() {
            return label;
        }

        public String getType() {
            return type;
        }

        public Boolean getDisplay() {
            return display;
        }

        public String getFilterOperator() {
            return filterOperator;
        }

        // a simple filter - add in several values that can be matched to a query
        public List<String> getFilterValues () {
            return filterValues;
        }
    }

    public List<sObject> runQuery (String queryId) {
        String queryString = createQueryString (queryId);
        List<sObject> listReturn;

        List<sObject> listRaw = Database.query(queryString);

        // apply any specified FLS restrictions
        if (hasApplyUserFLS()) {
            SObjectAccessDecision filterFLS = Security.stripInaccessible(getApplyUserFLS(),listRaw);
            listReturn = filterFLS.getRecords();
        }
        else {
            listReturn = listRaw;
        }

        System.debug('filtered query response');
        System.debug(listReturn);

        return listReturn;
    }

    private String createQueryString (String queryId) {

        Boolean firstWhereClauseSubClause = true;

        List<String> selectFields = new List<String>();

        for (ConfigItem field : fields) {
            selectFields.add(field.getApi());
        }
        String queryString = 'select ' + String.join(selectFields,',') + ' from ' + this.getObjectType();

        if (this.getWhereClause() != null && this.getWhereClause().trim() != '') {
            queryString += (firstWhereClauseSubClause ? ' where ' : ' and ');
            firstWhereClauseSubClause = false;    
            queryString += this.getWhereClause() + ' : queryId ' ; // escape single quotes should not be necessary as we are dealing with ids and not expsoing to front end;         
        }

        for (ConfigItem field : fields) {
            if (field.filterValues != null && field.filterValues.size() != 0) {
                queryString += (firstWhereClauseSubClause ? ' where ' : ' and ');
                firstWhereClauseSubClause = false;  

                if (field.type == 'String') {
                    String filterOperator = field.getFilterOperator();
                    List<String> filterValues = field.getFilterValues();
                    if (filterOperator == 'IN' || filterOperator == 'NOT IN') {
                        queryString += field.api + ' ' + filterOperator + ' ' +  
                                    String.format( '(\'\'{0}\'\')', new List<String> { String.join( filterValues , '\',\'') });
                    }
                }
            }
        }

        if (this.hasEnforceSecurity()) {
            queryString += getEnforceSecurityClause();   
        }

        if (this.getOrderByClause() != null && this.getOrderByClause().trim() != '') {
            queryString += ' order by '  + this.getOrderByClause() ;
        }

        if (this.hasLimitRows()) {
            queryString += ' LIMIT ' + this.getLimitRows() ;   
        }


        System.debug('createQueryString ' + queryString);
        return queryString;
    }


}
