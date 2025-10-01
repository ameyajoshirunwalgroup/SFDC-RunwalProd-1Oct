({
    doInit: function(cmp) 
    {
        cmp.set("v.Spinner",true);
        //var myPageRef = cmp.get("v.pageReference");
        //var towId = myPageRef.state.c__towerId;
        var towerId= cmp.get("v.towerId");
        var projectId= cmp.get("v.projectId")
        debugger;
        if(towerId != null && towerId != '' && towerId != undefined){
            var action = cmp.get("c.getTowerTC");
            
            action.setParams({ towerId :towerId });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    cmp.set("v.tcMessage",response.getReturnValue());
                    cmp.set("v.Spinner",false);
                }
                else
                {
                    cmp.set("v.hasError",true);
                    cmp.set("v.errorMessage",response.getError()[0].message);
                    cmp.set("v.Spinner",false);
                    return;
                }
                
            });
            $A.enqueueAction(action);  
        }
        else if(projectId != null && projectId != '' && projectId != undefined){

            var action = cmp.get("c.getProjectTC");
            
            action.setParams({ projectId :decodeURIComponent(projectId) });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    cmp.set("v.tcMessage",response.getReturnValue());
                    cmp.set("v.Spinner",false);
                }
                else
                {
                    cmp.set("v.hasError",true);
                    cmp.set("v.errorMessage",response.getError()[0].message);
                    cmp.set("v.Spinner",false);
                    return;
                }
                
            });
            $A.enqueueAction(action);  
        }


    }
})