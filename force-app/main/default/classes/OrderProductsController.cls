/**
 * @File Name          : OrderProductsController
 * @Description        : Methods for ordered products management
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public without sharing class OrderProductsController {

    @AuraEnabled
    public static void upsertOrderItems(String orderItems){
        try {
            List<OrderItem> oItems = (List<OrderItem>)JSON.deserialize(orderItems, List<OrderItem>.class);
            upsert oItems;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage('Error while inserting order items');
            throw auraException;
        }
    }

    @AuraEnabled
    public static void deleteOrderItems(String orderItems){
        try {
            List<OrderItem> oItems = (List<OrderItem>)JSON.deserialize(orderItems, List<OrderItem>.class);
            delete oItems;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage('Error while deleting order items');
            throw auraException;
        }
    }

    @AuraEnabled
    public static String confirmOrder(String requestData){
        try {
            HttpResponse resp = OrderProductsCalloutService.sendConfirmationRequest(requestData, 'POST');
            return JSON.serialize(new ConfirmationResponse(resp.getBody(), resp.getStatusCode()));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateOrderStatus(String orderId, String orderItems){
        try {
            Order confirmedOrder = new Order();
            confirmedOrder.Id = orderId;
            confirmedOrder.Status = 'Activated';
            update confirmedOrder;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage(e.getTypeName());
            throw auraException;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getOrderedProducts(String recordId){
        try {
            List<OrderItem> orderItems = OrderItemDAO.getOrderItemsByOrderId(recordId);
            return JSON.serialize(orderItems);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ConfirmationResponse {
        public String resBody;
        public Integer statusCode;

        public ConfirmationResponse(String resBody, Integer statusCode){
            this.resBody = resBody;
            this.statusCode = statusCode;
        }
    }

    public class OrderProductsControllerException extends Exception {}
}
