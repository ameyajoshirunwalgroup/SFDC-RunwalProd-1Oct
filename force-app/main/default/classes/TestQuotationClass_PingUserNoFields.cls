@isTest
private class TestQuotationClass_PingUserNoFields {
    @isTest
    static void ping() {
        Id me = UserInfo.getUserId();
        User u = new User(Id = me);
        System.assertNotEquals(null, u.Id);
    }
}