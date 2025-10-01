({
	doInit : function(component, event, helper) {
		helper.getDocuments(component);
		helper.getPortalDocuments(component);
	},
    
    viewDoc : function(component, event, helper) {
		helper.ViewDocuments(component);
	},

	
    
    viewDemandLetter : function(component, event, helper) {
		//helper.ViewDemandLetterDocuments(component, event);
        component.set("{!v.pdfContainer}", ""); 
		var action = component.get("c.ViewDemandLetterDocs");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit });
         action.setCallback(this, function(response) {
            var state = response.getState();
			if (state === "SUCCESS") 
			{
				if(response.getReturnValue() != null)
				{
					var lstRes = response.getReturnValue();
					var strRes = '';
					for(var EachRes in lstRes)
					{
						strRes=strRes.concat(lstRes[EachRes]);
					}
					//alert(strRes);
					component.set("v.lstPDF", lstRes);
					component.set("v.imageIndex", 0);
					helper.goToPDF(component, event, lstRes[0]);
				}
				else
					alert("Demand letter is not generated.");
				/*var evt = $A.get("e.force:navigateToComponent");
					evt.setParams({
						componentDef : "c:PDFViewer",
						componentAttributes: {
							pdfData : response.getReturnValue();
						}
					});
					evt.fire();*/
			}
        });
         $A.enqueueAction(action);
	},

	viewMoneyReceipt : function(component, event, helper) {
		//helper.ViewMoneyReceiptPDFDocuments(component);
		component.set("{!v.pdfContainer}", ""); 
		var action = component.get("c.ViewGenMoneyReceipt");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				if(response.getReturnValue() != null)
				{
					var lstRes = response.getReturnValue();
					var strRes = '';
					for(var EachRes in lstRes)
					{
						strRes=strRes.concat(lstRes[EachRes]);
					}
					//alert(strRes);
					component.set("v.lstPDF", lstRes);
					component.set("v.imageIndex", 0);
					helper.goToPDF(component, event, lstRes[0]);
				}
				else
					alert("Money Receipt is not generated.");
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},

	viewAllotPDF : function(component, event, helper) {
		component.set("{!v.pdfContainer}", ""); 
		//helper.ViewAllotPDFDocuments(component);
		var action = component.get("c.ViewAllotmentLetterDocs");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				if(response.getReturnValue() != null)
				{
					var lstRes = response.getReturnValue();
					var strRes = '';
					for(var EachRes in lstRes)
					{
						strRes=strRes.concat(lstRes[EachRes]);
					}
					//alert(strRes);
					component.set("v.lstPDF", lstRes);
					component.set("v.imageIndex", 0);
					helper.goToPDF(component, event, lstRes[0]);
				}
				else
					alert("Allotment is not generated.");
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},

	viewReminderPDF : function(component, event, helper) {
		component.set("{!v.pdfContainer}", ""); 
		//helper.ViewReminderLetterPDFDocuments(component);
		var action = component.get("c.ViewReminderLetterDocs");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null)
				{
					var lstRes = response.getReturnValue();
					var strRes = '';
					for(var EachRes in lstRes)
					{
						strRes=strRes.concat(lstRes[EachRes]);
					}
					//alert(strRes);
					component.set("v.lstPDF", lstRes);
					component.set("v.imageIndex", 0);
					helper.goToPDF(component, event, lstRes[0]);
				}
				else
					alert("Reminder is not generated.");
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},

	ApplicantLedger : function(component, event, helper) {
		component.set("{!v.pdfContainer}", ""); 
		//helper.ApplicantLedgerDocuments(component);
		//helper.getValidDate(component);
		
		var action = component.get("c.ApplicantLedgerGenerate");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				if(response.getReturnValue()[0].indexOf('Alert : ') >= 0)
				{
					alert(response.getReturnValue()[0]);
				}
				else
				{
					var lstRes = response.getReturnValue();
					
					component.set("v.lstPDF", lstRes);
					component.set("v.imageIndex", 0);
					helper.goToPDF(component, event, lstRes[0]);
				}
            }
        });
         $A.enqueueAction(action);
	},
    
    UploadAtt : function(component, event, helper) {
        helper.getPortalDocuments(component);
        var attachment1 = component.find("tdsfile").getElement();
		if(attachment1.value != "")
		{
			helper.UploadAtts1(component);
		}
		var attachment2 = component.find("formfile").getElement();
		if(attachment2.value != "")
		{
            helper.UploadAtts2(component);
		}
		var attachment3 = component.find("Regisfile").getElement();
		if(attachment3.value != "")
		{
            helper.UploadAtts3(component);
		}
		var attachment4 = component.find("Otherfile").getElement();
		if(attachment4.value != "")
		{
            helper.UploadAtts4(component);
		}

		if(attachment1.value == "" && attachment2.value == "" && attachment3.value == "" && attachment4.value == "")
		{
			alert("Please add atleast one attachment to proceed.");
		}
		else
		{
			
		}
	},
    
    hidePopUp : function(component, event, helper)
    {
        var PopUp = component.find("PoPShow");
        $A.util.addClass(PopUp, 'hidePopup');
    },

	hidePopUpConStage : function(component, event, helper)
    {
        var PopUp = component.find("PoPShowConstage");
        $A.util.addClass(PopUp, 'hidePopup');
    },

	viewConstructionStage : function(component, event, helper)
	{
		var action = component.get("c.viewLatestConstructionStage");
		var selectedUnit = component.get("v.SelectedUnit");
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var varRespons = response.getReturnValue();
				if(varRespons.indexOf("Error : ") >= 0)
				{
					alert(varRespons);
				}
				else
				{
					component.set("v.CurrentConsStage", response.getReturnValue());
					var popUp = component.find("PoPShowConstage");
                    $A.util.removeClass(popUp, 'hidePopup');
				}
                //helper.goToPDF(component, event, response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
	},
	
	changeImgBack : function(component, event, helper) {
		helper.changeImgBack(component, event);
	},

	changeImgForwrd : function(component, event, helper) {
		helper.changeImgForwrd(component, event);
	}
})