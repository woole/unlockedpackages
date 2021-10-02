@isTest
public class CallItemActivityCountLTCtrl_Test {

    
    /** Create CallItem and Task **/

    @testSetup static void setup() {
		
        Account Acc = AccountTestDataFactory.createAccount('TestUser1');
        Contact con = ContactTestDataFactory.createContact('test','user1',Acc.Id);
        User adminUser = SalesTestUtility.createUsSystemAdminUser();
        SalesTestUtility.assignPermissionSet(adminUser.id,new String[]{'Sage_Global_Sales_Admin'});
        System.runAs(adminUser){
        Call_Item__c callItem= new  Call_Item__c();
        callItem.Account__c=Acc.id;
        callItem.Contact__c=con.id;
        callItem.Active_Start_Date__c=System.today();
        callItem.Target_Finish_Date__c=System.today()+30;
        callItem.FederationUserID__c=adminUser.Email;
	    insert callItem;
        

        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'Testing CallItem'; //string
        T.OwnerId = adminUser.Id; //user id
        T.WhatId = callItem.id; //record id
        insert T;
        }

    }

    /*** CallItem Owner and Running Test user are Same**/
    @isTest
    public static void testIsOpenByOwner() {
        Test.startTest();
        Boolean expectedisOpenByOwner=true;
        User adminUser =[select Id, Email, FederationIdentifier from User where Email like '%@myorgsage.com' Limit 1 ];
        
        System.runAs(adminUser){
        Call_Item__c beforecallItem = [select id, ownerid, isOpenedByOwner__c, Attempted_Calls__c from Call_Item__c Limit 1];
        CallItemActivityCountLTCtrl.callCounter(beforecallItem.id);
        Call_Item__c aftercallItem = [select id, ownerid, isOpenedByOwner__c, Attempted_Calls__c from Call_Item__c where id=: beforecallItem.id];
        Boolean actualIsOpenByOwner=aftercallItem.isOpenedByOwner__c;
        System.AssertEquals(expectedisOpenByOwner, actualIsOpenByOwner);
        }
        Test.stopTest();
    }
    
    /*** CallItem Owner and Running Test user are not Same**/
    @isTest
    public static void testOwnerNotSameAsCallItemOwner() {
        Test.startTest();
        Boolean expectedisOpenByOwner=false;
        
        Call_Item__c beforecallItem = [select id, ownerid, isOpenedByOwner__c, Attempted_Calls__c from Call_Item__c Limit 1];
        CallItemActivityCountLTCtrl.callCounter(beforecallItem.id);
   	    Call_Item__c aftercallItem = [select id, ownerid, isOpenedByOwner__c, Attempted_Calls__c from Call_Item__c where id=: beforecallItem.id];
        Boolean actualIsOpenByOwner=aftercallItem.isOpenedByOwner__c;
        System.AssertEquals(expectedisOpenByOwner, actualIsOpenByOwner);
        Test.stopTest();
    }
	
    @isTest
    public static void testIncorrectRecordID(){
        Test.startTest();
        
        Call_Item__c beforecallItem = [select id, ownerid, isOpenedByOwner__c, Attempted_Calls__c from Call_Item__c Limit 1];
		Task t = [Select id  from Task];
        try{
        CallItemActivityCountLTCtrl.callCounter(t.id);
        }
        catch(Exception e){
		 }
        Test.stopTest();
    }



}