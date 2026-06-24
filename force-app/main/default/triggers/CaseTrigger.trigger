trigger CaseTrigger on Case (before update,before insert) {
    if(checkRecursion.isFirstRunA()){
    	CaseCommentHistoryHandler.updateCommentHistory(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }
}