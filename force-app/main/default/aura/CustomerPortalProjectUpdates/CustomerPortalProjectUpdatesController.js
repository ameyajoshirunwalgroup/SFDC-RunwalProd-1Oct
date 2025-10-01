({
	doInit : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action=component.get('c.getPortalHomeData');
        
        action.setCallback(this,function(response){
            var state = response.getState();
            //console.log('state ='+state);
            if (state === "SUCCESS") {
               
				
                component.set("v.RunwalHomeWrapList", response.getReturnValue());
                component.set("v.Spinner",false);
                console.log('v.RunwalHomeWrapList='+JSON.stringify(response.getReturnValue()));
              }
        });$A.enqueueAction(action);
       
    },
    
    onactiveTab: function(component, event, helper) {
        console.log('*');
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].towerConstructionDetails != undefined)
                            {
  
                                    if(event.getSource().get('v.id')== component.get("v.RunwalHomeWrapList")[i].BookingId)
                                    {
                                        var contphotos = [];
                                        var obj =component.get("v.RunwalHomeWrapList")[i].towerConstructionDetails;
                                        for (var key in obj) {
                                          var photoarray=[];
                                          if (obj.hasOwnProperty(key)) {
                                             for(var innerkey in obj[key])
                                             {
                                                 
                                                 var jsonobject = {};
                                                 jsonobject['photoId'] = innerkey;
                                                 jsonobject['description'] = obj[key][innerkey];
                                                 photoarray.push(jsonobject)
                                                 
                                             }
                                              contphotos.push({value:photoarray, key:key});
                                            //contphotos.push({value:obj[key], key:key});
                                          }
                                        }
                                        
                                        component.set("v.contructionphotos", contphotos);
                                       // var map =component.get('v.photosmap');
                                        //map[component.get("v.RunwalHomeWrapList")[i].towerConstructionWrapperList[j].photodatemonth+','+component.get("v.RunwalHomeWrapList")[i].towerConstructionWrapperList[j].photodatemonth.photodateyear]=
                                        // var obj = component.get("v.RunwalHomeWrapList")[i].towerConstructionWrapperList.RW_Complaint_SubType__c.pickListMap;
                                    }
                                
                            }
                        }
    },
    
    openBrochureLink:function(component, event, helper) {
		// window.open("https://runwalgroup.in/affordability-calculator");
		window.open(event.getSource().get('v.name').ProjectBrochureLink);
    },
    
    openprojectvideoLink:function(component, event, helper) {
		 //window.open("https://runwalgroup.in/affordability-calculator");
		 window.open(event.getSource().get('v.name').ProjectVideoLink);
    },
    
    opentowerfloorplanlink:function(component, event, helper) {
		 //window.open("https://runwalgroup.in/affordability-calculator");
        window.open(event.getSource().get('v.name').TowerFloorPlanLink);
    },
})