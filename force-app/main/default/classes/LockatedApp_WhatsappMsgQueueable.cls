//public class LockatedApp_WhatsappMsgQueueable implements Queueable, Database.AllowsCallouts{

global class LockatedApp_WhatsappMsgQueueable implements Database.Batchable<ParameterWrap>, Database.AllowsCallouts {

    list<ParameterWrap> wrapList;

    public LockatedApp_WhatsappMsgQueueable(List<ParameterWrap> wrapList) {
        this.wrapList = wrapList;
    }

    /*public void execute(QueueableContext qc) {
        for(ParameterWrap wrap : wrapList){
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(wrap.param1,wrap.param2,wrap.param3,wrap.param4,wrap.param5,wrap.param6,wrap.param7,wrap.param8,wrap.param9,wrap.param10,wrap.param11,wrap.param12); 
            }
        }
    }*/

    

        global Iterable<ParameterWrap> start(Database.BatchableContext bc){
            return wrapList;
        }
    
        global void execute(Database.BatchableContext bc, List<ParameterWrap> scope){

            for(ParameterWrap wrap : scope){
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(wrap.param1,wrap.param2,wrap.param3,wrap.param4,wrap.param5,wrap.param6,wrap.param7,wrap.param8,wrap.param9,wrap.param10,wrap.param11,wrap.param12); 
                }
            }
        }
    
        global void finish(Database.BatchableContext bc) {}
    

    public static ParameterWrap wrapper(String param1,String param2,String param3,String param4,String param5,String param6,String param7,String param8,String param9,String param10,String param11,String param12) {
        ParameterWrap wrap = new ParameterWrap();
        wrap.param1 =  param1;
        wrap.param2 =  param2;
        wrap.param3 =  param3;
        wrap.param4 =  param4;
        wrap.param5 =  param5;
        wrap.param6 =  param6;
        wrap.param7 =  param7;
        wrap.param8 =  param8;
        wrap.param9 =  param9;
        wrap.param10 =  param10;
        wrap.param11 =  param11;
        wrap.param12 =  param12;
        return wrap;
    }

    global class ParameterWrap{
        public String param1;
        public String param2;
        public String param3;
        public String param4;
        public String param5;
        public String param6;
        public String param7;
        public String param8;
        public String param9;
        public String param10;
        public String param11;
        public String param12;
    }
}