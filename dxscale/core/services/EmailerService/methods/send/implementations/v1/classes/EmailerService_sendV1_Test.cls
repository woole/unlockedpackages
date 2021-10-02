@isTest
public class EmailerService_sendV1_Test {

    @future
    public static void insertEmailTemplate(){
        EmailTemplate template = new  EmailTemplate (DeveloperName='TestEmailTemplate',isActive=true,name='TestEmailTemplate', subject='Test Email',HtmlValue=null,Body='Testing',FolderId=UserInfo.getUserId(),TemplateType = 'text');
        insert template;
    }

    public static ServiceFrameworkBaseTestSetup initializeBaseSetup () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.implementingClass = 'EmailerService_sendV1';
        baseSetup.inputInterfaceVersion = 'IEmailRequestV1';
        baseSetup.outputInterfaceVersion = 'IHTTPResponse';
        baseSetup.inputCreationClass = 'IStringOutput';
        baseSetup.invocationType = 'Sync';
        return baseSetup;
    }

    @TestSetup
    static void makeData(){
        Contact contact = new Contact(FirstName='Fred',LastName='Tester',Email='test@example.com');
        insert contact;
        Account acc1 = new Account(Name='Test1');
        insert acc1;
        insertEmailTemplate();

    }

    @isTest
    static void EmailerService_sendV1_Test() {
        Contact c = [select Id from contact where Email='test@example.com'];
        Account acc = [select Id from account where name = 'Test1'];
        IEmailRequestV1 request = new EmailRequestV1('TestEmailTemplate',c.id, acc.id,null,false,'no-reply@sage.com');
        EmailerService_sendV1 service = new EmailerService_sendV1();
        
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();            
            IService_Output_Master outputData = service.dispatch(invocationDetails,request);
        Test.stopTest();
        System.assert(outputData!=null);
        System.assertEquals('SUCCESS',outputData.getState());
        
    }

    @isTest
    static void EmailerService_sendV1_Test_Failure() {
        Contact c = [select Id from contact where Email='test@example.com'];
        Account acc = [select Id from account where name = 'Test1'];
        IEmailRequestV1 request = new EmailRequestV1('MyDummyTemplate',c.id, acc.id,null,false,'no-reply@sage.com');
        EmailerService_sendV1 service = new EmailerService_sendV1();
        
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();            
            IService_Output_Master outputData = service.dispatch(invocationDetails,request);
        Test.stopTest();
        System.assert(outputData!=null);
        System.assertEquals(outputData.getState(),'FAIL');
        
    }    
}
