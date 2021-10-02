public inherited sharing class OpportunitySalesHandler extends TriggerService {
    private MapAccountCountryToOppCountry mapCountryHelper;
    private LockOpportunityTriggerHelper lockOpportunityHelper;

    public OpportunitySalesHandler() {
        this.mapCountryHelper = new MapAccountCountryToOppCountry();
        this.lockOpportunityHelper = new LockOpportunityTriggerHelper();
    }

    public void setOverride(MapAccountCountryToOppCountry mapCountryHelper) {
        this.mapCountryHelper = mapCountryHelper;
    }

    public void setOverride(LockOpportunityTriggerHelper lockOpportunityHelper) {
        this.lockOpportunityHelper = lockOpportunityHelper;
    }

    public override void onBeforeInsert() {
		this.mapCountryHelper.mapAccCtryToOppCtry(
			(List<Opportunity>) this.listNewSObject
		);
		this.mapCountryHelper.updateRegionOnOpportunity(
			(Map<Id, Opportunity>) this.mapNewSObject,
			(List<Opportunity>) this.listNewSObject
		);
		//this.mapCountryHelper.copyContactDetails((List<Opportunity>) this.listNewSObject);
        this.lockOpportunityHelper.populateLocalCRMFields((List<Opportunity>) this.listNewSObject);
        
        // Added as part of CCORE-1383 by KIRAN MOOTA
        //opportunityCloseDateTriggerHandler oppCloseDate = new opportunityCloseDateTriggerHandler();
        // Added as part of CCORE-1383 by KIRAN MOOTA
        OpportunityTriggerHandler.OpportunityCloseDate((List<Opportunity>) this.listNewSObject);
    	OpportunityTriggerHandler.populateCreatedByRole((List<Opportunity>) this.listNewSObject);
        OpportunityTriggerHandler.populateOpportunityFieldsOnLeadConversion((List<Opportunity>) this.listNewSObject);
    }

    public override void onBeforeUpdate() {
        this.mapCountryHelper.mapAccCtryToOppCtry((List<Opportunity>) this.listNewSObject);
        this.mapCountryHelper.updateRegionOnOpportunity((Map<Id, Opportunity>) this.mapNewSObject, (List<Opportunity>) this.listNewSObject);
        //this.mapCountryHelper.oppsWithQuotes((Map<Id, Opportunity>) this.mapOldSObject, (List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapNewSObject);
        OpportunityTriggerHandler.OpportunityPushCounter((Map<Id, Opportunity>) this.mapOldSObject, (List<Opportunity>) this.listNewSObject);
        this.mapCountryHelper.updateTCV((List<Opportunity>) this.listNewSObject);
		// this.mapCountryHelper.copyContactDetails((List<Opportunity>) this.listNewSObject);
        this.lockOpportunityHelper.checkOppoIntegrationStatus((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);

        //CCORE-1202 - invoking method to change the owner of given opportunities in bulk via list views
        OpportunityTriggerHandler.massUpdateOppOwner((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);
        
        //CCORE-1416  ::  Move Process Builder (Opp_NS_Last_Update) to Opp Trigger
        OpportunityTriggerHandler.updatesNextSteps((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);
        
        OpportunityTriggerHandler.OpportunityCloseDateCloseWon_lost((Map<Id, Opportunity>) this.mapOldSObject, (List<Opportunity>) this.listNewSObject);  
    }
        
    public override void onAfterUpdate() {
        
        OpportunityTriggerHandler.rejectedOppNotifications((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);

        // Added as part of EAD-1311 to populate product names on the opportunty
        // Removed under EAD-2102. This update is now made from the OpportunityLineItemTriggerHelper class
        // OpportunityTriggerHandler.populateProductNamesOnOpportunity((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);
    }
}