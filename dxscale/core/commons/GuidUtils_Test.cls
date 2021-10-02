@isTest
public class GuidUtils_Test {


    @isTest
    static void testGetGUID() {
        String guid = GuidUtils.getGUID();
        System.assert(guid != null);
        System.assert(guid.contains('-'));
        //check it's a valid guid format
        String expectedFormat = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';
        String[] formatSplits = expectedFormat.split('-');
        String[] guidSplits = guid.split('-');
        for(integer i; i < formatSplits.size(); i++){
            Integer expected =  formatSplits[i].length();
            Integer actual =  guidSplits[i].length();
            System.assertEquals(expected, actual, 'expected split : ' + i + 'of guid to be : ' + expected + ' but was : ' + actual);
        }
        
    } 
}
