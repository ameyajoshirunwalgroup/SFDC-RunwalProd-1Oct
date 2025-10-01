({
	fetchApfHelper : function(component, event, helper) {
        console.log('fetchApfHelper');
        component.set('v.mycolumns', [
                {label: 'Connector Code', fieldName: 'Connector_Code__c', type: 'text'},
                {label: 'Project', fieldName: 'Project_Name__c', type: 'text'},
                {label: 'Company', fieldName: 'Company__c', type: 'text'},
            	{label: 'Bank', fieldName: 'RW_Bank_Name__c', type: 'text'},
            	{label: 'Connector Fee for Commercial', fieldName: 'Connector_Fee_for_Commercial__c', type: 'text'},
            	{label: 'Connector Fee for Residential', fieldName: 'Connector_Fee_for_Residential__c', type: 'text'},
            	{label: 'Connector Fee', fieldName: 'Connector_Fee__c', type: 'text'},
            	{label: 'Tower Type', fieldName: 'Tower_Type__c', type: 'text'}
            ]);
        var action = component.get("c.fetchApfRecords");
        var connCode = component.get("v.connectorCode");
        console.log('connCode: ', connCode);
        action.setParams({
            "code" : connCode
        });
        console.log('fetchApfHelper1');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.apfList", response.getReturnValue());
                component.set("v.showTable", true);
            }
        });
        $A.enqueueAction(action);
    }
})