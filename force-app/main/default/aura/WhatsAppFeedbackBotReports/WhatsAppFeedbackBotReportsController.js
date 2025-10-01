({
    init: function(component, event, helper) {
        helper.getProjectFeedback(component);
    },
    doInit : function(component, event, helper) {
        
        var visitType='';
        var newuser='';
        var today = new Date();
        var year = today.getFullYear();
        var yearList = [year, year-1, year-2, year-3, year-4];
        component.set("v.year", yearList);
        component.set("v.year1", year);
        component.set("v.year2", year-1);
        component.set("v.year3", year-2);
        component.set("v.year4", year-3);
        component.set("v.year5", year-4);
        console.log('yearValues: ', yearList);
        console.log('yearValues: ', component.get("v.year"));
        
        
        console.log('userDetails');
        var action = component.get("c.userDetails");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('team resp ', response.getReturnValue());
            var resp = response.getReturnValue();
            var team1 = resp.split(':')[0];
            var team2 = resp.split(':')[1];
            console.log('team1: ', team1);
            console.log('team2: ', team2);
            var team3 = resp.split(':')[2];
            var team4 = resp.split(':')[3];
            console.log('team3: ', team3);
            console.log('team4: ', team4);       
            component.set("v.userTeam", response.getReturnValue());
            //component.set("v.team", response.getReturnValue());
            component.set("v.team", team1);
            component.set("v.team2", team2);
            component.set("v.showCPCaseDashboard", team3);
            component.set("v.userName", team4);
            
            component.set("v.dateRange","LAST_N_DAYS:30");
            if(component.get("v.team") != null && component.get("v.team") != '' && component.get("v.team") != undefined){
                component.set("v.report","NPS Report");
                helper.npsRepHelper(component, event, helper);
            }else {
                alert('You do not have the access. Please contact System administrator.');
            }
            
            if(team2 == 'FM'){
                console.log('----------FM');
                //component.find('lWCChild').LWCFunction();
                component.set("v.showPostPossessionForFM", true);
                var lwcCmp = component.find('lWCChild');
                lwcCmp.LWCFunction();
            }
            //component.set("v.report","Case Feedback Report");
            
            helper.npsScoreHelper(component);
        });
        $A.enqueueAction(action);
        


                
    },
    
    yearChange : function(component, event, helper){
        var yearValue = component.get("v.year")[component.get("v.yearVal")];
        console.log('yearValue: ', yearValue);
        
        //if(component.get("v.yearVal") != '' && component.get("v.monthVal") != ''){
        if(yearValue != '' && component.get("v.monthVal") != ''){
            console.log('monthValue: ', component.get("v.monthVal"));
            component.set("v.yearMonthWiseData", true);
            if(component.get("v.report") == 'NPS Report'){
                helper.npsRepHelper(component, event, helper);
            }else if(component.get("v.report") == 'Events Report'){
                helper.eventRepHelper(component, event, helper);
            }else if(component.get("v.report") == 'Customer Insights'){
                helper.custInsghRepHelper(component, event, helper);
            }
             
        }
        
        		
       
        //helper.custInsghRepHelper(component, event, helper);
        if(document.querySelector('c-test')){
            document.querySelector('c-test').resetTable();
        }
         if(document.querySelector('c-visitFeedbackDashboard')){
            document.querySelector('c-visitFeedbackDashboard').resetTable();
        }
    },
    
  visitTypeChange: function(component, event, helper) {
    var selectedVisitType = component.get("v.visitType");  
    console.log(component.get("v.visitType"));
    console.log('selectedVisitType: ', selectedVisitType);
    
    if(document.querySelector('c-visitFeedbackDashboard')){
            document.querySelector('c-visitFeedbackDashboard').resetTable();
        }
}
,
    onChange: function(component, event, helper) {
        const inputValue = event.getParam("userValue");
        console.log('Value:', inputValue);
        if (Array.isArray(inputValue) && inputValue.length > 0) {
            const inputValuenew = inputValue[0];
            console.log('Value:', inputValuenew);
        }else{
            component.set("v.userValue", "");
        }
    },

    
    repChange : function(component, event, helper) {
        console.log('repChange');
        console.log('report', component.get("v.report"));
        if(component.get("v.report") == 'NPS Report'){
            component.set("v.report","NPS Report");
            component.set("v.disableOverallExportButton",false);
            helper.npsRepHelper(component, event, helper);
        }else if(component.get("v.report") == 'Events Report'){
            component.set("v.report","Events Report");
            component.set("v.showNPSDataTable", false);
            component.set("v.showNPSEndOfConv", false);
            component.set("v.showNPSCaseCls", false);
            component.set("v.showNPSCalDisp", false);
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSpostPos", false);
			component.set("v.showNPSdayofPos", false);
            helper.eventRepHelper(component, event, helper);
        }else if(component.get("v.report") == 'Customer Insights'){
            component.set("v.report","Customer Insights");
            component.set("v.showNPSDataTable", false);
            component.set("v.showNPSEndOfConv", false);
            component.set("v.showNPSCaseCls", false);
            component.set("v.showNPSCalDisp", false);
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSpostPos", false);
			component.set("v.showNPSdayofPos", false);
            helper.custInsghRepHelper(component, event, helper);
            helper.custInstScoreHelper(component);
        }else if(component.get("v.report") == 'Campaign Report'){
            component.set("v.report","Campaign Report");
            component.set("v.showNPSDataTable", false);
            component.set("v.showNPSEndOfConv", false);
            component.set("v.showNPSCaseCls", false);
            component.set("v.showNPSCalDisp", false);
            component.set("v.showNPSdayofReg", false);
            component.set("v.showNPSpostPos", false);
			component.set("v.showNPSdayofPos", false);
            component.set("v.showCampNpsTable", false);
            component.set("v.showCampTable", false);
            component.set("v.showCampAllDetTable", false);
            component.set("v.selectedCapmaign", "");
            helper.campNPSHelper(component, event, helper);
            helper.campaignsList(component, event, helper);
        }else if(component.get("v.report") == 'Post Possession Handover'){
            component.set("v.showPostPossessionForFM", true);
            var lwcCmp = component.find('lWCChild');
            lwcCmp.LWCFunction();
        }
    },
    
    dateChange : function(component, event, helper) {
        component.set("v.showNPSDataTable",false);
        //helper.remarksReport(component);
        var dater = component.get("v.dateRange");
        if(dater === 'Custom'){
            component.set("v.showNPSTable",false);
        }else{
            component.set("v.yearVal", '');
            component.set("v.monthVal", '');
            
            if(component.get("v.showdayofReg")){
                helper.dayofRegHelper(component);
            }else if(component.get("v.showdayofPos")){
                helper.dayofPosHelper(component);
            }else if(component.get("v.showpostPos")){
                helper.postPosHelper(component);
            }else if(component.get("v.showEventTable")){
                helper.recordDetHelper(component);
            }else if(component.get("v.showNPSEndOfConv")){
                helper.endOfConvHelper(component);
            }else if(component.get("v.showNPSCalDisp")){
                helper.callDipHelper(component);
            }else if(component.get("v.showNPSCaseCls")){
                helper.caseClsHelper(component);
            }
            
            helper.npsRepHelper(component, event, helper);
            helper.custInsghRepHelper(component, event, helper);
            
            var action = component.get("c.eventReport");
            //var selectedTeam = component.find("team").get("v.value");
            //var selectedDateRange = component.find("dateRange").get("v.value");
            var selectedDateRange = component.get("v.dateRange");
            var tm = component.get("v.userTeam");
            //console.log('team: ', selectedTeam);
            console.log('date Range: ', selectedDateRange);
            action.setParams({
                "userTeam":tm,
                "dateRange":selectedDateRange
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response ', response.getReturnValue());
                component.set("v.countDetails", response.getReturnValue());
                console.log('resp: ', component.get("v.countDetails"));
            });
            $A.enqueueAction(action);
        }
        if(dater != 'Custom'){
            component.set("v.yearVal", '');
            component.set("v.monthVal", '');
        }
        if(document.querySelector('c-test')){
            document.querySelector('c-test').resetTable();
        }
        if(document.querySelector('c-visitFeedbackDashboard')){
            document.querySelector('c-visitFeedbackDashboard').resetTable();
        }
    },
    
    recordDet : function(component, event, helper){
        
        component.set("v.showEventTable", true);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        
        component.set("v.selectedEvent", event.currentTarget.id);
        
        helper.recordDetHelper(component);
        
        /*var dv = document.getElementById("showEventTableData");
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
    },
    
    overallRecordDet : function(component, event, helper){
        
        component.set("v.showEventTable", true);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        
        console.log("overallRecordDetHelper: ", event.currentTarget.id);
        
        helper.overallRecordDetHelper(component, event.currentTarget.id);
        
        /*var dv = document.getElementById("showNPSDataTableData");
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
    },
    
     npsRecordDet : function(component, event, helper){
         
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
        component.set("v.showNPSDataTablePPD", false);
        component.set("v.disableOverallExportButton", true);
        console.log('Id: ',  event.currentTarget.id);
         component.set("v.currentTarget",event.currentTarget.id);
         var evId = event.currentTarget.id;
         var action = component.get("c.npsRecordDetails");
         var selectedDateRange = component.get("v.dateRange");
         if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            action.setParams({
                "fbType":event.currentTarget.id,
                "team": component.get("v.team"),
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            action.setParams({
                "fbType":event.currentTarget.id,
                "team": component.get("v.team"),
                "dateRange":selectedDateRange
            });
        }
         /*action.setParams({
             "fbType":event.currentTarget.id,
             "team": component.get("v.team"),
             "dateRange":selectedDateRange
         });*/
         action.setCallback(this, function(response){
             var state = response.getState();
             console.log('response ', response.getReturnValue());
             component.set("v.npsData", response.getReturnValue());
             component.set("v.showNPSDataTable", true);
             console.log('Id1: ', evId);
             component.set("v.showNPSTable", false);
             
         });
         $A.enqueueAction(action);
        
    },
    
    npsRecordDetPPD : function(component, event, helper){
         
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
       	component.set("v.showNPSDataTable", false);
        component.set("v.disableOverallExportButton", true);
        console.log('Id: ',  event.currentTarget.id);
        component.set("v.currentTarget",event.currentTarget.id);
        var evId = event.currentTarget.id;
        var action = component.get("c.npsRecordDetailsPPD");
        var selectedDateRange = component.get("v.dateRange");
        if(component.get("v.yearMonthWiseData") === true){
            var yr = component.get("v.year")[component.get("v.yearVal")];
        	var mnth = component.get("v.monthVal");
            action.setParams({
                "fbType":event.currentTarget.id,
                "team": component.get("v.team"),
                "dateRange":selectedDateRange,
                "year":yr,
                "month":mnth
            });
            
        }else{
            action.setParams({
                "fbType":event.currentTarget.id,
                "team": component.get("v.team"),
                "dateRange":selectedDateRange
            });
        }
         /*action.setParams({
             "fbType":event.currentTarget.id,
             "team": component.get("v.team"),
             "dateRange":selectedDateRange
         });*/
         action.setCallback(this, function(response){
             var state = response.getState();
             console.log('response ', response.getReturnValue());
             component.set("v.npsDataPPD", response.getReturnValue());
             component.set("v.showNPSDataTablePPD", true);
             component.set("v.showNPSTable", false);
         });
         $A.enqueueAction(action);
        
    },
    
    openRec : function(component, event, helper){
        var recId = event.currentTarget.id;
        console.log('recId: ', recId);
        var recName = event.currentTarget.name;
        console.log('recName: ', recName);
        var url = 'https://runwal.lightning.force.com/lightning/r/WhatsApp_Feedback__c/'+recId+'/view';
        window.open(url);
    },
    
    dayofReg : function(component, event, helper){
        component.set("v.showdayofReg", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofPos", false);
        component.set("v.showpostPos", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showsalesExp", false);
        
        helper.dayofRegHelper(component, '');
        
        /*var dv = document.getElementById("showdayofRegData");
        console.log('dv: ', dv);
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
		//alert("Coordinates: " + rect.left + "px, " + rect.top + "px");
        
    },
    
    dayofPos : function(component, event, helper){
        
        component.set("v.showdayofPos", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showpostPos", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showsalesExp", false);
        
        helper.dayofPosHelper(component, '');
        
        /*var dv = document.getElementById("showdayofPosData");
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
       
    },
    
    postPos : function(component, event, helper){
        
        component.set("v.showpostPos", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showNPSDataTable",false);
        component.set("v.showsalesExp", false);
        
        helper.postPosHelper(component, '');
        
        /*var dv = document.getElementById("showpostPosData");
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
    },
    
    salesExp : function(component, event, helper){
        
        component.set("v.showsalesExp", true);
        component.set("v.showEventTable", false);
        component.set("v.showdayofReg", false);
        component.set("v.showdayofPos", false);
        component.set("v.showNPSDataTable",false);
        
        helper.salesExpHelper(component, '');
        
        /*var dv = document.getElementById("showpostPosData");
        var rect = dv.getBoundingClientRect();
        scrollTo(rect.left, rect.top);*/
    },
    
     caseCls : function(component, event, helper){
        component.set("v.showNPSCaseCls", true);
         component.set("v.showNPSDataTable",false);
        helper.caseClsHelper(component);
     },
    calDisp : function(component, event, helper){
        component.set("v.showNPSCalDisp", true);
        component.set("v.showNPSDataTable",false);
        helper.callDipHelper(component);
     },
    endOfBot : function(component, event, helper){
        component.set("v.showNPSEndOfConv", true);
        component.set("v.showNPSDataTable",false);
        helper.endOfConvHelper(component);
     },
    
    detailedRep : function(component, event, helper){
        var fbType = event.currentTarget.id;
        var proj = event.currentTarget.name;
        if(fbType == 'Case Closure'){
            component.set("v.showNPSCaseCls", true);
            helper.caseClsHelper(component, proj);
            component.set("v.showNPSTable", false);
        }else if(fbType == 'Call Disposition'){
            component.set("v.showNPSCalDisp", true);
        	helper.callDipHelper(component, proj);
            component.set("v.showNPSTable", false);
        }else if(fbType == 'End of Bot conversation'){
            component.set("v.showNPSEndOfConv", true);
        	helper.endOfConvHelper(component, proj);
           component.set("v.showNPSTable", false);
        }else if(fbType == 'Day of Registration'){
            component.set("v.showdayofReg", true);
            component.set("v.showEventTable", false);
            component.set("v.showdayofPos", false);
            component.set("v.showpostPos", false);
            helper.dayofRegHelper(component, proj);
            component.set("v.showNPSTable", false);
        }else if(fbType == 'Day of Possession Handover'){
            component.set("v.showdayofPos", true);
            component.set("v.showEventTable", false);
            component.set("v.showdayofReg", false);
            component.set("v.showpostPos", false);
            helper.dayofPosHelper(component, proj);
            component.set("v.showNPSTable", false);
        }else if(fbType == 'Post Possession Handover'){
            component.set("v.showpostPos", true);
            component.set("v.showEventTable", false);
            component.set("v.showdayofReg", false);
            component.set("v.showdayofPos", false);
            helper.postPosHelper(component, proj);
            component.set("v.showNPSTable", false);
        }else if(fbType == 'Sales Experience'){
            component.set("v.showSalesExp", true);
            component.set("v.showpostPos", false);
            component.set("v.showEventTable", false);
            component.set("v.showdayofReg", false);
            component.set("v.showdayofPos", false);
            helper.salesExpHelper(component, proj);
            component.set("v.showNPSTable", false);
        }
    },
    
    goBack : function(component, event, helper){
        component.set("v.showNPSTable", true);
        component.set("v.showNPSDataTable",false);
        component.set("v.showNPSDataTablePPD",false);
        component.set("v.showpostPos", false);
        component.set("v.showdayofPos", false);
        component.set("v.showdayofReg", false);
        component.set("v.showNPSEndOfConv", false);
        component.set("v.showNPSCalDisp", false);
        component.set("v.showNPSCaseCls", false);
        component.set("v.showNPSdayofReg", false);
        component.set("v.showNPSdayofPos", false);
        component.set("v.showNPSpostPos", false);
        component.set("v.showNPSsalesExp", false);
        component.set("v.disableOverallExportButton", false);
     },
    
    campChange : function(component, event, helper){
        var camp = component.get("v.selectedCapmaign");
        console.log('camp: ', camp);
        helper.campaignQuestions(component);
        helper.campNPSHelper(component);
        var action = component.get("c.campaignReport");
        action.setParams({
            "camp":camp
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.campCountDetails", response.getReturnValue());
            component.set("v.showCampTable", true);
            component.set("v.showCampAllDetTable", false);
            component.set("v.showCampCountTable", false);
            component.set("v.showCampNpsTable", true);
        });
        $A.enqueueAction(action);
    },
    
    campFBDetails : function(component, event, helper){
        helper.campaignQuestions(component);
        helper.campFBDetailsHelper(component);
    },
    
    campRecordDet : function(component, event, helper){
        var camp = component.get("v.selectedCapmaign");
        console.log('camp: ', camp);
        helper.campaignQuestions(component);
        var action = component.get("c.campaignRecDetails");
        action.setParams({
            "camp":camp,
            "eventType": event.currentTarget.id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.campRecDetails", response.getReturnValue());
            component.set("v.showCampCountTable", true);
            component.set("v.showCampAllDetTable", false);
            component.set("v.campNPSDetailsTable", false);
        });
        $A.enqueueAction(action);
    },
    
    campNpsRecordDet : function(component, event, helper){
        var camp = component.get("v.selectedCapmaign");
        console.log('camp: ', camp);
        
        var action = component.get("c.campNpsRecordDetails");
        action.setParams({
            "fbType":event.currentTarget.id,
            "camp":camp
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('campNPSHelper ', response.getReturnValue());
            component.set("v.campNPSDetails", response.getReturnValue());
            component.set("v.campNPSDetailsTable", true);
            component.set("v.showCampCountTable", false);
            component.set("v.showCampAllDetTable", false);
        });
        $A.enqueueAction(action);
    },
    
    exportData : function(component, event, helper){
        
        var trName = event.getSource().get("v.name");
        var reqAction = false;
        if(trName == 'npsExp'){
            var action = component.get("c.npsExport");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "userTeam":component.get("v.userTeam"),
                	"dateRange":component.get("v.dateRange"),
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                action.setParams({
                    "userTeam":component.get("v.userTeam"),
                    "dateRange":component.get("v.dateRange")
                });
            }
            /*action.setParams({
                "team":component.get("v.team"),
                "dateRange":component.get("v.dateRange"),
                "year":yr,
                "month":mnth
            });*/
            reqAction = true;
        }else if(trName == 'custInsExp'){
            var action = component.get("c.custInsExport");
            if(component.get("v.yearMonthWiseData") === true){
                var yr = component.get("v.year")[component.get("v.yearVal")];
                var mnth = component.get("v.monthVal");
                action.setParams({
                    "team":component.get("v.team"),
                	"dateRange":component.get("v.dateRange"),
                    "year":yr,
                    "month":mnth
                });
                
            }else{
                action.setParams({
                    "team":component.get("v.team"),
                    "dateRange":component.get("v.dateRange")
                });
            }
            /*action.setParams({
                "team":component.get("v.team"),
                "dateRange":component.get("v.dateRange"),
                "year":yr,
                "month":mnth
            });*/
            reqAction = true;
        }else if(trName == 'campExp'){
            var action = component.get("c.campaignExport");
            action.setParams({
                "camp":component.get("v.selectedCapmaign")
            });
            reqAction = true;
        }else if(trName == 'dayOfRegExp'){
            var action = component.get("c.dayOfRegData");
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
                    "isExport":true
                });
                
            }else{
                action.setParams({
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":true
                });
            }
            reqAction = true;
            //var expdata = component.get("v.dayOfRegData");
        }else if(trName == 'dayOfPosExp'){
            var action = component.get("c.dayofPosData");
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
                    "isExport":true
                });
                
            }else{
                action.setParams({
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":true
                });
            }
            reqAction = true;
            //var expdata = component.get("v.dayOfPosData");
            //reqAction = false;
        }else if(trName == 'postPosExp'){
            var action = component.get("c.postPosData");
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
                    "isExport":true
                });
                
            }else{
                action.setParams({
                    "team":tm,
                    "dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":true
                });
            }
            reqAction = true;
            //var expdata = component.get("v.postPosData");
            //reqAction = false;
        }else if(trName == 'salesExp'){
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
                    "isExport":true
                });
                
            }else{
                action.setParams({
                    "team":tm,
                	"dateRange":selectedDateRange,
                    "report":"Event",
                    "isExport":true
                });
            }
            //var expdata = component.get("v.salesExpData");
            reqAction = true;
        }else if(trName == 'caseCls'){
            /*var action = component.get("c.caseClsDataExport");
            action.setParams({
                "team":component.get("v.team"),
                "dateRange":component.get("v.dateRange"),
                "proj": event.currentTarget.name
            });*/
            var expdata = component.get("v.caseClsData");
            reqAction = false;
        }else if(trName == 'callDisp'){
            /*var action = component.get("c.callDispDataExport");
            action.setParams({
                "team":component.get("v.team"),
                "dateRange":component.get("v.dateRange"),
				"proj": event.currentTarget.name
            });*/
            var expdata = component.get("v.callDipData");
            reqAction = false;
        }else if(trName == 'recDet'){
            var expdata = component.get("v.npsData");
            reqAction = false;
        }else if(trName == 'recDetPPD'){
            var expdata = component.get("v.npsDataPPD");
            reqAction = false;
        }
        
        /*var action = component.get("c.npsExport");
        action.setParams({
            "team":component.get("v.team"),
            "dateRange":component.get("v.dateRange")
        });*/
        
        if(reqAction === true){
            action.setCallback(this, function(response){
                var state = response.getState();
                //console.log('campNPSHelper ', response.getReturnValue());
                //component.set("v.npsExpData", response.getReturnValue());
                var expdata = response.getReturnValue();
                var csv = helper.convertArrayOfObjectsToCSV(component, expdata);
                if (csv == null){return;}
                
                // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; //
                hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv]
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download csv file
            });
            $A.enqueueAction(action);
        }else{
            var csv = helper.convertArrayOfObjectsToCSV(component, expdata);
            if (csv == null){return;}
            
            // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
            hiddenElement.target = '_self'; //
            hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv]
            document.body.appendChild(hiddenElement); // Required for FireFox browser
            hiddenElement.click(); // using click() js function to download csv file
        }
        
    }
    
})