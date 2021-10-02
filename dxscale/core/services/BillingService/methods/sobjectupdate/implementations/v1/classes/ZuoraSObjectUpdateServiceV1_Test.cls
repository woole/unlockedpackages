/**
 * Although the usecase for this is Zuora SObjects, we can test with any valid SObject.
 * We can't gurantee the Zuora packages are installed in an env so use standard ones here
 */
@isTest
public class ZuoraSObjectUpdateServiceV1_Test {
    @TestSetup
    static void makeData(){
        List<SObject> updateList = new List<SObject>();
        Account account = new Account(Name='testAccount');
        updateList.add(account);
        Account account2 = new Account(Name='testAccount2');
        updateList.add(account2);
        insert updateList;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=account.id,
                        Email='my.email@test.com',MailingCity='Atlanta',MailingCountry='United States',
                        MailingStreet='123 Street');
        insert contact;     
             
    }

    @isTest
    static void testUpdateContactSObject(){
        String correlationid = 'test-123-456';
        Account account2 = [select Id from account where name = 'testAccount2'];
        Contact contact = [select id from contact where email = 'my.email@test.com' limit 1];
        ZuoraSObjectUpdateServiceV1 service = new ZuoraSObjectUpdateServiceV1();
        Map<String,String> params = new Map<String,String>{'Email' => 'new-funky-email@example.com'};
        billing_IUpdateRequest contactUpdate = new billing_UpdateRequest(contact.id,correlationid,'ZuoraSObjectUpdateServiceV1_Test','Contact',params);
        billing_IUpdateSObjectRequest updateRequest = new billing_UpdateSObjectRequest(correlationid,new List<billing_IUpdateRequest>{contactUpdate});
        IService_Output_Master output = service.dispatch(null,updateRequest);
        System.assert(output != null, 'Service output cannot be null');
        contact = [select id, email from contact where id = :contact.id];
        System.assertEquals('new-funky-email@example.com', contact.Email, 'Email does not match with setup data');
    }
}
