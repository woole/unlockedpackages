public inherited sharing class BrokerConfigCredentials {
    

    private Map<String,IConfigCredentials> authMap;
    @TestVisible
    private List<AuthCredentials__mdt> authList;
    private Map<String,Auth_Credentials_Override__c> authOverrides;
    
    

    public BrokerConfigCredentials () {

    }

    private void init(){
        authMap = new Map<String,IConfigCredentials>();
        authOverrides = new Map<String,Auth_Credentials_Override__c>();

        List<Auth_Credentials_Override__c> overrides = [select Name,Named_Credential__c,Scope__c,Endpoint_URL__c from Auth_Credentials_Override__c];
        for(Auth_Credentials_Override__c auth:overrides){
            authOverrides.put(auth.Name,auth);
        }
        if(authList == null){
            authList = [select Token_URL__c,Named_Credential__c,Client_ID__c, Request_TimeOut__c,Client_Secret__c, Grant_Type__c,scope__c,Cache_Time_To_Live__c,ProviderType__c,DeveloperName FROM AuthCredentials__mdt];    
        }
        
        for(AuthCredentials__mdt auth:authList){
            //do we have an override ?
            Auth_Credentials_Override__c authOverride = authOverrides.get(auth.DeveloperName);
            core_ConfigCredentials cred = new core_ConfigCredentials(auth,authOverride);
            authMap.put(auth.DeveloperName,cred);
        }
    }

    public IConfigCredentials getCredentials(String credentialName){
        if(authMap == null){
            init();
        }
        return authMap.get(credentialName);
    }   



    
    public class core_ConfigCredentials implements IConfigCredentials{

        public String url;
        public Integer cacheTTL;
        public String clientID;
        public String clientSecret;
        public String type;
        public String providerType;
        //this is in milliseconds internally but held as seconds in the CMDT
        public Integer requestTimeOut;
        public String scope;
        public String namedCredentialName;        

        public core_ConfigCredentials(){}

        public core_ConfigCredentials(AuthCredentials__mdt auth, Auth_Credentials_Override__c ovd){
            this.url = auth.Token_URL__c;
            this.namedCredentialName = auth.Named_Credential__c;
            this.scope = auth.Scope__c;
            this.clientID = auth.Client_ID__c;
            this.clientSecret = auth.Client_Secret__c;
            this.providerType = auth.ProviderType__c;
            this.type = auth.Grant_Type__c;
            //default to 60 seconds
            Integer toMillis = 60000;
            if(auth.Request_TimeOut__c != null){
                toMillis = auth.Request_TimeOut__c.intValue()*1000;
            }
            this.requestTimeOut = toMillis;
            
            if(auth.Cache_Time_To_Live__c != null){
                this.cacheTTL = auth.Cache_Time_To_Live__c.intValue();
            }
            //load overrides if there are some
            if(ovd != null){
                //pull in overrides
                if(String.isNotBlank(ovd.Endpoint_URL__c)){
                    this.url = ovd.Endpoint_URL__c;
                }
                if(String.isNotBlank(ovd.Named_Credential__c)){
                    this.namedCredentialName = ovd.Named_Credential__c;
                }
                if(String.isNotBlank(ovd.Scope__c)){
                    this.scope = ovd.Scope__c;
                }
            }
        }



        public String getURL(){
            return this.url;

        }
        public Integer getCacheTTL(){
            return this.cacheTTL;
        }
        public String getClientID(){
            return this.clientID;
        }
        public String getClientSecret(){
            return this.clientSecret;
        }
        public String getType(){
            return this.type;
        }

        public String getNamedCredentialName(){
            return this.namedCredentialName;
        }
        
        public String getProviderType(){
            return this.providerType;
        }
        public Integer getRequestTimeOut(){
            return this.requestTimeOut;
        }
        public String getScope(){
            return this.scope;
        }
        
    }

}
