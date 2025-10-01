({
	shiftDiv : function(component, event,lWidth) {
		var changeposition = component.get("v.intervalId");
        //var position = component.get("v.lstRunwalEvent");
        var floatElement = document.getElementById('tofloat');	  
        if(changeposition < lWidth){
            if(floatElement != undefined && floatElement.style != undefined && floatElement.style.right !=undefined)
            {
            floatElement.style.right = changeposition+'px';
            changeposition = changeposition + 5;
            component.set("v.intervalId",changeposition);
            }
        }
        //reset the left to 0
        else{
            component.set("v.intervalId",0);
            //component.set("v.lstRunwalEvent");
            floatElement.style.right = "0px";
            changeposition = component.get("v.intervalId");//resetting so as to hit the if block again
            //position = component.get("v.lstRunwalEvent");
        }
	}
})