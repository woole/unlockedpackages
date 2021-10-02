@isTest
public class CustomerInsightViewControllerTest {
    
    @isTest public static void CustomerInsightViewControllerTest1(){
        boolean isEditable = CustomerInsightViewController.getInsightFieldAccess();
        System.assertEquals(false, isEditable);
    }
}