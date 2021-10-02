@isTest
public class TokenAuth_IO_Test {
    @isTest
    static void testTokenAuthRequest() {
        ITokenAuthRequest request = new TokenAuthRequest('correlation-id-guid','TestAuthName');
        System.assertEquals(request.getCorrelationId(), 'correlation-id-guid');
        request.setCorrelationId('new-id');
        System.assertEquals(request.getCorrelationId(), 'new-id');
    }

    @isTest
    static void testTokenAuthResponse(){

        ITokenAuthResponse response = new TokenAuthResponse('tokenId');
        response.setCorrelationId('correlation-id');
        System.assertEquals(response.getCorrelationId(), 'correlation-id');
        System.assertEquals(response.getAccessToken(), 'tokenId');
    }
}
