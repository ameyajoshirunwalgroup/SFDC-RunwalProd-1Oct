({
	doInit : function(component, event, helper) {
        
        helper.getExistingCase(component);
		helper.getProjectUnit(component);
		helper.getCaseType(component);
    },

	insertCase : function(component, event, helper) {
        var Sub = component.get("v.Subj");
   		var Desc = component.get("v.Descr");
		var Unit = component.get("v.SelectedUnit");
		var CaseTyp = component.get("v.SelectedCaseType");
        var action= component.get("c.insertNewCase");
		action.setParams({ "Sub" : Sub,
                           "Descrp" : Desc,
						   "SelectedUnit" : Unit,
						   "CaseType" : CaseTyp});
		action.setCallback(this, function(response) {
           
          // alert('state=='+response.getState());
            if(response.getState() == 'SUCCESS') {
				if(response.getReturnValue() == 'Case has been successfully created.')
				{
					alert(response.getReturnValue());
					component.set("v.Subj", "");
					component.set("v.Descr", "");
					helper.getExistingCase(component);           
				}
				else
					alert(response.getReturnValue());
      	     }
       	    else {
			alert("problem in inserted Lead from server");
       	     }
       	 });
        $A.enqueueAction(action);
    },
})