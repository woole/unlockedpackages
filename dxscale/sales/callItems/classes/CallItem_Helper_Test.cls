@isTest
public class CallItem_Helper_Test {
	@testsetup
	static void setup() {
		
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser  = new User(Alias = 'standt', Email='callitemtst@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, FederationIdentifier ='callitemtst@testorg.com',
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='callitemtst@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);        
   		System.runAs(adminUser){
            Account acc1 = AccountTestDataFactory.createAccount('Test1');
		Account acc2 = AccountTestDataFactory.createAccount('Test2');
		Contact con1 = ContactTestDataFactory.createContact(
			'test1',
			'user1',
			acc1.Id
		);
		Contact con2 = ContactTestDataFactory.createContact(
			'test2',
			'user2',
			acc2.Id
		);
		Call_Item__c ci_today_fsdate = new Call_Item__c();
		ci_today_fsdate.Call_List_Name__c = 'Test call item';
		ci_today_fsdate.Account__c = acc1.id;
		ci_today_fsdate.Contact__c = con1.id;
		ci_today_fsdate.Active_Start_Date__c = System.today() + 5;
		ci_today_fsdate.Target_Finish_Date__c = System.today() + 30;
		ci_today_fsdate.FederationUserID__c = adminUser.Email;
		insert ci_today_fsdate;

		Call_Item__c ci_tsdate = new Call_Item__c();
		ci_tsdate.Call_List_Name__c = 'Test call item today';
		ci_tsdate.Account__c = acc2.id;
		ci_tsdate.Contact__c = con2.id;
		ci_tsdate.Active_Start_Date__c = System.today();
		ci_tsdate.Target_Finish_Date__c = System.today() + 30;
		ci_tsdate.FederationUserID__c = adminUser.Email;
		insert ci_tsdate;

		Call_Item__c emptyContact = new Call_Item__c();
		emptyContact.Call_List_Name__c = 'Test CallItem Status';
		emptyContact.Account__c = acc2.id;
		emptyContact.Contact__c = null;
		emptyContact.Active_Start_Date__c = System.today() + 5;
		emptyContact.Target_Finish_Date__c = System.today() + 30;
		emptyContact.FederationUserID__c = adminUser.Email;
		insert emptyContact;

		Call_Item__c ci_ActiveInactive = new Call_Item__c();
		ci_ActiveInactive.Call_List_Name__c = 'Inactivate CallItem';
		ci_ActiveInactive.Account__c = acc2.id;
		ci_ActiveInactive.Contact__c = con2.id;
		ci_ActiveInactive.Active_Start_Date__c = System.today();
		ci_ActiveInactive.Target_Finish_Date__c = System.today();
		ci_ActiveInactive.Visibility_Status__c = 'Active';
		ci_ActiveInactive.FederationUserID__c = adminUser.Email;
		insert ci_ActiveInactive;

		Call_Item__c ci_ActiveInactive1 = new Call_Item__c();
		ci_ActiveInactive1.Call_List_Name__c = 'Inactivate CallItem1';
		ci_ActiveInactive1.Account__c = acc2.id;
		ci_ActiveInactive1.Contact__c = con2.id;
		ci_ActiveInactive1.Active_Start_Date__c = System.today() + 5;
		ci_ActiveInactive1.Target_Finish_Date__c = System.today();
		ci_ActiveInactive1.Visibility_Status__c = 'Active';
		ci_ActiveInactive1.FederationUserID__c = adminUser.Email;
		insert ci_ActiveInactive1;

		Call_Item__c addCallItem = new Call_Item__c();
		addCallItem.Call_List_Name__c = 'Add CallItem1';
		addCallItem.Account__c = acc1.id;
		addCallItem.FederationUserID__c = adminUser.Email;
		insert addCallItem;
        }
	}

	@isTest
	public static void testCallItemInsert() {
		Test.startTest();
		User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
        Contact con = [
			SELECT id, accountid
			FROM Contact
			WHERE account.name = 'Test2'
		];
        
        String expectedVisibilityStatus = 'Inactive';
        Integer expectedNumberOfContacts = 1;
        String expectedOwner = adminUser.Id;
        String expectedOwnerEmail = adminUser.Email;
		String expectedContactId = con.Id;
		String expectedStatus = 'Missing Contact';
        
		Call_Item__c ci = [
			SELECT
				Id,
				OwnerId,
                Owner.Email,
				Visibility_Status__c,
				contact__c,
				Number_of_Account_Contacts__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'Add CallItem1'
			LIMIT 1
		];
        
		ci.contact__c = con.Id;
        update ci;
        
		//visibility status must be "Inactive" if Active Start Date is not populated and status not set to Active.
		system.assertEquals(expectedVisibilityStatus, ci.Visibility_Status__c);
		//expectedowner must be running User ID .
        system.assertEquals(expectedOwner, ci.OwnerId);
        system.assertEquals(expectedOwnerEmail, ci.Owner.Email);
		//This is manually done by the user, on line 98, we are setting the contact to con.id and expected the same contactid on the callitem
        system.assertEquals(expectedContactId, ci.contact__c);
		//Number Of Contact must be equal to Contacts on the Account Selected.
		system.assertEquals(expectedNumberOfContacts,ci.Number_of_Account_Contacts__c);
        }
		Test.stopTest();
	}
    
