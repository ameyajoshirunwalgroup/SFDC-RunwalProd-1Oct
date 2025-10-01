({
	loadPDF: function (component, event, helper) {
		 try{
		   
		   var iFramId = component.find('pdfFrame');
           //iFramId.height = iFrameID.contentWindow.document.body.scrollHeight + "px";
		   
		   var pdfData = component.get('v.pdfData');
           var pdfjsframe = component.find('pdfFrame')
           if(typeof pdfData != 'undefined'){
            pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*'); 
           }
          }catch(e){
           alert('Error: ' + e.message);
          }
    }
})