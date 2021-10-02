@IsTest(SeeAllData = false)
public with sharing class ReferenceDataAccessHelper_Test {
    @IsTest static void getProductCrmMappingTest() {
        // GIVEN
        String countryCodeGB = 'GB';
        String countryCodeAUS = 'AU';
        // WHEN
        Test.startTest();
        List<CountryProduct__mdt> listProductCrmMapping = ReferenceDataAccessHelper.getProductCrmMapping();
        Test.stopTest();
        // THEN
        System.assert(listProductCrmMapping != null && !listProductCrmMapping.isEmpty());
        for (CountryProduct__mdt eachCountryProduct :listProductCrmMapping) {
            if (eachCountryProduct.CountryMapping__r.CountryCode__c != null) {
                if (eachCountryProduct.CountryMapping__r.CountryCode__c.equalsIgnoreCase(countryCodeGB)
                        || eachCountryProduct.CountryMapping__r.CountryCode__c.equalsIgnoreCase(countryCodeAUS)) {
                    System.assertEquals('INA - Intacct', eachCountryProduct.ProductMapping__r.LocalCRMName__c);
                }
            }
        }
    }

    @IsTest static void getCrmMappingByProductByCountryTest() {
        // GIVEN
        String countryCodeGB = 'GB';
        String countryCodeAUS = 'AU';
        String productName = 'Sage Intacct';
        // WHEN
        Test.startTest();
        Map<String, Map<String, String>> mapCountryProductCrm = ReferenceDataAccessHelper.getCrmMappingByProductByCountry();
        Test.stopTest();
        // THEN
        System.assert(mapCountryProductCrm != null && !mapCountryProductCrm.isEmpty());
        System.debug(mapCountryProductCrm);
        System.assert(mapCountryProductCrm.get(countryCodeAUS) != null);
        System.assert(mapCountryProductCrm.get(countryCodeGB) != null);
        System.assertEquals('INA - Intacct', mapCountryProductCrm.get(countryCodeGB).get(productName));
        System.assertEquals('INA - Intacct', mapCountryProductCrm.get(countryCodeAUS).get(productName));
    }
}
