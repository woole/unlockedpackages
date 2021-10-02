public inherited sharing class ServiceInvocation {
    
    String serviceInvocationName;
    IInvocation_Details invocationDetails;

    public ServiceInvocation(String serviceInvocationName) {
        this.serviceInvocationName = serviceInvocationName;
    }

    public ServiceInvocation(IInvocation_Details invocationDetails){
        this.invocationDetails = invocationDetails;
        this.serviceInvocationName = invocationDetails.getServiceInvocationName();
    }

    public static ServiceInvocation initialize(String serviceInvocationName) {
        ServiceInvocation si = new ServiceInvocation(serviceInvocationName);
        si.retrieveMetadata();
        if (si.invocationDetails.getUseCache()) {
            // Create a hash for each invocation record that is configured to use cache
            String hashValue = ServiceCacheHandler.hashStoredInvocation((IInvocation_Stored) si.getInvocationDetails());
            System.debug('setInvocationHash:' + hashValue);
            // Pass the hash through to the service which can then use it to determine processing
            si.getInvocationDetails().setInvocationHash(hashValue);
        }

        // add dynamic content
        si.invocationDetails.setUserId(UserInfo.getUserId());
        si.invocationDetails.setInvocationTime(DateTime.Now());  

        return si;
    }

    public String getServiceInvocationName() {
        return this.serviceInvocationName;
    }

    public IInvocation_Details retrieveMetadata () {

        IInvocation_Details csOverride = getOverride ();

        if (csOverride != null) {
            this.invocationDetails = csOverride;
        }
        else {
            this.invocationDetails = getMetadataRecord (serviceInvocationName);

            // If there is no audit setup then, for now, accept this an don't throw an exception
            if (this.invocationDetails == null && serviceInvocationName != ServiceConfigStrings.AUDIT_SERVICE_INVOCATION) {
                String exceptionString = ServiceErrorStrings.STATE_NO_INVOCATION_FOUND + serviceInvocationName;
                throw new Service.ServiceFrameworkException(exceptionString);    
            }
        }

        return this.invocationDetails;
    }

    public IInvocation_Details getInvocationDetails() {
        return this.invocationDetails;
    }

    // retrieves an instance of the input interface. 
    // Note however than the code using this will still need to do an explicit cast to the correct interface definition 
    public IService_Input_Master getInputInterfaceInstance() {
        return (IService_Input_Master) getInputCreationClassType().newInstance();
    }

    private Type getInputCreationClassType() {
        String inputCreationClass = this.getInvocationDetails().getInputCreationClass();
        return Type.forName(inputCreationClass);
    }

    // public boolean isOutputInterfaceInstance(Object obj) {
    //     String outputInterfaceVersion = this.getInvocationDetails().getOutputInterfaceVersion();
    //     return obj instanceOf Type.forName(outputInterfaceVersion);
    // }


    // The usual mechanism for invoking a service, using the invocation details derived from its metadata 
    public IService_Output_Master invokeService(IService_Input_Master inputData) {
        IService_Output_Master outputData = null;
        IService_Output_Master auditData = null;
        try {
            this.invocationDetails.setInvocationTime(DateTime.Now());  
            if (!isUserPermissioned()){ // check user is permissioned to use the invocation.
                return isUserPermissionedFailsResponse();
            }

            switch on this.invocationDetails.getInvocationType() {
                when 'Sync' , 'Stub', 'OutboundBroker' {
                    Service service = Service.initialize(this.invocationDetails.getServiceName());

                    // note that regardless of whether a service returns a response that the invoker uses it should always return at least the base Interface requirement (success / message)
                    outputData = (IService_Output_Master) service.delegateImplementation(this.invocationDetails,inputData);
                    System.debug('CorrelationId = ' + outputData.getCorrelationId());
                    // the invocation can be configured to always return raw output
                    if (this.invocationDetails.getOutputAuditOverrideOption() != 'Raw') {
                        auditData = service.generateOutputAudit(outputData);
                    }
                    else {
                        auditData = outputData;
                    }
                }
                when 'Async', 'Audit' { // Audit invocations are Asynchronously published
                    System.debug('invokeService publishAsync');
                    outputData =  (IService_Output_Master) publishAsync (inputData);
                }
                when 'AsyncNoPublish' {
                    outputData = new ServiceOutputMaster();
                    outputData.setState ('SUCCESS');
                }
                when else {
                    System.debug('unrecognized Invocation_Type__c');
                    String exceptionString = ServiceErrorStrings.STATE_NO_INVOCATION_TYPE + this.invocationDetails.getInvocationType();
                    throw new Service.ServiceFrameworkException(exceptionString);
                }
            }
        }
        catch (Exception e) {            
            outputData = new ServiceOutputMaster();
            outputData.setState (ServiceErrorStrings.STATE_INVOCATION_GENERIC_EXCEPTION);
            outputData.setErrorMessage(e.getMessage());
        }

        // publish outcome as appropriate
        // failure to publish an error should not cause a transaction to fail however.

        try {
            ServiceInvocation sinvAudit = ServiceAuditPublisher.getAuditServiceInvocation(this.invocationDetails,  outputData.getState(), 'Invoker');
            if (sinvAudit != null && sinvAudit.getInvocationDetails() != null) {
                ServiceAuditPublisher.publishAudit (sinvAudit, this.invocationDetails, inputData, outputData, auditData);
            }
        }
        catch (Exception e) {   
            // error handing framework has failed, the transaction continues to be processed         
            System.debug(LoggingLevel.ERROR, 'Could not publish Audit Message. Check configuration. ' + e.getMessage());
        }

        return outputData;
    }



    /* 
    Note there is only partial coverage of this method in the generic package.
    This is deliberate as to test the method fully would require creating a Platform Event in the org which we should not do */


    @TestVisible
    private IService_Output_Master publishAsync (IService_Input_Master inputData) {
        // note that there are different behaviours for high volume and standard volume PEs
        // EventBus.publish is async for high volume events 
        // There was an org limit on describe events but there this was removed
        // Note that there we are not bulkifying here, the service service should invoke one event as a list rather than multiple events

        IService_Output_Master outputData = new ServiceOutputMaster();
        SObject sobj;

        try {
            sobj = populatePlatformEvent (this.invocationDetails.getAsyncPlatformEvent(), inputData);
        }
        catch (Exception e) {            
            outputData.setState (ServiceErrorStrings.STATE_EVENT_CREATION_FAILURE);
            outputData.setErrorMessage(ServiceErrorStrings.ERRORMSG_EVENT_CREATION_FAILURE + invocationDetails.getAsyncPlatformEvent());
            return outputData;
        }


        Database.SaveResult sr = EventBus.publish(sobj);
        if (sr.isSuccess()) {
            System.debug('Successfully published event to PE: ' + this.invocationDetails.getAsyncPlatformEvent() + ' with id ' + sr.getId());
            outputData.setState('SUCCESS');
        } else {
            for(Database.Error err : sr.getErrors()) {
                String errorMsg = 'Error publishing to : ' + sobj.getSObjectType();
                errorMsg += ': Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage();
                System.debug(errorMsg);
                outputData.setState (ServiceErrorStrings.STATE_EVENT_PUBLISH_FAILURE);
                outputData.setErrorMessage(errorMsg);
            }
        }       
        return outputData;

    }


    /* 
    Note there is no test coverage of this method in the generic package.
    This is deliberate as to test the method would require creating a Platform Event in the org which we should not do */

    @TestVisible
    private SObject populatePlatformEvent (String eventName, IService_Input_Master inputData) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(eventName);
        SObject sobj = targetType.newSObject();
        sobj.put(ServiceAsync.INVOCATION_DETAILS_FIELD, ServiceSerialize.serializeObject(this.invocationDetails));                
        sobj.put(ServiceAsync.INPUT_DATA_FIELD,ServiceSerialize.serializeObject(inputData) );
        return sobj;
    }

    // Custom Metadata Retrieval and Cacheing

    public static IInvocation_Details getMetadataRecord (String serviceInvocationName) {
        List<Service_Invocation__mdt> listServiceInvocationMDT = 
            [SELECT Id, 
                DeveloperName,
                MasterLabel,
                Invocation_Type__c, 
                Log_Requests__c, 
                Async_Only_Log_Service__c, 
                Async_Platform_Event__c,
                Input_Interface_Version__c,
                Output_Interface_Version__c,
                Input_Creation_Class__c,
                Iteration__c,
                Method__c,
                Service_Name__c,
                Use_Cache__c,
                Use_Cache_Partition__c,
                External_Invocation__c,
                Invocation_Permission__c,
                Invocation_Restricted_By_Permission__c,
                External_Restricted_User__c,
                Output_Audit_Override_Option__c
                from Service_Invocation__mdt
                where DeveloperName = :serviceInvocationName];                    

        if (listServiceInvocationMDT.size() > 0) {
            IInvocation_Details sad = new ServiceInvocationImplementations.InvocationDetails();
            Service_Invocation__mdt meta = listServiceInvocationMDT[0];
            sad.setServiceName(meta.Service_Name__c);
            sad.setInvocationType(meta.Invocation_Type__c);
            sad.setMetadataId(meta.Id);
            sad.setLogRequests(meta.Log_Requests__c);
            sad.setAsyncOnlyLogService(meta.Async_Only_Log_Service__c);
            sad.setServiceInvocationName(meta.DeveloperName);
            sad.setAsyncPlatformEvent(meta.Async_Platform_Event__c);
            sad.setInputInterfaceVersion(meta.Input_Interface_Version__c);        
            sad.setInputCreationClass(meta.Input_Creation_Class__c);        
            sad.setOutputInterfaceVersion(meta.Output_Interface_Version__c);        
            sad.setIteration ((Integer) meta.Iteration__c);
            sad.setMethod(meta.Method__c);
            sad.setExternalInvocation(meta.External_Invocation__c);
    	    sad.setInvocationPermission(meta.Invocation_Permission__c);
            sad.setInvocationRestrictedByPermission(meta.Invocation_Restricted_By_Permission__c);
            sad.setExternalRestrictedUser(meta.External_Restricted_User__c);
            sad.setOutputAuditOverrideOption(meta.Output_Audit_Override_Option__c);
            sad.setUseCache(meta.Use_Cache__c);
            sad.setUseCachePartition(meta.Use_Cache_Partition__c);
            return sad;
        }
        else {
            return null;
        }
    }

    public List<IInvocation_Details> retrieveOverrides () {
        List<Service_Invocation_Override__c> listServiceInvocationOverrides = 
        [SELECT Id, 
            Name,
            Invocation_Type__c, 
            Log_Requests__c, 
            Async_Only_Log_Service__c, 
            Stub_Class__c,
            Async_Platform_Event__c,
            Input_Interface_Version__c,
            Output_Interface_Version__c,
            Input_Creation_Class__c,
            Iteration__c,
            Method__c,
            Service_Name__c,
            Use_Cache__c,
            Use_Cache_Partition__c,
            Override_Default__c,
            Metadata_Invoker_Id__c,
            User_Permission__c,
            External_Invocation__c,
            Invocation_Permission__c,
            Invocation_Restricted_By_Permission__c,
            External_Restricted_User__c,
            Output_Audit_Override_Option__c
            from Service_Invocation_Override__c
            where Metadata_Invoker_Id__c = :serviceInvocationName];

        List<IInvocation_Details> listisi = new List<IInvocation_Details>();

        for (Service_Invocation_Override__c csOverride : listServiceInvocationOverrides) {

            IInvocation_Details sad = new ServiceInvocationImplementations.InvocationDetails();
            sad.setServiceName(csOverride.Service_Name__c);
            sad.setInvocationType(csOverride.Invocation_Type__c);
            sad.setMetadataId(csOverride.Id);
            sad.setLogRequests(csOverride.Log_Requests__c);
            sad.setAsyncOnlyLogService(csOverride.Async_Only_Log_Service__c);
            sad.setServiceInvocationName(csOverride.Metadata_Invoker_Id__c);
            sad.setAsyncPlatformEvent(csOverride.Async_Platform_Event__c);
            sad.setInputInterfaceVersion(csOverride.Input_Interface_Version__c);        
            sad.setInputCreationClass(csOverride.Input_Creation_Class__c);        
            sad.setOutputInterfaceVersion(csOverride.Output_Interface_Version__c);        
            sad.setIteration ((Integer) csOverride.Iteration__c);
            sad.setMethod(csOverride.Method__c);
    	    sad.setExternalInvocation(csOverride.External_Invocation__c);
            sad.setInvocationPermission(csOverride.Invocation_Permission__c);
            sad.setInvocationRestrictedByPermission(csOverride.Invocation_Restricted_By_Permission__c);
            sad.setExternalRestrictedUser(csOverride.External_Restricted_User__c);
            sad.setOutputAuditOverrideOption(csOverride.Output_Audit_Override_Option__c);
            sad.setUseCache(csOverride.Use_Cache__c);
            sad.setUseCachePartition(csOverride.Use_Cache_Partition__c);
            sad.setStubClass(csOverride.Stub_Class__c);
            sad.setOverrideDefault(csOverride.Override_Default__c);
            sad.setUserPermission(csOverride.User_Permission__c);
            listisi.add(sad);
        }

        return listisi;
    }
    
    // return override if relevant
    // returns the first with a user permission requirement satisfied by the running user
    // if none found then returns the default override, in the absence of that returns null

    public IInvocation_Details getOverride () {
        List<IInvocation_Details> allOverrides = retrieveOverrides();
        boolean foundDefault = false;
        IInvocation_Details defaultOverride = null;

        for (IInvocation_Details isi : allOverrides) {
            if (isi.getOverrideDefault()) {
                foundDefault = true;
                isi.setConfigurationType('Default Custom Override');
                defaultOverride = isi;
            }
            else {
                String userPermission = isi.getUserPermission();
                if (PermissionUtils.userHasCustomPermission(userPermission)){
                    isi.setConfigurationType('User Custom Override');
                    return isi;
                }
            }
        }        
        return defaultOverride;
    }    

    // used to determine if an external call should be allowed
    public boolean allowExternalCall() {
        return invocationDetails.getExternalInvocation();
    }

    public IService_Output_Master allowExternalCallFail() {
        IService_Output_Master outputData = new ServiceOutputMaster();
        outputData.setState (ServiceErrorStrings.STATE_INVALID_EXTERNAL_USER);
        outputData.setErrorMessage (ServiceErrorStrings.ERRORMSG_INVALID_EXTERNAL_USER);
        return outputData;
    }

    public boolean isUserPermissioned() {
        if (invocationDetails.getInvocationRestrictedByPermission()) {
            String invocationPermission = invocationDetails.getinvocationPermission();
            if (invocationPermission != null && invocationPermission.trim() != '') {
                return (PermissionUtils.userHasCustomPermission(invocationPermission));
            }    
        }
        return true;
    }

    public IService_Output_Master isUserPermissionedFailsResponse() {
        IService_Output_Master outputData = new ServiceOutputMaster();
        outputData.setState (ServiceErrorStrings.STATE_UNPERMISSIONED_USER);
        outputData.setErrorMessage (ServiceErrorStrings.ERRORMSG_UNPERMISSIONED_USER);
        return outputData;
    }


}
