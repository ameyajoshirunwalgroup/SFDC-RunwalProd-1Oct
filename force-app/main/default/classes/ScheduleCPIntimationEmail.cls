global class ScheduleCPIntimationEmail implements Schedulable {

    global void execute(SchedulableContext sc) {
        sendEmails();
    }

    public static void sendEmails() {

        List<Broker__c> cpList = [
            Select id,Name,RW_Email__c,RW_Mobile_No__c from Broker__c where RW_Mobile_No__c = '8766529867'
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Broker__c cp : cpList) {

            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setToAddresses(new List<String>{ cp.RW_Email__c });
                mail.setSubject('Introducing Runwal Elevate App 🚀');

                String body = 'Hi ' + cp.Name + ',<br><br>';
                body += 'We are delighted to introduce <b>Runwal Elevate</b> — our brand-new app designed exclusively for our Channel Partners.<br><br>';

                body += '🏢 <b>Project Details</b> — Explore all projects in one place.<br>';
                body += '📄 <b>Offers & Brochures</b> — Download and share instantly.<br>';
                body += '💰 <b>Billings & Invoices</b> — Access anytime.<br>';
                body += '📊 <b>Payout Tracking</b> — Track earnings in real time.<br><br>';

                body += '<b>Download the App</b><br>';
                body += '▶ Google Play: https://play.google.com/store/apps/details?id=com.lockated.runwal.cp<br>';
                body += 'App Store: https://apps.apple.com/in/app/runwal-elevate/id6758725386<br><br>';

                body += '<b>Your Login Credentials</b><br>';
                body += '✉ Email: ' + cp.RW_Email__c + '<br>';
                body += '📱 Phone: ' + cp.RW_Mobile_No__c + '<br>';
                body += '🔒 Default Password: runwal@1234<br><br>';

                body += '⚠ Please change your password after first login.<br><br>';
                body += 'Regards,<br>Team Runwal';

                mail.setHtmlBody(body);

                emails.add(mail);

            } catch (Exception e) {
                System.debug('Error for CP: ' + cp.Id + ' - ' + e.getMessage());
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}