@RestResource(urlMapping='/holidays/*')
global class LockatedApp_Holidays {
    
    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        //List<Holiday> holidays = [SELECT Id, Name, ActivityDate FROM Holiday ORDER BY ActivityDate];
        /*String jsonBody = req.requestBody.toString();
        DateRange reqData = (DateRange)JSON.deserialize(jsonBody, DateRange.class);
        Date startDate = Date.valueOf(reqData.start_date);
        Date endDate = Date.valueOf(reqData.end_date);*/
        Holidays holidaysList = new Holidays();
        List<Day> days = new List<Day>();
        
        //Date dt1 = Date.newInstance(2025, 01, 01);
        //Date dt2 = Date.newInstance(2025, 12, 31);
        Date todayDate = Date.today();
        Date startOfYear = Date.newInstance(todayDate.year(), 1, 1);
        Date endOfYear = Date.newInstance(todayDate.year(), 12, 31);
        Map<Date, Holiday> holidaysMap = getHolidaysForDates(startOfYear,endOfYear);
        //Map<Date, Holiday> holidaysMap = getHolidaysForDates(startDate,endDate);
        
        for(Date dt : holidaysMap.keySet()){
            Day d = new Day();
            d.holiday_name = holidaysMap.get(dt).Name;
            d.holiday_date = String.valueOf(dt);
            days.add(d);
        }
        
        holidaysList.holidays = days;
        res.responseBody = Blob.valueOf(JSON.serialize(days));
        res.statusCode = 200;
    }
    
       
    public static Map<Date, Holiday> getHolidaysForDates(Date startDate, date endDate){
        Map<Date, Holiday> toReturn = new Map<Date, holiday>();
        List<Date> dates = new List<Date>();
        List<Holiday> holidays = [select id, name, ActivityDate, Description, EndTimeInMinutes, IsAllDay, IsRecurrence, RecurrenceDayOfMonth, RecurrenceDayOfWeekMask, RecurrenceEndDateOnly, 
                                    RecurrenceInstance, RecurrenceInterval, RecurrenceMonthOfYear, RecurrenceStartDate, RecurrenceType, StartTimeInMinutes FROM Holiday
                                    WHERE IsRecurrence = true OR ActivityDate = THIS_YEAR];

        for (Holiday h : holidays){
            if (h.RecurrenceType == 'RecursYearlyNth'){
                dates = getYearlyNthHoliday(h, startDate, endDate);
            }else if (h.RecurrenceType == 'RecursYearly'){
                dates = getYearlyHoliday(h, startDate, endDate);
            }else if (h.RecurrenceType == 'RecursMonthlyNth'){
                //dates = getMonthlyNthHoliday(h, startDate, endDate);
            }else if (h.RecurrenceType == 'RecursMonthly'){
                dates = getMonthlyHoliday(h, startDate, endDate);
            }else if (h.RecurrenceType == 'RecursWeekly'){
                dates = getWeeklyHoliday(h, startDate, endDate);
            }else if (h.RecurrenceType == 'RecursDaily'){
                dates = getDailyHoliday(h, startDate, endDate);
            }else if(h.RecurrenceType == null){
                dates = getNoRecurrenceHolidays(h, startDate, endDate);
            }
                
            for (Date d : dates)
                toReturn.put(d, h);
        }
        System.debug('dates: ' + dates);
        return toReturn;
    }
    
    public static List<Date> getNoRecurrenceHolidays(Holiday h, date startDate, date endDate){//recurs on set days in a year, like Christmas, New Years 
        List<Date> toReturn = new List<Date>();
        Map<String, Integer> monthMap = getMonthMap();
        for (Integer year : getYears(startDate, EndDate)){
            Integer month = monthMap.get(h.RecurrenceMonthOfYear);
            Date d = h.ActivityDate;
            System.debug('d: ' + d);
            System.debug('startDate: ' + startDate);
            System.debug('endDate: ' + endDate);
            if (d >= startDate && d <= endDate){
                System.debug('d: ' + d);
                System.debug('startDate: ' + startDate);
                System.debug('endDate: ' + endDate);
                toReturn.add(d);
            }
                
        }
        System.debug('toReturn: ' + toReturn);
        return toReturn;
    }
    
    public static List<Date> getYearlyHoliday(Holiday h, date startDate, date endDate){//recurs on set days in a year, like Christmas, New Years 
        List<Date> toReturn = new List<Date>();
        Map<String, Integer> monthMap = getMonthMap();
        for (Integer year : getYears(startDate, EndDate)){
            Integer month = monthMap.get(h.RecurrenceMonthOfYear);
            Date d = date.newInstance(year, month, h.RecurrenceDayOfMonth);
            System.debug('d: ' + d);
            System.debug('startDate: ' + startDate);
            System.debug('endDate: ' + endDate);
            if (d >= startDate && d <= endDate){
                System.debug('d: ' + d);
                System.debug('startDate: ' + startDate);
                System.debug('endDate: ' + endDate);
                toReturn.add(d);
            }
                
        }
        System.debug('toReturn: ' + toReturn);
        return toReturn;
    }

    public static List<Date> getYearlyNthHoliday(Holiday h, date startDate, date endDate){//recurs on something like 2nd tuesday of march - Thanksgiving, MLK day, Columbus Day
        List<Date> toReturn = new List<Date>();

        Map<Integer, Integer> maskedDayMap = getBitMaskMap();
        Map<String, Integer> monthMap = getMonthMap();
        Map<String, Integer> weekMap = getWeekMap();

        Integer day = maskedDayMap.get(h.RecurrenceDayOfWeekMask);
        Integer month = monthMap.get(h.RecurrenceMonthOfYear);
        for (Integer year : getYears(startDate, EndDate)){
            Date d;
            if (h.RecurrenceInstance == 'Last')
                d = getLastXOfMonth(day, month, year);
            else{
                Integer week = weekMap.get(h.RecurrenceInstance);
                d = getXDayOfMonth(week, day, date.newInstance(year, month, 2));
            }
            if (d > startDate && d < endDate)
                toReturn.add(d);
        }
        return toReturn;
    }


    public static List<Date> getMonthlyHoliday(Holiday h, date startDate, date endDate){//recurs on set day of every month - something like 5th of every month
        List<Date> toReturn = new List<Date>();
        for (Date d : getMonths(startDate, endDate)){
            Date da = date.newInstance(d.year(), d.month(), h.RecurrenceDayOfMonth);
            if (da > startDate && da < endDate)
                toReturn.add(da);
        }
        return toReturn;
    }
    /*public static List<Date> getMonthlyNthHoliday(Holiday h, date startDate, date endDate){//recurs monthly - something like every second sunday
        List<Date> toReturn = new List<Date>();

        List<Date> months = getMonths(startDate, endDate);
        Integer day = getBitMaskMap().get(h.RecurrenceDayOfWeekMask);

        Integer week = getWeekMap().get(h.RecurrenceInstance);
        for (date month : months){
            Date d;
             if (h.RecurrenceInstance == 'Last')
                    d = getLastXOfMonth(day, month.month(), month.year());
            else
                d = getXDayOfMonth(week, day, date.newInstance(month.year(), month.month(), 1));
            if (d > startDate && d < endDate)
                toReturn.add(d);
        }
       return toReturn;
    }*/
    public static List<Date> getWeeklyHoliday(Holiday h, date startDate, date endDate){//something like every sat, sun or tues
        List<Date> toReturn = new List<Date>();
        Integer day = getBitMaskMap().get(h.RecurrenceDayOfWeekMask);
        Map<String, Integer> wMap = createDayOfWeekMap();
        DateTime d = datetime.newInstance(startDate.year(), startdate.month(), startDate.day(), 0, 0, 0);//valueOf(startDate);
        while (wMap.get(d.format('EEEE')) != day)
            d = d.addDays(1);
        while (d < endDate){
            if (d > startDate && d < endDate)
                toReturn.add(date.valueOf(d));
            d = d.addDays(7);
        }
        return toReturn;
    }
    public static List<Date> getDailyHoliday(Holiday h, date startDate, date endDate){//something like every 15 days from start
        List<Date> toReturn = new List<Date>();
        Integer remainder;
        Date dailyDate = startDate.addDays(-1);

        while (remainder != 0){
            dailyDate = dailyDate.addDays(1);
            remainder = math.mod(h.RecurrenceStartDate.daysBetween(dailyDate), h.RecurrenceInterval);
        }
        toReturn.add(dailyDate);
        while (dailyDate < endDate){
            dailyDate = dailyDate.addDays(h.RecurrenceInterval);
            if (dailyDate > startDate && dailyDate < endDate)
                toReturn.add(dailyDate);
        }
        return toReturn;
    }


    public static Date getLastXOfMonth(Integer dayOfWeek, Integer month, Integer year){
        Map<String, Integer> DayOfWeekMap = createDayofWeekMap();
        DateTime lastMonthDate = DateTime.newInstance(year, month + 1, 0, 0, 0, 0);
        Integer day = DayOfWeekMap.get(lastMonthDate.format('EEEE'));

        while(day != dayOfWeek){
            lastMonthDate = lastMonthDate.addDays(-1);
            day = DayOfWeekMap.get(lastMonthDate.format('EEEE'));
        }
        return Date.valueOf(lastMonthDate);
    }

    public static Date getXDayOfMonth(Integer week, Integer day, date monthIn){
        Map<String, Integer> DayOfWeekMap = createDayofWeekMap();
        DateTime firstMonthDate = DateTime.newInstance(monthIn.year(), monthIn.month(), 0, 0, 0, 0);

        Integer dayName;
        while(dayName != day){
            firstMonthDate = firstMonthDate.addDays(1);
            dayName = DayOfWeekMap.get(firstMonthDate.format('EEEE'));
        }
        if (week == 1)
            return date.valueOf(firstMonthDate);
        else
            return date.valueOf(firstMonthDate.addDays(7 * (week - 1)));  
    }

