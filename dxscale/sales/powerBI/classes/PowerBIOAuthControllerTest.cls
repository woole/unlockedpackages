@isTest
public class PowerBIOAuthControllerTest {
    public static PageReference pageRef = Page.PowerBIReport;
	public static OAuthApp_pbi__c app;
	public static PowerBIOAuthController controller = new PowerBIOAuthController();
    public static Account acc;
    public static Opportunity opp;
	
	@testSetup public static void setUp()
	{	
		app = new OAuthApp_pbi__c();
		app.Name = 'PowerBI2';
		app.Token_Expires_On__c = '0';
		app.Client_Id__c = 'clientId';
		app.Client_Secret__c = 'clientSecret';
		app.Authorization_URL__c = 'https://login.windows.net/common/oauth2/authorize';
		app.Access_Token_URL__c = 'https://login.microsoftonline.com/common/oauth2/token';
		app.Resource_URI__c = 'https://analysis.windows.net/powerbi/api';
		insert app;
		
		controller.application_name = 'PowerBI2';
        
	}
	
	public static testMethod void createController()
	{		
		System.assertNotEquals(controller, null);		
	}   
	
	public static testMethod void checkAccessTokenNotNull()
	{
		System.assertNotEquals(controller.PBIAccess_token, null);	
	}
	
	public static testMethod void checkRefreshTokenNotNull()
	{
		System.assertNotEquals(controller.PBIRefresh_token, null);	
	}
	
	public static testMethod void checkExpiresOnNotNull()
	{
		System.assertNotEquals(controller.PBIExpires_on, null);	
	}
	
	public static testMethod void checkHasTokenReturnsFalse()
	{
		System.assertEquals(controller.getHasToken(), false);	
	}
	
	public static testMethod void checkHasTokenReturnsTrue()
	{
		controller.PBIAccess_token =  'testToken';
		System.assertEquals(controller.getHasToken(), false);	
	}
	
	public static testMethod void getAuthURLReturnSuccess()
	{
		Test.setCurrentPage(pageRef);
        controller.application_name = 'PowerBI2';
		String authUrl = controller.getAuthUrl();
		
		System.assertEquals(authUrl.contains('https://login.windows.net/common/oauth2/authorize?'), true);
	}
	
	public static testMethod void redirectOnCallbackCreatesCookies()
	{	
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		PowerBIOAuthControllerTest.getAuthURLReturnSuccess();
		pageRef = new PageReference('https://c.eu11.visual.force.com/apex/PowerBIReport?code=testCode');
		Test.setCurrentPage(pageRef);
		controller.isCallback = true;

		PageReference ref = controller.redirectOnCallback(pageRef);
		
		String accessCookie = controller.PBIAccess_token;
		String refreshCookie =  controller.PBIRefresh_token;
		
		System.assertEquals('accessCookieToken',accessCookie);
		System.assertEquals('refreshCookieToken',refreshCookie);
		Test.stopTest();
	}

    public static testMethod void refreshToken()
	{	
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		PowerBIOAuthControllerTest.getAuthURLReturnSuccess();
		pageRef = new PageReference('https://c.eu11.visual.force.com/apex/PowerBIReport?code=testCode');
		Test.setCurrentPage(pageRef);
		controller.isCallback = true;

		controller.refreshAccessToken(pageRef);
		
		String accessCookie = controller.PBIAccess_token;
		String refreshCookie =  controller.PBIRefresh_token;
		
		System.assertEquals('accessCookieToken',accessCookie);
		System.assertEquals('refreshCookieToken',refreshCookie);
		Test.stopTest();
	}
    public static testMethod void accRecordIDTest()
	{	
        acc = new Account(Name='PowerBI account', Sales_Office__c='Dublin CBC', Type='Customer', Industry='Automotive', 
                          BillingCountry='United Kingdom', BillingCity='London', BillingStreet='302 Salisbury Street');
        insert acc;
		Test.startTest();
        pageRef = new PageReference('https://c.eu11.visual.force.com/apex/PowerBIReport');
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.id);
        controller.retrieveAccId();
        String reportId = controller.reportId;
        Test.stopTest();
    }
    public static testMethod void oppRecordIDTest()
	{	
        acc = new Account(Name='PowerBI account', Sales_Office__c='Dublin CBC', Type='Customer', Industry='Automotive', 
                          BillingCountry='United Kingdom', BillingCity='London', BillingStreet='302 Salisbury Street');
        insert acc;
        opp = new Opportunity(AccountId=acc.Id, name='PowerBI Opp 1', StageName=Label.Opportunity_Sales_Stages_Stage1,
                              CloseDate=Date.today(), Lead_Source__c='Marketing');
        
        insert opp;
		Test.startTest();
        pageRef = new PageReference('https://c.eu11.visual.force.com/apex/PowerBIReport');
		Test.setCurrentPage(pageRef);
        try{
            if(opp.Id != null){
                ApexPages.currentPage().getParameters().put('id', opp.id);
                controller.retrieveAccId();
            }
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}