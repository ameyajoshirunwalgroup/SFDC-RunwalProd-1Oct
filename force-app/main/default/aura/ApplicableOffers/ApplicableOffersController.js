({
	 doInit:function(component){
       
       //console.log('**'+component.get("v.OfferRecord"));
         component.set('v.columns', [
            {label: 'Offer Name', fieldName: 'RW_Offer_Name__c', type: 'text'},
            {label: 'Sub Offer Name', fieldName: 'RW_Sub_Offer_Name__c', type: 'text'},
            {label: 'Valid Till', fieldName: 'RW_End_Date__c', type: 'date'},
            
        ]);
    
        
     }
    
})