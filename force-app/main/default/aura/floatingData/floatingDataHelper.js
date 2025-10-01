({
    shiftDiv: function(component, event,lWidth) {
        var changeposition = component.get("v.intervalId");
        var floatElement = document.getElementById('tofloat');
        var classEle = document.getElementsByClassName('tofloat');
        var data = component.get("v.lstRunwalEvent");
        var bolFlah = true;
        var bolBlobk = true;
        var lastElement = data[data.length-1].style;
        try{
            if(classEle.length > 0){
                for(var index=0;index<classEle.length;index++){
                    var eachElement = classEle[index];
                    
                    if(parseInt(lastElement) < -700 && parseInt(data[index].style) < 0){
                        data[index].style = -1600;
                    }
                    if(parseInt(data[index].style) == -1600 && bolFlah){
                        bolFlah = false;
                        console.log('line 12',index)
                        if(index ==0){
                            eachElement.style.left = window.innerWidth-150+'px';
                            data[index].style = window.innerWidth-150;
                        }else{
                            eachElement.style.left = parseInt(data[index-1].style)+4+'px';
                            data[index].style = parseInt(data[index-1].style)+4;
                        }
                        
                        eachElement.style.display = 'inline';
                        
                        return true;
                    }else if(parseInt(data[index].style) > -1500){
                        console.log('line 17')
                        var leftData = parseInt(data[index].style)-2;
                        eachElement.style.left = leftData>-1500 ? leftData+'px':-1600+'px';
                        eachElement.style.display = 'inline';
                        data[index].style = leftData>-1500 ? leftData:-1600;
                    }else if(parseInt(data[index].style) != -1600 && bolBlobk && parseInt(data[index].style) == -1500){
                        bolBlobk = false;
                        console.log('line 22')
                        eachElement.style.left = -1600+'px';//data[data.length-1].style != -10 ? -10+'px':0+'px';
                        data[index].style = -1600;//data[data.length-1].style != -10 ? -10:0;
                        eachElement.style.display = 'none';//data[data.length-1].style == -10 ? 'none':'inline';
                    }
                }            
            }
        }catch(e){}
      /*  if(changeposition >0){
            floatElement.style.left = changeposition+'px';
            changeposition = changeposition - 2;
            component.set("v.intervalId",changeposition);
            component.set("v.bolFloatFlag",true);
        }
        //reset the left to 0
        else{
            component.set("v.intervalId",lWidth);
            floatElement.style.left = "0px";
            changeposition = component.get("v.intervalId");//resetting so as to hit the if block again
        }*/
        var cls = document.getElementsByClassName('eachLink');
        console.log('cls : ',cls)
    }
})