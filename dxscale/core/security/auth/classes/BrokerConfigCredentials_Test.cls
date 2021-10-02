@isTest
public class BrokerConfigCredentials_Test {

    @TestSetup
    static void makeData(){
        Auth_Credentials_Override__c authOverride = new Auth_Credentials_Override__c(Name='Test2',Named_Credential__c='OverrideName',
                            Scope__c='myOverriddenScope',Endpoint_URL__c='http://myoverride.com');
        insert authOverride;
    }
    
    @isTest
    static void testNoOverride(){
        AuthCredentials__mdt cred1 = new AuthCredentials__mdt(DeveloperName='Test1',
                    Token_URL__c='http://test.local.place.com',Named_Credential__c='RealName',Scope__c='myRealScope',Request_TimeOut__c=88);
        List<AuthCredentials__mdt> testAuthList = new List<AuthCredentials__mdt>();
        testAuthList.add(cred1);
        BrokerConfigCredentials config = new BrokerConfigCredentials();
        config.authList = testAuthList;
        IConfigCredentials credentials = config.getCredentials('Test1');
        System.assert(credentials != null);
        System.assertEquals(credentials.getURL(),'http://test.local.place.com');
        System.assertEquals(credentials.getNamedCredentialName(),'RealName');
        System.assertEquals(credentials.getScope(),'myRealScope');
        System.assertEquals(credentials.getRequestTimeOut(),88000);
    }

    @isTest
    static void testNoOverrideDefaultTimeOut(){
        AuthCredentials__mdt cred1 = new AuthCredentials__mdt(DeveloperName='Test1',
                    Token_URL__c='http://test.local.place.com',Named_Credential__c='RealName',Scope__c='myRealScope');
        List<AuthCredentials__mdt> testAuthList = new List<AuthCredentials__mdt>();
        testAuthList.add(cred1);
        BrokerConfigCredentials config = new BrokerConfigCredentials();
        config.authList = testAuthList;
        IConfigCredentials credentials = config.getCredentials('Test1');
        System.assert(credentials != null);
        System.assertEquals(credentials.getURL(),'http://test.local.place.com');
        System.assertEquals(credentials.getNamedCredentialName(),'RealName');
        System.assertEquals(credentials.getScope(),'myRealScope');
        System.assertEquals(credentials.getRequestTimeOut(),60000);
    }

    @isTest
    static void testWithOverride(){
        AuthCredentials__mdt cred1 = new AuthCredentials__mdt(DeveloperName='Test2',
                    Token_URL__c='http://test.local.place.com',Named_Credential__c='RealName',Scope__c='myRealScope', Request_TimeOut__c=100,Cache_Time_To_Live__c=3400);
        List<AuthCredentials__mdt> testAuthList = new List<AuthCredentials__mdt>();
        testAuthList.add(cred1);
        BrokerConfigCredentials config = new BrokerConfigCredentials();
        config.authList = testAuthList;
        IConfigCredentials credentials = config.getCredentials('Test2');
        System.assert(credentials != null);
        System.assertEquals(credentials.getURL(),'http://myoverride.com');
        System.assertEquals(credentials.getNamedCredentialName(),'OverrideName');
        System.assertEquals(credentials.getScope(),'myOverriddenScope');
    }    
}
