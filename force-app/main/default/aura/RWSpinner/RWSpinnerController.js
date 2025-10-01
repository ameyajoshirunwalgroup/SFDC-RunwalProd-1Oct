({
	showSpinner : function (component, event, helper) {
        //alert("show");
     var toggleText = component.find("spinner");
    $A.util.removeClass(toggleText,'toggle');
},

 hideSpinner : function (component, event, helper) {
     //alert("hide");
   var toggleText = component.find("spinner");
   $A.util.addClass(toggleText,'toggle');
  }
})