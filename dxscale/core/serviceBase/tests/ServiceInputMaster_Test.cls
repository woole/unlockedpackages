@isTest
public  class ServiceInputMaster_Test {

    @isTest
    static void testCorrelationId(){
        ServiceInputMaster sim = new ServiceInputMaster();
        sim.setCorrelationId('test12');
        System.assertEquals('test12', sim.getCorrelationId());
    }
}
