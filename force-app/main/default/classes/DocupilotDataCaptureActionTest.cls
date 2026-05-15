@IsTest
private class DocupilotDataCaptureActionTest {
  private class SuccessMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      System.assertEquals('POST', request.getMethod());
      System.assertEquals('application/json', request.getHeader('Content-Type'));
      System.assertEquals('callout:Docupilot/dashboard/documents/create/123/abc', request.getEndpoint());

      Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(request.getBody());
      System.assertEquals('alice@example.com', (String) requestBody.get('Email_Address'));

      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('{"status":"success","data":{"file_url":"https://files.example.com/doc.pdf","file_name":"doc.pdf"}}');
      return response;
    }
  }

  private class FailureMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(400);
      response.setBody('{"status":"error"}');
      return response;
    }
  }

  @IsTest
  static void submitReturnsSuccessResponse() {
    Test.setMock(HttpCalloutMock.class, new SuccessMock());

    DocupilotPayload payload = new DocupilotPayload();
    payload.emailAddress = 'alice@example.com';

    DocupilotDataCaptureAction.Request requestItem = new DocupilotDataCaptureAction.Request();
    requestItem.dataCapturePath = '/dashboard/documents/create/123/abc';
    requestItem.payload = payload;

    Test.startTest();
    List<DocupilotDataCaptureAction.Response> responses =
      DocupilotDataCaptureAction.submit(new List<DocupilotDataCaptureAction.Request>{ requestItem });
    Test.stopTest();

    System.assertEquals(1, responses.size());
    System.assertEquals('https://files.example.com/doc.pdf', responses[0].fileUrl);
    System.assertEquals('doc.pdf', responses[0].fileName);
  }

  @IsTest
  static void submitReturnsFailureResponseForHttpErrors() {
    Test.setMock(HttpCalloutMock.class, new FailureMock());

    DocupilotPayload payload = new DocupilotPayload();
    payload.emailAddress = 'alice@example.com';

    DocupilotDataCaptureAction.Request requestItem = new DocupilotDataCaptureAction.Request();
    requestItem.dataCapturePath = 'https://example.docupilot.app/dashboard/documents/create/123/abc';
    requestItem.payload = payload;

    Test.startTest();
    List<DocupilotDataCaptureAction.Response> responses =
      DocupilotDataCaptureAction.submit(new List<DocupilotDataCaptureAction.Request>{ requestItem });
    Test.stopTest();

    System.assertEquals(1, responses.size());
    System.assertEquals(null, responses[0].fileUrl);
    System.assertEquals(null, responses[0].fileName);
  }

  @IsTest
  static void submitThrowsValidationErrors() {
    DocupilotDataCaptureAction.Request requestItem = new DocupilotDataCaptureAction.Request();
    requestItem.dataCapturePath = '';

    try {
      DocupilotDataCaptureAction.submit(new List<DocupilotDataCaptureAction.Request>{ requestItem });
      System.assert(false, 'Expected DocupilotActionException to be thrown');
    } catch (DocupilotDataCaptureAction.DocupilotActionException ex) {
      System.assertEquals('dataCapturePath is required.', ex.getMessage());
    }
  }
}