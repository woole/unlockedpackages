@IsTest
public class callItemActiveDeactivateBatch_Test {   
    @IsTest static void test() { 
        CallItem_Helper.runTriggerMethod = true;
        User adminUser = SalesTestUtility.createUsSystemAdminUser();
        SalesTestUtility.assignPermissionSet(adminUser.id,new String[]{'Sage_Global_Sales_Admin'});
        System.runAs(adminUser){
            List<Call_Item__c> CallItemList = new List<Call_Item__c>();
            // insert 20 call items
            for (Integer i=0;i<10;i++) {
                CallItemList.add(new Call_Item__c(FederationUserID__c=adminUser.Email, Active_Start_Date__c = date.TODAY(),Target_Finish_Date__c = date.TODAY()+2,Visibility_Status__c = 'Inactive'));
                CallItemList.add(new Call_Item__c(FederationUserID__c=adminUser.Email,Target_Finish_Date__c = date.TODAY(),Active_Start_Date__c = date.TODAY()+2,Visibility_Status__c = 'Active'));
                        }
            insert CallItemList;
        }
        Test.startTest();
        callItemActiveDeactivateBatch cib = new callItemActiveDeactivateBatch();
        Id batchId = Database.executeBatch(cib);     
        Test.stopTest();
                
        System.assertEquals(10, [select count() from Call_Item__c where Active_Start_Date__c <= TODAY AND Visibility_Status__c = 'Active']);
        System.assertEquals(10, [select count() from Call_Item__c where Target_Finish_Date__c <= TODAY AND Visibility_Status__c = 'InActive']);
      }
    
      @IsTest static void test1() {
        CallItem_Helper.runTriggerMethod = true;
        User adminUser = SalesTestUtility.createUsSystemAdminUser();
        System.runAs(adminUser){
            List<Call_Item__c> CallItemList = new List<Call_Item__c>();
            for (Integer i=0;i<10;i++) {
                CallItemList.add(new Call_Item__c(FederationUserID__c=adminUser.Email,Target_Finish_Date__c = date.TODAY(),Active_Start_Date__c = date.TODAY(),Visibility_Status__c = 'Active'));            
            }
            insert CallItemList;
        }
        
         
        Test.startTest();
        callItemActiveDeactivateBatch cib = new callItemActiveDeactivateBatch();
        Id batchId = Database.executeBatch(cib);
        Test.stopTest();
                
        System.assertEquals(10, [select count() from Call_Item__c where Target_Finish_Date__c <= TODAY AND Visibility_Status__c = 'InActive']);
    }
}