@isTest
public class AccountHelperTest {
    @isTest
    static void testGreeting() {
        String result1 = AccountHelper.getGreeting('Rama');
        String result2 = AccountHelper.getGreeting('');
        
        System.assertEquals('Hello Rama', result1);
        System.assertEquals('Hello Guest', result2);
    }
}