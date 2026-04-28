public with sharing class DocupilotDataCaptureAction {
  private static final String NAMED_CREDENTIAL = 'Docupilot';

  public class Request {
    @InvocableVariable(required=true)
    public String dataCapturePath;

    @InvocableVariable(required=true)
    public DocupilotPayload payload;
  }

  public class Response {
    @InvocableVariable
    public String fileUrl;

    @InvocableVariable
    public String fileName;
  }

  @InvocableMethod(label='Submit Docupilot Data Capture' description='Posts a Docupilot payload to a data capture URL.')
  public static List<Response> submit(List<Request> requests) {
    List<Response> responses = new List<Response>();

    for (Request requestItem : requests) {
      Response responseItem = new Response();
      validateRequest(requestItem);

      HttpRequest httpRequest = new HttpRequest();
      httpRequest.setEndpoint(buildEndpoint(requestItem.dataCapturePath));
      httpRequest.setMethod('POST');
      httpRequest.setHeader('Content-Type', 'application/json');
      httpRequest.setHeader('Accept', 'application/json');
      httpRequest.setBody(JSON.serialize(requestItem.payload.toMap()));

      Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);
      populateResponse(responseItem, httpResponse);

      responses.add(responseItem);
    }

    return responses;
  }

  private static void validateRequest(Request requestItem) {
    if (requestItem == null) {
      throw new DocupilotActionException('Request cannot be null.');
    }

    if (String.isBlank(requestItem.dataCapturePath)) {
      throw new DocupilotActionException('dataCapturePath is required.');
    }

    if (requestItem.payload == null) {
      throw new DocupilotActionException('payload is required.');
    }
  }

  private static String buildEndpoint(String dataCapturePath) {
    String normalizedPath = normalizePath(dataCapturePath);
    return 'callout:' + NAMED_CREDENTIAL + normalizedPath;
  }

  private static String normalizePath(String dataCapturePath) {
    String trimmed = dataCapturePath == null ? null : dataCapturePath.trim();
    if (String.isBlank(trimmed)) {
      return '';
    }

    Integer protocolIndex = trimmed.indexOf('://');
    if (protocolIndex >= 0) {
      Integer pathStartIndex = trimmed.indexOf('/', protocolIndex + 3);
      trimmed = pathStartIndex >= 0 ? trimmed.substring(pathStartIndex) : '/';
    }

    return trimmed.startsWith('/') ? trimmed : '/' + trimmed;
  }

  private static void populateResponse(Response responseItem, HttpResponse httpResponse) {
    if (httpResponse == null) {
      return;
    }

    String responseBody = httpResponse.getBody();
    if (String.isBlank(responseBody)) {
      return;
    }

    Object deserialized = JSON.deserializeUntyped(responseBody);
    if (!(deserialized instanceof Map<String, Object>)) {
      return;
    }

    Map<String, Object> responseMap = (Map<String, Object>) deserialized;
    Object dataValue = responseMap.get('data');
    if (dataValue instanceof Map<String, Object>) {
      Map<String, Object> dataMap = (Map<String, Object>) dataValue;
      responseItem.fileUrl = stringValue(dataMap.get('file_url'));
      responseItem.fileName = stringValue(dataMap.get('file_name'));
    }
  }

  private static String stringValue(Object value) {
    return value == null ? null : String.valueOf(value);
  }

  public class DocupilotActionException extends Exception {
  }
}