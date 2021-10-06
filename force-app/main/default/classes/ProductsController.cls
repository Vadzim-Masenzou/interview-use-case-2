/**
 * @File Name          : OrderProductsController
 * @Description        : Methods for available products management
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public with sharing class ProductsController {
    
    @AuraEnabled(cacheable=true)
    public static String getAvailableProducts(String recordId, Integer offset, Integer rowLimit){
        try {
            List<PricebookEntry> productsList = new List<PricebookEntry>();
            String orderPricebookId = OrderDAO.getOrderPricebookId(recordId);
            if(orderPricebookId!= null){
                productsList = PricebookEntryDAO.getPricebookEntriesByPb(orderPricebookId, offset, rowLimit).values();
                if(productsList.isEmpty() && offset == 0){
                    throw new ProductsControllerException('No active products available');
                }
            } else {
                throw new ProductsControllerException('There is no Price Book assigned to this Order');
            }
            return JSON.serialize(productsList);
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage(e.getMessage());
            throw auraException;
        }
    }

    public class ProductsControllerException extends Exception {}

}
