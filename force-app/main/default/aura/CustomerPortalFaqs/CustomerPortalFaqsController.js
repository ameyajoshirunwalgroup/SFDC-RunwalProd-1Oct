({
	doInit : function(component, event, helper) {
        //var changeElement = component.find("Ans");
        
        var url = $A.get('$Resource.Customer_Portal_FAQs_Background_Image');
        component.set('v.backgroundImageURL', url);
        var title = $A.get("$Label.c.FAQ_Header_English");
        var showMulti = $A.get("$Label.c.Show_Multi_Language_FAQ_on_Customer_Portal");
        component.set("v.showMultiLanguage", showMulti);
        console.log(showMulti);
        if(showMulti === 'true'){
            console.log('showMulti if: ', showMulti);
            var action = component.get("c.englishFaq");
        }else{
            console.log('showMulti else: ', showMulti);
            var action = component.get("c.lstFetchFaqs");
        }
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstFaqs", response.getReturnValue());
                component.set("v.title", title);
            }
        });
		$A.enqueueAction(action);
	},
    
    hindiFaqs : function(component, event, helper) {
        //var changeElement = component.find("Ans");
        var title = $A.get("$Label.c.FAQ_Header_Hindi");
        var action = component.get("c.hindiFaq");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstFaqs", response.getReturnValue());
                component.set("v.title", title);
            }
        });
		$A.enqueueAction(action);
	},
    
    marathiFaqs : function(component, event, helper) {
        //var changeElement = component.find("Ans");
        var title = $A.get("$Label.c.FAQ_Header_Marathi");
        var action = component.get("c.marathiFaq");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstFaqs", response.getReturnValue());
                component.set("v.title", title);
            }
        });
		$A.enqueueAction(action);
	},
    
    englishFaqs : function(component, event, helper) {
        //var changeElement = component.find("Ans");
        var title = $A.get("$Label.c.FAQ_Header_English");
        var action = component.get("c.englishFaq");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstFaqs", response.getReturnValue());
                component.set("v.title", title);
            }
        });
		$A.enqueueAction(action);
	},
    
    onclickQue : function(component, event, helper) {
        // first get the div element. by using aura:id
        var id = event.currentTarget.dataset.id;
        for (var i=0; i<component.get("v.lstFaqs").length ; i++) {
   if(component.get("v.lstFaqs")[i].RW_Question__c == id)
   {
       //component.find(component.get("v.lstFaqs")[i].RW_Answer__c).set('v.class','');
      component.find(component.get("v.lstFaqs")[i].RW_Order__c).set('v.class',''); 
       //component.find('test').set('v.class','');
       //$A.util.removeClass(component.find('test'), 'slds-hide');
   }
}
      //var changeElement = component.find("Ans");
        // by using $A.util.toggleClass add-remove slds-hide class
     // $A.util.addClass(component.find("Ans","slds-hide"));
	  } 
})