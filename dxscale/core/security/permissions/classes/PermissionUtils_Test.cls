@isTest
public class PermissionUtils_Test {
    
    @TestSetup
    static void makeData(){
        User adminUser = CoreTestUtils.setUpUserWithPermissions('myAdmOrg','System Administrator',new String[]{'Sage_Global_Core_Admin'});
        User userNoPerms = CoreTestUtils.setUpUserWithPermissions('myStdOrg','Standard User',new List<String>());
        
    }

    @isTest
    static void testGetMap(){
        User adminUser = [select Id from user where email like '%@myAdmOrg.com' limit 1];
        User stdUser = [select Id from user where email like '%@myStdOrg.com' limit 1];
        
        List<String> fields = new List<String>{'Exception_Type__c'};
        Test.startTest();
            System.runAs(stdUser){
                Map<PermissionUtils.PERMISSION_TYPE,List<String>> results = PermissionUtils.getDoesNotHaveAccessMap(fields,'Logger__c');
                System.assert(results !=null,'expetced a permission map but was null');
                System.assert(results.get(PermissionUtils.PERMISSION_TYPE.READ_PERMISSION) != null,'user should not have had read access to this field (i.e. expected it to be in the map)');
            }
            System.runAs(adminUser){
                Map<PermissionUtils.PERMISSION_TYPE,List<String>> results = PermissionUtils.getDoesNotHaveAccessMap(fields,'Logger__c');
                System.assert(results !=null,'expetced a permission map but was null');
                System.assert(!results.containsKey(PermissionUtils.PERMISSION_TYPE.READ_PERMISSION),'admin should have have had permssison. check permission set');
            }            
        Test.stopTest();
        
    }

    @isTest
    static void testAddNewList(){
        Map<PermissionUtils.PERMISSION_TYPE,List<String>> userPermissions = new  Map<PermissionUtils.PERMISSION_TYPE,List<String>>();
        System.assertEquals(false, userPermissions.containsKey(PermissionUtils.PERMISSION_TYPE.READ_PERMISSION),'map should not initally have a key for read permission');
        PermissionUtils.addNewList(userPermissions,'MyTestField',PermissionUtils.PERMISSION_TYPE.READ_PERMISSION);
        System.assertEquals(true, userPermissions.containsKey(PermissionUtils.PERMISSION_TYPE.READ_PERMISSION),'map should have added a read permission key');        
        PermissionUtils.addNewList(userPermissions,'MyTestField2',PermissionUtils.PERMISSION_TYPE.READ_PERMISSION);
        System.assertEquals(2, userPermissions.get(PermissionUtils.PERMISSION_TYPE.READ_PERMISSION).size(),'read permission should have 2 values');        
    }

    @isTest
    static void testCheckFieldPermission(){
        User adminUser = [select Id from user where email like '%@myAdmOrg.com' limit 1];
        User stdUser = [select Id from user where email like '%@myStdOrg.com' limit 1];

        List<String> fields = new List<String>{'Exception_Type__c'};
        System.runAs(stdUser){
            Boolean result = PermissionUtils.checkFieldPermissions(fields,'Logger__c',PermissionUtils.PERMISSION_TYPE.READ_PERMISSION);
            System.assertEquals(false, result,'std user should not have had this read permission');
        }

        System.runAs(adminUser){
            Boolean result = PermissionUtils.checkFieldPermissions(fields,'Logger__c',PermissionUtils.PERMISSION_TYPE.READ_PERMISSION);
            System.assertEquals(true, result,'admin user should have had this read permission');
        }        
        
    }

}
