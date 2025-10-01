@isTest
global class CreateUserWhenUnitBookedMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
        
        Map<String,String> data = new Map<String,String>();
        data.put('account_id', 'Test');
        data.put('firstname', 'Test');
        data.put('lastname', 'T');
        data.put('email', 'test@mail.com');
        data.put('number', '5874589658');
        data.put('flat', 'T2-1303');
        data.put('tower', 'A');
        data.put('customer_code', '20011295');
        data.put('booking_number', '20011295');
        data.put('society_id', '3492');
        data.put('country_code', '+91');
        data.put('country_code_name', 'in');
        data.put('status', '1');
        data.put('ownership', 'owner');
        data.put('is_primary', '1');
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.Serialize(data));
        response.setStatusCode(200);
        return response; 
    }
}