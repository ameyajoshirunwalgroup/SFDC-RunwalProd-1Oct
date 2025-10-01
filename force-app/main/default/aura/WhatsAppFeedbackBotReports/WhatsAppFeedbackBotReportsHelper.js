({
    eventRepHelper : function(component, event, helper) {
        console.log('eventRepHelper ');
        //var action = component.get("c.eventReport");
        //var selectedTeam = component.find("team").get("v.value");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        var tm = component.get("v.userTeam");
        //console.log('team: ', selectedTeam);
        console.log('date Range: ', selectedDateRange);
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            var action = component.get("c.eventReport");
            action.setParams({
                "userTeam":tm,
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            var action = component.get("c.eventReport");
            action.setParams({
                "userTeam":tm,
                "dateRange":selectedDateRange
            });
        }
        /*action.setParams({
            "team":tm,
            "dateRange":selectedDateRange
        });*/

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.countDetails", response.getReturnValue());
            //console.log('resp: ', component.get("v.countDetails"));
        });
        $A.enqueueAction(action);
    },
    
    npsRepHelper : function(component, event, helper) {
        console.log('npsRepHelper:');
        //var action = component.get("c.npsReport");
        //var selectedTeam = component.find("team").get("v.value");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        //var tm = component.get("v.team");
        var tm = component.get("v.userTeam");
        console.log('---tm--: ', tm);
        //console.log('team: ', selectedTeam);
        
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            var action = component.get("c.npsReport");
            action.setParams({
                "userTeam":tm,
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            var action = component.get("c.npsReport");
            action.setParams({
                "userTeam":tm,
                "dateRange":selectedDateRange
            });
        }
        console.log('date Range: ', selectedDateRange);
        /*action.setParams({
            "team":tm,
            "dateRange":selectedDateRange
        });*/

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if(response.getReturnValue() != null){
                component.set("v.showNPSTable",true);
                component.set("v.npsMap", response.getReturnValue());
                console.log('npsMap: ', response.getReturnValue());
            }else{
                component.set("v.showNPSTable",false);
                component.set("v.showNPSDataTable",false);
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    custInsghRepHelper : function(component, event, helper) {
        console.log('npsRepHelper:');
        //var action = component.get("c.customerInsightsReport");
        //var selectedTeam = component.find("team").get("v.value");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        var tm = component.get("v.team");
        //console.log('team: ', selectedTeam);
        console.log('date Range: ', selectedDateRange);
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            var action = component.get("c.customerInsightsReport");
            action.setParams({
                "team":tm,
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            var action = component.get("c.customerInsightsReport");
            action.setParams({
                "team":tm,
                "dateRange":selectedDateRange
            });
        }
        /*action.setParams({
            "team":tm,
            "dateRange":selectedDateRange
        });*/

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if(response.getReturnValue() != null){
                component.set("v.showNPSTable",true);
                component.set("v.custInstMap", response.getReturnValue());
                console.log('custInstMap: ', response.getReturnValue());
            }else{
                component.set("v.showNPSTable",false);
                component.set("v.showNPSDataTable",false);
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    setPicklistOptions: function(component, picklistType) {
        var options = [];
        if (picklistType === 'channelPartnerOptions') {
            options = [
                { label: 'Channel Partner Case Report', value: 'Channel Partner Case Report' }
                // Add more channel partner specific options here
            ];
        } else {
            options = [
                { label: 'NPS Report', value: 'NPS Report' },
                { label: 'Events Report', value: 'Events Report' },
                { label: 'Customer Insights', value: 'Customer Insights' },
                { label: 'Campaign Report', value: 'Campaign Report' },
                { label: 'Channel Partner Case Report', value: 'Channel Partner Case Report' }
                // Add default options here
            ];
        }
        component.set("v.picklistOptions", options);
    },
       
    dayofRegHelper : function(component, proj){
        //component.set("v.showdayofReg", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showallEventTable", false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
		console.log('--dayofRegHelper--', component.get("v.report"));
        if(component.get("v.report") == 'Events Report'){
            console.log('--dayofRegHelper: Event Report--');
            component.set("v.showdayofReg", true);
            var action  = component.get("c.dayOfRegData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth,
                    "report":"Event",
                    "isExport":false
                });
                
            }else{
                action.setParams({
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":false
                });
            }
            /*action.setParams({
                "team":tm,
                "dateRange":selectedDateRange
            });*/
            component.set("v.showNPSpostPos", false);
			component.set("v.showNPSdayofPos", false);
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.dayOfRegData", response.getReturnValue());
                
            });
            $A.enqueueAction(action);
        }else if(component.get("v.report") == 'NPS Report'){
            console.log('proj: ', proj);
            component.set("v.showNPSdayofReg", true);
            //var action = component.get("c.dayOfRegNpsData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                var action = component.get("c.dayOfRegNpsData");
                action.setParams({
                    "proj":proj,
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                var action = component.get("c.dayOfRegNpsData");
                action.setParams({
                    "proj":proj,
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth
                });
            }
            /*action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
            	"team":component.get("v.team")
            });*/
            component.set("v.showNPSpostPos", false);
			component.set("v.showNPSdayofPos", false);
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.dayOfRegData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        
        
        
    },
    
    dayofPosHelper : function(component, proj){
        //component.set("v.showdayofPos", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showpostPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showallEventTable", false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action;
        if(component.get("v.report") == 'Events Report'){
            component.set("v.showdayofPos", true);
            action = component.get("c.dayofPosData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth,
                    "report":"Event",
                    "isExport":false
                });
                
            }else{
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":false
                });
            }
            /*action.setParams({
                "team":tm,
                "dateRange":selectedDateRange
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSpostPos", false);
           
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.dayOfPosData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        if(component.get("v.report") == 'NPS Report'){
            component.set("v.showNPSdayofPos", true);
            action = component.get("c.dayofPosNpsData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                //var action = component.get("c.dayofPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team"),
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                //var action = component.get("c.dayofPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team")
                });
            }
            /*action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
            	"team":component.get("v.team")
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSpostPos", false);
           
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.dayOfPosData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        
    },
    
    postPosHelper : function(component, proj){
        component.set("v.showpostPos", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showallEventTable", false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action;
        if(component.get("v.report") == 'Events Report'){
            component.set("v.showpostPos", true);
            action = component.get("c.postPosData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth,
                    "report":"Event",
                    "isExport":false
                });
                
            }else{
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":false
                });
            }
            /*action.setParams({
                "team":tm,
                "dateRange":selectedDateRange
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSdayofPos", false);
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.postPosData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        if(component.get("v.report") == 'NPS Report'){
            component.set("v.showNPSpostPos", true);
            action = component.get("c.postPosNpsData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                //var action = component.get("c.postPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team"),
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                //var action = component.get("c.postPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team")
                });
            }
            /*action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
            	"team":component.get("v.team")
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSdayofPos", false);
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.postPosData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        
    },
    
    salesExpHelper : function(component, proj){
        component.set("v.showpostPos", false);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showallEventTable", false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action;
        if(component.get("v.report") == 'Events Report'){
            component.set("v.showsalesExp", true);
            action = component.get("c.salesExpData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "year":yr,
                    "month":mnth,
                    "report":"Event",
                    "isExport":false
                });
                
            }else{
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":false
                });
            }
            /*action.setParams({
                "team":tm,
                "dateRange":selectedDateRange
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSdayofPos", false);
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.salesExpData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        if(component.get("v.report") == 'NPS Report'){
            component.set("v.showNPSsalesExp", true);
            action = component.get("c.salesExpNpsData");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.team");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                //var action = component.get("c.postPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team"),
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                //var action = component.get("c.postPosNpsData");
                action.setParams({
                    "proj":proj,
                    "dateRange":selectedDateRange,
                    "team":component.get("v.team")
                });
            }
            /*action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
            	"team":component.get("v.team")
            });*/
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSdayofPos", false);
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.salesExpData", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
        
    },
    getProjectFeedback: function(component) {
        var action = component.get("c.getProjectFeedback");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.feedbackList", response.getReturnValue());
            } else {
                console.error("Failed to fetch project feedback");
            }
        });
        $A.enqueueAction(action);
    },
    caseClsHelper : function(component, proj){
        console.log('target name: ', proj);
        component.set("v.showNPSCaseCls", true);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action = component.get("c.caseClosureData");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        var tm = component.get("v.team");
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            action.setParams({
                 "proj":proj,
                "dateRange":selectedDateRange,
                "team":component.get("v.team"),
                "year":yr,
                "month":mnth
            });
            
        }else{
            action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
                "team":component.get("v.team")
            });
        }
        /*action.setParams({
            "proj":proj,
            "dateRange":selectedDateRange,
            "team":component.get("v.team")
        });*/
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.caseClsData", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    callDipHelper : function(component, proj){
        component.set("v.showNPSCalDisp", true);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action = component.get("c.callDispData");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        var tm = component.get("v.team");
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
                "team":component.get("v.team"),
                "year":yr,
                "month":mnth
            });
            
        }else{
            action.setParams({
                "proj":proj,
                "dateRange":selectedDateRange,
                "team":component.get("v.team")
            });
        }
        /*action.setParams({
            "proj":proj,
            "dateRange":selectedDateRange,
            "team":component.get("v.team")
        });*/
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.callDipData", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    endOfConvHelper : function(component, proj){
        component.set("v.showNPSEndOfConv", true);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        var action = component.get("c.endOfBotData");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        var tm = component.get("v.team");
        
        //window.scrollTo(0, 10000);
        //window.scrollBy(10, window.innerHeight);
        /*var scrollOptions = {
            left: 0,
            top: 1471,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);*/
        //window.scrollBy(0, window.innerHeight);
        
        action.setParams({
            "proj":proj,
            "dateRange":selectedDateRange,
            "team":component.get("v.team")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.endOfConvData", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    recordDetHelper : function(component, event, helper){
        
        component.set("v.showEventTable", true);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        component.set("v.showallEventTable", false);
        component.set("v.showNPSDataTablePPD", false);
        var action = component.get("c.recordDetails");
        console.log('event: ', component.get("v.selectedEvent"));
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            //var action = component.get("c.eventReport");
            action.setParams({
                "fbType":component.get("v.selectedEvent"),
                "team": component.get("v.team"),
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            action.setParams({
                "fbType":component.get("v.selectedEvent"),
                "team": component.get("v.team"),
                "dateRange":selectedDateRange
            });
        }
        /*action.setParams({
            "fbType":component.get("v.selectedEvent"),
            "team": component.get("v.team"),
            "dateRange":selectedDateRange
        });*/
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.recDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    overallRecordDetHelper : function(component, fbType){
        
        component.set("v.showallEventTable", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        component.set("v.showNPSDataTablePPD", false);
        var action = component.get("c.overallDayOfRegData");
        //var selectedDateRange = component.find("dateRange").get("v.value");
        var selectedDateRange = component.get("v.dateRange");
        action.setParams({
            "fbType":fbType,
            "team": component.get("v.team"),
            "dateRange":selectedDateRange
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.allRecDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    
    userDetails : function(component, event, helper){
        console.log('userDetails');
        var action = component.get("c.userDetails");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('team resp ', response.getReturnValue());
            component.set("v.userTeam", response.getReturnValue());
            component.set("v.team", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    campaignsList : function(component, event, helper){
        console.log('campaignDetails');
        var action = component.get("c.campaignDetails");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('Resp ', response.getReturnValue());
            component.set("v.CampaignPicklistOptions", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    campaignQuestions : function(component, event, helper){
        console.log('campaignQuestions');
        var action = component.get("c.campaignFBQuestions");
        action.setParams({
            "camp":component.get("v.selectedCapmaign")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('Resp ', response.getReturnValue());
            component.set("v.campQuestions", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    campFBDetailsHelper : function(component, event, helper){
        var camp = component.get("v.selectedCapmaign");
        console.log('camp: ', camp);
        
        var action = component.get("c.campaignFBDetails");
        action.setParams({
            "camp":camp
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.campFBData", response.getReturnValue());
            component.set("v.showCampAllDetTable", true);
            component.set("v.showCampCountTable", false);
            component.set("v.campNPSDetailsTable", false);
        });
        $A.enqueueAction(action);
    },
    
    campNPSHelper : function(component, event, helper){
        var camp = component.get("v.selectedCapmaign");
        console.log('camp: ', camp);
        
        var action = component.get("c.campaignNPS");
        action.setParams({
            "camp":camp
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('campNPSHelper ', response.getReturnValue());
            component.set("v.campNPSData", response.getReturnValue());
            component.set("v.showCampAllDetTable", false);
            component.set("v.showCampCountTable", false);
        });
        $A.enqueueAction(action);
    },
    
    npsScoreHelper : function(component, event, helper){
        
        var action = component.get("c.npsSummaryForYear");
        var tm = component.get("v.userTeam");
        console.log('npsScoreHelper team: ', tm);
        action.setParams({
            "userTeam":tm
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('npsSummary ', response.getReturnValue());
            component.set("v.npsSummary", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    custInstScoreHelper : function(component, event, helper){
        
        var action = component.get("c.custInstSummaryForYear");
        var tm = component.get("v.team");
        console.log('npsScoreHelper team: ', tm);
        action.setParams({
            "team":tm
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('custInstSummary ', response.getReturnValue());
            component.set("v.custInstSummary", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    convertArrayOfObjectsToCSV : function(component, objectRecords){
        var csvStringResult, counter, keys, columnDivider, lineDivider;

        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }

        // store ,[comma] in columnDivider variable for separate CSV values and
        // for start next line use '\n' [new line] in lineDivider variable
        columnDivider = ',';
        lineDivider =  '\n';

        // in the keys valirable store fields API Names as a key
        // this labels use in CSV file header
        keys = Object.keys(objectRecords[0]); // FIXME: If the first record has empty fields, then they won't appear in header.
        console.log(keys);

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;

        for(var i=0; i < objectRecords.length; i++){
            counter = 0;

            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;

                // add , [comma] after every String value,. [except first]
                if(counter > 0){
                    csvStringResult += columnDivider;
                }

                csvStringResult += '"'+ objectRecords[i][skey]+'"';

                counter++;

            }

            csvStringResult += lineDivider;
        }

        return csvStringResult;
    }
})