public static Map<String, Integer> createDayOfWeekMap(){
    return new Map<String, Integer>{'Sunday' => 1, 'Monday' => 2, 'Tuesday' => 3, 'Wednesday' => 4, 'Thursday' => 5, 'Friday' => 6, 'Saturday' => 7};
}
public static List<Date> getMonths(Date startDate, Date endDate){
        List<Date> months = new List<Date>();
        Date m = date.newInstance(startDate.year(), startDate.month(), 1);
        months.add(m);
        if (startDate.month() != endDate.month() || startDate.year() != endDate.year()){
            while (m.monthsBetween(endDate) != 0){
                m = m.addMonths(1);
                months.add(m);
            }
        }
        return months;
    }

 public static List<Integer> getYears(date startDate, date endDate){
        List<Integer> years = new List<Integer>();
        Integer y = startDate.year();
        years.add(y);
        if (startDate.year() != endDate.year()){
            while (y != endDate.year()){
                y = y + 1;
                years.add(y);
            }
        }
        return years;
    }
    
    public static Map<Integer, Integer> getBitMaskMap(){
        return new Map<Integer, Integer>{1 => 1, 2 => 2, 4 => 3, 8 => 4, 16 => 5, 32 => 6, 64 => 7};//1 =  1 - Sunday, 2 = 2 Monday, 4 = 3 Tuesday, /8 = 4 Wednesday, 16 = 5 Thursday, 32 = 6 Friday, 64 = 7 Saturday
    }
    public static Map<String, Integer> getMonthMap(){
        return new Map<String, Integer>{'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6, 'July' => 7, 'August' => 8, 'September' => 9,
        'October' => 10, 'November' => 11, 'December' => 12};
    }
    public static Map<String, Integer> getWeekMap(){return new Map<String, Integer>{'First' => 1, 'Second' => 2, 'Third' => 3, 'Fourth' => 4, 'Fifth' => 5};}
    
    global class Holidays{
        public List<Day> holidays;
    }
    
    public class Day{
        public String holiday_name;
        public String holiday_date;
    }
    
    global class DateRange{
        public String start_date;
        public String end_date;
    }
}