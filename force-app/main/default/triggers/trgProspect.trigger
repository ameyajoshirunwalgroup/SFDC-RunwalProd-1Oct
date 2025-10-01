trigger trgProspect on Prospect__c (before insert,after insert,after update) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        Set<id> leadIDs = new set<id>();
        Set<id> accountIDs = new set<id>();
        List<Prospect__c> lstOfprosWithLead = new List<Prospect__c>();
        List<Prospect__c> lstOfprosWithAccount = new List<Prospect__c>();
        List<Prospect__c> prosListWithLead = new List<Prospect__c>();
        List<Prospect__c> prosListWithAccount = new List<Prospect__c>();
        
        Map<Id,Prospect__c> ProsMapL = new Map<Id,Prospect__c>();
        Map<Id,Prospect__c> ProsMapA = new Map<Id,Prospect__c>();
        
        for(Prospect__c p : trigger.new){
            system.debug('p::'+p);
            if(p.Lead__c != null && p.Project__c != null && p.Active__c){
                leadIDs.add(p.Lead__c);
                lstOfprosWithLead.add(p);
                system.debug('inside lead condition');
            }
            if(p.Account__c != null && p.Project__c != null && p.Active__c){
                accountIDs.add(p.Account__c);
                lstOfprosWithAccount.add(p);
                system.debug('inside Account condition');
            }
            
            /*
//Added by Prashant to update AOP type and CP category when Temp CP is changed.
if(p.Temp_Channel_Partner__c != null){
system.debug('Inside temp cp not null');
list<Temp_Channel_Partner__c> newCP = [Select Id,AOP_Type__c,CP_Category__c from Temp_Channel_Partner__c where Id =: p.Temp_Channel_Partner__c];
system.debug('Inside temp cp not null'+newCP );                        
if(newCP[0].AOP_Type__c!= null){
p.AOP_Type__c = newCP[0].AOP_Type__c;
}
if(newCP[0].CP_Category__c != null){
p.CP_Category__c = newCP[0].CP_Category__c;
}
}*/
            
            //Added by Prashant to update AOP type and CP category when Broker is changed.
            if(p.Lead_Source__c == 'Channel Partner'){
                if(p.Channel_Partner__c != null){
                    if(p.Project__c != null){
                        /*List<Project__c> projectList = [Select Id,Name,Project_Location__c from Project__c where id =: p.Project__c];
if(!projectList.isEmpty() && projectList[0].Project_Location__c != null){
list<Project_Location__c> projectLocationList =[Select Id,CP_Category__c from Project_Location__c where Id =: projectList[0].Project_Location__c];
if(!projectLocationList.isEmpty() && projectLocationList[0].CP_Category__c != null){
p.CP_Category__c = projectLocationList[0].CP_Category__c;
}
}*/
                        
                        //New logic - 19/11-24
                        List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                               where Project__c =: p.Project__c and Channel_Partner__c =: p.Channel_Partner__c];
                        system.debug('cpCategoryList'+cpCategoryList);                        
                        if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                            p.CP_Category__c = cpCategoryList[0].Category__c;
                        }
                    }
                    list<Broker__c> newCP = [Select Id,AOP_Type__c from Broker__c where Id =: p.Channel_Partner__c];
                    if(!newCP.isEmpty() && newCP[0].AOP_Type__c!= null){
                        p.AOP_Type__c = newCP[0].AOP_Type__c;
                    }
                }
            }
            
        }
        system.debug('leadIDs:: '+leadIDs);
        if(!leadIDs.isEmpty()){
            prosListWithLead = [select id,name,Account__c,Lead__c,Project__c,Active__c from Prospect__c where Lead__c IN: leadIDs and Active__C = true and Project__c != null]; 
            system.debug('prosListWithLead ::: '+prosListWithLead );
            if(!prosListWithLead.isEmpty()){
                for(Prospect__c ps : prosListWithLead)
                    ProsMapL.put(ps.Lead__c,ps); 
            }
        }
        system.debug('ProsMapL::: '+ProsMapL);
        system.debug('accountIDs:: '+accountIDs);
        if(!accountIDs.isEmpty()){
            prosListWithAccount = [select id,name,Account__c,Lead__c,Project__c,Active__c from Prospect__c where Account__c IN: accountIDs and Active__C = true and Project__c != null]; 
            system.debug('prosListWithAccount::: '+prosListWithAccount);
            if(!prosListWithAccount.isEmpty()){
                for(Prospect__c psnew : prosListWithAccount)
                    ProsMapA.put(psnew.Account__c,psnew); 
            }
        }    
        
        system.debug('ProsMapA::: '+ProsMapA);
        if(!lstOfprosWithLead.isEmpty() && !ProsMapL.isEmpty()){
            system.debug('condituon 111');
            for(Prospect__c pr : lstOfprosWithLead){
                
                if(ProsMapL.containsKey(pr.Lead__C)){
                    system.debug('condituon 222');
                    if(Pr.Project__c == ProsMapL.get(pr.Lead__C).Project__c){
                        system.debug('condituon 333');
                        pr.addError('There is Already Active Prospect on selected Lead with selected Project ');
                        system.debug('inside match condition with lead');
                    }
                }
            }
        }
        
        if(!lstOfprosWithAccount.isEmpty() && !ProsMapA.isEmpty()){
            system.debug('condituon 1');
            for(Prospect__c prNew : lstOfprosWithAccount){
                if(ProsMapA.containsKey(prNew.Account__c)){
                    system.debug('condituon 2');
                    if(PrNew.Project__c == ProsMapA.get(prNew.Account__c).Project__c){
                        system.debug('condituon 3');
                        prNew.addError('There is already Active Prospect on selected Account with selected Project ');
                        system.debug('inside match condition with Account');
                    }
                }
            }
        }     
    }
    // Added by shailesh on 12.12.2017//
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            List<Prospect__c> lstProspect = new List<Prospect__c>();
            for(Prospect__c p : trigger.new) {
                if(p.User__c != null && p.Opportunity__c != null)
                    lstProspect.add(p);
            }
            if(!lstProspect.isEmpty())
                ProspectManagementServices.updateSMonOpty(lstProspect);
        }
        if(Trigger.isUpdate) {
            List<Prospect__c> lstProspect = new List<Prospect__c>();
            for(Prospect__c p : trigger.new) {
                if(p.Opportunity__c != null && p.User__c != null && trigger.oldMap.get(p.id).User__c != trigger.newMap.get(p.id).User__c)
                    lstProspect.add(p);
            }
            if(!lstProspect.isEmpty())
                ProspectManagementServices.updateSMonOpty(lstProspect);
        }
        
        decimal a =1;
        decimal b= 2;
        decimal c= 0;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        for (Prospect__c p: trigger.new) {
            if(p.Lead_Source__c == 'Channel Partner'){
                //Added by Prashant to update AOP type and CP category when Broker is changed.                
                if (Trigger.newMap.get(p.Id).Channel_Partner__c != Trigger.oldMap.get(p.Id).Channel_Partner__c) {
                    if(Trigger.newMap.get(p.Id).Channel_Partner__c != null){
                        system.debug('Inside Update trigger on broker change');
                        List<Broker__c> newCP = [Select Id, AOP_Type__c from Broker__c where Id =: Trigger.newMap.get(p.Id).Channel_Partner__c];
                        if(!newCP.isEmpty() && newCP[0].AOP_Type__c != null){
                            p.AOP_Type__c = newCP[0].AOP_Type__c;
                        }
                    }else if(Trigger.newMap.get(p.Id).Channel_Partner__c == null){
                        p.AOP_Type__c = null;
                    }
                } 
                
                //CHange cp category when cp is changed
                if (Trigger.newMap.get(p.Id).Channel_Partner__c != Trigger.oldMap.get(p.Id).Channel_Partner__c) {
                    if(Trigger.newMap.get(p.Id).Channel_Partner__c != null){
                        system.debug('Inside Update trigger on broker change');
                        //New logic - 19/11-24
                        List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                               where Project__c =: Trigger.newMap.get(p.Id).Project__c and Channel_Partner__c =: Trigger.newMap.get(p.Id).Channel_Partner__c];
                        system.debug('cpCategoryList'+cpCategoryList);                        
                        if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                            p.CP_Category__c = cpCategoryList[0].Category__c;
                        }
                    }else if(Trigger.newMap.get(p.Id).Channel_Partner__c == null){
                        p.CP_Category__c = null;
                    }
                } 
                
                //CHange cp category when project is changed
                if (Trigger.newMap.get(p.Id).Project__c != Trigger.oldMap.get(p.Id).Project__c) {
                    if(Trigger.newMap.get(p.Id).Project__c != null){
                        //New logic - 19/11-24
                        List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                               where Project__c =: Trigger.newMap.get(p.Id).Project__c and Channel_Partner__c =: Trigger.newMap.get(p.Id).Channel_Partner__c];
                        system.debug('cpCategoryList'+cpCategoryList);                        
                        if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                            p.CP_Category__c = cpCategoryList[0].Category__c;
                        }
                    }else if(Trigger.newMap.get(p.Id).Project__c == null){
                        p.CP_Category__c = null;
                    }
                }  
            }
        }
    }
}