public inherited sharing class ServiceMethod {

    /* Custom Metadata Retrieval and Cacheing */

    private static Map<String,ServiceMethod.ServiceMethodWrap> mapServiceMethodWrap = new Map<String,ServiceMethod.ServiceMethodWrap>(); 

    public class ServiceMethodWrap {
        public Id serviceMethodMetadataId;
        public String serviceName;
        public Integer iteration;
        public String serviceMethodName;
        public String serviceImplementationName;
        public String nextInvocationName;
        public String responseInvocationName;
        public Service_Method__mdt serviceMethodMDT;

        public String getServiceImplementationName() {
            return this.serviceImplementationName;
        }

        public String getNextInvocationName() {
            return this.nextInvocationName;
        }

        public String getResponseInvocationName() {
            return this.responseInvocationName;
        }

        public String getServiceMethodMetadataId() {
            return this.serviceMethodMetadataId;
        }

    }

    public static String createServiceMetadataKey (String serviceName, Integer iteration, String serviceMethodName) {
        return serviceName + '.' + iteration + '.' + serviceMethodName;
    }

    public static ServiceMethod.ServiceMethodWrap getMetadataWrap (String serviceName, Integer iteration, String serviceMethodName) {
        String mapKey = createServiceMetadataKey (serviceName, iteration, serviceMethodName);
        if (mapServiceMethodWrap.containsKey(mapKey)) {
            return mapServiceMethodWrap.get(mapKey);
        }
        else {
            System.debug('ServiceMethod.getMetadataWrap:' + serviceName + ',' +  iteration + ',' + serviceMethodName);

            List<Service_Method__mdt> listServiceMethodMDT = 
                [SELECT Id, DeveloperName,Method__c,Service__c, Service_Implementation__c, Iteration__c, How_Implemented__c, External_Processing_Id__c, Next_Invocation__r.DeveloperName,Response_Invocation__r.DeveloperName, Service_Implementation__r.DeveloperName, Service__r.DeveloperName 
                    from Service_Method__mdt
                    where Method__c = :serviceMethodName and Iteration__c = :iteration and Service__r.DeveloperName = :serviceName];
            
            if (listServiceMethodMDT.size() > 0) {
                ServiceMethod.ServiceMethodWrap smw = cacheMetadata(serviceName, iteration, serviceMethodName, listServiceMethodMDT[0]);
                smw.serviceImplementationName = listServiceMethodMDT[0].Service_Implementation__r.DeveloperName;
                smw.nextInvocationName = listServiceMethodMDT[0].Next_Invocation__r.DeveloperName;
                smw.responseInvocationName = listServiceMethodMDT[0].Response_Invocation__r.DeveloperName;
                smw.serviceMethodMetadataId = listServiceMethodMDT[0].Id;
                return smw;
            }
            else {
                return null;
            }
        }
    }

    public static ServiceMethod.ServiceMethodWrap cacheMetadata(String serviceName, Integer iteration, String serviceMethodName, Service_Method__mdt newServiceMethodMDT) {
        ServiceMethod.ServiceMethodWrap smw = new ServiceMethod.ServiceMethodWrap();
        String mapKey = createServiceMetadataKey (serviceName, iteration, serviceMethodName);
        smw.serviceName = serviceName;
        smw.iteration = iteration;
        smw.serviceMethodName = serviceMethodName;
        smw.serviceMethodMDT = newServiceMethodMDT;
        mapServiceMethodWrap.put(mapKey,smw);
        return smw;
    }

    // For test classes only, creates dummy custom metadata
    // instantiate a mininmal CMT record  
    // Add additional attributes to the variable returned and add to the CMT map.

    public static Service_Method__mdt createTestMetadata(String serviceName, Integer iteration, String serviceMethodName) {
        Service_Method__mdt serviceMethodMDT = new Service_Method__mdt();
        serviceMethodMDT.DeveloperName = createServiceMetadataKey (serviceName, iteration, serviceMethodName);
        serviceMethodMDT.Method__c = serviceMethodName;
        return serviceMethodMDT;
    }

}
