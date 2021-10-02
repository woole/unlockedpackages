@isTest
public class AuditRepublish_Test {
   

    @TestSetup
    static void makeData(){
        User adminUser = CoreTestUtils.setUpUserWithPermissions('myAdmOrg','System Administrator',new String[]{'auditService'});
        User userNoPerms = CoreTestUtils.setUpUserWithPermissions('myStdOrg','Standard User',new List<String>());
        Service_Framework_Audit__c audit1 = new Service_Framework_Audit__c(Input_Data__c='{"hello":"world"}',Invocation_Name__c='TestInvocation1');
        insert audit1;
    }

    @isTest
    static void testGetInput(){
        User adminUser = [select Id from user where email like '%@myAdmOrg.com' limit 1];
        User stdUser = [select Id from user where email like '%@myStdOrg.com' limit 1];        
        Service_Framework_Audit__c audit = [select Id from Service_Framework_Audit__c LIMIT 1];
        Test.startTest();
            System.runAs(stdUser){
                String inputData = AuditRepublish.getInput(audit.Id);
                System.assert(inputData == null,'expected Not to have permissions');
            }
            System.runAs(adminUser){
                String inputData = AuditRepublish.getInput(audit.Id);
                System.assert(inputData != null,'expected to to have permissions');
            }            
        Test.stopTest();        
    
    }

}
