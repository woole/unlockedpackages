@IsTest
public class ServiceUtils_Test {

	@IsTest
	private static void shouldGenerateIds() {
		Test.startTest();
		List<Id> ids = new List<Id>();
		for (Integer i = 0; i < 400; i++) {
			Id idValue = ServiceUtils.generateId();
			ids.add(idValue);
		}
		Test.stopTest();

		String userIdPrefix = UserInfo.getUserId().substring(0, ServiceUtils.ID_RESERVED_CHARACTERS);
		String incrementPrefix = ''.rightPad(ServiceUtils.ID_INCREMENTER_PREFIX_LENGTH, 'Z');

		for (Integer i = 0; i < ids.size(); i++) {
			String idString = String.valueOf(ids[i]);

			// Prefix should match user ID
			System.assert(
				idString.startsWith(userIdPrefix),
				'Expected first ' + ServiceUtils.ID_RESERVED_CHARACTERS + ' characters of ID to match user ID: ' + idString
			);

			// Incrementing value should start with prefix
			System.assert(
				idString.substring(ServiceUtils.ID_RESERVED_CHARACTERS).startsWith(incrementPrefix),
				'Expected ID to contain \'' + incrementPrefix + '\': ' + idString
			);

		}
	}

	@IsTest
	private static void stripMyDomain() {
		String hostURL = 'https://saas-velocity-554-dev-ed.cs81.my.salesforce.com';
		String sReturn = ServiceUtils.stripMyDomain(hostURL);
		System.assertEquals('saas-velocity-554-dev-ed', sReturn, 'stripMyDomain should return just domain name');
	}

	@IsTest
	private static void getMyDomain() {
		String sReturn = ServiceUtils.getMyDomain();
		System.assert(!sReturn.contains('.'),'getMyDomain should strip all full stops');
		System.assert(!sReturn.contains('/'),'getMyDomain should strip all slashes');
	}

	@IsTest
    public static void getHashBase16() {
		String hash1 = ServiceUtils.getHashBase16('1');
		String hash2 = ServiceUtils.getHashBase16('2');
		System.assert(hash1 != hash2,'getHashBase16 return different values for different input');		
    } 

	@IsTest
    public static void stripNonAlphas() {
		String stripped = ServiceUtils.stripNonAlphas('1 _&a');
		System.assertEquals('1a', stripped, 'stripNonAlphas should return only the alphanumeric characters from its input');
    } 

	

}