({
    doInit: function (component, event, helper) {
        component.set("v.isLoading", true);
        var selectedId = component.get('v.recordId');
        const baseURL = window.location.hostname;
        var selectedPdfName;
        var documentType;
        var modalHeader;
        const actionAPI = component.find("quickActionAPI");
        actionAPI.getSelectedActions({ actionName: "lightning:isUrlAddressable" })
            .then(function (result) {
                if (result.success && result.actions[0].actionName) {
                    var listOfActionName = result.actions[0].actionName.split('.');
                    if (listOfActionName[1] === 'SCSPdf') {
                        selectedPdfName = 'SaleConfirmationSheet_VFP';
                        documentType = 'SCS';
                        modalHeader = 'SALE CONFIRMATION SHEET';
                    } 
                    component.set("v.modalHeader", modalHeader);
                    component.set("v.documentType", documentType);  
                    component.set("v.objectApiName", listOfActionName[0]);
                    component.set("v.pdfUniqueName", selectedPdfName);
                    let mainURL = 'https://' + baseURL + '/apex/' + selectedPdfName + '?id=' + selectedId;
                    component.set("v.PDF_URL", mainURL);
                    component.set("v.isLoading", false);
                   
                } else {
                    helper.helperShowToast('Error', 'Error while getting quick action', 'error');
                    helper.helperCloseModal(component, event, helper);
                }
            })
            .catch(function (error) {
                console.log('getActionInfo error------------------>', error);
            });
    },
    closeModal: function (component, event, helper) {
        helper.helperCloseModal(component, event, helper);
    },
    saveQuote: function (component, event, helper) {
        component.set("v.isLoading", true);
        let recId = component.get("v.recordId");
        let objName = component.get("v.objectApiName");
        let pdfName = component.get("v.pdfUniqueName");
        let documentType = component.get("v.documentType");
        let action = component.get("c.savePDF");
        action.setParams({ recordId: recId, vfPageName: pdfName, objName: objName, documentType:documentType});
        action.setCallback(this, function (response) {
            var state = response.getState();
            var responseWrapper = response.getReturnValue();
            if (state === "SUCCESS") {
                if (responseWrapper.isSuccess) {
                    helper.helperShowToast('Success', responseWrapper.body, 'success');
                } else {
                    helper.helperShowToast('Error', responseWrapper.body, 'error');
                }
            } else {
                helper.helperShowToast('error', responseWrapper.body, 'error');
            }
            helper.helperCloseModal(component, event, helper);
            component.set("v.isLoading", false);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
})