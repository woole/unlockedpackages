@IsTest
public class DynamicQueryService_QueryV1_Test {

    public static ServiceFrameworkBaseTestSetup initializeBaseSetup () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.implementingClass = 'DynamicQueryService_QueryV1';
        baseSetup.inputInterfaceVersion = 'IDynamicQueryConfigData';
        baseSetup.outputInterfaceVersion = 'IQueryListMap';
        baseSetup.inputCreationClass = 'DynamicQueryConfigData';
        baseSetup.invocationType = 'Sync';
        return baseSetup;
    }
 
    @IsTest
    public static void Service_Success () {

        // Need an object that is always going to have data in it in any environment
        // We use the User object and the running user's id as will always exists and will always be populated

        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // retrieve the custom metadata for this invocation
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        String masterConfig =  '{"whereClause":"id = ","enforceSecurity":true,"applyUserFLS":"READABLE","limitRows":500,"orderByClause":"Name","terminal":true,"fields":[{"api":"name","label":"Name","type":"String","display":true,"filterOperator":"NOT IN","filterValues":["RIDICULOUS MADE UP NAME"]},{"api":"id","type":"id","display":true},{"api":"phone","type":"phone","display":true},{"api":"isActive","type":"boolean","display":true},{"api":"Latitude","type":"decimal","display":true},{"api":"lastvieweddate","type":"date","display":true},{"api":"NumberOfFailedLogins","type":"integer","display":true},{"api":"LanguageLocaleKey","type":"currency","display":true}],"objectType":"User"}';

        // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
        IDynamicQueryConfigData cd = (IDynamicQueryConfigData) ServiceSerialize.deserializeByClassName(masterConfig,baseSetup.inputCreationClass);
        Id recordId = UserInfo.getUserId();
        cd.setQueryId(recordId);

        // invoke the service and cast the output to the correct interface
        IQueryListMap outputData;

        outputData = (IQueryListMap) sinv.invokeService(cd);

        // Prepare the screen output
        String state = outputData.getState();
        String errorMessage = outputData.getErrorMessage();
        Boolean potentiallyMoreRows = outputData.getPotentiallyMoreRows();

        System.assertEquals('SUCCESS',state,'state should have been SUCCESS but was ' + state);      
        System.assertEquals(false,potentiallyMoreRows,'potentiallyMoreRows should have false ');      

        IQueryListMap iso = (IQueryListMap) outputData;

        System.assertEquals(1,iso.getNumberRows(),'should have had 1 row, but was ' + iso.getNumberRows());
        System.assertEquals(1,iso.getAll().size(),'All rows should have had 1 row, but was ' + iso.getAll().size());

        while(iso.hasNext()) {
            Map<String,Object> mapper = iso.getNext();  
            String userId = UserInfo.getUserId();
            System.assertEquals(userId,mapper.get('id'),'id should have matched userId of ' + userId + ' but was ' +mapper.get('id'));      
        }
   }


   @IsTest
    public static void Service_FailBadMasterConfig () {

        // Need an object that is always going to have data in it in any environment
        // We use the User object and the running user's id as will always exists and will always be populated

        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // retrieve the custom metadata for this invocation
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        // bad config containing a non-existent field api name
        String badMasterConfig =  '{"whereClause":"id = ","limitRows":500,"orderByClause":"Name","terminal":true,"fields":[{"api":"thisisnotarealfieldapi","label":"Name","type":"String","display":true},{"api":"id","type":"id","display":true},{"api":"phone","type":"phone","display":true},{"api":"isActive","type":"boolean","display":true},{"api":"Latitude","type":"decimal","display":true},{"api":"lastvieweddate","type":"date","display":true},{"api":"NumberOfFailedLogins","type":"integer","display":true},{"api":"LanguageLocaleKey","type":"currency","display":true}],"objectType":"User"}';

        // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
        IDynamicQueryConfigData cd = (IDynamicQueryConfigData) ServiceSerialize.deserializeByClassName(badMasterConfig,baseSetup.inputCreationClass);
        Id recordId = UserInfo.getUserId();
        cd.setQueryId(recordId);

        // invoke the service and cast the output to the correct interface
        IQueryListMap outputData;
        outputData = (IQueryListMap) sinv.invokeService(cd);

        // Prepare the screen output
        String state = outputData.getState();
        String errorMessage = outputData.getErrorMessage();

        System.assertEquals('FAILURE: DynamicQueryService: Query Failed',state,'state should have been FAILURE: DynamicQueryService: Query Failed but was ' + state);      
        System.assert(errorMessage.startsWith('Query failed'),'error should have started with Query Failed');      

    }


}


