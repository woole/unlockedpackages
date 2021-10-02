@isTest
public class DynamicQueryConfigLoader_Test {


    //As you cannot DML custommetadata - this test relies on ExampleQueryGridDisplay being in the org
    @isTest
    public static void testLoadConfigSuccess(){
        
        QueryGridDisplayConfiguration__mdt config = DynamicQueryConfigLoader.getInstance().getConfig('ExampleQueryGridDisplay');
        System.assert(config != null,'QueryGridDisplayConfiguration__mdt should not be null');
    }

    @isTest
    public static void testLoadConfigNoConfig(){
        
        try{
            QueryGridDisplayConfiguration__mdt config = DynamicQueryConfigLoader.getInstance().getConfig('DUMMY');
            //should not get here
            System.assertEquals(false, true,'Should have thrown an exception but did not');
        }catch(DynamicQueryConfigLoader.DynamicQueryConfigLoaderException e){
            System.assert(e != null,'Exception should not be null');
        }
        
        
    }     
}
