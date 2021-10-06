/**
 * @File Name          : OrderProductsCalloutService
 * @Description        : Callout service for order confirmation
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public without sharing class OrderProductsCalloutService {

    public final static String ENDPOINT_URL = 'https://vadim-assignment.requestcatcher.com';
    
    public static HttpResponse sendConfirmationRequest(String body, String reqType){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_URL);
        req.setMethod(reqType);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setBody(body);
        Http h = new Http();
        return h.send(req);
    }
}
