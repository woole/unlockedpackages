// Added under EAD-2102 to populate product names on the opportunity correctly
public inherited sharing class OpportunityLineItemTriggerHandler extends TriggerService {
    
    static String CLASSNAME = 'OpportunityLineItemTriggerHandler';
    
    public OpportunityLineItemTriggerHandler() {}

    public override void onAfterInsert() {
        LogControl.push('onAfterInsert', CLASSNAME);

        OpportunityControlSwitch__c triggerSwitch = OpportunityControlSwitch__c.getInstance();
        
        if (Test.isRunningTest() || triggerSwitch.RunTrigger__c ) {
        	OpportunityLineItemTriggerHelper.populateProductNamesOnOpportunity((List<OpportunityLineItem>) this.listNewSObject);
        }
    }
    
    public override void onAfterUpdate() {
        LogControl.push('onAfterUpdate', CLASSNAME);

        OpportunityControlSwitch__c triggerSwitch = OpportunityControlSwitch__c.getInstance();
        
        if (Test.isRunningTest() || triggerSwitch.RunTrigger__c ) {
        	OpportunityLineItemTriggerHelper.populateProductNamesOnOpportunity((List<OpportunityLineItem>) this.listNewSObject);
        }
    }

    public override void onAfterDelete() {
        LogControl.push('onAfterDelete', CLASSNAME);

        OpportunityControlSwitch__c triggerSwitch = OpportunityControlSwitch__c.getInstance();
        
        if (Test.isRunningTest() || triggerSwitch.RunTrigger__c ) {
        	OpportunityLineItemTriggerHelper.populateProductNamesOnOpportunity((List<OpportunityLineItem>) this.mapOldSObject.values());
        }
    }
}