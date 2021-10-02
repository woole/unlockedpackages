@isTest
public class UserTestDataFactory {
    
    public static User createUser(String profileId){
        User u = new User(
            profileId=profileId,
            FirstName='Test',
            LastName = 'User',
            Email = 'test.user@a.com',
            Username = 'test.user@a.com' + System.currentTimeMillis(),
            CompanyName = 'Acme',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
       );
       insert u;
       return u;
    }

    
}