	@isTest
	public static void testVisbilityStatusWithActiveStartDate_Today() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
		String expectedVisibilityStatus = 'Active';
		Call_Item__c ci = [
			SELECT Id, Visibility_Status__c
			FROM Call_Item__c
			WHERE Active_Start_Date__c <= Today
			LIMIT 1
		];
		// If Active Start Date is equal to Today, then system should automatically set the Visibility Status to Active
		system.assertEquals(expectedVisibilityStatus, ci.Visibility_Status__c);
        }
		Test.stopTest();
	}

	@isTest
	public static void testVisbilityStatusWithActiveStartDate_Future() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
		String expectedVisibilityStatus = 'Inactive';
		Call_Item__c ci = [
			SELECT Id, Visibility_Status__c
			FROM Call_Item__c
			WHERE Active_Start_Date__c > Today
			LIMIT 1
		];
		// If Active Start Date is not equal to Today, then system should automatically set the Visibility Status to Inactive
		system.assertEquals(expectedVisibilityStatus, ci.Visibility_Status__c);
        }
		Test.stopTest();
	}

	@isTest
	public static void testUpdateOwnerOnChangeOfFederationEmail() {
		Test.startTest();
        
        User adminUser = [select Id, Email, FederationIdentifier from User where Email ='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
	    User adminUser2 = SalesTestUtility.createUsSystemAdminUser();
		String expectedOwner = adminUser2.Id;
        
		Call_Item__c ci = [SELECT Id, status__c, ownerid, FederationUserID__c, Account__c FROM Call_Item__c LIMIT 1];
        ci.FederationUserID__c = adminUser2.FederationIdentifier;
        update ci;
		ci = [SELECT Id, status__c, ownerid, FederationUserID__c, Account__c FROM Call_Item__c LIMIT 1];
        //ci.FederationUserID__c = adminUser2.FederationIdentifier;
		//owner id must always be equal to Federation User Email Owner ID
		system.assertEquals(expectedOwner, ci.ownerid);
        }
		Test.stopTest();
	}
    
	@isTest
	public static void testPopulateAccountWithSFCRMID() {
		Test.startTest();
        User adminUser = [select Id, Email, FederationIdentifier from User where Email ='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
		String expectedAccountName = 'Test2';
		Account acc = [SELECT id FROM Account WHERE Name = 'Test2'];
		Call_Item__c ci = [
			SELECT Id, Account__c, Account__r.Name, FederationUserID__c
			FROM Call_Item__c
			WHERE Account__c = :acc.id
			LIMIT 1
		];

		//Base Test, we should see the same account that was populated on the callitem
		System.assertEquals(expectedAccountName, ci.Account__r.Name);
        }
		Test.stopTest();
	}

	@isTest
	public static void testPopulateFederatedUser() {
		Test.startTest();
		
       User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
        String expectedOwner = adminUser.Id;
		Account acc = [SELECT id FROM Account LIMIT 1];
		Call_Item__c ci = [
			SELECT Id, status__c, ownerid, FederationUserID__c, Account__c
			FROM Call_Item__c
			WHERE Account__c = :acc.Id
			LIMIT 1
		];
		//owner id must always be equal to Federation User Email Owner ID
		system.assertEquals(expectedOwner, ci.ownerid);
        }
		Test.stopTest();
	}

	@isTest
	public static void testPopulateInvalidFederatedUser() {
		Test.startTest();
        User adminUser1 =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser1){
		User adminUser =[select FederationIdentifier from User Limit 1 ];
        String expectedOwner = adminUser.Id;
		Account acc = [SELECT id FROM Account LIMIT 1];
		Call_Item__c ci = [
			SELECT Id, status__c, ownerid, FederationUserID__c, Account__c
			FROM Call_Item__c
			WHERE Account__c = :acc.Id
			LIMIT 1
		];
		ci.FederationUserID__c = 'EmailDoesntExists@example.com';
		try {
			update ci;
		} catch (Exception e) {
			//Expected Outcome - should get an error message
			System.assert(e.getMessage().contains('Federation ID doesnt exist'));
		}
        }
		Test.stopTest();
	}

	@isTest
	public static void testUpdateStatusWhenContactFound() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
		String expectedCiStatus = 'To Be Actioned';
		String currentStatus = 'Missing Contact';
		Contact con = [SELECT id, accountid FROM contact LIMIT 1];
		Call_Item__c ci = [
			SELECT Id, Account__c, Account__r.Name, contact__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'Test CallItem Status'
			LIMIT 1
		];
		ci.contact__c = con.Id;
		update ci;
		ci = [
			SELECT
				Id,
				Account__c,
				Account__r.Name,
				FederationUserID__c,
				contact__c,
				status__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'Test CallItem Status'
			LIMIT 1
		];

		//Once contact set on the callitem, its status should be moved to "To Be Actioned"
		system.assertEquals(expectedCiStatus, ci.status__c);
        }
		Test.stopTest();
	}

	@isTest
	public static void testInactiveCallItem() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
		String expectedVisibiliyStatus = 'Inactive';
		String currentVisibiliyStatus = 'Active';
		Call_Item__c ci = [
			SELECT Id, Visibility_Status__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'Inactivate CallItem'
			LIMIT 1
		];

		//If Active StartDate and Target Finishe Date are same then Visibility Status should be set to Inactive
		system.assertEquals(expectedVisibiliyStatus, ci.Visibility_Status__c);
        }
		Test.stopTest();
	}

	@isTest
	public static void testInactiveCallItem_V1() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
		String expectedVisibiliyStatus = 'Inactive';
		String currentVisibiliyStatus = 'Active';
		Call_Item__c ci = [
			SELECT Id, Visibility_Status__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'Inactivate CallItem1'
			LIMIT 1
		];
		//If Target Finishe Date is Today then Visibility Status should be set to Inactive
		system.assertEquals(expectedVisibiliyStatus, ci.Visibility_Status__c);
        }
		Test.stopTest();
	}

	@isTest
	public static void testVisbilityStatusManually() {
		Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
		Boolean expectedVisibilityStatusSetManually = true;
		String currentVisibiliyStatus = 'Active';
		Call_Item__c ci = [
			SELECT Id, Visibility_Status__c
			FROM Call_Item__c
			WHERE Active_Start_Date__c <= Today
			LIMIT 1
		];
		ci.Visibility_Status__c = 'Inactive';
		ci.Active_Start_Date__c = System.today() + 10;
		ci.Call_List_Name__c = 'StatusManually';
		update ci;
		ci = [
			SELECT Id, isVisibilityStatusSetManually__c
			FROM Call_Item__c
			WHERE Call_List_Name__c = 'StatusManually'
			LIMIT 1
		];

		//If visibility status is set manually then we have to enable the flag
		system.assertEquals(
			expectedVisibilityStatusSetManually,
			ci.isVisibilityStatusSetManually__c
		);
        }
		Test.stopTest();
	}
    
    @isTest
	public static void testCallItem_DAC_getAccountContacts() {
		Test.startTest();
		
       User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
        Integer expectedSize = 1;
		Call_Item__c ci = [
			SELECT Id, Call_List_Name__c, status__c, Contact__c, ownerid, FederationUserID__c, Account__c
			FROM Call_Item__c
			WHERE Call_List_Name__c =: 'Test call item'
			LIMIT 1
		];
        List<Contact> listofitems = new List<Contact>();
            listofitems = CallItem_DAC.getAccountContacts(ci.Id);
		//must return total contacts associated with account.
		system.assertEquals(expectedSize, listofitems.size());
        }
		Test.stopTest();
	}
    
    @isTest
	public static void testCallItem_DAC_getCallItemContacts() {
		Test.startTest();
		
       User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com'  Limit 1 ];
        System.runAs(adminUser){
        Integer expectedSize = 1;
		Call_Item__c ci = [
			SELECT Id, Call_List_Name__c, status__c, Contact__c, ownerid, FederationUserID__c, Account__c
			FROM Call_Item__c
			WHERE Call_List_Name__c =: 'Test call item'
			LIMIT 1
		];
        List<Call_Item__c> listofitems = new List<Call_Item__c>();
            listofitems = CallItem_DAC.getCallItemContacts(ci.Id);
		//must return total contacts associated with account.
		system.assertEquals(expectedSize, listofitems.size());
        }
		Test.stopTest();
	}
}