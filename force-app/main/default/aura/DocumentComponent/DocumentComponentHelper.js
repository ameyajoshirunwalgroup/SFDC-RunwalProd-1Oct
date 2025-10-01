({
	getDocuments : function(component) {
		var action = component.get("c.fetchDocuments");
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstOfUnit", response.getReturnValue());
				component.set("v.SelectedUnit", response.getReturnValue()[0]);
            }
        });
         $A.enqueueAction(action);
	},

	getPortalDocuments : function(component) {
		var action = component.get("c.FetchAllPortalDocuments");
         action.setCallback(this, function(response) {
            var state = response.getState();
			//alert(response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.lstAtts", response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
	},

	getValidDate : function(component) {
		var action = component.get("c.fetchLedgerDate");
		var selectedUnit = component.get("v.SelectedUnit");
		alert(selectedUnit);
		action.setParams({ "strSelectedUnit" : selectedUnit });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ValidTo", response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
	},

	goToPDF : function(component, event, PDFData){
		$A.createComponent(
            "c:PDFViewer",
             {
                 "pdfData": PDFData
             },
             function(PDFViewer, status, errorMessage){
                 if (status === "SUCCESS") {
                    var pdfContainer = component.get("v.pdfContainer");
                     pdfContainer.push(PDFViewer);
                     component.set("v.pdfContainer", pdfContainer);
                     var popUp = component.find("PoPShow");
                     $A.util.removeClass(popUp, 'hidePopup');
                 }
                 else if (status === "INCOMPLETE") {
                     console.log("No response from server or client is offline.");
                 }
                 else if (status === "ERROR") {
                     console.log("Error: " + errorMessage);
                 }
          }
		);	
	},

    ViewDocuments : function(component) {
		var action = component.get("c.GoToDocuments");
         action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
			alert("Payment Plan is not generated.");
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                
            }
        });
         $A.enqueueAction(action);
	},
    
    ViewDemandLetterDocuments : function(component, event) {
		var action = component.get("c.ViewDemandLetterDocs");
		var selectedUnit = component.get("v.SelectedUnit");
		alert(selectedUnit);
		action.setParams({ "strSelectedUnit" : selectedUnit });
         action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {

				alert(response.getReturnValue());
				//component.set("v.pdfData", response.getReturnValue());
				/*var evt = $A.get("e.force:navigateToComponent");
				evt.setParams({
					componentDef : "c:PDFViewer",
					componentAttributes: {
						pdfData : response.getReturnValue();
					}
				});
				evt.fire();*/

				//this.loadpdf(component, event, response.getReturnValue());

                //alert(response.getReturnValue());
                //window.open(response.getReturnValue(),"_self");
				/*var base64PDF = response.getReturnValue();
				var objbuilder = '';
				objbuilder += ('<object width="100%" height="100%"      data="data:application/pdf;base64,');
				objbuilder += (base64PDF);
				objbuilder += ('" type="application/pdf" class="internal">');
				objbuilder += ('<embed src="data:application/pdf;base64,');
				objbuilder += (base64PDF);
				objbuilder += ('" type="application/pdf" />');
				objbuilder += ('</object>');
    
				var win = window.open("","_blank","titlebar=yes");
				//win.document.title = "My Title";
				win.document.write('<html><body>');
				win.document.write(objbuilder);
				win.document.write('</body></html>');
				layer = jQuery(win.document);*/

            }
        });
         $A.enqueueAction(action);
	},

	loadpdf : function(component, event, pdfData) {
		try{
		   //var pdfData = component.get('v.pdfData');
		   var pdfjsframe = component.find('pdfFrame')
		   if(typeof pdfData != 'undefined'){
			pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*'); 
			}
		  }
		  catch(e){
		   alert('Error: ' + e.message);
		  }
	},

	ViewMoneyReceiptPDFDocuments : function(component) {
		var action = component.get("c.ViewMoneyReceipt");
		var selectedUnit = component.get("v.SelectedUnit");
		alert(selectedUnit);
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {
                alert(response.getReturnValue());
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},

	ViewAllotPDFDocuments : function(component) {
		var action = component.get("c.ViewAllotmentLetterDocs");
		var selectedUnit = component.get("v.SelectedUnit");
		alert(selectedUnit);
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {
                alert(response.getReturnValue());
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},

	ViewReminderLetterPDFDocuments : function(component) {
		
	},

	ApplicantLedgerDocuments : function(component) {
		var action = component.get("c.ApplicantLedgerGenerate");
		var selectedUnit = component.get("v.SelectedUnit");
		alert(selectedUnit);
		action.setParams({ "strSelectedUnit" : selectedUnit});
         action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {
                alert(response.getReturnValue());
                //window.open(response.getReturnValue(),"_self");
            }
        });
         $A.enqueueAction(action);
	},
    
    MAX_FILE_SIZE: 750 000,
    UploadAtts1 : function(component) {
		//var action = component.get("c.UploadAttachments");
        var attTds = component.find("tdsfile").getElement();
		
        var file = attTds.files[0];
		attTds = "";
    
    	if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
        //alert("The file has been successfully added.");
        var fr = new FileReader();
        
        var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents, "Form 16B(TDS Certificate)");
        };

        fr.readAsDataURL(file);
	},

	UploadAtts2 : function(component) {
		//var action = component.get("c.UploadAttachments");
        var attTds = component.find("formfile").getElement();
		
        var file = attTds.files[0];
		attTds = "";
    
    	if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
        //alert("The file has been successfully added.");
        var fr = new FileReader();
        
        var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents, "Payment Details");
        };

        fr.readAsDataURL(file);
	},

	UploadAtts3 : function(component) {
		//var action = component.get("c.UploadAttachments");
        var attTds = component.find("Regisfile").getElement();
		
        var file = attTds.files[0];
		attTds = "";
    
    	if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
        //alert("The file has been successfully added.");
        var fr = new FileReader();
        
        var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents, "Bank Loan Sanction Letter");
        };

        fr.readAsDataURL(file);
	},

	UploadAtts4 : function(component) {
		//var action = component.get("c.UploadAttachments");
        var attTds = component.find("Otherfile").getElement();
		
        var file = attTds.files[0];
		attTds = "";
    
    	if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
        //alert("The file has been successfully added.");
        var fr = new FileReader();
        
        var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents, "Other Documents");
        };

        fr.readAsDataURL(file);
	},
        
    upload: function(component, file, fileContents, DocName) {
		//alert("m in");
        var action = component.get("c.UploadAttachments"); 
		var selectedUnit = component.get("v.SelectedUnit");
        action.setParams({
            "fileName": file.name,
            "base64Data": encodeURIComponent(fileContents), 
            "contentType": file.type,
			"strSelectedUnit" : selectedUnit,
			"DocumentName" : DocName
        });

        action.setCallback(this, function(response) {
            //attachId = response.getReturnValue();
            //console.log(attachId);
			alert(response.getReturnValue());
        });
            
        //$A.run(function() {
            $A.enqueueAction(action); 
        //});
		this.getPortalDocuments(component);
    },

	changeImgForwrd : function(component, event) {
        var currentImg = component.get("v.imageIndex");
        var lstAllAtt = component.get("v.lstPDF");
        component.set("v.imageIndex", currentImg + 1); 
		component.set("v.pdfContainer", ""); 
		this.goToPDF(component, event, lstAllAtt[currentImg + 1]);
	},

	changeImgBack : function(component, event) {
        var currentImg = component.get("v.imageIndex");
        var lstAllAtt = component.get("v.lstPDF");
        component.set("v.imageIndex", currentImg - 1); 
		component.set("v.pdfContainer", "");
		this.goToPDF(component, event, lstAllAtt[currentImg - 1]);
	},
})