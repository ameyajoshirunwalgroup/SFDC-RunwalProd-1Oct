trigger RegistrationScheduleTrigger on Registration_Schedule__c (before insert, before update) {
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        List<Id> rsIds = new List<Id>();
        List<Id> bkgIds = new List<Id>();
        Map<Id,Date> bkgVsSchDate = new Map<Id,Date>();
        
        for(Registration_Schedule__c rs : trigger.new){
            rsIds.add(rs.Id);
            bkgIds.add(rs.Booking__c);
            rs.Active__c = true;
            bkgVsSchDate.put(rs.Booking__c, rs.Registration_Schedule_Date__c);
        }
        if(bkgIds.size() > 0){
            Map<Id, Booking__c> bkgsMap = new Map<Id, Booking__c>([SELECT Id, RW_Project_Name__c, Primary_Applicant_Email__c, RW_Registration_Status__c, Opportunity__r.RW_Email__c, Primary_Applicant_Name__c, Status__c FROM Booking__c WHERE Id =: bkgIds]);
            System.debug('bkgIds: ' + bkgIds);
            System.debug('bkgsMap: ' + bkgsMap);
            if(rsIds.size() > 0 && bkgsMap.size() > 0){
                Map<String, Project_Location_Address__c> addressMap = Project_Location_Address__c.getall();
                for(Registration_Schedule__c rs : trigger.new){
                    rs.Customer_Email__c = bkgsMap.get(rs.Booking__c).Opportunity__r.RW_Email__c;
                    rs.Customer_Name__c = bkgsMap.get(rs.Booking__c).Primary_Applicant_Name__c;
                    for(Project_Location_Address__c addr : addressMap.values()){
                        /*if(bkgsMap.get(rs.Booking__c).RW_Project_Name__c == addr.Project__c && rs.Venue__c == addr.Location__c){
                            rs.Address__c = addr.Address__c;
                        }*/
                        if(rs.Venue__c == addr.Location__c){
                            rs.Address__c = addr.Address__c;
                        }
                    }
                    if(bkgsMap.get(rs.Booking__c).RW_Registration_Status__c == 'Registration Completed'){
                        rs.addError('Registration already completed');
                    }
                    /*if(bkgsMap.get(rs.Booking__c).RW_Project_Name__c != '7 Mahalaxmi'){
                        rs.addError('Registration Schedule can not be created for this Project');
                    }*/
                }
                List<Registration_Schedule__c> rsList = [SELECT Id, Booking__c FROM Registration_Schedule__c WHERE Booking__c =: bkgIds AND Active__c = true];
                System.debug('rsList: ' + rsList);
                if(rsList.size() > 0){
                    Map<String, List<Registration_Schedule__c>> bkgVsRsMap = new Map<String, List<Registration_Schedule__c>>();
                    for(Registration_Schedule__c rs : rsList){
                        if(bkgVsRsMap.get(rs.Booking__c) != null){
                            bkgVsRsMap.get(rs.Booking__c).add(rs);
                        }else{
                            bkgVsRsMap.put(rs.Booking__c, new List<Registration_Schedule__c>{rs});
                        }
                    }
                    List<Registration_Schedule__c> rsToInactive = new List<Registration_Schedule__c>();
                    for(String bkgId : bkgVsRsMap.keySet()){
                        for(Registration_Schedule__c rs : bkgVsRsMap.get(bkgId)){
                            if(!rsIds.contains(rs.Id)){
                                rs.Active__c = false;
                                rsToInactive.add(rs);
                            }
                        }
                    }
                    if(rsToInactive.size() > 0){
                        update rsToInactive;
                    }
                    
                    if(bkgVsSchDate.keySet().size() > 0){
                        List<Booking__c> bkgs = new List<Booking__c>();
                        for(String bkgId : bkgVsSchDate.keySet()){
                            Booking__c bkg = new Booking__c();
                            bkg.Id = bkgId;
                            bkg.RW_Schedule_Registration_Date__c = bkgVsSchDate.get(bkgId);
                            bkgs.add(bkg);
                        }
                        update bkgs;
                    }
                }
                
            }else{
                //throw new CommonException('Registration Schedule can not be created for this Project');
            }
            
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> bkgIds = new Set<Id>();
        for(Registration_Schedule__c rs : Trigger.new){
            bkgIds.add(rs.Booking__c);
            
        }
        if(bkgIds.size() > 0){
            Map<Id, Booking__c> bkgMap = new Map<Id, Booking__c>([SELECT Id, RW_Registration_Status__c FROM Booking__c WHERE Id =: bkgIds]);
            for(Registration_Schedule__c rs : Trigger.new){
                if(bkgMap.get(rs.Booking__c).RW_Registration_Status__c == 'Registration Completed'){
                    rs.addError('Registration already completed.');
                }
            }
        }
    }
    
    
}