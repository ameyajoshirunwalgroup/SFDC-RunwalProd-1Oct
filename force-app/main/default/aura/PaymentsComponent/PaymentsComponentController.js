({
    showPaymentFields: function(cmp,event,helper)
    {debugger;                      cmp.set("v.dateErrorMsg","");

     if(event.getSource().get("v.value") != 'Digital' && event.getSource().get("v.value") != ''){
         cmp.set("v.showPaymentFields",true);
         cmp.set("v.addDisabled",false);
         cmp.set("v.digitalPaymentMode",false);

         
     }
     else
     {
         var receipt =  cmp.get("v.RecieptsList");
         if(receipt.length >1){
             cmp.set("v.ASpinner",true);
             var action1= cmp.get("c.removePaymentType");
             action1.setParams({  payments :cmp.get("v.RecieptsList"),size:receipt.length-1 });
             action1.setCallback(this, function(response) 
                                 {
                                     var state = response.getState();
                                     if (state === "SUCCESS") 
                                     {
                                         cmp.set("v.RecieptsList",response.getReturnValue());
                                         var receipts=   cmp.get("v.RecieptsList");
                                         debugger;          
                                         receipts[0].Total_Amount__c=  cmp.get("v.tokenAmount");
                                         cmp.set("v.RecieptsList",receipts);
                                         if(response.getReturnValue().length==1){
                                             cmp.set("v.removeDisabled",true);
                                         }
                                     }cmp.set("v.Spinner",false);}
                                );
             $A.enqueueAction(action1);
         }
         cmp.set("v.showPaymentFields",false);
         
         cmp.set("v.addDisabled",true);
         
         var receipts=   cmp.get("v.RecieptsList");
         debugger;          
         receipts[0].Total_Amount__c=  cmp.get("v.tokenAmount");
         cmp.set("v.RecieptsList",receipts);
         cmp.set("v.digitalPaymentMode",true);
     }
    },
    doInit:function(cmp,event,helper){
        var receiptfieldNames = ["Mode__c","DraweeBank__c"];
        var action13 = cmp.get("c.getPicklistValuesForFields");
        var rec = cmp.get("v.RecieptsList");
        console.log("MK"+rec);
        debugger;
        if(rec[0].Mode__c != 'Digital' && (rec[0].Mode__c!= "" && rec[0].Mode__c!= null && rec[0].Mode__c!= 'undefined'))
        {
            cmp.set("v.showPaymentFields",true);}
        
        action13.setParams({ "objectName" : 'Receipt__c' , fieldNames :receiptfieldNames });
        action13.setCallback(this, function(response) 
                             {
                                 var state = response.getState();
                                 if (state === "SUCCESS") 
                                 { 
                                     var receipts=   cmp.get("v.RecieptsList");
                                     debugger;          
                                     receipts[0].Total_Amount__c=  cmp.get("v.tokenAmount");
                                     cmp.set("v.RecieptsList",receipts);
                                     var responsevalues = response.getReturnValue();
                                     if(responsevalues.Mode__c)
                                     {
                                         cmp.set("v.PaymentModePicklistOptions",responsevalues.Mode__c);
                                     }
                                     
                                     if(responsevalues.DraweeBank__c)
                                     {
                                         cmp.set("v.PaymentBankPicklistOptions",responsevalues.DraweeBank__c);
                                     }
                                     
                                     cmp.set("v.ASpinner",false);
                                 }
                                 else
                                 {
                                     //   cmp.set("v.hasError",true);
                                     // cmp.set("v.errorMessage",response.getError()[0].message);
                                     cmp.set("v.ASpinner",false);
                                 }
                             });
        $A.enqueueAction(action13);
        
    },
    addPayment:function(cmp,event,helper){
        debugger;cmp.set("v.ASpinner",true);
        var action = cmp.get("c.addPaymentType");
        action.setParams({  payments :cmp.get("v.RecieptsList") });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   cmp.set("v.RecieptsList",response.getReturnValue());
                                   if(response.getReturnValue().length>1){
                                       cmp.set("v.removeDisabled",false);
                                   }
                               }
                               cmp.set("v.ASpinner",false);
                           });
        $A.enqueueAction(action);
    },
    removePayment:function(cmp,event,helper){
        debugger;cmp.set("v.ASpinner",true);
        var action1= cmp.get("c.removePaymentType");
        action1.setParams({  payments :cmp.get("v.RecieptsList"),size:1 });
        action1.setCallback(this, function(response) 
                            {
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    cmp.set("v.RecieptsList",response.getReturnValue());
                                    if(response.getReturnValue().length==1){
                                        cmp.set("v.removeDisabled",true);
                                    }
                                }
                                cmp.set("v.ASpinner",false);}
                           );
        $A.enqueueAction(action1);
        
    }, checkInstrumentDate:function(component, event, helper)
    
    {debugger;

   component.set("v.dateErrorMsg","");
         debugger;  
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         var threemonth = new Date();
         threemonth.setMonth(threemonth.getMonth() - 3);
         threemonth = $A.localizationService.formatDate(threemonth, "YYYY-MM-DD");
         var dateValues = event.getSource().get("v.value");
         
         if(dateValues < threemonth)
         {
             component.set("v.chequedateValidationError", true);
             component.set("v.dateErrorMsg","Cheque Date cannot be before Last 3 months from today");
             
         }
         else
         {
             component.set("v.chequedateValidationError", false);
             component.set("v.dateErrorMsg","");
             
         }
         
           
    },
    checkInstrumentDate1:function(component, event, helper)
    
    {debugger;

   component.set("v.dateErrorMsg","");
        
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         
         var dateValues = event.getSource().get("v.value");
         
         if(dateValues > today)
         {
             component.set("v.chequedateValidationError", true);
             component.set("v.dateErrorMsg","Card swipe/DD date cannot be future date");
             
         }
         else
         {
             component.set("v.chequedateValidationError", false);
             component.set("v.dateErrorMsg","");
             
         
     }            
    },
    
})