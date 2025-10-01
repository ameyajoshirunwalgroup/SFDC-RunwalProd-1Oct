({
    doInit : function(component, event, helper) {
        console.log('recordId!!!',component.get("v.recordId"));
        var action = component.get("c.wcCallRemarks");
        action.setParams({
            "wcObjID":component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response){  
            
            var state = response.getState();
            if ("SUCCESS" === state ) {
                // var rmks = [];
                
                if(null!=response.getReturnValue()){
                    var rmkList = response.getReturnValue(); 
                    console.log('rmkList!!!',rmkList);
                    
                    var remarkList=[];
                    
                    for (var i=0; i<rmkList.length; i++) {
                        var obj = {};
                        obj['Name']= rmkList[i].Name;
                        obj['OwnerName']= rmkList[i].Owner.Name;
                        obj['CreatedDate']= rmkList[i].CreatedDate;
                        obj['CreatedByName']= rmkList[i].CreatedBy.Name;
                        obj['LastModifiedDate']= rmkList[i].LastModifiedDate;
                        obj['LastModifiedByName']= rmkList[i].LastModifiedBy.Name;
                        if(rmkList[i].RW_Remarks__c != null && rmkList[i].RW_Remarks__c != undefined){
                            var objRemark={};
                            var rems='';
                            var counter = 0;
                            var key;
                            var value;
                            var remark;
                            var recListData=[];
                            rmkList[i].RW_Remarks__c.split(",").forEach(element=>{
                                counter++;
                                
                                if(element != null && element != undefined ){
                                var rc ='\nReceiptListRemarks';
                                var df = JSON.stringify(element.split(':')[0]);
                                key = JSON.parse(df);
                                //console.log(rc.trim(),' : key : ',key)
                                // console.log(key.localeCompare(rc),' : type ofkey : ',typeof key)
                                if(key.localeCompare(rc)){
                                console.log('line 44')
                                value = element.split(':')[1] != undefined ? element.split(':')[1].split('~')[1]:'';
                                remark = element.split(':')[1] != undefined ? element.split(':')[1].split('%')[1]:'';
                            }else{
                                                                        value='';
                                                                        var objRec;
                                                                        if(element != undefined && element != null){
                                element.split(";").forEach(ff=>{
                                    console.log('ff : ',ff)
                                    if(ff.includes('Name')){
                                    console.log('====== >>> ',ff.includes('~'))
                                   
                                    if(objRec != null && objRec != undefined){
                                        var objFD = JSON.stringify(objRec);
                                        recListData.push(JSON.parse(objFD));
                                	}
                                    objRec={};
                                    if(ff.includes('~')){
                                    	objRec[ff.split('~')[1].split(':')[0]] = ff.split('~')[1].split(':')[1]; 
                                    }else{
                                        objRec[ff.split(':')[0].replace(/(\r\n|\n|\r)/gm, "")] = ff.split(':')[1]; 
                                    }
                                }else{
                                    console.log('line 64')
                                    if(! ff.split(':')[0].includes('ReceiptListRemarks ')){
                                    	objRec[ff.split(':')[0].replace(/(\r\n|\n|\r)/gm, "")] = ff.split(':')[1];
                                }else{
                                    	remark = ff.split(':')[0].split('%')[1];
                                    console.log('remmmm : ',remark)
                                }
                                    	
                                }
                                });
                                    recListData.push(objRec);
                                    console.log('recListData : ',recListData)
                                    component.set("v.remarkListData",recListData)
                                    console.log('recListData  amt: ',recListData[0]['Total_Amount__c'])
                                }
                                    var recList = element.split(':')[1] != undefined ? element.split(':')[2]:'';
                                    console.log('recList : ',recList);
                                  //  remark = recList[recList.length-1]['~ReceiptListRemarks'];
                                    
                                }
                                                           
                                                           }
                                                           //console.log('remark!!! ',remark);
                                                           var key1 = key.replace(/(\r\n|\n|\r)/gm, "");
                                objRemark[key1]=value;
                                var rem = 'remark'+key1;
                                console.log('rem ',rem);
                                objRemark[rem] = remark;
                                rems = 'remarks';//+counter;
                                console.log('rems!!! ',rems);
                                console.log('counter!!! ',counter);
                            });
                            obj[rems]=objRemark;
                            console.log('obj!!! ',obj);
                            //console.log('objRemark!!! ',objRemark);
                        }
                        remarkList.push(obj);
                        console.log('remarkList!!!',remarkList);
                        
                    }
                    component.set("v.rmkList",remarkList);
                    console.log('remarkList!!!@@',remarkList);
                    //component.set("v.rmkList", rmkWrp.wcRmksList);
                    // 
                }
            }else if ("ERROR" === state ) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });  
        $A.enqueueAction(action);  
    }
    
    
})