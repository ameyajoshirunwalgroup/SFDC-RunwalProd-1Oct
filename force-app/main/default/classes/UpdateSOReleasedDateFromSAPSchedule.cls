public class UpdateSOReleasedDateFromSAPSchedule implements Schedulable {
	public void execute(SchedulableContext dc) {
        //UpdateSOReleasedDateFromSAP b = new UpdateSOReleasedDateFromSAP();
        UpdateSOReleasedDateFromSAP.updateSOReleased();
    }
}