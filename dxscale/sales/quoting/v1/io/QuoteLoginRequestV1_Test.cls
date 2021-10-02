@isTest
public class QuoteLoginRequestV1_Test {

    
    @isTest
    static void testCreateRequest (){
       String exampleJSON = '{\r\n      \"client\": {\r\n        \"id\": \"salesforce-global\",\r\n        \"name\": \"Salesforce Global\"\r\n      },\r\n      \"user\": {\r\n        \"id\": \"user-123\",\r\n        \"federatedId\": \"test.user123@sage.com\",\r\n        \"name\": \"test user\",\r\n        \"email\": \"test.user123@sage.com\",\r\n        \"groups\": [\r\n          \"public-one\",\"public-two\"\r\n        ]\r\n      },\r\n      \"opportunity\": {\r\n        \"id\": \"opp-1123456\",\r\n        \"name\": \"Test Opp1\",\r\n        \"billToContact\": {\r\n          \"id\": \"bill-1234\",\r\n          \"firstName\": \"Bill\",\r\n          \"lastName\": \"Contact\",\r\n          \"displayName\": \"Bill Contact\",\r\n          \"email\": \"bill.contact@example.com\",\r\n          \"account\": {\r\n            \"id\": \"acc-1234\",\r\n            \"name\": \"Test Account1\",\r\n            \"countryCode\": \"GB\",\r\n            \"currencyCode\": \"GBP\",\r\n            \"salesOffice\": \"Dublin\",\r\n            \"locale\": \"en_GB\",\r\n            \"billingAccountId\": \"bill-acc-123\",\r\n            \"address\": {\r\n              \"line1\": \"123\",\r\n              \"line2\": \"streat road\",\r\n              \"state\": \"newcastle\",\r\n              \"postalCode\": \"NE11 8II\",\r\n              \"city\": \"Newcastle\",\r\n              \"country\": \"UK\"\r\n            },\r\n            \"vatRegistrationNumber\": \"vat-123\"\r\n          }\r\n        },\r\n        \"sellToContact\": {\r\n          \"id\": \"sell-123\",\r\n          \"firstName\": \"Sell\",\r\n          \"lastName\": \"Contact\",\r\n          \"displayName\": \"Sell Contact\",\r\n          \"email\": \"sell.contact@exqmple.com\",\r\n          \"account\": {\r\n            \"id\": \"acc-234\",\r\n            \"name\": \"Test Acc 2\",\r\n            \"countryCode\": \"IE\",\r\n            \"currencyCode\": \"EUR\",\r\n            \"salesOffice\": \"Dublin\",\r\n            \"locale\": \"en_IE\",\r\n            \"billingAccountId\": \"billing-234\",\r\n            \"address\": {\r\n              \"line1\": \"1 place\",\r\n              \"line2\": \"1 street\",\r\n              \"state\": \"Dublin\",\r\n              \"postalCode\": \"D1 9II\",\r\n              \"city\": \"Dublin\",\r\n              \"country\": \"IE\"\r\n            },\r\n            \"vatRegistrationNumber\": \"vat-234\"\r\n          }\r\n        }\r\n      },\r\n      \"lookups\": [\r\n        {\r\n          \"lookupType\": \"lookup1\",\r\n          \"id\": \"look-123\",\r\n          \"displayText\": \"test\",\r\n          \"parentLookupType\": \"test-parent\",\r\n          \"parentLookupId\": \"parent-1\"\r\n        }\r\n      ]\r\n  }';
       QuoteLoginRequestV1 request = (QuoteLoginRequestV1)JSON.deserialize(exampleJSON, QuoteLoginRequestV1.class);
       System.assert(request!=null);
       System.assertEquals(request.user.id,'user-123');
       System.assertEquals(request.user.federatedId,'test.user123@sage.com');
       System.assertEquals(request.user.groups.size(),2);
       System.assert(request.opportunity!=null);
       System.assertEquals(request.opportunity.name,'Test Opp1');
       System.assert(request.opportunity.billToContact!=null);
       System.assertEquals('vat-123', request.opportunity.billToContact.account.vatRegistrationNumber);
       System.assertEquals('vat-234', request.opportunity.sellToContact.account.vatRegistrationNumber);
    }    
    
}
