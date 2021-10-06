/**
 * @File Name          : HttpMockupService
 * @Description        : Http Mock Service
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public class HttpMockupService implements HttpCalloutMock{
    protected Integer statusCode;
    protected String responseBody;
    
    public HttpMockupService(String responseBody, Integer statusCode) {
    	this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
    
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(this.responseBody);
        response.setStatusCode(this.statusCode);

        return response;
    }
}
