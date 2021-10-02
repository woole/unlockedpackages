/**
* Test class for the SelectPriceBookLTCtrl Lightning controller for SelectPriceBook LEX component
*/
@IsTest
public with sharing class SelectPriceBookLTCtrl_Test {

	@TestSetup
	static void makeData(){
		User userNoPerms = SalesTestUtility.setUpUserWithPermissions('myExampleOrg','Standard User',new List<String>());
		PriceBookTestDataFactory.createPriceBook2('Custom PriceBook', 'GBP');
	}


	@IsTest
	public static void getPricebooks() {
		//standard user has no additional permissions and as such shows the Name on Pricebook is readable without additional perms
		User stdUser = [select Id from user where email like '%@myExampleOrg.com' limit 1];
		Test.startTest();
		System.runAs(stdUser){
			List<Pricebook2> priceBooks = SelectPriceBookLTCtrl.getPricebooks();
			System.assertEquals(1, priceBooks.size(),'A pricebook should have been returned');
		}
		Test.stopTest();
	}
    
    	@IsTest
	public static void getPricebooksCurrency() {
		//standard user has no additional permissions and as such shows the Name on Pricebook is readable without additional perms
		User stdUser = [select Id from user where email like '%@myExampleOrg.com' limit 1];
		Test.startTest();
		System.runAs(stdUser){
            String excludes = '%AME Pricebook%';
            List<Pricebook2> priceBooks = SelectPriceBookLTCtrl.getPricebooksCurrency('GBP',excludes);
			System.assertEquals(1, priceBooks.size(),'A pricebook should have been returned');
        }
		Test.stopTest();
	}
}