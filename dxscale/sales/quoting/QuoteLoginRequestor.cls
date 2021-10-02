public with sharing class QuoteLoginRequestor {
    
    static String CLASS_NAME = 'QuoteLoginRequestor';
    
    @TestVisible
    private static GenericServiceInvoker invoker;

    public static QuoteLogin login(QuoteLoginRequestV1 request){
        LogControl.push('login',CLASS_NAME);
        //to keep the hard dependencies we need to serialize
        QuoteLoginContext loginRequest = new QuoteLoginContext();
        loginRequest.context = request;
        loginRequest.setCorrelationId(GuidUtils.getGUID());
        String requestJSON = JSON.serialize(loginRequest);
        System.debug(LoggingLevel.DEBUG,'Quote Request : ' + requestJSON);
        QuoteLogin loginResponse;
        try{
            //call the service
            GenericServiceInvoker invoker = getInvoker();
            IService_Output_Master response = invoker.call(requestJSON);
            System.debug(LoggingLevel.DEBUG,'Response : ' + response.getState());
            //check the state
            if(response != null && response.getState() != 'SUCCESS'){
                //we will return null but log it
                QuoteLoginException quoteException = new QuoteLoginException();
                quoteException.setMessage('QuoteAPI Login call failed (correlationId:'+response.getCorrelationId()+ ') errorMessage:' + response.getErrorMessage());
                LogControl.debugException(quoteException);
                throw quoteException;
            }else{
                //success
                String quoteLogin = JSON.serialize(response);
                loginResponse = (QuoteLogin)JSON.deserialize(quoteLogin, QuoteLogin.class);
            }
            return loginResponse;
        }catch(Exception e){ 
            //unexpected Error
            LogControl.debugException(e);
            throw new QuoteLoginException('Failed to Login to the QuoteAPI, contact an Administrator');
        }finally{
            LogControl.pop();
        }
    }

    private static GenericServiceInvoker getInvoker(){
        if(invoker == null){
            invoker = new GenericServiceInvoker('QuoteProxyCallout');
        }
        return invoker;
    }    

    public class QuoteLoginException extends Exception {
        
    }
    
}
