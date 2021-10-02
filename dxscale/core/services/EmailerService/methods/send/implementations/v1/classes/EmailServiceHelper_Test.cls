@IsTest 
public class EmailServiceHelper_Test {
    
    @future
    public static void insertEmailTemplate(){
        EmailTemplate template = new  EmailTemplate (DeveloperName='TestEmailTemplate',name='TestEmailTemplate', subject='Test Email',HtmlValue=null,Body='Testing',FolderId=UserInfo.getUserId(),TemplateType = 'text');
        insert template;
    }


    @TestSetup
    static void makeData(){
        insertEmailTemplate();
        Contact contact = new Contact(FirstName='Fred',LastName='Tester',Email='test@example.com');
        insert contact;
        Account acc1 = new Account(Name='Test1');
        insert acc1;        
    }

  @isTest
  static void testGetEmailTemplate(){
    EmailTemplate et1 = EmailServiceHelper.getEmailTemplate('TestEmailTemplate');
    System.assert(et1 != null);
    System.assertEquals(et1.Subject,'Test Email');
  } 

  @isTest
  static void testGetEmailTemplate_Missing(){
    try {
        EmailServiceHelper.getEmailTemplate('Dummy');    
        System.assert(false,'should have thrown exception');
    } catch (Exception e) {
        System.assert(e instanceof EmailServiceException);
    }
    
  }
  
  @isTest
  static void testGetEmailMessage(){
    Contact c = [select Id from contact where Email='test@example.com'];
    Account acc = [select Id from account where name = 'Test1'];
    IEmailRequestV1 request = new EmailRequestV1('TestEmailTemplate',c.id, acc.id,null,false,'Test Email');
    Messaging.SingleEmailMessage emailMsg = EmailServiceHelper.getEmailMessage(request);
    System.assert(emailMsg != null);
  }

  
}