public class JsonClsSchedule{
        public String subject;	//Prep for customer meeting
        public cls_body body;
        public cls_start start;
        public cls_end end_end;
        public cls_location location;
        public cls_attendees[] attendees;
        public boolean allowNewTimeProposals;
        public boolean isOnlineMeeting;
        public String onlineMeetingProvider;	//teamsForBusiness
        public String id;
        public cls_onlineMeeting onlineMeeting;
        //public String Comment;
        public class cls_body {
            public String contentType;	//HTML
            public String content;	//Does this time work for you?
            public cls_body(){}
        }
        public class cls_start {
            public String dateTime_start;	//2019-11-20T13:00:00
            public String timeZone;	//Pacific Standard Time
            public cls_start(){}
        }
        public class cls_end {
            public String dateTime_End;	//2019-11-20T14:00:00 string string;
            public String timeZone;	//Pacific Standard Time
            public cls_end(){} 
        }
        public class cls_location {
            public String displayName;	//Cordova conference room
            public cls_location(){}
        }
        public class cls_attendees {
            public cls_emailAddress emailAddress;
            public String type;	//required
            public cls_attendees(){}
        }
        public class cls_emailAddress {
            public String address;	//AdeleV@contoso.OnMicrosoft.com
            public String name;	//Adele Vance
            public cls_emailAddress(){}
        }
        public class cls_onlineMeeting {
            public String joinUrl;
            public String conferenceId;
            public String tollNumber;
            public cls_onlineMeeting(){}
        }
       
    
}