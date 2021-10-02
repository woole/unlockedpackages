public class ReferenceDataAccessHelper {
    private static List<CountryProduct__mdt> productCrmMapping = null;
    /**
     * @description query to Product local crm mappings metadata type
     *
     * @return list of Product local crm mappings
     */
    public static List<CountryProduct__mdt> getProductCrmMapping() {
        if (productCrmMapping == null){
            productCrmMapping = [   SELECT  Id
                                        ,   MasterLabel
                                        ,   DeveloperName
                                        ,   Language
                                        ,   QualifiedApiName
                                        ,   NamespacePrefix
                                        ,   ProductMapping__r.MasterLabel
                                        ,   ProductMapping__r.LocalCRMName__c
                                        ,   CountryMapping__r.CountryCode__c
                                    FROM CountryProduct__mdt ];
        }

        return productCrmMapping;
    }

    /**
     * @description query to Product local crm mappings metadata type
     *
     * @return map of country code and map of product and local crm name
     */
    public static Map<String, Map<String, String>> getCrmMappingByProductByCountry() {
        // BUILD A MAP OF LOCAL CRM MAPPING BY PRODUCT BY COUNTRY
        Map<String, Map<String, String>> retVal = new Map<String, Map<String, String>>();

        for (CountryProduct__mdt eachMapping : ReferenceDataAccessHelper.getProductCrmMapping()) {
            retVal.put(eachMapping.CountryMapping__r.CountryCode__c
                    , new Map<String, String> { eachMapping.ProductMapping__r.MasterLabel => eachMapping.ProductMapping__r.LocalCRMName__c });
        }

        return retVal;
    }
}
