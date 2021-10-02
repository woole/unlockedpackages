public inherited sharing class ServiceImplementation {

    /* Custom Metadata Retrieval and Cacheing */

    private static Map<String,ServiceImplementation.ServiceImplementationWrap> mapServiceImplementationWrap = new Map<String,ServiceImplementation.ServiceImplementationWrap>(); 

    public class ServiceImplementationWrap {
        public Id serviceImplementationMetadataId;
        public String serviceImplementationName;
        public Service_Implementation__mdt serviceImplementationMDT;

        public String getServiceImplementationMetadataId() {
            return this.serviceImplementationMetadataId;
        }

    }

    public static ServiceImplementation.ServiceImplementationWrap getMetadataWrap (String serviceImplementationName) {
        if (mapServiceImplementationWrap.containsKey(serviceImplementationName)) {
            return mapServiceImplementationWrap.get(serviceImplementationName);
        }
        else {

            List<Service_Implementation__mdt> listServiceImplementationMDT = 
                [SELECT Id, DeveloperName,Implementation_Type__c,Implementing_Class__c,Implementing_Flow__c, Output_Creation_Class__c
                    from Service_Implementation__mdt
                    where DeveloperName = :serviceImplementationName];
            
            if (listServiceImplementationMDT.size() > 0) {
                ServiceImplementation.ServiceImplementationWrap siw = cacheMetadata(listServiceImplementationMDT[0].DeveloperName, listServiceImplementationMDT[0]);
                siw.serviceImplementationMetadataId = listServiceImplementationMDT[0].Id;
                return siw;
            }
            else {
                String exceptionString = ServiceErrorStrings.ERRORMSG_NO_SERVICE_IMPLEMENTATION_FOUND + serviceImplementationName;
                throw new Service.ServiceFrameworkException(exceptionString);
            }

        }
    }

    public static ServiceImplementation.ServiceImplementationWrap cacheMetadata(String serviceImplementationName, Service_Implementation__mdt newServiceImplementationMDT) {
        ServiceImplementation.ServiceImplementationWrap simpw = new ServiceImplementation.ServiceImplementationWrap();
        simpw.serviceImplementationName = serviceImplementationName;
        simpw.serviceImplementationMDT = newServiceImplementationMDT;
        mapServiceImplementationWrap.put(newServiceImplementationMDT.DeveloperName,simpw);
        return simpw;
    }

    public static ServiceImplementation.ServiceImplementationWrap updateCacheMetadata(Service_Implementation__mdt newServiceImplementationMDT) {
        ServiceImplementation.ServiceImplementationWrap simpw = ServiceImplementation.mapServiceImplementationWrap.get(newServiceImplementationMDT.DeveloperName);
        simpw.serviceImplementationMDT = newServiceImplementationMDT;
        return simpw;
    }


    // For test classes only, creates dummy custom metadata
    // instantiate a mininmal CMT record  
    // Add additional attributes to the variable returned and add to the CMT map.

    public static Service_Implementation__mdt createTestMetadata(String serviceImplementationName) {
        Service_Implementation__mdt serviceImplementationMDT = new Service_Implementation__mdt();
        serviceImplementationMDT.DeveloperName = serviceImplementationName;
        return serviceImplementationMDT;
    }



}
